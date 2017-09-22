---
title: Vagrant集群配置，模拟多机分布式环境
date: 2017-08-25 03:43:31
tags:
 - Vagrant集群
categories:
 - 虚拟机/容器
banner: http://ov4crdzpr.bkt.clouddn.com/17-8-25/34757661.jpg
---
Vagrant是一个很好的虚拟机管理软件，常用来作为团队统一开发环境的工具。基本操作这里就不讲了，大家可以自己搜索。这里推荐篇我们以前老大写的一篇文章：[浅谈好居如何做到统一化的开发环境][1]

Vagrant搭建集群，可以模拟多机环境，平时用来研究分布式系统。比如服务器负载均衡、Web子系统间通信、数据库主从复制读写分离、以及Ansible自动化部署等等。

其实Vagrant可以很方便的实现集群，只需简单的配置下Vagrantfile。

可以先自己添加一个专门用来做集群的box，然后修改Vagrantfile文件，内容大致如下：
```ruby
Vagrant.configure(2) do |config|
  # 如果需要三台就(1..3)的形式
  (1..2).each do |i|
    config.vm.define "cluster#{i}" do |node|
      node.vm.box = "centos6"
      node.vm.hostname = "cluster#{i}"
      node.vm.network "private_network", type: "dhcp"
      # 映射目录 根据自己实际情况配置
      node.vm.synced_folder "../var/www/cluster", "/var/www/cluster"
      node.vm.provider "virtualbox" do |v|
        v.name = "cluster#{i}"
        v.memory = 512
        v.cpus = 1
      end
    end
  end
end
```
我这里ip是dhcp动态获取，你也可以结合自己网段指定ip。

改好后，vagrant up启动服务器：

![](http://ov4crdzpr.bkt.clouddn.com/17-8-25/2171202.jpg)

查看各主机ssh信息:

```bash
vagrant ssh-config
```

![](http://ov4crdzpr.bkt.clouddn.com/17-8-25/1265132.jpg)

比如这里可以使用vagrant ssh cluster1 进入cluster1主机，进去后ifconifg查下ip，后面可以用ssh客户端工具连接这条主机。

好了，是不是很简单，接下来去研究搭建你的分布式系统吧！

  [1]: http://tech.haoju.co/article/consistent-development-environment-using-vagrant
