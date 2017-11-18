---
title: Docker实践 - 超简单配置ftp服务
date: 2017-11-18 09:08:58
tags:
  - nginx
  - ftp
  - docker

categories:
  - 虚拟机/容器

banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/docker-logo.jpg
---

## 缘起
前几天双十一的时候在京东上买了一台云虚拟机，很便宜，2g内存的才121元一年。买的时候产品那边同事就打招呼叫我帮他配个ftp服务平时上传浏览原型图用。

今天闲来无事就捣鼓这些环境，Nginx这边我一开始就是用Docker跑的，但是刚开始没想到也可以把ftp服务扔到容器里。

刚开始我只是在Centos下正规的配置vsftpd服务，但是后来有个问题一直难以解决，就是ftp登陆上传的时候，新建的文件所在用户组和other都没有权限，配置了umask也无济于事，selinux也关闭了，想到我ftp用户目录和docker里跑的nginx都是一个目录，这种复杂的环境，想想就头疼，啥方法都用尽了，就是解决不了。

## 实践
后来突然想到，我ftp不也可以直接扔docker吗？只用映射个21端口，然后在宿主机配个volume卷。然后去docker hub搜ftp镜像，没想到真的有一大堆，选来选去选了bogem/ftp，只因为这个配置简单，该有的也有。

地址：[https://hub.docker.com/r/bogem/ftp/][1]

就像说明说的，启动服务特简单：
```
docker run -d -v <host folder>:/home/vsftpd \
                -p 20:20 -p 21:21 -p 47400-47470:47400-47470 \
                -e FTP_USER=<username> \
                -e FTP_PASS=<password> \
                -e PASV_ADDRESS=<ip address of your server> \
                --name ftp \
                --restart=always bogem/ftp
```

用的时候相应参数改下就可以了。

我nginx这边服务也特简单，因为只用跑静态服务（当然要配个php-fpm服务也超级简单）
```
docker run -d --name ftp-server -v {跟ftp一个目录}:/usr/share/nginx/html:ro -p 81:80 nginx
```

这样整个服务就都启动啦，ftp可以正常上传，然后通过81端口可以访问静态页面。是不是超级简单。。以后啥服务都基本可以扔在docker跑了。


  [1]: https://hub.docker.com/r/bogem/ftp/
