# Dockerfile

# --- 第一阶段：构建 ---
# 使用官方的 Node.js Alpine 镜像作为构建环境
FROM node:alpine AS builder

# 在容器中创建并设置工作目录
WORKDIR /usr/src/app

# 复制 package.json 和 package-lock.json (如果存在)
# 这样做可以利用 Docker 的缓存机制，只有在依赖更新时才重新安装
COPY package*.json ./

# 安装项目依赖
RUN npm install --production

# 复制项目源代码到工作目录
COPY . .

# --- 第二阶段：生产 ---
# 使用一个干净的 Node.js Alpine 镜像作为最终的生产环境
FROM node:alpine

# 设置工作目录
WORKDIR /usr/src/app

# 创建一个非 root 用户 "node" 来运行应用，增强安全性
# 并将工作目录的所有权赋予该用户
RUN addgroup -S appgroup && adduser -S node -G appgroup
RUN chown -R node:appgroup /usr/src/app

# 从 "builder" 阶段复制安装好的依赖
COPY --from=builder /usr/src/app/node_modules ./node_modules

# 从 "builder" 阶段复制应用源代码
COPY --from=builder /usr/src/app .

# 切换到非 root 用户
USER node

# 暴露应用运行的端口 (这里假设是 3000)
# 您可以根据 index.js 中的实际端口进行修改
EXPOSE 3000

# 定义容器启动时运行的命令
CMD ["node", "index.js"]
