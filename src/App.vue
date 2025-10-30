<template>
  <div id="app">
    <ChatView />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import ChatView from '@/views/ChatView.vue'
import { useThemeStore } from '@/stores/theme'

// 初始化主题
const themeStore = useThemeStore()

onMounted(() => {
  // 主题会自动从 localStorage 读取并应用
  console.log('🎨 当前主题:', themeStore.theme)
})
</script>

<style>
/* App 特定样式已移至 style.css */
</style>

