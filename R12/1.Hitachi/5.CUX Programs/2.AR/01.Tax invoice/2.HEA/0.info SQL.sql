/*
HEA Tax invoice
*/

SELECT tih.created_by,
tih.status_code,
til.line_number,
       --tih.last_updated_by,
       tih.*
  FROM xxar_tax_invoice_headers_all tih,
       xxar_tax_invoice_lines_all   til
 WHERE 1 = 1
   AND tih.header_id = til.header_id
   AND tih.invoice_number --= 'SPR-17000345'
       IN (
       --'SPE-17000215'
       'SPR-18000527'
       )
       
       --AND tih.status_code = 'CANCELLED'--'INVOICED'----<> 'INVOICED'
       AND tih.org_id = 82
       /*AND EXISTS
       (SELECT 1 FROM  RA_CUSTOMER_TRX_ALL arh WHERE 1=1 AND arh.trx_number =  tih.invoice_number
       AND arh.org_id = arh.org_id)*/
       ORDER BY tih.header_id DESC
       ;

SELECT *
  FROM xxar_tax_invoice_headers_all tih
 WHERE 1 = 1
   AND tih.invoice_number --= 'SPR-17000345'
       IN ('SPE-18000024',
           'SPE-18000098',
           'SPE-18000100',
           'SPE-18000105', --
           'SPE-18000110',
           'SPE-18000111',
           'SPE-18000143',
           'SPE-18000152');

SELECT *
  FROM fnd_user xx
 WHERE 1 = 1
   AND xx.user_id = 1312;
