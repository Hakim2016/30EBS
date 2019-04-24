--org_id      Resp_id     Resp_app_id
--HBS 101     51249       660        
--HEA 82      50676       660
--HET 141     51272       20005
--SHE 84      50778       20005

/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  
END;
*/

SELECT ool.unit_selling_price * ool.ordered_quantity total,
       ool.line_number,
       ool.schedule_ship_date,
       ooh.*
  FROM oe_order_headers_all ooh, oe_order_lines_all ool
 WHERE 1 = 1
   AND ooh.header_id = ool.header_id
      --AND ooh.org_id = 101
   AND ool.unit_selling_price <> 0
   AND ooh.order_number LIKE '19041%' /*IN (
   '190417001',
'190417002',
'190417003',
'190417004',
'190417005',
'190417006',
'190417007',
'190417008',
'190417009',
'190417010'
   
   )*/ --('23000461') --('53020044'); --('53020400', '53020422');
;
SELECT xsh.source_system, ooh.*
  FROM oe_order_headers_all ooh, xxpjm_so_addtn_headers_all xsh
 WHERE 1 = 1
   AND ooh.header_id = xsh.so_header_id
      --AND ooh.org_id = 101
   AND ooh.order_number IN ('11001269');

--so line dff1 dff4
SELECT ooh.creation_date,
       ooh.order_number,
       ooh.conversion_rate,
       ooh.conversion_type_code,
       ooh.conversion_rate_date,
       ooh.transactional_curr_code,
       ott.name so_type,
       (SELECT xsh.source_system
          FROM xxpjm_so_addtn_headers_all xsh
         WHERE 1 = 1
           AND ooh.header_id = xsh.so_header_id) src_sys,
       ooh.booked_flag,
       ooh.cancelled_flag,
       ott.transaction_type_id,
       ool.line_type_id,
       
       (SELECT ott2.attribute5
          FROM oe_transaction_types_v ott2
         WHERE 1 = 1
           AND ott2.transaction_type_id = ool.line_type_id) line_type,
       /*ooh.attribute5,
       ool.attribute5,
       ott.attribute5,
       ool.attribute15,*/
       ool.project_id,
       ool.task_id,
       
       (SELECT ppa.segment1
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = ool.project_id) prj_num,
       (
        
        SELECT pt.task_number
          FROM pa_tasks pt
         WHERE 1 = 1
           AND pt.project_id = ool.project_id
           AND pt.task_id = ool.task_id) task_num,
       ool.ordered_item,
       ool.line_number,
       ool.cust_production_seq_num,
       ool.ordered_quantity,
       ool.pricing_quantity,
       ool.pricing_quantity_uom,
       ool.unit_selling_price,
       ool.line_number,
       ool.last_update_date,
       ott.name,
       ooh.order_type_id,
       ott.transaction_type_code,
       (SELECT fu.user_name
          FROM fnd_user fu
         WHERE 1 = 1
           AND fu.user_id = ool.last_updated_by) usr,
       ool.attribute1,
       ool.attribute4,
       ool.*
  FROM oe_order_headers_all   ooh,
       oe_order_lines_all     ool,
       oe_transaction_types_v ott
 WHERE 1 = 1
   AND ooh.org_id = 82 --84 --101
   AND ott.transaction_type_id = ooh.order_type_id(+)
   AND ott.org_id = ooh.org_id
   AND ooh.header_id = ool.header_id(+)
      --AND ott.name = 'Order_HEA_Oversea Parts Sales'--'Order_HEA_Domestic_EQ_Sales' --'SHE_Oversea_Spare Parts'
      --AND ooh.cancelled_flag <> 'Y'
   AND ooh.booked_flag = 'Y'
      --AND ooh.creation_date >= to_date('20180101', 'yyyymmdd')
   AND ooh.order_number --= '11001269'
       IN (
           --'12003056'
           '12002949',
           '12003690',
           '12003758',
           '12003759',
           '12003779',
           '12003785',
           '12003797',
           '12003805',
           '12003840',
           '12003848',
           '12003860',
           '12003884',
           '12003918',
           '12004029',
           '12004111',
           '12004119',
           '12004130',
           '12004152',
           '12004185',
           '12004190',
           '12004198')

