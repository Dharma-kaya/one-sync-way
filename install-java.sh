#!/bin/bash

# 定义所需的 Java 版本和下载链接
JAVA_VERSION="11"
JAVA_DOWNLOAD_URL="https://example.com/path/to/java-${JAVA_VERSION}.tar.gz"

# 定义安装目录（根据你的实际情况修改）
INSTALL_DIR="/opt/my_java"

# 检查是否已安装 Java
if command -v java >/dev/null 2>&1; then
    echo "Java 已经安装。跳过安装步骤。"
    exit 0
fi

# 如果安装目录不存在，则创建
mkdir -p "$INSTALL_DIR"

# 下载 Java
echo "正在下载 Java ${JAVA_VERSION}..."
curl -L "$JAVA_DOWNLOAD_URL" -o "$INSTALL_DIR/java.tar.gz"

# 解压 Java
echo "正在解压 Java..."
tar -xzf "$INSTALL_DIR/java.tar.gz" -C "$INSTALL_DIR"

# 设置环境变量
echo "正在设置环境变量..."
export JAVA_HOME="$INSTALL_DIR/java-${JAVA_VERSION}"
export PATH="$JAVA_HOME/bin:$PATH"

# 验证安装
if command -v java >/dev/null 2>&1; then
    echo "Java ${JAVA_VERSION} 安装成功。"
else
    echo "Java 安装失败。"
fi

# 清理临时文件
rm "$INSTALL_DIR/java.tar.gz"

# 注意：你需要根据你的具体环境调整路径和下载链接。
# 另外，考虑将此脚本添加到部署流程或自动化流水线中。




#当你安装了自己的 Java 版本后，你可以通过以下方式方便地调用它，同时不影响系统默认的 Java：
#方法1：使用绝对路径：
#在你的脚本或命令中，直接指定你安装的 Java 版本的绝对路径。例如：
/opt/my_java/java-11/bin/java -version
#这将调用你安装的 Java 11

#方法2：设置别名：
#在你的 shell 配置文件（如 ~/.bashrc 或 ~/.zshrc）中添加别名。例如：
alias myjava='/opt/my_java/java-11/bin/java'
#然后在终端中运行：
myjava -version
#这将调用你安装的 Java 11。

#方法3：使用环境变量：
#在你的脚本中，设置一个临时的环境变量，以便在当前会话中使用你的 Java 版本。例如：
export JAVA_HOME="/opt/my_java/java-11"
export PATH="$JAVA_HOME/bin:$PATH"
#然后运行你的 Java 程序。

#方法4：使用脚本：
#编写一个小的 Bash 脚本，将你的 Java 版本路径添加到 PATH 中，然后运行你的程序。例如：
#!/bin/bash
export JAVA_HOME="/opt/my_java/java-11"
export PATH="$JAVA_HOME/bin:$PATH"
java -version
#然后运行这个脚本。

#请根据你的实际需求选择其中一种方法。这样，你就可以方便地调用你自己安装的 Java，而不会影响系统默认的 Java 版本。如果还有其他问题，欢迎继续提问！