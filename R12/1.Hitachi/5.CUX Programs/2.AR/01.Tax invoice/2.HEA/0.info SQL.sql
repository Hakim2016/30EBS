/*
HEA Tax invoice
*/

SELECT tih.created_by,
       --tih.last_updated_by,
       tih.*
  FROM xxar_tax_invoice_headers_all tih,
       xxar_tax_invoice_lines_all   til
 WHERE 1 = 1
   AND tih.header_id = til.header_id
   AND tih.invoice_number = 'SPR-17000345';
   
   SELECT * FROM fnd_user xx WHERE 1=1 AND xx.user_id = 1312;
