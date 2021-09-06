# 部署

## 安装gitlib

### 安装相关依赖

yum -y install policycoreutils openssh-server openssh-clients postfix

### 启动ssh服务&设置为开机启动

systemctl enable sshd && sudo systemctl start sshd

### 设置postfix开机自启，并启动，postfix支持gitlab发信功能

systemctl enable postfix && systemctl start postfix

### 开放ssh以及http服务，然后重新加载防火墙列表

firewall-cmd --add-service=ssh --permanent

firewall-cmd --add-service=http --permanent

firewall-cmd --reload

如果关闭防火墙就不需要做以上配置

### 下载gitlab包

并且安装在线下载安装包：wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el6/gitlab-ce-12.4.2-ce.0.el6.x86_64.rpm

安装：rpm -i gitlab-ce-12.4.2-ce.0.el6.x86_64.rpm

### 修改gitlab配置

```shell
vi /etc/gitlab/gitlab.rb

修改gitlab访问地址和端口，默认为80，我们改为82

external_url 'http://192.168.66.100:82'

nginx['listen_port'] = 82

 git_data_dirs({
   "default" => {
     "path" => "/data/gitlab"         #找到“git_data_dirs”下添加该值，指定存储gitlab数据
    }
 })                                    
```

#### 扩展

修改gitlab日志存放位置

```shell
#查看默认位置
[root@localhost etc]$ cat /etc/gitlab/gitlab.rb|grep log_directory
# gitlab_rails['log_directory'] = "/var/log/gitlab/gitlab-rails"
# registry['log_directory'] = "/var/log/gitlab/registry"
# gitlab_workhorse['log_directory'] = "/var/log/gitlab/gitlab-workhorse"
# unicorn['log_directory'] = "/var/log/gitlab/unicorn"
# puma['log_directory'] = "/var/log/gitlab/puma"
# sidekiq['log_directory'] = "/var/log/gitlab/sidekiq"
# gitlab_shell['log_directory'] = "/var/log/gitlab/gitlab-shell/"
# postgresql['log_directory'] = "/var/log/gitlab/postgresql"
# redis['log_directory'] = "/var/log/gitlab/redis"
# nginx['log_directory'] = "/var/log/gitlab/nginx"
# logrotate['log_directory'] = "/var/log/gitlab/logrotate"
# gitlab_pages['log_directory'] = "/var/log/gitlab/gitlab-pages"
# prometheus['log_directory'] = '/var/log/gitlab/prometheus'
# alertmanager['log_directory'] = '/var/log/gitlab/alertmanager'
# node_exporter['log_directory'] = '/var/log/gitlab/node-exporter'
# redis_exporter['log_directory'] = '/var/log/gitlab/redis-exporter'
# postgres_exporter['log_directory'] = '/var/log/gitlab/postgres-exporter'
# pgbouncer_exporter['log_directory'] = "/var/log/gitlab/pgbouncer-exporter"
# gitlab_exporter['log_directory'] = "/var/log/gitlab/gitlab-exporter"
# grafana['log_directory'] = '/var/log/gitlab/grafana'
# gitaly['log_directory'] = "/var/log/gitlab/gitaly"
# storage_check['log_directory'] = '/var/log/gitlab/storage-check'
# sidekiq_cluster['log_directory'] = "/var/log/gitlab/sidekiq-cluster"
# pgbouncer['log_directory'] = '/var/log/gitlab/pgbouncer'
# repmgr['log_directory'] = '/var/log/gitlab/repmgrd'
# consul['log_directory'] = '/var/log/gitlab/consul'

#创建与默认日志目录格式相似的目录
mkdir -p  /data/log/gitlab/alertmanager
mkdir -p  /data/log/gitlab/gitaly
mkdir -p  /data/log/gitlab/gitlab-exporter
mkdir -p  /data/log/gitlab/gitlab-rails
mkdir -p  /data/log/gitlab/gitlab-shell
mkdir -p  /data/log/gitlab/gitlab-workhorse
mkdir -p  /data/log/gitlab/grafana
mkdir -p  /data/log/gitlab/logrotate
mkdir -p  /data/log/gitlab/nginx
mkdir -p  /data/log/gitlab/node-exporter
mkdir -p  /data/log/gitlab/postgres-exporter
mkdir -p  /data/log/gitlab/postgresql
mkdir -p  /data/log/gitlab/prometheus
mkdir -p  /data/log/gitlab/reconfigure
mkdir -p  /data/log/gitlab/redis
mkdir -p  /data/log/gitlab/redis-exporter
mkdir -p  /data/log/gitlab/sidekiq
mkdir -p  /data/log/gitlab/unicorn

###备份配置文件####

#在配置文件最底下追加自定义的日志存放位置
gitlab_rails['log_directory'] = "/data/log/gitlab/gitlab-rails"  
registry['log_directory'] = "/data/log/gitlab/registry"  
gitlab_workhorse['log_directory'] = "/data/log/gitlab/gitlab-workhorse"  
unicorn['log_directory'] = "/data/log/gitlab/unicorn"  
puma['log_directory'] = "/data/log/gitlab/puma"  
sidekiq['log_directory'] = "/data/log/gitlab/sidekiq"  
gitlab_shell['log_directory'] = "/data/log/gitlab/gitlab-shell/"  
postgresql['log_directory'] = "/data/log/gitlab/postgresql"  
redis['log_directory'] = "/data/log/gitlab/redis"  
nginx['log_directory'] = "/data/log/gitlab/nginx"  
logrotate['log_directory'] = "/data/log/gitlab/logrotate"  
gitlab_pages['log_directory'] = "/data/log/gitlab/gitlab-pages"  
prometheus['log_directory'] = '/data/log/gitlab/prometheus'  
alertmanager['log_directory'] = '/data/log/gitlab/alertmanager'  
node_exporter['log_directory'] = '/data/log/gitlab/node-exporter'  
redis_exporter['log_directory'] = '/data/log/gitlab/redis-exporter'  
postgres_exporter['log_directory'] = '/data/log/gitlab/postgres-exporter'  
pgbouncer_exporter['log_directory'] = "/data/log/gitlab/pgbouncer-exporter"  
gitlab_exporter['log_directory'] = "/data/log/gitlab/gitlab-exporter"  
grafana['log_directory'] = '/data/log/gitlab/grafana'  
gitaly['log_directory'] = "/data/log/gitlab/gitaly"  
storage_check['log_directory'] = '/data/log/gitlab/storage-check'  
sidekiq_cluster['log_directory'] = "/data/log/gitlab/sidekiq-cluster"  
pgbouncer['log_directory'] = '/data/log/gitlab/pgbouncer'  
repmgr['log_directory'] = '/data/log/gitlab/repmgrd'  
consul['log_directory'] = '/data/log/gitlab/consul'

#重载配置及重新启动
gitlab-ctl reconfigure
gitlab-ctl restart
```

