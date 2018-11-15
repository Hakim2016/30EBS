SELECT prh.org_id,
       prh.segment1            req_number,
       prl.requisition_line_id,
       prl.line_num            req_line_num,
       prl.line_location_id,
       poll.po_header_id,
       poh.segment1            po_order_number
  FROM apps.po_requisition_headers_all prh,
       apps.po_requisition_lines_all   prl,
       apps.po_line_locations_all      poll,
       apps.po_headers_all             poh
 WHERE 1 = 1
   AND prh.requisition_header_id = prl.requisition_header_id
   AND prl.line_location_id = poll.line_location_id
   AND poll.po_header_id = poh.po_header_id
   AND prh.org_id = 84
   AND prh.segment1 IN ('1200019259');
