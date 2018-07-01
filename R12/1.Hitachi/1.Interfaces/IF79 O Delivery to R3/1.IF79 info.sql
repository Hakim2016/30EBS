--IF79
XXAR_DELIVERY_TO_R3_INT;
xxar_Delivery_to_R3_pkg;--.main
/*
XXARDTOR3
XXAR: Delivery Interface outbound GSCM to R3


*/

SELECT intf.creation_date,
       intf.so_number,
       intf.hbs_sg_mfg_number mfg,
       intf.delivery_date,
       intf.backup_delivery_dates,
       intf.file_name,
       intf.*
  FROM xxar_delivery_to_r3_int intf
 WHERE 1 = 1
   --AND intf.ledger_id = 2041 --HBS
      --AND intf.creation_date > trunc(SYSDATE)
      --AND intf.so_number IN ('53020155')
   AND intf.so_number IN ('E3020044')--('E3020400')--, 'E3020422')
  --AND intf.hbs_sg_mfg_number IN ('JAC0084-IN','JAC0085-IN','JAC0086-IN','JAC0087-IN')
--AND intf.hbs_sg_mfg_number IN ('JED0210-VN','JED0211-VN','JED0212-VN','JED0219-VN','JED0220-VN','JED0225-VN')
--AND intf.hbs_sg_mfg_number IN ('JFA0245-VN','JFA0246-VN','JFA0247-VN','JFA0248-VN','JFA0249-VN','JFA0250-VN','JFA0251-VN','JFA0252-VN')
 ORDER BY intf.creation_date,
 intf.so_number,
          intf.hbs_sg_mfg_number;
