# 构建阶段
FROM node:18-alpine AS builder

WORKDIR /app

# 复制依赖文件
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 构建生产版本
RUN npm run build

# 生产阶段
FROM nginx:alpine

# 安装 curl 用于健康检查
RUN apk add --no-cache curl

# 复制构建产物到 Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# 创建 Nginx 配置
RUN echo 'server { \n\
    listen 80; \n\
    server_name localhost; \n\
    \n\
    # 前端静态文件 \n\
    location / { \n\
        root /usr/share/nginx/html; \n\
        index index.html index.htm; \n\
        try_files $uri $uri/ /index.html; \n\
    } \n\
    \n\
    # API 代理到后端 9300 端口 \n\
    location /api/ { \n\
        proxy_pass http://host.docker.internal:9300/api/; \n\
        proxy_set_header Host $host; \n\
        proxy_set_header X-Real-IP $remote_addr; \n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \n\
        proxy_set_header X-Forwarded-Proto $scheme; \n\
        \n\
        # 超时设置（RAG 检索可能较慢） \n\
        proxy_connect_timeout 300s; \n\
        proxy_send_timeout 300s; \n\
        proxy_read_timeout 300s; \n\
    } \n\
    \n\
    # 健康检查 \n\
    location /health { \n\
        access_log off; \n\
        return 200 "healthy\\n"; \n\
        add_header Content-Type text/plain; \n\
    } \n\
} \n' > /etc/nginx/conf.d/default.conf

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

