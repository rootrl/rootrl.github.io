---
title: Docker实践 - 入门篇
date: 2017-09-22 07:57:56
tags:
 - Docker

categories:
 - 虚拟机/容器

banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/docker-logo.jpg
---
## 简介
Docker 是使用 Go 语言 进行开发实现的，基于 Linux 内核的 cgroup，namespace，以及 AUFS 类的 Union FS 等技术，对进程进行封装隔离，属于 操作系统层面的虚拟化技术。由于隔离的进程独立于宿主和其它的隔离的进程，因此也称其为容器。

下面的图片比较了 Docker 和传统虚拟化方式的不同之处。传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程；而容器内的应用进程直接运行于宿主的内核，容器内没有自己的内核，而且也没有进行硬件虚拟。因此容器要比传统虚拟机更为轻便。

![虚拟机][1]

#### 虚拟机


![Docker][2]

#### Docker

## 基本概念
Docker三大概念：镜像、容器、仓库

镜像
Docker 镜像是一个特殊的文件系统，除了提供容器运行时所需的程序、库、资源、配置等文件外，还包含了一些为运行时准备的一些配置参数（如匿名卷、环境变量、用户等）。镜像不包含任何动态数据，其内容在构建之后也不会被改变。
镜像还有一个重要概念就是分层储存，镜像构建时，会一层层构建，前一层是后一层的基础。每一层构建完就不会再发生改变，后一层上的任何改变只发生在自己这一层。

容器
镜像（Image）和容器（Container）的关系，就像是面向对象程序设计中的类和实例一样，镜像是静态的定义，容器是镜像运行时的实体。容器可以被创建、启动、停止、删除、暂停等。

容器的实质是进程，但与直接在宿主执行的进程不同，容器进程运行于属于自己的独立的 命名空间。因此容器可以拥有自己的 root 文件系统、自己的网络配置、自己的进程空间，甚至自己的用户 ID 空间。容器内的进程是运行在一个隔离的环境里，使用起来，就好像是在一个独立于宿主的系统下操作一样。这种特性使得容器封装的应用比直接在宿主运行更加安全。也因为这种隔离的特性，很多人初学 Docker 时常常会把容器和虚拟机搞混。

前面讲过镜像使用的是分层存储，容器也是如此。每一个容器运行时，是以镜像为基础层，在其上创建一个当前容器的存储层，我们可以称这个为容器运行时读写而准备的存储层为容器存储层。

容器存储层的生存周期和容器一样，容器消亡时，容器存储层也随之消亡。因此，任何保存于容器存储层的信息都会随容器删除而丢失。

按照 Docker 最佳实践的要求，容器不应该向其存储层内写入任何数据，容器存储层要保持无状态化。所有的文件写入操作，都应该使用 数据卷（Volume）、或者绑定宿主目录，在这些位置的读写会跳过容器存储层，直接对宿主(或网络存储)发生读写，其性能和稳定性更高。

数据卷的生存周期独立于容器，容器消亡，数据卷不会消亡。因此，使用数据卷后，容器可以随意删除、重新 run，数据却不会丢失。

仓库
镜像构建完成后，可以很容易的在当前宿主上运行，但是，如果需要在其它服务器上使用这个镜像，我们就需要一个集中的存储、分发镜像的服务，Docker Registry 就是这样的服务。
仓库分为共有仓库和私有仓库

这些概念都是搜索来的，由于要控制时间和篇幅故没有好好整理（本篇博客的关注点也不在这），大家最好先自行搜索理解Docker的基本概念，这有利于后期实践。


## 安装
Docker官网提供两个版本即Docker CE（社区免费版）和 Docker EE（企业版），我们这里使用Docker CE
由于Docker CE要求Linux内核必须3.10以上，所以这里选用Centos7.2版本（7.0满足内核最低要求），不过用Centos跑Docker生产环境不推荐使用（好像是储存驱动和部分功能不稳定，具体可以自己了解）。

作为实验，我这里是用Vagrant启动一个Centos虚拟机来跑Docker

首先安装环境依赖
```bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

为了加快速度，这里使用国内阿里云源
```bash
sudo yum-config-manager \
--add-repo \
https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

安装Docker CE
```bash
sudo yum makecache fast
sudo yum install docker-ce
```

启动docker
```
 sudo systemctl enable docker
 sudo systemctl start docker
```

创建Docker用户组，并把当前用户加入管理组
```
sudo groupadd docker
sudo usermod -aG docker $USER

```

为了提高以后镜像下载速度，大家可以使用镜像加速器（这里不讲了，具体百度，很简单，就是替换docekrhub仓库地址）

Docker使用：

### 获取镜像
docker pull [选项] [Docker Registry地址]<仓库名>:<标签>

这里如果Registry地址不写，默认就是Dockerhub
比如我们下载一个Centos6.6的镜像：

```
docker pull centos:6.6
```

下载好后可以查看下载的镜像

```
docker images
```
### 运行镜像
```
docker run --name centos -it --rm centos:6.6 /bin/bash
```

* -i 和 -t 是使用交互命令 还有一个用得多的就是-p 端口映射，比如把容器80端口映射到本机81端口: -p 81:80

