#!/bin/bash

# 瀚高数据库版本
readonly HGDB_VERSION=hgdb-see-4.5.10

# 获取当前系统的架构
readonly ARCH=$(uname -m)

# 获取当前脚本的目录
readonly SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 获取执行该 SHELL 的用户名和主用户组
readonly USER_NAME=$(id -un)
readonly USER_GROUP=$(id -gn)
# 获取执行该 SHELL 的用户对应的主目录
readonly USER_HOME=$HOME

# 解析自定义参数
echo "Received options: $@"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --install-dir) install_dir="$2"; shift ;;
        --data-dir) data_dir="$2"; shift ;;
        --bakup-dir) bakup_dir="$2"; shift ;;
        --archive-mode) archive_mode="$2"; shift ;;
        --archive-dir) archive_dir="$2"; shift ;;
        --buffer-shared) buffer_shared="$2"; shift ;;
        --auth-method) auth_method="$2"; shift ;;
        --encoding) database_encoding="$2"; shift ;;
        --encryption-method) encryption_method="$2"; shift ;;
        --echo-message) echo_message="$2"; shift ;;
        --password) admin_password="$2"; shift ;;
        --lic) lic_file="$2"; shift ;;
        --run-user) run_user="$2"; shift ;;
        --run-group) run_group="$2"; shift ;;
        --help) cat "$(dirname "$0")/help.txt"; exit 0 ;;
        --quiet) quiet=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# 全局变量
# 从自定义参数获取值，如果没有参数输入则给定默认值
INSTALL_DIR=${install_dir:-/opt/highgo}
DATA_DIR=${data_dir:-${USER_HOME}/data}
BAKUP_DIR=${bakup_dir:-${USER_HOME}/hgdbbak}
archive_mode=${archive_mode:-on}
archive_dir=${archive_dir:-${USER_HOME}/hgdbbak/archive}
buffer_shared=${buffer_shared:-1GB}
auth_method=${auth_method:-sm3}
admin_password=${admin_password:-Hello@1234}
lic_file=${lic_file:-$HOME/hgdb_0_t.lic}
RUN_USER=${run_user:-$USER_NAME}
RUN_GROUP=${run_group:-$USER_GROUP}

# 瀚高路径
# DATA_DIR 与 HGDATA 内容一样，HGDATA 是个软链接。通常我们使用 HGDATA，目录操作的时候可以使用 DATA_DIR。
HGBASE=$INSTALL_DIR/$HGDB_VERSION
HGDATA=$INSTALL_DIR/$HGDB_VERSION/data
HGBINPATH=$INSTALL_DIR/$HGDB_VERSION/bin

# 模板目录
TEMPLATE_PATH=$SCRIPT_DIR/template
# 自启动服务
DB_SERVICE_NAME=${HGDB_VERSION:-hgdb}
DB_SERVICE_FILE="/etc/systemd/system/${DB_SERVICE_NAME}.service"

# 根据架构选择对应的包名
case "$ARCH" in
    x86_64)
        #PACKAGE_HGDB="$SCRIPT_DIR/x86_64/hgdb-see-4.5.8.5-f0671cf.x86_64.tar.gz"
        PACKAGE_HGDB="$SCRIPT_DIR/x86_64/hgdb-see-4.5.10-a64a611-20240426.x86_64.tar.gz"
        PACKAGE_HGHAC="$SCRIPT_DIR/x86_64/hghac4.2.3.3-see-17f931d-20240620.x86_64.tar.gz"
        PACKAGE_HGPROXY="$SCRIPT_DIR/x86_64/hgproxy4.0.28-fdd2553-20240514.x86_64.tar.gz"
        PACKAGE_POSTGIS="$SCRIPT_DIR/x86_64/postgis340-hgdb-see-4.5.10-a64a611-20240426.x86_64.tar.gz"
        ;;
    armv7l)
        PACKAGE_HGDB="package-armv7l.deb"
        ;;
    loongarch64)
        #PACKAGE_HGDB="$SCRIPT_DIR/loongarch64/hgdb-see-4.5.8.6-195675f-20240822.loongarch64.tar.gz"
        PACKAGE_HGDB="$SCRIPT_DIR/loongarch64/hgdb-see-4.5.10-a64a611-20240426.loongarch64.tar.gz"
        PACKAGE_HGHAC="$SCRIPT_DIR/loongarch64/hghac-loongarch64.tar.gz"
        PACKAGE_HGPROXY="$SCRIPT_DIR/loongarch64/hgproxy-loongarch64.tar.gz"
        PACKAGE_POSTGIS="$SCRIPT_DIR/loongarch64/postgis310-hgdb-see-4.5.10-a64a611-20240426.loongarch64.tar.gz"
        ;;
    aarch64)
        PACKAGE_HGDB="$SCRIPT_DIR/arm64/hgdb-see-4.5.10-a64a611-20240426.aarch64.tar.gz"
        PACKAGE_HGHAC="$SCRIPT_DIR/arm64/hghac4.2.3.3-see-17f931d-20240617.aarch64.tar.gz"
        PACKAGE_HGPROXY="$SCRIPT_DIR/arm64/hgproxy4.0.28-fdd2553-20240514.aarch64.tar.gz"
        PACKAGE_POSTGIS="$SCRIPT_DIR/arm64/postgis340-hgdb-see-4.5.10-a64a611-20240426.aarch64.tar.gz"
        ;;
    i686)
        PACKAGE_HGDB="package-i686.deb"
        ;;
    *)
        echo "未识别的架构: $ARCH"
        exit 1
        ;;
