#!/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CBIT-FrontAiForge 交互式部署脚本
# 作者：Ren CBIT https://github.com/reneverland/
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "docker-compose未安装，请先安装docker-compose"
        exit 1
    fi
    
    print_success "Docker环境检查通过"
}

# 检测现有配置
check_existing_config() {
    if [ -f ".env" ]; then
        print_warning "检测到已存在的.env配置文件"
        echo ""
        cat .env
        echo ""
        read -p "是否使用现有配置？(y/n，默认y): " use_existing
        use_existing=${use_existing:-y}
        if [[ "$use_existing" == "y" || "$use_existing" == "Y" ]]; then
            return 0
        fi
    fi
    return 1
}

# 选择后端地址
select_backend_url() {
    print_header "选择后端API地址"
    echo ""
    echo "请选择后端API地址类型："
    echo ""
    echo "  1) http://llmhi.com:9300           (推荐 - 域名访问，适用于公网环境)"
    echo "  2) http://10.120.30.200:9300       (内网IP，适用于学校局域网)"
    echo "  3) http://127.0.0.1:9300           (本机访问，仅限容器所在服务器)"
    echo "  4) 自定义地址                      (手动输入后端地址)"
    echo ""
    read -p "请输入选项 (1-4，默认1): " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            BACKEND_API_URL="http://llmhi.com:9300"
            print_info "已选择：域名访问 - $BACKEND_API_URL"
            ;;
        2)
            BACKEND_API_URL="http://10.120.30.200:9300"
            print_info "已选择：内网IP - $BACKEND_API_URL"
            ;;
        3)
            BACKEND_API_URL="http://127.0.0.1:9300"
            print_warning "注意：本机地址仅适用于前后端在同一服务器的情况"
            ;;
        4)
            read -p "请输入后端API完整地址 (例如: http://your-server:9300): " BACKEND_API_URL
            if [[ ! "$BACKEND_API_URL" =~ ^https?:// ]]; then
                print_error "无效的URL格式，请以 http:// 或 https:// 开头"
                exit 1
            fi
            print_info "已设置自定义地址：$BACKEND_API_URL"
            ;;
        *)
            print_error "无效的选项，请输入1-4"
            exit 1
            ;;
    esac
}

# 生成.env文件
generate_env_file() {
    print_header "生成环境配置文件"
    
    cat > .env << EOF
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CBIT-FrontAiForge 环境变量配置
# 自动生成时间: $(date '+%Y-%m-%d %H:%M:%S')
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 后端API地址
BACKEND_API_URL=${BACKEND_API_URL}

# 应用信息
VITE_APP_TITLE=SME Intelligent Assistant
VITE_APP_VERSION=1.0.0
EOF

    print_success "环境配置文件已生成：.env"
    echo ""
    print_info "配置内容："
    cat .env
}

# 测试后端连接
test_backend_connection() {
    print_header "测试后端连接"
    
    # 提取主机和端口
    backend_host=$(echo $BACKEND_API_URL | sed -E 's|https?://([^:/]+).*|\1|')
    backend_port=$(echo $BACKEND_API_URL | sed -E 's|https?://[^:]+:([0-9]+).*|\1|')
    
    print_info "正在测试连接到 $backend_host:$backend_port ..."
    
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$backend_host/$backend_port" 2>/dev/null; then
        print_success "后端服务器可访问！"
        return 0
    else
        print_warning "无法连接到后端服务器 $backend_host:$backend_port"
        print_warning "这可能是正常的，如果后端服务未启动或防火墙限制"
        read -p "是否继续部署？(y/n，默认y): " continue_deploy
        continue_deploy=${continue_deploy:-y}
        if [[ "$continue_deploy" != "y" && "$continue_deploy" != "Y" ]]; then
            exit 1
        fi
    fi
}

# 停止旧容器
stop_old_container() {
    print_header "检查并停止旧容器"
    
    if docker ps -a --format '{{.Names}}' | grep -q "cbit_frontaiforge"; then
        print_info "发现旧容器，正在停止并删除..."
        docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true
        print_success "旧容器已清理"
    else
        print_info "未发现旧容器"
    fi
}

# 构建并启动Docker
build_and_start() {
    print_header "构建并启动Docker容器"
    
    print_info "开始构建Docker镜像（这可能需要几分钟）..."
    
    # 尝试使用 docker-compose 或 docker compose
    if command -v docker-compose &> /dev/null; then
        docker-compose build --no-cache
        docker-compose up -d
    else
        docker compose build --no-cache
        docker compose up -d
    fi
    
    print_success "Docker容器已启动"
}

# 等待服务就绪
wait_for_service() {
    print_header "等待服务就绪"
    
    print_info "正在等待前端服务启动（最多等待60秒）..."
    
    for i in {1..60}; do
        if curl -sf http://localhost:9200/health > /dev/null 2>&1; then
            print_success "前端服务已就绪！"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    echo ""
    print_warning "服务启动超时，请检查容器日志"
    print_info "查看日志命令: docker logs cbit_frontaiforge"
}

# 显示访问信息
show_access_info() {
    print_header "部署完成"
    echo ""
    print_success "CBIT-FrontAiForge 前端已成功部署！"
    echo ""
    print_info "📍 访问地址："
    echo "   - 本机访问：http://localhost:9200"
    echo "   - 局域网访问：http://$(hostname -I | awk '{print $1}'):9200"
    echo ""
    print_info "⚙️  后端API地址：$BACKEND_API_URL"
    echo ""
    print_info "📋 常用命令："
    echo "   - 查看日志：docker logs -f cbit_frontaiforge"
    echo "   - 停止服务：docker-compose down"
    echo "   - 重启服务：docker-compose restart"
    echo "   - 查看状态：docker ps | grep cbit_frontaiforge"
    echo ""
    print_info "🔧 如需修改配置："
    echo "   1. 编辑 .env 文件"
    echo "   2. 重新运行：./deploy-interactive.sh"
    echo ""
}

# 主流程
main() {
    clear
    print_header "CBIT-FrontAiForge 交互式部署向导"
    echo ""
    print_info "此脚本将帮助您快速部署前端Docker服务"
    echo ""
    
    # 1. 检查Docker环境
    check_docker
    
    # 2. 检查现有配置
    if check_existing_config; then
        print_info "使用现有配置，跳过配置步骤"
        source .env
    else
        # 3. 选择后端地址
        select_backend_url
        
        # 4. 生成配置文件
        generate_env_file
    fi
    
    echo ""
    
    # 5. 测试后端连接
    test_backend_connection
    
    echo ""
    
    # 6. 停止旧容器
    stop_old_container
    
    echo ""
    
    # 7. 构建并启动
    build_and_start
    
    echo ""
    
    # 8. 等待服务就绪
    wait_for_service
    
    echo ""
    
    # 9. 显示访问信息
    show_access_info
}

# 运行主流程
main

