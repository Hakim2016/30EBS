-- 
-- Trace file（追踪文件)是以trc为后续的文本文件,它记录了各种sql操作及所消耗的时间等,
-- 根据trace文件我们就可以了解哪些sql导致了系统的性能瓶颈，进而采取恰当的方式调优.

-- 查看系统当前会不会产生trace文件，以及trace文件目录
SELECT *
  FROM v$parameter vp
 WHERE 1 = 1
   AND vp.name IN ('sql_trace', 'user_dump_dest');
   
/*
    NUM  NAME  TYPE  VALUE  DISPLAY_VALUE  ISDEFAULT  ISSES_MODIFIABLE  ISSYS_MODIFIABLE  ISINSTANCE_MODIFIABLE  ISMODIFIED  ISADJUSTED  ISDEPRECATED  ISBASIC  DESCRIPTION  UPDATE_COMMENT  HASH
1  1758  user_dump_dest  2  /mt4/u01/UAT/db/tech_st/11.2.0/admin/UAT_gscmpsvdbt01/diag/rdbms/uat/UAT/trace  /mt4/u01/UAT/db/tech_st/11.2.0/admin/UAT_gscmpsvdbt01/diag/rdbms/uat/UAT/trace	TRUE	FALSE	IMMEDIATE	TRUE	FALSE	FALSE	TRUE	FALSE	User process dump directory		2332088509
2	1821	sql_trace	1	FALSE	FALSE	TRUE	TRUE	IMMEDIATE	TRUE	FALSE	FALSE	TRUE	FALSE	enable SQL trace		750089050
*/
   
-- Trace 生效、失效
alter session set sql_trace=true; -- 当前session生效
alter SYSTEM  set sql_trace=true; -- 当前system生效
alter session set sql_trace=FALSE; -- 当前session失效
alter SYSTEM  set sql_trace=FALSE; -- 当前system失效

-- 获取Trace文件
-- 生效trace后，运行SQL或PLSQL程序，到trace文件目录获取trace文件(.trc)

-- 修改Trace文件目录
--如果是oracle 11g 以下的版本则:alter system set user_dump_dest = 'd:\oracle\trace';(注意:trace文件就直接生成在trace目录下)
--如果是oracle 11g.则alter system set user_diagnostic_dest = 'd:\oracle\trace';
--(注意:trace文件不会直接生成在trace目录下.trace目录下会生成其他很多目录.
--trace文件的具体目录是:d:\oracle\trace\diag\rdbms\orli11r2\orli11r2\trace.其中的orli11r2是SID)

-- 获取当前Trace 文件名
SELECT d.value || '/' || lower(rtrim(i.instance, chr(0))) || '_ora_' || p.spid || '.trc'
--INTO v_result
  FROM (SELECT p.spid
          FROM v$mystat  m,
               v$session s,
               v$process p
         WHERE m.statistic# = 1
           AND s.sid = m.sid
           AND p.addr = s.paddr) p,
       (SELECT t.instance
          FROM v$thread    t,
               v$parameter v
         WHERE v.name = 'thread'
           AND (v.value = '0' OR to_char(t.thread#) = v.value)) i,
       (SELECT VALUE
          FROM v$parameter
         WHERE NAME = 'user_dump_dest') d;
         
-- 使用tkprof分析trace文件
-- 命令：tkprof .trc_file_path .txt_new_file_name aggregate=yes sys=no waits=yes sort=fchela
-- 例子：tkprof /mt4/u01/UAT/db/tech_st/11.2.0/admin/UAT_gscmpsvdbt01/diag/rdbms/uat/UAT/trace/UAT_ora_2759.trc pjl_ora_tkprof.txt aggregate=yes sys=no waits=yes sort=fchela
