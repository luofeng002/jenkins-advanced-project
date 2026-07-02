#!/bin/bash
# 部署脚本

ENV=$1
VERSION=$2
PORT=$3

if [ -z "$ENV" ] || [ -z "$VERSION" ]; then
    echo "用法: $0 <环境> <版本> [端口]"
    exit 1
fi

PORT=${PORT:-8088}
CONTAINER_NAME="jenkins-advanced-${ENV}"

echo "🚀 部署 ${ENV} 环境 (版本: ${VERSION})..."

# 停止旧容器
echo "停止旧容器..."
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

# 启动新容器
echo "启动新容器..."
docker run -d \
    --name ${CONTAINER_NAME} \
    -p ${PORT}:80 \
    --restart unless-stopped \
    -e ENV=${ENV} \
    -e VERSION=${VERSION} \
    my-hello-jenkins:${VERSION}

# 健康检查
echo "等待服务启动..."
for i in {1..10}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT}/ | grep -q "200"; then
        echo "✅ 部署成功！访问: http://localhost:${PORT}"
        exit 0
    fi
    sleep 2
done

echo "❌ 部署失败！"
exit 1