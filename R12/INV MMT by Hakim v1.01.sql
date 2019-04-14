SELECT 
mmt.transaction_date,
--mmt.creation_date,
mmt.organization_id              orgs_id,
       msi.segment1,
       mtt.transaction_type_name        trx_type,
       mts.transaction_source_type_name trx_src_type,
       mmt.primary_quantity             qty,
       --mmt.source_code,
       --mmt.transaction_source_id,
       (SELECT xx.segment1 || '.' || xx.segment2 || '.' || xx.segment3
          FROM mtl_sales_orders xx
         WHERE 1 = 1
           AND xx.sales_order_id = mmt.transaction_source_id --3256851
        ) so_info,
       --mmt.source_line_id,
       inv_project.get_locator(mmt.locator_id, mmt.organization_id) locator, --
       mmt.costed_flag,
       mmt.pm_cost_collected prj_costed,
       mmt.source_code,
       mmt.project_id,
       mmt.task_id,
       mmt.*
  FROM mtl_material_transactions  mmt,
       mtl_system_items_b         msi,
       apps.mtl_transaction_types mtt,
       mtl_txn_source_types       mts
 WHERE 1 = 1
   AND mts.transaction_source_type_id = mmt.transaction_source_type_id
   AND mmt.transaction_type_id = mtt.transaction_type_id
   --AND mtt.transaction_type_name IN ('Sales Order Pick')
   AND mmt.inventory_item_id = msi.inventory_item_id
   AND mmt.organization_id = msi.organization_id
   --AND mmt.costed_flag = 'N'
      --AND mmt.transaction_id = 54868663--60911685--8915869
      --AND mmt.last_update_date >= trunc(SYSDATE) - 1 --SYSDATE - 2
   --AND mmt.organization_id = 83--121--86
   --AND mmt.inventory_item_id = 3939072
   AND mmt.transaction_id -->=
   --= 38434933--54899211--54898548--54897910--56683536
IN(4178665)
   --=5097
   --= 54896869--54895834
      --33834547 --2017
       --49368602 --2018
      --AND mmt.created_by = 4270
      --AND msi.segment1 = '1000EX-EN'
   /*AND EXISTS (SELECT 'Y'
          FROM mtl_sales_orders mso
         WHERE 1 = 1
           AND mso.sales_order_id = mmt.transaction_source_id
           AND mso.segment2 = 'SHE_Oversea_Spare Parts')*/
--AND rownum <=1000
/*AND mmt.source_code --= 'DN In'
IN ('DN In', 'DN Out')*/
 ORDER BY mmt.transaction_id DESC;

SELECT mmt.transaction_id trx_id,
       mmt.transaction_date trx_date,
       decode(mmt.organization_id, 86, 'FAC', 85, 'HO', mmt.organization_id) org,
       (SELECT msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = mmt.inventory_item_id
           AND msi.organization_id = mmt.organization_id) item,
       mmt.primary_quantity qty,
       inv_project.get_locator(mmt.locator_id, mmt.organization_id) locator,
       --mmt.transaction_type_id,
       (SELECT mtt.transaction_type_name
          FROM mtl_transaction_types mtt
         WHERE 1 = 1
           AND mtt.transaction_type_id = mmt.transaction_type_id) trx_type,
       mmt.source_code,
       mmt.transaction_reference trx_ref,
       mmt.source_line_id,
       mmt.costed_flag,
       mmt.pm_cost_collected prj_costed,
       mmt.created_by,
       mmt.transaction_id,
       mmt.creation_date,
       --mmt.locator_id,
       mmt.project_id,
       (SELECT ppa.segment1 prj_num
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = mmt.project_id) prj_num,
       mmt.task_id,
       (SELECT pt.task_number
          FROM pa_tasks pt
         WHERE 1 = 1
           AND pt.task_id = mmt.task_id) task,
       mmt.source_project_id,
       (SELECT ppa.segment1 prj_num
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = mmt.source_project_id) src_prj_num,
       mmt.source_task_id ,
       (SELECT pt.task_number
          FROM pa_tasks pt
         WHERE 1 = 1
           AND pt.task_id = mmt.source_task_id) src_task,
       mmt.costed_flag,
       mmt.pm_cost_collected,
       mmt.*
  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   --AND mmt.last_update_date > trunc(SYSDATE) - 10
   --AND mmt.source_code --= 'DN In'
       --IN ('DN In', 'DN Out', '')
      --AND mmt.project_id IS NOT NULL
      --AND mmt.created_by = 4270
      AND mmt.transaction_id --= 52998974
      IN(38434933, 38434935)
   --AND mmt.transaction_reference = '1804261'
 ORDER BY mmt.transaction_id;

--1.transaction_type_id refer to mtl_transaction_types
SELECT *
  FROM mtl_transaction_types mtt
 WHERE 1 = 1
      --AND mtt.transaction_type_id
   --AND mtt.transaction_type_name LIKE 'Sales Order Pick' --'Sales%Order%Pick'--
 ORDER BY mtt.creation_date --mtt.transaction_type_id
;

--2.transaction_action_id refer to lookup 'MTL_TRANSACTION_ACTION'
SELECT *
  FROM mfg_lookups v
 WHERE v.lookup_type = 'MTL_TRANSACTION_ACTION'
 ORDER BY v.lookup_code;

--3.transaction_source_id refer to 
SELECT *
  FROM wip_discrete_jobs wdj;

--4.transaction_source_type_id refer to mtl_txn_source_types
SELECT mts.transaction_source_type_id   trx_src_id,
       mts.transaction_source_type_name trx_src,
       --mts.transaction_source_category trx_cate,
       mts.description des,
       mts.*
  FROM mtl_txn_source_types mts;

--xla
SELECT xte.source_id_int_1,
xte.application_id
       ,xte.*
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
      AND xte.source_id_int_1 = 4178665--43901381
   --AND xte.application_id = 707
   --AND xte.security_id_int_1 = 83
   --AND xte.creation_date > SYSDATE - 2
   ;

SELECT xte.source_id_int_1,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal
 WHERE 1 = 1
   AND xte.entity_id(+) = xah.entity_id
   AND xte.application_id(+) = xah.application_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xte.source_id_int_1 = 43901381
   AND xte.application_id = 707
   AND xte.security_id_int_1 = 83
   AND xte.creation_date > SYSDATE - 2;

inv_project.get_locator(mmt.locator_id, mmt.organization_id) locator

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
