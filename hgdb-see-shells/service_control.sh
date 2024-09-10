# service_control.sh

# 瀚高服务配置
# service_db_setup
# service_db_running_control[start|stop|restart|status|reload]
# service_db_unset
# service_hghac_setup
# service_hghac_running_control[start|stop|restart|status|reload]
# service_hghac_unset
function setup_service_hgdb() {
    local l_service_name=${SERVICE_NAME_HGDB}
    local l_service_file=${DB_SERVICE_FILE}
    local l_service_templatefile="${TEMPLATE_PATH}/hgdb-see.service.template"
    local l_run_user=${RUN_USER}  # 替换为实际的运行用户
    local l_run_group=${RUN_GROUP}  # 替换为实际的运行用户组
    local l_binpath=${HGBINPATH}  # 替换为实际的 hgdb bin 目录
    local l_data=${HGDATA}  # 替换为实际的 hgdb 数据目录

    echo "开始配置服务: ${l_service_name}..."

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

# 删除服务的函数（通用）
# 调用函数
# 例如： remove_service "nginx.service"
remove_service() {
    local service_name="$1"

    # 检查是否提供了服务名称
    if [ -z "$service_name" ]; then
        echo "错误：请提供要删除的服务名称。或者手动删除服务。"
        return # 不中断，函数结束
    fi

    # 检查服务是否存在
    #trap '' SIGPIPE;
    if (systemctl list-units --type=service --all) | grep "$service_name"; then
	    echo $?
        echo "服务 $service_name 存在，继续执行..."
    else
	    echo $?
        echo "服务 $service_name 不存在或未加载，请手动检查或删除服务文件。"
        return  # 不中断，函数结束
    fi

    echo "停止 $service_name 服务..."
    sudo systemctl stop "$service_name"

    echo "禁用 $service_name 服务..."
    sudo systemctl disable "$service_name"

    # 获取 service 文件路径
    service_path=$(systemctl show -p FragmentPath "$service_name" | cut -d'=' -f2)

    if [ -n "$service_path" ] && [ -f "$service_path" ]; then
        echo "删除服务文件：$service_path"
        sudo rm "$service_path"
    else
        echo "未找到 $service_name 的服务文件路径或文件不存在。"
    fi

    echo "重新加载 systemd 守护进程..."
    sudo systemctl daemon-reload

    echo "检查是否成功移除 $service_name..."
    if systemctl list-units --type=service --all | grep -q "$service_name"; then
        echo "服务 $service_name 未完全移除，请手动检查。"
    else
        echo "服务 $service_name 已成功移除。"
    fi
}



