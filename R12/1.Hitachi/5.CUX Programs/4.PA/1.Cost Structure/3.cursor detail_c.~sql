--CURSOR details_c IS
      SELECT DISTINCT xpcsd.structure_id,
                      pet.expenditure_type,
                      xpcsd.org_id,
                      hou.name             organization_name,
                      xpcsd.project_id,
                      xpcsd.actual_task_id task_id
        FROM xxpa_proj_cost_stc_dtls   xpcsd,
             hr_all_organization_units hou,
             xxpa_proj_cost_structure  xpcs,
             pa_expenditure_types      pet
       WHERE xpcsd.request_id = g_request_id
         AND xpcsd.org_id = hou.organization_id
         AND xpcsd.structure_id = xpcs.structure_id
         AND xpcs.expenditure_type_id = pet.expenditure_type_id;
