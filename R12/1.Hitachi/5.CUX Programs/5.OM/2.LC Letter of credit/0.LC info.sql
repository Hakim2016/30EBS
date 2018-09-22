--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 51249,
                             resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;
*/
SELECT *
  FROM xxom_lc_maintenance_v xx
 WHERE 1 = 1
   --AND xx.lc_number = '18/BMLCS/18185'
   AND xx.customer_number = 'HL00000038'
   AND xx.creation_date >= to_date('20170801','yyyymmdd')
   ORDER BY xx.line_id DESC
   ;

SELECT *
  FROM xxom_lc_maintenance xlm
 WHERE 1 = 1
   AND xlm.lc_number = '18/BMLCS/18185';
