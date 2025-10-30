<template>
  <Teleport to="body">
    <div class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in" @click.self="emit('close')">
      <div class="bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[80vh] overflow-hidden animate-slide-up">
        <!-- 头部 -->
        <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <div>
            <h2 class="text-xl font-bold text-gray-800">选择应用实例</h2>
            <p class="text-sm text-gray-600 mt-1">选择一个应用开始对话</p>
          </div>
          <button
            @click="emit('close')"
            class="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
          >
            <X class="w-5 h-5 text-gray-500" />
          </button>
        </div>

        <!-- 应用列表 -->
        <div class="p-6 overflow-y-auto max-h-[calc(80vh-120px)]">
          <!-- 加载中 -->
          <div v-if="isLoadingApps" class="flex flex-col items-center justify-center py-12">
            <LoadingDots text="加载应用列表..." />
          </div>

          <!-- 错误提示 -->
          <div v-else-if="appsError" class="text-center py-12">
            <AlertCircle class="w-12 h-12 text-red-500 mx-auto mb-4" />
            <p class="text-gray-600 mb-4">{{ appsError }}</p>
            <button
              @click="appStore.loadApplications()"
              class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
            >
              重试
            </button>
          </div>

          <!-- 空状态 -->
          <div v-else-if="applications.length === 0" class="text-center py-12">
            <Database class="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p class="text-gray-600">暂无可用的应用实例</p>
            <p class="text-sm text-gray-500 mt-2">请联系管理员创建应用实例</p>
          </div>

          <!-- 应用卡片 -->
          <div v-else class="space-y-3">
            <button
              v-for="app in applications"
              :key="app.id"
              @click="handleSelect(app.id)"
              class="w-full p-4 bg-gradient-to-br from-white to-gray-50 rounded-xl border-2 border-gray-200 hover:border-blue-400 hover:shadow-lg transition-all text-left group"
            >
              <div class="flex items-start gap-4">
                <!-- 图标 -->
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center flex-shrink-0">
                  <Bot class="w-6 h-6 text-white" />
                </div>

                <!-- 信息 -->
                <div class="flex-1 min-w-0">
                  <h3 class="font-semibold text-gray-800 group-hover:text-blue-700 transition-colors mb-1">
                    {{ app.name }}
                  </h3>
                  <p class="text-sm text-gray-600 mb-2 line-clamp-2">
                    {{ app.description || '暂无描述' }}
                  </p>
                  
                  <!-- 标签 -->
                  <div class="flex flex-wrap gap-2">
                    <span class="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full">
                      {{ getModeLabel(app.mode) }}
                    </span>
                    <span class="px-2 py-1 bg-purple-100 text-purple-700 text-xs rounded-full">
                      {{ app.llm_model }}
                    </span>
                    <span v-if="app.knowledge_bases && app.knowledge_bases.length > 0" class="px-2 py-1 bg-green-100 text-green-700 text-xs rounded-full flex items-center gap-1">
                      <Database class="w-3 h-3" />
                      {{ app.knowledge_bases.length }}个知识库
                    </span>
                  </div>
                </div>

                <!-- 箭头 -->
                <ChevronRight class="w-5 h-5 text-gray-400 group-hover:text-blue-600 transition-colors flex-shrink-0 mt-2" />
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { X, Bot, ChevronRight, Database, AlertCircle } from 'lucide-vue-next'
import { useAppStore } from '@/stores/app'
import LoadingDots from './LoadingDots.vue'

const appStore = useAppStore()
const { applications, isLoadingApps, appsError } = storeToRefs(appStore)

const emit = defineEmits<{
  close: []
  select: [appId: number]
}>()

function handleSelect(appId: number) {
  emit('select', appId)
}

function getModeLabel(mode: string): string {
  const modeMap: Record<string, string> = {
    safe: '安全模式',
    standard: '标准模式',
    enhanced: '增强模式'
  }
  return modeMap[mode] || mode
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>

