<template>
  <div class="flex gap-2 items-center justify-center py-4">
    <div class="flex gap-1.5">
      <div 
        v-for="i in 3" 
        :key="i"
        class="w-2 h-2 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full animate-bounce"
        :style="{ animationDelay: `${i * 0.15}s` }"
      />
    </div>
    <span v-if="text" class="text-sm text-gray-600 ml-2">{{ text }}</span>
  </div>
</template>

<script setup lang="ts">
interface Props {
  text?: string
}

withDefaults(defineProps<Props>(), {
  text: ''
})
</script>

