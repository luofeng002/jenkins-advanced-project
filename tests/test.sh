#!/bin/bash
# 测试脚本

echo "🧪 开始运行测试..."

# 测试 1: 检查容器是否运行
echo "测试 1: 检查 Docker 容器状态..."
if docker ps | grep -q "jenkins-advanced"; then
    echo "✅ 容器运行中"
else
    echo "❌ 容器未运行"
    exit 1
fi

# 测试 2: 测试 HTTP 响应
echo "测试 2: 测试 HTTP 响应..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8088/ | grep -q "200"; then
    echo "✅ HTTP 响应正常"
else
    echo "❌ HTTP 响应异常"
    exit 1
fi

# 测试 3: 测试页面内容
echo "测试 3: 测试页面内容..."
if curl -s http://localhost:8088/ | grep -q "Jenkins"; then
    echo "✅ 页面内容正确"
else
    echo "❌ 页面内容错误"
    exit 1
fi

echo "✅ 所有测试通过！"