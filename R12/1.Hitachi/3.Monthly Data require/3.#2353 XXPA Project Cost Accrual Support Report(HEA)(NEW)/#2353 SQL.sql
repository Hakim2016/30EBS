/*tips:
1.line44 parameters.p_end_date - 1 should not be weekend whose exchange rate have not be maintained
2.line128 chage the date
3. =X3-Z3
*/
SELECT hou.name,
       /*ptt.task_type,
       xpmm.ba_fully_packing_date,
       xpmm.hand_over_date,
       poh.org_id,*/
       poh.segment1               po_number,
       ppa.segment1               project_number,
       --ppa.project_status_code    project_status,
       pt.task_number,
       pda.expenditure_type,
       msi.segment1               item_number,
       --msi.description,
       pol.item_description,
       pol.line_num,
       pll.shipment_num,
       pda.distribution_num,
       pda.quantity_ordered,
       pda.quantity_delivered,
       pda.quantity_billed,
       pda.quantity_cancelled,
       pol.unit_meas_lookup_code,
       --
       round(pol.unit_price * pda.quantity_ordered, 2) dist_amount,
       poh.currency_code,
       gcc.concatenated_segments charge_account,
       pda.creation_date,
       aps.vendor_name supplier,
       decode(pda.req_distribution_id,
              NULL,
              pda.req_header_reference_num,
              porh.segment1) requisition,
       ppf.full_name buyer,
       --poh.authorization_status,
       --ptt.task_type,
       decode(nvl(pol.unit_price * pda.quantity_ordered, 0),
              0,
              0,
              gl_currency_api.convert_amount(poh.currency_code,
                                             'SGD',
                                             parameters.p_end_date - 2, --pda.creation_date, -- p_conversion_date,
                                             'Corporate',
                                             pol.unit_price *
                                             pda.quantity_ordered)) po_amount_sgd,
       nvl(decode(pda.attribute_category,
                  'HEA_OU',
                  to_number(pda.attribute1),
                  0),
           0) AS history_goods_delivered_amount, --his_delivery_amount,

       (SELECT nvl(SUM(nvl(rrs.accounted_dr, 0) - nvl(rrs.accounted_cr, 0)),
                   0)
          FROM apps.rcv_transactions rt, apps.rcv_receiving_sub_ledger rrs
         WHERE 1 = 1
           AND rt.po_distribution_id = pda.po_distribution_id
           AND rt.transaction_type = 'DELIVER'
           AND rt.destination_type_code = 'EXPENSE'
           AND rt.transaction_date <= parameters.p_end_date
              --
           AND rrs.set_of_books_id = hou.set_of_books_id -- fnd_profile.value('GL_SET_OF_BKS_ID')
           AND rrs.accounting_line_type = 'Charge'
           AND rrs.rcv_transaction_id = rt.transaction_id -- p_transaction_id
        ) + --part_one,

       (SELECT nvl(SUM(nvl(rrs.accounted_dr, 0) - nvl(rrs.accounted_cr, 0)),
                   0)
          FROM apps.rcv_transactions ret, apps.rcv_receiving_sub_ledger rrs
         WHERE 1 = 1
           AND ret.transaction_type = 'RETURN TO RECEIVING'
           AND ret.transaction_date <= parameters.p_end_date
           AND ret.parent_transaction_id IN
               (SELECT rt.transaction_id
                  FROM apps.rcv_transactions rt
                 WHERE 1 = 1
                   AND rt.po_distribution_id = pda.po_distribution_id
                   AND rt.transaction_type = 'DELIVER'
                   AND rt.destination_type_code = 'EXPENSE'
                   AND rt.transaction_date <= parameters.p_end_date)
              --
           AND rrs.set_of_books_id = hou.set_of_books_id -- fnd_profile.value('GL_SET_OF_BKS_ID')
           AND rrs.accounting_line_type = 'Charge'
           AND rrs.rcv_transaction_id = ret.transaction_id) + -- part_two,

       (SELECT nvl(SUM(mta.base_transaction_value), 0)
          FROM apps.mtl_material_transactions mmt,
               apps.rcv_transactions          rt,
               apps.mtl_transaction_accounts  mta
         WHERE 1 = 1
           AND mmt.rcv_transaction_id = rt.transaction_id
           AND mmt.transaction_type_id IN (18, 36)
           AND rt.po_distribution_id = pda.po_distribution_id
           AND rt.transaction_date <= parameters.p_end_date
              --
           AND mta.accounting_line_type = 1
           AND mta.transaction_id = mmt.transaction_id -- p_transaction_id
        ) goods_delivered_amount, --part_three,
        NULL balance_amount,
        po_headers_sv3.get_po_status(poh.po_header_id) approved_status,
