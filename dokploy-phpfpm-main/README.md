# dokploy-phpfpm

`dokploy-phpfpm` 是一个用于快速部署 PHP-FPM 应用的 [Dokploy](https://github.com/Dokploy/dokploy) 项目模板。

## 特性

* 预配置的 PHP-FPM 环境
* 可选的 Nginx Web 服务器
* 简单的 Docker Compose 配置
* 方便的开发和部署流程

## 快速开始

1.  **克隆仓库：**
    ```bash
    git clone https://github.com/Ariesly/dokploy-phpfpm.git
    cd dokploy-phpfpm
    ```
2.  **构建镜像：**
    ```bash
    docker-compose build
    ```
3.  **启动容器：**
    ```bash
    docker-compose up -d
    ```
4.  **访问应用：**
    在浏览器中访问 `http://localhost`（如果使用了 Nginx）。

## 目录结构

```
dokploy-phpfpm/
├── docker-compose.yml   # Docker Compose 配置文件
├── docker/              # Dockerfile 目录
│   └── php-fpm/         # PHP-FPM
├── src/                 # PHP 应用目录
│   └── ...              # 您的 PHP 应用代码
├── nginx/               # Nginx 配置目录（可选）
│   └── conf.d/          # Nginx 配置文件
│       └── default.conf # Nginx 默认配置文件
└── ...
```

## 自定义配置

* **修改 PHP 配置：**
    编辑 `docker/php-fpm/Dockerfile` 或在 `src/` 目录下添加 `php.ini` 文件。
* **修改 Nginx 配置：**
    编辑 `nginx/conf.d/default.conf` 文件。
* **添加依赖项：**
    在 `docker/php-fpm/Dockerfile` 中添加 `RUN` 指令安装所需的 PHP 扩展或依赖项。
* **修改端口映射:**
    在 `docker-compose.yml` 文件中修改端口映射。

## 注意事项

* 请确保您的系统已安装 Docker 和 Docker Compose。
* 根据您的应用需求，可能需要调整 Dockerfile 和 Docker Compose 配置文件。