#!/bin/bash
# 文件名：elastic_resource_management.sh

# 设置资源阈值
cpu_threshold=60
memory_threshold=60

# get_cpu_usage() {
#     top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}'
#     # 获取 CPU 使用率的方法（例如：top、sar、mpstat 等）
#     # 这里只是一个示例，你需要根据实际情况替换为你的方法
#     echo 50
# }

# get_memory_usage() {
#     # 获取内存使用率的方法（例如：free、top、ps 等）
#     # 这里只是一个示例，你需要根据实际情况替换为你的方法
#     echo 55
# }

# 无限循环, 增压CPU
endless_loop() {
    echo -ne "i=0; while true; do i=i+100; i=100; done" | /bin/bash &
}


if [ $# != 1 ]; then
    echo "USAGE: $0 <CPUs>"
    exit 1
fi

for i in $(seq $1); do
    endless_loop
    pid_array[$i]=$!
done


# 主循环
while true; do
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    memory_usage=$(free -m | awk '/Mem/ {print $3/$2 * 100}')

    if [ "$cpu_usage" -lt "$cpu_threshold" ] && [ "$memory_usage" -lt "$memory_threshold" ]; then
        
        
        # 资源占用率低于阈值，增加 CPU 和内存压力
        # 这里可以调用之前提到的方案一或方案二中的方法来增加资源占用
        echo "Resource usage is below threshold. Increasing load..."
        # 在这里执行你的操作，例如启动更多的任务、进程等
    else
        # 资源占用率高于阈值，不作处理
        echo "Resource usage is above threshold. No action needed."
    fi

    # 等待一段时间后再次检查
    sleep 60
done
