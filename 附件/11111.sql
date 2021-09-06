set termout       off
set echo          off
set feedback      off
set heading       off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on

set pagesize 50000
set linesize 175
set long     2000000000

clear buffer computes columns breaks

define filename=oracle


--Basic variable Information
COLUMN tdate NEW_VALUE _date NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY') tdate FROM dual;

COLUMN time NEW_VALUE _time NOPRINT
SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') time FROM dual;

COLUMN date_time NEW_VALUE _date_time NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS') date_time FROM dual;

COLUMN date_time_timezone NEW_VALUE _date_time_timezone NOPRINT
SELECT TO_CHAR(systimestamp, 'Mon DD, YYYY (') || TRIM(TO_CHAR(systimestamp, 'Day')) || TO_CHAR(systimestamp, ') "at" HH:MI:SS AM') || TO_CHAR(systimestamp, ' "in Timezone" TZR') date_time_timezone FROM dual;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN dbid NEW_VALUE _dbid NOPRINT
SELECT dbid dbid FROM v$database;

COLUMN platform_id NEW_VALUE _platform_id NOPRINT
SELECT platform_id platform_id FROM v$database;

COLUMN platform_name NEW_VALUE _platform_name NOPRINT
SELECT platform_name platform_name FROM v$database;

COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'MM/DD/YYYY HH24:MI:SS') startup_time FROM v$instance;

COLUMN host_name NEW_VALUE _host_name NOPRINT
SELECT host_name host_name FROM v$instance;

COLUMN html_name NEW_VALUE _html_name NOPRINT
SELECT 'database_'||TO_CHAR(SYSDATE,'YYYYMMDD')||'.html' html_name FROM dual;

COLUMN instance_name NEW_VALUE _instance_name NOPRINT
SELECT instance_name instance_name FROM v$instance;

COLUMN instance_number NEW_VALUE _instance_number NOPRINT
SELECT instance_number instance_number FROM v$instance;

COLUMN thread_number NEW_VALUE _thread_number NOPRINT
SELECT thread# thread_number FROM v$instance;

COLUMN cluster_database NEW_VALUE _cluster_database NOPRINT
SELECT value cluster_database FROM v$parameter WHERE name='cluster_database';

COLUMN cluster_database_instances NEW_VALUE _cluster_database_instances NOPRINT
SELECT value cluster_database_instances FROM v$parameter WHERE name='cluster_database_instances';

COLUMN reportRunUser NEW_VALUE _reportRunUser NOPRINT
SELECT user reportRunUser FROM dual;


--Module Information
set heading on

set markup html on spool on preformat off entmap on -
head ' -
  <title>Digitalchina Snapshot Oracle Database Report</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:9pt Arial,Helvetica,sans-serif; color:Black; background:white; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 9pt Arial,Helvetica,sans-serif; color:white; background:#0066cc; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} -
    a                 {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#663300; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'WIDTH="90%" BORDER="1"' 

spool  /home/oracle/scripts/&_html_name

set markup html on entmap off



--Header Show

prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Day Information</u></b></font></center>  


prompt 
prompt <a name="巡检"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>日巡检-数据库部分</b></font><hr align="left" width="460"> 

prompt <table width="90%" border="1"> -
<tr><th align="left" width="20%">Run Date / Time / Timezone</th><td width="80%"><tt>&_date_time_timezone</tt></td></tr> -
<tr><th align="left" width="20%">Host Name</th><td width="80%"><tt>&_host_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Name</th><td width="80%"><tt>&_dbname</tt></td></tr> -
<tr><th align="left" width="20%">Database ID</th><td width="80%"><tt>&_dbid</tt></td></tr> -
<tr><th align="left" width="20%">Global Database Name</th><td width="80%"><tt>&_global_name</tt></td></tr> -
<tr><th align="left" width="20%">Instance Name</th><td width="80%"><tt>&_instance_name</tt></td></tr> -
<tr><th align="left" width="20%">Instance Number</th><td width="80%"><tt>&_instance_number</tt></td></tr> -
<tr><th align="left" width="20%">Thread Number</th><td width="80%"><tt>&_thread_number</tt></td></tr> -
<tr><th align="left" width="20%">Database Block Size</th><td width="80%"><tt>&_blocksize</tt></td></tr> -
<tr><th align="left" width="20%">Report Run User</th><td width="80%"><tt>&_reportRunUser</tt></td></tr> -
</table>


--Information of Tablespace
prompt <a name="表空间使用率"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>表空间使用率</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN status                                  HEADING '是否在线'            ENTMAP off
COLUMN name                                    HEADING '表空间名称'   ENTMAP off
COLUMN type        FORMAT a12                  HEADING '表空间类型'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                  HEADING '区管理模式'         ENTMAP off
COLUMN segment_mgt FORMAT a9                   HEADING '段管理模式'         ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING '表空间大小'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999  HEADING '剩余空间'   ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999  HEADING '使用空间'   ENTMAP off
COLUMN pct_used                                HEADING '表空间使用率'         ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>'   OF ts_size used free ON report

SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name || '</font></b>'                               name
  , d.contents                                          type
  , d.extent_management                                 extent_mgt
  , d.segment_space_management                          segment_mgt
  , round(NVL(a.bytes/1024/1024, 0) ,2)                 ts_size
  , round(NVL(f.bytes/1024/1024, 0) ,2)                 free
  , round(NVL(a.bytes/1024/1024,0) - NVL(f.bytes/1024/1024, 0) ,2) used
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM 
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_data_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes) bytes
      from dba_free_space
      group by tablespace_name
    ) f
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = f.tablespace_name(+)
  AND NOT (
    d.extent_management like 'LOCAL'
    AND
    d.contents like 'TEMPORARY'
  )
