SELECT poh.org_id,
       poh.segment1 po_number,
       ppa.segment1 project_number,
       pt.task_number,
       pda.expenditure_type,
       msi.segment1 item_number,
       msi.description,
       pol.line_num,
       pll.shipment_num,
       pda.distribution_num,
       pda.quantity_ordered,
       pda.quantity_delivered,
       pda.quantity_billed,
       pda.quantity_cancelled,
       pol.unit_meas_lookup_code,
       round(pol.unit_price * pda.quantity_ordered, 2) dist_amount,
       poh.currency_code,
       gcc.concatenated_segments,
       pda.creation_date,
       aps.vendor_name,
       decode(pda.req_distribution_id, NULL, pda.req_header_reference_num, porh.segment1) requisition,
       ppf.full_name buyer,
       po_headers_sv3.get_po_status(poh.po_header_id),
       poh.status_lookup_code,
       poh.authorization_status,
       poh.firm_status_lookup_code,
       poh.agent_id,
       pol.item_id,
       pda.project_id,
       pda.task_id,
       pda.code_combination_id,
       
       decode(nvl(pol.unit_price * pda.quantity_ordered, 0),
              0,
              0,
              nvl(gl_currency_api.convert_amount(poh.currency_code,
                                                 'SGD',
                                                 p_conversion_date,
                                                 'Corporate',
                                                 pol.unit_price * pda.quantity_ordered)),
              0) po_amount_sgd
  FROM po_distributions_all           pda,
       po_line_locations_all          pll,
       po_lines_all                   pol,
       financials_system_params_all   fsp,
       mtl_system_items_b             msi,
       po_headers_all                 poh,
       pa_projects_all                ppa,
       pa_tasks                       pt,
       gl_code_combinations_kfv       gcc,
       ap_suppliers                   aps,
       po_req_distributions_all       pord,
       po_requisition_lines_all       porl,
       po_requisition_headers_all     porh,
       per_people_f                   ppf
 WHERE 1 = 1
   AND poh.segment1 = '10028668' --'10024549'--'10003999'
   AND pda.line_location_id = pll.line_location_id
   AND pll.po_line_id = pol.po_line_id
   AND fsp.org_id = pol.org_id
   AND msi.inventory_item_id(+) = pol.item_id
   AND nvl(msi.organization_id, fsp.inventory_organization_id) = fsp.inventory_organization_id
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
   AND trunc(SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
 ORDER BY pol.line_num,
          pll.shipment_num,
          pda.distribution_num;
