--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 51249,
                             resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;*/

/*CURSOR cur_pa IS*/
SELECT pa.segment1 so_number,
       ei.expenditure_type cost_element,
       party.duns_number_c customer_code,
       party.party_name customer_name,
       ei.expenditure_item_date record_date,
       decode(et.attribute14, 'Taken', 2, 'Offset', 3, 'Transfer', 4, 2) price_identification_code,
       decode(ei.system_linkage_function,
              'ST',
              decode(pa_security.view_labor_costs(ei.project_id), 'Y', ei.project_burdened_cost, NULL),
              'OT',
              decode(pa_security.view_labor_costs(ei.project_id), 'Y', ei.project_burdened_cost, NULL),
              ei.project_burdened_cost) price,
       ei.denom_currency_code currency_code,
       substr(pc.expenditure_comment, 1, instr(pc.expenditure_comment, '-', 1) - 1) po_number,
       pt2.task_number hbs_sg_mfg_number,
       '' remark,
       ei.expenditure_item_id source_id,
       ei.project_id,
       ei.task_id,
       ei.org_id,
       hou.set_of_books_id ledger_id,
       oh.header_id so_header_id
  FROM pa_expenditure_items_all ei,
       pa_expenditure_types     et,
       pa_expenditures_all      x,
       pa_projects              pa,
       pa_tasks                 pt,
       pa_tasks                 pt2,
       oe_order_headers_all     oh,
       hz_cust_accounts         cust_acct,
       hz_parties               party,
       pa_expenditure_comments  pc,
       hr_operating_units       hou

 WHERE 1 = 1
   AND ei.expenditure_type = et.expenditure_type
   AND ei.expenditure_id = x.expenditure_id
   AND ei.project_id = pa.project_id
   AND ei.task_id = pt.task_id
   AND pt.top_task_id = pt2.task_id
   AND pa.org_id = oh.org_id
   AND pa.segment1 = to_char(oh.order_number)
   AND oh.sold_to_org_id = cust_acct.cust_account_id(+)
   AND cust_acct.party_id = party.party_id(+)
   AND ei.expenditure_item_id = pc.expenditure_item_id(+)
   AND ei.org_id = hou.organization_id
   AND x.expenditure_status_code = 'APPROVED'
   AND ei.project_burdened_cost IS NOT NULL
   AND (ei.transaction_source IS NULL OR ei.transaction_source = 'Other Cost2' OR ei.transaction_source = 'HBS_Oracle')
      /*         and et.attribute14 in ('Transfer','Offset','Taken')
        AND NOT EXISTS
      (SELECT 'Y'
               FROM XXAP_JOURNAL_TO_R3_DATA_INT J
              WHERE J.SOURCE_CODE = 'PA'
                AND J.SOURCE_ID = ei.expenditure_item_id)*/
      
      /*AND ei.Last_Update_Date >=
      NVL(P_START_DATE, EI.Last_Update_Date)*/
   AND ei.expenditure_item_id IN (15429305,)
   AND hou.set_of_books_id = nvl( /*g_ledger_id*/ 2041, hou.set_of_books_id)
 ORDER BY ei.expenditure_item_id

;
