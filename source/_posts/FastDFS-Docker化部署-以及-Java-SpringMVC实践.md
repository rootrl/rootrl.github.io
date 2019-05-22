---
title: FastDFS Docker化部署 以及 Java SpringMVC实践
date: 2019-05-22 21:23:39
tags:
 - Java
 - FastDFS
 - Docker
categories:
 - 开发语言
 - Java
---

FastDFS Docker化部署 以及 Java SpringMVC实践

### 简介
FastDFS是一个轻量级分布式文件系统。可以对文件进行管理，功能包括：文件存储、文件同步、文件访问（文件上传、文件下载）等，而且可以集群部署，有高可用保障。相应的竞品有Ceph、TFS等。相比而言FastDFS对硬件的要求比较低，所以适合中小型公司。


### 概念

FastDFS服务端由两个重要部分组成：跟踪器（Tracker）和存储节点（Storage）。

Tracker主要做调度工作，在访问上起负载均衡的作用。Tracker可以做集群部署，各个节点之间是平等的，客户端请求时采用轮询机制，某个Tracker不能提供服务时就换另一个。Storage启动后会连接到Tracker Server告知自己的Group信息，形成映射关联，并采用心跳机制保持状态。
Storage存储节点负责文件的存储，Storage可以集群部署。

Storage集群有以下特点：
- 以组（Group）为单位（也有称呼为卷 Volume的），集群的总容量为所有组的集合。
- 一个卷（组）内storage server之间相互通信，文件进行同步，保证卷内storage完全一致，所以一个卷的容量以最小的服务器为准。不同的卷之间相互不通信。
- 当某个卷的压力较大时可以添加storage server（纵向扩展），如果系统容量不够可以添加卷（横向扩展）。

### 上传流程

此章节根据资料整理，可能随着版本有所改变，这里只介绍大致的，以便了解整个运作流程。如果需要深入研究，建议还是以官方文档为标准。

一，客户端请求会打到负载均衡层，到tracker server时，由于每个server之间是对等的关系，所以可以任意选择一个tracker server。

二，到storage层：tracker server接收到upload file请求时，会为该请求分配一个可以存储该文件的group。

分配group规则：
- Round robin 轮询
- Specified group 指定一个group
- Load balance 剩余存储空间多的group优先

三，确定group后，tracker会在group内选择一个storage server给客户端。

   在group内选择storage server时规则：
- Round robin 轮询
- First server ordered by ip 按ip排序
- First server ordered by priority，按优先级排序（优先级在storage上配置）

四，选择storage path：当分配好storage server后，客户端向storage发送写文件请求，storage将会为文件分配一个数据存储目录，支持规则如下：

- round robin 轮询
- 剩余存储空间最多的优先

五，生成File id：选定存储目录之后，storage会为文件生成一个File id。规则如下：
    由storage server ip、文件创建时间、文件大小，文件crc32和一个随机数拼接而成，然后将这个二进制串进程base64编码，转换为可打印的字符串。

六，选择两级目录：每个存储目录下有两级256 * 256的子目录，storage会按文件Field进行两次hash，路由到其中的一个目录，然后将文件以file id为文件名存储到该子目录下。

一个文件路径最终由如下组成：组名/磁盘/目录/文件名

七，客户端upload file成功后，会拿到一个storage生成的文件名，接下来客户端根据这个文件名即可访问到该文件。


### 下载流程

下载流程如下：

一，选择tracker server：和upload file一样，在download file时随机选择tracker server。

二，选择group：tracker发送download请求给某个tracker，必须带上文件名信息，tracker从文件名中解析出group、大小、创建时间等信息，根据group信息获取对于的group。

三，选择storage server：从group中选择一个storage用来服务读请求。由于group内的文件同步时在后台异步进行的，所以有可能出现在读到的时候，文件还没有同步到某些storage server上，为了尽量避免反问道这样的storage，tracker按照一定的规则选择group内可读的storage。

### 文件HTTP预览服务

