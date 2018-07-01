SELECT rt.po_header_id,
       rt.po_line_id,
       poh.segment1 po_num,
       poh.type_lookup_code,
       rt.*
  FROM rcv_transactions rt,
       po_headers_all   poh
 WHERE 1 = 1
   AND rt.transaction_id IN ('4608314', '4860128', '4860130', '4860132', '4860134', '4860136')
   AND rt.po_header_id = poh.po_header_id
--AND rt.po_line_id
;

--requisition
SELECT rt.po_header_id,
       rt.po_line_id,
       poh.segment1 po_num,
       poh.type_lookup_code,
       rt.*
  FROM rcv_transactions           rt,
       po_headers_all             poh,
       po_requisition_headers_all prh
 WHERE 1 = 1
   AND rt.transaction_id IN ('4608314', '4860128', '4860130', '4860132', '4860134', '4860136')
   AND rt.po_header_id = poh.po_header_id
   AND prh.
--AND rt.po_line_id
;

SELECT prh.created_by, prl.attribute1, prl.item_description, prh.*, prl.*
  FROM po_requisition_headers_all prh,
  po_requisition_lines_all prl
 WHERE 1 = 1
 AND prh.org_id = 82
 AND prh.requisition_header_id = prl.requisition_header_id
   AND prh.segment1 = '1200043980';
