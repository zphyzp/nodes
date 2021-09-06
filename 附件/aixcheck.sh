#!/bin/bash
####Basic 
echo "Begin collect Information..."
echo ""
echo "Warning: Must use oracle user & Input the ture Directory"
sleep 1
echo ""
echo "Now make a result Directory(/home/oracle/scripts)"
if [ -d /home/oracle/scripts ];then
echo "The Directory To Be Created."
else
mkdir -p /home/oracle/scripts
echo "Created The Directory." 
fi 
sleep 2

echo ""
echo -n "Please Enter Your Oracle GodenGate Directory[/goldengate]: "
read gg_d
sleep 2

echo ""
echo -n "Please Enter Your Oracle Grid Base Directory[/u01/app/11.2/grid]: "
read gr_d
echo "info all"|$gg_d/ggsci >/home/oracle/scripts/ggrpt
echo "$gg_d/ggsci"

$gr_d/bin/crs_stat -t -v >/home/oracle/scripts/crsrpt
echo $gr_d/bin/crs_stat -t -v
echo $TIME
####Done File
TIME_Y=`date +%Y`
TIME_M=`date +%m`
TIME_D=`date +%d`
HOSTNAME=`hostname`
DONEFILE=/home/oracle/scripts/os_aix_"$HOSTNAME"_"$TIME_Y""$TIME_M""$TIME_D".html
####Main Information
TIME=`date`
KERNEL=`lsattr -El sys0 |grep systemid |awk '{print $2}'`
OSLEVEL=`lsattr -El sys0 |grep modelname |awk '{print $2}'`
UPTIME=`uptime|awk -F "," '/up/ {print $1}'`
####Memory Information
MEM_T=`svmon -G | awk '/memory/ {print $2}'`
MEM_U=`svmon -G | awk '/memory/ {print $3}'`
MEM_F=`svmon -G | awk '/memory/ {print $4}'`
PG_T=`svmon -G | awk '/pg space/ {print $3}'`
PG_U=`svmon -G | awk '/pg space/ {print $4}'`
####CPU Information
CPU_IDEL=`vmstat 1 3|awk 'NR==8 {print $16}'`
####File System Information
M1_NAME=`df -g |awk 'NR==2 {print $7}'`
M1_TOL=`df -g |awk 'NR==2 {print $2}'`
M1_F=`df -g |awk 'NR==2 {print $3}'`
M1_U=`df -g |awk 'NR==2 {print $4}'`
M2_NAME=`df -g |awk 'NR==3 {print $7}'`
M2_TOL=`df -g |awk 'NR==3 {print $2}'`
M2_F=`df -g |awk 'NR==3 {print $3}'`
M2_U=`df -g |awk 'NR==3 {print $4}'`
M3_NAME=`df -g |awk 'NR==4 {print $7}'`
M3_TOL=`df -g |awk 'NR==4 {print $2}'`
M3_F=`df -g |awk 'NR==4 {print $3}'`
M3_U=`df -g |awk 'NR==4 {print $4}'`
M4_NAME=`df -g |awk 'NR==5 {print $7}'`
M4_TOL=`df -g |awk 'NR==5 {print $2}'`
M4_F=`df -g |awk 'NR==5 {print $3}'`
M4_U=`df -g |awk 'NR==5 {print $4}'`
M5_NAME=`df -g |awk 'NR==6 {print $7}'`
M5_TOL=`df -g |awk 'NR==6 {print $2}'`
M5_F=`df -g |awk 'NR==6 {print $3}'`
M5_U=`df -g |awk 'NR==6 {print $4}'`
M6_NAME=`df -g |awk 'NR==7 {print $7}'`
M6_TOL=`df -g |awk 'NR==7 {print $2}'`
M6_F=`df -g |awk 'NR==7 {print $3}'`
M6_U=`df -g |awk 'NR==7 {print $4}'`
M7_NAME=`df -g |awk 'NR==8 {print $7}'`
M7_TOL=`df -g |awk 'NR==8 {print $2}'`
M7_F=`df -g |awk 'NR==8 {print $3}'`
M7_U=`df -g |awk 'NR==8 {print $4}'`
M8_NAME=`df -g |awk 'NR==9 {print $7}'`
M8_TOL=`df -g |awk 'NR==9 {print $2}'`
M8_F=`df -g |awk 'NR==9 {print $3}'`
M8_U=`df -g |awk 'NR==9 {print $4}'`
M9_NAME=`df -g |awk 'NR==10 {print $7}'`
M9_TOL=`df -g |awk 'NR==10 {print $2}'`
M9_F=`df -g |awk 'NR==10 {print $3}'`
M9_U=`df -g |awk 'NR==10 {print $4}'`
M10_NAME=`df -g |awk 'NR==11 {print $7}'`
M10_TOL=`df -g |awk 'NR==11 {print $2}'`
M10_F=`df -g |awk 'NR==11 {print $3}'`
M10_U=`df -g |awk 'NR==11 {print $4}'`
M11_NAME=`df -g |awk 'NR==12 {print $7}'`
M11_TOL=`df -g |awk 'NR==12 {print $2}'`
M11_F=`df -g |awk 'NR==12 {print $3}'`
M11_U=`df -g |awk 'NR==12 {print $4}'`
M12_NAME=`df -g |awk 'NR==13 {print $7}'`
M12_TOL=`df -g |awk 'NR==13 {print $2}'`
M12_F=`df -g |awk 'NR==13 {print $3}'`
M12_U=`df -g |awk 'NR==13 {print $4}'`
M13_NAME=`df -g |awk 'NR==14 {print $7}'`
M13_TOL=`df -g |awk 'NR==14 {print $2}'`
M13_F=`df -g |awk 'NR==14 {print $3}'`
M13_U=`df -g |awk 'NR==14 {print $4}'`
M14_NAME=`df -g |awk 'NR==15 {print $7}'`
M14_TOL=`df -g |awk 'NR==15 {print $2}'`
M14_F=`df -g |awk 'NR==15 {print $3}'`
M14_U=`df -g |awk 'NR==15 {print $4}'`
M15_NAME=`df -g |awk 'NR==16 {print $7}'`
M15_TOL=`df -g |awk 'NR==16 {print $2}'`
M15_F=`df -g |awk 'NR==16 {print $3}'`
M15_U=`df -g |awk 'NR==16 {print $4}'`
###Oracle Listener Information
ORA_LISTENER=`ps -ef |grep -i listener |awk '/tnslsnr/ {print $8}'`
###Cluster Resource Information
CR_N1=`cat /home/oracle/scripts/crsrpt |awk 'NR==3 {print $1}'`
CR_S1=`cat /home/oracle/scripts/crsrpt |awk 'NR==3 {print $6}'`
CR_H1=`cat /home/oracle/scripts/crsrpt |awk 'NR==3 {print $7}'`
CR_N2=`cat /home/oracle/scripts/crsrpt |awk 'NR==4 {print $1}'`
CR_S2=`cat /home/oracle/scripts/crsrpt |awk 'NR==4 {print $6}'`
CR_H2=`cat /home/oracle/scripts/crsrpt |awk 'NR==4 {print $7}'`
CR_N3=`cat /home/oracle/scripts/crsrpt |awk 'NR==5 {print $1}'`
CR_S3=`cat /home/oracle/scripts/crsrpt |awk 'NR==5 {print $6}'`
CR_H3=`cat /home/oracle/scripts/crsrpt |awk 'NR==5 {print $7}'`
CR_N4=`cat /home/oracle/scripts/crsrpt |awk 'NR==6 {print $1}'`
CR_S4=`cat /home/oracle/scripts/crsrpt |awk 'NR==6 {print $6}'`
CR_H4=`cat /home/oracle/scripts/crsrpt |awk 'NR==6 {print $7}'`
CR_N5=`cat /home/oracle/scripts/crsrpt |awk 'NR==7 {print $1}'`
CR_S5=`cat /home/oracle/scripts/crsrpt |awk 'NR==7 {print $6}'`
CR_H5=`cat /home/oracle/scripts/crsrpt |awk 'NR==7 {print $7}'`
CR_N6=`cat /home/oracle/scripts/crsrpt |awk 'NR==8 {print $1}'`
CR_S6=`cat /home/oracle/scripts/crsrpt |awk 'NR==8 {print $6}'`
CR_H6=`cat /home/oracle/scripts/crsrpt |awk 'NR==8 {print $7}'`
CR_N7=`cat /home/oracle/scripts/crsrpt |awk 'NR==9 {print $1}'`
CR_S7=`cat /home/oracle/scripts/crsrpt |awk 'NR==9 {print $6}'`
CR_H7=`cat /home/oracle/scripts/crsrpt |awk 'NR==9 {print $7}'`
CR_N8=`cat /home/oracle/scripts/crsrpt |awk 'NR==10 {print $1}'`
CR_S8=`cat /home/oracle/scripts/crsrpt |awk 'NR==10 {print $6}'`
CR_H8=`cat /home/oracle/scripts/crsrpt |awk 'NR==10 {print $7}'`
CR_N9=`cat /home/oracle/scripts/crsrpt |awk 'NR==11 {print $1}'`
CR_S9=`cat /home/oracle/scripts/crsrpt |awk 'NR==11 {print $6}'`
CR_H9=`cat /home/oracle/scripts/crsrpt |awk 'NR==11 {print $7}'`
CR_N10=`cat /home/oracle/scripts/crsrpt |awk 'NR==12 {print $1}'`
CR_S10=`cat /home/oracle/scripts/crsrpt |awk 'NR==12 {print $6}'`
CR_H10=`cat /home/oracle/scripts/crsrpt |awk 'NR==12 {print $7}'`
CR_N11=`cat /home/oracle/scripts/crsrpt |awk 'NR==13 {print $1}'`
CR_S11=`cat /home/oracle/scripts/crsrpt |awk 'NR==13 {print $6}'`
CR_H11=`cat /home/oracle/scripts/crsrpt |awk 'NR==13 {print $7}'`
CR_N12=`cat /home/oracle/scripts/crsrpt |awk 'NR==14 {print $1}'`
CR_S12=`cat /home/oracle/scripts/crsrpt |awk 'NR==14 {print $6}'`
CR_H12=`cat /home/oracle/scripts/crsrpt |awk 'NR==14 {print $7}'`
CR_N13=`cat /home/oracle/scripts/crsrpt |awk 'NR==15 {print $1}'`
CR_S13=`cat /home/oracle/scripts/crsrpt |awk 'NR==15 {print $6}'`
CR_H13=`cat /home/oracle/scripts/crsrpt |awk 'NR==15 {print $7}'`
CR_N14=`cat /home/oracle/scripts/crsrpt |awk 'NR==16 {print $1}'`
CR_S14=`cat /home/oracle/scripts/crsrpt |awk 'NR==16 {print $6}'`
CR_H14=`cat /home/oracle/scripts/crsrpt |awk 'NR==16 {print $7}'`
CR_N15=`cat /home/oracle/scripts/crsrpt |awk 'NR==17 {print $1}'`
CR_S15=`cat /home/oracle/scripts/crsrpt |awk 'NR==17 {print $6}'`
CR_H15=`cat /home/oracle/scripts/crsrpt |awk 'NR==17 {print $7}'`
CR_N16=`cat /home/oracle/scripts/crsrpt |awk 'NR==18 {print $1}'`
CR_S16=`cat /home/oracle/scripts/crsrpt |awk 'NR==18 {print $6}'`
CR_H16=`cat /home/oracle/scripts/crsrpt |awk 'NR==18 {print $7}'`
CR_N17=`cat /home/oracle/scripts/crsrpt |awk 'NR==19 {print $1}'`
CR_S17=`cat /home/oracle/scripts/crsrpt |awk 'NR==19 {print $6}'`
CR_H17=`cat /home/oracle/scripts/crsrpt |awk 'NR==19 {print $7}'`
CR_N18=`cat /home/oracle/scripts/crsrpt |awk 'NR==20 {print $1}'`
CR_S18=`cat /home/oracle/scripts/crsrpt |awk 'NR==20 {print $6}'`
CR_H18=`cat /home/oracle/scripts/crsrpt |awk 'NR==20 {print $7}'`
CR_N19=`cat /home/oracle/scripts/crsrpt |awk 'NR==21 {print $1}'`
CR_S19=`cat /home/oracle/scripts/crsrpt |awk 'NR==21 {print $6}'`
CR_H19=`cat /home/oracle/scripts/crsrpt |awk 'NR==21 {print $7}'`
CR_N20=`cat /home/oracle/scripts/crsrpt |awk 'NR==22 {print $1}'`
CR_S20=`cat /home/oracle/scripts/crsrpt |awk 'NR==22 {print $6}'`
CR_H20=`cat /home/oracle/scripts/crsrpt |awk 'NR==22 {print $7}'`
CR_N21=`cat /home/oracle/scripts/crsrpt |awk 'NR==23 {print $1}'`
CR_S21=`cat /home/oracle/scripts/crsrpt |awk 'NR==23 {print $6}'`
CR_H21=`cat /home/oracle/scripts/crsrpt |awk 'NR==23 {print $7}'`
CR_N22=`cat /home/oracle/scripts/crsrpt |awk 'NR==24 {print $1}'`
CR_S22=`cat /home/oracle/scripts/crsrpt |awk 'NR==24 {print $6}'`
CR_H22=`cat /home/oracle/scripts/crsrpt |awk 'NR==24 {print $7}'`
CR_N23=`cat /home/oracle/scripts/crsrpt |awk 'NR==25 {print $1}'`
CR_S23=`cat /home/oracle/scripts/crsrpt |awk 'NR==25 {print $6}'`
CR_H23=`cat /home/oracle/scripts/crsrpt |awk 'NR==25 {print $7}'`
CR_N24=`cat /home/oracle/scripts/crsrpt |awk 'NR==26 {print $1}'`
CR_S24=`cat /home/oracle/scripts/crsrpt |awk 'NR==26 {print $6}'`
CR_H24=`cat /home/oracle/scripts/crsrpt |awk 'NR==26 {print $7}'`
CR_N25=`cat /home/oracle/scripts/crsrpt |awk 'NR==27 {print $1}'`
CR_S25=`cat /home/oracle/scripts/crsrpt |awk 'NR==27 {print $6}'`
CR_H25=`cat /home/oracle/scripts/crsrpt |awk 'NR==27 {print $7}'`
CR_N26=`cat /home/oracle/scripts/crsrpt |awk 'NR==28 {print $1}'`
CR_S26=`cat /home/oracle/scripts/crsrpt |awk 'NR==28 {print $6}'`
CR_H26=`cat /home/oracle/scripts/crsrpt |awk 'NR==28 {print $7}'`
CR_N27=`cat /home/oracle/scripts/crsrpt |awk 'NR==29 {print $1}'`
CR_S27=`cat /home/oracle/scripts/crsrpt |awk 'NR==29 {print $6}'`
CR_H27=`cat /home/oracle/scripts/crsrpt |awk 'NR==29 {print $7}'`
###OGG Porcess Information
OGG_M_S=`cat /home/oracle/scripts/ggrpt|awk '/MANAGER/ {print $2}'`
OGG_M_T=`cat /home/oracle/scripts/ggrpt|awk '/MANAGER/ {print $1}'`
OGG_RTB_S=`cat /home/oracle/scripts/ggrpt|awk '/R_TB/ {print $2}'`
OGG_RTB_T=`cat /home/oracle/scripts/ggrpt|awk '/R_TB/ {print $1}'`


