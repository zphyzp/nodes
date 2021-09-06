# coredns出现crash状态

```shell
#查看coredns容器状态日志
kubectl describe pod coredns-5c98db65d4-rz7gm -n kube-system

#重启coredns容器
kubectl delete pod coredns-5c98db65d4-rz7gm -n kube-system

#查看容器状态
kubectl get pod -n kube-system -o wide
```



# 重启docker导致horbar无法启动

```shell
重启docker后，harbor无法访问,提前备份resolv.conf文件
systemctl stop docker
ifconfig 
ifconfig down br-cd1d36fa87e2
systemctl restart network
systemctl start docker
docker rm -f $(docker ps -aq)
docker ps -a  #查看所有容器
cd /usr/local/harbor
./install.sh

##（docker-compose down/up）##
```

# 重新初始化k8s master1节点

```shell
1. 删除/etc/kubernetes/文件夹下的所有文件
2. 删除$HOME/.kube文件夹
3. 删除/var/lib/etcd文件夹
4. 停用端口号, 把下面的这些端口号都停用就ok
5. 停止kubelet
rm -rf /etc/kubernetes/*
rm -rf ~/.kube/*
rm -rf /var/lib/etcd/*
lsof -i :6443|grep -v "PID"|awk '{print "kill -9",$2}'|sh
lsof -i :10259|grep -v "PID"|awk '{print "kill -9",$2}'|sh
lsof -i :10257|grep -v "PID"|awk '{print "kill -9",$2}'|sh
lsof -i :2379|grep -v "PID"|awk '{print "kill -9",$2}'|sh
lsof -i :2380|grep -v "PID"|awk '{print "kill -9",$2}'|sh
systemctl stop kubelet
kubeadm reset
```

# k8s查看容器日志---查看运行中指定pod以及指定pod中容器的日志

1、查看指定pod的日志

```
kubectl logs <pod_name>
```

`kubectl logs -f <pod_name>` #类似tail -f的方式查看(tail -f 实时查看日志文件 tail -f 日志文件log)

2、查看指定pod中指定容器的日志

```
kubectl logs <pod_name> -c <container_name>
```

PS：查看Docker容器日志
`docker logs <container_id>`

# 卸载flannel网络步骤：

```bash
#第一步，在master节点删除flannel
kubectl delete -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#第二步，在node节点清理flannel网络留下的文件
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/
rm -f /etc/cni/net.d/*
注：执行完上面的操作，重启kubelet
```

# k8s 删除和维护服务节点

```bash
# 将 node 节点标记为不可调度，不影响现有 pod。注意 daemonSet 不受影响
kubectl cordon node-name
# 驱逐该节点的 pod
kubectl drain node-name
# 维护结束，节点重新投入使用
kubectl uncordon node-name
# 删除节点
kubectl delete node node-name
# 加入新节点，在master节点上执行，将输出再到新节点上执行
kubeadm token create --print-join-command
```