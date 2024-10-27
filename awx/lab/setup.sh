#!/bin/bash

# 更新软件源为国内镜像
sudo sed -i 's/http:\/\/us.archive.ubuntu.com\/ubuntu\//https:\/\/mirrors.aliyun.com\/ubuntu\//g' /etc/apt/sources.list
sudo sed -i 's/http:\/\/security.ubuntu.com\/ubuntu\//https:\/\/mirrors.aliyun.com\/ubuntu\//g' /etc/apt/sources.list

# 更新软件包列表
sudo apt-get update

if [ "$HOSTNAME" = "awx" ]; then
    # 安装必要的软件包
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # 添加 Docker 的 GPG 密钥
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # 添加 Docker 仓库
    sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

    # 再次更新软件包列表
    sudo apt-get update

    # 安装 Docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # 将当前用户添加到 docker 组
    sudo usermod -aG docker $USER

    # 启动 Docker 服务
    sudo systemctl enable docker
    sudo systemctl start docker

    # 安装 Python 相关包
    sudo apt-get install -y python3-venv python3-pip
    
    # 安装 docker-compose
    sudo pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple docker-compose
    
    # 安装指定版本的 Ansible
    sudo pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple ansible==2.9.*
    
    # 安装 Docker Python 库
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple docker

    # 安装 AWX 17.1.0
    cd /tmp
    wget https://github.com/ansible/awx/archive/refs/tags/17.1.0.tar.gz
    tar xvzf 17.1.0.tar.gz
    cd awx-17.1.0/installer

    # 修改 inventory 文件（如果需要）
    # sed -i 's/localhost/awx/g' inventory

    ansible-playbook -i inventory install.yml

    # 清理下载的文件
    cd /tmp
    rm -rf awx-17.1.0 17.1.0.tar.gz

    echo "AWX 17.1.0 installation completed."
fi

# 配置 SSH 密码认证
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
