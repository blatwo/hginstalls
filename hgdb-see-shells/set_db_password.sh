
# 密码设置
# 设置数据库用户密码并更新 .pgpass 文件
function set_db_password_and_update_pgpass() {
    local db_name="highgo"       # 数据库名称
    local new_password="${admin_password}"  # 新密码
    local pgpass_file="$HOME/.pgpass"  # .pgpass 文件路径

    echo "正在设置数据库用户密码为永久..."

    # 执行 SQL 命令设置密码和参数
    $HGBINPATH/psql $db_name syssso <<-EOF
SELECT set_secure_param('hg_idcheck.pwdvaliduntil','0');
ALTER USER current_user PASSWORD '${new_password}';
\c - sysdba
ALTER USER current_user PASSWORD '${new_password}';
\c - syssao
ALTER USER current_user PASSWORD '${new_password}';
EOF

    # 检查 SQL 命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "数据库用户密码设置成功。"
    else
        echo "数据库用户密码设置失败。" >&2
        return 1
    fi

    echo "正在更新 .pgpass 文件中的密码..."

    # 使用 sed 替换 .pgpass 文件中的旧密码
    sed -i "s/Hello@123456/$new_password/g" "$pgpass_file"

    # 检查 sed 命令是否成功执行
    if [ $? -eq 0 ]; then
        echo ".pgpass 文件更新成功。"
    else
        echo ".pgpass 文件更新失败。" >&2
        return 1
    fi
}