### 重载配置及启动

gitlab-ctl reconfigure

gitlab-ctl restart

### 把端口添加到防火墙

firewall-cmd --zone=public --add-port=82/tcp --permanent

firewall-cmd --reload



## 提交本地项目至gitlab

### windows安装git

### 提交项目至gitlab

到项目目录右键----》git bash here

执行

```shell
$ git init
$ git add .
$ git commit -m "第二次提交"
$ git config --global user.email "252275406@qq.com"
$ git config --global user.name "test"
$ git remote add origin http://192.168.123.5:82/web_demo/web_demo.git #在web的clone确定url
$ git push -u origin master 
```



## 安装jenkins

```sehll
yum install java-1.8.0-openjdk* -y

rpm -ivh jenkins-2.190.3-1.1.noarch.rpm

vi /etc/syscofig/jenkins

##修改内容如下：
JENKINS_USER="root"
JENKINS_PORT="8888"

##启动Jenkins
systemctl start jenkins

##打开浏览器访问
http://192.168.66.101:8888

##获取密码
cat /var/lib/jenkins/secrets/initialAdminPassword

```

### 替换jenkins工作目录

```shell
#安装jenkins完成后不要启动服务，先修改以下配置文件
vi /etc/sysconfig/jenkins 
JENKINS_HOME="/data/jenkins"    #修改为自己的工作目录
```





## 插件替换

```shell
cd /var/lib/jenkins/updates

sed -i 's/http:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' default.json && sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' default.json


```

把地址换成中文地址

![image-20210128165240077](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210128165240077.png)

## maven替换阿里云镜像

<mirror>
  <id>alimaven</id>
  <name>aliyun maven</name>
  <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
  <mirrorOf>cenltral</mirrorOf>
</mirror>

## 测试机安装tomcat

```shell
yum install java-1.8.0-openjdk* -y  #安装JDK（已完成）
tar -xzf apache-tomcat-8.5.47.tar.gz  #解压
mkdir -p /opt/tomcat  #创建目录
mv /root/apache-tomcat-8.5.47/* /opt/tomcat  #移动文件
/opt/tomcat/bin/startup.sh  #启动tomcat
```

## 配置tomcat用户权限

```shell
cd /opt/tomcat/conf
vi tomcat-users.xml

#添加如下内容
    <role rolename="tomcat"/>
    <role rolename="role1"/> 
    <role rolename="manager-script"/>
    <role rolename="manager-gui"/>
    <role rolename="manager-status"/>
    <role rolename="admin-gui"/>
    <role rolename="admin-script"/>
    <user username="tomcat" password="tomcat" roles="manager-gui,manager-script,tomcat,admin-gui,admin-script"/>
</tomcat-users>
 
#用户和密码都是：tomcat注意：为了能够刚才配置的用户登录到Tomcat，还需要修改以下配置 
vi /opt/tomcat/webapps/manager/META-INF/context.xml

<!--
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
       allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
-->
#把上面这行注释掉即可！    
```

