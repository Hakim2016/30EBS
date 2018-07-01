/*
SELECT t.responsibility_id, t.*
  FROM fnd_responsibility t
 WHERE 1 = 1
   AND t.responsibility_key LIKE '%HBS%SCM_SUPER_USER%';
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

DECLARE
  l_request_id NUMBER;
BEGIN
  fnd_global.APPS_INITIALIZE(user_id      => 4270,
                             resp_id      => 50778,
                             resp_appl_id => 20005);
  mo_global.init('M');
  FOR REC IN (SELECT PA.END_DATE
                FROM pa_periods_all pa
               WHERE pa.org_id = 84
                 AND pa.status IN ('C', 'O')
                 AND pa.end_date < to_date('2018-04-27', 'yyyy-mm-dd')
               ORDER BY PA.END_DATE ASC) LOOP
    l_request_id := fnd_request.submit_request(application => 'XXPA',
                                               program     => 'XXPAB008',
                                               start_time  => '2017/04/27 04:00:00',
                                               argument1   => NULL,
                                               argument2   => to_char(REC.END_DATE + 1,
                                                                      'YYYY/MM/DD'));
    dbms_output.put_line(l_request_id);
    COMMIT;
  END LOOP;

END;
