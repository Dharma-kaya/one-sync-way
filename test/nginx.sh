# nginx install and deploy frontend
#!/bin/bash

# 定义前端包路径和目标目录
frontend_package="/opt/hcc/frontend.tar.gz"
target_dir="/var/www/html"
nginx_home="$NGINX_HOME"  # 请将此处更改为你想要的nginx安装目录

# 检查前端包是否存在
if [ ! -f "$frontend_package" ]; then
    echo "前端包 $frontend_package 不存在，请确认路径是否正确。"
    exit 1
fi

# 解压前端包到目标目录
tar -xzf "$frontend_package" -C "$target_dir"

# 安装nginx
echo "正在安装nginx..."
# 假设你已经下载了nginx的tar.gz包，并且它位于与此脚本相同的目录中
nginx_tarball="nginx-1.20.1.tar.gz"
tar -xzf "$nginx_tarball"
cd "nginx-1.20.1"
./configure --prefix="$nginx_home"
make
make install

# 配置nginx
echo "配置nginx..."
cat <<EOF > "$nginx_home/conf/nginx.conf"
user  nginx;
worker_processes  auto;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   $target_dir;
            index  index.html;
        }
    }
}
EOF

ln -s "$nginx_home/conf/nginx.conf" /etc/nginx/sites-enabled/
systemctl restart nginx

# 校验nginx是否正常启动
if systemctl is-active --quiet nginx; then
    echo "nginx已成功启动。"
else
    echo "nginx启动失败，请检查配置和日志。"
fi

# 打印成功消息
echo "前端包已部署到 $target_dir 目录，并且nginx已安装并配置。"
