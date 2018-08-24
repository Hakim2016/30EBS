/*
XXPAPREFG
XXPA: Project FG Completion Data Collection
xxpa_cost_carry_over_pub.prepare_main
*/

/*
XXPAFGTXN
XXPA: Finish Goods Transfer
xxpa_cost_carry_over_pub.transfer_main
*/

--xxpa_cost_carry_over_pub;--.transfer_main

SELECT DISTINCT xcfd.source_table
  FROM xxpa_cost_flow_dtls_all xcfd
 WHERE 1 = 1;

SELECT xl.lookup_code,
       xl.meaning
  FROM xxpa_lookups xl
 WHERE 1 = 1
   AND xl.lookup_type = 'XXPA_FG_COMPLETION_STATUS'
   AND enabled_flag = 'Y'
 ORDER BY lookup_code;

SELECT *
  FROM pa_expenditure_types pet
 WHERE 1 = 1
   AND pet.expenditure_category = 'FG Transfer';

SELECT *
  FROM pa_expenditure_types pet
 WHERE 1 = 1
   AND pet.expenditure_category = 'FG Completion';
