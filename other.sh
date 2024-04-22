#!/bin/bash
############################################################## 安全加固
# 函数：记录日志信息
log_message() {
    local message="$1"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $message" | tee -a /var/log/system_init.log
}

# 函数：记录错误信息
log_error() {
    local error_message="$1"
    log_message "[ERROR] - $error_message"
}

# 函数：禁用不必要的服务
disable_unnecessary_services() {
    local services=("telnet" "ftp" "rsh" "rlogin" "talk" "finger" "rpcbind" "ypserv" "tftp")
    for service in "${services[@]}"; do
        systemctl disable "$service" &> /dev/null
        if [ $? -eq 0 ]; then
            log_message "已禁用不必要的服务: $service"
        else
            log_error "无法禁用服务: $service"
        fi
    done
}

# 函数：设置文件权限
set_file_permissions() {
    # 设置敏感文件权限
    chmod 600 /etc/passwd
    chmod 600 /etc/shadow
    chmod 600 /etc/group
    chmod 644 /etc/hosts.allow
    chmod 644 /etc/hosts.deny
    chmod 600 /etc/ssh/sshd_config

    # 设置系统日志文件权限
    chmod 640 /var/log/messages
    chmod 640 /var/log/secure
    chmod 640 /var/log/maillog

    log_message "已设置文件权限"
}

# 函数：配置SSH安全
configure_ssh_security() {
    # 禁用root远程登录
    sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

    # 禁用密码登录，只允许使用密钥登录
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

    # 禁用SSH协议版本1
    sed -i 's/^#Protocol 2/Protocol 2/' /etc/ssh/sshd_config

    # 禁用SSH空密码登录
    sed -i 's/^#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config

    # 设置SSH登录超时时间为5分钟
    echo "LoginGraceTime 300" >> /etc/ssh/sshd_config

    # 重新加载SSH配置
    systemctl reload sshd &> /dev/null

    log_message "已配置SSH安全"
}

# 函数：更新系统和安装安全补丁
update_system() {
    yum update -y &> /dev/null
    if [ $? -eq 0 ]; then
        log_message "已更新系统"
    else
        log_error "更新系统时发生错误"
    fi
}

# 函数：配置防火墙
configure_firewall() {
    # 启用防火墙
    systemctl start firewalld
    firewall_status=$(systemctl is-active firewalld)

    # 检查防火墙是否成功启用
    if [ "$firewall_status" != "active" ]; then
        log_error "无法启用防火墙"
        exit 1
    fi

    # 允许SSH服务通过防火墙
    firewall-cmd --permanent --add-service=ssh &> /dev/null

    # 重新加载防火墙规则
    firewall-cmd --reload &> /dev/null

    log_message "已配置防火墙"
}

# 函数：禁用USB存储设备
disable_usb_storage() {
    echo "install usb-storage /bin/true" > /etc/modprobe.d/usb-storage.conf
    log_message "已禁用USB存储设备"
}

# 函数：禁用IP转发
disable_ip_forwarding() {
    echo 0 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
    sysctl -p &> /dev/null
    log_message "已禁用IP转发"
}

# 函数：检查并修复用户权限
check_and_fix_user_permissions() {
    # 检查特权用户
    privileged_users=("root" "admin")
    for user in "${privileged_users[@]}"; do
        if ! id "$user" &> /dev/null; then
            useradd -m "$user"
            log_message "已创建特权用户: $user"
        fi
    done

    # 检查并修复其他用户
    while IFS=: read -r username _ _ _ _ home_directory _; do
        if [ ! -d "$home_directory" ]; then
            log_error "用户 $username 的家目录不存在: $home_directory"
        fi
        if [ ! -r "$home_directory" ]; then
            chmod 755 "$home_directory"
            log_message "已修复用户 $username 的家目录权限"
        fi
        if [ ! -x "$home_directory" ]; then
            chmod 755 "$home_directory"
            log_message "已修复用户 $username 的家目录权限"
        fi
    done < /etc/passwd

    log_message "已检查并修复用户权限"
}

# 函数：主要的安全加固函数
secure_system() {
    log_message "开始安全加固..."

    # 禁用不必要的服务
    disable_unnecessary_services

    # 设置文件权限
    set_file_permissions

    # 配置SSH安全
    configure_ssh_security

    # 更新系统和安装安全补丁
    update_system

    # 配置防火墙
    configure_firewall

    # 禁用USB存储设备
    disable_usb_storage

    # 禁用IP转发
    disable_ip_forwarding

    # 检查并修复用户权限
    check_and_fix_user_permissions

    log_message "安全加固完成"
}

# 执行主要的安全加固函数
secure_system




