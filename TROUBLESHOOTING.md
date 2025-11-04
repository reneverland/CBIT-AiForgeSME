# 502 Bad Gateway 错误排查与修复指南

## 问题症状

```
GET /api/applications/_public HTTP/1.1" 502
[error] connect() failed (111: Connection refused) while connecting to upstream
```

## 原因分析

502 错误表明：
- ✅ 前端容器（Nginx）正常运行
- ❌ 前端无法连接到后端 API 服务

---

## 🔍 完整检测步骤

### 步骤 1：检查后端服务是否运行

```bash
# 检查后端服务进程
ps aux | grep -i python | grep -i app

# 或检查后端容器（如果后端也用 Docker）
docker ps | grep backend

# 检查 9300 端口是否监听
netstat -tlnp | grep 9300
# 或
ss -tlnp | grep 9300
```

**预期结果**：应该看到后端服务在 9300 端口监听

---

### 步骤 2：测试后端 API 连通性

```bash
# 在服务器上直接测试后端 API
curl -v http://127.0.0.1:9300/api/applications/_public

# 或测试后端健康检查
curl -v http://127.0.0.1:9300/health
curl -v http://127.0.0.1:9300/api/health
```

**预期结果**：
- ✅ 如果返回 JSON 数据 → 后端正常
- ❌ 如果连接被拒绝 → 后端未启动或端口错误

---

### 步骤 3：检查前端容器配置

```bash
cd /root/CBIT-AiForgeSME

# 查看容器日志
docker-compose logs frontaiforge | tail -50

# 检查容器内的 Nginx 配置
docker-compose exec frontaiforge cat /etc/nginx/conf.d/default.conf

# 查看环境变量
docker-compose exec frontaiforge env | grep BACKEND
```

---

### 步骤 4：检查 Docker 网络模式

```bash
# 查看容器网络模式
docker inspect cbit_frontaiforge | grep -A 10 "NetworkMode"

# 如果使用 host 模式，后端必须在 127.0.0.1:9300
# 如果使用 bridge 模式，需要检查容器间通信
```

---

## ✅ 修复方案

### 方案 A：后端未启动（最常见）⭐

```bash
# 1. 启动后端服务
# 如果后端是 Python 应用：
cd /path/to/backend
python app.py
# 或
gunicorn -w 4 -b 0.0.0.0:9300 app:app

# 2. 验证后端运行
curl http://127.0.0.1:9300/api/applications/_public

# 3. 重启前端容器
cd /root/CBIT-AiForgeSME
docker-compose restart frontaiforge
```

---

### 方案 B：后端地址配置错误

```bash
cd /root/CBIT-AiForgeSME

# 1. 检查当前配置
cat .env.local 2>/dev/null || echo "No .env.local found"

# 2. 确定后端实际地址
# 后端在本机：
echo "BACKEND_API_URL=http://127.0.0.1:9300" > .env.local

# 后端在其他服务器：
echo "BACKEND_API_URL=http://BACKEND_SERVER_IP:9300" > .env.local

# 3. 重新构建并启动
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 4. 验证配置
docker-compose exec frontaiforge cat /etc/nginx/conf.d/default.conf | grep proxy_pass
```

---

### 方案 C：使用完整的快速修复脚本

创建并运行此脚本：

```bash
cat > /root/CBIT-AiForgeSME/fix-502.sh << 'EOFFIX'
#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "502 Bad Gateway 自动修复脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查后端服务
echo "🔍 检查后端服务..."
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9300/api/applications/_public | grep -q "200\|404\|500"; then
    echo "✅ 后端服务运行正常"
    BACKEND_OK=1
else
    echo "❌ 后端服务未运行或无法访问"
    echo ""
    echo "请先启动后端服务："
    echo "  方法1: cd /path/to/backend && python app.py"
    echo "  方法2: systemctl start backend-service"
    echo "  方法3: 检查后端 Docker 容器"
    BACKEND_OK=0
fi

echo ""
echo "🔧 配置前端..."

# 确保有环境配置
if [ ! -f ".env.local" ]; then
    echo "创建 .env.local 配置文件..."
    cat > .env.local << 'EOF'
# 后端 API 地址
BACKEND_API_URL=http://127.0.0.1:9300

# 应用配置
VITE_APP_TITLE=SME Intelligent Assistant
VITE_APP_VERSION=1.0.0
EOF
    echo "✅ 已创建默认配置"
fi

echo ""
echo "当前后端配置："
grep BACKEND_API_URL .env.local || echo "BACKEND_API_URL=http://127.0.0.1:9300"

echo ""
read -p "是否需要修改后端地址？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "请输入后端地址 (例如: http://192.168.1.100:9300): " backend_url
    sed -i "s|BACKEND_API_URL=.*|BACKEND_API_URL=$backend_url|" .env.local
    echo "✅ 已更新后端地址为: $backend_url"
fi

echo ""
echo "🔄 重建并重启前端容器..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 8

echo ""
echo "📊 检查服务状态..."
docker-compose ps

echo ""
echo "🧪 测试前端访问..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200/)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 前端页面访问正常 (HTTP $HTTP_CODE)"
else
    echo "⚠️  前端返回状态码: $HTTP_CODE"
fi

echo ""
echo "🧪 测试 API 代理..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200/api/applications/_public)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "404" ]; then
    echo "✅ API 代理工作正常 (HTTP $HTTP_CODE)"
else
    echo "❌ API 代理失败 (HTTP $HTTP_CODE)"
    echo ""
    echo "查看容器日志："
    docker-compose logs --tail=20 frontaiforge
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "修复脚本执行完成"
echo ""
echo "访问地址: http://$(hostname -I | awk '{print $1}'):9200"
echo "查看日志: docker-compose logs -f frontaiforge"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EOFFIX

chmod +x /root/CBIT-AiForgeSME/fix-502.sh
bash /root/CBIT-AiForgeSME/fix-502.sh
```