--AND ool.ordered_item IN ('ST02938-IN')
--('LB3901-PL210A')--('JED0210-VN','JED0211-VN','JED0212-VN','JED0219-VN','JED0220-VN','JED0225-VN');
 ORDER BY ool.last_update_date DESC;

SELECT *
  FROM oe_order_headers_all ooh
 WHERE 1 = 1
      --AND ooh.org_id = 82
   AND ooh.order_number = '12003779' --'12003779'
/*IN ('12002949',
'12003690',
'12003758',
'12003759',
'12003779',
'12003785',
'12003797',
'12003805',
'12003840',
'12003848',
'12003860',
'12003884',
'12003918',
'12004029',
'12004111',
'12004119',
'12004130',
'12004152',
'12004185',
'12004190',
'12004198')
*/
;

SELECT ppa.org_id, ppa.*
  FROM pa_projects_all ppa
 WHERE 1 = 1
      --AND ppa.org_id = 82
   AND ppa.segment1 IN ('12002949',
                        '12003690',
                        '12003758',
                        '12003759',
                        ----
                        '12003779',
                        '12003785',
                        '12003797',
                        '12003805',
                        '12003840',
                        '12003848', --
                        '12003860',
                        '12003884',
                        '12003918',
                        '12004029',
                        '12004111',
                        '12004119',
                        '12004130',
                        '12004152',
                        '12004185',
                        '12004190',
                        '12004198');

--so line dff1 dff4 associated with ar
SELECT ooh.order_number,
       (SELECT xx.trx_number
          FROM ra_customer_trx_all xx
         WHERE 1 = 1
           AND xx.customer_trx_id = rctl.customer_trx_id) ar_num,
       ool.line_number so_line,
       rctl.sales_order_line,
       ott.name so_type,
       ooh.booked_flag,
       ooh.cancelled_flag,
       ool.ordered_item,
       ool.line_number,
       ool.cust_production_seq_num,
       ool.ordered_quantity,
       ool.pricing_quantity,
       ool.pricing_quantity_uom,
       ool.unit_selling_price,
       ool.line_number,
       ool.last_update_date,
       ott.name,
       ooh.order_type_id,
       ott.transaction_type_code,
       (SELECT fu.user_name
          FROM fnd_user fu
         WHERE 1 = 1
           AND fu.user_id = ool.last_updated_by) usr,
       ool.attribute1,
       ool.attribute4,
       ool.*
  FROM oe_order_headers_all      ooh,
       oe_order_lines_all        ool,
       oe_transaction_types_v    ott,
       ra_customer_trx_lines_all rctl
 WHERE 1 = 1
      --AND rctl.sales_order = ooh.order_number
      --AND ool.line_number || '.' || ool.shipment_number = rctl.sales_order_line
   AND ooh.org_id = 84 --101
   AND ott.transaction_type_id = ooh.order_type_id(+)
   AND ott.org_id = ooh.org_id
   AND ooh.header_id = ool.header_id(+)
      --AND ott.name = 'SHE_Oversea_Spare Parts'
      --AND ooh.cancelled_flag <> 'Y'
      --AND ooh.creation_date >= to_date('20170601', 'yyyymmdd')
   AND ooh.order_number = '22013146' --'22011912'
--'22010117'
--'21000473'
--'202474'
--'23000414'
--'23000461'--'11000144'--'12003425'
--'10101647'--'10101629'--'11001299'--'11000884' --'53020261' --'53020362' --'53020261'--'53020165'--'53020155'--'53020400'
--AND ool.ordered_item IN ('ST02938-IN')
--('LB3901-PL210A')--('JED0210-VN','JED0211-VN','JED0212-VN','JED0219-VN','JED0220-VN','JED0225-VN');
 ORDER BY ool.last_update_date;

--packing list
SELECT v.project_number, v.mfg_number, v.task_number, v.status_code, v.*
  FROM xxinv_packing_lists_v v
 WHERE 1 = 1
      --AND v.status_code LIKE 'DRAFT%'
   AND v.project_number = '11001299' --'53020362'
      --AND v.creation_date > to_date('2018-03-01', 'yyyy-mm-dd')
   AND v.organization_id = 83 --HEA_ORG--121--HBS_ORG
 ORDER BY v.project_number;

