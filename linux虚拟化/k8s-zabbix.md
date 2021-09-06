# **zabbix k8s部署**

##    1.创建pv

```bash
vim mysql-pv.yaml
```

登录后复制

```bash
kind: PersistentVolume
apiVersion: v1
metadata:
  name: mysql-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

##     2.创建mysql配置文件（configMap）

```bash
vim mysql-config.yaml
```

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  custom.cnf: |
    [mysqld]
    default_storage_engine=innodb
    skip_external_locking
    skip_host_cache
    skip_name_resolve
    default_authentication_plugin=mysql_native_password
```

##     3.创建mysql密码（secret）

```bash
[root@k8s-master-01 mysql]# echo -n password|base64
cGFzc3dvcmQ=
vim mysql-secret.yaml
```

```bash
apiVersion: v1
kind: Secret
metadata:
  name: mysql-user-pwd
data:
  mysql-root-pwd: cGFzc3dvcmQ=
```

##  4.创建mysql部署文件

```bash
vim mysql-deploy.yaml
```

```bash
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort
  ports:
  - port: 3306
    nodePort: 30006
    protocol: TCP
    targetPort: 3306 
  selector:
    app: mysql

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql
        name: mysql
        imagePullPolicy: IfNotPresent
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-user-pwd
              key: mysql-root-pwd
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-config
          mountPath: /etc/mysql/conf.d/
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
        - name: timezone
          mountPath: /etc/localtime
      volumes:
      - name: mysql-config
        configMap:
          name: mysql-config
      - name: timezone
        hostPath:
          path: /usr/share/zoneinfo/Asia/Shanghai
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
         
```

## 5.使用kubectl命令及以上yaml文件部署mysql

```bash
[root@k8s-master-01 mysql]# kubectl apply -f ./      
configmap/mysql-config created
service/mysql created
deployment.apps/mysql created
persistentvolume/mysql-pv-volume created
persistentvolumeclaim/mysql-pv-claim created
secret/mysql-user-pwd created
```

创建完mysql pod后进入容器创建zabbix数据库(utf8)

```shell
#进入容器
[root@k8s-node2 ~]# docker exec -it 6c47e25db891 /bin/bash

#进入数据库
mysql -uroot -pxxxx

#创建字符集为utf-8的zabbix数据库
create database zabbix character set utf8 COLLATE utf8_bin;
```

## 部署zabbix-server

```bash
vim zabbix-server-deploy.yaml
```

```bash
apiVersion: v1
kind: Service
metadata:
  name: zabbixserver
spec:
  type: NodePort
  ports:
  - port:  10051
    nodePort: 30051
    protocol: TCP
    targetPort: 10051
  selector:
    app: zabbix-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zabbix-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: zabbix-server
  template:
    metadata:
      labels:
        app: zabbix-server
    spec:
      containers:
        - name: zabbix-server
          image: zabbix/zabbix-server-mysql
          imagePullPolicy: IfNotPresent
          ports:
          - containerPort: 10051
            name: server
            protocol: TCP
          readinessProbe:
            tcpSocket:
              port: server
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            tcpSocket:
              port: server
            initialDelaySeconds: 15
            periodSeconds: 20
          env:
          - name: DB_SERVER_HOST
            value: "mysql"
          - name: MYSQL_USER
            value: "zabbix"
          - name: MYSQL_PASSWORD
            value: "zabbix"
          - name: MYSQL_DATABASE
            value: "zabbix"
          - name: ZBX_CACHESIZE
            value: "1024M"
          - name: ZBX_TRENDCACHESIZE
            value: "1024M"
          - name: ZBX_HISTORYCACHESIZE
            value: "2048M"
          - name: ZBX_HISTORYINDEXCACHESIZE
            value: "1024M"
          - name: ZBX_STARTTRAPPERS
            value: "5"
          - name: ZBX_STARTPREPROCESSORS
            value: "10"
          - name: ZBX_STARTDBSYNCERS
            value: "10"
          - name: DB_SERVER_PORT
            value: "3306"
          - name: MYSQL_ROOT_PASSWORD
            valueFrom:
              secretKeyRef:
                name: mysql-user-pwd
                key: mysql-root-pwd
        - name: zabbix-agent
          image: zabbix/zabbix-agent
          imagePullPolicy: Always
          ports:
          - containerPort: 10050
            name: zabbix-agent
          env:
          - name: ZBX_HOSTNAME
            value: "Zabbix server"
          - name: ZBX_SERVER_HOST
            value: "127.0.0.1"
          - name: ZBX_PASSIVE_ALLOW
            value: "true"
          - name: ZBX_STARTAGENTS
            value: "3"
          - name: ZBX_TIMEOUT
            value: "10"
          securityContext:
            privileged: true
```