* --rm 是退出后删除容器
* --name 是给容器命名


这里会启动一个bash交互窗口，操作和在Centos中一样，但这一切只是一个进程，所以启动速度非常快

我们这里是用Docker run 来运行一个镜像


Docker run时的标准操作：
* 检查本地是否存在指定镜像， 不存在就从公有库进行下载
* 利用镜像创建并启动一个容器
* 分配一个文件系统，并在只读的镜像层外面挂载一层只读写层
* 从宿主机配置的网桥接口中桥接一个虚拟接口到容器中
* 从地址池配置一个ip地址给容器
* 执行用户指定的应用程序
* 执行完毕后容器被终止

操作完成后我们可以使用exit或者Ctrl+d退出容器

平时如果我们要在后台运行一个容器可以使用-d参数

```
docker run -itd centos:6.6 /bin/bash
```

这样容器就会在后台运行

这时候可以使用docker ps查看目前正在运行的容器，以及容器信息（包括容器ID）

如果要进入容器
```
docker attach <容器ID>
```

要终止一个容器可以使用
```
docker stop <容器ID>
```

使用docker ps -a可以查看所有容器，包括终止的

假如再次启动一个容器：
```
docker start <容器ID>
```

删除一个容器：
```
docker rm <容器ID>
```
docker rm 不会删除正在运行的容器

删除所有容器：
```
docker rm $(docker ps -a -q)
```

下面是我自己想的(使用awk和xargs)：
```
docker rm $(docker ps -a | awk '{if (NR > 1) print $1}'|xargs) 
```

导入和导出容器

导出
```
docker export 容器ID > ubuntu.tar
```

导入
```
cat unbuntu.rar | docker import - test/ubuntu:v1.0
```

也可以从一个网络地址导入
```
docker import http://dfsdf.taz example/imagesrepo
```


由于容器非常轻量，所以一般都是随时删除和创建容器的

容器的核心为所执行的应用程序，所需要的资源都是应用程序运行所必须的。除此之外，没有任何其他资源，可以在容器内用ps 或 top查看


### 构建镜像：
镜像一般是基于一个基础镜像构建，比如我们在centos6.6镜像上构建lanp环境
一般会用Dockerfile定制镜像

这里做个小例子，比如一般我们运行一个nginx容器，默认访问会是官方的欢迎界面，这里我们构建一个镜像，让它默认运行起来就是一个hello docker的界面

#### Dockerfile

mkdir创建一个测试的dir，然后进入创建一个Dockerfile文件，内容如下
```
From nginx # 基于nginx基础镜像

RUN echo "<h1>Hello, Docker!</h1>" > /usr/share/nginx/html/index.html # 重写index.html
```

先说说Dockerfile的格式
\# 后面的为注释
\ 是换行 （写多行shell命令实用）

再来说说Dockerfile的指令，这里我们使用了两条指令

FROM
指定基础镜像，这个是必备也必须是第一条指令

RUN
运行命令，也是最常用的命令
注意：
每个RUN命令都是不同的容器中，不是同一个执行环境
每一个RUN命令都是启动一个容器，执行命令，然后提交存储层文件变更。
比如你这样操作：
```
RUN cd /app
RUN echo "hello" > world.txt
```

这里/app/world.txt会找不到文件

还有许多其他指令这里就不深入了：
copy 复制指令，注意源文件是在上下文环境下面
add 跟高级的复制，不建议使用
cmd容器启动命令
docker不是虚拟机，docker是进程，在启动的时候需要指定运行参数，
CMD ["sh", "-c", "service nginx start"]

ENTRYPOINT入口点
docker 命令行可以接受参数

ENV 设置环境变量

ARG构建参数

VOLUME定义匿名卷

EXPOSE声明端口

WORKRIR 指定工作目录

USER指定当前用户

HEALTHCHECK 健康检查

ONBUILD 当前镜像为基础镜像去构建下一个镜像时会被执行

#### 构建镜像
好了下面我们可以在当前目录（Dockerfile所在目录）构建镜像
```
docker build -t nginx:v2 .  #注意此处的点为上下文目录，不能为绝对地址（具体自己可以去延伸）
```

然后 docker images就可以看到我们的镜像了

可以把容器跑起来看看
```
Docker run -it -p 80:80 nginx:v2
```

好了，由于篇幅原因，就到这里了，都是调研时事后整理的，所以比较琐碎，命令执行结果也没有截图（嫌Markdown中贴图麻烦，还要放到图床中，说到图床，以后图片我会直接贴到github了，具体操作是在Hexo Source目录下建立images目录，图片放到这目录然后提交到github，然后在网页中获取地址，这样就可以贴图了，而且图片资源可以和博客共存亡了，嘿嘿，总觉得图片放到其他地方不安全，以后某天图片会莫名访问不了）

接下来会深入调研，Docker的资源管理（因为Docker容器的储存层会和容器生命周期一起消亡，官方不提倡直接在容器中存储数据，应该跳过储存层，直接读写宿主机的存储机制，比如使用数据卷Volume实现），还有Docker的集群管理、容器监控，以及大名鼎鼎的Kubernetes


  [1]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/virtualization.png
  [2]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/docker.png

