SELECT poh.org_id,
       pv.vendor_id,
       pv.vendor_name,
       fu.user_name,
       poh.segment1 po_num,
       pol.item_id,
       (SELECT msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = pol.item_id
           AND rownum = 1) item,
       pol.unit_price * pol.quantity line_amt,
       pol.unit_price,
       pol.quantity,
       poh.*,
       pol.*
  FROM po_headers_all poh,
       po_lines_all   pol,
       po_vendors     pv,
       fnd_user       fu
 WHERE 1 = 1
   AND poh.vendor_id = pv.vendor_id
      --AND poh.vendor_id = 379
   AND fu.user_id = poh.created_by
      --AND fu.user_name LIKE 'HAND%'
   AND poh.po_header_id = pol.po_header_id
      --AND poh.segment1 = '10062173'--'10000023'
   AND poh.org_id = 101
      --AND poh.cancel_flag = 'N'
   AND poh.approved_flag = 'Y'
      --AND poh.
      --AND poh.creation_date >= to_date('20170101', 'yyyymmdd')
   AND poh.segment1 = '10000341' --'10051165'
--AND pol.unit_price = 27014
;
--82/84

--with project info
SELECT poh.org_id,
       pv.vendor_id,
       pv.vendor_name,
       fu.user_name,
       poh.segment1 po_num,
       pol.item_id,
       (SELECT msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = pol.item_id
           AND rownum = 1) item,
       pol.unit_price * pol.quantity line_amt,
       pod.project_id,
       ppa.segment1,
       pod.task_id,
       pod.expenditure_type,
       pod.code_combination_id,
       pt.task_number,
       pol.unit_price,
       pol.quantity,
       poh.*,
       pol.*
  FROM po_headers_all poh,
       po_lines_all   pol,
       po_vendors     pv,
       fnd_user       fu,
       PO_DISTRIBUTIONS_ALL pod,
       
                gl_code_combinations_kfv     gcc,
       pa_projects_all ppa,
       pa_tasks pt
 WHERE 1 = 1
AND pod.code_combination_id gcc.code_combination_id
 AND ppa.project_id = pod.project_id
 AND pt.task_id = pod.task_id
 AND pod.po_line_id = pol.po_line_id(+)
   AND poh.vendor_id = pv.vendor_id
      --AND poh.vendor_id = 379
   AND fu.user_id = poh.created_by
      --AND fu.user_name LIKE 'HAND%'
   AND poh.po_header_id = pol.po_header_id
      --AND poh.segment1 = '10062173'--'10000023'
   AND poh.org_id = 82--101
      --AND poh.cancel_flag = 'N'
   AND poh.approved_flag = 'Y'
      AND poh.creation_date >= to_date('20180101', 'yyyymmdd')
   --AND poh.segment1 = '10000341' --'10051165'
--AND pol.unit_price = 27014
AND pol.item_id IS NULL
;

SELECT * FROM PO_DISTRIBUTIONS_ALL pod
WHERE 1=1
AND pod.creation_date > TRUNC(SYSDATE)
;

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