############################################################## 文件权限检查
# 函数：检查和加固文件权限
check_and_harden_file_permissions() {
    log_message "开始检查和加固文件权限..."

    # 检查关键系统文件权限并设置为600
    critical_files=(
        "/etc/passwd"
        "/etc/shadow"
        "/etc/sudoers"
        "/etc/group"
    )
    for file in "${critical_files[@]}"; do
        if [ -e "$file" ]; then
            chmod 600 "$file"
            log_message "已加固文件权限: $file"
        else
            log_error "文件 $file 不存在."
        fi
    done

    # 检查和加固文件系统属性
    mount_output=$(mount)
    if ! echo "$mount_output" | grep -qE '\snoexec\s|\snosuid\s|\snodev\s'; then
        log_message "设置文件系统属性..."
        mount -o remount,noexec,nosuid,nodev /
        echo "noexec,nosuid,nodev added to /etc/fstab" >> "$LOG_FILE"
        log_message "已加固文件系统属性."
    fi

    log_message "文件权限检查和加固完毕."
}




############################################################## 内核优化
# 函数：内核优化
optimize_kernel() {
    log_message "开始内核优化..."

    # 设置sysctl参数
    sysctl_settings=(
        "fs.file-max=65535"                            # 文件描述符限制
        "fs.nr_open=65535"                              # 系统最大文件数
        "net.ipv4.tcp_syncookies=1"                    # 启用 SYN Cookie 防护
        "net.ipv4.conf.all.log_martians=1"             # 记录错误的地址信息
        "net.ipv4.conf.default.log_martians=1"         # 记录错误的地址信息
        "net.ipv4.icmp_echo_ignore_broadcasts=1"       # 忽略对广播地址的 ICMP 回应
        "net.ipv4.icmp_ignore_bogus_error_responses=1" # 忽略虚假的 ICMP 错误信息
        "net.ipv4.conf.all.accept_source_route=0"      # 禁用源路由
        "net.ipv4.conf.default.accept_source_route=0"  # 禁用源路由
        "net.ipv4.conf.all.accept_redirects=0"         # 禁用重定向
        "net.ipv4.conf.default.accept_redirects=0"     # 禁用重定向
        "net.ipv4.conf.all.secure_redirects=1"         # 仅接受来自正确网关的重定向
        "net.ipv4.conf.default.secure_redirects=1"     # 仅接受来自正确网关的重定向
        "net.ipv4.conf.all.send_redirects=0"           # 禁用发送重定向
        "net.ipv4.conf.default.send_redirects=0"       # 禁用发送重定向
        "net.ipv4.conf.all.rp_filter=1"                # 启用反向路径过滤
        "net.ipv4.conf.default.rp_filter=1"            # 启用反向路径过滤
        "net.ipv4.tcp_max_syn_backlog=2048"           # 最大 SYN 队列长度
        "net.ipv4.tcp_synack_retries=2"               # SYN+ACK 的重试次数
        "net.ipv4.tcp_syn_retries=5"                  # SYN 的重试次数
        "net.ipv4.tcp_fin_timeout=30"                 # FIN 超时时间
        "net.ipv4.tcp_keepalive_time=1200"            # Keepalive 超时时间
        "net.ipv4.tcp_window_scaling=1"               # 启用 TCP 窗口缩放
        "net.ipv4.tcp_sack=1"                         # 启用 TCP SACK
        "net.ipv4.tcp_timestamps=1"                   # 启用 TCP 时间戳
        "net.ipv4.tcp_rfc1337=1"                      # 启用 RFC 1337 保护
        "net.ipv4.tcp_slow_start_after_idle=0"        # 禁用空闲时的 TCP 慢启动
        "net.ipv4.tcp_max_tw_buckets=1440000"         # 最大 TIME-WAIT 超时连接数
        "net.ipv4.tcp_tw_reuse=1"                     # 允许 TIME-WAIT 状态的连接复用
        "net.ipv4.tcp_tw_recycle=1"                   # 开启 TIME-WAIT 快速回收
        "net.ipv4.tcp_max_orphans=3276800"            # 最大孤立连接数
        "net.ipv4.tcp_mem=65536 131072 262144"        # TCP 内存限制
        "net.ipv4.tcp_wmem=8192 16384 32768"          # TCP 发送缓冲区大小
        "net.ipv4.tcp_rmem=32768 65536 131072"        # TCP 接收缓冲区大小
        "net.ipv4.tcp_max_syn_backlog=8192"           # 最大 SYN 队列长度
        "net.ipv4.ip_local_port_range=1024 65535"     # 本地端口范围
        "net.ipv6.conf.all.disable_ipv6=1"           # 禁用IPv6
    )

    # 设置文件描述符软限制
    ulimit -n 65535

    # 设置文件描述符硬限制
    ulimit -Hn 65535

    # 应用sysctl参数
    for setting in "${sysctl_settings[@]}"; do
        sysctl -w "$setting"
    done

    log_message "内核优化完毕."
}





