SELECT rt.transaction_id,
       rt.transaction_type,
       rt.destination_type_code,
       rt.amount,
       rt.subinventory,
       rt.locator_id,
       rt.project_id,
       rt.task_id,
       rt.*
  FROM rcv_transactions rt
 WHERE 1 = 1
   AND rt.transaction_id IN (4654211, 4654212);
   
   SELECT * FROM RCV_VRC_TXS_V v
   WHERE 1=1
   AND v.transaction_id IN (4654211, 4654212);
   
   SELECT * FROM RCV_VRC_HDS_V v
   WHERE 1=1
   AND v.receipt_num = '85822'
   --AND v.organization_id = 83--SG1
   ;
