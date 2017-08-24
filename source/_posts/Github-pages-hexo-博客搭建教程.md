---
title: Github pages + hexo 博客搭建教程
date: 2017-08-24 07:33:12
tags:
 - 杂类
categories:
 - 杂类
---

![](http://ov4crdzpr.bkt.clouddn.com/17-8-24/87900151.jpg)

这里我将分享下本Blog的搭建方法。

### Github pages的规则 ###
首先得知道Github pages的规则：每个Github账号（比如Username）下面只能建立一个Pages，且命名必须符合这样的规则："username/username.github.io"

创建成功后，username.github.io就是你的域名（当然你可以通过别名解析绑定自己的域名）

实战：

1， 在Github建立一个新的Repository：命名为：username.github.io

2， 本地git clone https://github.com/username/username.github.io

3， cd username.github.io 然后 echo "Hello World" > index.html

4， 执行命令：

    git add .
    git commit -m "Initial commit"
    git push -u origin master

然后访问username.github.io，大功告成！

### 使用Hexo管理你的博客 ###

平时可以这样发布自己的博客，但是比较麻烦，我们可以通过相应的工具来管理Pages。比如Jekyll、Hexo等，这些工具原理就是把Markdown自动转化为Html便于我们书写博客，接下来详细介绍从零开始用Hexo+Github Pages搭建博客。

1， 创建repository(如果做了上述实践部分就先删除此repository，从头来)
在github建立一个新的repository：命名为：username.github.io, 并且勾选创建readme.md已初始化仓库这项。
**注: 替换username为你的账号名**

2，在本地git clone 你的博客项目地址

3，进入clone的项目目录，注意此时是在master分支，而master分支平常放生成的博客页面，所以我们现在创建一个hexo分支，用来管理hexo相关文件。

    git checkout -b hexo

4， 安装hexo，以及相关扩展依赖（建议把npm安装源改为国内的，淘宝就有提供，这样能提高安装速度）

    npm  install -g hexo

    hexo init    // 初始化

注意：hexo init要求当前目录是一个空目录，我这里解决办法是在执行hexo init 前把当前文件夹的文件都移到外面去（包括.git仓库目录），初始化完成后马上把文件移回来（一般只会有README.MD文件和.git目录）


    npm install    // 安装依赖

（此阶段若遇到 symlink error问题，则加参数：-no-bin-links）

    npm install hexo-deployer-git --save    // 安装deployer扩展

5，  修改_config.yml文件的deploy选项(如果你准备装第6步的博客主题，则可以放到第6步一起操作)：

    deploy:
    type: git
    repo: (对应你博客仓库的SSH地址)
    branch: master`

此外其他相关配置信息都改成你自己的，比如author这些

6， 选一个博客主题，我这里用的：icarus

    git clone https://github.com/ppoffice/hexo-theme-icarus.git themes/icarus

进入 themes/icarus 目录，把该主题提供的实例的配置文件 编辑下然后作为自己的配置文件

    cp _config.yml.example _config.yml

然后回到项目根目录，编辑主配置_config.yml 添加theme配置

    theme: icarus

**注：第5步如果没操作，则在这里一起操作**

7， 提交到仓库

    git add .
    git commit -m 'hexo init'
    git push -u origin hexo


8，发布一篇博文

    hexo new "your blog title"

（此步若遇到local hexo not found：rm -rf node_modules/ && npm install解决）
然后会在source/_posts下建立一个your-blog-title.md的文件，
你可以编辑此文件书写你想写的博客内容（Markdown格式）
写好后执行一次commit
然后执行生成博客Html文件和发布命令

    hexo generate -d

如果顺利的话，博客内容会发布到master分支

9， 此时可以输入username.github.io来访问你的博客

至此你的博客已经成功搭建！

###平常博客写作和管理流程###

1， 都在hexo分支上工作，用hexo new title建立新的md文件，然后书写，然后"git add . "，"git commit -m '' " ，"git push"提交。好了之后执行hexo generate -d 发布博客

2， 假如换了电脑后，先clone下你github上的博客仓库，然后 npm install -g hexo，npm install 和npm install hexo-deployer-git --save(和安装命令差不多，但是不要使用hexo init命令，因为仓库中已存在)，然后走正常博客书写发布流程即可。

^_^完结


