#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 502 Bad Gateway 自动检测与修复脚本
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "502 Bad Gateway 自动检测与修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 步骤 1: 检查后端服务
echo "🔍 步骤 1/5: 检查后端服务..."
echo "尝试连接后端 API..."

BACKEND_STATUS=0
for port in 9300 5000 8000; do
    echo "  检查端口 $port..."
    if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$port 2>/dev/null | grep -qE "200|404|500"; then
        echo "  ✅ 发现后端服务在端口 $port"
        BACKEND_PORT=$port
        BACKEND_STATUS=1
        break
    fi
done

if [ $BACKEND_STATUS -eq 0 ]; then
    echo ""
    echo "❌ 错误：未检测到后端服务运行"
    echo ""
    echo "请先启动后端服务，常见方法："
    echo "  1. Python 应用: cd /path/to/backend && python app.py"
    echo "  2. Gunicorn: gunicorn -w 4 -b 0.0.0.0:9300 app:app"
    echo "  3. Docker: docker-compose up -d backend"
    echo "  4. Systemd: systemctl start your-backend-service"
    echo ""
    echo "启动后端服务后，再次运行此脚本"
    exit 1
else
    echo "✅ 后端服务正常，端口: $BACKEND_PORT"
fi

echo ""
# 步骤 2: 配置环境变量
echo "🔧 步骤 2/5: 配置环境变量..."

if [ ! -f ".env.local" ]; then
    echo "创建 .env.local 配置文件..."
    cat > .env.local << EOF
BACKEND_API_URL=http://127.0.0.1:${BACKEND_PORT}
VITE_APP_TITLE=SME Intelligent Assistant
VITE_APP_VERSION=1.0.0
EOF
    echo "✅ 已创建配置文件"
else
    echo "配置文件已存在"
    # 更新后端地址
    if grep -q "BACKEND_API_URL" .env.local; then
        sed -i "s|BACKEND_API_URL=.*|BACKEND_API_URL=http://127.0.0.1:${BACKEND_PORT}|" .env.local
        echo "✅ 已更新后端地址"
    else
        echo "BACKEND_API_URL=http://127.0.0.1:${BACKEND_PORT}" >> .env.local
        echo "✅ 已添加后端地址"
    fi
fi

echo "当前配置："
cat .env.local

echo ""
# 步骤 3: 停止旧容器
echo "🛑 步骤 3/5: 停止现有容器..."
docker-compose down 2>/dev/null || true
echo "✅ 已停止"

echo ""
# 步骤 4: 重新构建
echo "🏗️  步骤 4/5: 重新构建容器..."
docker-compose build --no-cache

echo ""
# 步骤 5: 启动服务
echo "🚀 步骤 5/5: 启动服务..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动（10秒）..."
sleep 10

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 服务状态检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查容器状态
echo "1️⃣  容器状态："
docker-compose ps

echo ""
echo "2️⃣  测试前端页面："
FRONTEND_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200/ 2>/dev/null || echo "000")
if [ "$FRONTEND_CODE" = "200" ]; then
    echo "✅ 前端页面正常 (HTTP $FRONTEND_CODE)"
else
    echo "❌ 前端页面异常 (HTTP $FRONTEND_CODE)"
fi

echo ""
echo "3️⃣  测试 API 代理："
API_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200/api/applications/_public 2>/dev/null || echo "000")
if [ "$API_CODE" = "200" ] || [ "$API_CODE" = "404" ] || [ "$API_CODE" = "401" ]; then
    echo "✅ API 代理正常 (HTTP $API_CODE)"
elif [ "$API_CODE" = "502" ]; then
    echo "❌ 仍然返回 502，查看详细日志："
    echo ""
    docker-compose logs --tail=30 frontaiforge | grep -i error
    echo ""
    echo "建议："
    echo "  1. 检查后端是否真的在运行: curl http://127.0.0.1:${BACKEND_PORT}"
    echo "  2. 查看完整日志: docker-compose logs -f frontaiforge"
    echo "  3. 检查防火墙: sudo ufw status"
else
    echo "⚠️  API 返回异常状态码: $API_CODE"
fi

echo ""
echo "4️⃣  容器内网络测试："
if docker exec cbit_frontaiforge ping -c 1 127.0.0.1 >/dev/null 2>&1; then
    echo "✅ 容器网络正常"
else
    echo "❌ 容器网络异常"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 修复脚本执行完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 访问地址: http://$(hostname -I | awk '{print $1}'):9200"
echo "📋 查看日志: docker-compose logs -f frontaiforge"
echo "🔧 故障排查: 查看 TROUBLESHOOTING.md"
echo ""
