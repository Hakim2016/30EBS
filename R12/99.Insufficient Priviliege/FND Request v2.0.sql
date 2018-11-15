SELECT t.request_id,
       t.program,
       t.requestor,
       ppf.full_name,
       t.argument_text,
       t.request_date,
       t.actual_start_date,
       t.actual_completion_date,
       round(to_number(t.actual_completion_date - t.actual_start_date) * 24, 2) during_time,
       t.phase_code,
       t.status_code,
       t.parent_request_id
  FROM apps.fnd_conc_req_summary_v t,
       apps.per_people_f           ppf,
       apps.fnd_user               fu
 WHERE 1 = 1
      --and t.request_id = 12755112
      --and t.concurrent_program_id = 113574 --program id
      --and program = 'xxpa:project cost analysis (she/het) new'
      --'interface program:if62 (xxgl:accounting data outbound hfg)' --program name
   AND t.requestor = fu.user_name
   AND fu.employee_id = ppf.person_id
   AND ppf.effective_end_date = to_date('4712/12/31', 'yyyy/mm/dd')
   AND t.request_date BETWEEN to_date('2018/05/03', 'yyyy/mm/dd') AND /*sysdate --*/
       to_date('2018/05/04', 'yyyy/mm/dd')
      --AND t.requestor NOT IN ('SYSADMIN', 'HAND_ADMIN')
   AND t.program <> 'XXFND:Interface Manager';

SELECT vl.concurrent_program_name short_name,
       vl.user_concurrent_program_name,
       v.execution_file_name,
       vl.*
  FROM fnd_concurrent_programs_vl vl,
       fnd_executables_form_v     v
 WHERE 1 = 1
   AND vl.concurrent_program_name = v.executable_name
   AND vl.concurrent_program_name = 'XXGLAD3';
