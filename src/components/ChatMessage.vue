<template>
  <div class="w-full border-b transition-colors duration-200 message-animation"
       :class="isDark ? 'border-gpt-dark-border' : 'border-gray-100'">
    <div class="max-w-3xl mx-auto px-4 py-4">
      <div class="flex gap-4"
           :class="message.role === 'user' ? 'flex-row-reverse' : 'flex-row'">
        <!-- 头像 -->
        <div class="flex-shrink-0">
          <div v-if="message.role === 'assistant'" 
               class="w-8 h-8 rounded-lg flex items-center justify-center transition-colors duration-200"
               :class="isDark ? 'bg-cuhk-purple' : 'bg-cuhk-purple'">
            <i class="ri-robot-2-line text-white"></i>
          </div>
          <div v-else
               class="w-8 h-8 rounded-lg flex items-center justify-center transition-colors duration-200"
               :class="isDark ? 'bg-gradient-to-br from-purple-600 to-blue-600' : 'bg-gradient-to-br from-purple-500 to-blue-500'">
            <i class="ri-user-line text-white"></i>
          </div>
        </div>

        <!-- 消息内容 -->
        <div class="flex-1 min-w-0">
          <!-- 消息头部 -->
          <div class="flex items-center gap-2 mb-2"
               :class="message.role === 'user' ? 'justify-end' : 'justify-start'">
            <span class="text-sm font-semibold transition-colors duration-200"
                  :class="isDark ? 'text-gpt-dark-text' : 'text-gray-900'">
              {{ message.role === 'assistant' ? 'SME 智能助理' : '您' }}
            </span>
            <span class="text-xs transition-colors duration-200"
                  :class="isDark ? 'text-gpt-dark-text-secondary' : 'text-gray-500'">
              {{ formatTime(message.timestamp) }}
            </span>
          </div>

          <!-- 消息文本 -->
          <div v-if="message.content"
               class="prose prose-sm max-w-none transition-colors duration-200 relative"
               :class="[
                 message.role === 'user' 
                   ? 'text-right' 
                   : 'text-left',
                 isDark 
                   ? 'prose-invert text-gpt-dark-text' 
                   : 'text-gray-800'
               ]"
          >
            <!-- 思考中动态效果 -->
            <div v-if="message.content === '思考中...'" class="thinking-animation">
              <span class="thinking-icon">🤔</span>
              <span class="thinking-text-animated">正在思考</span>
              <span class="thinking-dots">
                <span class="dot">.</span>
                <span class="dot">.</span>
                <span class="dot">.</span>
              </span>
            </div>
            <!-- 正常内容 -->
            <div v-else v-html="renderedContent"></div>
            <!-- 🔥 打字机光标效果（仅在流式生成时显示） -->
            <span v-if="message.role === 'assistant' && isStreaming" 
                  class="typing-cursor"
                  :class="isDark ? 'typing-cursor-dark' : 'typing-cursor-light'"></span>
          </div>

          
          <!-- 参考文献 (折叠) -->
          <div v-if="message.role === 'assistant' && metadata && metadata.references && metadata.references.length > 0" 
               class="mt-4">
            <button 
              @click="showReferences = !showReferences"
              class="text-xs flex items-center gap-2 px-3 py-1.5 rounded-lg transition-all duration-200 hover:shadow-sm"
              :class="isDark 
                ? 'bg-gpt-dark-bg-alt text-gray-300 hover:bg-gpt-dark-border' 
                : 'bg-blue-50 text-blue-700 hover:bg-blue-100'"
            >
              <i class="ri-book-line"></i>
              <span class="font-medium">参考来源 ({{ metadata.references.length }})</span>
              <i :class="showReferences ? 'ri-arrow-up-s-line' : 'ri-arrow-down-s-line'"></i>
            </button>
            
            <div v-if="showReferences" class="mt-3 space-y-2 animate-slide-up">
              <div 
                v-for="(ref, idx) in metadata.references.slice(0, 3)" 
                :key="idx"
                class="text-xs p-3 rounded-lg border transition-colors duration-200"
                :class="isDark 
                  ? 'bg-gpt-dark-bg-alt border-gpt-dark-border' 
                  : 'bg-white border-gray-200 shadow-sm'"
              >
                <div class="flex items-center gap-2 mb-1">
                  <span class="px-2 py-0.5 rounded text-xs font-bold"
                        :class="isDark 
                          ? 'bg-cuhk-purple/30 text-cuhk-light' 
                          : 'bg-cuhk-purple/10 text-cuhk-purple'">
                    {{ ref.source_type === 'fixed_qa' ? 'Q&A' : 'KB' }}
                  </span>
                  <span class="font-semibold transition-colors duration-200"
                        :class="isDark ? 'text-gpt-dark-text' : 'text-gray-900'">
                    {{ ref.source_type === 'fixed_qa' ? 'Q&A' : ref.kb_name }}
                  </span>
                </div>
                <div class="line-clamp-2 opacity-70 transition-colors duration-200"
                     :class="isDark ? 'text-gpt-dark-text-secondary' : 'text-gray-600'">
                  {{ ref.content || ref.question }}
                </div>
              </div>
            </div>
          </div>

          <!-- 反馈按钮 (仅AI消息) -->
          <div v-if="message.role === 'assistant'" class="mt-4 flex items-center gap-3">
        <button 
          @click="submitFeedback('thumbs_up')"
          class="flex items-center gap-1 text-xs opacity-60 hover:opacity-100 transition-all duration-200"
          :class="feedbackRating === 'thumbs_up' ? 'text-green-600' : (isDark ? 'text-gray-400' : 'text-gray-500')"
          title="有帮助"
        >
          <i class="ri-thumb-up-line text-base"></i>
          <span v-if="feedbackRating === 'thumbs_up'">已反馈</span>
        </button>
        
        <button 
          @click="submitFeedback('thumbs_down')"
          class="flex items-center gap-1 text-xs opacity-60 hover:opacity-100 transition-all duration-200"
          :class="feedbackRating === 'thumbs_down' ? 'text-red-600' : (isDark ? 'text-gray-400' : 'text-gray-500')"
          title="没帮助"
        >
          <i class="ri-thumb-down-line text-base"></i>
          <span v-if="feedbackRating === 'thumbs_down'">已反馈</span>
        </button>

        <button 
          @click="copyMessage"
          class="flex items-center gap-1 text-xs opacity-60 hover:opacity-100 transition-all duration-200"
          :class="isDark ? 'text-gray-400' : 'text-gray-500'"
          title="复制"
        >
          <i v-if="!copied" class="ri-file-copy-line text-base"></i>
          <i v-else class="ri-check-line text-base text-green-600"></i>
        </button>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <!-- 反馈对话框 -->
  <div v-if="showFeedbackDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl max-w-md w-full p-6 animate-slide-up">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold" :class="isDark ? 'text-gray-100' : 'text-gray-900'">
              感谢您的反馈
            </h3>
            <button 
              @click="cancelFeedback"
              class="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            >
              <i class="ri-close-line text-xl" :class="isDark ? 'text-gray-400' : 'text-gray-500'"></i>
            </button>
          </div>

          <p class="text-sm mb-4" :class="isDark ? 'text-gray-300' : 'text-gray-600'">
            为了帮助我们改进，您可以填写正确答案（可选）：
          </p>

          <textarea
            v-model="correctAnswer"
            placeholder="请输入您认为的正确答案..."
            class="w-full h-32 px-4 py-3 border rounded-lg resize-none text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            :class="isDark 
              ? 'bg-gray-700 border-gray-600 text-gray-100 placeholder-gray-400' 
              : 'bg-white border-gray-300 text-gray-900 placeholder-gray-400'"
          ></textarea>

          <div class="flex items-center gap-3 mt-4">
            <button
              @click="submitFeedbackWithAnswer"
              class="flex-1 bg-primary hover:bg-primary/90 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors"
            >
              提交反馈
            </button>
            <button
              @click="cancelFeedback"
              class="px-4 py-2.5 rounded-lg text-sm font-medium transition-colors"
              :class="isDark 
                ? 'bg-gray-700 hover:bg-gray-600 text-gray-200' 
                : 'bg-gray-200 hover:bg-gray-300 text-gray-700'"
            >
              取消
            </button>
          </div>
        </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import { useThemeStore } from '@/stores/theme'