UNION ALL 
SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name  || '</font></b>'                              name
  , d.contents                                   type
  , d.extent_management                          extent_mgt
  , d.segment_space_management                   segment_mgt
  , round(NVL(a.bytes/1024/1024, 0) ,2)                             ts_size
   , round(NVL(a.bytes/1024/1024 - NVL(t.bytes,0)/1024/1024, 0),2)   free
  , round(NVL(t.bytes/1024/1024, 0),2)                              used
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL(t.bytes / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM
    sys.dba_tablespaces d
  , ( select tablespace_name, round(sum(bytes)/1024/1024,2) bytes
      from dba_temp_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, round(sum(bytes_cached)/1024/1024,2) bytes
      from v$temp_extent_pool
      group by tablespace_name
    ) t
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = t.tablespace_name(+)
  AND d.extent_management like 'LOCAL'
  AND d.contents like 'TEMPORARY'
ORDER BY 2;



--DataFiles
prompt <a name="数据文件"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>表空间数据文件是否自动扩展</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace                                   HEADING '表空间名称'  ENTMAP off
COLUMN filename                                     HEADING '数据文件'                      ENTMAP off
COLUMN filesize        FORMAT 999,999,999,999,999   HEADING '数据文件大小'                     ENTMAP off
COLUMN autoextensible                               HEADING '是否自动扩展'                ENTMAP off
COLUMN increment_by    FORMAT 999,999,999,999,999   HEADING '下次扩展'                          ENTMAP off
COLUMN maxbytes        FORMAT 999,999,999,999,999   HEADING '最大可扩展'                           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF filesize ON report

SELECT /*+ ordered */
    '<font color="#336699"><b>' || d.tablespace_name  || '</b></font>'  tablespace
  , '<tt>' || d.file_name || '</tt>'                                    filename
  , round(d.bytes/1024/1024,2)  filesize
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , round(d.increment_by* e.value/1024/1024,2)                                             increment_by
  , round(d.maxbytes/1024/1024,2)                                                          maxbytes
FROM
    sys.dba_data_files d
  , v$datafile v
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
UNION
SELECT
    '<font color="#336699"><b>' || d.tablespace_name || '</b></font>'   tablespace 
  , '<tt>' || d.file_name  || '</tt>'                                   filename
  , round(d.bytes/1024/1024,2)                                                             filesize
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , round(d.increment_by* e.value/1024/1024,2)                                             increment_by
  , round(d.maxbytes/1024/1024,2)                                                     maxbytes
FROM
    sys.dba_temp_files d
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
UNION
SELECT
    '<font color="#336699"><b>[ ONLINE REDO LOG ]</b></font>'
  , '<tt>' || a.member || '</tt>'
  , round(b.bytes/1024/1024,2)   
  , null
  , null
  , null
FROM
    v$logfile a
  , v$log b
WHERE
    a.group# = b.group#
UNION
SELECT
    '<font color="#336699"><b>[ CONTROL FILE    ]</b></font>'
  , '<tt>' || a.name || '</tt>'
  , null
  , null
  , null
  , null
FROM
    v$controlfile a
ORDER BY
    1
  , 2;



--ASM Used
prompt <a name="ASM"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>ASM 空间使用情况</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name HEADING '磁盘组名称' ENTMAP off
COLUMN total HEADING '磁盘组总大小' ENTMAP off
COLUMN free HEADING '磁盘组剩余空间' ENTMAP off
COLUMN state HEADING '磁盘组状态' ENTMAP off

CLEAR COMPUTES BREAKS

select 
'<div align="left"><font color="#336699"><b>' || name || '</b></font></div>' name
,total_mb/1024 total
,free_mb/1024 free
,state
from v$asm_diskgroup;






--Archive Mode
prompt <a name="归档模式"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>归档空间模式</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN db_log_mode                  FORMAT a95                HEADING 'Database|Log Mode'             ENTMAP off
COLUMN log_archive_start            FORMAT a95                HEADING '是否开启归档'            ENTMAP off
COLUMN oldest_online_log_sequence   FORMAT 999999999999999    HEADING '老的的日志序列'   ENTMAP off
COLUMN current_log_seq              FORMAT 999999999999999    HEADING '当前日志序列'         ENTMAP off

SELECT
    '<div align="center"><font color="#663300"><b>' || d.log_mode           || '</b></font></div>'    db_log_mode
  , '<div align="center"><font color="#663300"><b>' || p.log_archive_start  || '</b></font></div>'    log_archive_start
  , c.current_log_seq                                   current_log_seq
  , o.oldest_online_log_sequence                        oldest_online_log_sequence
FROM
    (select
         DECODE(   log_mode
                 , 'ARCHIVELOG', 'Archive Mode'
                 , 'NOARCHIVELOG', 'No Archive Mode'
                 , log_mode
         )   log_mode
     from v$database
    ) d
  , (select
         DECODE(   log_mode
                 , 'ARCHIVELOG', 'Enabled'
                 , 'NOARCHIVELOG', 'Disabled')   log_archive_start
     from v$database
    ) p
  , (select a.sequence#   current_log_seq
     from   v$log a
     where  a.status = 'CURRENT'
       and thread# = &_thread_number
    ) c
  , (select min(a.sequence#) oldest_online_log_sequence
     from   v$log a
     where  thread# = &_thread_number
    ) o
/



--Flash back
prompt <a name="闪回区"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>快速闪回区状态</b></font><hr align="left" width="460">

prompt <b>Current location, disk quota, space in use, space reclaimable by deleting files, and number of files in the Flash Recovery Area</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name               FORMAT a75                  HEADING '闪回区位置'               ENTMAP off
COLUMN space_limit        FORMAT 99,999,999,999,999   HEADING '闪回区空间大小'        ENTMAP off
COLUMN space_used         FORMAT 99,999,999,999,999   HEADING '闪回区使用大小'         ENTMAP off
COLUMN space_used_pct     FORMAT 999.99               HEADING '闪回区使用百分比'             ENTMAP off
COLUMN space_reclaimable  FORMAT 99,999,999,999,999   HEADING '可回收空间'  ENTMAP off
COLUMN pct_reclaimable    FORMAT 999.99               HEADING '可回收空间百分比'      ENTMAP off
COLUMN number_of_files    FORMAT 999,999              HEADING '闪回区文件数量'    ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || name || '</b></font></div>'    name
  , space_limit                                                                       space_limit
  , space_used                                                                        space_used
  , ROUND((space_used / DECODE(space_limit, 0, 0.000001, space_limit))*100, 2)        space_used_pct
  , space_reclaimable                                                                 space_reclaimable
  , ROUND((space_reclaimable / DECODE(space_limit, 0, 0.000001, space_limit))*100, 2) pct_reclaimable
  , number_of_files                                                                   number_of_files
FROM
    v$recovery_file_dest
ORDER BY
    name;


CLEAR COLUMNS BREAKS COMPUTES

COLUMN file_type                  FORMAT a75     HEADING '闪回区文件类型'
COLUMN percent_space_used                        HEADING '空间使用百分比'
COLUMN percent_space_reclaimable                 HEADING '回收空间百分比'
COLUMN number_of_files            FORMAT 999,999 HEADING '文件数量'

SELECT
    '<div align="center"><font color="#336699"><b>' || file_type || '</b></font></div>' file_type
  , percent_space_used                                                                  percent_space_used
  , percent_space_reclaimable                                                           percent_space_reclaimable
  , number_of_files                                                                     number_of_files
FROM
    v$flash_recovery_area_usage;


--Jobs Information
prompt <a name="Job"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>数据库Job</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job_id     FORMAT a75             HEADING 'Job ID'           ENTMAP off
COLUMN username   FORMAT a75             HEADING '用户名'             ENTMAP off
COLUMN what       FORMAT a175            HEADING '内容'             ENTMAP off
COLUMN next_date  FORMAT a110            HEADING '下次执行日期'    ENTMAP off
COLUMN interval   FORMAT a75             HEADING '时间间隔'         ENTMAP off
COLUMN last_date  FORMAT a110            HEADING '最后一次执行日期'    ENTMAP off
COLUMN failures   FORMAT a75             HEADING '是否失败'         ENTMAP off
COLUMN broken     FORMAT a75             HEADING '是否挂起'          ENTMAP off

SELECT
    DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || job || '</div></font></b>'
            , '<b><font color="#336699"><div align="center">' || job || '</div></font></b>')    job_id
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || log_user || '</font></b>'
            , log_user )    username
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || what || '</font></b>'
            , what )        what
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')      next_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || interval || '</font></b>'
            , interval )    interval
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')    last_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || NVL(failures, 0) || '</div></font></b>'
            , '<div align="center">'                          || NVL(failures, 0) || '</div>')    failures
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || broken || '</div></font></b>'
            , '<div align="center">'                          || broken || '</div>')      broken
