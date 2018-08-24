--1.IF61
/*
XARB005
XXAR:Receipt Apply Import HFG

XXAR_AR_RECEIPT_APPLY_HFG_INT
xxar_receipt_apply_imp_hfg_pkg.main

=========
1.import new receipt
2.write off the AR with the receipt
3.receipt should be created sucessfully before write-off
*/

--xxar_receipt_apply_imp_hfg_pkg;--.main

SELECT intf.xzahl,
       intf.augbl "Receipt Number",
       intf.belnr "Doc Num",
       intf.*
  FROM xxar_ar_receipt_apply_hfg_int intf
 WHERE 1 = 1
   --AND intf.creation_date > SYSDATE - 1
      AND intf.process_status = 'E'
      --AND intf.process_message = 'Customer Code not exists. GL Date is invalid, please check. '
   --AND intf.group_id = 5534
   --AND intf.belnr = '4800008891'
   ;
