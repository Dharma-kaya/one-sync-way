#!/bin/bash
# Filename    :  sys_check.sh
# Date        :  2024/04/21
# Author      :  TangMin
# Email       :  min_tang@outlook.com
# Notes       :  系统自检脚本

set -e
exec &> >(tee -a "sys_check.log")
timestamp=$(date +'%Y-%m-%d %H:%M:%S')
log_mesg(){ local mesg="$1"; echo "$timestamp - $mesg"; }
log_error(){ log_mesg "[ERROR] - $1"; }
log_waring(){ log_mesg "[WARNING] - $1"; }

print_sepa(){
    local sepa_char="$1"
    local sepa_length="$2"
    printf "%-${sepa_length}s" | tr ' ' "$sepa_char"
}
_15=$(print_sepa "*" 15)
_30=$(print_sepa "*" 30)


## 1. 基本信息扫描
printf "$_30 1. 基本信息扫描 $_30\n"
get_hardware_info(){
    printf "$_15\n"
    printf "$_15 a. 硬件信息\n"
    printf "$_15\n"
    # cpu
    cpu_model="$(lscpu | grep '^Model name' | awk -F ':' '{print $2}' | xargs)"
    cpus="$(lscpu | grep '^CPU(s):' | awk '{print $2}')"
    cpu_arch="$(lscpu | grep 'Architecture' | awk -F ':' '{print $2}' | xargs)"
    printf "CPU 信息:\n"
    printf "         架构: %-10s  型号: %-45s  核数: %s\n" "$cpu_arch" "$cpu_model" "$cpus"
    # mem
    printf "内存信息:\n"
    mem_slots="$(dmidecode -t memory | grep "Memory Device" | wc -l)"
    mem_effective_slots=0
    mem_total_sizes=0
    for ((i=1; i<=$mem_slots; i++))
    do
        mem_manuf=$(dmidecode -t memory | grep 'Manufacturer' | awk -F ': ' '{print $2}' | sed -n "${i}p")
        mem_type=$(dmidecode -t memory | grep 'Type:' | awk -F ': ' '{print $2}' | sed -n "${i}p")
        mem_freq=$(dmidecode -t memory | grep 'Speed' | awk -F ': ' '{print $2}' | sed -n "${i}p")
        mem_capa=$(dmidecode -t memory | grep 'Installed Size' | awk -F ': ' '{print $2}' | sed -n "${i}p")
        if [[ -z "$mem_manuf" ]] || [[ "$mem_manuf" =~ "No|Unknown|Not Installed" ]] || [[ -z "$mem_capa" ]] || [[ "$mem_capa" =~ "No|Unknown|Not Installed" ]]; then
            continue
        fi
        mem_effective_slots=$((mem_effective_slots + 1))
        mem_size=$(echo "$mem_capa" | grep -oE '[0-9]+')
        mem_total_sizes=$((mem_total_sizes + mem_size))
        printf "         厂商: %-12s  类型: %-12s  频率: %-12s  容量: %s\n" "$mem_manuf" "$mem_type" "$mem_freq" "$mem_capa"
    done
    printf "         当前内存插槽有效使用率 $mem_effective_slots/$mem_slots, 总容量 $((mem_total_sizes / 1024))GB\n"
    # disk
    printf "磁盘信息:\n"
    part=$(lsblk -o NAME,TYPE,FSTYPE,SIZE,MOUNTPOINT)
    printf "%s\n" "$part" | awk '{printf "         %-12s %-8s %-12s %s\n", $1,$2,$3,$4}'
    # nic
    printf "网卡信息:\n"
    interfaces=$(ip link show | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')
    for iface in $interfaces; do
        ip_address=$(ip addr show $iface | awk '$1 == "inet" {print $2}')
        mac_address=$(ip link show $iface | awk '$1 == "link/ether" {print $2}')
        bandwidth=$(ethtool $iface | awk '/Speed/ {print $2}')
        net_mode=$(ethtool $iface | awk '/Duplex/ {print $2}')
        printf "         接口: %-9s   IP : %-18s   MAC : %-18s   带宽: %-9s  双工模式: %s\n" "$iface" "$ip_address" "$mac_address" "$bandwidth" "$net_mode"
    done
}
get_hardware_info

get_sys_status(){
    printf "$_15\n"
    printf "$_15 b. 系统状态\n"
    printf "$_15\n"
    hostname=$(hostname)
    os=$(cat /etc/system-release)
    kernel_version=$(uname -r)
    uptime=$(uptime -p | sed 's/up //; s/,//')
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    mem_usage=$(free -m | awk '/Mem/ {print $3/$2 * 100}')
    # disk_usage=$(df -h / | awk '/\// {print $5}' | sed 's/%//')
    disk_usage=$(df -h)
    logged_users=$(who | wc -l)
    printf "主机名  : %s\n" "$hostname"
    printf "操作系统: %s\n" "$os"  
    printf "内核版本: %s\n" "$kernel_version"
    printf "系统从 $(uptime -s) 起, 已经运行了 $uptime\n"
    printf "资源耗用:\n"
    printf "         cpu使用率: %.2f%%, 内存使用率: %.2f%%\n" "$cpu_usage" "$mem_usage"
    printf "         磁盘使用率:\n"
    printf "%s\n" "$disk_usage" | awk '{printf "           %-24s %-8s %-8s %-8s %-6s %s\n", $1,$2,$3,$4,$5,$6}'
    printf "当前登录用户数: %d\n" "$logged_users"
}
get_sys_status