/*
XXOMDINVM
XXOMP001

*/

--SHE Tax invoice
SELECT v2.mfg_completion_date,
       dih.document_number dih_num,
       dih.so_number,
       --ooh.order_number,
       ppa.project_type,
       ool.task_id,
       ool.ordered_item,
       dil.header_id dih_id,
       dil.org_id,
       dih.transaction_date,
       nvl(dih.last_invoice_flag, 'N') lst_inv,
       ppa.project_status_code,
       dih.*
  FROM xxom_do_invoice_lines_all   dil,
       oe_order_lines_all          ool,
       oe_order_headers_all        ooh,
       xxom_do_invoice_headers_all dih,
       pa_projects_all             ppa,
       pa_project_types_all        ppt,
       xxpjm_mfg_status_v2         v2 --Addon PJM>>Project Srtatus Query
 WHERE 1 = 1
   AND v2.project_id = ppa.project_id
   AND v2.mfg_num = ool.ordered_item
   AND ool.header_id = ooh.header_id
   AND ppa.project_type = ppt.project_type
   AND ool.project_id = ppa.project_id
   AND dih.header_id = dil.header_id
   AND dil.oe_line_id = ool.line_id
   AND dih.org_id = 84
   AND dih.document_type = 'TAXINV'
      --AND ROWNUM = 1
   AND dih.document_number = 'TOAP000085' --'TOAP013212'
      --AND v2.mfg_completion_date IS NULL
      --AND dih.header_id = 57768754
      --AND dih.so_number = '217080209'--'21000749'
      --AND OOL.TASK_ID = P_TASK_ID
      --AND DIH.LAST_INVOICE_FLAG = 'Y'--todo170620 
      --AND nvl(ppt.attribute7, 'DOMESTIC') <> 'OVERSEA'
   AND dih.transaction_date BETWEEN to_date('20180101', 'yyyymmdd')
      /*P_START_DATE*/
       AND /*P_END_DATE*/
       to_date('20180331 23:59:59', 'yyyymmdd hh24:mi:ss')

;

SELECT dih.document_type doc_type,
       dih.document_number doc_num,
       dih.invoice_type_id type_id, --so type
       (SELECT ott.name
          FROM oe_order_types_v ott
         WHERE 1 = 1
           AND ott.transaction_type_id = dih.invoice_type_id) inv_so_type,
           dih.so_number,
       (SELECT DISTINCT ott.name
          FROM oe_order_headers_all   ooh,
               oe_transaction_types_v ott
         WHERE 1 = 1
           AND ooh.order_type_id = ott.transaction_type_id
           AND ooh.org_id = dih.org_id
           AND ott.org_id = ooh.org_id
           AND ooh.order_number = dih.so_number
        --AND ROWNUM = 1
        ) so_type,
       (SELECT msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = dil.inventory_item_id
           AND msi.organization_id = 86) item,
       dil.item_description,
       dih.contract_number,
       dih.ar_trx_type_id,
       dih.*
  FROM xxom_do_invoice_headers_all dih,
       xxom_do_invoice_lines_all   dil
 WHERE 1 = 1
   AND dih.header_id = dil.header_id
      --AND dih.header_id = 57768754
   AND dih.org_id = 84
   AND dih.document_type = 'TAXINV'
      --AND dih.creation_date> to_date('20180301', 'yyyymmdd')
   --AND dih.document_number = 'TOAP013212'--'TOAP000085' --'TOAP013212'
   AND dih.document_number LIKE 'TOAP%'--'TOAP000085' --'TOAP013212'
   AND dih.creation_date >= to_date('20180101','yyyymmdd')
   
--AND dih.invoice_type_id = 1017
;

SELECT
--v2.
 v2.*
  FROM xxpjm_mfg_status_v2 v2
 WHERE 1 = 1
   AND v2.org_id = 84
   AND v2.mfg_completion_date IS NULL
   AND v2.project_status_code <> '1010'
   AND v2.project_num = '217080209'
   AND v2.project_type IN ('SHE HO_SHE Project', 'SHE FAC_HET_Elevator', 'SHE HO_Mix Project', 'SHE HO_HEA Project')
--AND v2.
;

--org_id      Resp_id     Resp_app_id
--HBS 101     51249       660        
--HEA 82      50676       660
--HET 141     51272       20005
--SHE 84      50778       20005

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50778,
                             resp_appl_id => 20005);
  mo_global.init('M');
  
END;*/