############################################################## 安全审计
# 函数：安全审计
security_audit() {
    log_message "开始安全审计..."

    # 检查密码策略
    if ! grep -q "pam_pwquality.so" /etc/pam.d/common-password; then
        sed -i '/^password.*pam_unix.so/s/$/ remember=5 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 reject_username/' /etc/pam.d/common-password
        log_message "已添加密码策略."
    fi

    # 检查SSH配置
    if ! grep -qE "^Protocol\s+2" /etc/ssh/sshd_config; then
        sed -i 's/^#Protocol\s*\(.*\)/Protocol 2/' /etc/ssh/sshd_config
        log_message "已设置SSH配置为协议版本2."
    fi
    if ! grep -qE "^PermitRootLogin\s+no" /etc/ssh/sshd_config; then
        sed -i 's/^#PermitRootLogin\s*\(.*\)/PermitRootLogin no/' /etc/ssh/sshd_config
        log_message "已禁用root登录."
    fi
    if ! grep -qE "^PermitEmptyPasswords\s+no" /etc/ssh/sshd_config; then
        sed -i 's/^#PermitEmptyPasswords\s*\(.*\)/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        log_message "已禁用空密码登录."
    fi

    # 检查防火墙设置
    if ! iptables -L | grep -qE "(DROP|REJECT)"; then
        iptables -A INPUT -p tcp --dport 22 -j REJECT
        log_message "已添加防火墙规则，禁止SSH访问."
    fi

    # 检查是否存在未授权的用户账户
    if [ $(awk -F: '($3 >= 1000 && $1 != "nobody") {print}' /etc/passwd | wc -l) -ne 0 ]; then
        log_error "存在未授权的用户账户."
    fi

    # 检查文件系统完整性
    if ! rpm -q --verify shadow-utils; then
        log_error "文件系统存在异常."
    fi

    log_message "安全审计完毕."
}

# 执行安全审计函数
security_audit





############################################################## 日志轮转
# 函数：日志轮转
log_rotation() {
    log_message "开始日志轮转..."

    # 设置日志轮转规则
    if [ -f /etc/logrotate.conf ]; then
        if ! grep -q "/var/log/system_init.log" /etc/logrotate.conf; then
            echo "/var/log/system_init.log {
                rotate 7
                weekly
                missingok
                notifempty
                compress
                delaycompress
                sharedscripts
                postrotate
                    /usr/bin/find /var/log/ -name 'system_init.log-*' -type f -mtime +7 -exec gzip {} \;
                endscript
            }" >> /etc/logrotate.conf
            log_message "已设置系统初始化日志轮转规则."
        fi
    else
        log_error "未找到日志轮转配置文件."
    fi

    log_message "日志轮转完成."
}

# 执行日志轮转函数
log_rotation






############################################################## 错误检查
# 错误检查函数
check_errors() {
    # 检查系统日志中是否存在告警性质的记录
    if journalctl -p 3 -q | grep -q "error\|fail\|warning"; then
        log_error "系统日志中存在错误、失败或警告信息"
        exit 1
    fi

    # 检查系统是否存在崩溃记录
    if journalctl -q | grep -q "kernel panic\|systemd-coredump"; then
        log_error "系统存在崩溃记录"
        exit 1
    fi

    # 检查系统磁盘阵列是否丢失
    if journalctl -q | grep -q "mdadm\|RAID"; then
        log_error "系统磁盘阵列丢失"
        exit 1
    fi

    # 从系统日志中查找高负载记录
    if journalctl -q | grep -q "load average"; then
        log_error "系统存在高负载"
        exit 1
    fi
}

# 执行错误检查函数
check_errors






############################################################## 阻止攻击
# 函数：记录日志信息
log_message() {
    local message="$1"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $message" | tee -a /var/log/system_init.log
}

# 函数：阻止攻击
block_attack() {
    # 从系统日志中查找可疑攻击IP
    suspicious_ips=$(journalctl -q | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort | uniq -c | sort -nr | awk '$1 >= 10 {print $2}')

    # 如果存在可疑攻击IP，根据防火墙类型将其加入黑名单
    if [ -n "$suspicious_ips" ]; then
        # 检查防火墙类型
        if command -v firewall-cmd &> /dev/null; then
            # 使用 firewalld 规则
            for ip in $suspicious_ips; do
                firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='$ip' drop"
                log_message "已将可疑攻击IP $ip 加入 firewalld 黑名单"
            done

            # 重新加载 firewalld 规则
            firewall-cmd --reload
        elif command -v iptables &> /dev/null; then
            # 使用 iptables 规则
            for ip in $suspicious_ips; do
                iptables -A INPUT -s "$ip" -j DROP
                log_message "已将可疑攻击IP $ip 加入 iptables 黑名单"
            done

            # 保存 iptables 规则
            iptables-save > /etc/sysconfig/iptables
        else
            log_error "无法确定防火墙类型"
        fi

        # 发送告警通知
        echo "Subject: 可疑攻击警告" | sendmail -v admin@example.com
        log_message "已发送告警通知至 admin@example.com"
    else
        log_message "未发现可疑攻击IP"
    fi
}

# 执行阻止攻击函数
block_attack