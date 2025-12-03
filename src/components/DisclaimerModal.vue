<template>
  <div v-if="showModal" 
       class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50 animate-fade-in">
    <div class="rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto"
         :class="isDark ? 'bg-gray-800 border-2 border-gray-600' : 'bg-white'">
      <!-- 顶部图标和标题 -->
      <div class="p-6 pb-4">
        <div class="flex items-center justify-center mb-4">
          <div class="w-16 h-16 bg-gradient-to-br from-purple-500 to-indigo-600 rounded-full flex items-center justify-center">
            <i class="ri-information-line text-3xl text-white"></i>
          </div>
        </div>
        <h2 class="text-2xl font-bold text-center mb-2"
            :class="isDark ? 'text-white' : 'text-gray-900'">
          欢迎使用 SME AI Assistant
        </h2>
        <p class="text-center text-sm"
           :class="isDark ? 'text-gray-300' : 'text-gray-600'">
          香港中文大学（深圳）经管学院智能助手
        </p>
      </div>

      <!-- 免责声明内容 -->
      <div class="px-6 pb-6 space-y-4">
        <!-- 中文版本 -->
        <div class="p-4 rounded-lg"
             :class="isDark ? 'bg-gray-700' : 'bg-gray-50'">
          <h3 class="font-semibold mb-2 flex items-center gap-2"
              :class="isDark ? 'text-white' : 'text-gray-900'">
            <i class="ri-alert-line text-amber-500"></i>
            重要声明
          </h3>
          <p class="text-sm leading-relaxed"
             :class="isDark ? 'text-gray-200' : 'text-gray-700'">
            请将该人工智能的回复作为参考，不代表香港中文大学（深圳）经管学院的官方观点。
          </p>
        </div>

        <!-- 英文版本 -->
        <div class="p-4 rounded-lg"
             :class="isDark ? 'bg-gray-700' : 'bg-gray-50'">
          <h3 class="font-semibold mb-2 flex items-center gap-2"
              :class="isDark ? 'text-white' : 'text-gray-900'">
            <i class="ri-file-shield-line text-blue-500"></i>
            Data Processing Agreement
          </h3>
          <p class="text-sm leading-relaxed"
             :class="isDark ? 'text-gray-200' : 'text-gray-700'">
            By using this service, you agree to the processing of your data by our language model, 
            which may be used for further optimization of our model (e.g., vector databases, etc.).
          </p>
        </div>

        <!-- 同意协议复选框 -->
        <div class="flex items-start gap-3 p-4 rounded-lg border-2"
             :class="isDark ? 'border-gray-600 bg-gray-700' : 'border-purple-200 bg-purple-50'">
          <input 
            id="agree-checkbox"
            v-model="agreed"
            type="checkbox"
            class="mt-1 w-5 h-5 rounded border-gray-300 text-purple-600 focus:ring-purple-500 cursor-pointer"
          />
          <label for="agree-checkbox" 
                 class="text-sm cursor-pointer"
                 :class="isDark ? 'text-gray-200' : 'text-gray-700'">
            我已阅读并同意上述声明和数据处理协议 / I have read and agree to the above disclaimer and data processing agreement
          </label>
        </div>

        <!-- 按钮区域 -->
        <div class="flex gap-3 pt-2">
          <button
            @click="handleDecline"
            class="flex-1 px-6 py-3 rounded-lg font-medium transition-all duration-200"
            :class="isDark 
              ? 'bg-gray-700 text-gray-300 hover:bg-gray-600' 
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'"
          >
            <i class="ri-close-line mr-2"></i>
            不同意 / Decline
          </button>
          <button
            @click="handleAccept"
            :disabled="!agreed"
            class="flex-1 px-6 py-3 rounded-lg font-medium transition-all duration-200"
            :class="agreed
              ? 'bg-gradient-to-r from-purple-500 to-indigo-600 text-white hover:from-purple-600 hover:to-indigo-700 shadow-lg'
              : 'bg-gray-300 text-gray-500 cursor-not-allowed'"
          >
            <i class="ri-check-line mr-2"></i>
            同意并继续 / Accept
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useThemeStore } from '@/stores/theme'

const themeStore = useThemeStore()
const isDark = computed(() => themeStore.theme === 'dark')

const showModal = ref(false)
const agreed = ref(false)

const DISCLAIMER_KEY = 'sme_disclaimer_accepted'

onMounted(() => {
  // 检查用户是否已接受过免责声明
  const hasAccepted = localStorage.getItem(DISCLAIMER_KEY)
  if (!hasAccepted) {
    showModal.value = true
  }
})

function handleAccept() {
  if (!agreed.value) return
  
  // 保存接受状态到本地存储
  localStorage.setItem(DISCLAIMER_KEY, 'true')
  localStorage.setItem('sme_disclaimer_accepted_time', new Date().toISOString())
  
  showModal.value = false
}

function handleDecline() {
  if (confirm('如果不同意声明，您将无法使用此服务。确定要离开吗？\n\nIf you decline, you will not be able to use this service. Are you sure you want to leave?')) {
    // 可以跳转到其他页面或关闭窗口
    window.location.href = 'about:blank'
  }
}
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}
</style>

