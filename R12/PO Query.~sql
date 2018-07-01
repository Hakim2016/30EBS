SELECT poh.org_id,
       fu.user_name,
       poh.*,
       pol.*
  FROM po_headers_all poh,
       po_lines_all   pol,
       fnd_user       fu
 WHERE 1 = 1
   AND fu.user_id = poh.created_by
      --AND fu.user_name LIKE 'HAND%'
   AND poh.po_header_id = pol.po_header_id
   AND poh.segment1 = '10062173'--'10000023'
      --AND poh.org_id = 82
   --AND poh.cancel_flag = 'N'
   AND poh.approved_flag = 'Y'
--AND poh.creation_date >= to_date('20180301','yyyymmdd')
--AND poh.segment1 = ''
;
--82/84

SELECT HP.Duns_Number_c supplier_code,
       PAV.VENDOR_NAME  SUPPLIER_name,
       PH.PO_HEADER_ID,ph.org_id
  --INTO x_supplier_code, x_SUPPLIER_name, x_po_header_id
  FROM PO_HEADERS_ALL PH, AP_SUPPLIERS PAV, HZ_PARTIES HP
 WHERE PH.VENDOR_ID = pav.vendor_id(+)
   AND PAV.PARTY_ID = HP.PARTY_ID(+)
   --AND ph.org_id = /*p_org_id*/101
   AND ph.segment1 = /*p_po_number*/'10062173';
