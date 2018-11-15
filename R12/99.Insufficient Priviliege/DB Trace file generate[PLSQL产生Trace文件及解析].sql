-- 
-- Trace file��׷���ļ�)����trcΪ�������ı��ļ�,����¼�˸���sql�����������ĵ�ʱ���,
-- ����trace�ļ����ǾͿ����˽���Щsql������ϵͳ������ƿ����������ȡǡ���ķ�ʽ����.

-- �鿴ϵͳ��ǰ�᲻�����trace�ļ����Լ�trace�ļ�Ŀ¼
SELECT *
  FROM v$parameter vp
 WHERE 1 = 1
   AND vp.name IN ('sql_trace', 'user_dump_dest');
   
/*
    NUM  NAME  TYPE  VALUE  DISPLAY_VALUE  ISDEFAULT  ISSES_MODIFIABLE  ISSYS_MODIFIABLE  ISINSTANCE_MODIFIABLE  ISMODIFIED  ISADJUSTED  ISDEPRECATED  ISBASIC  DESCRIPTION  UPDATE_COMMENT  HASH
1  1758  user_dump_dest  2  /mt4/u01/UAT/db/tech_st/11.2.0/admin/UAT_gscmpsvdbt01/diag/rdbms/uat/UAT/trace  /mt4/u01/UAT/db/tech_st/11.2.0/admin/UAT_gscmpsvdbt01/diag/rdbms/uat/UAT/trace	TRUE	FALSE	IMMEDIATE	TRUE	FALSE	FALSE	TRUE	FALSE	User process dump directory		2332088509
2	1821	sql_trace	1	FALSE	FALSE	TRUE	TRUE	IMMEDIATE	TRUE	FALSE	FALSE	TRUE	FALSE	enable SQL trace		750089050
*/
   
-- Trace ��Ч��ʧЧ
alter session set sql_trace=true; -- ��ǰsession��Ч
alter SYSTEM  set sql_trace=true; -- ��ǰsystem��Ч
alter session set sql_trace=FALSE; -- ��ǰsessionʧЧ
alter SYSTEM  set sql_trace=FALSE; -- ��ǰsystemʧЧ

-- ��ȡTrace�ļ�
-- ��Чtrace������SQL��PLSQL���򣬵�trace�ļ�Ŀ¼��ȡtrace�ļ�(.trc)

-- �޸�Trace�ļ�Ŀ¼
--�����oracle 11g ���µİ汾��:alter system set user_dump_dest = 'd:\oracle\trace';(ע��:trace�ļ���ֱ��������traceĿ¼��)
--�����oracle 11g.��alter system set user_diagnostic_dest = 'd:\oracle\trace';
--(ע��:trace�ļ�����ֱ��������traceĿ¼��.traceĿ¼�»����������ܶ�Ŀ¼.
--trace�ļ��ľ���Ŀ¼��:d:\oracle\trace\diag\rdbms\orli11r2\orli11r2\trace.���е�orli11r2��SID)

-- ��ȡ��ǰTrace �ļ���
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
         
-- ʹ��tkprof����trace�ļ�
-- ���tkprof .trc_file_path .txt_new_file_name aggregate=yes sys=no waits=yes sort=fchela
-- ���ӣ�tkprof /mt4/u01/UAT/db/tech_st/11.2.0/admin/UAT_gscmpsvdbt01/diag/rdbms/uat/UAT/trace/UAT_ora_2759.trc pjl_ora_tkprof.txt aggregate=yes sys=no waits=yes sort=fchela