import { useChatStore } from '@/stores/chat'
import type { ChatMessage } from '@/types/chat'

interface Props {
  message: ChatMessage
  showMetadata?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showMetadata: true
})

const themeStore = useThemeStore()
const chatStore = useChatStore()
const showReferences = ref(false)
const copied = ref(false)
const feedbackRating = ref<'thumbs_up' | 'thumbs_down' | null>(null)
const showFeedbackDialog = ref(false)
const correctAnswer = ref('')

const isDark = computed(() => themeStore.theme === 'dark')
const metadata = computed(() => props.message.metadata)

// 🔥 检测是否正在流式生成
const isStreaming = computed(() => {
  return props.message.role === 'assistant' && 
         chatStore.isLoading && 
         props.message.content !== '思考中...'
})

// 格式化时间
function formatTime(timestamp?: number): string {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  return `${hours}:${minutes}`
}

// 优化的Markdown渲染 - 增强视觉效果
const renderedContent = computed(() => {
  if (!props.message.content) return ''
  
  try {
    // 配置Markdown渲染器
    marked.setOptions({
      breaks: true,
      gfm: true
    })
    
    let content = props.message.content
    
    // 1. 识别并美化百分比数据（添加进度条）
    content = content.replace(/(\d+\.?\d*)%/g, (match, num) => {
      const percentage = parseFloat(num)
      return `<span class="percentage-badge" data-value="${percentage}">${match}</span>`
    })
    
    // 2. 识别并美化金额数据
    content = content.replace(/(\d+\.?\d*万元|￥\d+\.?\d*)/g, (match) => {
      return `<span class="money-badge">${match}</span>`
    })
    
    // 3. 识别关键词并高亮
    const keywords = ['整体去向', '就业薪资', '行业分布', '升学情况', '地域分布', '建议行动']
    keywords.forEach(keyword => {
      const regex = new RegExp(`(${keyword})[：:]`, 'g')
      content = content.replace(regex, `<strong class="section-title">$1：</strong>`)
    })
    
    // 4. 识别列表项（中文顿号、逗号分隔）
    content = content.replace(/([^。！？\n]+)[、，]([^。！？\n]+)[、，]([^。！？\n]+)/g, (match) => {
      // 如果包含冒号，可能是列表
      if (match.includes('：') || match.includes(':')) {
        return match // 保持原样
      }
      return match
    })
    
    // 5. 渲染Markdown
    const html = marked(content) as string
    
    // 6. 后处理：添加进度条可视化
    let processedHtml = html.replace(/<span class="percentage-badge" data-value="([\d.]+)">([^<]+)<\/span>/g, 
      (_match, value, text) => {
        const percentage = parseFloat(value)
        const color = percentage >= 80 ? '#10b981' : percentage >= 60 ? '#3b82f6' : '#f59e0b'
        return `
          <span class="inline-flex items-center gap-2">
            <span class="percentage-text font-bold" style="color: ${color}">${text}</span>
            <span class="progress-bar-mini" style="--percentage: ${percentage}%; --color: ${color}"></span>
          </span>
        `
      }
    )
    
    return DOMPurify.sanitize(processedHtml, {
      ADD_ATTR: ['style', 'data-value'],
      ADD_TAGS: ['span']
    })
  } catch (error) {
    console.error('Markdown渲染失败:', error)
    return props.message.content
  }
})

