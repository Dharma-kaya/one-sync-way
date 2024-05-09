#!/bin/bash


cpu 增压方案1:
sudo yum install stress
stress --cpu 核心数 --timeout 超时停止

cpu 增压方案2:
# 设置循环次数
loop_count=1000

# 设置 CPU 亲和性为 CPU 0 和 1
taskset -c 0,1 /bin/bash -c "
for ((i=0; i<$loop_count; i++)); do
    echo \"Running infinite loop: \$i\"
    # 在这里添加您想要执行的其他命令
done
"

#!/bin/bash

# 设置阈值（40%）
threshold=40

# 获取 CPU 核心数量
core_count=$(nproc)

# 循环检查每个核心的使用率
for ((core=0; core<$core_count; core++)); do
    usage=$(mpstat -P $core | awk '/Average:/ {print 100 - $NF}')
    if ((usage > threshold)); then
        echo "Core $core: CPU usage is high ($usage%). Decrease pressure."
        # 在这里执行减压操作，例如降低负载或限制进程
    else
        echo "Core $core: CPU usage is within limits ($usage%). Increase pressure."
        # 在这里执行增压操作，例如启动更多进程或增加负载
    fi
done




#!/bin/bash

# 设置阈值（40%）
threshold=40

# 获取 CPU 核心数量
core_count=$(nproc)

# 循环检查每个核心的使用率
for ((core=0; core<$core_count; core++)); do
    usage=$(mpstat -P $core | awk '/Average:/ {print 100 - $NF}')
    if ((usage > threshold)); then
        echo "Core $core: CPU usage is high ($usage%). Decrease pressure."
        # 在这里执行减压操作，例如降低负载或限制进程
    else
        echo "Core $core: CPU usage is within limits ($usage%). Increase pressure."
        # 在这里执行增压操作，例如启动更多进程或增加负载
    fi
done




#!/bin/bash

# 设置阈值（百分比）
cpu_threshold=40
memory_threshold=90

# 获取CPU核心数
cpu_cores=$(nproc)

while true; do
    # 获取当前CPU使用率
    current_cpu_usage=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if [ $(echo "$current_cpu_usage < $cpu_threshold" |bc) -eq 1 ]; then
        # 增压：启动更多进程
        desired_process_count=$((cpu_cores * 2))  # 根据需要调整倍数
        echo "CPU使用率低于阈值，启动更多进程..."
        for ((i = 0; i < desired_process_count; i++)); do
            # 替换为你的启动进程命令，例如：
            # nohup your_process_command &
            echo "启动进程 $i ..."
            # 将进程放在父进程下
            # your_process_command
                # 设置循环次数
                loop_count=1000

                # 设置 CPU 亲和性为 CPU 0 和 1
                taskset -c 0,1 /bin/bash -c "
                for ((i=0; i<$loop_count; i++)); do
                    echo \"Running infinite loop: \$i\"
                    # 在这里添加您想要执行的其他命令
                    # echo -ne "i=0; while $i>1000000; do i=i+1;  done" | /bin/bash &
                done
                "
            # 记录子进程的PID
            child_pid=$!
            # 将子进程的PID添加到父进程的进程组
            echo "$child_pid" >> /tmp/parent_process_pids.txt
        done
    else
        # 减压：停止一些进程
        desired_process_count=$((cpu_cores / 2))  # 根据需要调整倍数
        echo "CPU使用率高于阈值，停止一些进程..."
        # 从记录的文件中读取子进程的PID并逐个杀死
        while read -r child_pid; do
            echo "杀死进程 $child_pid ..."
            kill "$child_pid"
        done < /tmp/parent_process_pids.txt
        # 删除记录文件
        rm /tmp/parent_process_pids.txt
    fi

    # 等待60秒后再次检测
    sleep 60
done



































 设置资源阈值
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