## 部署zabbix-web

```bash
vim zabbix-web.yaml
```

```bash
apiVersion: v1
kind: Service
metadata:
  name: zabbix-web
spec:
  type: NodePort
  ports:
  - port: 8080
    protocol: TCP
    nodePort: 30080
    targetPort: 8080
  selector:
    app: zabbix-web
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zabbix-web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: zabbix-web
  template:
    metadata:
      labels:
        app: zabbix-web
    spec:
      containers:
      - image: zabbix/zabbix-web-nginx-mysql
        name: zabbix-web
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
          name: web
          protocol: TCP
        env:
        - name: DB_SERVER_HOST
          value: "mysql"
        - name:  ZBX_SERVER_HOST
          value: "zabbixserver"
        - name: MYSQL_USER
          value: "zabbix"
        - name: MYSQL_PASSWORD
          value: "zabbix"
        - name: TZ
          value: "Asia/Shanghai"
```

##    使用kubectl命令及以上yaml文件部署

```bash
[root@k8s-master-01 zabbix]# kubectl apply -f ./
service/zabbixserver created
deployment.apps/zabbix-server created
service/zabbix-web created
deployment.apps/zabbix-web created
```

- ## 查看部署的组件状态

```bash
[root@k8s-master-01 zabbix]# kubectl get deploy,pod,svc,cm,secret,pv,pvc -o wide
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS                   IMAGES                                           SELECTOR
deployment.apps/mysql           1/1     1            1           15m     mysql                        mysql                                            app=mysql
deployment.apps/zabbix-server   1/1     1            1           3m23s   zabbix-server,zabbix-agent   zabbix/zabbix-server-mysql,zabbix/zabbix-agent   app=zabbix-server
deployment.apps/zabbix-web      2/2     2            2           3m23s   zabbix-web                   zabbix/zabbix-web-nginx-mysql                    app=zabbix-web

NAME                                READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
pod/mysql-ffcc44677-g2tlr           1/1     Running   0          15m     10.244.0.126   k8s-node-01   <none>           <none>
pod/zabbix-server-75cdd8865-rnxhx   2/2     Running   0          3m24s   10.244.0.127   k8s-node-01   <none>           <none>
pod/zabbix-web-856989975-8k45c      1/1     Running   0          3m23s   10.244.0.128   k8s-node-01   <none>           <none>
pod/zabbix-web-856989975-hxdfl      1/1     Running   0          3m24s   10.244.1.118   k8s-node-02   <none>           <none>

NAME                   TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)           AGE     SELECTOR
service/kubernetes     ClusterIP   10.0.0.1     <none>        443/TCP           88d     <none>
service/mysql          NodePort    10.0.0.15    <none>        3306:30006/TCP    15m     app=mysql
service/zabbix-web     NodePort    10.0.0.189   <none>        80:30080/TCP      3m23s   app=zabbix-web
service/zabbixserver   NodePort    10.0.0.234   <none>        10051:30051/TCP   3m23s   app=zabbix-server

NAME                     DATA   AGE
configmap/mysql-config   1      15m

NAME                         TYPE                                  DATA   AGE
secret/default-token-7qhlz   kubernetes.io/service-account-token   3      88d
secret/mysql-user-pwd        Opaque                                1      15m
secret/tls-secret            kubernetes.io/tls                     2      61d

NAME                               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE   VOLUMEMODE
persistentvolume/mysql-pv-volume   20Gi       RWO            Retain           Bound    default/mysql-pv-claim   manual                  15m   Filesystem

NAME                                   STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
persistentvolumeclaim/mysql-pv-claim   Bound    mysql-pv-volume   20Gi       RWO            manual         15m  
```