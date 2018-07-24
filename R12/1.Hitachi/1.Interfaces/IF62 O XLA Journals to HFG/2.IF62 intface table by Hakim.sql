--IF62
SELECT intf.blart, intf.ZLSCH, intf.XBLNR,intf.ledger_id, intf.source_table, intf.*
  FROM xxgl_accounting_hfg_int intf
 WHERE 1 = 1
 --AND intf.blart = 'KR'--'Y6'--'Y3'--AR--'Y6'--Y6_for_AP
 --AND intf.ledger_id= 2021
 --AND intf.XBLNR IN ('2003/2363/2364MAY18')--('58422148APR18')--('SPR-15000019','SPR-17000417')
 AND intf.creation_date > to_date('2018-07-18','yyyy-mm-dd')
--AND intf.request_id = 15904416

;

SELECT * FROM xxgl_acct_details_lines_hfg t
WHERE 1=1
AND t.ledger_id = 2021
AND t.source_table='XLA_AE_LINES'
;
