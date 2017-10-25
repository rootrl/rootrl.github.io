---
title: Docker实践 - 运行Nginx和PHP环境
date: 2017-10-25 03:49:10
tags:
 - Docker

categories:
 - 虚拟机/容器

banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/docker-logo.jpg
---

Docker安装Nginx和PHP环境


## 启动php-fpm

```
docker run --name server-php -d \
    -v /var/www/html:/var/www/html:ro \
    php:7.1-fpm

```

* php:7.1-fpm 为选定的镜像

* --name 容器名称

* -v -volume简称 定义数据卷，":"符号前代表本地目录，":"符号后代表容器内目录，ro表示只读



## Nginx conf
编辑本地Nginx Conf文件：/var/conf/nginx/conf.d/default.conf

```
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location ~ \.php$ {
        fastcgi_pass   php:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /var/www/html/$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

php:9000为php-fpm服务路径


## 启动nginx
```
docker run --name server-nginx -p 80:80 -d \
    -v /var/www/html:/usr/share/nginx/html:ro \
    -v /var/conf/nginx/conf.d:/etc/nginx/conf.d:ro \
    --link server-php:php \
    nginx

```

## 测试
vim /var/www/html/index.php

```
<?php
phpinfo();
```

访问服务器地址。

## 总结
基本遵循docker的思想：
* 一个容器运行一个Application， -link链接容器
* 容器是无状态的，不要储存数据，所以-v挂载数据卷

实际使用改进
* 日志也映射出来（-v配置即可）
* 这种多容器实际上要用Compose管理（后面有时间补上，再加个mysql例子）

实用命令 
进入容器: docker exec -it 容器ID bash 
