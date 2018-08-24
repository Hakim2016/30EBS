/*CURSOR cur_project(p_projet_id             IN  NUMBER,
                 p_task_id               IN  NUMBER,
                 p_project_catelog1      IN  VARCHAR2,
                 p_project_catelog2      IN  VARCHAR2) 
IS*/
SELECT *
  FROM (SELECT DISTINCT xpmm.project_id,
                        pa.project_status_code,
                        xpmm.project_number,
                        xpmm.task_id,
                        'NORMAL' project_catelog,
                        xpmm.ba_fully_packing_date
        
          FROM xxpa_proj_milestone_mrg_v xpmm,
               pa_projects_all           pa
        
         WHERE xpmm.project_id = pa.project_id
           AND pa.project_type NOT IN (SELECT meaning
                                         FROM xxpa_lookups
                                        WHERE lookup_type = 'XXPA_EQ_REV_SPEC_PROJ_TYPES')
           --AND (xpmm.ba_fully_packing_date <= last_day(p_period) + 0.99999)
        /*UNION ALL
        
        SELECT DISTINCT pa.project_id,
                        pa.project_status_code,
                        pa.segment1 project_number,
                        pt.task_id,
                        'SPECAIL' project_catelog,
                        NULL ba_fully_packing_date
        
          FROM pa_projects  pa,
               pa_tasks     pt,
               xxpa_lookups xl
         WHERE pa.project_id = pt.project_id
           AND pt.task_id = pt.to\*p_task_id*\5724551
           AND (nvl(xl.tag, 'N') != 'Y' OR EXISTS
                (SELECT NULL
                   FROM xxpjm_mfg_status_v xms
                  WHERE xms.task_id = pt.task_id
                    AND xms.scheduled_start_date <= last_day(p_period) + 0.99999))
           AND xl.meaning = pa.project_type
           AND xl.lookup_type = 'XXPA_EQ_REV_SPEC_PROJ_TYPES'
           AND xl.enabled_flag = 'Y'
           AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND
               nvl(xl.end_date_active, trunc(SYSDATE))
           AND xl.description = 'Y'*/) pa

 WHERE project_id = nvl(/*p_projet_id*/2207196, project_id)
   AND task_id = nvl(/*p_task_id*/5724551, task_id)
   AND 'N' = xxpa_utils.get_exclude_flag(task_id)
   AND project_catelog IN (/*p_project_catelog1*/'NORMAL', /*p_project_catelog2*/NULL)
   AND NOT EXISTS
 (SELECT 1
          FROM pa_project_statuses pps
         WHERE pps.project_status_code = pa.project_status_code
           AND pps.status_type = 'PROJECT'
           AND pps.project_status_name IN (SELECT meaning
                                             FROM xxpa_lookups
                                            WHERE lookup_type = 'XXPA_EQ_REV_PROJECT_STATUS'));


SELECT * FROM xxpa_proj_milestone_mrg_v xx WHERE 1=1 ;
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
