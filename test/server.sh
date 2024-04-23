#!/bin/bash
# 作者：Copilot
# QQ：123456789

# 指定包含 JAR 文件的目录
jar_directory="/opt/hcc"

# 指定 JAVA_HOME 目录
java_home="/path/to/java_home"

# 列出目录中的所有 JAR 文件
jar_files=("$jar_directory"/*.jar)

# 启动指定服务
start_specific_service() {
    local service_name="$1"
    local service_jar="$jar_directory/$service_name.jar"
    if [ -f "$service_jar" ]; then
        # 启动命令
        command="$java_home/bin/java -jar $service_jar > /var/log/$service_name.log 2>&1 &"
        # 执行启动命令
        eval "$command"
        echo "已启动 $service_name"
    else
        echo "找不到 $service_name.jar 文件。"
    fi
}

# 启动全部服务
start_all_services() {
    for jar_file in "${jar_files[@]}"; do
        service_name=$(basename "$jar_file" .jar)
        start_specific_service "$service_name"
    done
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        start_all_services
    else
        for service in "$@"; do
            start_specific_service "$service"
        done
    fi
}

# 调用主函数
main "$@"
