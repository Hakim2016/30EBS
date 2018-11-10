/*
Before use this scripts, please refer to 
  Re-Open a Closed Inventory Accounting Period (Doc ID 472631.1)
*/

SELECT acct_period_id      period,
       open_flag,
       period_name         NAME,
       period_start_date,
       schedule_close_date,
       period_close_date
  FROM org_acct_periods
 WHERE organization_id = 83--&org_id
 ORDER BY 1 DESC,
          2;
--------------------------------------------
UPDATE org_acct_periods
   SET open_flag = 'Y', period_close_date = NULL, summarized_flag = 'N'
 WHERE organization_id = 83--&&org_id
   AND acct_period_id = 151038-->= 151038&&acct_period_id
   ;

DELETE mtl_period_summary
 WHERE organization_id = 83--&org_id
   AND acct_period_id = 151038-->= &acct_period_id
   ;

DELETE mtl_period_cg_summary
 WHERE organization_id = 83--&org_id
   AND acct_period_id = 151038-->= &acct_period_id;
;
DELETE mtl_per_close_dtls
 WHERE organization_id = 83--&org_id
   AND acct_period_id = 151038-- >= &acct_period_id;
;
DELETE cst_period_close_summary
 WHERE organization_id = 83--&org_id
   AND acct_period_id = 151038-- >= &acct_period_id;
;
COMMIT;
