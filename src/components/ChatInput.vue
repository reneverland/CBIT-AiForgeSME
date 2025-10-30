<template>
  <div class="border-t transition-colors duration-200"
       :class="isDark ? 'border-gpt-dark-border bg-gpt-dark-bg' : 'border-gray-100 bg-white'">
    <div class="max-w-3xl mx-auto px-4 py-4">
      <!-- 输入卡片 -->
      <div class="rounded-2xl shadow-lg transition-all duration-200"
           :class="isDark ? 'bg-gpt-dark-bg-alt border border-gpt-dark-border' : 'bg-white border border-gray-200'">
        <div class="px-4 py-3">
          <!-- 文本输入框 -->
          <textarea
            ref="textareaRef"
            v-model="inputText"
            @keydown.enter.exact.prevent="handleSend"
            @input="adjustHeight"
            :placeholder="isLoading ? '正在生成回复中...' : placeholder"
            :disabled="disabled || isLoading"
            rows="1"
            class="w-full resize-none bg-transparent border-none outline-none text-base transition-colors duration-200"
            :class="isDark ? 'text-gpt-dark-text placeholder-gpt-dark-text-secondary' : 'text-gray-900 placeholder-gray-400'"
            style="max-height: 200px; min-height: 24px;"
          />
        </div>

        <!-- 底部工具栏 -->
        <div class="px-4 pb-3 flex items-center justify-between border-t"
             :class="isDark ? 'border-gpt-dark-border' : 'border-gray-100'">
          <!-- 左侧模型标识 -->
          <div class="flex items-center pt-3">
            <span class="text-xs px-2 py-0.5 rounded-md transition-colors duration-200"
                  :class="isDark ? 'bg-gray-700/50 text-gray-400' : 'bg-gray-100 text-gray-500'">
              Model: CBIT-Elite v 4.0
            </span>
          </div>
          
          <!-- 右侧提示和发送 -->
          <div class="flex items-center gap-3 pt-3">
            <span class="text-xs transition-colors duration-200"
                  :class="isDark ? 'text-gpt-dark-text-secondary' : 'text-gray-400'">
              按 Enter 发送，Shift + Enter 换行
            </span>
            
            <!-- 发送按钮 -->
            <button
              @click="handleSend"
              :disabled="!canSend"
              class="p-2.5 rounded-lg flex items-center justify-center transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed"
              :class="sendButtonClass"
              title="发送 (Enter)"
            >
              <svg v-if="!isLoading" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
              <svg v-else class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>

    <!-- 免责声明 -->
    <div v-if="currentApp" class="mt-3 text-center">
      <span class="text-xs px-2.5 py-1 rounded-full transition-colors duration-200"
            :class="isDark ? 'bg-gpt-dark-bg-alt text-gpt-dark-text-secondary' : 'bg-gray-100 text-gray-500'">
        内容由大语言模型生成, 不代表香港中文大学(深圳)经管学院官方观点
      </span>
    </div>

      <!-- 错误提示 -->
      <div v-if="error" class="mt-3 p-3 rounded-lg flex items-start gap-2 transition-colors duration-200"
           :class="isDark ? 'bg-red-900/20 border border-red-800' : 'bg-red-50 border border-red-200'">
        <svg class="w-5 h-5 flex-shrink-0 mt-0.5" :class="isDark ? 'text-red-400' : 'text-red-600'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <div class="flex-1">
          <p class="text-sm font-medium transition-colors duration-200"
             :class="isDark ? 'text-red-400' : 'text-red-800'">
            {{ error }}
          </p>
        </div>
        <button @click="clearError" class="text-sm transition-colors duration-200 hover:opacity-70"
                :class="isDark ? 'text-red-400' : 'text-red-600'">
          关闭
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue'
import { useChatStore } from '@/stores/chat'
import { useThemeStore } from '@/stores/theme'

const chatStore = useChatStore()
const themeStore = useThemeStore()

const inputText = ref('')
const textareaRef = ref<HTMLTextAreaElement>()

const isDark = computed(() => themeStore.theme === 'dark')
const currentApp = computed(() => chatStore.currentApp)
const isLoading = computed(() => chatStore.isLoading)
const error = computed(() => chatStore.error)

const placeholder = computed(() => {
  if (!currentApp.value) return '请先选择一个应用...'
  return '请输入您的问题...'
})

const disabled = computed(() => !currentApp.value || isLoading.value)

const canSend = computed(() => {
  return inputText.value.trim().length > 0 && !disabled.value
})

// 发送按钮样式
const sendButtonClass = computed(() => {
  if (!canSend.value) {
    return isDark.value 
      ? 'bg-gpt-dark-bg-alt text-gpt-dark-text-secondary'
      : 'bg-gray-200 text-gray-400'
  }
  return isDark.value
    ? 'bg-cuhk-purple hover:bg-cuhk-dark text-white hover:scale-105'
    : 'bg-cuhk-purple hover:bg-cuhk-dark text-white hover:scale-105'
})

// 自动调整高度
function adjustHeight() {
  nextTick(() => {
    if (textareaRef.value) {
      textareaRef.value.style.height = 'auto'
      textareaRef.value.style.height = textareaRef.value.scrollHeight + 'px'
    }
  })
}

// 发送消息
async function handleSend() {
  if (!canSend.value) return
  
  const message = inputText.value.trim()
  inputText.value = ''
  
  // 重置高度
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto'
  }
  
  await chatStore.sendMessage(message)
}

// 清除错误
function clearError() {
  chatStore.error = null
}

// 监听应用切换，清空输入
watch(() => currentApp.value, () => {
  inputText.value = ''
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto'
  }
})
</script>
