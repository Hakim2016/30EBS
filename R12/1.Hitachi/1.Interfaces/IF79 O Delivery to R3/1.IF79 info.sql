--IF79
XXAR_DELIVERY_TO_R3_INT;
xxar_Delivery_to_R3_pkg;--.main
/*
XXARDTOR3
XXAR: Delivery Interface outbound GSCM to R3


*/

SELECT intf.revise_flag,
       intf.version,
       intf.creation_date,
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
   /*AND intf.so_number IN --('12004014')
       ('E3020117')--('E3020117') --('E3020044')--('E3020400')--, 'E3020422')
AND intf.hbs_sg_mfg_number IN 
('JHA0068-AE')*/
--AND intf.revise_flag = 2
 ORDER BY intf.creation_date desc,
          intf.so_number,
          intf.hbs_sg_mfg_number;
          
DELETE FROM xxar_delivery_to_r3_int intf 
WHERE 1=1 
 AND intf.so_number IN 
       ('E3020003')
       AND intf.version = '2';
          
