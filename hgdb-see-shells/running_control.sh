# running_control.sh

# 控制数据库服务的启动、停止、重启、重新加载
# running_control start   # 启动数据库服务
# running_control stop    # 停止数据库服务
# running_control restart # 重启数据库服务
# running_control reload  # 重新加载数据库配置

function running_control() {
    # 本地变量定义
    local l_pgdata=${HGDATA:-$DATA_DIR}

    # 检查是否传入了操作参数
    if [ -z "$1" ]; then
        echo "请提供一个操作参数：start, stop, restart, reload"
        return 1
    fi

    # 解析操作参数
    case $1 in
        start)
            echo "正在启动数据库服务..."
            $HGBINPATH/pg_ctl -D "$l_pgdata" start
            ;;
        stop)
            echo "正在停止数据库服务..."
            $HGBINPATH/pg_ctl -D "$l_pgdata" stop
            ;;
        restart)
            echo "正在重启数据库服务..."
            $HGBINPATH/pg_ctl -D "$l_pgdata" restart
            ;;
        reload)
            echo "正在重新加载数据库配置..."
            $HGBINPATH/pg_ctl -D "$l_pgdata" reload
            ;;
        *)
            echo "无效的操作参数：$1。有效的参数为：start, stop, restart, reload" >&2
            return 1
            ;;
    esac

    # 检查命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "数据库服务 $1 操作完成。"
    else
        echo "数据库服务 $1 操作失败。" >&2
        return 1
    fi
}

