# set_env_variables.sh

# 设置环境变量
set_env_variables() {
    # 定义要添加的环境变量内容
    env_content="# BEGIN_HIGHGO_CFG
export HG_BASE=$INSTALL_DIR
export HGDB_HOME=\$HG_BASE/$HGDB_VERSION
export PGPORT=5866
export PGDATABASE=highgo
export PATH=\$HGDB_HOME/bin:\$PATH
export PGDATA=\$HGDB_HOME/data
# END_HIGHGO_CFG"

    # 获取当前用户的 home 目录
    user_home=$(eval echo ~$USER)

    # 优先选择 .bashrc
    if [ -f "$user_home/.bashrc" ]; then
        target_file="$user_home/.bashrc"
    elif [ -f "$user_home/.bash_profile" ]; then
        target_file="$user_home/.bash_profile"
    else
        echo "找不到 .bashrc 或 .bash_profile 文件，无法自动设置环境变量。请手动添加以下内容到你的 shell 配置文件中："
        echo "$env_content"
        return 1
    fi

    # 将环境变量写入配置文件
    if grep -q "BEGIN_HIGHGO_CFG" "$target_file"; then
        echo "环境变量已经配置过，跳过设置。"
    else
        echo "$env_content" >> "$target_file"
        echo "环境变量已成功添加到 $target_file 中，正在使配置生效...安装完成后请运行 'source $target_file' 以使配置生效。"
    fi
    source "$target_file"  # 立即生效
    echo "配置已生效。"
}

# 删除环境变量
unset_env_variables() {
    # 获取当前用户的 home 目录
    user_home=$(eval echo ~$USER)

    # 优先选择 .bashrc
    if [ -f "$user_home/.bashrc" ]; then
        target_file="$user_home/.bashrc"
    elif [ -f "$user_home/.bash_profile" ]; then
        target_file="$user_home/.bash_profile"
    else
        echo "找不到 .bashrc 或 .bash_profile 文件，无法自动删除环境变量。请手动删除 shell 配置文件中的环境变量。"
        return 1
    fi

    # 检查并删除环境变量部分
    if grep -q "BEGIN_HIGHGO_CFG" "$target_file"; then
        # 删除 BEGIN_HIGHGO_CFG 和 END_HIGHGO_CFG 之间的内容
        sed -i '/# BEGIN_HIGHGO_CFG/,/# END_HIGHGO_CFG/d' "$target_file"
        echo "环境变量已从 $target_file 中删除。"
    else
        echo "未找到相关的环境变量配置，跳过删除。"
    fi

    source "$target_file"  # 立即生效
    echo "配置已更新并生效。"
}

