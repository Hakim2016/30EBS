/*CURSOR cur_transaction IS*/
SELECT *
  FROM (SELECT xpmm.proj_milestone_id,
               xpmm.operating_unit,
               xpmm.org_id,
               xpmm.project_id,
               pa.project_status_code,
               pa.project_type,
               xpmm.project_number,
               pt.task_id,
               xpmm.mfg_no mfg_number,
               xpmm.ba_fully_packing_date,
               
               'NORMAL' project_catelog
        
          FROM xxpa_proj_milestone_mrg_v xpmm,
               pa_tasks                  pt,
               pa_projects_all           pa
        
         WHERE xpmm.project_id = pt.project_id
           AND xpmm.mfg_no = pt.task_number
           AND xpmm.project_id = pa.project_id
           AND pa.project_type NOT IN (SELECT meaning
                                         FROM xxpa_lookups
                                        WHERE lookup_type = 'XXPA_EQ_REV_SPEC_PROJ_TYPES')
        UNION ALL
        
        SELECT pt.task_id proj_milestone_id,
               ou.name    operating_unit,
               pa.org_id,
               
               pa.project_id,
               pa.project_status_code,
               pa.project_type,
               pa.segment1,
               pt.task_id,
               pt.task_number mfg_number,
               NULL ba_fully_packing_date,
               'SPECAIL' project_catelog
        
          FROM pa_projects        pa,
               pa_tasks           pt,
               hr_operating_units ou
        
         WHERE pa.org_id = ou.organization_id
           AND pt.project_id = pa.project_id
           AND pt.task_id = pt.top_task_id
           AND pa.project_type IN (SELECT meaning
                                     FROM xxpa_lookups
                                    WHERE lookup_type = 'XXPA_EQ_REV_SPEC_PROJ_TYPES'
                                      AND description = 'Y')) pa

 WHERE project_id = nvl(p_projet_id, project_id)
   AND task_id = nvl(p_task_id, task_id)
   AND project_catelog IN (p_project_catelog1, p_project_catelog2)
   AND NOT EXISTS
 (SELECT 1
          FROM pa_project_statuses pps
         WHERE pps.project_status_code = pa.project_status_code
           AND pps.status_type = 'PROJECT'
           AND pps.project_status_name IN (SELECT meaning
                                             FROM xxpa_lookups
                                            WHERE lookup_type = 'XXPA_EQ_REV_PROJECT_STATUS'));
