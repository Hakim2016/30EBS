SELECT pei.expenditure_item_id   pei_id,
       pei.expenditure_item_date pei_date,
       ppa.segment1              prj_num,
       pt.task_number,
       --pei.project_id,
       --pei.organization_id,
       --pei.org_id,
       pei.quantity qty,
       pei.burden_cost brd_cst,
       pei.project_burdened_cost prj_brd_cst,
       pei.expenditure_type expen_typ,
       pei.transaction_source trx_src,
       --pei.adjusted_expenditure_item_id,
       --pei.expenditure_item_id,
       --pei.inventory_item_id,
       --pei.source_expenditure_item_id,
       --pei.transferred_from_exp_item_id,
       --msi.inventory_item_id,
       msi.segment1,
       pet.attribute15,
       pet.expenditure_category,
       pei.expenditure_type,
       pei.document_type,
       pei.expenditure_item_date,
       pei.adjusted_expenditure_item_id adj_pei_id,
       pei.document_header_id,
       (SELECT aph.invoice_num
          FROM ap_invoices_all aph
         WHERE 1 = 1
           AND aph.invoice_id = pei.document_header_id) invoice_num,
       pei.document_type,
       pei.transaction_source,
       pei.orig_transaction_reference,
       ppa.segment1 proj_num,
       ppa.name proj_name,
       pt.task_number,
       top.task_number,
       pei.expenditure_type,
       pei.expenditure_item_date,
       pv.vendor_name,
       pv.segment1 vendor_num,
       pei.quantity,
       pei.unit_of_measure,
       pei.orig_transaction_reference, --mmt.id
       pei.*
  FROM pa_expenditure_items_all pei,
       pa_expenditure_types     pet,
       pa_projects_all          ppa,
       pa_tasks                 pt,
       pa_tasks                 top,
       po_vendors               pv,
       mtl_system_items_b       msi
 WHERE 1 = 1
   AND msi.inventory_item_id(+) = pei.inventory_item_id
   --AND msi.inventory_item_id(+) = nvl(pei.inventory_item_id,pei.expenditure_item_id)
   --AND msi.inventory_item_id = pei.expenditure_item_id
   AND msi.organization_id(+) = pei.organization_id
   AND pei.project_id = ppa.project_id
   AND pei.expenditure_type = pet.expenditure_type
   AND pei.task_id = pt.task_id
   AND pt.top_task_id = top.task_id
   AND pei.vendor_id = pv.vendor_id(+)
  /* AND pei.expenditure_type  
   LIKE 'DES Overhead'*/--'PUR Overhead Transfer'--'%FAC%Wooden%Case%'
   --IN ('FAC - Wooden Case')
   --AND pei.expenditure_item_id --= 15168527--15284278--15315822
       --IN (15168527, 15221846)
--AND pei.inventory_item_id = 3939072--15315822
--AND pei.task_id = 5725843
AND top.task_number IN ('TAC0473-TH')--('SAC0826-SG')--('SBH0216-PH')--('TAE0736-TH')--('SLS0230-SG','LN0732-L2') --'TAD0021-TH'--mfg
--AND pt.task_number = 'TAD0021-TH.D.11'
AND ppa.segment1 = '21000414'--'203042'--'11001297'--'215110107'--'11001262'--'10101506'--'215110107'--'21000400'--'118010001'--'10101647' --'10202892'--'21000197'--'10101506' --'21000197' --proj_num
AND ppa.org_id = 84 --84 --SHE --82 --HEA
--AND pei.expenditure_item_date >= to_date('2018-03-01', 'yyyy-mm-dd')
--AND pei.creation_date >= to_date('2017-04-01', 'yyyy-mm-dd')
--AND pei.creation_date <= to_date('2017-05-01', 'yyyy-mm-dd')
--AND pei.orig_transaction_reference --= '52992559'
--IN ('54869309')--('54154413')
--AND pei.quantity  = 0
 ORDER BY pet.expenditure_category,
          pet.expenditure_type

--ex : HEA Project 10101506      --SHE Project
;

SELECT *
  FROM pa_expend_items_adjust2_v pea
 WHERE 1 = 1
   AND pea.expenditure_id IN (15168527, 15221846);

--SELECT * FROM org_organization_definitions ood;

SELECT top.task_id top_task_id,
       top.task_number,
       pt.*
  FROM pa_tasks pt,
       pa_tasks top
 WHERE 1 = 1
   AND pt.top_task_id = top.task_id
   AND pt.task_number = 'TAD0021-TH.D.11';

