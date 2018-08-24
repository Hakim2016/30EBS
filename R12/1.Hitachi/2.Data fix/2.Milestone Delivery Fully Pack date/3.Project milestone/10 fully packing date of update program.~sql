--fully packing date of milstone   
 SELECT trunc(xmps.fully_packing_date),ppa.segment1, pa.task_id,xmps.*
        FROM xxinv_mfg_full_packing_sts xmps,
             pa_tasks                   pa,
             pa_projects_all            ppa --update by steven.wang 2017/02/07 add org_id for get_ba_fully_packing_date
       WHERE xmps.mfg_number = pa.task_number
            --update by steven.wang 2017/02/07 add org_id for get_ba_fully_packing_date begin
         AND pa.project_id = ppa.project_id
         AND ppa.org_id = xmps.org_id
            --update by steven.wang 2017/02/07 add org_id for get_ba_fully_packing_date end
         --AND pa.task_id = --6144328--p_task_id;
         AND ppa.segment1= '12004014'
;
