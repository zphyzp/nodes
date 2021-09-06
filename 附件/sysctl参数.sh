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

#net.ipv4.tcp_mem[0]:���ڴ�ֵ,TCPû���ڴ�ѹ��. 
#net.ipv4.tcp_mem[1]:�ڴ�ֵ��,�����ڴ�ѹ���׶�. 
#net.ipv4.tcp_mem[2]:���ڴ�ֵ,TCP�ܾ�����socket. 
#�����ڴ浥λ��ҳ,�������ֽ�.�ɲο����Ż�ֵ��:78643200/104857600/157286400����ֵ����1ҳ=4k),����ϵͳ�ڿ���ǰ���Ѽ���ã�Ĭ�ϼ��ɡ�
�鿴��cat /proc/sys/net/ipv4/tcp_mem
net.ipv4.tcp_mem = 78643200��300g�� 104857600(450g) 157286400(600g)       

#����SYN��������������.Ĭ��1024.���ظ��ط�����,���Ӹ�ֵ��Ȼ�кô�.�ɵ�����16384/32768/65535����ͬһʱ�䣬���ֻ�ܽ���32768���ͻ��˷���־�����
net.ipv4.tcp_max_syn_backlog = 32768                  

#TCPʧ���ش�����,Ĭ��ֵ15,��ζ���ش�15�βų��׷���.�ɼ��ٵ�5,�Ծ����ͷ��ں���Դ
@net.ipv4.tcp_retries2 = 5

#��˼ĳ��TCP������idle 30���Ӻ�,�ں˲ŷ���probe.���probe 3��(ÿ��30��)���ɹ�,�ں˲ų��׷���,��Ϊ��������ʧЧ                            
net.ipv4.tcp_keepalive_time = 1800                   
net.ipv4.tcp_keepalive_probes = 3                    
net.ipv4.tcp_keepalive_intvl = 30                    

#��ʾ����׽����ɱ���Ҫ��ر�,���������������������FIN-WAIT-2״̬��ʱ��
net.ipv4.tcp_fin_timeout = 30                        

#��ʾ��������,����TIME-WAIT sockets���������µ�TCP����,Ĭ��Ϊ0,��ʾ�ر�.��TIME-WAIT�׽������ù��ܣ����ڴ��ڴ������ӵ�Web�������ǳ���Ч��
net.ipv4.tcp_tw_reuse = 1                            

#��ʾ����TCP������TIME-WAIT sockets�Ŀ��ٻ���,Ĭ��Ϊ0,��ʾ�ر�.��TIME-WAIT�׽������ù��ܣ����ڴ��ڴ������ӵ�Web�������ǳ���Ч��
net.ipv4.tcp_tw_recycle = 1                          

#Ĭ��Ϊ180000,����ʹ��Ĭ��ֵ,�������С
net.ipv4.tcp_max_tw_buckets = 180000                  

#������һЩ����
net.ipv4.route.gc_timeout = 100                       
net.ipv4.tcp_syn_retries = 2                          
net.ipv4.tcp_synack_retries = 2                       