---

## 🔧 手动配置 Nginx 代理（备选方案）

如果使用环境变量不生效，可以直接修改 Nginx 配置：

```bash
# 1. 创建自定义 Nginx 配置
cat > /root/CBIT-AiForgeSME/nginx-custom.conf << 'EOF'
server {
    listen 9200;
    server_name _;
    
    # 前端静态文件
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # 后端 API 代理 - 修改这里的地址
    location /api/ {
        proxy_pass http://127.0.0.1:9300/api/;
        # 如果后端在其他服务器：
        # proxy_pass http://BACKEND_SERVER_IP:9300/api/;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # 超时设置
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
    
    # 健康检查
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# 2. 修改 docker-compose.yml 挂载配置
# 在 volumes 部分添加：
#   - ./nginx-custom.conf:/etc/nginx/conf.d/default.conf:ro

# 3. 重启容器
docker-compose restart frontaiforge
```

---

## 📋 常见场景和解决方案

### 场景 1：后端和前端在同一台服务器

```bash
# .env.local 配置
BACKEND_API_URL=http://127.0.0.1:9300

# 或者直接在 docker-compose.yml 中设置
environment:
  - BACKEND_API_URL=http://127.0.0.1:9300
```

### 场景 2：后端在另一台服务器

```bash
# 假设后端在 192.168.1.100:9300
echo "BACKEND_API_URL=http://192.168.1.100:9300" > .env.local

# 确保防火墙允许访问
sudo ufw allow from 当前服务器IP to any port 9300
```

### 场景 3：后端使用域名

```bash
# .env.local 配置
BACKEND_API_URL=http://backend.example.com:9300

# 或使用 HTTPS
BACKEND_API_URL=https://backend.example.com
```

### 场景 4：使用 Docker bridge 网络

```bash
# 如果后端也在 Docker 容器中
# docker-compose.yml 中添加：
services:
  frontend:
    networks:
      - app-network
  
  backend:
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

# 环境变量使用容器名
BACKEND_API_URL=http://backend:9300
```

---

## 🎯 快速诊断命令

```bash
# 一键诊断脚本
cat > /tmp/diagnose.sh << 'EOFDIAG'
#!/bin/bash
echo "=== 系统诊断 ==="
echo ""
echo "1. 后端服务检查："
curl -I http://127.0.0.1:9300/api/applications/_public 2>&1 | head -5
echo ""
echo "2. 前端容器状态："
docker ps | grep frontaiforge
echo ""
echo "3. 容器日志（最后10行）："
docker logs cbit_frontaiforge 2>&1 | tail -10
echo ""
echo "4. 端口监听："
ss -tlnp | grep -E ':(9200|9300)'
echo ""
echo "5. 网络连通性："
docker exec cbit_frontaiforge ping -c 2 127.0.0.1
echo ""
echo "6. Nginx 配置："
docker exec cbit_frontaiforge cat /etc/nginx/conf.d/default.conf | grep -A 5 "location /api"
EOFDIAG

bash /tmp/diagnose.sh
```

---

## 📞 如果问题仍未解决

1. **收集完整日志**：
   ```bash
   docker-compose logs frontaiforge > /tmp/frontend-logs.txt
   ```

2. **检查后端日志**：
   ```bash
   # 后端应用日志位置取决于部署方式
   tail -f /path/to/backend/logs/app.log
   ```

3. **验证网络连通性**：
   ```bash
   # 从容器内测试
   docker exec cbit_frontaiforge curl -v http://127.0.0.1:9300/api/applications/_public
   ```

4. **查看完整错误信息**：
   ```bash
   docker exec cbit_frontaiforge cat /var/log/nginx/error.log
   ```

---

**更新时间**: 2025-11-04  
**适用版本**: CBIT-AiForge SME v1.0.0