-------------------------------------------------------
SELECT tt.actual_month,
       pt.task_number,
       pei.expenditure_item_id trans_id,
       pei.expenditure_type,
       pei.transaction_source,
       pei.expenditure_item_date,
       pei.adjusted_expenditure_item_id adj_trans_id,
       pei.document_header_id,
       (SELECT aph.invoice_num
          FROM ap_invoices_all aph
         WHERE 1 = 1
           AND aph.invoice_id = pei.document_header_id) invoice_num,
       pei.document_type,
       pei.transaction_source,
       pei.orig_transaction_reference,
       ppa.segment1 proj_num,
       pei.*
  FROM pa_expenditure_items_all pei,
       pa_tasks pt,
       pa_projects_all ppa,
       (SELECT intf.actual_month,
               intf.company_name,
               pt.task_number,
               ppa.segment1 proj_num,
               intf.mfg_num,
               intf.sale_amount,
               intf.material,
               intf.labour,
               intf.subcon,
               intf.packing_freight,
               intf.org_id
        --intf.*
          FROM xxpa_cost_gcpm_int intf,
               pa_tasks           pt,
               pa_tasks           top,
               pa_projects_all    ppa
         WHERE 1 = 1
           AND ppa.project_id = pt.project_id
           AND pt.top_task_id = top.task_id
           AND pt.task_id = intf.task_id
              --AND intf.org_id = 82
              --AND intf.eq_er_category = 'EQ'
              --AND intf.mfg_num IN ('TAE0970-TH', 'TAE0969-TH', 'TAE0968-TH')
              --AND pt.task_number LIKE '%.D.11'
           AND (pt.task_number NOT LIKE '%.EQ' AND pt.task_number NOT LIKE '%.ER')
              --AND intf.actual_month = to_date('2017-08-01', 'yyyy-mm-dd')
              
           AND intf.group_id = (SELECT MAX(t2.group_id)
                                  FROM xxpa_cost_gcpm_int t2
                                 WHERE 1 = 1
                                   AND t2.mfg_num = intf.mfg_num
                                   AND t2.actual_month = intf.actual_month
                                   AND t2.task_id = intf.task_id)
         ORDER BY intf.actual_month,
                  intf.mfg_num DESC) tt

 WHERE 1 = 1
   AND pt.project_id = ppa.project_id
   AND pei.task_id = pt.task_id
   AND pt.task_number = tt.task_number --'TAD0021-TH.D.11'
   AND ppa.segment1 = tt.proj_num --'21000197'
      --AND trunc(tt.actual_month) = TRUNC(pei.expenditure_item_date)
      --AND pei.expenditure_item_id = 2980850
   AND tt.org_id = pei.org_id
   AND pei.project_burdened_cost = (tt.material + tt.labour + tt.subcon + tt.packing_freight)
 ORDER BY tt.actual_month,
          pt.task_number;

SELECT DISTINCT --pei.expenditure_item_id trans_id,
                --pei.organization_id,
                 pei.org_id,
                --ppa.segment1 proj_no,
                pei.transaction_source,
                pet.expenditure_category,
                pei.expenditure_type,
                pei.document_type,
                pei.document_distribution_type,
                pet.description /*,
       pei.expenditure_item_date,
       pei.adjusted_expenditure_item_id adj_trans_id,
       pei.document_header_id,
       (SELECT aph.invoice_num
          FROM ap_invoices_all aph
         WHERE 1 = 1
           AND aph.invoice_id = pei.document_header_id) invoice_num,
       pei.document_type,
       pei.transaction_source,
       pei.orig_transaction_reference,
       ppa.segment1 proj_num,
       ppa.name proj_name,
       pt.task_number,
       top.task_number,
       pei.expenditure_type,
       pei.expenditure_item_date,
       pv.vendor_name,
       pv.segment1 vendor_num,
       pei.quantity,
       pei.unit_of_measure,
       pei.burden_cost,
       pei.project_burdened_cost,
       pei.**/
  FROM pa_expenditure_items_all pei,
       pa_expenditure_types     pet,
       pa_projects_all          ppa,
       pa_tasks                 pt,
       pa_tasks                 top,
       po_vendors               pv,
       mtl_system_items_b       msi
 WHERE 1 = 1
   AND msi.inventory_item_id(+) = pei.inventory_item_id
   AND pei.project_id = ppa.project_id
   AND pei.expenditure_type = pet.expenditure_type
   AND pei.task_id = pt.task_id
   AND pt.top_task_id = top.task_id
   AND pei.vendor_id(+) = pv.vendor_id
--AND top.task_number = 'LN0732-L2' --'TAD0021-TH'--mfg
--AND pt.task_number = 'TAD0021-TH.D.11'
--AND ppa.segment1 = '10101647' --'10202892'--'21000197'--'10101506' --'21000197' --proj_num
--AND ppa.org_id = 82 --84 --SHE --82 --HEA
--AND pei.expenditure_item_date >= to_date('2018-03-11', 'yyyy-mm-dd')
 ORDER BY pei.org_id,
          pei.transaction_source,
          pet.expenditure_category,
          pei.expenditure_type

--ex : HEA Project 10101506      --SHE Project
;

SELECT DISTINCT pei.transaction_source,
                --pei.expenditure_category,
                pei.expenditure_type,
                pei.document_type,
                pei.document_distribution_type
  FROM pa_expenditure_items_all pei
 WHERE pei.expenditure_type = 'Products Costs';

SELECT *
  FROM pa_expenditure_types pet
 WHERE 1 = 1
   AND pet.expenditure_type IN ('DES Overhead',
                                'FAC - DES Overhead',
                                'FAC - Prod. Subcon',
                                'FAC - Store. Subcon',
                                'FAC - Wooden Case',
                                'PUR Overhead',
                                'PUR Overhead Transfer',
                                'Prod. Direct Labour',
                                'Prod. Overhead',
                                'Prod. Subcon Transfer',
                                'Products Costs');



--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50778,
                             resp_appl_id => 20005);
  mo_global.init('M');
  FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;
*/
