---
title: 使用Docker compose编排Laravel项目
date: 2018-07-05 14:40:01
tags:
 - Docker
 - Laravel
categories:
 - 虚拟机/容器 
---

使用Docker compose编排Laravel应用

### 前言
Laravel官方开发环境推荐的是Homestead(其实就是一个封装好的Vagrant box)，我感觉这个比较重，于是自己用Docker compose编排了一套开发环境，在这里分享下。

### 环境要求

先要安装好Docker 和 Docker compose，而且Docker 仓库镜像最好换成国内的。一般地，我开发电脑上会运行一个Vagrant，然后再在里面运行Docker等应用。


### 主要思路

Docker官方推荐的是一个容器运行一个服务，所以会有Compose编排，各个服务间通过容器互联技术通信，比如Php服务连接Mysql只用把Host名写成容器名，内部会直接转换成具体ip。代码目录使用数据卷从容器内映射到宿主机，配置文件（Nginx等）也是通过数据卷映射到容器内。

### 实践

这套服务我已经封装好了，平时用的话只用clone下来直接使用，我这里主要讲下实现思路。

项目地址：https://github.com/rootrl/php-environment-with-docker

我的项目目录结构：

php-environment-with-docker/
├── bin
│   ├── composer
│   ├── getContainerIp
│   └── php
├── conf
│   ├── nginx
│   │   └── conf.d
│   │       └── nginx.conf
│   └── redis
│       └── redis.conf
├── docker-compose.yaml
├── Dockerfile.php
├── LICENSE
├── README.MD
└── start

* bin 这里面都是封装的命令行工具，其实也是Docker容器服务，只不过他们都是用完即走的服务。
* conf 该目录都是应用的配置目录，会使用Volumn映射到容器内
* docker-composer.yaml compose 的编排文件，下面会具体讲到
* Dockerfile.php php的镜像构建（里面会有一些定制，比如改dns，装特殊扩展）
* start 运行./start就可以启动所有服务，重启也可以运行此命令

#### docekr-compose.yaml

此文件是compose的编排文件

```yaml
version: '2'

services:
nginx:
  depends_on:
   - "php"

  image: "nginx"

  volumes:
   - "$PWD/conf/nginx/conf.d:/etc/nginx/conf.d"
   - "$PWD/www:/usr/share/nginx/html"
  ports:
   - "8888:80"
  networks:
   - oa-network
  container_name: "oa-nginx"
  command: /bin/bash -c "mkdir -p /var/www && ln -s /usr/share/nginx/html /var/www && nginx -g 'daemon off;'"
php:
  image: "oa-php-fpm"
  build:  
   context: .
   dockerfile: "Dockerfile.php"
  networks:
   - oa-network
  container_name: "oa-php-fpm"
  volumes:
   - "$PWD/www:/var/www/html"

mysql:
  image: mysql:5.7
  volumes:
   - "$PWD/db_data:/var/lib/mysql"
  environment:
   MYSQL_ROOT_PASSWORD: root123
   MYSQL_DATABASE: oa
   MYSQL_USER: oa
   MYSQL_PASSWORD: oa123
  ports:
   - "3306:3306"
  networks:
   - oa-network
  container_name: "oa-mysql"

redis:
  image: "redis"
  ports:
   - "6379:6379"
  networks:
   - oa-network
  volumes:
   - "$PWD/conf/redis/redis.conf:/usr/local/etc/redis/redis.conf"
  container_name: "oa-redis"

networks:
oa-network:
  driver: bridge

```

这里定义了php-fpm、nignx、mysql、redis四个服务（如果需要其他服务，自行添加）。然后定义了一个公共的networks，这样容器内都可以很方便地进行通信。

比如nginx.conf中

```bash
server {
    listen       80;
    server_name  localhost;
    root /usr/share/nginx/html/public;
    index index.php index.html;
    location / {
    try_files $uri $uri/ /index.php?$query_string;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
    location ~ \.php$ {
        fastcgi_pass   php:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /var/www/html/public/$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

这里与php-fpm的连接方式：php:9000

#### Dockerfile.php

```bash
FROM php:7.2-fpm
    Run echo "nameserver 223.5.5.5" >> /etc/resolv.conf \
    && echo "nameserver 223.6.6.6" >> /etc/resolve.conf \
    && apt-get update \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli pdo_mysql \
    && pecl install swoole \
    && pecl install redis \
    && docker-php-ext-enable swoole redis

```

这是Php镜像构建，这里改了dns服务器，并安装了若干php扩展。

### 使用

#### 启动
./start 启动所有服务

#### 命令行

```bash

./bin/php -v

# Laravel artisan
./bin/php artisan

```


### 总结

具体可访问：https://github.com/rootrl/php-environment-with-docker