esac

# 引入目录管理脚本
# 安装目录：数据库软件，集群高可用软件，管理工具等
source $SCRIPT_DIR/hgdb-see-shells/set_dirs.sh

# 引入安装脚本 installs 文件
# 安装软件：数据库，高可用，管理工具等
source $SCRIPT_DIR/hgdb-see-shells/installs.sh

# 引入 pgpass 文件的操作功能
# 免密登录文件，定时备份需要
source $SCRIPT_DIR/hgdb-see-shells/set_pgpassfile.sh

# SSL 证书
# 安全版默认要开启 SSL 功能，必须要有证书
source $SCRIPT_DIR/hgdb-see-shells/install_ssl_certificate.sh

# 引入环境变量设置功能
# 环境变量：数据库相关二进制，数据等的路径
source $SCRIPT_DIR/hgdb-see-shells/set_env_variables.sh

# 引入 set_db_parameter.sh 文件
# 数据库服务运行参数的设置函数，便于微调参数
source $SCRIPT_DIR/hgdb-see-shells/set_db_parameter.sh

# 引入 running_control.sh 文件
# 数据库服务的启动关闭等操作
source $SCRIPT_DIR/hgdb-see-shells/running_control.sh

# 引入 service_control.sh 文件
source $SCRIPT_DIR/hgdb-see-shells/service_control.sh

# 检查是否为 root 用户
function check_user() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "警告：当前用户是 root，建议新建一个非 root 用户进行安装。"
        read -p "是否继续以 root 用户身份安装？(Y/N): " choice
        case "$choice" in
            [Yy]* )
                echo "继续以 root 用户身份安装..."
                ;;
            [Nn]* )
                echo "安装已取消。请切换到非 root 用户后重新运行此脚本。"
                exit 1
                ;;
            * )
                echo "无效输入！安装已取消。"
                exit 1
                ;;
        esac
    fi
}


# 安装授权文件并检查安装结果
function install_and_check_license() {
    # s授权文件默认放到当前目录
    local license_file="${lic_file}"

    echo "正在修改授权文件权限..."

    # 修改授权文件权限
    chmod 0600 "$license_file"

    # 检查权限修改是否成功
    if [ $? -eq 0 ]; then
        echo "授权文件权限修改成功。"
    else
        echo "授权文件权限修改失败。" >&2
        return 1
    fi

    echo "正在安装授权文件..."

    # 安装授权文件
    $HGBINPATH/hg_lic -l -F "$license_file"

    # 检查授权文件安装是否成功
    if [ $? -eq 0 ]; then
        echo "授权文件安装成功。"
    else
        echo "授权文件安装失败。" >&2
        return 1
    fi

    echo "正在确认安装结果..."

    # 确认安装结果
    $HGBINPATH/hg_lic

    # 检查确认命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "授权文件已成功确认。"
    else
        echo "授权文件确认失败。" >&2
        return 1
    fi
}

# 安装 PostgreSQL
function install_pgsql() {
    # 在此添加 PostgreSQL 安装逻辑
    echo "PostgreSQL 安装完成。"
}

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


# 客户端验证（HBA）
# 更新 pg_hba.conf 文件，添加客户端验证策略
function hba() {
    # 定义 pg_hba.conf 文件路径
    pg_hba_file=${HGDATA:-$PGDATA}/pg_hba.conf

    # 检查 pg_hba.conf 文件是否存在
    if [ ! -f "$pg_hba_file" ]; then
        echo "pg_hba.conf 文件不存在，路径：$pg_hba_file" >&2
        exit 1
    fi

    # 追加内容到 pg_hba.conf 文件
    echo "正在更新 pg_hba.conf 文件..."
    tee -a "$pg_hba_file" <<-EOF
# BEGIN_HIGHGO_CFG
# IPv4 local connections:
host    all             all             0.0.0.0/0               ${auth_method}
# END_HIGHGO_CFG
EOF

    if [ $? -eq 0 ]; then
        echo "pg_hba.conf 文件更新成功，路径：$pg_hba_file。"
    else
        echo "pg_hba.conf 文件更新失败。" >&2
        exit 1
    fi
}

