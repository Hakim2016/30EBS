
/*
IF66
XXGL:Accounting Data Outbound HFG(ERV)
xxgl_account_exp_erv_hfg_pkg.main
XXGL_ACCOUNTING_HFG_INT
*/

SELECT *
  FROM xxgl_accounting_hfg_int xx
 WHERE 1 = 1
 --AND xx.blart = 'Y8'
 --AND xx.xblnr = 'PO_5311848'
   --AND xx.request_id = 16727638 --16727497
   --AND xx.creation_date >= SYSDATE - 2
   --AND xx.ZUONR = '10070815' --Assignment No
   AND xx.reference1 = 'IF66'
   AND xx.ledger_id = 2021
   --AND xx.budat = --Posting Date in the Document
   ORDER BY xx.unique_id DESC
   ;

SELECT xx.request_id,
       COUNT(*)
  FROM xxgl_accounting_hfg_int xx
 WHERE 1 = 1
   --AND xx.creation_date >= SYSDATE - 2
   AND xx.request_id >= 16727489
 GROUP BY xx.request_id
 ORDER BY xx.request_id
--HAVING COUNT(*) = 0
;
