---
title: Ansible in action
date: 2018-04-20 20:21:00
tags:
 - ansible
categories: 
 - DevOps
---
### Environment
os: centos7
ansible version: 2.5


### install ansible:
```
sudo yum install ansible
```

### inventory file:
/etc/ansible/hosts
```
[webserver]
192.168.8.215

[dbserver]
192.168.8.214
```

Or whereever your inventory file is and use -i to specific it.

### Set login without password：
```
ssh-copy-id user@your-server-ip
```

Test ping ur host
```
ansible all -m ping
```
set user and root:
```
ansbile all -m ping -u bruce --sudo
```

using shell module:
```
ansible all -m shell -a 'echo $(hostname -i)'
```

### Playbook:

playbook.yml content with:
```
---
- hosts: all
  remote_user: rootrl
  tasks:
   - name: test connection
     ping:
   - name: test a script
     script: ./script.sh

```
script.sh:
```
#!/usr/bin/env bash

cat <<TPL > hay.txt
hello
        this is text
TPL
```
before run:
```
# check syntax
ansible-playbook playbook.yml --syntax-check

# check host list
ansible-playbook playbook.yml --list-hosts
```

run:
```
ansible-playbook playbook.yml
```
run cat to proof stuff be changed:
```
ansible all -m shell -a "cat /home/rootrl/hay.txt"
```

### Demo:

[https://github.com/rootrl/Init-new-instance-with-ansible.git][1]

git clone and run:

```
ansible-playbook -i hosts main.yml
```

### Result:

```
[rootrl@jdu4e00u53f7 Init-new-instance-with-ansible]$ ansible-playbook -i hosts main.yml

PLAY [webserver] *************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************
ok: [45.77.44.159]

TASK [test ping] *************************************************************************************************************************************
ok: [45.77.44.159]

TASK [install docker] ********************************************************************************************************************************

changed: [45.77.44.159]

TASK [test docker] ***********************************************************************************************************************************
changed: [45.77.44.159]

TASK [debug] *****************************************************************************************************************************************
ok: [45.77.44.159] => {
    "msg": [
        "",
        "Hello from Docker!",
        "This message shows that your installation appears to be working correctly.",
        "",
        "To generate this message, Docker took the following steps:",
        " 1. The Docker client contacted the Docker daemon.",
        " 2. The Docker daemon pulled the \"hello-world\" image from the Docker Hub.",
        "    (amd64)",
        " 3. The Docker daemon created a new container from that image which runs the",
        "    executable that produces the output you are currently reading.",
        " 4. The Docker daemon streamed that output to the Docker client, which sent it",
        "    to your terminal.",
        "",
        "To try something more ambitious, you can run an Ubuntu container with:",
        " $ docker run -it ubuntu bash",
        "",
        "Share images, automate workflows, and more with a free Docker ID:",
        " https://hub.docker.com/",
        "",
        "For more examples and ideas, visit:",
        " https://docs.docker.com/engine/userguide/"
    ]
}

TASK [install shadowsock] ****************************************************************************************************************************
changed: [45.77.44.159]

PLAY RECAP *******************************************************************************************************************************************
45.77.44.159               : ok=6    changed=3    unreachable=0    failed=0   
```


  [1]: https://github.com/rootrl/Init-new-instance-with-ansible.git
  
