---
title: Npm常见
date: 2017-09-29 04:13:53
tags:
 - npm
categories:
 - 前端
 - 工具

banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/npm.jpg
---

## 关于安装
Npm安装分为局部安装和全局安装

### 全局安装

通过 加 --global/-g 安装

包会被安装在{prefix}/lib/node_modules下面

其中{prefix}通常是/usr/或/usr/local

通过以下命令可以获取具体prefix
```
npm config get prefix
```

通过npm list可以查看全局路径下的所有包（加--depth=0可以缩短显示效果）

### 局部安装
包会被安装到项目根目录下的node_modules文件夹下面，属于当前用户的。

一般依赖package.json文件安装
通过npm init命令一路回车就会在根目录下面创建package.json文件

```
{
  "name": "project",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
```
main表示程序入口文件，scripts指定运行脚本命令缩写。

比如安装underscore
```
npm install underscore
```
就会发现dependencies已经被添加

```
{
  ...
  "dependencies": {
    "underscore": "^1.8.3"
  }
}
```

其中插入符号（^）表示安装不低于此版本的包。
npm默认安装时为把安装的包存为dependencies域，如果指定--save-dev就会填入devDependencies
其中：
* Dependencies为程序运行必备的包
* DevDependencies 是开发时所需要的包

### 安装过程
npm安装模块过程：
* 发出npm install命令
* npm 向 registry 查询模块压缩包的网址
* 下载压缩包，存放在~/.npm目录
* 解压压缩包到当前项目的node_modules目录


## 删除包
```
npm uninstall underscore
```

## 更新包
首先检查包是否有有更新
```
npm outdated

Package     Current  Wanted  Latest  Location
underscore    1.8.2   1.8.3   1.8.3  project
```

Current代表当前的包版本，Lastest为最新版本，Wanted为在不破坏现有代码情况下，可以更新到的版本号。


npm v5中新增package-lock.json 其目的是确保在所有主机上安装同样的依赖库，无论是在node_modules目录或package.json文件修改依赖树，都会自动记录下来。

更新具体包：
```
npm update unserscore
```

更新所有过期包
```
npm update
```

## 查找包
```
npm search 
```

## 重新安装项目依赖
```
npm install
```

## 管理缓存
npm安装时会保存副本，这样下次再安装时，就不需要联网，存储存储在默认用户目录下的.npm文件夹（windows为npm-cache）

清理缓存
```
npm cache clean
```

## 使用淘宝镜像加速安装速度
具体访问：https://npm.taobao.org/

## 常见问题：

1, 安装时加--verbose可以查看具体信息
2, 如果用root用户或sudo还是提示权限不足：

```
npm config set user 0
npm config set unsafe-perm true
```

