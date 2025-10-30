/**
 * CBIT-AiForge API 服务
 * 与后端 /api 接口对接
 */

import axios, { AxiosInstance } from 'axios'
import type {
  Application,
  ApplicationsResponse,
  ChatCompletionRequest,
  ChatCompletionResponse
} from '@/types/chat'

// 创建 axios 实例
const apiClient: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 300000, // 5分钟超时（RAG检索可能需要较长时间）
  headers: {
    'Content-Type': 'application/json'
  }
})

// 响应拦截器
apiClient.interceptors.response.use(
  response => response,
  error => {
    console.error('API请求失败:', error)
    if (error.response) {
      // 服务器返回错误
      const errorMessage = error.response.data?.detail || error.response.data?.message || '请求失败'
      throw new Error(errorMessage)
    } else if (error.request) {
      // 请求发送但没有收到响应
      throw new Error('网络错误，请检查连接')
    } else {
      // 其他错误
      throw new Error(error.message || '未知错误')
    }
  }
)

/**
 * 获取所有应用实例（公开访问，无需认证）
 */
export async function fetchApplications(): Promise<ApplicationsResponse> {
  const response = await apiClient.get<ApplicationsResponse>('/applications/_public')
  return response.data
}

/**
 * 获取单个应用实例详情
 */
export async function fetchApplication(appId: number): Promise<Application> {
  const response = await apiClient.get<Application>(`/applications/${appId}`)
  return response.data
}

/**
 * 发送聊天消息
 * @param endpointPath 应用的endpoint路径
 * @param apiKey 应用的API密钥
 * @param request 聊天请求
 */
export async function sendChatMessage(
  endpointPath: string,
  apiKey: string,
  request: ChatCompletionRequest
): Promise<ChatCompletionResponse> {
  const response = await apiClient.post<ChatCompletionResponse>(
    `/apps/${endpointPath}/chat/completions`,
    request,
    {
      headers: {
        'Authorization': `Bearer ${apiKey}`
      }
    }
  )
  return response.data
}

/**
 * 发送流式聊天消息（SSE）
 * @param endpointPath 应用的endpoint路径
 * @param apiKey 应用的API密钥
 * @param request 聊天请求
 * @param onChunk 接收到数据块的回调
 * @param onComplete 完成时的回调
 * @param onError 错误时的回调
 */
export async function sendChatMessageStream(
  endpointPath: string,
  apiKey: string,
  request: ChatCompletionRequest,
  onChunk: (chunk: string) => void,
  onComplete: (metadata?: any) => void,
  onError: (error: Error) => void,
  onMetadata?: (metadata: any) => void  // 新增：实时处理 metadata 的回调
): Promise<void> {
  try {
    const response = await fetch(`/api/apps/${endpointPath}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({ ...request, stream: true })
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.detail || errorData.message || `HTTP ${response.status}`)
    }

    const reader = response.body?.getReader()
    if (!reader) {
      throw new Error('无法获取响应流')
    }

    const decoder = new TextDecoder()
    let buffer = ''
    let fullContent = ''
    let metadata: any = {}

    while (true) {
      const { done, value } = await reader.read()
      
      if (done) break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split('\n')
      buffer = lines.pop() || ''

      for (const line of lines) {
        if (line.trim() === '') continue
        if (!line.startsWith('data: ')) continue

        const data = line.slice(6).trim()
        if (data === '[DONE]') {
          onComplete(metadata)
          return
        }

        try {
          const json = JSON.parse(data)
          const content = json.choices?.[0]?.delta?.content || ''
          
          if (content) {
            fullContent += content
            onChunk(content)
          }

          // 保存metadata（最后一个chunk可能包含完整metadata）
          // 支持多种metadata格式：
          // 1. json.choices[0].message.metadata (完整消息中的metadata)
          // 2. json.choices[0].delta.metadata (流式增量中的metadata)
          // 3. json.metadata (直接格式)
          // 4. json.cbit_metadata (自定义格式)
          const messageMetadata = json.choices?.[0]?.message?.metadata
          const deltaMetadata = json.choices?.[0]?.delta?.metadata
          
          if (messageMetadata || deltaMetadata || json.metadata || json.cbit_metadata) {
            const newMetadata = {
              ...json.metadata,
              ...json.cbit_metadata,
              ...deltaMetadata,
              ...messageMetadata
            }
            
            metadata = {
              ...metadata,
              ...newMetadata
            }
            
            // 🔧 关键修复：后端返回的是 citations，需要映射为 references
            if (metadata.citations && metadata.citations.length > 0) {
              metadata.references = metadata.citations.map((citation: any) => ({
                source_type: citation.type === 'kb' ? 'knowledge_base' : citation.type,
                source_display: citation.label,
                kb_name: citation.source_name,
                content: citation.snippet,
                text_snippet: citation.snippet,
                similarity: citation._internal_score || 0,
                confidence_level: '高',
                source: citation.type,
                source_detail: `知识库「${citation.source_name}」`
              }))
              console.log('✅ 接收到来源:', metadata.references.length, '个')
            }
            
            // 向后兼容：也检查原有的 references 格式
            if (metadata.references && metadata.references.length > 0) {
              console.log('✅ 检测到 references:', metadata.references.length, '个来源')
            }
            
            // 🔥 核心修复：立即处理 Q&A 建议 metadata（不等到 [DONE]）
            if (newMetadata.needs_confirmation === true || newMetadata.suggested_questions) {
              console.log('🎯 实时检测到 Q&A 建议:', newMetadata.suggested_questions?.length, '个')
              if (onMetadata) {
                onMetadata(metadata)
              }
            }
          }
        } catch (e) {
          console.warn('解析SSE数据失败:', data, e)
        }
      }
    }

    onComplete(metadata)
  } catch (error) {
    onError(error as Error)
  }
}

/**
 * 健康检查
 */
export async function healthCheck(): Promise<{ status: string; service: string }> {
  const response = await apiClient.get('/health')
  return response.data
}

/**
 * 提交反馈
 */
export async function submitFeedback(
  applicationId: number,
  userMessage: string,
  aiResponse: string,
  rating: 'thumbs_up' | 'thumbs_down',
  comment?: string
): Promise<void> {
  await apiClient.post(`/conversations/${applicationId}/feedback`, {
    user_message: userMessage,
    ai_response: aiResponse,
    rating: rating,
    comment: comment
  })
}

export default {
  fetchApplications,
  fetchApplication,
  sendChatMessage,
  healthCheck,
  submitFeedback
}

