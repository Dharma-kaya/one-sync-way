#!/bin/bash

# 解析 ini 文件
parse_ini_file() {
    local file="$1"
    local section="$2"
    local key="$3"

    # 读取配置文件
    while IFS='=' read -r config_key config_value; do
        config_key=$(echo "$config_key" | tr -d '[:space:]')
        config_value=$(echo "$config_value" | tr -d '[:space:]')

        if [[ "$config_key" == "["* ]]; then
            current_section="${config_key#[}"
            current_section="${current_section%]}"
        elif [[ -n "$current_section" ]]; then
            if [[ "$current_section" == "$section" ]]; then
                if [[ "$config_key" == "$key" ]]; then
                    echo "$config_value"
                    return
                fi
            fi
        fi
    done < "$file"

    # 若未传入参数，则导出全部配置
    if [[ -z "$section" && -z "$key" ]]; then
        while IFS='=' read -r config_key config_value; do
            config_key=$(echo "$config_key" | tr -d '[:space:]')
            config_value=$(echo "$config_value" | tr -d '[:space:]')

            if [[ "$config_key" == "["* ]]; then
                current_section="${config_key#[}"
                current_section="${current_section%]}"
            elif [[ -n "$current_section" ]]; then
                echo "export $config_key=$config_value"
            fi
        done < "$file"
    else
        echo "配置项 [$section] $key 未找到。"
    fi
}

# 示例用法
ini_file="env.ini"
section="jre"
key="JAVA_HOME"

# 获取 JAVA_HOME 的值
java_home=$(parse_ini_file "$ini_file" "$section" "$key")
if [[ -n "$java_home" ]]; then
    echo "$section $key = $java_home"
else
    echo "配置项 [$section] $key 未找到。"
fi

# 导出全部配置
parse_ini_file "$ini_file"
