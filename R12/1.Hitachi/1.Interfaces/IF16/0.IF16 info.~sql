/*
IF16
Quotation & MFG from GOE
XXMRP:Project Forecast Interface Import (IF16)
xxmrp_pro_forecast_import_pkg.main
XXMRP_FORECAST_IMPORT_INT
*/

--xxmrp_pro_forecast_import_pkg;.main

SELECT xx.quotation_number,
       xx.*
  FROM xxmrp_forecast_import_int xx
 WHERE 1 = 1
      --AND xx.creation_date 
   AND xx.quotation_number = '18T01978T0'--'18T03510T0' --'17J04810J2'
--AND rownum = 1
;

SELECT COUNT(*) cnt
  FROM xxmrp_forecast_import_int xfi
 WHERE xfi.group_id = 48761--p_int_rec.group_id
   AND xfi.action_group_id = 0--p_int_rec.action_group_id
   AND xfi.interface_type = 'Quotation'--p_int_rec.interface_type
   --AND (xfi.mfg_no = p_int_rec.mfg_no OR p_int_rec.mfg_no IS NULL)
   AND (xfi.quotation_number = '18T03510T0'/*p_int_rec.quotation_number OR p_int_rec.quotation_number IS NULL*/)
   AND (xfi.quotation_line = '001'/*p_int_rec.quotation_line OR p_int_rec.quotation_line IS NULL*/)
   AND (xfi.spec_name = p_int_rec.spec_name OR p_int_rec.spec_name IS NULL)
   AND xfi.unique_id <> --p_int_rec.unique_id
   ;

SELECT *
  FROM fnd_user xx
 WHERE 1 = 1
   AND xx.user_id = 4554;
