#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CBIT-AiForge SME - Quick Deployment Script
# CBIT-AiForge SME - 快速部署脚本
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CBIT-AiForge SME - Quick Deployment Script"
echo "CBIT-AiForge SME - 快速部署脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check and configure environment variables
if [ -f ".env" ]; then
    echo "✓ Found .env file"
    echo "✓ 发现 .env 文件"
    
    # Check current backend URL
    CURRENT_BACKEND=$(grep "^BACKEND_API_URL=" .env | cut -d'=' -f2)
    echo ""
    echo "📝 Current backend URL | 当前后端地址:"
    echo "   $CURRENT_BACKEND"
    echo ""
    
    # Check if it's still the default value
    if [ "$CURRENT_BACKEND" = "http://127.0.0.1:9300" ]; then
        echo "⚠  WARNING: Using default backend address!"
        echo "⚠  警告：正在使用默认后端地址！"
        echo ""
        echo "If your backend is on a different server, please update .env file:"
        echo "如果您的后端在其他服务器上，请更新 .env 文件："
        echo "  nano .env"
        echo ""
        echo "Example | 示例:"
        echo "  BACKEND_API_URL=http://llmhi.com:5173"
        echo ""
        read -p "Continue with current backend? (y/n) / 使用当前后端继续？(y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Please edit .env file and run this script again."
            echo "请编辑 .env 文件后重新运行此脚本。"
            exit 0
        fi
    fi
else
    echo "❌ Error: .env file not found!"
    echo "❌ 错误：找不到 .env 文件！"
    echo ""
    echo "Creating .env from example..."
    echo "从示例创建 .env..."
    
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✓ Created .env from .env.example"
        echo "✓ 已从 .env.example 创建 .env"
        echo ""
        echo "⚠  Please edit .env file to configure your backend URL"
        echo "⚠  请编辑 .env 文件配置您的后端地址"
        exit 1
    else
        echo "❌ Error: .env.example not found!"
        echo "❌ 错误：找不到 .env.example 文件！"
        exit 1
    fi
fi

echo ""
echo "🔧 Checking Docker..."
echo "🔧 检查 Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found! Please install Docker first."
    echo "❌ 未找到 Docker！请先安装 Docker。"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found! Please install Docker Compose first."
    echo "❌ 未找到 Docker Compose！请先安装 Docker Compose。"
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"
echo "✓ Docker 和 Docker Compose 已安装"
echo ""

echo "🛑 Stopping existing containers..."
echo "🛑 停止现有容器..."
docker-compose down 2>/dev/null || true

echo ""
echo "🏗️  Building Docker image..."
echo "🏗️  构建 Docker 镜像..."
docker-compose build --no-cache

echo ""
echo "🚀 Starting services..."
echo "🚀 启动服务..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start..."
echo "⏳ 等待服务启动..."
sleep 5

echo ""
echo "📊 Checking service status..."
echo "📊 检查服务状态..."
docker-compose ps

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Deployment completed successfully!"
echo "✅ 部署成功完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Access URLs / 访问地址:"
echo "   - http://localhost:9200"
echo "   - http://127.0.0.1:9200"
echo "   - http://YOUR_SERVER_IP:9200"
echo ""
echo "📋 Useful commands / 常用命令:"
echo "   View logs / 查看日志:"
echo "     docker-compose logs -f frontaiforge"
echo ""
echo "   Stop services / 停止服务:"
echo "     docker-compose down"
echo ""
echo "   Restart services / 重启服务:"
echo "     docker-compose restart"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
