---
title: 关于JWT(Json Web Token)的思考及使用心得
date: 2018-10-03 22:52:27
tags:
 - jwt
 - 鉴权
categories:
 - 安全
---
## 什么是JWT？

JWT\(Json Web Token\)是一个开放的数据交换验证标准rfc7519 \(https://tools.ietf.org/html/rfc7519\)，一般用来做轻量级的API鉴权。由于许多API接口设计是遵循无状态的(比如Restful)，所以JWT是Cookie Session这一套机制的替代方案。

### 组成
JWT由三部分组成头部(header)、载荷(payload)、签名(signature)。头部定义类型和加密方式；载荷部分放不是很重要的数据；签名使用定义的加密方式加密base64后的header和payload和一段你自己的加密key。最后的token由base64(header).base64(payload).base64(signatrue)组成。

### 使用方式
平时需要鉴权的接口需要传这个token，可以post字段提交，但是一般建议放在header头中 ，因为JWT一般配合https使用，这样就万无一失。

### 为什么安全？
首先token是服务端签发，然后验证时是用同样加密方式把header、payload和key再加密遍 然后看是不是和签名一致 如果不一致就说明token是非法的 这里主要靠的是加密（比如HS256）难以被攻破 至少目前吧 另外不得不说这里的加密对服务器来说是一个开销 这也是JWT的缺点

## 使用
我很早就听说过JWT 但那时候还没用上 感觉近几年前后端分离思想加速了JWT的使用 MVC前置到前端（VUE、REACT）后端只用提供API API强调无状态 自然而然使用了JWT这套方案

之前做小程序时 没有绝对使用JWT这套方案 我把它简化了下

最近开发的一套项目用的是Laravel做后端提供API服务，所以自然而然使用了JWT，使用的扩展是tymon/jwt-auth 关于这套扩展机制的具体使用可以参考这篇文章 写的很不错：https://laravel-china.org/articles/10885/full-use-of-jwt

## 项目使用时的具体细节

### JWT三个时间概念

JWT有三个时间概念： 过期时间 宽限时间 刷新时间

上面那文章说token过了过期时间是不可刷新的，但其实是可以刷新的，我这边使用时可以（开启了黑名单机制和1min宽限时间） 但是过了刷新时间不能刷新这是肯定的

### token刷新

可以借用laravel的中间件实现自动刷新 服务端判断过期了但是在刷新时间内主动刷新一次 并把新的token在Header头中返回给客户端

### 记住我功能

我感觉定义刷新时间（比如一个月） + token自动刷新机制这一套就是记住我功能

### 不能主动销毁Token

默认JWT这套方案好像不可以主动剔除用户的，因为服务端不会存token，只是验证。这和session不一样。 但是我感觉可以借用黑名单机制 来判断 中间件中判断该token在剔除黑名单中就销毁token并返回鉴权失败

### 单点登录

结合缓存比如redis存客户端标识是可以的

### 多套用户权限机制

比如客户端有用户端和商家端两套用户机制（不同表），可以在auth.php定义两个guard 分别指定对应的model Login逻辑单独写 比如auth('userApi') auth('corpApi') 可以拿到不同的guard 刷新中间件是可以共用的 不过router中的middleware方法可以指定具体的middleware

### 为什么不同权限体系的刷新中间件可以公用

感觉是jwt-auth实现了这机制 验证token时会根据sub字段判断 我base64decode两个token的payload后发现sub一个是1 一个是2

如果有问题欢迎指正！
