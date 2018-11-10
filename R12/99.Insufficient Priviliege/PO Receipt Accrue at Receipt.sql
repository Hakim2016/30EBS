--Accrual Account 

SELECT rt.transaction_id,
       rt.po_header_id,
       rt.po_unit_price,
       rt.source_doc_quantity,
       rsl.rcv_sub_ledger_id,
       rsl.accounted_cr,
       rt.po_unit_price * rt.source_doc_quantity actual_amount,
       rt.po_unit_price * rt.source_doc_quantity - nvl(rsl.accounted_cr, 0) adj_amount,
       code_combination_id adj_account
  FROM rcv_transactions         rt,
       rcv_receiving_sub_ledger rsl
 WHERE rt.transaction_id = rsl.rcv_transaction_id
   --AND rt.transaction_type = 'RECEIVE'
   --AND rsl.accounting_line_type = 'Accrual'
   AND rt.transaction_id = 5008497
   --AND abs(rt.po_unit_price * rt.source_doc_quantity - nvl(rsl.accounted_cr, 0)) >= &&amt
   ;

--Receiving Inspection Account 

SELECT rt.transaction_id,
       rt.po_header_id,
       rt.po_unit_price,
       rt.primary_quantity,
       rsl.rcv_sub_ledger_id,
       rsl.accounted_dr,
       rt.po_unit_price * rt.primary_quantity actual_amount,
       rt.po_unit_price * rt.primary_quantity - nvl(rsl.accounted_dr, 0) adj_amount,
       code_combination_id adj_account
  FROM rcv_transactions         rt,
       rcv_receiving_sub_ledger rsl
 WHERE rt.transaction_id = rsl.rcv_transaction_id
   AND rt.transaction_type = 'RECEIVE'
   AND rsl.accounting_line_type = 'Receiving Inspection'
   AND abs(rt.po_unit_price * rt.primary_quantity - nvl(rsl.accounted_dr, 0)) >= &&amt;
