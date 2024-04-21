#!/bin/bash
timestamp=$(date +'%Y-%m-%d %H:%M:%S')

# 记录本次自检日志
log_message(){
    local message="$1"
    echo "$timestamp - $message" | tee -a /var/log/system_check.log
}

log_error(){
    log_message "[ERROR] - $1"
}

log_waring(){
    log_message "[WARNING] - $1"
}


## 1. 基本信息扫描
log_message "******************************* 1. 基本信息扫描 *******************************"
get_hardware_info(){
    log_message "--------------------------- 硬件参数 ------------------------------"
    cpu_model="$(lscpu | grep '^Model name' | awk -F ':' '{print $2}' | xargs)"
    cpus="$(lscpu | grep '^CPU(s):' | awk '{print $2}')"
    cpu_arch="$(lscpu | grep 'Architecture' | awk -F ':' '{print $2}' | xargs)"
    printf "$timestamp - CPU信息 :\n $timestamp -    架构: %-11s  型号:%-45s  核数: %s\n" "$cpu_arch" "$cpu_model" "$cpus"
    log_message "内存大小 :$(free -h | grep Mem | awk '{print $2}')"
    log_message "网卡信息 :"
    interfaces=$(ip link show | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')
    for iface in $interfaces; do
        ip_address=$(ip addr show $iface | awk '$1 == "inet" {print $2}')
        mac_address=$(ip link show $iface | awk '$1 == "link/ether" {print $2}')
        bandwidth=$(ethtool $iface | awk '/Speed/ {print $2}')
        printf "$timestamp -    接口: %-10s   IP 地址: %-18s   MAC 地址: %-18s   带宽: %s\n" "$iface" "$ip_address" "$mac_address" "$bandwidth"
    done
}

get_hardware_info
# 2. 文件

# 3. 用户