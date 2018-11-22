--IF62
SELECT intf.creation_date,
       intf.interface_file_name,
       intf.blart, --trx type
       intf.zterm payment_term,
       intf.zlsch,
       intf.xblnr, --trx num
       intf.ledger_id,
       intf.source_table,
       intf.*
  FROM xxgl_accounting_hfg_int intf
 WHERE 1 = 1
      --AND intf.blart = 'Y6' --'KR'--'Y6'--'Y3'--AR--'Y6'--Y6_for_AP
      --AND intf.ledger_id = 2021
   --AND intf.zterm = 'FB50'
      --AND intf.XBLNR 
      --= 'SPE-18000075'--'10000017446'
      --IN ('2003/2363/2364MAY18')--('58422148APR18')--('SPR-15000019','SPR-17000417')
      --AND trunc(intf.creation_date) = to_date('2018-08-02', 'yyyy-mm-dd')
      AND intf.creation_date >= SYSDATE - 1/24--to_date('2018-08-01 12:00:00','yyyy-mm-dd hh24:mi:ss')
      --AND intf.request_id = 15904416
      --AND intf.interface_file_name LIKE '201808021B0701ENGLJL0009%'
      --AND intf.interface_file_name = '201808021B0701ENGLJL0009.TXT'--LIKE '201808021B0701ENGLJL0009%'
      --AND intf.interface_file_name = '201808021B0701ENGLJL0009.TXT'
      --AND rownum = 1
   --AND intf.group_id >= 1340218
   AND intf.xblnr = 'SG00050348*7'
   ORDER BY intf.group_id DESC

;

SELECT t.xblnr,
       t.hkont,
       nvl(t.yygaddinfo, 0),
       t.hkont || '.' || nvl(t.yygaddinfo, 0),
       t.dr_cr_flag,
       t.wrbtr, --外币金额
       t.dmbtr, --折换的本位币
       t.wmwst, --税金额（单独计算）
       t.mwsts,
       decode(t.dr_cr_flag, 'dr', decode(t.dmbtr, NULL, t.wrbtr, t.dmbtr), decode(t.dmbtr, NULL, -t.wrbtr, -t.dmbtr)) amount,
       decode(t.dr_cr_flag, 'dr', decode(t.mwsts, NULL, t.wmwst, t.mwsts), decode(t.mwsts, NULL, -t.wmwst, -t.mwsts)) tax,
       t.interface_file_name
--,t.*
  FROM apps.xxgl_accounting_hfg_int t
 WHERE 1 = 1
   AND t.ledger_id = '2021'
--AND t.budat between '20150701' and '20150831'
 AND
--AND XBLNR in ('10000006560','10000006707')
;

SELECT *
  FROM xxgl_acct_details_lines_hfg t
 WHERE 1 = 1
   AND t.ledger_id = 2021
   AND t.source_table = 'XLA_AE_LINES';
