# 1、创建hcjxh的mysql数据库

其中包含pv,pvc,statefulset,svc

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: hc-mysql-pv
  namespace: test-ns
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: hc-mysql-pv
  nfs:
    path: /data/k8s/hc-mysql
    server: 192.66.32.22
-
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: hc-mysql
  name: hc-mysql
  namespace: test-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hc-mysql
  serviceName: "hc-mysql"
  template:
    metadata:
      labels:
        app: hc-mysql
    spec:
      imagePullSecrets:
      - name: registry-pull-secret
      containers:
      - image: hub.jgswy.com/zabbix/mysql:8.0
        imagePullPolicy: IfNotPresent
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: R00T@mysql
        volumeMounts:
        - name: hc-mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: hc-mysql-storage
    spec:
      accessModes: [ "ReadWriteMany" ]
      storageClassName: "hc-mysql-pv"
      resources:
        requests:
          storage: 20Gi
-
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hc-mysql-svc
  name: hc-mysql-svc
  namespace: test-ns
spec:
  type: NodePort
  ports:
  - port: 3306
    nodePort: 30006
    protocol: TCP
    targetPort: 3306
  selector:
    app: hc-mysql
```

2、还原数据库

```shell
#解压备份
gunzip mysql-yndb.sql.tar

#将备份拷贝至容器
docker cp mysql-yndb.sql.tar e271882e941f:/var/lib

#容器中登入数据库恢复数据
mysql> source  /var/lib/mysql-yndb.sql
```

