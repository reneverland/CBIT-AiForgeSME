/**
 * 聊天状态管理 - Pinia Store
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Application, ChatMessage, ChatCompletionRequest } from '@/types/chat'
import { sendChatMessageStream } from '@/api/chat'

export const useChatStore = defineStore('chat', () => {
  // 状态
  const currentApp = ref<Application | null>(null)
  const messages = ref<ChatMessage[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  
  // 待确认的建议问题
  const pendingSuggestions = ref<any[]>([])
  const needsConfirmation = ref(false)
  
  // 是否需要联网搜索授权
  const needsWebSearchAuth = ref(false)

  // 计算属性
  const hasMessages = computed(() => messages.value.length > 0)
  const lastMessage = computed(() => 
    messages.value.length > 0 ? messages.value[messages.value.length - 1] : null
  )

  /**
   * 设置当前应用
   */
  function setCurrentApp(app: Application) {
    currentApp.value = app
    // 切换应用时清空消息历史
    messages.value = []
    error.value = null
  }

  /**
   * 添加消息到历史记录
   */
  function addMessage(message: ChatMessage) {
    messages.value.push({
      ...message,
      timestamp: message.timestamp || Date.now()
    })
  }

  /**
   * 发送用户消息（流式输出版本）
   */
  async function sendMessage(
    content: string,
    options: {
      skip_fixed_qa?: boolean
      selected_qa_id?: number
      force_web_search?: boolean
    } = {}
  ) {
    if (!currentApp.value) {
      error.value = '请先选择应用实例'
      return
    }

    if (!content.trim()) {
      return
    }

    // 🔧 关键修复：在发送新消息前立即清除旧的建议状态
    needsConfirmation.value = false
    pendingSuggestions.value = []
    needsWebSearchAuth.value = false
    error.value = null

    // 添加用户消息
    const userMessage: ChatMessage = {
      role: 'user',
      content: content.trim(),
      timestamp: Date.now()
    }
    addMessage(userMessage)

    // 设置加载状态
    isLoading.value = true

    // 创建一个临时的assistant消息用于流式输出
    const assistantMessage: ChatMessage = {
      role: 'assistant',
      content: '思考中...', // 🔧 修复：显示"思考中..."而不是空内容
      timestamp: Date.now()
    }
    addMessage(assistantMessage)
    const messageIndex = messages.value.length - 1

    try {
      // 构建请求 - 包含完整对话历史（除了最后一条占位消息）
      const historyMessages = messages.value.slice(0, -1).map(msg => ({
        role: msg.role,
        content: msg.content
      }))
      
      // 🔍 调试日志：确认对话历史
      console.log('📤 发送请求 - 对话历史:', historyMessages.length, '条消息')
      console.log('📝 最新问题:', content.trim())
      if (historyMessages.length > 0) {
        console.log('💬 完整历史:', historyMessages.map(m => `${m.role}: ${m.content.substring(0, 50)}...`))
      }
      
      const request: ChatCompletionRequest = {
        messages: historyMessages,
        temperature: currentApp.value.temperature,
        stream: true, // ✅ 启用流式输出
        ...options
      }
      
      // 🔍 调试：检查请求选项
      if (options.selected_qa_id) {
        console.log('🎯 使用固定Q&A:', options.selected_qa_id)
      }
      if (options.skip_fixed_qa) {
        console.log('⚡ 跳过固定Q&A，使用RAG')
      }

      // 🚀 优化：批量更新chunk，减少DOM渲染频率
      let chunkBuffer = ''
      let updateTimer: number | null = null
      const CHUNK_UPDATE_INTERVAL = 50 // 50ms更新一次，平衡流畅度和性能

      // 调用流式API
      await sendChatMessageStream(
        currentApp.value.endpoint_path,
        currentApp.value.api_key,
        request,
        // onChunk: 接收到数据块时更新消息（批量更新）
        (chunk: string) => {
          if (messageIndex < messages.value.length) {
            // 🔧 修复：第一个chunk到达时，清除"思考中..."
            if (messages.value[messageIndex].content === '思考中...') {
              messages.value[messageIndex].content = ''
            }
            
            // 将chunk加入缓冲区
            chunkBuffer += chunk
            
            // 使用定时器批量更新，减少DOM操作
            if (updateTimer) {
              clearTimeout(updateTimer)
            }
            updateTimer = window.setTimeout(() => {
              if (messageIndex < messages.value.length && chunkBuffer) {
                messages.value[messageIndex].content += chunkBuffer
                chunkBuffer = ''
              }
            }, CHUNK_UPDATE_INTERVAL)
          }
        },
        // onComplete: 流式传输完成
        (metadata?: any) => {
          // 🚀 清除定时器，立即应用剩余的buffer
          if (updateTimer) {
            clearTimeout(updateTimer)
          }
          if (messageIndex < messages.value.length && chunkBuffer) {
            messages.value[messageIndex].content += chunkBuffer
            chunkBuffer = ''
          }
          
          if (messageIndex < messages.value.length && metadata) {
            messages.value[messageIndex].metadata = metadata

            // 🔧 关键修复：只有当metadata明确包含needs_confirmation时才显示建议
            // 避免旧的建议卡片残留
            if (metadata.needs_confirmation === true) {
              needsConfirmation.value = true
              pendingSuggestions.value = metadata.suggested_questions || []
              
              // 如果没有内容但有建议，添加提示消息
              if (!messages.value[messageIndex].content && pendingSuggestions.value.length > 0) {
                messages.value[messageIndex].content = '我找到了一些相关的问题，请选择：'
              }
            } else {
              // 明确没有建议时，确保清除状态
              needsConfirmation.value = false
              pendingSuggestions.value = []
            }

            // 检查是否需要联网搜索授权
            if (metadata.web_search_prompt === true) {
              needsWebSearchAuth.value = true
            } else {
              needsWebSearchAuth.value = false
            }
          }
          isLoading.value = false
        },
        // onError: 发生错误
        (err: Error) => {
          error.value = err.message || '发送消息失败'
          console.error('发送消息失败:', err)
          
          // 更新错误消息
          if (messageIndex < messages.value.length) {
            messages.value[messageIndex].content = `❌ 抱歉，发生了错误：${error.value}`
          }
          isLoading.value = false
        },
        // onMetadata: 实时处理 metadata（仅保存，不立即显示建议）
        (metadata: any) => {
          console.log('🎯 实时接收到 metadata:', metadata)
          
          // 立即清除"思考中..."
          if (messageIndex < messages.value.length && messages.value[messageIndex].content === '思考中...') {
            messages.value[messageIndex].content = ''
          }
          
          // 🔧 修复：只保存 metadata，不立即显示建议问题
          // 建议问题将在 onComplete 中处理，确保先显示回答再显示建议
          if (messageIndex < messages.value.length) {
            messages.value[messageIndex].metadata = metadata
          }
          
          console.log('📝 metadata 已保存，建议问题将在回答完成后显示')
        }
      )

    } catch (err: any) {
      error.value = err.message || '发送消息失败'
      console.error('发送消息失败:', err)
      
      // 更新错误消息
      if (messageIndex < messages.value.length) {
        messages.value[messageIndex].content = `❌ 抱歉，发生了错误：${error.value}`
      }
      isLoading.value = false
    }
  }

  /**
   * 选择建议的Q&A
   */
  async function selectSuggestion(qaId: number, question: string) {
    // 🔧 修复：选择建议时，立即清除建议卡片
    needsConfirmation.value = false
    pendingSuggestions.value = []
    
    // 发送用户选择的问题
    await sendMessage(question, { selected_qa_id: qaId })
  }

  /**
   * 继续思考（跳过固定Q&A）
   */
  async function continueThinking(originalQuestion: string) {
    // 🔧 修复：继续思考时，立即清除建议卡片
    needsConfirmation.value = false
    pendingSuggestions.value = []
    
    // 使用原始问题重新发送，跳过固定Q&A
    // 先移除最后一条AI消息（建议消息）
    if (messages.value.length > 0 && messages.value[messages.value.length - 1].role === 'assistant') {
      messages.value.pop()
    }
    
    await sendMessage(originalQuestion, { skip_fixed_qa: true })
  }

  /**
   * 授权联网搜索
   */
  async function authorizeWebSearch(originalQuestion: string) {
    // 🔧 修复：授权联网搜索时，立即清除旧状态
    needsConfirmation.value = false
    pendingSuggestions.value = []
    needsWebSearchAuth.value = false
    
    // 移除最后一条提示消息
    if (messages.value.length > 0 && messages.value[messages.value.length - 1].role === 'assistant') {
      messages.value.pop()
    }
    
    await sendMessage(originalQuestion, { force_web_search: true })
  }

  /**
   * 清空聊天历史
   */
  function clearMessages() {
    messages.value = []
    error.value = null
    needsConfirmation.value = false
    needsWebSearchAuth.value = false
    pendingSuggestions.value = []
  }

  /**
   * 提交反馈
   */
  async function submitFeedback(message: ChatMessage, rating: 'thumbs_up' | 'thumbs_down', comment?: string) {
    if (!currentApp.value) return
    
    try {
      // 找到上一条用户消息
      const messageIndex = messages.value.indexOf(message)
      let userMessage = ''
      for (let i = messageIndex - 1; i >= 0; i--) {
        if (messages.value[i].role === 'user') {
          userMessage = messages.value[i].content
          break
        }
      }

      // 调用后端API提交反馈
      await import('@/api/chat').then(module => {
        return module.submitFeedback(
          currentApp.value!.id,
          userMessage,
          message.content,
          rating,
          comment
        )
      })
      
      console.log('反馈提交成功', comment ? '（含正确答案）' : '')
    } catch (err) {
      console.error('提交反馈失败:', err)
    }
  }

  return {
    // 状态
    currentApp,
    messages,
    isLoading,
    error,
    pendingSuggestions,
    needsConfirmation,
    needsWebSearchAuth,
    
    // 计算属性
    hasMessages,
    lastMessage,
    
    // 方法
    setCurrentApp,
    addMessage,
    sendMessage,
    selectSuggestion,
    continueThinking,
    authorizeWebSearch,
    clearMessages,
    submitFeedback
  }
})

