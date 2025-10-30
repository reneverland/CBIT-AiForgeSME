<template>
  <div class="bg-gradient-to-br from-blue-50 to-purple-50 rounded-xl p-4 animate-slide-up">
    <!-- 标题 -->
    <div class="flex items-center gap-2 mb-3">
      <Lightbulb class="w-5 h-5 text-blue-600" />
      <h3 class="font-medium text-gray-800">{{ displayTitle }}</h3>
    </div>

    <!-- 建议列表 -->
    <div class="space-y-2">
      <button
        v-for="(suggestion, idx) in suggestions"
        :key="idx"
        @click="emit('select', suggestion)"
        class="w-full text-left px-4 py-3 bg-white rounded-lg hover:bg-blue-50 hover:border-blue-300 border border-gray-200 transition-all group"
      >
        <div class="flex items-start gap-3">
          <div class="flex-shrink-0 w-6 h-6 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center text-sm font-medium mt-0.5">
            {{ idx + 1 }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-gray-800 group-hover:text-blue-700 transition-colors">
              {{ suggestion.question }}
            </p>
            <div class="flex items-center gap-2 mt-1 text-xs text-gray-500">
              <span>{{ similarityText }}: {{ (suggestion.similarity * 100).toFixed(0) }}%</span>
              <div class="flex-1 bg-gray-200 rounded-full h-1.5 overflow-hidden">
                <div 
                  class="h-full bg-gradient-to-r from-blue-400 to-purple-500 transition-all"
                  :style="{ width: `${suggestion.similarity * 100}%` }"
                />
              </div>
            </div>
          </div>
          <ChevronRight class="w-5 h-5 text-gray-400 group-hover:text-blue-600 transition-colors flex-shrink-0" />
        </div>
      </button>
    </div>

    <!-- 继续思考按钮 -->
    <button
      v-if="showContinueButton"
      @click="emit('continue')"
      class="w-full mt-3 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors flex items-center justify-center gap-2"
    >
      <Search class="w-4 h-4" />
      <span>{{ continueText }}</span>
    </button>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Lightbulb, ChevronRight, Search } from 'lucide-vue-next'
import { useI18n } from '@/i18n'
import type { Suggestion } from '@/types/chat'

interface Props {
  suggestions: Suggestion[]
  title?: string
  showContinueButton?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  showContinueButton: true
})

const emit = defineEmits<{
  select: [suggestion: Suggestion]
  continue: []
}>()

const i18n = useI18n()

// 默认标题
const displayTitle = computed(() => {
  return props.title || i18n.t().suggestions.title
})

// 继续按钮文本
const continueText = computed(() => {
  return i18n.t().suggestions.continue
})

// 相似度文本
const similarityText = computed(() => {
  return i18n.getLanguage() === 'zh' ? '相似度' : 'Similarity'
})
</script>

