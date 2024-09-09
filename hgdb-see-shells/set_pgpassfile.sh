# set_pgpassfile.sh
# 生成 .pgpass 文件，并备份原有的 .pgpass
function add_pgpassfile() {
    # 定义 .pgpass 文件路径
    pgpass_file="$HOME/.pgpass"

    # 如果 .pgpass 文件存在，备份它
    if [ -f "$pgpass_file" ]; then
        backup_file="$pgpass_file.bak.$(date +%Y%m%d%H%M%S)"
        echo "检测到现有的 .pgpass 文件，正在备份到 $backup_file ..."
        cp "$pgpass_file" "$backup_file"
        if [ $? -eq 0 ]; then
            echo "备份成功。"
        else
            echo "备份失败。" >&2
            exit 1
        fi
    fi

    # 创建新的 .pgpass 文件
    echo "生成新的 .pgpass 文件..."
    cat > "$pgpass_file" <<EOF
localhost:5866:*:sysdba:Hello@123456
localhost:5866:*:syssao:Hello@123456
localhost:5866:*:syssso:Hello@123456
EOF

    # 确保 .pgpass 文件的权限为 600
    chmod 600 "$pgpass_file"
    if [ $? -eq 0 ]; then
        echo ".pgpass 文件已生成，路径：$pgpass_file，权限已设置为 600。"
    else
        echo "无法设置 .pgpass 文件的权限。" >&2
        exit 1
    fi
}

# 删除 .pgpass 文件及其备份
function remove_pgpassfile() {
    # 定义 .pgpass 文件路径
    pgpass_file="$HOME/.pgpass"
    backup_pattern="$HOME/.pgpass.bak.*"

    # 删除 .pgpass 文件
    if [ -f "$pgpass_file" ]; then
        echo "正在删除 .pgpass 文件..."
        rm -f "$pgpass_file"
        if [ $? -eq 0 ]; then
            echo ".pgpass 文件已成功删除。"
        else
            echo ".pgpass 文件删除失败。" >&2
            exit 1
        fi
    else
        echo "未检测到 .pgpass 文件，跳过删除操作。"
    fi

    # 删除 .pgpass 备份文件
    if ls $backup_pattern 1> /dev/null 2>&1; then
        echo "正在删除所有 .pgpass 备份文件..."
        rm -f $backup_pattern
        if [ $? -eq 0 ]; then
            echo "所有 .pgpass 备份文件已成功删除。"
        else
            echo ".pgpass 备份文件删除失败。" >&2
            exit 1
        fi
    else
        echo "未检测到任何 .pgpass 备份文件。"
    fi
}
