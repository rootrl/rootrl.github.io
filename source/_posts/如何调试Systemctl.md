---
title: 如何调试Systemctl
date: 2018-09-03 02:53:27
tags:
 - linux
 - systemctl
categories:
 - Unix/Linux
---

有时候我们使用systemctl命令，比如systemctl start kube-apiserver时会提示错误：
```bash 
[root@vultr kubenetes]# systemctl start kube-apiserver         
Job for kube-apiserver.service failed because the control process exited with error code. See "systemctl status kube-apiserver.service" and "journalctl -xe" for details.
```

根据提示，再运行systemctl status kube-apiserver.service 会提示类似：

```bash
● kube-apiserver.service - Kubernetes API Service
   Loaded: loaded (/usr/lib/systemd/system/kube-apiserver.service; disabled; vendor preset: disabled)
   Active: failed (Result: start-limit) since Fri 2018-07-20 06:37:05 UTC; 1min 17s ago
     Docs: https://github.com/GoogleCloudPlatform/kubernetes
  Process: 8208 ExecStart=/usr/bin/kube-apiserver $KUBE_LOGTOSTDERR $KUBE_LOG_LEVEL $KUBE_ETCD_SERVERS $KUBE_API_ADDRESS $KUBE_API_PORT $KUBELET_PORT $KUBE_ALLOW_PRIV $KUBE_SERVICE_ADDRESSES $KUBE_ADMISSION_CONTROL $KUBE_API_ARGS (code=exited, status=203/EXEC)

Jul 20 06:37:05 vultr.guest systemd[1]: kube-apiserver.service: main process exited, code=exited, status=203/EXEC
Jul 20 06:37:05 vultr.guest systemd[1]: Failed to start Kubernetes API Service.
Jul 20 06:37:05 vultr.guest systemd[1]: Unit kube-apiserver.service entered failed state.
Jul 20 06:37:05 vultr.guest systemd[1]: kube-apiserver.service failed.
Jul 20 06:37:05 vultr.guest systemd[1]: kube-apiserver.service holdoff time over, scheduling restart.
Jul 20 06:37:05 vultr.guest systemd[1]: start request repeated too quickly for kube-apiserver.service
Jul 20 06:37:05 vultr.guest systemd[1]: Failed to start Kubernetes API Service.
Jul 20 06:37:05 vultr.guest systemd[1]: Unit kube-apiserver.service entered failed state.
Jul 20 06:37:05 vultr.guest systemd[1]: kube-apiserver.service failed.
```

注意看ExecStart

```bash
ExecStart=/usr/bin/kube-apiserver $KUBE_LOGTOSTDERR $KUBE_LOG_LEVEL $KUBE_ETCD_SERVERS $KUBE_API_ADDRESS $KUBE_API_PORT $KUBELET_PORT $KUBE_ALLOW_PRIV $KUBE_SERVICE_ADDRESSES $KUBE_ADMISSION_CONTROL $KUBE_API_ARGS
```

其实我们调试思想是，我们知道是这个kube-apiserver命令加上后续参数执行时出错了，所以只要我们手动运行一下这个命令就知道错在哪了，但是这里环境变量还是类似$KUBE_LOG_LEVEL这种变量，不是编译后的，不好调试运行。

这里有个技巧就是，编辑你system服务的service配置文件，在Service选中添加一项，类似：

```bash
ExecStartPre=/bin/bash -l -c 'echo "/usr/bin/kube-apiserver $YOUR_ARGS">/tmp/systemctl.debug'
```

实际运行时这里$YOUR_ASRGS替换为你自己在systemctl status后看到的参数。

然后systemctl daemon-reload，再start服务后，就可以运行 cat /tmp/systemctl.debug查看具体的运行命令，然后拷贝下来在命令行运行下就可以知道具体的错误了。
