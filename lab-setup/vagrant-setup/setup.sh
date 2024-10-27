#!/bin/bash

# 备份原始的仓库
cp -r /etc/yum.repos.d /etc/yum.repos.d.backup

# 删除所有现有的仓库文件
rm -f /etc/yum.repos.d/*.repo

# 创建新的 CentOS-Base.repo 文件使用阿里云镜像
cat > /etc/yum.repos.d/CentOS-Base.repo <<EOL
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-\$releasever - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-\$releasever - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-\$releasever - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
baseurl=https://mirrors.aliyun.com/epel/7/\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-7
EOL

# 清理和更新 Yum 缓存
yum clean all
yum makecache

# 更新系统
yum update -y

# 安装必要的软件包
yum install -y epel-release
yum install -y vim git wget curl

# 设置主机文件
echo "192.168.200.10 ansible-controller" >> /etc/hosts
echo "192.168.200.11 ansible-node1" >> /etc/hosts
echo "192.168.200.12 ansible-node2" >> /etc/hosts

# 禁用 SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# 配置 SSH 以进行密码认证（用于 Ansible）
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# 设置 Ansible（仅在控制器上）
if [ "$(hostname)" == "ansible-controller" ]; then
    yum install -y ansible
    mkdir -p /etc/ansible
    echo "[all]" > /etc/ansible/hosts
    echo "ansible-controller" >> /etc/ansible/hosts
    echo "ansible-node1" >> /etc/ansible/hosts
    echo "ansible-node2" >> /etc/ansible/hosts
fi
