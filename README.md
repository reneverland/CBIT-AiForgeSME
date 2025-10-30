# CBIT-AiForge SME Intelligent Assistant | SME 智能助手

[![Build Status](https://github.com/coolxilian/CBIT-AiForgeSME/actions/workflows/deploy.yml/badge.svg)](https://github.com/coolxilian/CBIT-AiForgeSME/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org)
[![Vue.js](https://img.shields.io/badge/vue-3.4.21-4FC08D.svg?logo=vue.js)](https://vuejs.org)
[![TypeScript](https://img.shields.io/badge/typescript-5.4.5-3178C6.svg?logo=typescript)](https://www.typescriptlang.org)
[![Docker](https://img.shields.io/badge/docker-supported-2496ED.svg?logo=docker)](https://www.docker.com)

[English](#english) | [中文](#chinese)

---

<a name="english"></a>

## 📖 Overview

**CBIT-AiForge SME Intelligent Assistant** is a modern, production-ready frontend application for an AI-powered Q&A system. Built with Vue 3, TypeScript, and Vite, it leverages RAG (Retrieval-Augmented Generation) technology to provide intelligent assistance for the School of Management and Economics at The Chinese University of Hong Kong, Shenzhen.

### Key Features

- **Modern UI/UX Design**: Clean and elegant conversational interface with dark/light theme support
- **Intelligent Conversation**: Powered by large language models for natural dialogue
- **Knowledge Base Retrieval**: Precise knowledge search powered by RAG technology
- **Real-time Feedback**: Support for conversation evaluation and answer submission
- **Responsive Design**: Optimized for various screen sizes and devices
- **Docker Deployment**: Containerized deployment with Nginx for production environments
- **Internationalization**: Multi-language support (Chinese/English)

## 🏗️ Architecture

### Technology Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Vue 3.4.21 (Composition API) |
| **Language** | TypeScript 5.4.5 |
| **Build Tool** | Vite 5.2.8 |
| **State Management** | Pinia 2.1.7 |
| **Router** | Vue Router 4.3.0 |
| **HTTP Client** | Axios 1.6.8 |
| **Styling** | TailwindCSS 3.4.3 |
| **Markdown** | marked 12.0.2 + DOMPurify 3.1.0 |
| **Icons** | Lucide Icons + RemixIcon |
| **Container** | Docker + Nginx |

### Project Structure

```
CBIT-FrontAiForge/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline configuration
├── src/
│   ├── api/                    # API integration layer
│   │   └── chat.ts            # Chat API endpoints
│   ├── components/             # Reusable Vue components
│   │   ├── AppSelector.vue    # Application selector
│   │   ├── ChatInput.vue      # Chat input interface
│   │   ├── ChatMessage.vue    # Message display component
│   │   ├── Footer.vue         # Application footer
│   │   ├── Header.vue         # Application header
│   │   ├── LoadingDots.vue    # Loading animation
│   │   ├── SuggestionCard.vue # Suggestion cards
│   │   ├── WebSearchAuth.vue  # Web search authentication
│   │   └── WelcomeScreen.vue  # Welcome screen
│   ├── i18n/                   # Internationalization
│   │   └── index.ts           # Language configuration
│   ├── stores/                 # Pinia state management
│   │   ├── app.ts             # Application state
│   │   ├── chat.ts            # Chat state
│   │   └── theme.ts           # Theme state
│   ├── types/                  # TypeScript type definitions
│   │   └── chat.ts            # Chat-related types
│   ├── views/                  # Page views
│   │   └── ChatView.vue       # Main chat view
│   ├── App.vue                 # Root component
│   ├── main.ts                 # Application entry point
│   └── style.css              # Global styles
├── public/                     # Static assets
├── docker-compose.yml          # Docker Compose configuration
├── Dockerfile                  # Docker image definition
├── nginx.conf                  # Nginx server configuration
├── package.json                # Node.js dependencies
├── tsconfig.json              # TypeScript configuration
├── vite.config.ts             # Vite build configuration
└── tailwind.config.js         # TailwindCSS configuration
```

## 🚀 Getting Started

### Prerequisites

- **Node.js**: Version 18 or higher
- **npm** or **yarn**: Package manager
- **Docker** & **Docker Compose**: For containerized deployment (optional)

### Local Development

```bash
# Clone the repository
git clone https://github.com/coolxilian/CBIT-AiForgeSME.git
cd CBIT-AiForgeSME

# Install dependencies
npm install

# Start development server (port 9301)
npm run dev

# Access the application
# Local: http://localhost:9301
```

### Production Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

### Docker Deployment

```bash
# Build and start containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Rebuild containers
docker-compose build --no-cache
docker-compose up -d
```

## ⚙️ Configuration

### Environment Variables

Create `.env.production` file in the project root:

```env
# Backend API Configuration
VITE_API_BASE_URL=http://127.0.0.1:9300

# Application Settings
VITE_APP_TITLE=SME Intelligent Assistant
VITE_APP_VERSION=1.0.0
```

### Backend API Configuration

The application communicates with a backend service. Ensure the backend API is running and accessible at the configured URL.

Default backend endpoint: `http://127.0.0.1:9300`

### Port Configuration

The application runs on port **9200** in production (Docker deployment).

To change the port, modify `docker-compose.yml`:

```yaml
services:
  frontend:
    ports:
      - "9200:80"  # Change 9200 to your desired port
```

## 🔄 CI/CD Pipeline

The project includes a GitHub Actions workflow for continuous integration and deployment:

### Workflow Stages

1. **Build**: Compile TypeScript and build production assets
2. **Test**: Run linting and type checking
3. **Docker Build**: Create and push Docker images to GitHub Container Registry
4. **Deploy**: Deploy to production server (configurable)

### Triggering Deployments

- **Automatic**: Push to `main` branch triggers full pipeline
- **Manual**: Use GitHub Actions "Run workflow" button
- **Pull Request**: Builds and tests without deployment

### Container Registry

Docker images are published to: `ghcr.io/coolxilian/cbit-aiforgesme`

## 📦 Deployment Scripts

### Quick Update Script

```bash
# Full update and redeploy
sudo bash 快速更新.sh
```

### Manual Deployment

```bash
# Stop running containers
docker-compose down

# Clean build artifacts
rm -rf dist node_modules/.vite

# Rebuild application
npm run build

# Rebuild Docker image
docker-compose build --no-cache

# Start containers
docker-compose up -d
```

### Restart Services

```bash
# Quick restart (no rebuild)
bash restart.sh

# Full rebuild and restart
bash rebuild.sh
```

## 🌐 Access URLs

### Production

- **Internal Network**: http://127.0.0.1:9200
- **External Network**: http://www.llmhi.com:9200

### Development

- **Local Dev Server**: http://localhost:9301

## 🛡️ Best Practices

### Code Quality

- **TypeScript**: Strict type checking enabled
- **ESLint**: Code linting (configured in development)
- **Vue Best Practices**: Composition API, `<script setup>` syntax
- **Component Structure**: Single File Components (SFC)

### Performance Optimization

- **Code Splitting**: Vite automatic code splitting
- **Lazy Loading**: Route-based lazy loading
- **Asset Optimization**: Image and asset optimization
- **Tree Shaking**: Unused code elimination

### Security

- **XSS Protection**: DOMPurify for HTML sanitization
- **CORS**: Configured in backend API
- **Environment Variables**: Sensitive data in `.env` files (not committed)

## 🐛 Troubleshooting

### Cache Issues

If changes are not reflected after deployment:

```bash
# Clear browser cache
Ctrl + F5 (Windows/Linux)
Cmd + Shift + R (macOS)

# Clear Docker build cache
docker system prune -a
```

### Port Conflicts

If port 9200 is in use:

```bash
# Check port usage
sudo lsof -i :9200

# Kill process using port
sudo kill -9 <PID>
```

### Docker Build Failures

```bash
# Remove old containers and images
docker-compose down -v
docker system prune -a

# Rebuild from scratch
docker-compose build --no-cache
```

## 👥 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

© 2025 CBIT-AiForge SME Intelligent Assistant. All rights reserved.

## 🙏 Acknowledgments

- **Developer**: [Ren CBIT](https://github.com/reneverland/) - Lead Developer & Maintainer
- **Institution**: The Chinese University of Hong Kong, Shenzhen (CUHK-Shenzhen)
- **School**: School of Management and Economics (SME)

## ⚠️ Disclaimer

Content generated by large language models does not represent the official views of The Chinese University of Hong Kong, Shenzhen or the School of Management and Economics.

---

<a name="chinese"></a>

## 📖 项目概述

**CBIT-AiForge SME 智能助手**是一个现代化的生产级前端应用程序，为人工智能驱动的问答系统提供支持。采用 Vue 3、TypeScript 和 Vite 构建，利用 RAG（检索增强生成）技术为香港中文大学（深圳）经管学院提供智能助手服务。

### 核心特性

- **现代化 UI/UX 设计**：简洁优雅的对话界面，支持深色/浅色主题切换
- **智能对话系统**：基于大语言模型的自然对话能力
- **知识库检索**：RAG 技术驱动的精准知识搜索
- **实时反馈机制**：支持对话评价和答案提交
- **响应式设计**：适配各种屏幕尺寸和设备
- **Docker 容器化部署**：生产环境使用 Nginx 的容器化部署
- **国际化支持**：多语言支持（中文/英文）

## 🏗️ 系统架构

### 技术栈

| 类别 | 技术 |
|------|------|
| **框架** | Vue 3.4.21 (组合式 API) |
| **开发语言** | TypeScript 5.4.5 |
| **构建工具** | Vite 5.2.8 |
| **状态管理** | Pinia 2.1.7 |
| **路由管理** | Vue Router 4.3.0 |
| **HTTP 客户端** | Axios 1.6.8 |
| **样式框架** | TailwindCSS 3.4.3 |
| **Markdown 渲染** | marked 12.0.2 + DOMPurify 3.1.0 |
| **图标库** | Lucide Icons + RemixIcon |
| **容器化** | Docker + Nginx |

### 项目结构

```
CBIT-FrontAiForge/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD 流水线配置
├── src/
│   ├── api/                    # API 集成层
│   │   └── chat.ts            # 聊天 API 端点
│   ├── components/             # 可复用 Vue 组件
│   │   ├── AppSelector.vue    # 应用选择器
│   │   ├── ChatInput.vue      # 聊天输入界面
│   │   ├── ChatMessage.vue    # 消息展示组件
│   │   ├── Footer.vue         # 应用底部
│   │   ├── Header.vue         # 应用头部
│   │   ├── LoadingDots.vue    # 加载动画
│   │   ├── SuggestionCard.vue # 建议卡片
│   │   ├── WebSearchAuth.vue  # 网络搜索认证
│   │   └── WelcomeScreen.vue  # 欢迎界面
│   ├── i18n/                   # 国际化
│   │   └── index.ts           # 语言配置
│   ├── stores/                 # Pinia 状态管理
│   │   ├── app.ts             # 应用状态
│   │   ├── chat.ts            # 聊天状态
│   │   └── theme.ts           # 主题状态
│   ├── types/                  # TypeScript 类型定义
│   │   └── chat.ts            # 聊天相关类型
│   ├── views/                  # 页面视图
│   │   └── ChatView.vue       # 主聊天视图
│   ├── App.vue                 # 根组件
│   ├── main.ts                 # 应用入口
│   └── style.css              # 全局样式
├── public/                     # 静态资源
├── docker-compose.yml          # Docker Compose 配置
├── Dockerfile                  # Docker 镜像定义
├── nginx.conf                  # Nginx 服务器配置
├── package.json                # Node.js 依赖
├── tsconfig.json              # TypeScript 配置
├── vite.config.ts             # Vite 构建配置
└── tailwind.config.js         # TailwindCSS 配置
```

## 🚀 快速开始

### 环境要求

- **Node.js**：版本 18 或更高
- **npm** 或 **yarn**：包管理器
- **Docker** 和 **Docker Compose**：用于容器化部署（可选）

### 本地开发

```bash
# 克隆仓库
git clone https://github.com/coolxilian/CBIT-AiForgeSME.git
cd CBIT-AiForgeSME

# 安装依赖
npm install

# 启动开发服务器（端口 9301）
npm run dev

# 访问应用
# 本地: http://localhost:9301
```

### 生产构建

```bash
# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

### Docker 部署

```bash
# 构建并启动容器
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止容器
docker-compose down

# 重新构建容器
docker-compose build --no-cache
docker-compose up -d
```

## ⚙️ 配置说明

### 环境变量

在项目根目录创建 `.env.production` 文件：

```env
# 后端 API 配置
VITE_API_BASE_URL=http://127.0.0.1:9300

# 应用设置
VITE_APP_TITLE=SME 智能助手
VITE_APP_VERSION=1.0.0
```

### 后端 API 配置

应用与后端服务通信。确保后端 API 正在运行并可通过配置的 URL 访问。

默认后端端点：`http://127.0.0.1:9300`

### 端口配置

应用在生产环境（Docker 部署）中运行在 **9200** 端口。

修改端口，编辑 `docker-compose.yml`：

```yaml
services:
  frontend:
    ports:
      - "9200:80"  # 将 9200 改为您需要的端口
```

## 🔄 CI/CD 流水线

项目包含 GitHub Actions 工作流，用于持续集成和部署：

### 工作流阶段

1. **构建**：编译 TypeScript 并构建生产资源
2. **测试**：运行代码检查和类型检查
3. **Docker 构建**：创建并推送 Docker 镜像到 GitHub Container Registry
4. **部署**：部署到生产服务器（可配置）

### 触发部署

- **自动触发**：推送到 `main` 分支触发完整流水线
- **手动触发**：使用 GitHub Actions "Run workflow" 按钮
- **拉取请求**：构建和测试，但不部署

### 容器镜像仓库

Docker 镜像发布到：`ghcr.io/coolxilian/cbit-aiforgesme`

## 📦 部署脚本

### 快速更新脚本

```bash
# 完整更新和重新部署
sudo bash 快速更新.sh
```

### 手动部署

```bash
# 停止运行中的容器
docker-compose down

# 清理构建产物
rm -rf dist node_modules/.vite

# 重新构建应用
npm run build

# 重新构建 Docker 镜像
docker-compose build --no-cache

# 启动容器
docker-compose up -d
```

### 重启服务

```bash
# 快速重启（无需重新构建）
bash restart.sh

# 完全重新构建并重启
bash rebuild.sh
```

## 🌐 访问地址

### 生产环境

- **内网访问**：http://127.0.0.1:9200
- **外网访问**：http://www.llmhi.com:9200

### 开发环境

- **本地开发服务器**：http://localhost:9301

## 🛡️ 最佳实践

### 代码质量

- **TypeScript**：启用严格类型检查
- **ESLint**：代码检查（在开发环境配置）
- **Vue 最佳实践**：组合式 API、`<script setup>` 语法
- **组件结构**：单文件组件 (SFC)

### 性能优化

- **代码分割**：Vite 自动代码分割
- **懒加载**：基于路由的懒加载
- **资源优化**：图片和资源优化
- **Tree Shaking**：消除未使用的代码

### 安全性

- **XSS 防护**：使用 DOMPurify 进行 HTML 清理
- **CORS**：在后端 API 中配置
- **环境变量**：敏感数据存储在 `.env` 文件中（不提交到版本控制）

## 🐛 故障排除

### 缓存问题

如果部署后更改未生效：

```bash
# 清除浏览器缓存
Ctrl + F5 (Windows/Linux)
Cmd + Shift + R (macOS)

# 清除 Docker 构建缓存
docker system prune -a
```

### 端口冲突

如果端口 9200 已被占用：

```bash
# 检查端口占用
sudo lsof -i :9200

# 终止占用端口的进程
sudo kill -9 <PID>
```

### Docker 构建失败

```bash
# 删除旧容器和镜像
docker-compose down -v
docker system prune -a

# 从头开始重新构建
docker-compose build --no-cache
```

## 👥 贡献指南

欢迎贡献！请遵循以下准则：

1. Fork 仓库
2. 创建特性分支（`git checkout -b feature/AmazingFeature`）
3. 提交更改（`git commit -m 'Add some AmazingFeature'`）
4. 推送到分支（`git push origin feature/AmazingFeature`）
5. 开启拉取请求

## 📄 许可证

© 2025 CBIT-AiForge SME 智能助手。保留所有权利。

## 🙏 致谢

- **开发者**：[Ren CBIT](https://github.com/reneverland/) - 首席开发者与维护者
- **机构**：香港中文大学（深圳）
- **学院**：经管学院 (SME)

## ⚠️ 免责声明

大语言模型生成的内容不代表香港中文大学（深圳）或经管学院的官方观点。

---

**Repository**: https://github.com/coolxilian/CBIT-AiForgeSME

**Maintainer**: [Ren CBIT](https://github.com/reneverland/)

**Contact**: cooledward@outlook.com
