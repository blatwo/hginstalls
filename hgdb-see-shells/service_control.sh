# service_control.sh

# 设置服务函数
function setup_service() {
    local l_service_name=${HGDB_VERSION}
    local l_service_file=${DB_SERVICE_FILE}
    local l_service_templatefile="${TEMPLATE_PATH}/hgdb-see.service.template"
    local l_run_user=${RUN_USER}  # 替换为实际的运行用户
    local l_run_group=${RUN_GROUP}  # 替换为实际的运行用户组
    local l_binpath=${HGBINPATH}  # 替换为实际的 hgdb bin 目录
    local l_data=${HGDATA}  # 替换为实际的 hgdb 数据目录

    echo "开始配置服务: ${service_name}..."

    # 复制模板到系统目录
    #cp my_service_template.service ${service_file}

    # 替换模板中的占位符
    sed -e "s|\${run_user}|${l_run_user}|g" \
        -e "s|\${run_group}|${l_run_group}|g" \
        -e "s|\${HGBINPATH}|${l_binpath}|g" \
        -e "s|\${HGDATA}|${l_data}|g" \
        ${l_service_templatefile} | sudo tee ${l_service_file}

    # 重新加载 systemd
    sudo systemctl daemon-reload

    # 启动并启用服务
    sudo systemctl enable ${l_service_name}
    sudo systemctl start ${l_service_name}
    sudo systemctl status ${l_service_name}

    echo "服务配置完成并已启动。"
}


# 卸载服务函数
function uninstall_service() {
    local l_service_name=${HGDB_VERSION}
    local l_service_file=${DB_SERVICE_FILE}

    echo "开始卸载服务: ${l_service_name}..."

    # 停止并禁用服务
    sudo systemctl stop ${l_service_name}
    sudo systemctl disable ${l_service_name}

    # 删除服务文件
    if [ -f ${l_service_file} ]; then
        sudo rm -f ${service_file}
        echo "服务文件已删除: ${l_service_file}"
    else
        echo "服务文件未找到: ${l_service_file}"
    fi

    # 重新加载 systemd
    sudo systemctl daemon-reload

    echo "服务卸载完成。"
}

