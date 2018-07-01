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
  fnd_global.apps_initialize(user_id => 4270, resp_id => 51249, resp_appl_id => 660);
  mo_global.init('M');
  FOR rec IN (SELECT ool.attribute4,
                     ool.ordered_item,
                     ool.project_id,
                     ool.task_id,
                     (SELECT pt.top_task_id
                        FROM pa_tasks pt
                       WHERE 1 = 1
                         AND pt.task_id = ool.task_id) top_task_id
                FROM oe_order_headers_all ooh,
                     oe_order_lines_all   ool
               WHERE 1 = 1
                 AND ooh.header_id = ool.header_id
                 AND ooh.order_number = '53020400'
                 AND ooh.org_id = 101 --HBS
                 AND ool.ordered_item IN ('JED0210-VN')
              --('JED0210-VN', 'JED0211-VN', 'JED0212-VN', 'JED0219-VN', 'JED0220-VN', 'JED0225-VN')
               ORDER BY ool.line_number)
  LOOP
    l_request_id := fnd_request.submit_request(application => 'XXPA',
                                               program     => 'XXPAUPDATESTATUS',
                                               start_time  => '2017/04/27 04:00:00',
                                               argument1   => 'BA',
                                               argument2   => rec.project_id,
                                               argument3   => rec.top_task_id);
    dbms_output.put_line(l_request_id);
    COMMIT;
  END LOOP;

END;
