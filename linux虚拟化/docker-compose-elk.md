# docker-elk

## docker-compose文件

```yml
version: "3"
services:
  es-master:
    container_name: es-master
    hostname: es-master
    image: elasticsearch:7.7.1
    restart: always
    ports:
      - 9200:9200
      - 9300:9300
    volumes:
      - /data/elasticsearch/master/conf/es-master.yaml:/usr/share/elasticsearch/config/elasticsearch.yml
      - /data/elasticsearch/master/data:/usr/share/elasticsearch/data
      - /data/elasticsearch/master/logs:/usr/share/elasticsearch/logs
    environment:
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"

  es-slave1:
    container_name: es-slave1
    image: elasticsearch:7.7.1
    restart: always
    ports:
      - 9201:9200
      - 9301:9300
    volumes:
      - /data/elasticsearch/slave1/conf/es-slave1.yaml:/usr/share/elasticsearch/config/elasticsearch.yml
      - /data/elasticsearch/slave1/data:/usr/share/elasticsearch/data
      - /data/elasticsearch/slave1/logs:/usr/share/elasticsearch/logs
    environment:
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"

  es-slave2:
    container_name: es-slave2
    image: elasticsearch:7.7.1
    restart: always
    ports:
      - 9202:9200
      - 9302:9300
    volumes:
      - /data/elasticsearch/slave2/conf/es-slave2.yaml:/usr/share/elasticsearch/config/elasticsearch.yml
      - /data/elasticsearch/slave2/data:/usr/share/elasticsearch/data
      - /data/elasticsearch/slave2/logs:/usr/share/elasticsearch/logs
    environment:
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"

  kibana:
    container_name: kibana
    hostname: kibana
    image: kibana:7.7.1
    restart: always
    ports:
      - 5601:5601
    volumes:
      - /data/kibana/conf/kibana.yml:/usr/share/kibana/config/kibana.yml
    environment:
      - elasticsearch.hosts=http://es-master:9200
    depends_on:
      - es-master
      - es-slave1
      - es-slave2
  logstash:
    container_name: logstash
    hostname: logstash
    image: logstash:7.7.1
    command: logstash -f ./conf/logstash.conf
    restart: always
    volumes:
      - /data/logstash/conf/logstash.conf:/usr/share/logstash/conf/logstash.conf
      - /data/logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml
      - /data/logstash/ssl:/usr/share/logstash/ssl
    ports:
      - 5044:5044
    depends_on:
      - es-master
      - es-slave1
      - es-slave2

```

## 配置文件

### es配置文件

xpack相关配置先注释掉，生成证书后统一配置

```yml
#es-master

cluster.name: es-cluster
node.name: es-master
node.master: true
network.host: 0.0.0.0
http.port: 9200
transport.tcp.port: 9300
 
discovery.seed_hosts: ["es-master:9300","es-slave1:9300","es-slave2:9300"]
cluster.initial_master_nodes: ["es-master"]

http.cors.enabled: true
http.cors.allow-origin: "*"
 
# 这条配置表示开启xpack认证机制
xpack.security.enabled: true
xpack.license.self_generated.type: basic
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12

#es-slave1
cluster.name: es-cluster
node.name: es-slave1
node.master: true
network.host: 0.0.0.0
http.port: 9201
transport.tcp.port: 9301
 

discovery.seed_hosts: ["es-master:9300","es-slave1:9300","es-slave2:9300"]
cluster.initial_master_nodes: ["es-master"]

http.cors.enabled: true
http.cors.allow-origin: "*"
 
# 这条配置表示开启xpack认证机制
xpack.security.enabled: true
xpack.license.self_generated.type: basic
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12

#es-slave2
cluster.name: es-cluster
node.name: es-slave2
node.master: true
network.host: 0.0.0.0
http.port: 9202
transport.tcp.port: 9302

discovery.seed_hosts: ["es-master:9300","es-slave1:9300","es-slave2:9300"]
cluster.initial_master_nodes: ["es-master"]

http.cors.enabled: true
http.cors.allow-origin: "*"
 
# 这条配置表示开启xpack认证机制
xpack.security.enabled: true
xpack.license.self_generated.type: basic
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
```

### kibana配置文件

```yml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: "https://es-master:9200"
kibana.index: ".kibana"
i18n.locale: "zh-CN"
#xpack相关配置
xpack.reporting.encryptionKey: "a_random_string"
xpack.security.encryptionKey: "something_at_least_32_characters"
xpack.encryptedSavedObjects.encryptionKey: 'fhjskloppd678ehkdfdlliverpoolfcr'
elasticsearch.ssl.certificateAuthorities: ["/usr/share/kibana/config/elastic-certificates.p12"]
elasticsearch.ssl.verificationMode: none
```

### logstash配置文件

```yml
#logstash.yml
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.username: "logstash_system"
xpack.monitoring.elasticsearch.password: "Capinfo@123"
xpack.monitoring.elasticsearch.hosts: "https://es-master:9200"
xpack.monitoring.elasticsearch.ssl.certificate_authority: "/usr/share/logstash/config/ca.pem"
xpack.monitoring.elasticsearch.ssl.verification_mode: certificate
xpack.monitoring.elasticsearch.sniffing: false


#logstash.conf
input {
  beats {
    port => 5044
  }

}

output{
  stdout {codec => rubydebug}
    elasticsearch {
    user => "elastic"
    password => "Capinfo@123"
    ssl_certificate_verification => false
    ssl => true
    cacert => "/usr/share/logstash/config/ca.pem"
    index => "networklogs-%{+YYYY.MM.dd}"
    hosts => ["es-master:9200"]
    }
}

```

### filebeat配置文件

```yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /data/log/test/*/*.log
  tags: ["B41"]
setup.template.settings:
  index.number_of_shards: 3
output.logstash:
  hosts: ["0.0.0.0:5044"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
```

## 开启elk内部tls/ssl安全认证（监控需要）

### es

```bash
修改配置文件，开启x-pack模块，先不要开启https模块，生成完密码再开启

执行命令生成p12证书
/usr/share/elasticsearch/bin/elasticsearch-certutil ca
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

将生成的两个证书拷贝至上方配置文件对应的目录后，赋予权限，重启es
重启完成后执行以下命令配置密码
elasticsearch-setup-passwords interactive

配置文件中开启https模块，重启es
```

### kibana

```bash
将证书考入config文件内

修改配置文件，开启x-pack后重启镜像
```

### logstash

```shel
为logstash剥离出一个ca证书，并拷贝至相应目录授权
openssl pkcs12 -in elastic-certificates.p12 -clcerts -nokeys -chain -out ca.pem

修改logstash配置文件后重启镜像
```

