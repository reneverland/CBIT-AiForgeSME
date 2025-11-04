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

# Check if .env.local exists
if [ -f ".env.local" ]; then
    echo "✓ Found existing .env.local file"
    echo "✓ 发现已存在的 .env.local 文件"
else
    echo "⚠ .env.local not found, creating from example..."
    echo "⚠ 未找到 .env.local，从示例文件创建..."
    
    if [ -f ".env.example" ]; then
        cp .env.example .env.local
        echo "✓ Created .env.local from .env.example"
        echo "✓ 已从 .env.example 创建 .env.local"
        echo ""
        echo "📝 Using default backend: http://127.0.0.1:9300"
        echo "📝 使用默认后端地址: http://127.0.0.1:9300"
        echo ""
        echo "To change backend URL, edit .env.local file:"
        echo "要修改后端地址，请编辑 .env.local 文件："
        echo "  nano .env.local"
        echo ""
        read -p "Press Enter to continue or Ctrl+C to abort... / 按回车继续或 Ctrl+C 取消..." 
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
