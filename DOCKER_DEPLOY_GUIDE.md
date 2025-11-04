# CBIT-FrontAiForge Docker 部署指南

> 作者：Ren CBIT https://github.com/reneverland/

## 📋 修复说明

### 问题描述
- 本地服务器Docker可以正常访问后端API
- 其他服务器部署Docker时出现 502 Bad Gateway 错误
- 原因：Docker配置中使用了本地地址 `127.0.0.1`，其他服务器无法访问

### 修复内容
✅ 修改 `Dockerfile.host` - 修正默认后端端口为 9300  
✅ 修改 `docker-compose.yml` - 默认使用域名 `http://llmhi.com:9300`  
✅ 创建 `deploy-interactive.sh` - 交互式部署脚本  
✅ 更新部署文档和使用说明

---

## 🚀 部署方式

### 方式一：交互式部署（⭐ 推荐）

适合**首次部署**和**其他服务器部署**，脚本会自动引导您完成所有配置。

```bash
# 1. 克隆或拉取代码
git clone <repository_url>
cd CBIT-FrontAiForge

# 2. 运行交互式部署脚本
./deploy-interactive.sh
```

**脚本功能：**
- ✅ 自动检测Docker环境
- ✅ 引导选择后端地址（域名/内网IP/自定义）
- ✅ 自动生成 `.env` 配置文件
- ✅ 测试后端连接
- ✅ 自动构建和启动Docker
- ✅ 显示访问地址和常用命令

**后端地址选项：**
1. `http://llmhi.com:9300` - 域名访问（推荐，适用于公网环境）
2. `http://10.120.30.200:9300` - 内网IP（适用于学校局域网）
3. `http://127.0.0.1:9300` - 本机访问（仅限前后端同服务器）
4. 自定义地址 - 手动输入

---

### 方式二：快速部署（使用默认配置）

适合**本服务器**直接部署，使用默认域名访问。

```bash
# 直接启动（默认后端地址：http://llmhi.com:9300）
docker-compose up -d
```

---

### 方式三：自定义配置

#### 选项A：使用环境变量

```bash
# 临时指定后端地址
BACKEND_API_URL=http://10.120.30.200:9300 docker-compose up -d
```

#### 选项B：使用 .env 文件

```bash
# 1. 创建配置文件
cat > .env << EOF
BACKEND_API_URL=http://10.120.30.200:9300
VITE_APP_TITLE=SME Intelligent Assistant
VITE_APP_VERSION=1.0.0
EOF

# 2. 启动服务
docker-compose up -d
```

---

## 📍 常见配置示例

### 本服务器部署（前后端同服务器）
```bash
BACKEND_API_URL=http://llmhi.com:9300
# 或使用域名更稳定
```

### 学校其他服务器部署
```bash
# 方式1：使用域名（推荐）
BACKEND_API_URL=http://llmhi.com:9300

# 方式2：使用内网IP
BACKEND_API_URL=http://10.120.30.200:9300
```

### 开发测试环境
```bash
BACKEND_API_URL=http://127.0.0.1:9300
```

---

## 🛠️ 常用命令

### 查看服务状态
```bash
docker ps | grep cbit_frontaiforge
```

### 查看日志
```bash
# 实时查看日志
docker logs -f cbit_frontaiforge

# 查看最后100行日志
docker logs --tail 100 cbit_frontaiforge
```

### 重启服务
```bash
# 重启容器
docker-compose restart

# 完全重建（配置修改后）
docker-compose down
docker-compose up -d --build
```

### 停止服务
```bash
docker-compose down
```

### 修改配置后重新部署
```bash
# 1. 编辑配置
vim .env

# 2. 重新部署
docker-compose down
docker-compose up -d --build
```

---

## 🔍 故障排查

### 问题1：502 Bad Gateway

**症状：** 访问前端显示 502 错误

**排查步骤：**
```bash
# 1. 检查容器是否运行
docker ps | grep cbit_frontaiforge

# 2. 查看容器日志
docker logs cbit_frontaiforge

# 3. 检查后端地址配置
cat .env

# 4. 测试后端连接
curl http://llmhi.com:9300/api/applications/_public
```

**解决方案：**
- 确认后端服务已启动
- 检查防火墙是否开放 9300 端口
- 确认配置的后端地址可访问
- 重新运行 `./deploy-interactive.sh` 选择正确的后端地址

### 问题2：无法访问前端

**症状：** 浏览器无法打开 http://localhost:9200

**排查步骤：**
```bash
# 1. 检查容器状态
docker ps -a | grep cbit_frontaiforge

# 2. 检查端口占用
netstat -tunlp | grep 9200

# 3. 检查防火墙
sudo ufw status
```

**解决方案：**
```bash
# 开放防火墙端口
sudo ufw allow 9200

# 或使用 firewalld
sudo firewall-cmd --permanent --add-port=9200/tcp
sudo firewall-cmd --reload
```

### 问题3：Docker构建失败

**症状：** 构建过程中出现错误

**解决方案：**
```bash
# 清理Docker缓存后重建
docker system prune -a
docker-compose build --no-cache
docker-compose up -d
```

---

## 📊 服务信息

### 端口说明
- **前端端口：** 9200（对外访问）
- **后端端口：** 9300（API服务）
- **健康检查：** http://localhost:9200/health

### 访问方式
- **本机访问：** http://localhost:9200
- **局域网访问：** http://服务器IP:9200
- **公网访问：** 需配置域名和Nginx

---

## 🔐 安全建议

### 生产环境部署建议
1. **使用HTTPS**：配置SSL证书，启用HTTPS访问
2. **配置防火墙**：仅开放必要端口
3. **设置访问控制**：使用Nginx配置IP白名单
4. **定期更新**：及时更新Docker镜像和依赖

### Nginx反向代理示例
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:9200;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

---

## 📞 技术支持

如遇到问题，请检查：
1. Docker日志：`docker logs cbit_frontaiforge`
2. 后端服务状态：`curl http://后端地址:9300/api/applications/_public`
3. 网络连接：确认服务器间网络互通

---

## 📝 版本历史

### v1.1 (2025-11-04)
- ✅ 修复502错误：支持多服务器部署
- ✅ 新增交互式部署脚本
- ✅ 优化Docker配置和文档

### v1.0
- 初始Docker化版本