Storage还可以结合nginx的fastdfs-nginx-module提供http服务，以实现图片等预览功能。

这个部分这里不做介绍，后续可能单独写篇文章，因为我发现对fastDFS集群提供http服务还是挺复杂，包括我下面找的docker镜像都不完善，主要是规划的问题，包括衍生的服务，缓存，以及对图片的处理（nginx+lua）这些，后续打算研究下，重新开源个docker构建镜像。

### 实战

#### 安装、部署规划

FastDFS安装方法网上有很多教程，这里不多讲，我建议使用docker来运行FastDFS，可以自己根据安装步骤构建自己的镜像。然后在需要的机器直接运行，后续扩容也方便，再启动一个storage容器就可以了。

详细版安装推荐篇文章：https://segmentfault.com/a/1190000008674582

#### Docker集群搭建

我这里从github上找的一个别人构建好的镜像，可以直接使用。地址：https://github.com/luhuiguo/fastdfs-docker

使用方法也很简单

```bash

# 启动一个tracker服务器
docker run -dti --network=host --name tracker -v /var/fdfs/tracker:/var/fdfs luhuiguo/fastdfs tracker

# 启动storage0
docker run -dti --network=host --name storage0 -e TRACKER_SERVER=10.1.5.85:22122 -v /var/fdfs/storage0:/var/fdfs luhuiguo/fastdfs storage

# 再启动一个storage1
docker run -dti --network=host --name storage1 -e TRACKER_SERVER=10.1.5.85:22122 -v /var/fdfs/storage1:/var/fdfs luhuiguo/fastdfs storage

# 启动一个新组的storage
docker run -dti --network=host --name storage2 -e TRACKER_SERVER=10.1.5.85:22122 -e GROUP_NAME=group2 -e PORT=22222 -v /var/fdfs/storage2:/var/fdfs luhuiguo/fastdfs storage
```


#### 部署注意点
1，原github地址上的usage介绍，启动storage0和storage1有一个参数错误(多一个-e)，以我上面发的命令为准。
2，这里的TRACKER_SERVER注意改为你自己的，同一个网段内网ip。

3，实际上这里docker容器之间还是同一个物理主机上部署的(根据network而言)，虽然后续可以通过加硬盘，然后新建storage绑定到新加硬盘mount上，但是如果是大公司的生产环境还是推荐建立一个overlay网络，具体见：https://www.cnblogs.com/bigberg/p/8521542.html，这样可以直接扩物理机集群了。另外这里也提供docker-compose方式启动服务，实际也不推荐使用，因为tracker和storage server以后必然是分开的，所以还是推荐单个docker容器保持灵活性。这里高级点可以用k8s进行自动扩容（后续打算重新开源个镜像）。

### Java实践

#### 导入需要包
这里使用官方的客户端包：https://github.com/happyfish100/fastdfs-client-java
```bash
# 下载源码
git clone https://github.com/happyfish100/fastdfs-client-java.git

cd fastdfs-client-java

# 打jar包
mvn clean install

# 输出目录
cd target

# 导入到本地仓库 注意这里version根据实际生成的来
mvn install:install-file -DgroupId=org.csource -DartifactId=fastdfs-client-java -Dversion=1.27-SNAPSHOT -Dpackaging=jar -Dfile=fastdfs-client-java-1.27-SNAPSHOT.jar
```

#### 在pom.xml中引入依赖

```bash
    <dependency>
        <groupId>org.csource</groupId>
        <artifactId>fastdfs-client-java</artifactId>
        <version>1.27-SNAPSHOT</version>
    </dependency>

    <dependency>
      <groupId>commons-fileupload</groupId>
      <artifactId>commons-fileupload</artifactId>
      <version>1.3.1</version>
    </dependency>

    <dependency>
      <groupId>commons-io</groupId>
      <artifactId>commons-io</artifactId>
      <version>2.2</version>
    </dependency>

    <dependency>
      <groupId>org.apache.commons</groupId>
      <artifactId>commons-lang3</artifactId>
      <version>3.1</version>
    </dependency>
```

