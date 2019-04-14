<<<<<<< HEAD
SELECT pol.line_num,
       poh.org_id,
       poh.TYPE_LOOKUP_CODE,
=======

SELECT pol.line_num l_num,
       --pol.creation_date,
       pol.last_update_date,
       /*
       (SELECT fu.user_name
          FROM fnd_user fu
         WHERE 1 = 1
           AND fu.user_id = pol.created_by) created_by,*/
       (SELECT fu.user_name
          FROM fnd_user fu
         WHERE 1 = 1
           AND fu.user_id = pol.last_updated_by) update_by,
       poh.org_id,/*
>>>>>>> 461b3011e905a742257846dea4bb4850f49959c9
       pv.vendor_id,
       pv.vendor_name,*/
       --fu.user_name,
       poh.segment1 po_num,
       poh.currency_code curr,
       --pol.item_id,
       (SELECT msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = pol.item_id
           AND rownum = 1) item,
       (SELECT msi.description
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = pol.item_id
           AND rownum = 1) description,
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
<<<<<<< HEAD
      --AND poh.segment1 = '10062173'--'10000023'
   --AND poh.org_id = 81--7905
--101 --84 --101
      --AND poh.cancel_flag = 'N'
   --AND poh.approved_flag = 'Y'
   --AND poh.TYPE_LOOKUP_CODE = 'STANDARD'
   AND poh.CREATED_BY = 1206
      --AND poh.
      --AND poh.creation_date >= to_date('20170101', 'yyyymmdd')
   --AND poh.segment1 = '10000415' --'10026376' --'10000341' --'10051165'
=======
      --AND poh.po_header_id = 3050339
   AND poh.segment1 = '10070207'--'10071699' --'10073394'--'10062173'--'10000023'
   AND poh.org_id = 82 --101 --84 --101
--AND poh.cancel_flag = 'N'
--AND poh.approved_flag = 'Y'
--AND poh.
--AND poh.creation_date >= to_date('20170101', 'yyyymmdd')
--AND poh.segment1 = '10000415' --'10026376' --'10000341' --'10051165'
>>>>>>> 461b3011e905a742257846dea4bb4850f49959c9
--AND pol.unit_price = 27014
 ORDER BY pol.line_num;
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
  FROM po_headers_all       poh,
       po_lines_all         pol,
       po_vendors           pv,
       fnd_user             fu,
       po_distributions_all pod,
       
       gl_code_combinations_kfv gcc,
       pa_projects_all          ppa,
       pa_tasks                 pt
 WHERE 1 = 1
   AND pod.code_combination_id = gcc.code_combination_id
   AND ppa.project_id = pod.project_id
   AND pt.task_id = pod.task_id
   AND pod.po_line_id = pol.po_line_id(+)
   AND poh.vendor_id = pv.vendor_id
      --AND poh.vendor_id = 379
   AND fu.user_id = poh.created_by
      --AND fu.user_name LIKE 'HAND%'
   AND poh.po_header_id = pol.po_header_id
      --AND poh.segment1 = '10062173'--'10000023'
   AND poh.org_id = 101--82 --101
      --AND poh.cancel_flag = 'N'
   --AND poh.approved_flag = 'Y'
   --AND poh.creation_date >= to_date('20180101', 'yyyymmdd')
      AND poh.segment1 IN--= '10000341' --'10051165'
      ('10000032',
'10000096',
'10000313',
'10000389',
'10000402',
'10000428',
'10000429',
'10000430',
'10000436',
'10000443',
'10000452',
'10000462',
'10000463',
'10000465',
'10000483',
'10000484',
'10000488',
'10000495',
'10000506',
'10000509',
'10000510',
'10000511',
'10000522',
'10000527',
'10000529',
'10000531',
'10000539',
'10000556',
'10000563',
'10000567',
'10000576',
'10000577',
'10000580',
'10000581',
'10000582',
'10000583',
'10000584',
'10000589',
'10000595',
'10000596',
'10000639'
)
      --AND pol.unit_price = 27014
   --AND pol.item_id IS NULL
   ;

SELECT *
  FROM po_distributions_all pod
 WHERE 1 = 1
   AND pod.creation_date > trunc(SYSDATE);

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

/*
po line
po receipt
ap invoice
*/

SELECT poh.segment1 po_num,
       pol.po_line_id,
       pol.quantity,
       pol.base_unit_price,
       --instr(pol.base_unit_price, '.'),
       --(length(pol.base_unit_price) - instr(pol.base_unit_price, '.')) digit_l,
       SUM(rt.quantity_billed) qty,
       SUM(rt.amount_billed) billed,
       pol.base_unit_price - SUM(rt.amount_billed) diff,
       COUNT(*) rcv_cnt
/*rt.transaction_type,
rt.transaction_id,
rt.currency_code,
rt.quantity,
--rt.amount,
rt.quantity_billed,
rt.amount_billed,
pol.base_unit_price,
pol.cancel_flag,
pol.*,
rt.**/
  FROM po_headers_all       poh,
       po_lines_all         pol,
       po_distributions_all pod,
       rcv_transactions     rt
 WHERE 1 = 1
   AND poh.po_header_id = pol.po_header_id
   AND rt.po_line_id = pol.po_line_id
   AND pol.po_line_id = pod.po_line_id
   AND pol.org_id = 101
      --AND pol.quantity = 1
   AND pol.unit_meas_lookup_code = 'SET'
   AND nvl(pol.cancel_flag, 'N') <> 'Y'
   AND rt.transaction_type = 'RECEIVE'
   AND instr(pol.base_unit_price, '.') > 0 --unit price is not integer
   AND (length(pol.base_unit_price) - instr(pol.base_unit_price, '.')) >= 2 --the decimal place of unit price should more than 2
--AND pol.po_line_id = 2946500--1064733--2946500 --1064733

 GROUP BY poh.segment1,
          pol.po_line_id,
          pol.quantity,
          pol.base_unit_price

HAVING COUNT(*) >= 3 AND SUM(rt.quantity_billed) = pol.quantity --1
AND pol.base_unit_price <> SUM(rt.amount_billed);

SELECT poh.segment1,
       pol.po_line_id,
       pol.quantity,
       pol.base_unit_price,
       rt.amount_billed,
       
       rt.transaction_type,
       rt.transaction_id,
       rt.currency_code,
       rt.quantity,
       --rt.amount,
       rt.quantity_billed,
       rt.amount_billed,
       pol.base_unit_price,
       pol.cancel_flag,
       pol.*,
       rt.*
  FROM po_headers_all       poh,
       po_lines_all         pol,
       po_distributions_all pod,
       rcv_transactions     rt
 WHERE 1 = 1
   AND poh.po_header_id = pol.po_header_id
   AND rt.po_line_id = pol.po_line_id
   AND pol.po_line_id = pod.po_line_id
   AND pol.org_id = 101
   AND pol.quantity = 1
   AND pol.unit_meas_lookup_code = 'SET'
   AND nvl(pol.cancel_flag, 'N') <> 'Y'
   AND rt.transaction_type = 'RECEIVE'
   AND pol.po_line_id IN -- 1714454 --2946500 --1064733
       (2903914
        --2875818
        --,2946503,2965259,2903914,2946504,2965238,2965277,2946501,2946502,2946500,2946505
        );

SELECT length(345.9),
       instr(345.9, '.'),
       length(345.9333) - instr(345.9333, '.'),
       instr('hakim.444', '.')
  FROM dual;
