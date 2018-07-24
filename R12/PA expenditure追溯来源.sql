--source :inventory
SELECT DISTINCT mmt.transaction_id,
                mtt.transaction_type_name,
                pei.transaction_source /*,we.wip_entity_name*/
  FROM apps.pa_expenditure_items_all  pei,
       apps.mtl_material_transactions mmt,
       apps.pa_projects_all           ppa,
       apps.mtl_transaction_types     mtt --,
--apps.wip_entities we
 WHERE pei.orig_transaction_reference = to_char(mmt.transaction_id)
   AND pei.transaction_source = 'Inventory'
      --and   mmt.transaction_type_id =35
   AND mmt.transaction_type_id = mtt.transaction_type_id
      --and   mmt.transaction_source_id = we.wip_entity_id
   AND ppa.project_id = pei.project_id
   AND mmt.transaction_id = 54869415 --52992559 --28669285
;
--AND ppa.segment1 = '216070054'
--and   we.wip_entity_name = '10467019'

--source :inventory
SELECT /*DISTINCT */mmt.transaction_id,
                mtt.transaction_type_name,
                pei.expenditure_item_id,
                pei.transaction_source,
                we.wip_entity_name
  FROM apps.pa_expenditure_items_all  pei,
       apps.mtl_material_transactions mmt,
       apps.pa_projects_all           ppa,
       apps.mtl_transaction_types     mtt,
       apps.wip_entities              we
 WHERE pei.orig_transaction_reference = to_char(mmt.transaction_id)
   AND pei.transaction_source = 'Inventory'
      --and   mmt.transaction_type_id =35
   AND mmt.transaction_type_id = mtt.transaction_type_id
   and   mmt.transaction_source_id = we.wip_entity_id
   AND ppa.project_id = pei.project_id
   AND mmt.transaction_id = 54869415 --52992559 --28669285
;

SELECT *
  FROM pa_expenditure_items_all pei
 WHERE 1 = 1
   AND pei.orig_transaction_reference --= '52992559'
       IN ('54154413');

SELECT mmt.orig_transaction_reference,
       mmt.*

  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   AND mmt.transaction_id = 52992559;

--UNION ALL
SELECT mmt.transaction_id,
       mtt.transaction_type_name,
       pha.segment1
  FROM apps.pa_expenditure_items_all  pei,
       apps.mtl_material_transactions mmt,
       apps.pa_projects_all           ppa,
       apps.mtl_transaction_types     mtt,
       apps.po_headers_all            pha
 WHERE pei.orig_transaction_reference = mmt.transaction_id
   AND pei.transaction_source = 'Inventory'
   AND mmt.transaction_type_id = 18
   AND mmt.transaction_type_id = mtt.transaction_type_id
   AND mmt.transaction_source_id = pha.po_header_id
   AND ppa.project_id = pei.project_id
   AND pei.expenditure_item_id = 1880868
--and   ppa.segment1 = '21000514'  
;

-- expenditure from AP invoice derive PO receive information
SELECT pha.segment1             po_number,
       pla.line_num,
       ppa.segment1             project_number,
       pt.task_number,
       rt.destination_type_code
  FROM apps.pa_expenditure_items_all     pei,
       apps.ap_invoice_distributions_all aid,
       apps.rcv_transactions             rt,
       apps.po_distributions_all         pda,
       apps.po_lines_all                 pla,
       apps.po_headers_all               pha,
       apps.pa_projects_all              ppa,
       apps.pa_tasks                     pt
 WHERE pei.transaction_source = 'AP INVOICE'
   AND pei.document_distribution_id = aid.invoice_distribution_id
   AND pei.document_line_number = aid.invoice_line_number
   AND rt.po_distribution_id = aid.po_distribution_id
   AND rt.transaction_type = 'DELIVER'
   AND rt.po_distribution_id = pda.po_distribution_id
   AND rt.po_line_id = pla.po_line_id
   AND rt.project_id = ppa.project_id
   AND rt.task_id = pt.task_id
   AND rt.project_id = pda.project_id
   AND rt.task_id = pda.task_id
   AND pda.project_id = ppa.project_id
   AND pda.task_id = pt.task_id
   AND ppa.project_id = pt.project_id
   AND pda.po_line_id = pla.po_line_id
   AND pla.po_header_id = pha.po_header_id
   AND pei.expenditure_item_id = 46442

;
