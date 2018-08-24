SELECT proj_milestone_id,
             project_id,
             task_id,
             org_id,
             cos_add_up_amount
        FROM xxpa_proj_milestone_manage
       WHERE project_id = 2207196--nvl(p_project_id, project_id)
         AND task_id = 5724679--nvl(p_task_id, task_id)
;         
         --org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;*/
