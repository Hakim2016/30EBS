select * from iby.iby_external_payees_all
  where payee_party_id = 465719;
  
SELECT * FROM AP_INTERFACE_REJECTIONS t
WHERE 1=1
AND t.creation_date > TRUNC(SYSDATE);

SELECT * FROM ap_invoices_interface intf
WHERE 1=1
AND intf.invoice_id = 170596;
