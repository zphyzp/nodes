

## 修改root密码和解除账户锁定

### 1.进入控制台

```shell
gitlab-rails console -e production
或
gitlab-rails console production
```

### 2.找到用户并重置密码并保存

```shell
#找到用户
user = User.where(id: 1).first
或者
user = User.find_by(email: ‘admin@local.host‘)

#更改密码
user.password = ‘secret_pass‘
user.password_confirmation = ‘secret_pass‘

#保存
user.save!
=> true
```

### 3.如果用户锁住可解锁用户

```shell
irb(main):012:0> user=User.where(email:'jenkins@domain.com').first
=> #<User id:22 @jenkins>
irb(main):013:0> user.unlock_access!
=> true
irb(main):014:0> 
```

普罗米修斯监控告警已通知相关技术负责人并处理完成。

对机关事务云平台运维人员进行gitlab文档管理的相关培训。

## git回滚操作（本地仓库）

```shell
git reset --hard HEAD^ #回到上一个版本
git reset --hard HEAD^^ #回到上上一个版本

git log #查看commit日志，确定id号
git reset --hard 18db613 #回滚到指定id版本
```

## gitlab的备份与恢复

### 备份

#### 1、备份前停止服务

```shell
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
```

#### 2、手动备份数据

```shell
#手动备份
gitlab-rake gitlab:backup:create
#启动服务
gitlab-ctl start
```

#### 3、查看备份文件

```shell
#备份目录（默认）
/var/opt/gitlab/backups/
/etc/gitlab/gitlab-secrets.json #key文件

#查看备份
$ ls -l /var/opt/gitlab/backups/
1618450839_2021_04_15_12.10.14_gitlab_backup.tar #1618450839为unix时间戳，可上网转化时间戳以查看具体时间
```

### 恢复

#### 1、恢复前停止服务

```shell
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
```

#### 2、恢复数据

```shell
#指定配置文件恢复数据
gitlab-rake gitlab:backup:restore BACKUP=1618451992_2021_04_15_12.10.14

#启动服务
gitlab-ctl start
```

## 