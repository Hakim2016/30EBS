--Cost structure-info
/*
XXPAB006
XXPA:Generate Expenditure Batch For Cost Structure
xxpa_proj_cost_structure_pkg.main

*/

xxpa_proj_cost_structure_pkg;--.main


SELECT *
  FROM xxpa_lookups xl
 WHERE 1 = 1
   AND xl.lookup_type = 'XXPA_SPEC_MODEL_TYPES'
   AND xl.enabled_flag = 'Y'
   AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND nvl(xl.end_date_active, trunc(SYSDATE))
   ORDER BY to_number(xl.lookup_code)
   ;
