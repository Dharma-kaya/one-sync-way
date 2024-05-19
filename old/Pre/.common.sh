# 注释条打印
print_sepa(){
    local sepa_char="$1"
    local sepa_length="$2"
    if [[ ! -n "$2" ]]; then
	    printf "%$(tput cols)s\n" | tr ' ' "$1"
	  else
	    printf "%-${sepa_length}s" | tr ' ' "$sepa_char"
    fi
}
_top=$(print_sepa "=")
_15=$(print_sepa "=" 15)
# 时间戳
log_mesg(){
	local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
	local mesg="$1"
	eval echo "$timestamp - $mesg"
}

echo "$_top"
log_mesg "$_15 开始检查并卸载旧版docker ......"