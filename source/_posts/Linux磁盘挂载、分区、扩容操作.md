---
title: Linux磁盘挂载、分区、扩容操作
date: 2018-11-30 22:45:38
tags:
 - Linux
 - mount
categories:
 - Unix/Linux
---
注：以下操作系统环境为CentOS7

### 基本概念

在操作前，首先要了解一些基本概念

#### 磁盘

在Linux系统中所有的设备都会以文件的形式存储。设备一般保存在/dev目录下面，以sda、sda1、sda2 ...,sdb、sdb1...,hda,hdb。现在的设备一般都是sd命名，以前的很老的硬盘是以ha命名。
sda：第一块硬盘，如果对磁盘进行了分区会有sda1(第一个分区)，sda2等。
sdb：第二个硬盘，同样对硬盘分区后有sdb1,sdb2等。

#### 分区

分区的目的就是便于管理，比如在Windows系统我们一般会分C盘，D盘，E盘等。

Linux只能创建4个主分区，如果需要创建更多的分区那么久必须创建逻辑分区，其中逻辑分区需要占用一个主分区。

#### 文件系统

Linux中的文件系统也就是分区类型，在Windows中有NTEF,FAT32等，linux中常见的有Ext2、Ext3、Ext4、Linux swap、proc、sysfs、tmpfs等，可以通过mount命名查看当前已挂载的文件系统。

#### 格式化

在前面创建完分区后有一步是要对分区进行格式化，其实在Windows系统中也是一样，在创建好一个分区后也需要将分区格式化，只有格式化成具体的文件类型才能使用。

#### 挂载
在Windows中分区格式化后就可以使用，但是在Linux系统中必须将分区挂载到具体的路径下才可以。

### 常用命令
```bash
lsblk  查看当前磁盘情况
df -lh  查看文件系统情况 -l 查看挂载点
parted -l 会列出文件系统类型
fdisk -l 查看当前未挂载硬盘
```

### 挂载新硬盘

挂载一个新硬盘基本思路是：创建分区、创建文件系统、挂载。

#### 一、查看新硬盘

首先，查看硬盘状况：

```bash
fdisk -l
```

其中：
如果磁盘下面有类似：Disk /dev/sdc doesn't contain a valid partition table；或者说磁盘下面没有类似于：sdb1 sdb2 说明该磁盘未挂载

这里假设看到硬盘名为 /dev/sdb


#### 二、创建分区

```bash
dfisk /dev/sdb
```

根据提示，依次输入"n"，"p" "1"，两次回车，"wq"
意思就是新建一个主分区（1），大小是整个sdb磁盘，然后写入。

注：上述操作为了简便，只是创建一个主分区。其实一个磁盘最多有四个主分区（包括一个扩展分区），1-4都是主分区，我们也可以把一个分区作为扩展分区（通过df -lh 查看到的system为Extended）

此时磁盘已经分区，但是还没有文件系统，磁盘依然不能用


#### 三、写入系统

```bash
mkfs.ext4 /dev/sdb
```
该命令会格式化磁盘并写入文件系统


#### 四、挂载

比如挂载到/data下面
```
mkdir /data # 如果存在此步省略
mount /dev/sdb /data
```


#### 五、设置开机自动挂载

以上只是临时挂载，还需设置为开机自动挂载

```
vim /etc/fstab


# 然后在内容结尾处增加一行（注意文件类型要对应）：

/dev/sdb    /data    ext4    defaults    0 0

```


### 扩容

#### 关于挂载到已有目录

如果你要用来挂载的目录里面并不是空的，那么挂载了文件系统之后，原目录下的东西就会暂时的消失。并不是被覆盖掉，而是暂时的隐藏了起来，等到新分割槽被卸除之后，则原目录原本的内容就会再次出来。

如果要永久挂载已有目录，可以在新硬盘创建文件系统后，先挂载到一个临时目录，然后把要扩展的目录复制到这临时目录，然后删除要扩展的目录，再卸载临时挂载点，重新挂载到要扩展的目录上。举例：

```
# 比如要扩充 /var

# 在创建好文件系统后 新建临时挂载点 storage
mkdir /storage

# 将/dev/sdb1挂载到/storage下
mount /dev/sdb1  /storage

# 拷贝/var下的所有内容到新的硬盘
cp -pdr /var /storage
# 或在/var 目录下执行：find . -depth -print | cpio - pldvm /temp
# 删除当前/var目录下的内容
rm -rf /var/*
# 重新挂载硬盘到/var目录
umount /dev/sdb1
mount /dev/sdb1 /var

# 过程中若提示磁盘忙，使用fuser找出将正在使用磁盘的程序并结束掉；

fuser -m -v /var
fuser -m -v -i -k /var

```

### 扩展

如果扩容比较频繁，那推荐使用LVM管理（最后一个参考链接）


### 参考
http://www.cnblogs.com/chenmh/p/5096592.html
https://segmentfault.com/a/1190000004585900
https://blog.csdn.net/wzb56_earl/article/details/7580601
https://www.cnblogs.com/sourceforge/p/mount-folder-to-new-disk-in-centos.html
http://www.cnblogs.com/gaojun/archive/2012/08/22/2650229.html
