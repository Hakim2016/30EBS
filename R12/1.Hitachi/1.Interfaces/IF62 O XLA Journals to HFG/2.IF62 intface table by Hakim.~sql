--IF62
SELECT intf.creation_date,
       intf.interface_file_name,
       intf.blart, --trx type
       --intf.zterm               payment_term,
       --intf.zlsch,
       intf.xblnr, --trx num
       intf.waers               curr,
       intf.kursf               rate,
       intf.dr_cr_flag drcr,
       intf.hkont hfg_acc,
       intf.zz0001 gscm_subacc,
       --intf.yygaddinfo,
       intf.wrbtr               etr_amt,
       intf.dmbtr               loc_amt,
       intf.ledger_id,
       intf.source_table,
       intf.source_header_id,
       intf.request_id,
       intf.*
  FROM xxgl_accounting_hfg_int intf
 WHERE 1 = 1
      --AND intf.hkont LIKE '1161400990'--'11454%'--SAP accounting there exists account mapping
      --1161400990 Raw Material in SAP
      --AND intf.blart = 'Y8' --'KR'--'Y6'--'Y3'--AR--'Y6'--Y6_for_AP
      AND intf.ledger_id = 2021--2041
      --AND intf.dmbtr = -27.28
      --AND intf.zterm = 'FB50'
   /*AND intf.source_header_id = --28360654--21996198--33034601
      
       (SELECT xah.ae_header_id--, xte.transaction_number, xte.application_id, xte.ledger_id
          FROM xla.xla_transaction_entities xte,
               xla_ae_headers               xah
         WHERE 1 = 1
           AND xte.entity_id = xah.entity_id
           AND xte.ledger_id = 2041
           AND xte.application_id = 222--222--707--222 --707
           AND xte.transaction_number = 'JPE-17000322'--'50532595'--'SPE-18000075'
           --and xah.ae_header_id = 22822729--29058160
        )*/
       AND intf.XBLNR --LIKE '%75371468'--'%5235833%' --= 48629279--48624778
       IN (/*'PO_5085765',
'PO_5235833',--PO_5235833 PO_5235833 PO+rcv.trx_id
'PO_5236949',
'INV_64512074',--INV+mmt.trx_id
'INV_69864747',
'INV_70045973'*/
'INV_75370664',
'INV_75371468'
)
       --= 'JPE-17000322'--'SPE-18000075'--'10000017446'
      --IN (48624778, 48629281)
      --IN (50532595)
      --IN ('2003/2363/2364MAY18')--('58422148APR18')--('SPR-15000019','SPR-17000417')
      --AND trunc(intf.creation_date) >= to_date('2018-01-02', 'yyyy-mm-dd')
      --AND intf.BUDAT LIKE '201811%'
      --AND intf.creation_date >= SYSDATE - 35--to_date('2018-08-01 12:00:00','yyyy-mm-dd hh24:mi:ss')
      --AND intf.request_id = 15904416
      --AND intf.interface_file_name LIKE '201808021B0701ENGLJL0009%'
      --AND intf.interface_file_name = '201808021B0701ENGLJL0009.TXT'--LIKE '201808021B0701ENGLJL0009%'
      --AND intf.interface_file_name = '201808021B0701ENGLJL0009.TXT'
      --AND rownum = 1
      --AND intf.group_id >= 1340218
      --AND intf.xblnr = 'SG00050348*7'
      --AND to_char(NVL(intf.dmbtr,intf.WRBTR))LIKE '68.%'
   --AND rownum = 1
 ORDER BY intf.group_id DESC,
 intf.source_header_id,
 --intf.source_line_id,
 intf.dr_cr_flag DESC
 

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

SELECT *
  FROM xla_ae_headers xah
 WHERE 1 = 1
   AND xah.ae_header_id = 29058160
