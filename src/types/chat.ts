/**
 * CBIT-AiForge 聊天相关类型定义
 * 与后端 API 接口保持一致
 */

// 消息角色
export type MessageRole = 'user' | 'assistant' | 'system'

// 应用实例
export interface Application {
  id: number
  name: string
  description: string
  mode: 'safe' | 'standard' | 'enhanced'
  mode_config: Record<string, any>
  ai_provider: string
  llm_model: string
  temperature: number
  api_key: string
  endpoint_path: string
  endpoint_url: string
  is_active: boolean
  total_requests: number
  total_tokens: number
  created_at: string
  updated_at: string
  full_config?: Record<string, any>
  mode_description?: string
  knowledge_bases?: KnowledgeBase[]
}

// 知识库
export interface KnowledgeBase {
  id: number
  name: string
  priority: number
  weight: number
  boost_factor: number
}

// 聊天消息
export interface ChatMessage {
  role: MessageRole
  content: string
  metadata?: MessageMetadata
  timestamp?: number
}

// 消息元数据
export interface MessageMetadata {
  source?: string
  source_display?: string
  retrieval_confidence?: number
  matched_source?: string
  matched_source_display?: string
  retrieval_path?: RetrievalPathItem[]
  references?: Reference[]
  suggestions?: Suggestion[]
  needs_confirmation?: boolean
  web_search_prompt?: boolean
  _strategy_info?: any
}

// 检索路径项
export interface RetrievalPathItem {
  source: string
  status: string
  message?: string
  results_count?: number
  confidence?: number
}

// 参考引用
export interface Reference {
  id?: number
  source_type: 'fixed_qa' | 'kb' | 'web' | 'tavily_answer' | 'tavily_web'
  question?: string
  content?: string
  kb_name?: string
  similarity?: number
  url?: string
  title?: string
}

// 建议问题
export interface Suggestion {
  question: string
  similarity: number
  qa_id?: number
}

// Chat Completion 请求
export interface ChatCompletionRequest {
  messages: ChatMessage[]
  temperature?: number
  max_tokens?: number
  stream?: boolean
  skip_fixed_qa?: boolean
  selected_qa_id?: number
  force_web_search?: boolean
}

// Chat Completion 响应
export interface ChatCompletionResponse {
  id: string
  object: string
  created: number
  model: string
  choices: Choice[]
  usage: Usage
  cbit_metadata?: CbitMetadata
}

// 选择项
export interface Choice {
  index: number
  message: ChatMessage
  finish_reason: string
}

// Token使用情况
export interface Usage {
  prompt_tokens?: number
  completion_tokens?: number
  total_tokens: number
}

// CBIT扩展元数据
export interface CbitMetadata {
  matched_fixed_qa?: boolean
  match_confidence?: number
  suggested_questions?: Suggestion[]
  retrieval_sources?: {
    fixed_qa: boolean
    vector_kb: boolean
    web_search: boolean
  }
  timing?: {
    retrieval_ms: number
    generation_ms: number
    total_ms: number
  }
  source_info?: {
    primary_source: string
    retrieval_source: string
    confidence: number
    confidence_level: string
  }
  needs_confirmation?: boolean
}

// 应用列表响应
export interface ApplicationsResponse {
  total: number
  applications: Application[]
}

