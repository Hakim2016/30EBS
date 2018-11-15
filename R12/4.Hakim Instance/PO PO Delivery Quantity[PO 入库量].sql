SELECT poh.segment1,
       poh.po_header_id,
       poh.creation_date,
       pol.line_num,
       pol.quantity,       
       pol.cancel_flag,
       poll.shipment_num,
       poll.quantity,
       poll.quantity_cancelled,
       tmp.distribution_num,
       tmp.*
  FROM (SELECT pod.org_id,
               pod.attribute15,
               pod.distribution_num,
               pod.line_location_id,
               pod.po_distribution_id,
               pod.destination_type_code,
               pod.quantity_ordered,
               pod.quantity_cancelled,
               pod.quantity_ordered - pod.quantity_cancelled net_quantity_ordered,
               pod.project_id,
               pod.task_id,
               (SELECT nvl(SUM(ail.quantity_invoiced), 0)
                  FROM ap_invoice_lines_all ail
                 WHERE 1 = 1
                   AND ail.po_header_id = pod.po_header_id
                   AND (ail.po_distribution_id IS NOT NULL AND ail.po_distribution_id = pod.po_distribution_id OR
                       ail.po_distribution_id IS NULL AND ail.po_line_location_id = pod.line_location_id)) quantity_invoiced,
               (SELECT nvl(SUM(mmt.transaction_quantity), 0)
                  FROM mtl_material_transactions mmt,
                       rcv_transactions          rt,
                       rcv_transactions          prt
                 WHERE 1 = 1
                   AND rt.parent_transaction_id = prt.transaction_id
                   AND rt.po_distribution_id IS NOT NULL
                   AND mmt.rcv_transaction_id = rt.transaction_id
                   AND rt.po_distribution_id = pod.po_distribution_id) quantity_delivery
          FROM po_distributions_all pod
         WHERE 1 = 1
        -- AND pod.project_id = l_project_id -- 82959
        -- AND pod.task_id = l_task_id -- 1068882
        -- AND nvl(pod.attribute15, '###') = nvl(l_group_part, '###')
        
        ) tmp,
       po_line_locations_all poll,
       po_lines_all pol,
       po_headers_all poh
 WHERE 1 = 1
   AND tmp.line_location_id = poll.line_location_id
   AND poll.po_line_id = pol.po_line_id
   AND pol.po_header_id = poh.po_header_id
   AND tmp.org_id = 84
   AND poll.ship_to_organization_id = 86
   AND tmp.project_id IS NOT NULL
      --AND poh.segment1 = '787778'
   AND tmp.destination_type_code IN ('INVENTORY')
   AND nvl(tmp.net_quantity_ordered, -10000) <> nvl(tmp.quantity_delivery, -20000)
   AND EXISTS (SELECT 1
          FROM rcv_transactions rts
         WHERE 1 = 1
           AND tmp.po_distribution_id = rts.po_distribution_id)
 ORDER BY poh.po_header_id DESC;
