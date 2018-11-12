
SELECT t.responsibility_id,tl.responsibility_name,tl.language, t.*
  FROM fnd_responsibility t,
  fnd_responsibility_tl tl
 WHERE 1 = 1
 AND t.responsibility_id = tl.responsibility_id
 AND tl.language = 'US'
   --AND t.responsibility_key LIKE --'%HBS%SCM_SUPER_USER%'
   --'COST%MANAGEMENT%'
   AND tl.responsibility_name LIKE 'Cost Management%SLA'
   ;
   --HEA SCM SUPER USER

select * from fnd_user fu where fu.user_name = 'HAND_HKM';
--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86

BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;