/*       poh.status_lookup_code,
       poh.firm_status_lookup_code,
       poh.agent_id,
       pol.item_id,
       pda.project_id,
       pda.task_id,*/
       pda.code_combination_id
  FROM apps.hr_operating_units             hou,
       apps.po_distributions_all           pda,
       apps.po_line_locations_all          pll,
       apps.po_lines_all                   pol,
       apps.financials_system_params_all   fsp,
       apps.mtl_system_items_b             msi,
       apps.po_headers_all                 poh,
       apps.pa_projects_all                ppa,
       apps.pa_tasks                       pt,
       apps.gl_code_combinations_kfv       gcc,
       apps.ap_suppliers                   aps,
       apps.po_req_distributions_all       pord,
       apps.po_requisition_lines_all       porl,
       apps.po_requisition_headers_all     porh,
       apps.per_people_f                   ppf,
       apps.xxpa_proj_milestone_manage_all xpmm,
       apps.pa_proj_elements               ppe,
       apps.pa_task_types                  ptt,
       --
       (SELECT to_date('2018-11-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss') p_start_date,
               to_date('2018-11-30 23:59:59', 'yyyy-mm-dd hh24:mi:ss') p_end_date,
               --
               /*'10003999'*/
               NULL po_number,
               /*'10003999'*/
               NULL project_number,
               /*'SR00001-SG'*/
               NULL mfg_number
          FROM dual) PARAMETERS
 WHERE 1 = 1
   AND hou.organization_id = pda.org_id
   AND poh.segment1 = nvl(parameters.po_number, poh.segment1)
   AND ppa.segment1 = nvl(parameters.project_number, ppa.segment1) --'11000083'
   AND xpmm.mfg_num = nvl(parameters.mfg_number, xpmm.mfg_num) --'SR00001-SG'
      -- AND rownum = 1
      --AND xpmm.ba_fully_packing_date >SYSDATE -100
      --AND poh.segment1 IN ('10028668', '10024549', '10003999')
   AND pda.line_location_id = pll.line_location_id
   AND pll.po_line_id = pol.po_line_id
   AND fsp.org_id = pol.org_id
   AND msi.inventory_item_id(+) = pol.item_id
   AND nvl(msi.organization_id, fsp.inventory_organization_id) =
       fsp.inventory_organization_id
   AND pol.po_header_id = poh.po_header_id
   AND pda.project_id = ppa.project_id(+)
   AND pda.task_id = pt.task_id(+)
   AND pda.code_combination_id = gcc.code_combination_id(+)
   AND poh.vendor_id = aps.vendor_id
      --
   AND pda.req_distribution_id = pord.distribution_id(+)
   AND pord.requisition_line_id = porl.requisition_line_id(+)
   AND porl.requisition_header_id = porh.requisition_header_id(+)
      --
   AND poh.agent_id = ppf.person_id
   AND trunc(SYSDATE) BETWEEN ppf.effective_start_date AND
       ppf.effective_end_date
   AND pt.top_task_id = xpmm.task_id
      --
   AND pt.task_id = ppe.proj_element_id
   AND pt.project_id = ppe.project_id
   AND ppe.type_id = ptt.task_type_id
      --
   AND ptt.task_type IN ('EQ COST', 'ER COST')
   AND (ptt.task_type = 'EQ COST' AND --
       xpmm.ba_fully_packing_date >= parameters.p_start_date AND
       xpmm.ba_fully_packing_date <= parameters.p_end_date OR
       ptt.task_type = 'ER COST' AND --
       xpmm.hand_over_date >= parameters.p_start_date AND
       xpmm.hand_over_date <= parameters.p_end_date)
   AND nvl(pll.cancel_flag, 'N') != 'Y'
   AND pda.org_id IN (101, 82)
 ORDER BY poh.segment1,
          pol.line_num,
          pll.shipment_num,
          pda.distribution_num
