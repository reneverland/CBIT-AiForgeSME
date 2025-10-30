#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CBIT-FrontAiForge 快速重启脚本
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

echo "🔄 重启 CBIT-FrontAiForge..."

# 停止容器
echo "   停止容器..."
docker-compose down

# 启动容器
echo "   启动容器..."
docker-compose up -d

# 等待启动
sleep 2

# 显示状态
echo ""
echo "✅ 重启完成！"
docker-compose ps

echo ""
echo "查看日志: docker-compose logs -f"

