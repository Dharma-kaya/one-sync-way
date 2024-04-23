#!/bin/bash
# Filename    :  common.sh
# Date        :  2024/04/21
# Author      :  TangMin
# Email       :  min_tang@outlook.com
# Notes       :  脚本公共部分

set -e

timestamp=$(date +'%Y-%m-%d %H:%M:%S')

# 日志打印函数: 消息内容
log_mesg(){ local mesg="$1"; echo "$timestamp - $mesg"; }
log_error(){ log_mesg "[ERROR] - $1"; }
log_waring(){ log_mesg "[WARNING] - $1"; }

# 注释条打印函数: 字符 个数
print_sepa(){
    local sepa_char="$1"
    local sepa_length="$2"
    printf "%-${sepa_length}s" | tr ' ' "$sepa_char"
}

# 时长计算函数: 开始时间 结束时间
calc_dura(){
    local dura=$(($2 - $1))
    if ((dura) < 60); then
        echo "${dura}s"
    elif ((dura < 3600)); then
        echo "$((dura / 60))min $((dura % 60))s"
    else
        echo "$((dura/ 3600))h $(((dura % 3600) / 60))min"
    fi
}

# ini配置解析与变量导入函数: ini配置文件路径 section key
export_env(){
    local ini_path="$1"
    local section="$2"
    local key="$3"
    
    local value=$(awk -F '=' '/\['"$section"'\]/{a=1}a==1 && $1~/' "$key" '/{print $2;exit}' "$ini_path")
    export "$key"="$value"
    echo "已将 $key='$value' 导入环境变量."
}


# 解析INI配置文件并存储到关联数组
parse_ini_file() {
    local ini_file="$1"
    declare -A config

    while IFS='=' read -r key value; do
        config["$key"]="$value"
    done < <(awk -F '=' '/^[^#]/ {print $1, $2}' "$ini_file")

    # 返回关联数组
    echo "${config[@]}"
}

# 权限及安全检查函数
check_sec(){
    # 检查权限、脚本运行前的安全等...
    # 检查用户是否为root
    if [[ $EUID -ne 0 ]]; then
        echo "请使用root权限运行此脚本。"
        exit 1
    fi

    # 检查环境变量是否已设置
    if [[ -z "$MY_ENV_VAR" ]]; then
        echo "请设置MY_ENV_VAR环境变量。"
        exit 1
    fi
}

# 备份创建函数
ceate_backup(){
    local backup_dir="/var/backups"
    local timestamp=$(date +'%Y%m%d%H%M%S')
    local backup_file="$backup_dir/myapp_backup_$timestamp.tar.gz"
    tar czf "$backup_file" /path/to/data
    echo "已创建备份文件：$backup_file"
}


# 通用错误处理函数
handle_error() {
    local exit_code="$1"
    local message="$2"
    echo "Error: $message"
    exit "$exit_code"
}
# 示例：模拟一个错误
simulate_error() {
    local random_number=$((RANDOM % 2))
    if [ "$random_number" -eq 0 ]; then
        handle_error 1 "Something went wrong!"
    else
        echo "No error this time."
    fi
}
# 主函数
main() {
    simulate_error
    echo "Script continues normally."
}
# 调用主函数
main





# 日志轮转函数
rotate_logs(){
    # 如果你的脚本会生成日志文件，编写一个函数来实现日志轮转，以避免日志文件过大
    local log_file="/var/log/myapp.log"
    local max_log_size=$((10 * 1024 * 1024))  # 10MB

    if [[ -f "$log_file" && $(stat -c %s "$log_file") -gt $max_log_size ]]; then
        mv "$log_file" "$log_file.old"
        touch "$log_file"
    fi
}


# 显示进度条-步数控制
show_progress_by_steps() {
    local total_steps="$1"
    local current_step=0
    local progress_char="▉"  # 进度条字符

    while ((current_step < total_steps)); do
        # 在这里执行你的具体命令或任务
        # 每完成一个步骤，更新进度条
        current_step=$((current_step + 1))
        local percentage=$((current_step * 100 / total_steps))
        local progress=$(printf "%.0f" "$((current_step * 50 / total_steps))")  # 进度条长度

        printf "\r[%-${progress}s] %3d%%" "${progress_char:0:$progress}" "$percentage"
        sleep 0.1  # 控制刷新速度
    done

    echo  # 换行
}

## 示例用法
#  引用进度条函数
source progress.sh
total_steps=100
show_progress "$total_steps"
# 在这里执行你的具体安装步骤
# ...
echo "进度条完成！"

# 显示进度条-时长控制
show_progress_by_duration() {
    local total_duration="$1"  # 预估的总时长（秒）
    local current_duration=0
    local progress_char="▉"  # 进度条字符

    while ((current_duration < total_duration)); do
        # 在这里执行你的具体命令或任务
        # 每完成一个步骤，更新进度条
        current_duration=$((current_duration + 1))
        local percentage=$((current_duration * 100 / total_duration))
        local progress=$(printf "%.0f" "$((current_duration * 50 / total_duration))")  # 进度条长度

        printf "\r[%-${progress}s] %3d%%" "${progress_char:0:$progress}" "$percentage"
        sleep 1  # 控制刷新速度（每秒一次）
    done

    echo  # 换行
}
## 示例用法
#  引用进度条函数
source progress.sh
total_duration=300
show_progress_by_duration "$total_duration"
# 在这里执行你的具体安装步骤
# ...
echo "进度条完成！"