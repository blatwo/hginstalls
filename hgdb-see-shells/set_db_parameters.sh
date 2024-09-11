
# 设置数据库系统参数
function set_db_parameters() {
    local db_name="highgo"  # 数据库名称
    local db_user="sysdba"  # 用户名

    echo "正在设置数据库系统参数..."

    # 定义 SQL 文件路径
    TEMPLATE_SQL_FILE="$SCRIPT_DIR/template/db_params_template.sql"  # 模板文件路径

    # 检查模板 SQL 文件是否存在
    if [ ! -f "$TEMPLATE_SQL_FILE" ]; then
        echo "SQL 模板文件 $TEMPLATE_SQL_FILE 不存在。" >&2
        return 1
    fi

    # 替换 SQL 模板文件中的占位符为实际的变量值
    # 使用 psql 执行替换后的 SQL 文本（管道符）
    sed -e "s/@SHARED_BUFFERS@/${buffer_shared}/g" \
        -e "s/@ARCHIVE_MODE@/${ARCHIVE_MODE}/g" \
        -e "s|@ARCHIVE_DIR@|${ARCHIVE_DIR}|g" \
        "${TEMPLATE_SQL_FILE}" | $HGBINPATH/psql $db_name $db_user

    # 检查命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "数据库系统参数设置成功。"
    else
        echo "数据库系统参数设置失败。" >&2
        return 1
    fi
}

# 设置数据库安全参数
function set_security_parameters() {
    local db_name="highgo"  # 数据库名称
    local db_user="syssso"  # 用户名

    echo "正在设置数据库安全参数..."

    # 定义 SQL 文件路径
    TEMPLATE_SQL_FILE="$SCRIPT_DIR/template/set_security_parameters.sql"  # 模板文件路径

    # 检查模板 SQL 文件是否存在
    if [ ! -f "$TEMPLATE_SQL_FILE" ]; then
        echo "SQL 模板文件 $TEMPLATE_SQL_FILE 不存在。" >&2
        return 1
    fi

    # 替换 SQL 模板文件中的占位符为实际的变量值
    # 使用 psql 执行替换后的 SQL 文本（管道符）
    sed -e "s/@PASSWORD_POLICY@/${PASSWORD_POLICY}/g" \
        "${TEMPLATE_SQL_FILE}" | $HGBINPATH/psql $db_name $db_user

    # 检查 SQL 命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "数据库安全参数设置成功。"
    else
        echo "数据库安全参数设置失败。" >&2
        return 1
    fi
}

# 关闭数据库审计功能
function disable_audit() {
    local db_name="highgo"  # 数据库名称
    local db_user="syssao"  # 用户名

    echo "正在关闭数据库审计功能..."

    # 使用 psql 执行关闭审计的 SQL 命令
    $HGBINPATH/psql $db_name $db_user <<-EOF
SELECT set_audit_param('hg_audit','off');
EOF

    # 检查 SQL 命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "数据库审计功能已成功关闭。"
    else
        echo "关闭数据库审计功能失败。" >&2
        return 1
    fi
}