// 复制消息
function copyMessage() {
  navigator.clipboard.writeText(props.message.content).then(() => {
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2000)
  })
}

// 提交反馈
async function submitFeedback(rating: 'thumbs_up' | 'thumbs_down') {
  if (feedbackRating.value === rating) return // 防止重复点击
  
  // 如果是差评，弹出对话框让用户填写正确答案
  if (rating === 'thumbs_down') {
    showFeedbackDialog.value = true
    return
  }
  
  // 好评直接提交
  feedbackRating.value = rating
  await chatStore.submitFeedback(props.message, rating)
  console.log(`反馈已提交: ${rating}`)
}

// 提交带正确答案的反馈
async function submitFeedbackWithAnswer() {
  if (!correctAnswer.value.trim() && showFeedbackDialog.value) {
    // 如果没填写正确答案，询问是否仅提交差评
    if (!confirm('您未填写正确答案，是否仅提交"不满意"反馈？')) {
      return
    }
  }
  
  feedbackRating.value = 'thumbs_down'
  await chatStore.submitFeedback(props.message, 'thumbs_down', correctAnswer.value.trim())
  
  showFeedbackDialog.value = false
  correctAnswer.value = ''
  console.log('反馈已提交（含正确答案）')
}

// 取消反馈对话框
function cancelFeedback() {
  showFeedbackDialog.value = false
  correctAnswer.value = ''
}
</script>

<style scoped>
/* 🔧 思考中动态动画效果 */
.thinking-animation {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(59, 130, 246, 0.1) 100%);
  border-radius: 12px;
  border: 1px solid rgba(139, 92, 246, 0.2);
}

.thinking-icon {
  font-size: 1.5rem;
  animation: thinking-bounce 1s ease-in-out infinite;
}

@keyframes thinking-bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-4px);
  }
}

.thinking-text-animated {
  font-weight: 500;
  color: #7c3aed;
  animation: thinking-pulse 2s ease-in-out infinite;
}

.dark .thinking-text-animated {
  color: #a78bfa;
}

@keyframes thinking-pulse {
  0%, 100% {
    opacity: 0.7;
  }
  50% {
    opacity: 1;
  }
}

.thinking-dots {
  display: flex;
  gap: 2px;
}

.thinking-dots .dot {
  font-size: 1.2rem;
  font-weight: bold;
  color: #7c3aed;
  animation: dot-wave 1.4s ease-in-out infinite;
}

.dark .thinking-dots .dot {
  color: #a78bfa;
}

