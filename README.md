## README.md
### 安装前提
1. 建议创建一个操作系统用户，如：`highgo`（推荐）。也可以直接安装到 root 用户；
2. 指定软件安装目录，如：`/opt/highgo`，需要 root 用户操作或对`/opt`目录有创建目录权限的普通用户，提前将权限问题解决好；
3. 指定数据存放目录，同样需要将权限问题解决好，建议使用外部大磁盘挂载目录；
4. 访问安全策略，开放指定端口，如：5866（默认）；

### 01. 创建 OS 用户
登录 `root` 用户，创建用户组`highgo`以及新用户`highgo`：

```bash
sudo groupadd highgo
sudo useradd -m -g highgo -s /bin/bash -c "Highgo DataBase" highgo
echo "highgo:Hgdb@123" | sudo chpasswd
```

:::info
![](https://cdn.nlark.com/yuque/0/2024/bmp/40571765/1712132641909-f6037439-6ad0-41c2-8bc4-2ec013a84841.bmp?x-oss-process=image%2Fformat%2Cwebp%2Fresize%2Cw_16%2Climit_0%2Fresize%2Cw_16%2Climit_0)**说明**：

1. 参数`-c` 填写的是用户描述，如：<font style="color:rgb(55, 65, 81);">用途</font>；
2. 命令 `echo` 后面是密码，当前设置“Hgdb@123”。个别操作系统（如：麒麟 v10 sp3/openEuler）的密码可能有限制，到时候根据密码复杂度设置情况（参考密码：`Hello@hg.com`）。

:::

在 `/etc/sudoers.d/` 目录下为 `highgo` 用户创建一个单独的文件：

```bash
echo 'highgo ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/highgo
```

出于安全性考虑，尽量不要设置无需密码，可以去掉`NOPASSWD:`。

确保文件的权限是 0440：

```bash
sudo chmod 0440 /etc/sudoers.d/highgo
```

切到用户 `highgo` 下：

```bash
sudo su - highgo
```

### 02. 安装目录
例如，你要安装到`/opt`下，那你就需要创建 OS 用户 `highgo` 的目录：

```bash
sudo mkdir -p /opt/highgo/
sudo chown -R highgo:highgo /opt/highgo
```

如果不指定，默认将安装到当前用户的主目录下。如：`/root` 或 `/home/highgo`。

### 03. 数据目录
数据目录主要存放重要的数据，例如整个 DATA 目录或者备份目录。DATA 目录创建命令如下：

```bash
sudo mkdir -p /data/highgo/data
sudo chown -R highgo:highgo /data
```

如果不指定默认是用户主目录下的 `data `目录，如：`/root/data`或`/home/highgo/data`。

备份目录

```bash
sudo mkdir -p /data/highgo/hgdbbak/archive
sudo chown -R highgo:highgo /data/highgo/hgdbbak
```

### 03. 上传授权
授权文件名 `hgdb_0_t.lic`，尽量不要改名字。推荐传到当前用户的主目录下，这样默认会自动识别。也可以放到其他目录，但安装的时候需要通过选项指定这个目录。

:::info
![](https://cdn.nlark.com/yuque/0/2024/bmp/40571765/1712132641909-f6037439-6ad0-41c2-8bc4-2ec013a84841.bmp?x-oss-process=image%2Fformat%2Cwebp%2Fresize%2Cw_16%2Climit_0%2Fresize%2Cw_16%2Climit_0)**提示**

也可以忽略授权这一步，后面单独使用数据库命令安装也可以。

:::

### 04. 安装
将安装文件`hgdb-see-4.5.10.run`上传到当前用户主目录下。

修改可执行属性，确保可以直接执行，如：

```bash
sudo chmod a+x hgdb-see-4.5.10.run
```

**默认安装**

```bash
./hgdb-see-4.5.10.run
```

默认值说明：

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `--password` | `Hello@1234` | 设置数据库管理员的初始密码。 |
| `--auth-method` | `md5` | 指定数据库的身份验证方法，可以是 `md5`，`sm3` 等。注意使用 `sm3` 需要更换瀚高的驱动。 |
| `--archive-mode` | `off` | 设置数据库的归档是否开启，开启 `on` 关闭 `off`。关闭归档模式，数据库不生成 WAL 归档文件。生产环境建议开启。 |
| `--buffer-shared` | `2GB` | 设置数据库的共享缓冲区大小。一般分配 1/4 物理内存。 |
| `--lic` | `$HOME/hgdb_0_t.lic` | 指定数据库软件的授权文件路径。默认是当前目录下，所以你可以将授权文件放到当前目录，且命名为`hgdb_0_t.lic`。 |
| `--install-dir` | `/opt/highgo` | 指定数据库软件的安装目录，此目录将是数据库、集群，读写分离等软件的安装目录。默认值`/opt/highgo`。 |
| `--data-dir` | `$HOME/data` | 指定数据库的数据目录，所有数据库相关的数据文件将存储在此路径下。通常会指定为较大的挂载磁盘目录。例如：`/mount_dir/highgo/data`。 |
| `--archive-dir` | `$HOME/hgdbbak/archive` | 指定数据库的归档文件目录。用于存放数据库归档日志文件的目录（如果启用了归档模式）。如果事务比较频繁，该目录可能会变的很大，通常也是放到较大的挂载目录。例如：`/mount_dir/highgo/hgdbbak/archive`。 |


参数化安装

```bash
./hgdb-see-4.5.10.run -- --password Hello@12345 \
                         --auth-method md5 \
                         --archive-mode off \
                         --buffer-shared 2GB \
                         --lic /home/highgo/hgdb_0_t.lic \
                         --install-dir /home/highgo \
                         --data-dir /home/highgo/data \
                         --archive-dir /home/highgo/hgdbbak/archive
```

如果想再次执行，得找到解压目录，例如指定了/tmp/hgsofts：

```bash
/tmp/hgsofts/install.sh  --password Hello@12345 \
                         --auth-method md5 \
                         --archive-mode off \
                         --buffer-shared 2GB \
                         --lic /home/highgo/hgdb_0_t.lic \
                         --install-dir /home/highgo \
                         --data-dir /home/highgo/data \
                         --archive-dir /home/highgo/hgdbbak/archive
```

以下是对命令 `./hgdb-see-4.5.10.run` 各参数的说明：

示例：

```bash
./hgdb-see-4.5.10.run -- --password Hello@12345 \
                         --auth-method md5 \
                         --archive-mode off \
                         --buffer-shared 2GB \
                         --data-dir /data/highgo/data \
                         --bakup-dir /data/highgo/hgdbbak \
                         --archive-dir /data/highgo/hgdbbak/archive
```

没有指定参数`--install-dir`，将会默认安装到 `/opt/highgo` 下，你需要提前建好此目录并赋予必要的访问权限。

### 卸载
#### 停服
```bash
pg_ctl stop
sudo systemctl stop hgdb-see-4.5.10
```

#### 备份数据
```bash
# 备份命令

```

#### 删除相关目录
```bash
sudo rm -fr $HG_BASE
rm -fr data hgdbbak
```

或者只删除安装目录下的文件

```bash
sudo rm -fr $HG_BASE/*
```

#### 删除服务
```bash
sudo systemctl diable hgdb-see-4.5.10
```

#### 清理环境变量
```bash
sed -i '/# BEGIN_HIGHGO_CFG/,/# END_HIGHGO_CFG/d' /home/highgo/.bashrc
```

#### 删除密码文件
```bash
rm -fr .pgpass
```

#### 删除用户
要彻底删除已创建的用户 `highgo`，可以按照以下步骤进行操作：

1. **删除用户：**使用 `userdel` 命令来删除用户 `highgo`。其中，`-r` 选项用于删除用户的主目录以及主目录中的所有文件。

```bash
sudo userdel -r highgo
```

2. **删除组（如果不再需要）：**如果该用户的组 `highgo` 不再需要，可以使用 `groupdel` 命令删除该组。

```bash
sudo groupdel highgo
```

3. 删除 sudoer 设置：

```bash
rm -fr /etc/sudoers.d/highgo
```

4. **检查并删除残留文件：**用户删除后，有时在其他位置可能还有残留的文件或配置。可以通过以下命令检查是否有与该用户相关的残留文件，并手动清理：

```bash
sudo find / -name "*highgo*" -exec rm -rf {} \;
```

执行完上述步骤后，`highgo` 用户及其相关的所有文件和组将被彻底删除。

