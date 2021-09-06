net.core.wmem_default = 1746400                       
net.core.wmem_max = 3492800                           
net.core.rmem_default = 1746400                       
net.core.rmem_max = 3492800                           
net.core.netdev_max_backlog = 32768                   
net.core.somaxconn = 16384                            
net.core.optmem_max = 10240                           
net.ipv4.ip_local_port_range = 1024 65535             
net.ipv4.tcp_wmem = 873200 1746400 3492800            
net.ipv4.tcp_rmem = 873200 1746400 3492800            

#net.ipv4.tcp_mem[0]:低于此值,TCP没有内存压力. 
#net.ipv4.tcp_mem[1]:在此值下,进入内存压力阶段. 
#net.ipv4.tcp_mem[2]:高于此值,TCP拒绝分配socket. 
#上述内存单位是页,而不是字节.可参考的优化值是:78643200/104857600/157286400（数值有误，1页=4k),此致系统在开机前就已计算好，默认即可。
查看：cat /proc/sys/net/ipv4/tcp_mem
net.ipv4.tcp_mem = 78643200（300g） 104857600(450g) 157286400(600g)       

#进入SYN包的最大请求队列.默认1024.对重负载服务器,增加该值显然有好处.可调整到16384/32768/65535。在同一时间，最大只能接受32768个客户端发起持久连接
net.ipv4.tcp_max_syn_backlog = 32768                  

#TCP失败重传次数,默认值15,意味着重传15次才彻底放弃.可减少到5,以尽早释放内核资源
@net.ipv4.tcp_retries2 = 5

#意思某个TCP连接在idle 30分钟后,内核才发起probe.如果probe 3次(每次30秒)不成功,内核才彻底放弃,认为该连接已失效                            
net.ipv4.tcp_keepalive_time = 1800                   
net.ipv4.tcp_keepalive_probes = 3                    
net.ipv4.tcp_keepalive_intvl = 30                    

#表示如果套接字由本端要求关闭,这个参数决定了它保持在FIN-WAIT-2状态的时间
net.ipv4.tcp_fin_timeout = 30                        

#表示开启重用,允许将TIME-WAIT sockets重新用于新的TCP连接,默认为0,表示关闭.打开TIME-WAIT套接字重用功能，对于存在大量连接的Web服务器非常有效。
net.ipv4.tcp_tw_reuse = 1                            

#表示开启TCP连接中TIME-WAIT sockets的快速回收,默认为0,表示关闭.打开TIME-WAIT套接字重用功能，对于存在大量连接的Web服务器非常有效。
net.ipv4.tcp_tw_recycle = 1                          

#默认为180000,建议使用默认值,不建议调小
net.ipv4.tcp_max_tw_buckets = 180000                  

#其它的一些设置
net.ipv4.route.gc_timeout = 100                       
net.ipv4.tcp_syn_retries = 2                          
net.ipv4.tcp_synack_retries = 2                       
