#!/bin/bash
# 作者：Copilot
# QQ：123456789

# 指定 MySQL 安装包的下载链接
mysql_download_url="https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz"

# 指定 MySQL 安装路径（可自定义）
install_path="/opt/mysql"

# 检查是否为 ROOT 用户
CheckRoot() {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: You must be root to run this script. Please use root to install."
        exit 1
    fi
    clear
}

# 下载并解压 MySQL 安装包
InstallMySQL() {
    mkdir -p "$install_path"
    cd "$install_path" || exit
    wget "$mysql_download_url"
    tar -zxvf "$(basename "$mysql_download_url")"
    mv "$(basename "$mysql_download_url" .tar.gz)" mysql
}

# 配置 MySQL
ConfigureMySQL() {
    # 添加 MySQL 环境变量
    echo "export PATH=\$PATH:$install_path/mysql/bin" >> /etc/profile
    source /etc/profile

    # 初始化 MySQL 数据目录
    mkdir -p "$install_path/data"
    "$install_path/mysql/bin/mysqld" --initialize-insecure --user=mysql --datadir="$install_path/data"

    # 创建 my.cnf 配置文件
    echo "[mysqld]" > "$install_path/my.cnf"
    echo "datadir=$install_path/data" >> "$install_path/my.cnf"
    echo "socket=$install_path/mysql.sock" >> "$install_path/my.cnf"
    echo "port=3306" >> "$install_path/my.cnf"

    # 启动 MySQL
    "$install_path/mysql/bin/mysqld_safe" --defaults-file="$install_path/my.cnf" &
}

# 主函数
Main() {
    CheckRoot
    InstallMySQL
    ConfigureMySQL
    echo "MySQL 安装完成。"
}

Main