--packing
SELECT case_type,
       task_number,
       subinventory_code,
       project_number,
       project_long_name,
       delivery_number,
       list_number,
       mfg_num,
       locator_id,
       list_version,
       case_id,
       packing_list_id,
       organization_id,
       dimension_uom_code,
       to_organization_id,
       to_subinv_code,
       to_locator_id,
       po_header_id,
       po_line_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       object_version_number,
       project_id,
       task_id,
       standard_flag,
       case_item_id,
       category_set_id,
       category_id,
       delivery_id,
       oe_header_id,
       oe_line_id,
       scrap_flag,
       supplier_id,
       supplier_site_id,
       use_default_flag,
       case_number,
       case_name,
       case_status,
       case_source,
       category,
       category_desc,
       supplier_case,
       case_length,
       case_width,
       case_high,
       case_weight,
       case_net_weight,
       country_of_origin,
       remark
  FROM xxinv_cases_packing_v v
 WHERE organization_id = 83 --121
      --AND (oe_header_id = 2127868)
   AND v.project_number = '11001299' --'53020362' --'53020261' --'53020362'
   AND (scrap_flag = 'N')
 ORDER BY list_number DESC, case_number ASC;

--shipping
SELECT --delivery_id,
 delivery_number,
 --organization_id,
 packing_list_id,
 created_by,
 project_number,
 --project_long_name,
 --object_version_number,
 last_updated_by,
 last_update_date,
 TYPE,
 delivery_status,
 transport_name,
 estimate_departure_date,
 estimate_arrival_date,
 creation_date,
 created,
 remark,
 ship_from_country,
 ship_from_country_desc
  FROM xxinv_delivery_v
 WHERE 1 = 1
      --(created_by = 4270)
   AND project_number = '11001299' --'53020362'
 ORDER BY delivery_number DESC;

--Fully Delivery
SELECT org_id,
       mfg_number,
       project_number,
       --project_long_name,
       fully_packing_status,
       fully_packing_date,
       delivery_status,
       fully_delivery_date,
       top_task_id
  FROM xxinv_delivery_headers_v
 WHERE 1 = 1
   AND org_id = 82 --101
   AND project_number = '11001299' --'53020261' --'53020362'
 ORDER BY mfg_number;

/*SELECT row_id,
       order_number,
       line_number,
       market,
       line_type,
       ship_from_org_code,
       operating_unit,
       project_number,
       task_number,
       ordered_item,
       item_description,
       ordered_quantity,
       line_status,
       transaction_date,
       delivery_date,
       delivery_status,
       top_task_id,
       org_id,
       line_id,
       header_id,
       task_id,
       project_id,
       ship_from_org_id,
       flow_status_code,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
  FROM xxinv_delivery_lines_v
 WHERE (top_task_id = 6163185)
 ORDER BY order_number DESC,
          line_number  ASC;*/

--project milestone management
SELECT xpmm.proj_milestone_id,
       hou.name               operating_unit,
       pp.org_id,
       pp.project_id,
       pp.segment1            project_number,
       pt.task_id,
       pt.task_number         mfg_no,
       --xpmm.creation_date,
       xpmm.period_name,
       xpmm.ba_fully_packing_date,
       xpmm.fully_packing_date,
       xpmm.fully_delivery_date,
       xpmm.installation_progress_rate,
       xpmm.hand_over_date,
       xpmm.fm_period_month, --add by gusenlin 2014-01-21
       pp.project_type,
       pp.rowid                        row_id,
       xpmm.object_version_number,
       xpmm.created_by,
       xpmm.creation_date,
       xpmm.last_updated_by,
       xpmm.last_update_date,
       xpmm.last_update_login,
       xpmm.program_application_id,
       xpmm.program_id,
       xpmm.program_update_date,
       xpmm.request_id
  FROM pa_projects_all            pp,
       pa_tasks                   pt,
       hr_operating_units         hou,
       xxpa_proj_milestone_manage xpmm
 WHERE pp.org_id = hou.organization_id
   AND pp.enabled_flag = 'Y'
   AND pp.project_status_code = 'APPROVED'
   AND pp.template_flag = 'N'
   AND pp.project_id = pt.project_id
   AND pt.task_id = pt.top_task_id
   AND pp.org_id = nvl(xpmm.org_id, pp.org_id)
   AND pt.project_id = xpmm.project_id(+)
   AND pt.task_number = xpmm.mfg_num(+)
   AND pp.org_id = 82 --101
   AND pp.segment1 = '11001299' --'53020362' --'53020362' --'53020261'--'53020362'--'53020400'
