# set_dirs.sh

# 检查并准备安装目录
# 软件安装目录：INSTALL_DIR
# 数据库安装目录：HGBASE
# 数据目录：DATA_DIR
# 备份目录：BAKUP_DIR
# 归档目录：archive_dir
function check_install_dir() {
    # 确保 INSTALL_DIR, DATA_DIR, archive_dir 已被初始化
    if [ -z "$INSTALL_DIR" ] || [ -z "$DATA_DIR" ] || [ -z "$archive_dir" ]; then
        echo "One or more required directories are not set." >&2
        exit 1
    fi

    echo "Install directory: ${INSTALL_DIR}"
    echo "Data directory: ${DATA_DIR}"
    echo "Backup directory: ${BAKUP_DIR}"
    echo "Archive directory: ${archive_dir}"

    # 判断安装目录是否存在
    if [ -d "$INSTALL_DIR" ]; then
        echo "Directory $INSTALL_DIR exists."
        # 判断是否有读写权限
        if [ -r "$INSTALL_DIR" ] && [ -w "$INSTALL_DIR" ]; then
            echo "You have read and write permissions for $INSTALL_DIR."
        else
            echo "You do NOT have sufficient permissions for $INSTALL_DIR." >&2
            exit 1
        fi
    else
        echo "Directory $INSTALL_DIR does not exist. Creating it now..."
        if ! sudo mkdir -p "$INSTALL_DIR"; then
            echo "Failed to create install directory." >&2
            exit 1
        fi
        echo "Install directory created successfully."
    fi

    # 判断数据目录是否存在，不存在则创建
    if [ ! -d "$DATA_DIR" ]; then
        echo "Data directory $DATA_DIR does not exist. Creating it now..."
        if ! mkdir -p "$DATA_DIR"; then
            echo "Failed to create data directory." >&2
            exit 1
        fi
        echo "Data directory $DATA_DIR created successfully."
    else
        echo "Data directory $DATA_DIR already exists."
    fi

    # 判断备份目录是否存在，不存在则创建
    if [ ! -d "$BAKUP_DIR" ]; then
        echo "Backup directory $BAKUP_DIR does not exist. Creating it now..."
        if ! mkdir -p "$BAKUP_DIR"; then
            echo "Failed to create backup directory." >&2
            exit 1
        fi
        echo "Backup directory created successfully."
    else
        echo "Backup directory $BAKUP_DIR already exists."
    fi
    
    # 判断归档目录是否存在，不存在则创建
    if [ ! -d "$archive_dir" ]; then
        echo "Archive directory $archive_dir does not exist. Creating it now..."
        if ! mkdir -p "$archive_dir"; then
            echo "Failed to create archive directory." >&2
            exit 1
        fi
        echo "Archive directory created successfully."
    else
        echo "Archive directory $archive_dir already exists."
    fi
        
}

# 备份数据目录和归档目录
function backup_dirs() {
    # 备份数据目录
    if [ -d "$DATA_DIR" ]; then
        backup_data_dir="${DATA_DIR}_backup_$(date +%Y%m%d%H%M%S)"
        echo "Backing up data directory to $backup_data_dir ..."
        if cp -r "$DATA_DIR" "$backup_data_dir"; then
            echo "Backup of data directory successful: $backup_data_dir"
        else
            echo "Backup of data directory failed." >&2
            exit 1
        fi
    else
        echo "Data directory does not exist. Nothing to back up."
    fi

    # 备份备份目录
    if [ -d "$BAKUP_DIR" ]; then
        backup_backup_dir="${BAKUP_DIR}_backup_$(date +%Y%m%d%H%M%S)"
        echo "Backing up backup directory to $backup_backup_dir ..."
        if cp -r "$BAKUP_DIR" "$backup_backup_dir"; then
            echo "Backup of backup directory successful: $backup_backup_dir"
        else
            echo "Backup of backup directory failed." >&2
            exit 1
        fi
    else
        echo "Backup directory does not exist. Nothing to back up."
    fi

    # 备份归档目录
    if [ -d "$archive_dir" ]; then
        backup_archive_dir="${archive_dir}_backup_$(date +%Y%m%d%H%M%S)"
        echo "Backing up archive directory to $backup_archive_dir ..."
        if cp -r "$archive_dir" "$backup_archive_dir"; then
            echo "Backup of archive directory successful: $backup_archive_dir"
        else
            echo "Backup of archive directory failed." >&2
            exit 1
        fi
    else
        echo "Archive directory does not exist. Nothing to back up."
    fi
}

# 删除数据目录和归档目录
function remove_dirs() {
    # 删除数据目录
    if [ -d "$DATA_DIR" ]; then
        echo "Are you sure you want to delete the data directory $DATA_DIR? This action cannot be undone! (yes/no)"
        read confirmation
        if [ "$confirmation" == "yes" ]; then
            echo "Deleting data directory $DATA_DIR ..."
            if rm -rf "$DATA_DIR"; then
                echo "Data directory deleted successfully."
            else
                echo "Failed to delete data directory." >&2
                exit 1
            fi
        else
            echo "Deletion of data directory aborted."
        fi
    else
        echo "Data directory $DATA_DIR does not exist. Nothing to delete."
    fi

    # 删除归档目录
    if [ -d "$archive_dir" ]; then
        echo "Are you sure you want to delete the archive directory $archive_dir? This action cannot be undone! (yes/no)"
        read confirmation
        if [ "$confirmation" == "yes" ]; then
            echo "Deleting archive directory $archive_dir ..."
            if rm -rf "$archive_dir"; then
                echo "Archive directory deleted successfully."
            else
                echo "Failed to delete archive directory." >&2
                exit 1
            fi
        else
            echo "Deletion of archive directory aborted."
        fi
    else
        echo "Archive directory does not exist. Nothing to delete."
    fi

    # 删除备份目录
    if [ -d "$BAKUP_DIR" ];then
        echo "Are you sure you want to delete the backup directory $BAKUP_DIR? This action cannot be undone! (yes/no)"
        read confirmation
        if [ "$confirmation" == "yes" ]; then
            echo "Deleting backup directory $BAKUP_DIR ..."
            if rm -rf "$BAKUP_DIR"; then
                echo "Backup directory deleted successfully."
            else
                echo "Failed to delete backup directory." >&2
                exit 1
            fi
        else
            echo "Deletion of backup directory aborted."
        fi
    else
        echo "Backup directory does not exist. Nothing to delete."
    fi
}

# 删除安装目录下安装的文件
function remove_install_dir() {
    # 删除已安装的数据库软件
    if [ -d "$HGBASE" ]; then
        echo "Are you sure you want to delete the install directory $HGBASE? This action cannot be undone! (yes/no)"
        read confirmation
        if [ "$confirmation" == "yes" ]; then
            echo "Deleting install directory $HGBASE ..."
            if sudo rm -rf "$HGBASE"; then
                echo "Install directory deleted successfully."
            else
                echo "Failed to delete install directory." >&2
                exit 1
            fi
        else
            echo "Deletion of install directory aborted."
        fi
    else
        echo "Install directory does not exist. Nothing to delete."
    fi
}

