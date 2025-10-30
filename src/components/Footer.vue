<template>
  <footer class="text-center py-6 space-y-2 theme-transition"
          :class="isDark ? 'bg-gpt-dark-bg text-gpt-dark-text' : 'bg-white text-gray-800'">
    <div class="flex items-center justify-center space-x-6 text-xs"
         :class="isDark ? 'text-gray-400' : 'text-gray-500'">
      <a href="https://github.com/reneverland/" 
         target="_blank"
         rel="noopener noreferrer"
         class="flex items-center space-x-2 hover:text-primary transition-colors duration-200">
        <div class="w-4 h-4 flex items-center justify-center">
          <i class="ri-github-line"></i>
        </div>
        <span>GitHub</span>
      </a>
      <a href="https://cbit.cuhk.edu.cn" 
         target="_blank"
         rel="noopener noreferrer"
         class="flex items-center space-x-2 hover:text-primary transition-colors duration-200">
        <div class="w-4 h-4 flex items-center justify-center">
          <i class="ri-links-line"></i>
        </div>
        <span>SME-CBIT开发</span>
      </a>
    </div>
    <p class="text-xs"
       :class="isDark ? 'text-gray-500' : 'text-gray-400'">
      © 2025 SME 智能助手
    </p>
  </footer>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useThemeStore } from '@/stores/theme'

const themeStore = useThemeStore()
const isDark = computed(() => themeStore.theme === 'dark')
</script>

