# install_ssl_certificate.sh

# 安装 SSL 证书
# 数据目录：DATA_DIR
function install_ssl_certificate() {
    # 执行 hg_sslkeygen.sh 生成 SSL 证书
    $HGBINPATH/hg_sslkeygen.sh "$DATA_DIR"

    # 判断命令是否成功
    if [ $? -ne 0 ]; then
        echo "SSL 证书生成失败，正在解压备用证书..."
        # 解压 tar.gz 证书文件到 data 目录
        tar -xzf $SCRIPT_DIR/crts100.tar.gz -C "$DATA_DIR"
        if [ $? -eq 0 ]; then
            echo "备用证书解压成功。"
        else
            echo "备用证书解压失败，请检查证书文件。" >&2
            exit 1
        fi
    else
        echo "SSL 证书生成成功。"
    fi
}
