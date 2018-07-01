--1.process revenue
--project revenue & cost
/*CURSOR lines_c(p_type       VARCHAR2,
                   p_project_id NUMBER,
                   p_task_id    NUMBER,
                   p_pa_period  VARCHAR2) IS*/
      SELECT task_id, eq_interface_flag, hand_over_date
        FROM xxpa_proj_milestone_manage /*_all*/ xpmm
       WHERE 'Y' = xxpa_proj_revenue_cos_pkg.get_process_flag(p_type,
                                                              xpmm.task_id,
                                                              p_project_id,
                                                              p_task_id,
                                                              xpmm.org_id,
                                                              p_pa_period);
