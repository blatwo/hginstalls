# set_db_parameter.sh

# 设置数据库单个系统参数
function set_db_parameter() {
    local db_name="$1"      # 数据库名称
    local db_user="$2"      # 用户名
    local db_password="$3"  # 密码
    local parameter="$4"    # 参数名称
    local value="$5"        # 参数值

    # 检查是否提供了所有必需的参数
    if [ -z "$db_name" ] || [ -z "$db_user" ] || [ -z "$db_password" ] || [ -z "$parameter" ] || [ -z "$value" ]; then
        echo "请提供所有必需的参数：数据库名称、用户名、密码、参数名称、参数值。" >&2
        return 1
    fi

    echo "正在设置数据库参数：$parameter = $value"

    # 使用 psql 设置数据库参数
    PGPASSWORD="$db_password" $HGBINPATH/psql -d "$db_name" -U "$db_user" -c "ALTER SYSTEM SET $parameter = '$value';"

    # 检查命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "参数 $parameter 设置成功。"
    else
        echo "参数 $parameter 设置失败。" >&2
        return 1
    fi
}
