#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CBIT-FrontAiForge 重新构建脚本（仅重新构建前端代码）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

echo "🔨 重新构建 CBIT-FrontAiForge..."

# 1. 构建前端
echo ""
echo "📦 1/2 构建前端代码..."
npm run build

if [ $? -eq 0 ]; then
    echo "   ✅ 前端构建成功"
else
    echo "   ❌ 前端构建失败"
    exit 1
fi

# 2. 重启Docker容器
echo ""
echo "🐳 2/2 重启Docker容器..."
docker-compose restart

echo ""
echo "✅ 重新构建完成！"
echo ""
echo "访问地址: http://127.0.0.1:9200"
echo "查看日志: docker-compose logs -f"

