--SHE
/*BEGIN
  fnd_global.APPS_INITIALIZE(resp_appl_id =>20005 ,resp_id =>50778 ,user_id =>4088 );
  mo_global.init('M');
END;*/

SELECT mfg.task_number       mfg_no,
       a.expenditure_item_id trans_id,
       a.project_number,
       a.task_number,
       a.expenditure_type,
       -- a.INVENTORY_ITEM,
       -- a.WIP_RESOURCE,
       a.expenditure_item_date,
       a.transaction_source,
       a.orig_transaction_reference,
       a.orig_user_exp_txn_reference,
       nvl(a.employee_name, pv.vendor_name) employee_supplier_name,
       a.quantity,
       a.unit_of_measure_m,
       a.project_currency_code,
       a.burdened_cost,
       a.project_burdened_cost,
       a.accrued_revenue,
       a.bill_amount,
       a.expenditure_comment,
       a.expenditure_organization_name,
       a.non_labor_resource
  FROM pa_expend_items_adjust2_v a,
       pa_tasks                  mfg,
       pa_tasks                  pt,
       po_vendors                pv
 WHERE /*(a.PROJECT_ID = 1270575)
   AND (a.TASK_ID = 4268933)*/
 a.org_id = 84
/* and a.expenditure_item_date BETWEEN
to_date('2018-02-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND
to_date('2018-02-28 23:59:59', 'YYYY-MM-DD HH24:MI:SS')*/
 AND a.vendor_id = pv.vendor_id(+)
 AND mfg.task_number IN ('TAC0949-TH',
                     'TAC1008-TH',
                     'TAC1009-TH',
                     'TAC1010-TH',
                     'TAC1011-TH',
                     'TAC1012-TH',
                     'TAJ0075-TH',
                     'TFA0852-TH',
                     'TAJ0103-TH',
                     'TAD0160-TH',
                     'TAD0161-TH',
                     'TAD0162-TH',
                     'TAD0192-TH',
                     'TAD0241-TH',
                     'TAD0242-TH',
                     'TFA0928-TH',
                     'TFA0929-TH',
                     'TAE1106-TH',
                     'TAE1138-TH',
                     'TAE1139-TH',
                     'TFA0886-TH',
                     'TFA0887-TH',
                     'TED0001-TH',
                     'TAD0240-TH',
                     'TAD0271-TH',
                     'TBK0052-TH',
                     'TAC0468-TH',
                     'TAE0804-TH',
                     'TAE0138-TH',
                     'TAE0139-TH',
                     'TAE0140-TH',
                     'TAE0141-TH',
                     'TAC0978-TH',
                     'TAC0979-TH',
                     'TAC0980-TH',
                     'TAC0981-TH',
                     'TAC0983-TH',
                     'TAE1161-TH',
                     'TEB0062-TH',
                     'TAE1151-TH',
                     'TAJ0127-TH',
                     'TAE1116-TH',
                     'TAE1117-TH')
 AND a.task_id = pt.task_id
 AND pt.top_task_id = mfg.task_id
 ORDER BY a.expenditure_item_id,
          a.expenditure_item_date,
          a.task_id,
          a.expenditure_id,
          nvl(a.source_expenditure_item_id,
              nvl(a.adjusted_expenditure_item_id, nvl(a.transferred_from_exp_item_id, a.expenditure_item_id))),
          a.expenditure_item_id
