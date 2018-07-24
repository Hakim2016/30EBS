--WEADI-Upload Expense AP
/*
XXAP:Expense Invoice Uploading
XXAPEXPINVIMP
xxap_expinvoice_upload_pkg.main
*/

xxap_expinvoice_upload_pkg;--.main

SELECT * FROM xxap_invoices_interface xaphi
WHERE 1=1
AND xaphi.invoice_num = 'GE18070129';

SELECT * FROM xxap_invoice_lines_interface;

SELECT * FROM ap_invoices_interface;

SELECT * FROM ap_invoice_lines_interface;
