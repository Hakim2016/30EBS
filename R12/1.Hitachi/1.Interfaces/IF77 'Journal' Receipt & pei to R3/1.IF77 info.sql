--info-IF77
--AP
XXAP_JOURNAL_TO_R3_DATA_INT;
xxap_journal_to_R3_pkg;--.main
/*
XXAPJTOR3
xxap_journal_to_R3_pkg.main
XXAP: Journal Interface outbound to R3

*/
SELECT intf.price,
       intf.creation_date,
       intf.*
  FROM xxap_journal_to_r3_data_int intf
 WHERE 1 = 1
      --AND intf.po_number = '10066959'--'10000073'
      --AND intf.hbs_sg_mfg_number = 'SAC0792-SG'--'JAJ0028-IN'
   AND intf.so_number = 'E3020442'--'E3020044'
   --AND intf.creation_date > SYSDATE - 60
/*   AND NOT EXISTS (SELECT 'Y'
          FROM xxap_journal_to_r3_data_int t2
         WHERE 1 = 1
           AND t2.po_number = '10000073'
           AND t2.hbs_sg_mfg_number = 'JAJ0028-IN'
           AND abs(t2.price) = abs(intf.price)
           AND t2.unique_id <> intf.unique_id)*/
--AND intf.source_id
 --ORDER BY abs(intf.price)
;
