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
