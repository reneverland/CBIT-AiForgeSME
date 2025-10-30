<template>
  <div class="bg-amber-50 border border-amber-200 rounded-xl p-4 animate-slide-up">
    <div class="flex items-start gap-3">
      <div class="flex-shrink-0 w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center">
        <AlertCircle class="w-5 h-5 text-amber-600" />
      </div>
      <div class="flex-1 min-w-0">
        <h3 class="font-medium text-gray-800 mb-1">{{ notFoundText }}</h3>
        <p class="text-sm text-gray-600 mb-3">
          {{ questionText }}
        </p>
        <p class="text-xs text-gray-500 mb-4 flex items-start gap-1">
          <Info class="w-3 h-3 flex-shrink-0 mt-0.5" />
          <span>{{ hintText }}</span>
        </p>
        <div class="flex gap-2">
          <button
            @click="emit('authorize')"
            class="flex-1 px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:shadow-lg transition-all flex items-center justify-center gap-2"
          >
            <Globe class="w-4 h-4" />
            <span>{{ authorizeButtonText }}</span>
          </button>
          <button
            @click="emit('cancel')"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
          >
            {{ cancelText }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { AlertCircle, Info, Globe } from 'lucide-vue-next'
import { useI18n } from '@/i18n'

const emit = defineEmits<{
  authorize: []
  cancel: []
}>()

const i18n = useI18n()

const notFoundText = computed(() => {
  return i18n.getLanguage() === 'zh' ? '知识库未找到相关信息' : 'No relevant information found in knowledge base'
})

const questionText = computed(() => {
  return i18n.getLanguage() === 'zh' 
    ? '是否愿意开启联网模块进行问题回答？' 
    : 'Would you like to enable web search to answer this question?'
})

const hintText = computed(() => {
  return i18n.getLanguage() === 'zh' 
    ? '提示：联网搜索结果来源于网络，仅供参考' 
    : 'Note: Web search results are from the internet for reference only'
})

const authorizeButtonText = computed(() => {
  return i18n.getLanguage() === 'zh' ? '启用联网搜索' : 'Enable Web Search'
})

const cancelText = computed(() => {
  return i18n.t().common.cancel
})
</script>

