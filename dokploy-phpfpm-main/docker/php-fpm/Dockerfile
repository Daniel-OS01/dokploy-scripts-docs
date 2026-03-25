FROM php:7.4.33-fpm

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装 GD 依赖和扩展包需要的工具
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 安装 mysqli 和 pdo_mysql
RUN docker-php-ext-install mysqli pdo_mysql

# 安装 ZIP 扩展
RUN docker-php-ext-install zip

# 配置并安装 GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# 配置 PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# 自定义 PHP 配置
RUN echo "memory_limit=1024M" >> /usr/local/etc/php/conf.d/docker-php-memory-limit.ini

# 启用 ZIP 扩展
# RUN echo "extension=zip.so" > "$PHP_INI_DIR/conf.d/zip.ini"

WORKDIR /var/www/html

# 使用 www-data 用户运行
USER www-data

EXPOSE 9000
CMD ["php-fpm"]
