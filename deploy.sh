#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CBIT-FrontAiForge v4.0 一键部署脚本
# 端口: 9300
# 作者: Reneverland, CBIT, CUHK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e  # 遇到错误立即退出

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 CBIT-FrontAiForge v4.0 部署脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否在正确的目录
if [ ! -f "package.json" ]; then
    echo "❌ 错误: 请在CBIT-FrontAiForge目录下运行此脚本"
    exit 1
fi

# 显示当前配置
echo "📋 当前配置:"
echo "   - 前端端口: 9300"
echo "   - 后端API: /api (代理到后端)"
echo "   - 默认应用: sme"
echo ""

# 1. 停止现有容器
echo "📦 1/5 停止现有容器..."
docker-compose down 2>/dev/null || true
echo "   ✅ 容器已停止"
echo ""

# 2. 安装依赖（如果node_modules不存在）
if [ ! -d "node_modules" ]; then
    echo "📦 2/5 安装依赖..."
    npm install
    echo "   ✅ 依赖安装完成"
else
    echo "📦 2/5 跳过依赖安装（已存在）"
fi
echo ""

# 3. 构建前端
echo "🔨 3/5 构建前端..."
npm run build
if [ $? -eq 0 ]; then
    echo "   ✅ 前端构建成功"
else
    echo "   ❌ 前端构建失败"
    exit 1
fi
echo ""

# 4. 构建并启动Docker容器
echo "🐳 4/5 构建并启动Docker容器..."
docker-compose up -d --build
if [ $? -eq 0 ]; then
    echo "   ✅ Docker容器启动成功"
else
    echo "   ❌ Docker容器启动失败"
    exit 1
fi
echo ""

# 5. 检查容器状态
echo "🔍 5/5 检查容器状态..."
sleep 3
docker-compose ps

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 部署完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "访问地址:"
echo "  • 局域网: http://127.0.0.1:9300"
echo "  • 外部访问: http://llmhi.com:9300 (如已配置)"
echo ""
echo "查看日志:"
echo "  docker-compose logs -f"
echo ""
echo "重启服务:"
echo "  ./restart.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

