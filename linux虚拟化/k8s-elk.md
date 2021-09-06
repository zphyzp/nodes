# k8s搭建elk

## 下载镜像和包

```shell
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.11.2
docker pull docker.elastic.co/kibana/kibana:7.11.2
docker pull docker.elastic.co/logstash/logstash:7.11.2
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.11.2-x86_64.rpm
```

## 一，搭建elasticsearch+kibana

### elasticsearch配置文件

```shell
vi elasticsearch.yml
cluster.name: my-es
node.name: es-kibana
cluster.initial_master_nodes: ["es-kibana"]
path.data: /usr/share/elasticsearch/data
#path.logs: /var/log/elasticsearch
bootstrap.memory_lock: false
network.host: 0.0.0.0
http.port: 9200
#集群个节点IP地址，也可以使用els、els.shuaiguoxia.com等名称，需要各节点能够解析
#discovery.zen.ping.unicast.hosts: ["172.16.30.11", "172.17.77.12"]
#集群节点数
#discovery.zen.minimum_master_nodes: 2
#增加参数，使head插件可以访问es
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
```

###  kibana配置文件

注意kibana连接的主机使用了域名，是由有状态应用statefulset创建的Pod

```shell
# cat kibana.yml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: "http://localhost:9200"
kibana.index: ".kibana"
i18n.locale: "zh-CN"
```

### 创建elasticsearch和kibana的配置文件configmap

本次把日志收集系统放置在命名空间kube-system

```shell
#先创建elk名称空间
kubectl create namespace elk
#创建configmap
kubectl create configmap es-config -n elk --from-file=elasticsearch.yml
kubectl create configmap kibana-config -n elk --from-file=kibana.yml
```

### 安装nfs用于es存储

```shell
#每个节点都安装
yum install -y nfs-common nfs-utils rpcbind
systemctl start nfs
systemctl enable nfs
systemctl start rpcbind
systemctl enable rpcbind
mkdir -p /data/elasticsearch

#编辑配置文件
vi /etc/exports
/data/elasticsearch *(rw,no_root_squash,no_all_squash,sync)

#重启nfs和rpc
systemctl restart nfs
systemctl restart rpcbind

#在另外节点创建目录并挂载
mkdir -p /data/elasticsearch
mount -t nfs 192.168.160.12:/data/elasticsearch /data/elasticsearch

```

### 创建es-pv

```shell
# more es-pv.yaml 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: es-pv
  namespace: elk
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: es-pv
  nfs:
    path: /data/elasticsearch
    server: 192.168.160.12
    
#创建PV
kubectl create -f es-pv.yaml
```

### 创建es-kibana的yaml配置文件

```shell
#vi es-statefulset.yaml 
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: es-kibana
  name: es-kibana
  namespace: elk
spec:
  replicas: 1
  selector:
    matchLabels:
      app: es-kibana
  serviceName: "es-kibana"
  template:
    metadata:
      labels:
        app: es-kibana
    spec:
      imagePullSecrets:
      - name: registry-pull-secret
      containers:
      - image: docker.elastic.co/elasticsearch/elasticsearch:6.8.14
        imagePullPolicy: Never
        name: elasticsearch
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:       
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: es-config
          mountPath: /usr/share/elasticsearch/config/elasticsearch.yml
          subPath: elasticsearch.yml
        - name: es-persistent-storage
          mountPath: /usr/share/elasticsearch/data
      - image: docker.elastic.co/kibana/kibana:6.8.14
        imagePullPolicy: Never
        name: kibana
        volumeMounts:
        - name: kibana-config
          mountPath: /usr/share/kibana/config/kibana.yml
          subPath: kibana.yml
      volumes:
      - name: es-config
        configMap:
          name: es-config
      - name: kibana-config
        configMap:
          name: kibana-config
  volumeClaimTemplates:
  - metadata:
      name: es-persistent-storage
    spec:
      accessModes: [ "ReadWriteMany" ]
      storageClassName: "es-pv"
      resources:
        requests:
          storage: 5Gi
      #hostNetwork: true
      #dnsPolicy: ClusterFirstWithHostNet
      
#创建es-kibana
kubectl apply -f es-statefulset.yaml
```

### 创建es-kibana的svc

```shell
# more es-svc.yaml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: es-kibana
  name: es-kibana
  namespace: elk
spec:
  ports:
  - name: es9200
    port: 9200
    protocol: TCP
    targetPort: 9200
  - name: es9300
    port: 9300
    protocol: TCP
    targetPort: 9300
  selector:
    app: es-kibana
  type: ClusterIP

# more es-kibana-nodeport-svc.yml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: es-kibana
  name: es-kibana-nodeport-svc
  namespace: elk
spec:
  ports:
  - name: 9200-9200
    port: 9200
    nodePort: 31882
    protocol: TCP
    targetPort: 9200
  - name: 5601-5601
    port: 5601
    nodePort: 31883
    protocol: TCP
    targetPort: 5601
  selector:
    app: es-kibana
  type: NodePort
  
#创建svc
kubectl create -f es-svc.yaml
kubectl create -f es-kibana-nodeport-svc.yml 
```

## 二，创建logstash服务

### logstash.yml与logstash.con配置文件

```shell
# more logstash.yml 
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.url: http://#es的ClusterIP:9200

# more logstash.conf 
input {
  beats {
     port => 5044
  }
}
   
filter {
  mutate {
    rename => { "[host][name]" => "host" }
  }
}
   
output {
           elasticsearch {
              hosts => ["http://#es的ClusterIP:9200"]
              index => "k8s-system-log-%{+YYYY.MM.dd}"
           }
          stdout{
              codec => rubydebug
           }
}


#创建configmap
kubectl create configmap logstash-yml-config -n elk  --from-file=logstash.yml
kubectl create configmap logstash-config -n elk  --from-file=logstash.conf
```

### logstash的yaml配置文件

```shell
# more logstash-statefulset.yaml 
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: logstash
  name: logstash
  namespace: elk
spec:
  serviceName: "logstash"
  replicas: 1
  selector:
    matchLabels:
      app: logstash
  template:
    metadata:
      labels:
        app: logstash
    spec:
      imagePullSecrets:
      - name: registry-pull-secret
      containers:
      - image: docker.elastic.co/logstash/logstash:6.8.14
        imagePullPolicy: Never
        name: logstash
        volumeMounts:
        - name: logstash-yml-config
          mountPath: /usr/share/logstash/config/logstash.yml
          subPath: logstash.yml
        - name: logstash-config
          mountPath: /usr/share/logstash/pipeline/logstash.conf
          subPath: logstash.conf
      volumes:
      - name: logstash-yml-config
        configMap:
          name: logstash-yml-config
      - name: logstash-config
        configMap:
          name: logstash-config
 
 #创建logstash
 kubectl apply -f logstash-statefulset.yaml
```

logstash的svc

```shell
# more logstash-nodeport-svc.yml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: logstash
  name: logstash-nodeport-svc
  namespace: elk
spec:
  ports:
  - name: logstash
    port: 5044
    nodePort: 31884
    protocol: TCP
    targetPort: 5044
  selector:
    app: logstash
  type: NodePort
```



