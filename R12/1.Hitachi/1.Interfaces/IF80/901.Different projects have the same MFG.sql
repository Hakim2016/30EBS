/*BEGIN
  fnd_global.APPS_INITIALIZE(user_id      => 4270,
                             resp_id      => 50778,
                             resp_appl_id => 20005);
  mo_global.init('M');
END;*/
SELECT DISTINCT intf.org_id,
                intf.task_id,
                intf.mfg_num,
                ooh.order_number,
                pa.segment1         proj_num,
                intf.eq_er_category,
                pa.project_type,
                ott.name            order_type,
                intf.actual_month,
                intf.sale_amount,
                intf.additional_flag
  FROM xxpa_cost_gcpm_int     intf,
       pa_projects_all        pa,
       oe_order_headers_all   ooh,
       oe_transaction_types_v ott
 WHERE 1 = 1
   AND intf.project_id = pa.project_id
   AND EXISTS (SELECT 1
          FROM xxpa_cost_gcpm_int xcgi
         WHERE xcgi.mfg_num = intf.mfg_num
           AND xcgi.task_id <> intf.task_id
           AND xcgi.org_id = intf.org_id
           AND xcgi.eq_er_category = intf.Eq_Er_Category)

   AND intf.source_header_id = ooh.header_id
   AND ooh.order_type_id = ott.transaction_type_id
 ORDER BY intf.org_id, intf.mfg_num,intf.task_id
 ;