--AND pt.task_number IN 
--('JED0210-VN','JED0211-VN','JED0212-VN','JED0219-VN','JED0220-VN','JED0225-VN')
--AND xpmm.fully_packing_date IS NOT NULL
--AND xpmm.fully_delivery_date IS NOT NULL
--AND ROWNUM < 5
 ORDER BY hou.name, pp.segment1;

--tax invoice
SELECT xth.invoice_number, xtl.item_number, xth.status_code, xtl.*
  FROM xxar_tax_invoice_headers_v xth, xxar_tax_invoice_lines_v xtl
 WHERE 1 = 1
   AND xth.header_id = xtl.header_id
   AND xth.invoice_number = 'SPE-17000226' --'DP-15000334'
      --AND xth.invoice_number LIKE 'SPE%'
   AND xtl.item_number IS NOT NULL
   AND xtl.creation_date > to_date('2018-03-01', 'yyyy-mm-dd')
--AND xth.tax_rate <> 0
--AND xth.delivery_number IS NOT NULL
--AND xth.status_code = ''

 ORDER BY xtl.creation_date DESC;

--ar invoice
SELECT rct.customer_trx_id,
       rct.trx_number,
       rct.complete_flag,
       --rct.
       rctl.line_number,
       rctl.sales_order,
       rctl.inventory_item_id item_id,
       --rctl.quantity_ordered,
       --rctl.quantity_credited,
       rctl.quantity_invoiced,
       --rctl.
       (SELECT msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND msi.inventory_item_id = rctl.inventory_item_id
              /*AND msi.organization_id = rctl.org_id */
           AND rownum = 1) item_num,
       rctl.description,
       rctl.*
  FROM ra_customer_trx_all rct, ra_customer_trx_lines_all rctl
 WHERE 1 = 1
   AND rct.customer_trx_id = rctl.customer_trx_id
   AND rct.trx_number = 'SPE-17000226' --'SPR-17000624' --'JPE-18000001'
;

--xla
SELECT xe.event_id,
       xte.entity_id,
       xte.source_id_int_1,
       xe.event_date,
       xe.creation_date,
       xah.completed_date,
       xah.gl_transfer_status_code posted,
       xah.gl_transfer_date,
       xal.ae_header_id,
       xal.ae_line_num,
       xal.accounting_class_code   acc_clss_cd,
       xal.accounted_dr            acc_dr,
       xal.accounted_cr            acc_cr,
       xal.accounting_date,
       xte.entity_id,
       xte.entity_code,
       xte.creation_date,
       xte.transaction_number,
       xte.ledger_id,
       xah.event_id,
       xah.accounting_date,
       xah.gl_transfer_date,
       xah.description,
       xah.completed_date,
       xah.period_name,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal
 WHERE 1 = 1
   AND xte.application_id = 222
   AND xte.ledger_id = 2021 --2041
   AND xte.entity_id = xe.entity_id
   AND xte.entity_id = xah.entity_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xte.source_id_int_1 = 4156949 --4167034
--AND xah.description = 'Invoice Transaction Type - EQ_Oversea_Invoice Invoice Transaction Number - JPE-18000001 Document Sequence Category - Document Number -'
--AND xah.creation_date > TRUNC(SYSDATE)
--AND ROWNUM = 1
;

SELECT *
  FROM xla.xla_transaction_entities xte, xla_events xe
 WHERE 1 = 1
   AND xte.application_id = 222
   AND xe.application_id = xte.application_id
   AND xe.entity_id = xte.entity_id
   AND xte.source_id_int_1 = 4156949 --4167034
;

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_short_name = 'AR';
