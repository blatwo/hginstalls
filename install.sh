#!/bin/bash
set -euo pipefail

# ANSI 颜色定义
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly RESET='\033[0m'

# 瀚高数据库软件版本
readonly HGDB_VERSION="hgdb-see-4.5.10"
readonly HGHAC_VERSION="hghac-x.x.x"
readonly HGPROXY_VERSION="hgproxy-x.x.x"

# 当前系统 CPU 的架构
readonly ARCH=$(uname -m)

# 执行脚本的用户名和主用户组
readonly USER_NAME=$(id -un)
readonly USER_GROUP=$(id -gn)

# 获取执行该 SHELL 的用户对应的主目录
readonly USER_HOME=$HOME

# 当前脚本的目录
readonly SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 安装包目录
#readonly PKG_DIR=$(dirname "$(realpath "$0")")
readonly PKG_DIR=$HOME/hgdb-sees

# 解析执行 RUN 文件时输入的自定义参数
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
# 数据库实例的 DATA 目录的物理路径。默认是当前用户主目录下的 data 目录。
DATA_DIR=${data_dir:-${USER_HOME}/data}
# 数据库备份路径。默认是当前用户主目录下的 hgdbbak 目录。
BAKUP_DIR=${bakup_dir:-${USER_HOME}/hgdbbak}
# 归档模式，默认开启（on）
ARCHIVE_MODE=${archive_mode:-on}
# 归档目录，默认是当前用户目录下的 hgdbbak/archive。
ARCHIVE_DIR=${archive_dir:-${USER_HOME}/hgdbbak/archive}
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
SERVICE_NAME_HGDB=${HGDB_VERSION:-hgdb}
SERVICE_NAME_ETCD=${HGDB_VERSION:-etcd}
SERVICE_NAME_HGHAC=${HGDB_VERSION:-hghac}
SERVICE_NAME_HGPROXY=${HGDB_VERSION:-hgproxy}
# 用户定义的服务建议存放到 /etc/systemd/system/ 目录下
DB_SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME_HGDB}.service"

# 根据架构选择对应的包名
case "$ARCH" in
    x86_64)
        #PACKAGE_HGDB="$SPKG_DIR/x86_64/hgdb-see-4.5.8.5-f0671cf.x86_64.tar.gz"
        PACKAGE_HGDB="$PKG_DIR/x86_64/hgdb-see-4.5.10-a64a611-20240426.x86_64.tar.gz"
        PACKAGE_HGHAC="$PKG_DIR/x86_64/hghac4.2.3.3-see-17f931d-20240620.x86_64.tar.gz"
        PACKAGE_HGPROXY="$PKG_DIR/x86_64/hgproxy4.0.28-fdd2553-20240514.x86_64.tar.gz"
        PACKAGE_POSTGIS="$PKG_DIR/x86_64/postgis340-hgdb-see-4.5.10-a64a611-20240426.x86_64.tar.gz"
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

# 打印标题
echo -e "${CYAN}======================================================${RESET}"
echo -e "${CYAN}  系统环境信息  ${RESET}"
echo -e "${CYAN}======================================================${RESET}"

# 打印全局变量信息
echo -e "${GREEN}瀚高数据库版本       ${YELLOW}: ${RESET}${HGDB_VERSION}"
echo -e "${GREEN}系统架构             ${YELLOW}: ${RESET}${ARCH}"
echo -e "${GREEN}脚本目录             ${YELLOW}: ${RESET}${SCRIPT_DIR}"
echo -e "${GREEN}软件包目录           ${YELLOW}: ${RESET}${PKG_DIR}"
echo -e "${GREEN}当前用户             ${YELLOW}: ${RESET}${USER_NAME}"
echo -e "${GREEN}当前用户组           ${YELLOW}: ${RESET}${USER_GROUP}"
echo -e "${GREEN}用户主目录           ${YELLOW}: ${RESET}${USER_HOME}"

# 打印结束线
echo -e "${CYAN}======================================================${RESET}"


# 引入目录管理脚本
# 安装目录：数据库软件，集群高可用软件，管理工具等
source $SCRIPT_DIR/hgdb-see-shells/set_dirs.sh

# 引入安装脚本 installs 文件
# 安装软件：数据库，高可用，管理工具等
source $SCRIPT_DIR/hgdb-see-shells/installs.sh

# 初始化数据库
source $SCRIPT_DIR/hgdb-see-shells/init_db.sh

# HBA 客户端验证策略
source $SCRIPT_DIR/hgdb-see-shells/hba.sh

# 设置数据库基本参数、安全参数、审计开关
source $SCRIPT_DIR/hgdb-see-shells/set_db_parameters.sh

# 引入 pgpass 文件的操作功能
# 免密登录文件，定时备份需要
source $SCRIPT_DIR/hgdb-see-shells/set_pgpassfile.sh

# 更新密码为永久有效期
source $SCRIPT_DIR/hgdb-see-shells/set_db_password.sh

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

# 授权安装和检查
source $SCRIPT_DIR/hgdb-see-shells/install_and_check_license.sh

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
            check_install_dir	#检查目录并创建相关目录
            install_hgdb	#安装瀚高数据库软件
            set_env_variables	#设置环境变量
            init_db		#初始化数据库实例
            install_ssl_certificate	#安装SSL证书
            add_pgpassfile		#添加pgpass文件
            hba				#配置HBA客户端验证
            running_control start	#启动数据库服务
            set_db_parameters		#设置数据库基本参数
            set_db_password_and_update_pgpass	#更新密码策略和用户密码
            running_control restart		#重启数据库服务
            set_security_parameters		#设置安全参数
            running_control restart		#重启数据库服务
            generate_uninstall_script		#
            disable_audit			#停用审计功能
            install_and_check_license		#安装授权
            running_control restart		#重启数据库服务
            running_control stop		#停止数据库服务
	    setup_service_hgdb		#配置自启动服务(systemd)
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
            remove_service ${SERVICE_NAME_HGDB}
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
