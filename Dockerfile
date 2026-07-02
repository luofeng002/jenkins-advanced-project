# 使用 Nginx 基础镜像  
FROM nginx:alpine

# 创建应用目录
WORKDIR /usr/share/nginx/html

# 复制源码
COPY src/ .

# 暴露端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
