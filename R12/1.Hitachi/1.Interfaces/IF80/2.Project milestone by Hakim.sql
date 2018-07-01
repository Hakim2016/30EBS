SELECT to_date(t.period_name, 'MON-YY') period,
       t.period_name,
       t.installation_progress_rate progress,
       --row_id,
       t.org_id,
       t.project_id,
       t.mfg_no,
       t.object_version_number,
       t.created_by,
       t.creation_date,
       t.last_updated_by,
       t.last_update_date
  FROM xxpa_proj_progress_his_v t,
       pa_projects_all          ppa
 WHERE 1 = 1
      --(to_date(period_name, 'MON-YY') < to_date('', 'MON-YY') OR '' IS NULL)
   AND t.org_id = 82
   AND ppa.org_id = t.org_id
   AND t.project_id = ppa.project_id
      --AND ppa.segment1 = '11000363'--'11000958'--'11000363'
   AND t.mfg_no = 'SBC0256-SG' --'SBC0266-SG'--'SAE0191-SG'--'SBC0256-SG'
      
   AND to_date(period_name, 'MON-YY') IN (SELECT MIN(to_date(period_name, 'MON-YY'))
                                            FROM xxpa_proj_progress_his_v v
                                           WHERE v.installation_progress_rate = t.installation_progress_rate
                                             AND v.mfg_no = t.mfg_no
                                             AND v.org_id = t.org_id
                                             AND v.project_id = t.project_id);