##The Body Information
echo "<html> " >> $DONEFILE
echo "<head>" >>$DONEFILE
echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" >>$DONEFILE
echo "<meta name="generator" content="SQL*Plus 11.2.0">" >>$DONEFILE
echo "    <title>Digitalchina Snapshot Oracle Database Report</title>    <style type="text/css">      body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}      p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}      table,tr,td       {font:9pt Arial,Helvetica,sans-serif; color:Black; background:white; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;}      th                {font:bold 9pt Arial,Helvetica,sans-serif; color:white; background:#0066cc; padding:0px 0px 0px 0px;}      h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}      h2                {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}      a                 {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.link            {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#663300; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}      a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}    </style>" >>$DONEFILE
echo "</head>" >>$DONEFILE
echo "<body BGCOLOR="#C0C0C0">" >>$DONEFILE
echo "" >>$DONEFILE
echo "<br>" >>$DONEFILE                                                                                                                                                                       
echo "<center>" >>$DONEFILE                                                                                                                                           
echo "<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b><u>主机日巡检</u></b></font>     " >>$DONEFILE                                           
echo "</center>" >>$DONEFILE                                                                                                                                          
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "" >>$DONEFILE                                                                                                                                                   
echo "" >>$DONEFILE                                                                                                                                                   
echo "" >>$DONEFILE                                                                                                                                                   
echo "" >>$DONEFILE                                                                                                                                                   
echo "" >>$DONEFILE                                                                                                                                                   
echo "" >>$DONEFILE                                                                                                                                                   
echo "" >>$DONEFILE                                                                                                                                                   
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<a name="巡检"></a>  " >>$DONEFILE                                                                                                                                
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>主机描述</b></font><hr align="left" width="460">    " >>$DONEFILE                       
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<table width="90%" border="1">  <tr>" >>$DONEFILE                                                                                                               
echo "    <th align="left" width="20%">当前时间</th>    " >>$DONEFILE                                                                                                     
echo "    <td width="80%"><tt>$TIME</tt></td></tr>  <tr>" >>$DONEFILE                                                                                                
echo "      <th align="left" width="20%">主机名</th>   " >>$DONEFILE                                                                                                     
echo "      <td width="80%">$HOSTNAME</td></tr>  <tr>" >>$DONEFILE                                                                                                
echo "      <th align="left" width="20%">系统版本</th>    " >>$DONEFILE                                                                                                   
echo "      <td width="80%">$OSLEVEL</td></tr>  <tr>" >>$DONEFILE                                                                                   
echo "        <th align="left" width="20%">内核版本</th>    " >>$DONEFILE                                                                                                 
echo "        <td width="80%">$KERNEL</td></tr>  <tr>" >>$DONEFILE                                                                                                  
echo "        <th align="left" width="20%">主机运行时间</th>      " >>$DONEFILE                                                                                             
echo "        <td width="80%">$UPTIME</td></tr>  </table>" >>$DONEFILE                                                                                               
echo "<p><br>" >>$DONEFILE                                                                                                                                            
echo "</p>" >>$DONEFILE                                                                                                                                               
echo "<p> <a name="Memory"></a> <br>" >>$DONEFILE                                                                                                                        
echo "<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>内存空间使用情况</b></font></p>        " >>$DONEFILE                                        
echo "<hr align="left" width="460">" >>$DONEFILE                                                                                                                      
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<table WIDTH="90%" BORDER="1">" >>$DONEFILE                                                                                                                     
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <th width="20%" scope="col">内存</th>  " >>$DONEFILE                                                                                                          
echo "    <th width="21%" scope="col"> 总大小</th>   " >>$DONEFILE                                                                                                       
echo "    <th width="26%" scope="col">使用空间</th>    " >>$DONEFILE                                                                                                      
echo "    <th width="33%" scope="col"> 剩余空间</th>    " >>$DONEFILE                                                                                                     
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><b><font color="#336699">内存空间</font></b></td>    " >>$DONEFILE                                                                                          
echo "    <td align="right"> $MEM_T </td>" >>$DONEFILE                                                                                                                   
echo "    <td align="right"> $MEM_U </td>" >>$DONEFILE                                                                                                            
echo "    <td> $MEM_F </td>" >>$DONEFILE                                                                                                                           
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>交换分区</b></font></div></td>    " >>$DONEFILE                                                                  
echo "    <td align="right"> $PG_T </td>" >>$DONEFILE                                                                                                                   
echo "    <td align="right"> $PG_U </td>" >>$DONEFILE                                                                                                            
echo "    <td>  </td>" >>$DONEFILE                                                                                                                           
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "</table>" >>$DONEFILE                                                                                                                                           
echo "<p></p>" >>$DONEFILE                                                                                                                                            
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "  <a name="CPU"></a>" >>$DONEFILE                                                                                                                               
echo "  <br>" >>$DONEFILE                                                                                                                                             
echo "<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>CPU使用情况</b></font><hr align="left" width="460">    " >>$DONEFILE                    
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<table WIDTH="90%" BORDER="1">" >>$DONEFILE                                                                                                                     
echo "<tr>" >>$DONEFILE                                                                                                                                               
echo "<th width="19%" scope="col">名称</th>  " >>$DONEFILE                                                                                                              
echo "<th width="81%" scope="col">空闲率</th>   " >>$DONEFILE                                                                                                            
echo "</tr>" >>$DONEFILE                                                                                                                                              
echo "<tr>" >>$DONEFILE                                                                                                                                               
echo "<td>" >>$DONEFILE                                                                                                                                               
echo "<div align="left"><b><font color="#336699">CPU</font></b></div>" >>$DONEFILE                                                                                    
echo "</td>" >>$DONEFILE                                                                                                                                              
echo "<td align="left"> $CPU_IDEL </td>" >>$DONEFILE                                                                                                                     
echo "</tr>" >>$DONEFILE                                                                                                                                              
echo "</table>" >>$DONEFILE                                                                                                                                           
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p> <a name="Filesystem"></a> <br>" >>$DONEFILE                                                                                                                        
echo "<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>文件系统使用情况</b></font></p>        " >>$DONEFILE                                        
echo "<hr align="left" width="460">" >>$DONEFILE                                                                                                                      
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<table WIDTH="90%" BORDER="1">" >>$DONEFILE                                                                                                                     
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <th scope="col">目录名称</th>    " >>$DONEFILE                                                                                                                  
echo "    <th scope="col">总容量</th>   " >>$DONEFILE                                                                                                                    
echo "    <th scope="col">使用容量</th>    " >>$DONEFILE                                                                                                                  
echo "    <th scope="col"> 使用百分比</th>     " >>$DONEFILE                                                                                                               
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M1_NAME</b></font></div></td>" >>$DONEFILE                                                                      
echo "    <td align="right"> $M1_TOL </td>" >>$DONEFILE                                                                                                                  
echo "    <td align="right"> $M1_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M1_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M2_NAME</b></font></div></td>" >>$DONEFILE                                                                      
echo "    <td align="right"> $M2_TOL </td>" >>$DONEFILE                                                                                                                  
echo "    <td align="right"> $M2_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M2_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M3_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M3_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M3_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M3_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M4_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M4_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M4_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M4_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M5_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M5_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M5_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M5_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M6_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M6_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M6_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M6_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M7_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M7_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M7_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M7_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M8_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M8_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M8_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M8_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M9_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M9_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M9_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M9_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M10_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M10_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M10_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M10_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M11_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M11_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M11_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M11_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M12_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M12_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M12_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M12_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M13_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M13_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M13_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M13_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M14_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M14_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M14_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M14_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><font color="#336699"><b>$M15_NAME</b></font></div></td>" >>$DONEFILE                                                                       
echo "    <td align="right"> $M15_TOL </td>" >>$DONEFILE                                                                                                                    
echo "    <td align="right"> $M15_F </td>" >>$DONEFILE                                                                                                           
echo "    <td> $M15_U </td>" >>$DONEFILE                                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "</table>" >>$DONEFILE                                                                                                                                           
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p><a name="Listener"></a> <br>" >>$DONEFILE                                                                                                                         
echo "  <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Oracle监听状态</b></font></p>    " >>$DONEFILE                                        
echo "<hr align="left" width="460">" >>$DONEFILE                                                                                                                      
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<table WIDTH="90%" BORDER="1">" >>$DONEFILE                                                                                                                     
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <th width="19%" scope="col">名称</th>  " >>$DONEFILE                                                                                                          
echo "    <th width="81%" scope="col"> 运行时间</th>   " >>$DONEFILE                                                                                                       
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><b><font color="#336699">LISTENER</font></b></div></td>" >>$DONEFILE                                                                  
echo "    <td align="left"> $ORA_LISTENER </td>" >>$DONEFILE                                                                                                        
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "</table>" >>$DONEFILE                                                                                                                                           
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p></p>" >>$DONEFILE                                                                                                                                            
echo "<p><a name="Cluster"></a> <br>" >>$DONEFILE                                                                                                                         
echo "<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Oracle集群资源状态</b></font></p>      " >>$DONEFILE                                      
echo "<hr align="left" width="460">" >>$DONEFILE                                                                                                                      
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<table WIDTH="90%" BORDER="1">" >>$DONEFILE                                                                                                                     
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <th width="30%" scope="col">资源名称</th>    " >>$DONEFILE                                                                                                      
echo "    <th width="70%" scope="col"> 状态</th>  " >>$DONEFILE                                                                                                         
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><b><font color="#336699">$CR_H1 $CR_N1</font></b></div></td>" >>$DONEFILE                                                                        
echo "    <td align="left"> $CR_S1 </td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><b><font color="#336699">$CR_H2 $CR_N2</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S2</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H3 $CR_N3</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S3</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H4 $CR_N4</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S4</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H5 $CR_N5</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S5</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H6 $CR_N6</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S6</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H7 $CR_N7</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S7</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H8 $CR_N8</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S8</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H9 $CR_N9</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S9</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H10 $CR_N10</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S10</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H11 $CR_N11</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S11</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H12 $CR_N12</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S12</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H13 $CR_N13</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S13</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H14 $CR_N14</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S14</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H15 $CR_N15</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S15</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H16 $CR_N16</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S16</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H17 $CR_N17</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S17</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H18 $CR_N18</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S18</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H19 $CR_N19</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S19</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H20 $CR_N20</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S20</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H21 $CR_N21</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S21</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H22 $CR_N22</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S22</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H23 $CR_N23</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S23</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H24 $CR_N24</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S24</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H25 $CR_N25</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S25</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H26 $CR_N26</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S26</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><div align="left"><b><font color="#336699">$CR_H27 $CR_N27</font></b></div></td>" >>$DONEFILE                                                                       
echo "    <td align="left">$CR_S27</td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "</table>" >>$DONEFILE                                                                                                                                           
echo "<p></p>" >>$DONEFILE                                                                                                                                            
echo "<p></p>" >>$DONEFILE                                                                                                                                            
echo "<p> <a name="OGG"></a> <br>" >>$DONEFILE                                                                                                                        
echo "<b><font color="#336699" size="+2" face="Arial,Helvetica,Geneva,sans-serif">Oracle GodenGate进程状态</font></b></p>    " >>$DONEFILE                                
echo "<hr align="left" width="460">" >>$DONEFILE                                                                                                                      
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<table WIDTH="90%" BORDER="1">" >>$DONEFILE                                                                                                                     
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <th width="31%" scope="col"> 进程名称 </th>    " >>$DONEFILE                                                                                                    
echo "    <th width="35%" scope="col">进程类型</th>    " >>$DONEFILE                                                                                                      
echo "    <th width="34%" scope="col">进程状态</th>    " >>$DONEFILE                                                                                                      
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><b><font color="#336699">MANAGER</font></b></td>" >>$DONEFILE                                                                                           
echo "    <td align="left"> $OGG_M_T </td>" >>$DONEFILE                                                                                                                  
echo "    <td align="left"> $OGG_M_S </td>" >>$DONEFILE                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><div align="left"><b><font color="#336699">R_TB</font></b></div></td>" >>$DONEFILE                                                                  
echo "    <td align="left"> $OGG_RTB_T </td>" >>$DONEFILE                                                                                                                  
echo "    <td align="left"> $OGG_RTB_S </td>" >>$DONEFILE                                                                                                                 
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><b><font color="#336699">  </font></b></td>" >>$DONEFILE                                                                                              
echo "    <td align="left">  </td>" >>$DONEFILE                                                                                                                   
echo "    <td align="left">  </td>" >>$DONEFILE                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "    <tr>" >>$DONEFILE                                                                                                                                           
echo "    <td><b><font color="#336699">  </font></b></td>" >>$DONEFILE                                                                                              
echo "    <td align="left">  </td>" >>$DONEFILE                                                                                                                   
echo "    <td align="left">  </td>" >>$DONEFILE                                                                                                                  
echo "  </tr>" >>$DONEFILE                                                                                                                                                                                                                                                                                       
echo "</table>" >>$DONEFILE                                                                                                                                           
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p>&nbsp;</p>" >>$DONEFILE                                                                                                                                      
echo "<p><b><font color="#336699" size="+2" face="Arial,Helvetica,Geneva,sans-serif">日志部分</font></b></p>    " >>$DONEFILE                                             
echo "<hr align="left" width="460">" >>$DONEFILE                                                                                                                      
echo "<br>" >>$DONEFILE                                                                                                                                               
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<table WIDTH="90%" BORDER="1">" >>$DONEFILE                                                                                                                     
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <th width="23%" scope="col"> 日志名称</th>    " >>$DONEFILE                                                                                                     
echo "    <th width="77%" scope="col">进程类型</th>    " >>$DONEFILE                                                                                                      
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><b><font color="#336699">操作系统日志</font></b></td>      " >>$DONEFILE                                                                                      
echo "    <td align="left">error</td>" >>$DONEFILE                                                                                                                    
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><b><font color="#336699">数据库日志</font></b></td>     " >>$DONEFILE                                                                                        
echo "    <td align="left">ora_</td>" >>$DONEFILE                                                                                                                     
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "  <tr>" >>$DONEFILE                                                                                                                                             
echo "    <td><b><font color="#336699">OGG日志</font></b></td>  " >>$DONEFILE                                                                                           
echo "    <td align="left">ogg_</td>" >>$DONEFILE                                                                                                                     
echo "  </tr>" >>$DONEFILE                                                                                                                                            
echo "</table>" >>$DONEFILE                                                                                                                                           
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<p>" >>$DONEFILE                                                                                                                                                
echo "<p><br>" >>$DONEFILE                                                                                                                                            
echo "</body>" >>$DONEFILE                                                                                                                                            
echo "</html>" >>$DONEFILE                                                                                                                                            
echo "" >>$DONEFILE
sleep 5
echo ""
echo "Reulst File: $DONEFILE"
echo "The END,Succefull Execution!!!"
