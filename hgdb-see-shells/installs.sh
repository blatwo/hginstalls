# installs.sh

# 安装数据库软件
function install_hgdb() {
    # 安装对应的包
    echo "安装数据库软件： $PACKAGE_HGDB..."
    echo "开始解压缩至目录 ${INSTALL_DIR} ............."
    tar -xzf ${PACKAGE_HGDB} -C ${INSTALL_DIR}
    # 创建 data 目录软链接
    ln -vsf ${DATA_DIR} ${HGDATA}
}

# 安装集群软件 HGHAC
function install_hghac() {
    # 安装对应的包
    echo "安装集群软件 HGHAC： $PACKAGE_HGHAC"
    echo "开始解压缩至目录 ${INSTALL_DIR} ............."
    tar -xzf ${PACKAGE_HGHAC} -C ${INSTALL_DIR}
}

# 安装读写分离软件 HGPROXY
function install_hgproxy() {    
    # 安装对应的包
    echo "安装读写分离软件 HGPROXY： $PACKAGE_HGPROXY..."
    echo "开始解压缩至目录 ${INSTALL_DIR} ............."
    tar -xzf ${PACKAGE_HGPROXY} -C ${INSTALL_DIR}
}

# 安装 PostGIS 插件
function install_postgis() {    
    # 安装对应的包
    echo "安装 PostGIS 插件： $PACKAGE_POSTGIS..."
    echo "开始解压缩至目录 ${INSTALL_DIR} ............."
    tar -xzf ${PACKAGE_POSTGIS} -C ${HGBASE}
}
