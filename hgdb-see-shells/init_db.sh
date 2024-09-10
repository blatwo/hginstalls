# 初始化数据库
function init_db() {
    # 参数化配置
    auth_method=${auth_method:-"sm3"}      # 认证方法，例如 sm3
    encryption_method=${encryption_method:-"sm4"} # 加密方法，例如 sm4
    echo_message=${echo_message:-"echo 12345678"} # 输出消息
    pgdata_dir=${HGDATA:-"$PGDATA"}  # 数据目录路径
    encoding=${database_encoding:-"UTF8"}       # 编码格式

    # 执行 initdb 命令
    echo $HGBINPATH/initdb -A "$auth_method" -e "$encryption_method" -c "$echo_message" -D "$pgdata_dir" -E "$encoding" 

    $HGBINPATH/initdb -A "$auth_method" -e "$encryption_method" -c "$echo_message" -D "$pgdata_dir" -E "$encoding" --pwfile=<(printf "%.0sHello@123456\n" {1..3})

    if [ $? -eq 0 ]; then
        echo "数据库初始化完成。"
    else
        echo "数据库初始化失败。" >&2
        exit 1
    fi
}
