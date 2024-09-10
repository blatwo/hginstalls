# 数据库授权安装和检查
function install_and_check_license() {
    # 授权文件默认放到当前目录
    local license_file="${lic_file}"

    # 检查授权文件是否存在
    if [ ! -f "$license_file" ]; then
        echo "授权文件不存在，跳过授权安装。" >&2
        return 0  # 文件不存在，直接返回，继续执行后续操作
    fi

    echo "正在修改授权文件权限..."

    # 修改授权文件权限
    chmod 0600 "$license_file"

    # 检查权限修改是否成功
    if [ $? -eq 0 ]; then
        echo "授权文件权限修改成功。"
    else
        echo "授权文件权限修改失败，跳过授权安装。" >&2
        return 0  # 继续后续操作，而不是退出整个脚本
    fi

    echo "正在安装授权文件..."

    # 安装授权文件
    HGDB_HOME=$HGBASE $HGBINPATH/hg_lic -l -F "$license_file"

    # 检查授权文件安装是否成功
    if [ $? -eq 0 ]; then
        echo "授权文件安装成功。"
    else
        echo "授权文件安装失败，跳过授权确认。" >&2
        return 0  # 继续后续操作
    fi

    echo "正在确认安装结果..."

    # 确认安装结果
    HGDB_HOME=$HGBASE $HGBINPATH/hg_lic

    # 检查确认命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "授权文件已成功确认。"
    else
        echo "授权文件确认失败，跳过授权确认。" >&2
        return 0  # 继续后续操作
    fi

    # 授权完成后继续执行后续代码
    echo "授权流程完成。继续执行其他操作..."
}
