#!/bin/bash
# 回滚脚本

ENV=$1
VERSION=$2
PORT=$3

if [ -z "$ENV" ] || [ -z "$VERSION" ]; then
    echo "用法: $0 <环境> <版本> [端口]"
    exit 1
fi

PORT=${PORT:-8088}
CONTAINER_NAME="jenkins-advanced-${ENV}"

echo "↩️ 回滚 ${ENV} 环境到版本 ${VERSION}..."

# 检查镜像是否存在
if ! docker images | grep -q "my-hello-jenkins.*${VERSION}"; then
    echo "❌ 镜像 my-hello-jenkins:${VERSION} 不存在"
    exit 1
fi

# 停止并删除当前容器
echo "停止当前容器..."
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

# 启动旧版本
echo "启动旧版本..."
docker run -d \
    --name ${CONTAINER_NAME} \
    -p ${PORT}:80 \
    --restart unless-stopped \
    -e ENV=${ENV} \
    -e VERSION=${VERSION} \
    my-hello-jenkins:${VERSION}

echo "✅ 回滚完成！当前版本: ${VERSION}"