.thinking-dots .dot:nth-child(1) {
  animation-delay: 0s;
}

.thinking-dots .dot:nth-child(2) {
  animation-delay: 0.2s;
}

.thinking-dots .dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes dot-wave {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.4;
  }
  30% {
    transform: translateY(-6px);
    opacity: 1;
  }
}

/* 🔥 打字机光标效果 */
.typing-cursor {
  display: inline-block;
  width: 2px;
  height: 1.2em;
  margin-left: 2px;
  vertical-align: text-bottom;
  animation: blink 1s step-end infinite;
}

.typing-cursor-light {
  background-color: #7c3aed;
}

.typing-cursor-dark {
  background-color: #a78bfa;
}

@keyframes blink {
  0%, 50% {
    opacity: 1;
  }
  50.1%, 100% {
    opacity: 0;
  }
}
</style>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.message-animation {
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-up {
  animation: slideUp 0.2s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ========== 增强的内容样式 ========== */

/* 段落标题样式 */
:deep(.section-title) {
  display: inline-block;
  font-size: 1.1em;
  font-weight: 700;
  color: #7c3aed;
  margin-top: 1em;
  margin-bottom: 0.5em;
  padding-bottom: 0.3em;
  border-bottom: 2px solid #7c3aed;
}

.dark :deep(.section-title) {
  color: #fbbf24;
  border-bottom-color: #fbbf24;
}

/* 百分比徽章 */
:deep(.percentage-text) {
  font-size: 1.1em;
  font-weight: 700;
}

/* 迷你进度条 */
:deep(.progress-bar-mini) {
  display: inline-block;
  width: 60px;
  height: 6px;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 3px;
  position: relative;
  overflow: hidden;
}

.dark :deep(.progress-bar-mini) {
  background: rgba(255, 255, 255, 0.1);
}

:deep(.progress-bar-mini)::after {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: var(--percentage);
  background: var(--color);
  border-radius: 3px;
  transition: width 0.3s ease;
}

/* 金额徽章 */
:deep(.money-badge) {
  display: inline-block;
  padding: 0.2em 0.6em;
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  color: white;
  border-radius: 0.5em;
  font-weight: 600;
  font-size: 0.95em;
  box-shadow: 0 2px 4px rgba(251, 191, 36, 0.3);
}

/* Prose样式增强 */
:deep(.prose) {
  max-width: none;
}

:deep(.prose p) {
  margin-bottom: 1em;
  line-height: 1.8;
}

:deep(.prose strong) {
  font-weight: 600;
  color: #1f2937;
}

.dark :deep(.prose strong) {
  color: #fbbf24;
  font-weight: 700;
}

:deep(.prose ul),
:deep(.prose ol) {
  margin-left: 1.5em;
  margin-bottom: 1em;
}

:deep(.prose li) {
  margin-bottom: 0.5em;
  padding-left: 0.5em;
}

:deep(.prose ul li) {
  list-style-type: disc;
}

:deep(.prose ol li) {
  list-style-type: decimal;
}

/* 代码块样式 */
:deep(.prose code) {
  background: rgba(124, 58, 237, 0.1);
  color: #7c3aed;
  padding: 0.2em 0.4em;
  border-radius: 0.3em;
  font-size: 0.9em;
  font-family: 'Monaco', 'Courier New', monospace;
}

.dark :deep(.prose code) {
  background: rgba(167, 139, 250, 0.2);
  color: #a78bfa;
}

:deep(.prose pre) {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 0.5em;
  padding: 1em;
  overflow-x: auto;
  margin: 1em 0;
}

.dark :deep(.prose pre) {
  background: #1e293b;
  border-color: #334155;
}

:deep(.prose pre code) {
  background: none;
  color: inherit;
  padding: 0;
}

/* 引用样式 */
:deep(.prose blockquote) {
  border-left: 4px solid #7c3aed;
  padding-left: 1em;
  margin: 1em 0;
  font-style: italic;
  color: #6b7280;
}

.dark :deep(.prose blockquote) {
  border-left-color: #a78bfa;
  color: #9ca3af;
}

/* 表格样式 */
:deep(.prose table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1em 0;
  font-size: 0.9em;
}

:deep(.prose th),
:deep(.prose td) {
  padding: 0.75em;
  border: 1px solid #e2e8f0;
  text-align: left;
}

.dark :deep(.prose th),
.dark :deep(.prose td) {
  border-color: #334155;
}

:deep(.prose th) {
  background: #f8fafc;
  font-weight: 600;
}

.dark :deep(.prose th) {
  background: #1e293b;
}

:deep(.prose tr:hover) {
  background: #f8fafc;
}

.dark :deep(.prose tr:hover) {
  background: #1e293b;
}
</style>
