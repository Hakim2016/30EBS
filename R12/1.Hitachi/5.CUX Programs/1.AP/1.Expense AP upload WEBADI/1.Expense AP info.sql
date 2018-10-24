--WEADI-Upload Expense AP
/*
XXAP:Expense Invoice Uploading
XXAPEXPINVIMP
xxap_expinvoice_upload_pkg.main
*/

xxap_expinvoice_upload_pkg;--.main
--after successfully created, data will be deleted
SELECT * FROM xxap_invoices_interface xaphi
WHERE 1=1
AND xaphi.invoice_num = 'TG18090176'--'655-RMS-0490854'--'GE18070129'

;

SELECT * FROM xxap_invoice_lines_interface;

SELECT * FROM ap_invoices_interface;

SELECT * FROM ap_invoice_lines_interface;


SELECT ffvv.flex_value,
           ffvv.flex_value_meaning,
           ffvv.description,
           ffvv.*
      /*INTO lv_flex_value,
           lv_flex_value_meaning*/
      FROM fnd_flex_value_sets ffvs,
           fnd_flex_values_vl  ffvv
     WHERE ffvs.flex_value_set_name = 'XXHEA_PAYMENT METHOD'
       AND ffvv.flex_value_set_id = ffvs.flex_value_set_id
       --AND ffvv.flex_value_meaning = p_payment_method
       
       ;
