/*SELECT * from fnd_user fu where 1=1 AND fu.user_name = '300429';*/

/*
SELECT t.responsibility_id, t.*
  FROM fnd_responsibility t
 WHERE 1 = 1
   AND t.responsibility_key LIKE '101_FA_SUPER_USER'--'%HBS%SCM_SUPER_USER%'
   
   ;
   --HEA SCM SUPER USER

select * from fnd_user fu where fu.user_name = 'HAND_HKM';--4270
--org_id      Resp_id     Resp_app_id
--HEA 82      50676       660
--HBS 101     51249       660
--SHE 84      50778       20005
*/

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 51249,
                             resp_appl_id => 660);
  mo_global.init('M');
  
END;*/

SELECT fcp.user_concurrent_program_name program,
       fcp.concurrent_program_name      short_name,
       --fcp.executable_id,
       --fef.executable_id,
       fef.executable_name,
       fef.execution_file_name,
       fef.execution_method_code,
       fef.APPLICATION_ID,
       (SELECT fa.application_short_name
          FROM fnd_application fa
         WHERE 1 = 1
           AND fa.application_id = fef.application_id) app_short_name,
       fef.application_name,
       fef.description
  FROM fnd_concurrent_programs_vl fcp, fnd_executables_form_v fef
 WHERE 1 = 1
   AND fcp.executable_id = fef.executable_id
      --AND fcp.concurrent_program_name = 'XXARBTOG4'--'XXPAJIPATP'--'XXPAB001'--'XXPAJIPATP'--'XXPAFGTXN'--'CUXHNETGLACN'--'INCTCM'--'XXPAB003'
   AND upper(fcp.user_concurrent_program_name) LIKE 'CUX:科目明细账%工程物资科目明细账';


DECLARE
  l_request_id NUMBER;
BEGIN
  fnd_global.APPS_INITIALIZE(user_id      => 1670,--300429 user_name
                             resp_id      => 50778,
                             resp_appl_id => 20003);--CUX
  mo_global.init('M');
  /*FOR REC IN (SELECT PA.END_DATE
                FROM pa_periods_all pa
               WHERE pa.org_id = 84
                 AND pa.status IN ('C', 'O')
                 AND pa.end_date < to_date('2018-04-27', 'yyyy-mm-dd')
               ORDER BY PA.END_DATE ASC) LOOP*/
    l_request_id := fnd_request.submit_request(application => 'CUX',--'XXPA',
                                               program     => 'CUXFAENGMATRPT',
                                               --start_time  => to_char(SYSDATE, 'yyyy/mm/dd hh24:mi:ss'),/*'2019/02/25 04:00:00',*/
                                               argument1   => '2021',--NULL,
                                               argument2   => '2018-12',/*to_char(REC.END_DATE + 1,
                                                                      'YYYY/MM/DD'))*/
                                               argument3   => '1605010101');
    dbms_output.put_line(l_request_id);
    COMMIT;
  --END LOOP;

END;
