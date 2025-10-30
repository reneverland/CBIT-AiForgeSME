/**
 * 多语言配置
 */

export type Language = 'zh' | 'en'

export interface I18nMessages {
  // 通用
  common: {
    loading: string
    error: string
    confirm: string
    cancel: string
    clear: string
    send: string
  }
  // 导航栏
  header: {
    title: string
    subtitle: string
    language: string
  }
  // 聊天界面
  chat: {
    welcome: string
    description: string
    placeholder: string
    thinking: string
    noApp: string
    exampleQuestions: string[]
  }
  // 建议卡片
  suggestions: {
    title: string
    selectOne: string
    continue: string
  }
  // 联网搜索
  webSearch: {
    title: string
    message: string
    authorize: string
    cancel: string
  }
  // 消息
  message: {
    source: string
    confidence: string
    references: string
    user: string
    assistant: string
  }
}

// 中文语言包
const zhMessages: I18nMessages = {
  common: {
    loading: '加载中...',
    error: '错误',
    confirm: '确定',
    cancel: '取消',
    clear: '清空',
    send: '发送'
  },
  header: {
    title: 'CBIT-AiForge',
    subtitle: '智能问答平台',
    language: '语言'
  },
  chat: {
    welcome: '欢迎使用 CBIT-AiForge',
    description: '基于RAG的智能问答系统，请输入您的问题开始对话',
    placeholder: '输入你的问题...',
    thinking: '思考中...',
    noApp: '应用实例未配置',
    exampleQuestions: [
      '如何申请贵校的项目？',
      '学费是多少？',
      '有哪些奖学金机会？',
      '项目的入学要求是什么？'
    ]
  },
  suggestions: {
    title: '我猜您可能想问：',
    selectOne: '请选择一个问题，或点击「继续思考」让AI自由回答',
    continue: '继续思考'
  },
  webSearch: {
    title: '需要联网搜索',
    message: '知识库中未找到相关信息，是否授权使用联网搜索获取答案？',
    authorize: '授权搜索',
    cancel: '取消'
  },
  message: {
    source: '来源',
    confidence: '置信度',
    references: '参考文献',
    user: '用户',
    assistant: '助手'
  }
}

// 英文语言包
const enMessages: I18nMessages = {
  common: {
    loading: 'Loading...',
    error: 'Error',
    confirm: 'Confirm',
    cancel: 'Cancel',
    clear: 'Clear',
    send: 'Send'
  },
  header: {
    title: 'CBIT-AiForge',
    subtitle: 'AI Q&A Platform',
    language: 'Language'
  },
  chat: {
    welcome: 'Welcome to CBIT-AiForge',
    description: 'RAG-based intelligent Q&A system. Enter your question to start the conversation',
    placeholder: 'Type your question...',
    thinking: 'Thinking...',
    noApp: 'Application not configured',
    exampleQuestions: [
      'How to apply for your program?',
      'What is the tuition fee?',
      'What scholarship opportunities are available?',
      'What are the admission requirements?'
    ]
  },
  suggestions: {
    title: 'You might want to ask:',
    selectOne: 'Please select a question, or click "Continue" to let AI answer freely',
    continue: 'Continue Thinking'
  },
  webSearch: {
    title: 'Web Search Required',
    message: 'No relevant information found in knowledge base. Authorize web search to get an answer?',
    authorize: 'Authorize',
    cancel: 'Cancel'
  },
  message: {
    source: 'Source',
    confidence: 'Confidence',
    references: 'References',
    user: 'User',
    assistant: 'Assistant'
  }
}

// 语言包映射
const messages: Record<Language, I18nMessages> = {
  zh: zhMessages,
  en: enMessages
}

// 当前语言
let currentLanguage: Language = 'zh'

// 获取浏览器语言
const getBrowserLanguage = (): Language => {
  const lang = navigator.language.toLowerCase()
  if (lang.startsWith('zh')) return 'zh'
  return 'en'
}

// 从 localStorage 读取语言设置
const savedLanguage = localStorage.getItem('language') as Language
if (savedLanguage && (savedLanguage === 'zh' || savedLanguage === 'en')) {
  currentLanguage = savedLanguage
} else {
  currentLanguage = getBrowserLanguage()
}

// 导出 i18n 函数
export const useI18n = () => {
  const setLanguage = (lang: Language) => {
    currentLanguage = lang
    localStorage.setItem('language', lang)
  }

  const t = (): I18nMessages => {
    return messages[currentLanguage]
  }

  const getLanguage = () => currentLanguage

  return {
    t,
    setLanguage,
    getLanguage,
    language: currentLanguage
  }
}

