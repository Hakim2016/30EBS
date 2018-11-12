
-- �Ѽ�Concurrent Request �� SQL Trace
/*
 1. System Administrator > Concurrent > Program > Define
    "Enable Trace" checkbox ��
    ע�⣺���������"Enable Trace",�ռ�����Sql Trace��������binds and waits.
    (Checking the Trace Check box on the Concurrent Program gives an Event 10046 Level 8 trace. 
    So even if the trace is set for Binds and Waits on the Submission form once the concurrent program 
    is encountered in the trace it will reset to level 8 so no binds will be present in the trace after that point.)
    
    
 2. Concurrent: Allow Debugging
    Responsibility: System Administrator
    Navigate: Profiles > System
    Query Profile Option: Concurrent: Allow Debugging
    Set profile to Yes
    ���Profile������ó�Yes����ô������Concurrent Request��ʱ��Debug Options��ͱ��Enable״̬�����ΪNo����ôDebug Options��ťΪ���ԣ�
    
 3. ����Debug Options�� ���ύ����ʱ���ύ��������ϣ�
    ��ѡSQL Trace����ѡ��"SQL Trace with Binds and Waits"

 4. �ҵ���Ӧ��sql trace�ļ�
    SELECT NAME,
           VALUE
      FROM v$parameter
     WHERE NAME LIKE 'user_dump_dest';
     App Server�ϣ��л��ϱߵ�·����Ȼ�� ls *Concurrent Request ID*
*/


-- Find Trace File Name
-- Run the following SQL to find out the Raw trace name and location for the concurrent program.  The SQL prompts the user for the request id

SELECT 'Request id: ' || request_id,
       prog.user_concurrent_program_name,
       'Trace id: ' || oracle_process_id,
       'Trace Flag: ' || req.enable_trace,
       'Trace Name:  ' || dest.value || '/' || lower(dbnm.value) || '_ora_' || oracle_process_id || '.trc',
       'Prog. Name: ' || prog.user_concurrent_program_name,
       'File Name: ' || execname.execution_file_name || execname.subroutine_name,
       'Status : ' || decode(phase_code, 'R', 'Running') || '-' || decode(status_code, 'R', 'Normal'),
       'SID Serial: ' || ses.sid || ',' || ses.serial#,
       'Module : ' || ses.module
  FROM fnd_concurrent_requests    req,
       v$session                  ses,
       v$process                  proc,
       v$parameter                dest,
       v$parameter                dbnm,
       fnd_concurrent_programs_vl prog,
       fnd_executables            execname
 WHERE 1 = 1 --req.request_id = &request
   AND req.oracle_process_id = proc.spid(+)
   AND proc.addr = ses.paddr(+)
   AND dest.name = 'user_dump_dest'
   AND dbnm.name = 'db_name'
   AND req.concurrent_program_id = prog.concurrent_program_id
   AND req.program_application_id = prog.application_id
      --- and prog.application_id = execname.application_id  
   AND prog.executable_application_id = execname.application_id
   AND prog.executable_id = execname.executable_id;

-- To check the timeline of the request :
SELECT request_id,
       to_char(request_date, 'DD-MON-YYYY HH24:MI:SS') request_date,
       to_char(requested_start_date, 'DD-MON-YYYY HH24:MI:SS') requested_start_date,
       to_char(actual_start_date, 'DD-MON-YYYY HH24:MI:SS') actual_start_date,
       to_char(actual_completion_date, 'DD-MON-YYYY HH24:MI:SS') actual_completion_date,
       to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') current_date,
       round((nvl(actual_completion_date, SYSDATE) - actual_start_date) * 24, 2) duration
  FROM fnd_concurrent_requests
 WHERE request_id = to_number('&p_request_id');
