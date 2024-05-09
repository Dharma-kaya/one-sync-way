#!/bin/bash
## frontend: npm package
npm_package(){
  frontend_dir="$WORKDIR/code/Frontend"
  log_mesg "npm 版本: $(npm -v)" && npm config set strict-ssl=false
  npm i pnpm -g && log_mesg "pnpm 版本: $(pnpm --version)"
  log_mesg "$_15 开始进行前端 npm 打包, 预估耗时 5-7min ..."
  log_mesg "待构建打包的前端代码目录: $(ls -l $frontend_dir)"
  comps=$(find $frontend_dir -maxdepth 1 -type d | tail -n +2)
  pkg(){
    cd $i
    start_time=$(date +%s)
    $pkg_tool install 1>/dev/null &
    $pkg_tool build:ies:popd:prod_editor_cloud:editor_cloud 1>/dev/null &
    wait
    local end_time=$(date +%s)
    local dura_time=$(calc_dura start_time end_time)
    local commitId=$(git rev-parse HEAD)
    printf "$timestamp - %-16s 打包完毕  耗时 %-10s  commitId %s\n" "$(basename $i)" "$dura_time" "$commitId"
  }
  for i in ${comps[@]}
  do
    # 判断使用哪种打包工具
    if [[ $i =~ "sch | review" ]]; then
      pkg_tool="npm"
    else
      pkg_tool="pnpm"
    fi
    # 合仓工程进入子目录打包
    if [[ $i =~ "sch" ]]; then
      comps=$(find $frontend_dir -maxdepth 2 -type d | tail -n +2 | grep "sch-")
      for i in ${comps[@]}; do pkg; done
    else
      pkg
    fi
  done
}
npm_package && find $WORKDIR -type f -name "*tar.gz"