---
title: PHP OPcodes实战：PHP类名和方法同名引起的问题
date: 2017-09-25 04:28:43
tags:
 - PHP
 - Opcodes
categories:
 - 开发语言
 - PHP
banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/opcode_result.png
---

## 简述
我刚开始是想用Php Opcodes来解决问题的，但是并没有派上用场，不过过程很详细的记录了，当是一个Opcodes使用教程吧。

## 缘起
```
<?php

abstract class Base
{
    abstract public function child();
}

class Child extends Base
{
    public function child()
    {
        echo "child";
    }
}

$class = new Child();                 
```

这里结果直接显示 child（注意是直接打印出"child"字符，我这里并没有调用child这个方法，Why?）

我试着写两个抽象方法：
```
<?php

abstract class Base
{
    abstract public function foo();
    abstract public function bar();
}

class Child extends Base
{
    public function foo()
    {
        echo "\n foo \n";
    }

    public function bar()
    {
        echo "\n bar \n";
    }
}

$class = new Child();
```

结果正常，什么也没显示。那为什么有一个抽象方法的时候会直接显示呢？

考虑到我这里换代码了，于是删除一个方法：
```
<?php

abstract class Base
{
    abstract public function foo();
}

class Child extends Base
{
    public function foo()
    {
        echo "\n foo \n";
    }
}

$class = new Child();                      
```

结果也正常，那再回头看第一个，方法。结构没什么不同，不过方法的名称和类的名称好像同名，但是这个原因吗？

## 深入

于是想到php的Opcode可以查看内部执行情况

具体见鸟哥文章：http://www.laruence.com/2008/06/18/221.html

PHP官方有个叫VLD的扩展可以查看opcode

安装:
```
wget http://pecl.php.net/get/vld-0.14.0.tgz
tar zxvf vld-0.14.0.tgz
cd vld-0.14.0
phpize # 编译php扩展，根据系统信息生成对应的configure文件
./configure -with-php-config=/usr/local/php/bin/php-config --enable-vld # 
```
配置编译vld的php-config路径
```
make && make install
```
在 php.ini 中激活vld
```
extension=vld.so
```

执行php -m | grep 'vld' 看是否安装成功

使用说明：
```
-dvld.active=1; # 使用vld扩展
-dvld.execute=0 # 不执行该文件 默认为1
-dvld.verbosity=3# 显示信息 0-3 个等级 3最高
php -dvld.active=1 -dvld.execute=0 foo.php # 查看 foo.php 的opcode
```

回到问题：
查看之前那个类的opcode

![此处输入图片的描述][1]

读懂cpcode前提
这其中，ASSIGN、ECHO、RETURN 这些 opcode TOKEN具体意义可参考官方文档：http://php.net/manual/en/internals2.opcodes.list.php


VLD说明：
* Branch analysis from position 这条信息多在分析数组时使用。
* Return found 是否返回，这个基本上有都有。
* filename 分析的文件名
* function name 函数名，针对每个函数VLD都会生成一段如上的独立的信息，这里显示当前函数的名称
* number of ops 生成的操作数
* compiled vars 编译期间的变量，这些变量是在PHP5后添加的，它是一个缓存优化。这样的变量在PHP源码中以IS_CV标记。
* op list 生成的中间代码的变量列表


好吧，最后通过opcode没有解决这个这个问题，因为两者的opcode是一样。。

后来弄懂了，这个问题简单讲就是一个兼容问题，在老的php版本中（5以前），如果类的方法和类同名的话，这个方法相当于一个构造函数。

php官方手册中也有写：

![此处输入图片的描述][2]


  [1]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/opcode_result.png
  [2]: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/construct.png
