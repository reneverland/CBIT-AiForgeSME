<template>
  <nav class="border-b shadow-sm theme-transition px-4 py-1.5"
       :class="isDark ? 'bg-gpt-dark-bg border-gpt-dark-border text-gpt-dark-text' : 'bg-gray-800 border-gray-700 text-gray-100'">
    <div class="flex items-center justify-between max-w-7xl mx-auto">
      <!-- 左侧：Logo -->
      <div class="flex items-center py-0.5">
        <img 
          src="/cbit-logo.png" 
          alt="SME Logo" 
          class="h-12 w-auto object-contain"
        />
      </div>

      <!-- 右侧：主题切换 + 清空对话 -->
      <div class="flex items-center space-x-4">
        <!-- 主题切换按钮 -->
        <button 
          @click="toggleTheme"
          class="w-10 h-10 flex items-center justify-center rounded-full transition-all duration-200"
          :class="isDark ? 'bg-gray-700 hover:bg-gray-600' : 'bg-gray-700 hover:bg-gray-600'"
          :title="isDark ? '切换到白天模式' : '切换到夜间模式'"
        >
          <i v-if="!isDark" class="ri-sun-line text-lg text-gray-200"></i>
          <i v-else class="ri-moon-line text-lg text-gray-200"></i>
        </button>

        <!-- 清空对话按钮 -->
        <button
          v-if="hasMessages"
          @click="clearChat"
          class="w-10 h-10 flex items-center justify-center rounded-full transition-all duration-200"
          :class="isDark ? 'bg-gray-700 hover:bg-gray-600' : 'bg-gray-700 hover:bg-gray-600'"
          title="清空对话"
        >
          <i class="ri-delete-bin-line text-lg text-gray-200"></i>
        </button>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useThemeStore } from '@/stores/theme'
import { useChatStore } from '@/stores/chat'

const themeStore = useThemeStore()
const chatStore = useChatStore()

const isDark = computed(() => themeStore.theme === 'dark')
const hasMessages = computed(() => chatStore.hasMessages)

function toggleTheme() {
  themeStore.toggleTheme()
}

function clearChat() {
  if (confirm('确定要清空当前对话吗？')) {
    chatStore.clearMessages()
  }
}
</script>