#### 添加Client配置

在resource目录下，添加conf/fdfs_client.conf配置文件
```bash
connect_timeout = 2
network_timeout = 30
charset = UTF-8
http.tracker_http_port = 80
http.anti_steal_token = no
http.secret_key = FastDFS1234567890

tracker_server = 192.168.1.163:22122
```
测试时实际上只需关注tracker_server，并且改为你自己的tracker server


#### 添加文件上传bean
applicationContext.xml配置中添加文件上传bean
```bash
    <bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
        <property name="maxUploadSize" value="62914560" />
        <property name="defaultEncoding" value="UTF-8" />
    </bean>
```
#### 建一个Client封装
建一个简单的client封装（勿作生产使用）
FastDFSClient.java
```java
package com.rootrl.fastDFSDemo.utiles;

import org.apache.commons.lang3.StringUtils;
import org.csource.common.NameValuePair;
import org.csource.fastdfs.*;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

public class FastDFSClient {

    private static StorageClient1 storageClient1 = null;

    static {
        try {
            // 获取配置文件
            String classPath = new File(FastDFSClient.class.getResource("/").getFile()).getCanonicalPath();
            String CONF_FILENAME = classPath + File.separator + "conf" + File.separator + "fdfs_client.conf";
            ClientGlobal.init(CONF_FILENAME);
            // 获取触发器
            TrackerClient trackerClient = new TrackerClient(ClientGlobal.g_tracker_group);
            TrackerServer trackerServer = trackerClient.getConnection();
            // 获取存储服务器
            StorageServer storageServer = trackerClient.getStoreStorage(trackerServer);
            storageClient1 = new StorageClient1(trackerServer, storageServer);
        } catch (Exception e) {
            System.out.println(e);
        }
    }

    /**
     * 上传文件
     * @param fis      文件输入流
     * @param fileName 文件名称
     * @return
     */
    public static String uploadFile(InputStream fis, String fileName) {
        try {
            NameValuePair[] meta_list = null;

            //将输入流写入file_buff数组
            byte[] file_buff = null;
            if (fis != null) {
                int len = fis.available();
                file_buff = new byte[len];
                fis.read(file_buff);
            }

            String fileid = storageClient1.upload_file1(file_buff, getFileExt(fileName), meta_list);
            return fileid;
        } catch (Exception ex) {
            return null;
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (IOException e) {
                    System.out.println(e);
                }
            }
        }
    }


    /**
     * 获取文件后缀
     * @param fileName
     * @return
     */
    private static String getFileExt(String fileName) {
        if (StringUtils.isBlank(fileName) || !fileName.contains(".")) {
            return "";
        } else {
            return fileName.substring(fileName.lastIndexOf(".") + 1);
        }
    }
}

```
#### 建立控制器
然后建立一个File控制器，做测试用
FileController.java
```java
package com.rootrl.fastDFSDemo.controller;

import com.rootrl.fastDFSDemo.utiles.FastDFSClient;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

@Controller
@RequestMapping("fastdfs")
public class FileController {

    @RequestMapping(value = "upload")
    @ResponseBody
    public String uploadFileSample(@RequestParam MultipartFile file){

        try {
            String fileId = FastDFSClient.uploadFile(file.getInputStream(), file.getOriginalFilename());

            return fileId;

        } catch (Exception e) {
            System.out.println(e.getMessage());
            return "error";
        }
    }

}

```

然后使用postman客户端测试，url为：http://localhost:8080/fastdfs/upload.do（依据自己实际情况变更）

注意postman使用post请求，然后切换到body/form-data标签项，添加一个Key为file，类型为file，然后value就可以上传文件了。成功会返回文件id，类似：group1/M00/00/00/wKgBo1zjxnOAT-k1AAAoMlb3hzU996.png


### 参考
https://blog.csdn.net/yxflovegs2012/article/details/53868362
