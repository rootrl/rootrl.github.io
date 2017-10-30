---
title: 搭建Ngrok内网穿透服务器
date: 2017-10-30 08:50:52
tags:
 - ngrok
 - 内网穿透

categories:
 - 其他

banner: https://raw.githubusercontent.com/rootrl/rootrl.github.io/master/images/ngrok.png
---

## 简介
Ngrok是实现内网穿透的，简单讲就是可以在外网访问你的Localhost环境。

## 安装
Ngrok需要Go环境支持，请确保安装了Go环境。

### 安装Go
```
# 下载包：
wget https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz
# 解压到/usr/local/go
sduo tar -C /usr/local -xzf go1.9.1.linux-amd64.tar.gz

# 配置环境变量 /etc/profile所有用户生效 $HOME/.profile当前用户
vim /etc/profile

# 末尾加上以下内容
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin

# 针对所有用户的需要重启电脑才可以生效；针对当前用户使用source命令
source ~/.profile

# 检测 
go version
```

###安装Ngrok
```
cd /usr/local/src
git clone https://github.com/inconshreveable/ngrok.git
export GOPATH=/usr/local/src/ngrok/
export NGROK_DOMAIN="youdomain.cn"
cd ngrok
```

生成证书 （必须）
```
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
openssl genrsa -out server.key 2048
openssl req -new -key server.key -subj "/CN=$NGROK_DOMAIN" -out server.csr
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 5000
```

复制证书到指定位置
```
cp rootCA.pem assets/client/tls/ngrokroot.crt
cp server.crt assets/server/tls/snakeoil.crt
cp server.key assets/server/tls/snakeoil.key
```

如果是国内服务器修改以下配置
```
vim /usr/local/ngrok/src/ngrok/log/logger.go
log "github.com/keepeye/log4go"
```

编译服务器，这里也同时编译了一个 linux 下的客户端。64位系统使用 amd64，如果是32位，需要修改成 amd386。
```
# 如果有权限错误看提示修改权限
cd /usr/local/go/src
GOOS=linux GOARCH=amd64 ./make.bash
cd /usr/local/src/ngrok/
GOOS=linux GOARCH=amd64 make release-server release-client

```

以上如果有$GOROOT_BOOTSTRAP错误
Copy一份源码

```
sudo cp -r /usr/local/go /usr/local/go-copy
export GOROOT_BOOTSTRAP=/usr/local/go-copy
```

## 服务器端使用
进入服务端目录，服务端程序文件名为 ngrokd，并执行相应命令
```
# 端口随你自己定义
cd /usr/local/src/ngrok/bin
./ngrokd -domain="$NGROK_DOMAIN" -httpAddr=":8085"

```

返回一下结果，说明成功：
```
[08:09:41 UTC 2016/12/19] [INFO] (ngrok/log.(*PrefixLogger).Info:83) [registry] [tun] No affinity cache specified
[08:09:41 UTC 2016/12/19] [INFO] (ngrok/log.Info:112) Listening for public http connections on [::]:80
[08:09:41 UTC 2016/12/19] [INFO] (ngrok/log.Info:112) Listening for public https connections on [::]:443
[08:09:41 UTC 2016/12/19] [INFO] (ngrok/log.Info:112) Listening for control and proxy connections on [::]:4443
[08:09:41 UTC 2016/12/19] [INFO] (ngrok/log.(*PrefixLogger).Info:83) [metrics] Reporting every 30 seconds
```

## 客户端使用
把刚刚从 VPS 服务器上生成的客户端服务器下载到本机，可以通过 scp 命令
```
mkdir -p /usr/local/ngrok/bin

sudo scp username@servername:/usr/local/src/ngrok/bin/ngrok /usr/local/ngrok/bin/ngrok（本地目录）
```

在/usr/local/ngirok/bin下新建ngrok.cfg文件
```
server_addr: "yourdomain.cn:4443"
trust_host_root_certs: false
```

运行客户端
```
./ngrok -config=./ngrok.cfg -subdomain=test 8080
# -subdomain参数指的是域名，例如这里是test.ngrok.uprogrammer.cn
# 后面的80是指本机端口，这里是指把本机的8080端口开放穿透
```

返回以下结果说明成功：
```
unnel Status                 online                                                                                                        
Version                       1.7/1.7                                                                                                       
Forwarding                    http://test.ngrok.uprogrammer.cn -> 127.0.0.1:8080                                                            
Forwarding                    https://test.ngrok.uprogrammer.cn -> 127.0.0.1:8080                                                           
Web Interface                 127.0.0.1:4040                                                                                                
# Conn                        0                                                                                                             
Avg Conn Time                 0.00ms
```

接下来通过test.yourdomain.cn就可以访问你本地8080端口的服务了。

## 可能问题
1，注意检查相应服务器端口是否经过防火墙允许转发了
2，我这边ngrok是装在我vagrant虚拟机里面，然后我们开发环境是内网另一台服务器上，所以我这边要用到一层反向代理。

## 总结
这篇文章基本参考的：`[http://linfuyan.com/ubuntu-ngrok][1]`
已通过实践验证，证明是可行的。


  [1]: http://linfuyan.com/ubuntu-ngrok
