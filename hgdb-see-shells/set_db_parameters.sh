
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
