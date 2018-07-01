/*
SELECT t.responsibility_id, t.*
  FROM fnd_responsibility t
 WHERE 1 = 1
   AND t.responsibility_key LIKE '%HEA%SCM_SUPER_USER%';
   --HEA SCM SUPER USER

select * from fnd_user fu where fu.user_name = 'HAND_HKM';--4270
--org_id      Resp_id     Resp_app_id
--HEA 82      50676       660
--SHE 84      50778       20005
*/

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  
END;*/

DECLARE
  l_result     BOOLEAN;
  l_request_id NUMBER;
  l_exit       BOOLEAN;
BEGIN
  fnd_global.apps_initialize(user_id => 4270, resp_id => 50676, resp_appl_id => 660);
  mo_global.init('M');
  --l_result := fnd_request.add_layout('XXWIP', 'XXWIPR002', 'en', 'US', 'PDF');

  l_request_id := fnd_request.submit_request(application => 'XXGL',
                                             program     => 'XXGLAD1',
                                             start_time  => SYSDATE,
                                             argument1   => xxfnd_interface_transaction_s.nextval,
                                             argument2   => SYSDATE,
                                             argument3   => 'HEA Ledger');

  IF l_request_id > 0 THEN
    --l_exit := app_form.quietcommit();
    dbms_output.put_line('The request id = ' || l_request_id);
  
  ELSE
    dbms_output.put_line('Fail to submit the request');
  
    --RAISE form_trigger_failure;
  END IF;
END;
