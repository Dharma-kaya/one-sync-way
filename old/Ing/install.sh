#!/bin/bash
# 作者：Copilot
# QQ：123456789

# 检查是否为 ROOT 用户
CheckRoot() {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: You must be root to run this script. Please use root to install."
        exit 1
    fi
    clear
}

# 安装 Nginx
InstallNginx() {
    echo "Installing Nginx..."
    # 在这里添加 Nginx 的安装步骤
    # ...
    echo "Nginx installed successfully."
}

# 安装 JRE
InstallJRE() {
    echo "Installing JRE..."
    # 在这里添加 JRE 的安装步骤
    # ...
    echo "JRE installed successfully."
}

# 安装 MySQL
InstallMySQL() {
    echo "Installing MySQL..."
    # 在这里添加 MySQL 的安装步骤
    # ...
    echo "MySQL installed successfully."
}

# 主函数
Main() {
    CheckRoot
    if [ $# -eq 0 ]; then
        InstallJRE
        InstallMySQL
        InstallNginx
    else
        for service in "$@"; do
            case "$service" in
                "jre") InstallJRE ;;
                "mysql") InstallMySQL ;;
                "nginx") InstallNginx ;;
                *) echo "Unknown service: $service" ;;
            esac
        done
    fi
}

# 调用主函数
Main "$@"