FROM
    dba_jobs
ORDER BY
    job;

--oromptme="rman备份"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN 备份信息</b></font><hr align="left" width="460">

prompt <b>Last 10 RMAN backup jobs</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN backup_name           FORMAT a130   HEADING '备份名称'          ENTMAP off
COLUMN start_time            FORMAT a75    HEADING '开始时间'           ENTMAP off
COLUMN elapsed_time          FORMAT a75    HEADING '执行时间'         ENTMAP off
COLUMN status                              HEADING '备份状态'               ENTMAP off
COLUMN input_type                          HEADING '类型'           ENTMAP off
COLUMN output_device_type                  HEADING '备份介质'       ENTMAP off
COLUMN input_size                          HEADING '源文件大小'           ENTMAP off
COLUMN output_size                         HEADING '输出大小'          ENTMAP off
COLUMN output_rate_per_sec                 HEADING '速率'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || r.command_id                                   || '</font></b></div>'  backup_name
  , '<div nowrap align="right">'            || TO_CHAR(r.start_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , '<div nowrap align="right">'            || r.time_taken_display                           || '</div>'             elapsed_time
  , DECODE(   r.status
            , 'COMPLETED'
            , '<div align="center"><b><font color="darkgreen">' || r.status || '</font></b></div>'
            , 'RUNNING'
            , '<div align="center"><b><font color="#000099">'   || r.status || '</font></b></div>'
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || r.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || r.status || '</font></b></div>'
    )                                                                                       status
  , r.input_type                                                                            input_type
  , r.output_device_type                                                                    output_device_type
  , '<div nowrap align="right">' || r.input_bytes_display           || '</div>'  input_size
  , '<div nowrap align="right">' || r.output_bytes_display          || '</div>'  output_size
  , '<div nowrap align="right">' || r.output_bytes_per_sec_display  || '</div>'  output_rate_per_sec
FROM
    (select
         command_id
       , start_time
       , time_taken_display
       , status
       , input_type
       , output_device_type
       , input_bytes_display
       , output_bytes_display
       , output_bytes_per_sec_display
     from v$rman_backup_job_details
     order by start_time DESC
    ) r
WHERE
    rownum < 11;


--dead block
prompt <a name="data_pump_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>死锁部分</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN sid FORMAT a75 HEADING 'Session id' ENTMAP off
COLUMN serial FORMAT a75 HEADING 'Serial' ENTMAP off
COLUMN schema HEADING '用户名' ENTMAP off
COLUMN osuser HEADING '系统用户名' ENTMAP off
COLUMN process HEADING '系统进程' ENTMAP off
COLUMN machine HEADING '主机名'  ENTMAP off
COLUMN terminal HEADING '终端'  ENTMAP off
COLUMN logon_time HEADING '登录时间' ENTMAP off


SELECT '<div align="left"><font color="#336699"><b>' || s.sid || '</b></font></div>' sid,s.serial# serial,s.schemaname schema,s.osuser osuser,s.process process,s.machine machine,s.terminal terminal,s.logon_time logon_time FROM v$session s,v$lock l WHERE s.sid = l.sid AND l.block=1 ORDER BY sid;



--Basic Block
prompt <a name="data_pump_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>普通阻塞</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN sid HEADING 'Session id' ENTMAP off
COLUMN serial HEADING 'Serial' ENTMAP off
COLUMN lockmode HEADING '锁模式' ENTMAP off
COLUMN objectname FORMAT a75 HEADING '对象名称' ENTMAP off


SELECT '<div align="left"><font color="#336699"><b>' || l.session_id || '</b></font></div>' sid,s.serial# serial,l.locked_mode lockmode,o.object_name objectname FROM v$locked_object l, all_objects o, v$session s WHERE l.object_id = o.object_id AND l.session_id = s.sid ORDER BY sid, s.serial#;

exit

