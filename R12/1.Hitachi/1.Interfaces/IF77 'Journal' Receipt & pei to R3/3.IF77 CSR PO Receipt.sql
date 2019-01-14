/*cursor cur_po_receipt is*/
---po receipt
SELECT pa.segment1 so_number,
       pd.expenditure_type cost_element,
       party.duns_number_c customer_code,
       party.party_name customer_name,
       rt.transaction_date record_date,
       1 price_identification_code,
       decode(rt.transaction_type,
              'RETURN TO RECEIVING',
              -1 * round(rt.quantity * rt.po_unit_price, 2),
              round(rt.quantity * rt.po_unit_price, 2)) price,
       rt.currency_code,
       ph.segment1 po_number,
       hp.duns_number_c supplier_code,
       pav.vendor_name supplier_name,
       pt2.task_number hbs_sg_mfg_number,
       '' remark,
       rt.transaction_id source_id,
       nvl(rt.project_id,
           (SELECT v.project_id
              FROM rcv_transactions v
             WHERE v.transaction_id = rt.parent_transaction_id)) project_id,
       nvl(rt.task_id,
           (SELECT v.task_id
              FROM rcv_transactions v
             WHERE v.transaction_id = rt.parent_transaction_id)) task_id,
       ph.po_header_id,
       oh.header_id so_header_id,
       odd.operating_unit org_id,
       odd.set_of_books_id ledger_id

  FROM rcv_transactions             rt,
       po_headers_all               ph,
       po_distributions             pd,
       ap_suppliers                 pav,
       hz_parties                   hp,
       pa_projects_all              pa,
       pa_tasks                     pt,
       pa_tasks                     pt2,
       oe_order_headers_all         oh,
       hz_cust_accounts             cust_acct,
       hz_parties                   party,
       org_organization_definitions odd
 WHERE rt.po_header_id = ph.po_header_id
   AND rt.po_distribution_id = pd.po_distribution_id
   AND rt.vendor_id = pav.vendor_id(+)
   AND pav.party_id = hp.party_id(+)
   AND nvl(rt.project_id,
           (SELECT v.project_id
              FROM rcv_transactions v
             WHERE v.transaction_id = rt.parent_transaction_id)) = pa.project_id
   AND nvl(rt.task_id,
           (SELECT v.task_id
              FROM rcv_transactions v
             WHERE v.transaction_id = rt.parent_transaction_id)) = pt.task_id
   AND pt.top_task_id = pt2.task_id
   AND pa.org_id = oh.org_id(+)
   AND pa.segment1 = oh.order_number(+)
   AND oh.sold_to_org_id = cust_acct.cust_account_id(+)
   AND cust_acct.party_id = party.party_id(+)
   AND rt.organization_id = odd.organization_id
   AND rt.transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')
   AND NOT EXISTS (SELECT 'Y'
          FROM xxap_journal_to_r3_data_int j
         WHERE j.source_code = 'PO RECIPT'
           AND j.source_id = rt.transaction_id)
      
   --AND rt.creation_date >= nvl(p_start_date, rt.creation_date)
   AND odd.set_of_books_id = nvl(/*g_ledger_id*/2041, odd.set_of_books_id)
 ORDER BY rt.transaction_id;
