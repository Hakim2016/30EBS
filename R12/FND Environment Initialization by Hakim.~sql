
SELECT t.responsibility_id, t.*
  FROM fnd_responsibility t
 WHERE 1 = 1
   AND t.responsibility_key LIKE '%HBS%SCM_SUPER_USER%';
   --HEA SCM SUPER USER

select * from fnd_user fu where fu.user_name = 'HAND_HKM';
--org_id      Resp_id     Resp_app_id
--HBS 101     51249       660        
--HEA 82      50676       660
--HET 141     51272       20005
--SHE 84      50778       20005

BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  
END;
