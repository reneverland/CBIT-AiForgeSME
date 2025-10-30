/**
 * 应用状态管理 - Pinia Store
 */

import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { Application } from '@/types/chat'
import { fetchApplications } from '@/api/chat'

export const useAppStore = defineStore('app', () => {
  // 状态
  const applications = ref<Application[]>([])
  const isLoadingApps = ref(false)
  const appsError = ref<string | null>(null)

  /**
   * 加载应用列表
   */
  async function loadApplications() {
    isLoadingApps.value = true
    appsError.value = null

    try {
      const response = await fetchApplications()
      applications.value = response.applications.filter(app => app.is_active)
      console.log('✅ 加载应用列表成功:', applications.value.length, '个应用')
      
      // 自动选择默认应用 (sme)
      return getDefaultApplication()
    } catch (err: any) {
      appsError.value = err.message || '加载应用列表失败'
      console.error('❌ 加载应用列表失败:', err)
      return null
    } finally {
      isLoadingApps.value = false
    }
  }

  /**
   * 获取默认应用（优先选择sme，否则第一个）
   */
  function getDefaultApplication(): Application | null {
    if (applications.value.length === 0) return null
    
    // 优先精确匹配name为'sme'的应用
    const exactSmeApp = applications.value.find(app => 
      app.name.toLowerCase() === 'sme'
    )
    
    if (exactSmeApp) {
      console.log('✅ 自动选择默认应用（精确匹配）: sme -', exactSmeApp.name)
      return exactSmeApp
    }
    
    // 如果没有精确匹配，查找包含'sme'的应用
    const smeApp = applications.value.find(app => 
      app.name.toLowerCase().includes('sme')
    )
    
    if (smeApp) {
      console.log('✅ 自动选择默认应用（包含sme）:', smeApp.name)
      return smeApp
    }
    
    // 如果没有sme相关应用，返回第一个应用
    console.log('✅ 自动选择第一个应用:', applications.value[0].name)
    return applications.value[0]
  }

  /**
   * 根据ID获取应用
   */
  function getApplicationById(id: number): Application | undefined {
    return applications.value.find(app => app.id === id)
  }

  /**
   * 根据endpoint路径获取应用
   */
  function getApplicationByPath(path: string): Application | undefined {
    return applications.value.find(app => app.endpoint_path === path)
  }

  return {
    // 状态
    applications,
    isLoadingApps,
    appsError,
    
    // 方法
    loadApplications,
    getApplicationById,
    getApplicationByPath,
    getDefaultApplication
  }
})

