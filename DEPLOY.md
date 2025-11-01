# Node.js 容器化部署指南

本文档将指导您如何使用 Docker 构建和部署此 Node.js 应用。

通过遵循这些步骤，您可以创建一个可移植、一致且隔离的运行环境，方便在任何支持 Docker 的机器上进行部署。

## 先决条件

-   **Docker**：确保您的部署环境中已安装 Docker。您可以从 [Docker 官网](https://www.docker.com/get-started) 获取适合您操作系统的安装包。

## 部署步骤

### 1. 构建 Docker 镜像

在项目的根目录（即 `Dockerfile` 所在的目录）中，打开终端并运行以下命令来构建 Docker 镜像：

```bash
docker build -t my-nodejs-app .
```

-   `docker build`：这是构建 Docker 镜像的命令。
-   `-t my-nodejs-app`：`-t` 参数用于给镜像打上一个标签（tag），方便后续引用。您可以将 `my-nodejs-app` 替换为您喜欢的任何名称。
-   `.`：这个点表示 Docker 的上下文路径，即 `Dockerfile` 所在的当前目录。

构建过程可能需要几分钟，Docker 会下载基础镜像、安装 npm 依赖，并按照 `Dockerfile` 中的指令执行每一步。

### 2. 运行 Docker 容器

镜像构建完成后，您可以使用 `docker run` 命令来启动一个容器。此应用通过**环境变量**来接收配置参数，您需要在运行时通过 `-e` 标志来传递它们。

以下是一个启动容器的示例命令：

```bash
docker run -d -p 3000:3000 \
  -e PORT=3000 \
  -e UUID="your-custom-uuid" \
  -e NEZHA_SERVER="your-nezha-server-domain" \
  -e NEZHA_PORT="your-nezha-server-port" \
  -e NEZHA_KEY="your-nezha-secret-key" \
  -e ARGO_DOMAIN="your-argo-tunnel-domain" \
  -e ARGO_AUTH="your-argo-auth-token-or-secret" \
  --name my-running-app my-nodejs-app
```

#### 命令参数解释：

-   `docker run`：运行一个容器的命令。
-   `-d`：表示在后台（detached mode）运行容器，这样终端就不会被占用。
-   `-p 3000:3000`：进行端口映射。
    -   第一个 `3000` 是您**宿主机**的端口。
    -   第二个 `3000` 是**容器内部**应用监听的端口（与 `Dockerfile` 中 `EXPOSE` 的端口以及您环境变量中 `PORT` 的值对应）。
    -   您可以根据需要更改宿主机端口，例如 `-p 8080:3000` 将使您可以通过宿主机的 8080 端口访问应用。
-   `-e KEY="VALUE"`：设置环境变量。您需要将示例中的 `your-custom-uuid` 等占位符替换为您的实际配置。
-   `--name my-running-app`：为正在运行的容器指定一个易于识别的名称。
-   `my-nodejs-app`：指定要运行的镜像名称，即您在 `docker build` 步骤中设置的标签。

#### 主要环境变量列表：

根据 `index.js` 的分析，以下是一些您可能需要配置的关键环境变量：

-   `PORT`：应用在容器内监听的端口，默认为 `3000`。
-   `UUID`：您的用户标识符。
-   `NEZHA_SERVER`：哪吒监控的服务器地址。
-   `NEZHA_PORT`：哪吒监控的服务器端口。
-   `NEZHA_KEY`：哪吒监控的密钥。
-   `ARGO_DOMAIN`：Argo Tunnel 的域名。
-   `ARGO_AUTH`：Argo Tunnel 的认证信息（可能是 token 或 secret JSON）。
-   `UPLOAD_URL`：节点信息上传的目标 URL (可选)。
-   `PROJECT_URL`：项目 URL (可选)。
-   `SUB_PATH`: 订阅文件路径 (可选，默认为 `sub.txt`)。

**请根据您的实际需求，在 `docker run` 命令中添加或修改相应的 `-e` 参数。**

### 3. 查看容器状态和日志

-   **查看正在运行的容器**：
    ```bash
    docker ps
    ```
-   **查看容器日志**（用于调试或确认应用是否正常启动）：
    ```bash
    docker logs my-running-app
    ```
    如果您需要实时查看日志，可以添加 `-f` 参数：
    ```bash
    docker logs -f my-running-app
    ```

### 4. 停止和移除容器

-   **停止容器**：
    ```bash
    docker stop my-running-app
    ```
-   **移除已停止的容器**（如果您想清理）：
    ```bash
    docker rm my-running-app
    ```

## 总结

现在您已经拥有了一个包含应用及其所有依赖的、可随时部署的 Docker 镜像。您只需要在目标服务器上运行 `docker run` 命令并提供正确的环境变量，即可轻松完成部署。
