---
title: 用Golang撸了个小工具
date: 2018-06-07 20:38:02
tags:
 - Golang
categories:
 - 开发语言
 - Golang
---
## 缘起

我们公司开发环境很特殊，一台本地服务器，然后分配多个ssh账户给开发者。平时上传代码只能ftp/sftp连接上传（以前用过samba共享，但被关了。。）。所以我们平时是在Phpstorm上用sftp远程打开服务器上的项目，然后设置自动上传。这样一般工作没问题。但是有个坑：Phpstorm无法捕获类似git checkout这些更改文件的变化。。所以也就无法让本地代码跟服务器保持一致了。所以也就诞生了想写个这个同步机制的念头，这种场景Golang很适合。于是就开始撸起来。。


项目地址：[https://github.com/rootrl/Mancy][1]


## 实现

大致思路是监测一个文件夹的变化（本地代码库），如果有变化就通过sftp上传到服务器上。

监测文件变化用的是golang的fsnotify package，它提供的监测变化类型如下：

```golang
const (
    FSN_CREATE = 1
    FSN_MODIFY = 2
    FSN_DELETE = 4
    FSN_RENAME = 8

    FSN_ALL = FSN_MODIFY | FSN_DELETE | FSN_RENAME | FSN_CREATE
)
```

但是fsnotify有个坑就是只能监测一层文件夹的变化，多层文件夹需要自己遍历挂载事件。后续新建文件夹，重命名这种也要手动加事件。

其中每个事件都对应一个处理通道，我的想法是让文件处理者和事件解耦，因为后面不一定是sftp来处理上传，也可能是rsync，也可能其他处理方式。所以后续处理者只用监听对应事件通道，处理者这里我用了golang的select实现了一个超时机制，有事件就处理，无事件有个几秒的等待时间。

fsnotify这块代码见： [https://github.com/rootrl/Mancy/blob/master/file_watcher.go][2]
sftp hanlder见： [https://github.com/rootrl/Mancy/blob/master/file_sftp_handler.go][3]


sftp用的是github.com/pkg/sftp这个库，用起来还是挺顺手，但都是写底层的api，所以我单独封装了个sftp_util: [https://github.com/rootrl/Mancy/blob/master/sftp_util.go][4] 有一些常见的上传文件/文件夹，删除文件/文件夹等操作


以上基本能实现主要功能了，然后我还定义了个配置文件结构，通过对应Json字符可以把字段自动映射到这个结构上，供后续使用。这也是golang json包的方便之处。

## 总结
写这个项目主要是用来练手golang的，刚开始阶段，代码可能写得有点垃圾。。比如sftpClent客户端这些目前是用全局变量实现的，能用，但是不够优雅。。后续慢慢改进。。（可能永远不会。。）

总之，Golang还是挺不错的！


  [1]: https://github.com/rootrl/Mancy
  [2]: https://github.com/rootrl/Mancy/blob/master/file_watcher.go
  [3]: https://github.com/rootrl/Mancy/blob/master/file_sftp_handler.go
  [4]: https://github.com/rootrl/Mancy/blob/master/sftp_util.go
