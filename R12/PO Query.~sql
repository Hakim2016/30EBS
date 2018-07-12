SELECT poh.org_id,
       pv.vendor_id,
       pv.vendor_name,
       fu.user_name,
       poh.*,
       pol.*
  FROM po_headers_all poh,
       po_lines_all   pol,
       po_vendors     pv,
       fnd_user       fu
 WHERE 1 = 1
   AND poh.vendor_id = pv.vendor_id
   AND poh.vendor_id = 379
   AND fu.user_id = poh.created_by
      --AND fu.user_name LIKE 'HAND%'
   AND poh.po_header_id = pol.po_header_id
      --AND poh.segment1 = '10062173'--'10000023'
   AND poh.org_id = 82
      --AND poh.cancel_flag = 'N'
   AND poh.approved_flag = 'Y'
      --AND poh.
   AND poh.creation_date >= to_date('20170101', 'yyyymmdd')
--AND poh.segment1 = ''
;
--82/84

SELECT hp.duns_number_c supplier_code,
       pav.vendor_name  supplier_name,
       ph.po_header_id,
       ph.org_id
--INTO x_supplier_code, x_SUPPLIER_name, x_po_header_id
  FROM po_headers_all ph,
       ap_suppliers   pav,
       hz_parties     hp
 WHERE ph.vendor_id = pav.vendor_id(+)
   AND pav.party_id = hp.party_id(+)
      --AND ph.org_id = /*p_org_id*/101
   AND ph.segment1 = /*p_po_number*/
       '10062173';
