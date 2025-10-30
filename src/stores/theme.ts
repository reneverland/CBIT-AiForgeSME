/**
 * 主题管理 - Pinia Store
 */

import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export type Theme = 'light' | 'dark'

export const useThemeStore = defineStore('theme', () => {
  // 从 localStorage 读取或默认为浅色
  const theme = ref<Theme>((localStorage.getItem('theme') as Theme) || 'light')

  // 切换主题
  function toggleTheme() {
    theme.value = theme.value === 'light' ? 'dark' : 'light'
  }

  // 设置主题
  function setTheme(newTheme: Theme) {
    theme.value = newTheme
  }

  // 监听主题变化，更新 DOM 和 localStorage
  watch(theme, (newTheme) => {
    // 更新 body class
    if (newTheme === 'dark') {
      document.documentElement.classList.add('dark')
      document.body.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
      document.body.classList.remove('dark')
    }
    
    // 保存到 localStorage
    localStorage.setItem('theme', newTheme)
  }, { immediate: true })

  return {
    theme,
    toggleTheme,
    setTheme
  }
})