# 设置数据库系统参数
function set_db_parameters() {
    echo "正在设置数据库系统参数..."

    # 使用 psql 执行一系列 SQL 命令来设置参数
    $HGBINPATH/psql highgo sysdba <<-EOF
alter system set listen_addresses = '*';
alter system set max_connections = 2000;
alter system set work_mem='16MB';
alter system set shared_buffers = '${buffer_shared}';
alter system set checkpoint_completion_target = 0.8;
alter system set log_destination = 'csvlog';
alter system set logging_collector = on;
alter system set log_directory = 'hgdb_log';
alter system set log_filename = 'highgodb_%d.log';
alter system set log_rotation_age = '1d';
alter system set log_rotation_size = 0;
alter system set log_truncate_on_rotation = on;
alter system set log_statement = 'ddl';
alter system set log_connections = on;
alter system set log_disconnections = on;
alter system set checkpoint_timeout = '30min';
alter system set maintenance_work_mem = '1GB';
alter system set archive_mode = ${archive_mode};
alter system set archive_timeout = '30min';
alter system set archive_command = 'cp %p ${archive_dir}/%f';
alter system set log_line_prefix = '%m [%p] %a %u %d %r %h';
alter system set nls_length_semantics = 'char'; 
EOF

    # 检查命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "数据库系统参数设置成功。"
    else
        echo "数据库系统参数设置失败。" >&2
        return 1
    fi
}


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

# 设置数据库安全参数
function set_security_parameters() {
    local db_name="highgo"  # 数据库名称
    local db_user="syssso"  # 用户名

    echo "正在设置数据库安全参数..."

    # 使用 psql 执行安全参数设置的 SQL 命令
    $HGBINPATH/psql $db_name $db_user <<-EOF
SELECT set_secure_param('hg_macontrol','min');
SELECT set_secure_param('hg_rowsecure','off');
SELECT set_secure_param('hg_showlogininfo','off');
SELECT set_secure_param('hg_clientnoinput','0');
SELECT set_secure_param('hg_idcheck.pwdpolicy','high');
EOF

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

# 定时备份
function backup_schedule(){
    # 在此添加函数逻辑
    echo "定时备份设置完成。"
}

# 自启动任务
function install_service(){
    # 在此添加函数逻辑
    echo "自启动服务设置完成。"
}

# 生成卸载脚本
function generate_uninstall_script() {
    # 在此添加卸载脚本生成逻辑
    echo "卸载脚本生成完成。"
}

# 卸载
function uninstall_pgsql() {
    # 在此添加卸载逻辑
    echo "PostgreSQL 卸载完成。"
}

# 询问是否继续安装的函数
function ask_continue() {
    while true; do
        read -p "是否继续安装其他组件？ (y/n): " yn
        case $yn in
            [Yy]* )
                echo "继续安装其他组件..."
                main_menu
                ;;
            [Nn]* )
                echo "退出安装..."
                exit 0
                ;;
            * )
                echo "无效输入，请输入 y 或 n。"
                ;;
        esac
    done
}

# 主菜单
function main_menu() {
    echo "请选择操作："
    echo "1. 单机一键部署"
    #echo "2. 单机交互式部署"
    echo "3. 安装 PostGIS 插件"
    #echo "4. 安装集群软件 HGHAC"
    #echo "5. 安装读写分离软件 HGPROXY"
    #echo "6. 高可用一发入魂"
    #echo "7. 备份定时任务"
    #echo "8. 自启动服务"
    echo "9. 卸载"
    echo "0. 返回主菜单"
    echo "q. 退出"
    read -p "请输入您的选择 [0-9, q]: " choice

    case $choice in
        1)
            check_install_dir
            install_hgdb
            set_env_variables
            init_db
            install_ssl_certificate
            add_pgpassfile
            hba
            running_control start
            set_db_parameters
            set_db_password_and_update_pgpass
            running_control restart
            set_security_parameters
            running_control restart
            generate_uninstall_script
            disable_audit
            install_and_check_license
            running_control restart
            running_control stop
            setup_service
            echo "瀚高数据库${HGDB_VERSION} 一键部署完成！"
            ask_continue
            ;;
        2)
            echo "瀚高数据库${HGDB_VERSION} 交互式部署完成！"
            ask_continue
            ;;
        3)
            install_postgis
            ask_continue
            ;;
        4)
            install_hghac
            ask_continue
            ;;
        5)
            install_hgproxy
            ask_continue
            ;;
        8)
            setup_service
            ask_continue
            ;;
        9)
            uninstall_service
            unset_env_variables
            remove_pgpassfile
            backup_dirs
            remove_dirs
            remove_install_dir
            ask_continue
            ;;
        0)
            echo "返回主菜单..."
            main_menu
            ;;
        q)
            echo "退出..."
            exit 0
            ;;
        *)
            echo "无效选择！退出..."
            exit 1
            ;;
    esac
}

# 脚本入口
check_user
main_menu
