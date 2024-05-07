#!/bin/bash

# 设置资源阈值
cpu_threshold=60
memory_threshold=60

# 无限循环, 增压CPU
endless_loop() {
    while true; do
        # 增压操作
        echo -ne "i=0; while i<10; do i=i+1; i=100; sleep 10; done" | /bin/bash &
        # sleep 1  # 避免无限循环过快
    done
}

limited_loop() {
    while i>100; do
        # 增压操作
        echo -ne "i=0; while i<10; do i=i+1; done" | /bin/bash &
        sleep 10  # 等待一段时间
    done
}

# 创建父进程
create_parent_process() {
        endless_loop &
        pid=$!
        echo $pid
}


# 主循环
while true; do
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    memory_usage=$(free -m | awk '/Mem/ {print $3/$2 * 100}')

    if [ $(echo "$cpu_usage < $cpu_threshold" | bc) -eq 1 ] && [ $(echo "$memory_usage < $memory_threshold" | bc) -eq 1 ]; then
        echo "cpu: $cpu_usage; mem: $memory_usage"
        echo "Resource usage is below threshold. Increasing load..."
        create_parent_process
    else
        echo "cpu: $cpu_usage; mem: $memory_usage"
        # 资源占用率高于阈值，不作处理
        echo "Resource usage is above threshold. No action needed."
        if [ -n "$pid" ]; then
            kill $pid
        fi
    fi

    # 等待一段时间后再次检查
    sleep 60
done





#!/bin/bash

# 获取当前 CPU 使用率
cpu_using=$(top -n 1 | grep '%Cpu' | awk '{print $2}' | awk -F '.' '{print $1}')

# 需要达到的 CPU 使用率，脚本传参
cpu_target=$1

# 如果脚本执行没有参数传入，返回脚本使用方法并退出脚本
if [ $# != 1 ]; then
    printf "\e[0;34mUSAGE: bash $0 40\e[0m\n"
    exit 1
fi

# 如果需要达到的 CPU 使用率小于等于当前使用率则退出脚本
# 反之，定义 cpu_status 为需要达到的 CPU 使用率和当前使用率的差值
if [[ "${cpu_target}" -le "${cpu_using}" ]]; then
    echo "CPU 使用率已经高于目标值，无需增加负载。"
    exit 0
else
    cpu_status=$((cpu_target - cpu_using))
fi

# 获取 CPU 线程数
cpu_threads=$(grep 'processor' /proc/cpuinfo | uniq | wc -l)

# 需要达到的 CPU 使用率使用线程数量
cpu_target_threads=$(awk "BEGIN {print int(${cpu_threads} * ${cpu_target} / 100)}")

# 需要增加的线程数量不能为负数
if [[ "${cpu_target_threads}" -lt "${cpu_threads}" ]]; then
    echo "CPU 使用率已经高于目标值，无需增加负载。"
    exit 0
fi

# 需要增加的线程数量
cpu_threads_to_add=$((cpu_target_threads - cpu_threads))

# 增加 CPU 负载
for i in $(seq ${cpu_threads_to_add}); do
    echo -ne "i=0; while true; do i=i+1; done" | /bin/bash &
done

echo "CPU 负载已增加，使资源使用率保持在 ${cpu_target}% 到 60% 之间。"
