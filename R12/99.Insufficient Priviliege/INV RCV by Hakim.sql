SELECT rt.transaction_id,
       rt.transaction_type,
       poh.segment1,
       rt.destination_type_code,
       rt.quantity,
       --rt.amount,
       rt.subinventory,
       rt.locator_id,
       ppa.segment1,
       pt.task_number,
       rt.project_id,
       rt.task_id,
       rt.*
  FROM rcv_transactions rt,
  po_headers_all poh,
  pa_projects_all ppa,
  pa_tasks pt
  
 WHERE 1 = 1
 AND ppa.project_id = pt.project_id
 AND rt.project_id = ppa.project_id(+)
 AND rt.task_id = pt.task_id
 AND rt.organization_id = 121
 AND rt.po_header_id = poh.po_header_id
   --AND rt.transaction_id IN (4654211, 4654212)
   AND poh.segment1 = '10000415'
   --AND pt.task_number = 'JBL0262-IN.EQ'
   ;
   
SELECT rt.transaction_id,
       rt.transaction_type,
       poh.segment1,
       rt.destination_type_code,
       rt.quantity,
       rt.quantity_billed,
       rt.amount_billed,
       --rt.amount,
       rt.subinventory,
       rt.locator_id,
       /*ppa.segment1,
       pt.task_number,*/
       rt.project_id,
       rt.task_id,
       rt.*
  FROM rcv_transactions rt,
  po_headers_all poh
  WHERE 1 = 1
 AND rt.organization_id = 83--121
 AND rt.po_header_id = poh.po_header_id
   --AND rt.transaction_id IN (4654211, 4654212)
   AND poh.segment1 = '10070231'--'10000415'
   --AND pt.task_number = 'JBL0262-IN.EQ'
   ;  
   SELECT * FROM RCV_VRC_TXS_V v
   WHERE 1=1
   AND v.transaction_id IN (4654211, 4654212);
   
   SELECT * FROM RCV_VRC_HDS_V v
   WHERE 1=1
   AND v.receipt_num = '85822'
   --AND v.organization_id = 83--SG1
   ;
