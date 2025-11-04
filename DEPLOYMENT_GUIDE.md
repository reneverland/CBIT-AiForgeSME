# Server Deployment Guide | 服务器部署指南

[English](#english-deployment-guide) | [中文](#中文部署指南)

---

<a name="english-deployment-guide"></a>

## English Deployment Guide

### Prerequisites

Ensure the following are installed on your server:

- **Git**: Version control system
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Port 9200**: Must be available (or configure a different port)

### Deployment Methods

#### Method 1: Deploy from GitHub (Recommended)

This method automatically pulls the latest code from GitHub and deploys it.

```bash
# 1. Clone the repository
cd /path/to/your/workspace
git clone https://github.com/reneverland/CBIT-AiForgeSME.git
cd CBIT-AiForgeSME

# 2. Configure backend API URL
# Edit .env file and update BACKEND_API_URL
nano .env

# Change this line to your backend server:
# BACKEND_API_URL=http://YOUR_SERVER_IP:PORT
# Example: BACKEND_API_URL=http://llmhi.com:5173

# 3. Build and start services
docker-compose up -d

# 4. Verify deployment
docker-compose ps
docker-compose logs -f frontaiforge
```

**Quick Deployment with Script:**

```bash
# Clone repository
git clone https://github.com/reneverland/CBIT-AiForgeSME.git
cd CBIT-AiForgeSME

# Edit .env file first
nano .env  # Update BACKEND_API_URL

# Run quick deploy script
bash quick-deploy.sh
```

**Important Note:**
The repository includes a `.env` file with default configuration. You **MUST** edit this file and update `BACKEND_API_URL` to match your backend server before deployment.

#### Method 2: Deploy from GitHub Container Registry

Pull pre-built Docker images directly from GitHub Container Registry:

```bash
# 1. Login to GitHub Container Registry
echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u reneverland --password-stdin

# 2. Pull the latest image
docker pull ghcr.io/reneverland/cbit-aiforgesme:latest

# 3. Run the container
docker run -d \
  --name cbit-frontend \
  -p 9200:80 \
  --restart unless-stopped \
  ghcr.io/reneverland/cbit-aiforgesme:latest

# 4. Verify deployment
docker ps | grep cbit-frontend
docker logs -f cbit-frontend
```

### Configuration

#### Backend API Configuration

Edit the Nginx configuration to proxy requests to your backend:

```bash
nano nginx.conf
```

Update the backend API location:

```nginx
location /api/ {
    proxy_pass http://YOUR_BACKEND_IP:9300/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

#### Port Configuration

To change the default port (9200), edit `docker-compose.yml`:

```yaml
services:
  frontend:
    ports:
      - "YOUR_PORT:80"  # Change 9200 to your desired port
```

### Update Deployment

To update to the latest version from GitHub:

```bash
# Navigate to project directory
cd /path/to/CBIT-AiForgeSME

# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Verify update
docker-compose logs -f frontend
```

### Automated Deployment with CI/CD

The repository includes GitHub Actions for automated deployment. To enable:

1. **Configure Server Access**:
   - Add server SSH credentials to GitHub repository secrets
   - Go to: Settings → Secrets and variables → Actions
   - Add: `SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY`

2. **Update Workflow File** (`.github/workflows/deploy.yml`):

```yaml
deploy:
  name: Deploy to Server
  runs-on: ubuntu-latest
  needs: docker-build
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  
  steps:
  - name: Deploy to production server
    uses: appleboy/ssh-action@master
    with:
      host: ${{ secrets.SERVER_HOST }}
      username: ${{ secrets.SERVER_USER }}
      key: ${{ secrets.SERVER_SSH_KEY }}
      script: |
        cd /path/to/CBIT-AiForgeSME
        git pull origin main
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
```

3. **Trigger Deployment**:
   - Push to `main` branch triggers automatic deployment
   - Or manually trigger via GitHub Actions interface

### Monitoring and Logs

```bash
# View all container logs
docker-compose logs -f

# View only frontend logs
docker-compose logs -f frontend

# Check container status
docker-compose ps

# View resource usage
docker stats
```

### Troubleshooting

#### Container Won't Start

```bash
# Check logs for errors
docker-compose logs frontend

# Check if port is in use
sudo lsof -i :9200

# Verify Docker service is running
sudo systemctl status docker
```

#### Cannot Access Application

```bash
# Check firewall settings
sudo ufw status
sudo ufw allow 9200/tcp

# Verify Nginx is running inside container
docker-compose exec frontend nginx -t
docker-compose exec frontend nginx -s reload
```

#### Out of Disk Space

```bash
# Clean up Docker resources
docker system prune -a --volumes

# Remove unused images
docker image prune -a
```

### Security Recommendations

1. **Use HTTPS**: Configure SSL/TLS certificates (Let's Encrypt recommended)
2. **Firewall**: Only expose necessary ports
3. **Regular Updates**: Keep Docker and system packages updated
4. **Access Control**: Restrict SSH access to authorized users only
5. **Monitoring**: Set up monitoring for unusual activity

### Performance Optimization

1. **Enable Gzip Compression**: Already configured in `nginx.conf`
2. **CDN**: Consider using a CDN for static assets
3. **Caching**: Browser caching is pre-configured
4. **Resource Limits**: Set Docker memory/CPU limits if needed

```yaml
services:
  frontend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
```

---

<a name="中文部署指南"></a>

## 中文部署指南

### 环境要求

确保服务器已安装以下软件：

- **Git**: 版本控制系统
- **Docker**: 版本 20.10 或更高
- **Docker Compose**: 版本 2.0 或更高
- **端口 9200**: 必须可用（或配置其他端口）

### 部署方式

#### 方式一：从 GitHub 部署（推荐）

此方法自动从 GitHub 拉取最新代码并部署。

```bash
# 1. 克隆仓库
cd /path/to/your/workspace
git clone https://github.com/reneverland/CBIT-AiForgeSME.git
cd CBIT-AiForgeSME

# 2. 配置后端 API 地址
# 编辑 .env 文件并更新 BACKEND_API_URL
nano .env

# 修改此行为您的后端服务器地址：
# BACKEND_API_URL=http://YOUR_SERVER_IP:PORT
# 示例: BACKEND_API_URL=http://llmhi.com:5173

# 3. 构建并启动服务
docker-compose up -d

# 4. 验证部署
docker-compose ps
docker-compose logs -f frontaiforge
```

**使用脚本快速部署：**

```bash
# 克隆仓库
git clone https://github.com/reneverland/CBIT-AiForgeSME.git
cd CBIT-AiForgeSME

# 先编辑 .env 文件
nano .env  # 更新 BACKEND_API_URL

# 运行快速部署脚本
bash quick-deploy.sh
```

**重要提示：**
仓库中包含一个默认配置的 `.env` 文件。部署前，您**必须**编辑此文件并将 `BACKEND_API_URL` 更新为您的后端服务器地址。

#### 方式二：从 GitHub Container Registry 部署

直接从 GitHub Container Registry 拉取预构建的 Docker 镜像：

```bash
# 1. 登录 GitHub Container Registry
echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u reneverland --password-stdin

# 2. 拉取最新镜像
docker pull ghcr.io/reneverland/cbit-aiforgesme:latest

# 3. 运行容器
docker run -d \
  --name cbit-frontend \
  -p 9200:80 \
  --restart unless-stopped \
  ghcr.io/reneverland/cbit-aiforgesme:latest

# 4. 验证部署
docker ps | grep cbit-frontend
docker logs -f cbit-frontend
```

### 配置说明

#### 后端 API 配置

编辑 Nginx 配置以代理请求到后端：

```bash
nano nginx.conf
```

更新后端 API 地址：

```nginx
location /api/ {
    proxy_pass http://YOUR_BACKEND_IP:9300/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

#### 端口配置

要更改默认端口（9200），编辑 `docker-compose.yml`：

```yaml
services:
  frontend:
    ports:
      - "YOUR_PORT:80"  # 将 9200 改为您需要的端口
```

### 更新部署

更新到 GitHub 最新版本：

```bash
# 进入项目目录
cd /path/to/CBIT-AiForgeSME

# 拉取最新更改
git pull origin main

# 重新构建并重启
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 验证更新
docker-compose logs -f frontend
```

### 使用 CI/CD 自动部署

仓库包含 GitHub Actions 自动部署配置。启用方法：

1. **配置服务器访问**：
   - 将服务器 SSH 凭据添加到 GitHub 仓库 secrets
   - 访问：Settings → Secrets and variables → Actions
   - 添加：`SERVER_HOST`、`SERVER_USER`、`SERVER_SSH_KEY`

2. **更新工作流文件**（`.github/workflows/deploy.yml`）：

```yaml
deploy:
  name: Deploy to Server
  runs-on: ubuntu-latest
  needs: docker-build
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  
  steps:
  - name: Deploy to production server
    uses: appleboy/ssh-action@master
    with:
      host: ${{ secrets.SERVER_HOST }}
      username: ${{ secrets.SERVER_USER }}
      key: ${{ secrets.SERVER_SSH_KEY }}
      script: |
        cd /path/to/CBIT-AiForgeSME
        git pull origin main
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
```

3. **触发部署**：
   - 推送到 `main` 分支自动触发部署
   - 或通过 GitHub Actions 界面手动触发

### 监控和日志

```bash
# 查看所有容器日志
docker-compose logs -f

# 仅查看前端日志
docker-compose logs -f frontend

# 检查容器状态
docker-compose ps

# 查看资源使用情况
docker stats
```

### 故障排查

#### 容器无法启动

```bash
# 查看错误日志
docker-compose logs frontend

# 检查端口是否被占用
sudo lsof -i :9200

# 验证 Docker 服务运行状态
sudo systemctl status docker
```

#### 无法访问应用

```bash
# 检查防火墙设置
sudo ufw status
sudo ufw allow 9200/tcp

# 验证容器内 Nginx 运行状态
docker-compose exec frontend nginx -t
docker-compose exec frontend nginx -s reload
```

#### 磁盘空间不足

```bash
# 清理 Docker 资源
docker system prune -a --volumes

# 删除未使用的镜像
docker image prune -a
```

### 安全建议

1. **使用 HTTPS**：配置 SSL/TLS 证书（推荐 Let's Encrypt）
2. **防火墙**：仅开放必要端口
3. **定期更新**：保持 Docker 和系统软件包更新
4. **访问控制**：限制 SSH 访问仅授权用户
5. **监控**：设置监控以检测异常活动

### 性能优化

1. **启用 Gzip 压缩**：已在 `nginx.conf` 中配置
2. **CDN**：考虑使用 CDN 分发静态资源
3. **缓存**：浏览器缓存已预配置
4. **资源限制**：根据需要设置 Docker 内存/CPU 限制

```yaml
services:
  frontend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
```

### 快速部署脚本

创建一键部署脚本：

```bash
#!/bin/bash
# deploy-server.sh

set -e

PROJECT_DIR="/path/to/CBIT-AiForgeSME"

echo "=========================================="
echo "CBIT-AiForge SME 部署脚本"
echo "=========================================="

# 检查是否为首次部署
if [ ! -d "$PROJECT_DIR" ]; then
    echo "首次部署：克隆仓库..."
    git clone https://github.com/reneverland/CBIT-AiForgeSME.git "$PROJECT_DIR"
    cd "$PROJECT_DIR"
else
    echo "更新部署：拉取最新代码..."
    cd "$PROJECT_DIR"
    git pull origin main
fi

echo "停止现有容器..."
docker-compose down

echo "构建 Docker 镜像..."
docker-compose build --no-cache

echo "启动服务..."
docker-compose up -d

echo "等待服务启动..."
sleep 5

echo "检查服务状态..."
docker-compose ps

echo "=========================================="
echo "部署完成！"
echo "访问地址: http://YOUR_SERVER_IP:9200"
echo "=========================================="

echo "查看日志命令: docker-compose logs -f frontend"
```

使用方法：

```bash
chmod +x deploy-server.sh
sudo ./deploy-server.sh
```

---

## Support | 技术支持

- **Repository Issues**: https://github.com/reneverland/CBIT-AiForgeSME/issues
- **Maintainer**: [Ren CBIT](https://github.com/reneverland/)
- **Contact**: cooledward@outlook.com

---

**Last Updated**: 2025-10-30

