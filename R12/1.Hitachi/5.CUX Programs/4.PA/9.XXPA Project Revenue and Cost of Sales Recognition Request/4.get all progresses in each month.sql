--CURSOR his_c(p_task_id NUMBER, p_period_name VARCHAR2) IS
      SELECT xpmmh.period_name,xpmmh.installation_progress_rate
        FROM xxpa_proj_milestone_manage_his xpmmh
       WHERE xpmmh.task_id = 5725841--p_task_id
         AND nvl(xpmmh.installation_progress_rate, 0) >=
             0--g_baseline_progress
         AND xpmmh.period_name = 'JUN-18'--p_period_name
         
         ;
