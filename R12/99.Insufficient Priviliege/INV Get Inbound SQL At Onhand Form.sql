SELECT SUM(ms.to_org_primary_quantity) inbound
  FROM mtl_supply           ms,
       rcv_shipment_headers rsh,
       rcv_shipment_lines   rsl
 WHERE 1 = 1
   AND ms.supply_type_code <> 'RECEIVING'
   AND ms.destination_type_code = 'INVENTORY'
   AND rsh.shipment_header_id(+) = ms.shipment_header_id
   AND rsl.shipment_line_id(+) = ms.shipment_line_id
   AND ms.to_organization_id = 86 --:inb_to_organization_id
   AND ms.item_id = 49793 --:inb_item_id
   AND ms.supply_type_code NOT IN ('RECEIVING')
      --AND ms.to_organization_id = :inb_to_organization_id
   AND ms.destination_type_code = 'INVENTORY'
   AND ms.supply_type_code <> 'RECEIVING'
 GROUP BY ms.item_id,
          ms.to_organization_id;