# jenkins构建maven项目

# pipeline

```shell
#通过pipeline流水线完成项目的拉取、构建、发布三步
pipeline {
    agent any

    stages {
        stage('pull code') {      ###拉取代码
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'c2a9590d-e4d1-454b-a7c6-ed60dfa5336f', url: 'http://192.168.123.5:82/test02/web_demo.git']]])
            }
        }
        stage('build project') {   ###构建项目
            steps {
                sh 'mvn clean package'
            }
        }
        stage('publish project') {   ###发布项目
            steps {
                deploy adapters: [tomcat9(credentialsId: '1cb98f57-748b-426a-b9d9-b1f9e93f7ffd', path: '', url: 'http://192.168.123.7:8080')], contextPath: null, war: 'target/*.war'
            }
        }
    }
}
```



http://192.168.105.5:8888/project/web_demo_pipeline

```shell
//git凭证ID
def git_auth = "21413694-9c9b-42c6-abe1-322dd0b813b6"
//git的url地址
def git_url = "git@192.66.32.22:test01/test01.git"
//Harbor的url地址
def harbor_url = "hub.jgswy.com"
//镜像库项目名称
def harbor_project = "test01"
//Harbor的登录凭证ID
def harbor_auth = "23eb8f85-5cec-4d56-b7be-f79fd2286951"

node {
   //获取当前选择的项目名称
   def selectedProjectNames = "${project_name}".split(",")

   stage('拉取代码') {
      checkout([$class: 'GitSCM', branches: [[name: "*/${branch}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: "${git_auth}", url: "${git_url}"]]])
   }


   stage('拷贝代码至dockerfile相同目录') {
      sh "rm -rf /root/docker-test/'${project_name}'" 
      sh "cp -rf /data/jenkins/workspace/'${project_name}' /root/docker-test/'${project_name}'"}
  
   stage('编写dokcerfile,并制作镜像') {
                 //编写dockerfile
                sh "echo 'FROM centos'  > /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'MAINTAINER zp'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'ADD jdk-8u271-linux-x64.tar.gz /usr/local'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'ADD apache-tomcat-8.5.47.tar.gz /usr/local' >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'ENV MYPATH /usr/local'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo  'WORKDIR \$MYPATH'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'RUN mkdir /usr/local/apache-tomcat-8.5.47/webapps/test' >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'COPY index.jsp /usr/local/apache-tomcat-8.5.47/webapps/test/index.jsp' >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'COPY WEB-INF /usr/local/apache-tomcat-8.5.47/webapps/test/WEB-INF' >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'ENV JAVA_HOME /usr/local/jdk1.8.0_271'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh 'echo "ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"  >> /root/docker-test/"${project_name}"/dockerfile'
                sh "echo 'ENV CATALINA_HOME /usr/local/apache-tomcat-8.5.47'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'ENV CATALINA_BASH /usr/local/apache-tomcat-8.5.47'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'ENV PATH \$PATH:\$JAVA_HOME/bin:\$CATALINA_HOME/bin:\$CATALINA_HOME/lib'  >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'EXPOSE '${PORT}'' >> /root/docker-test/'${project_name}'/dockerfile"
                sh "echo 'CMD /usr/local/apache-tomcat-8.5.47/bin/startup.sh && tail -F /usr/local/apache-tomcat-8.5.47/bin/log/catalina.out'  >> /root/docker-test/'${project_name}'/dockerfile"                   

                 //构建镜像
                 sh "docker build -f /root/docker-test/'${project_name}'/dockerfile -t '${project_name}':'${tag}' . "

                 //定义镜像名称
                 def imageName = "${project_name}:${tag}"

                 //对镜像打上标签
                 sh "docker tag ${imageName} ${harbor_url}/${harbor_project}/${imageName}"

                //把镜像推送到Harbor
                withCredentials([usernamePassword(credentialsId: "${harbor_auth}", passwordVariable: 'password', usernameVariable: 'username')]) {

                    //登录到Harbor
                    sh "docker login -u ${username} -p ${password} ${harbor_url}"

                    //镜像上传
                    sh "docker push ${harbor_url}/${harbor_project}/${imageName}"

                    sh "echo 镜像上传成功"
                  }
               //远程部署
               sshPublisher(publishers: [sshPublisherDesc(configName: 'docker_test', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/root/jenkins_shell/deploy.sh $harbor_url $harbor_project $project_name $tag $port $target_port $old_tag", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
               }
             }
   
```

