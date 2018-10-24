SELECT intf.actual_month act_mon,
       intf.company_name ou,
       intf.eq_er_category eqer,
       intf.additional_flag add_f,
       intf.creation_date,
       intf.created_by,
       (SELECT ooh.order_number
          FROM oe_order_headers_all   ooh,
               oe_transaction_types_v ott
         WHERE 1 = 1
           AND ooh.order_type_id = ott.transaction_type_id
           AND ott.org_id = intf.org_id
           AND ooh.header_id = intf.source_header_id) order_num,
       (SELECT ott.name
          FROM oe_order_headers_all   ooh,
               oe_transaction_types_v ott
         WHERE 1 = 1
           AND ooh.order_type_id = ott.transaction_type_id
           AND ott.org_id = intf.org_id
           AND ooh.header_id = intf.source_header_id) order_type,
       intf.mfg_num,
       pt.task_number,
       --intf.model,
       intf.sale_amount,
       intf.cogs,
       intf.material,
       intf.expense,
       intf.labour,
       intf.subcon,
       intf.packing_freight,
       pt.task_id,
       ppa.project_id,
       ppa.segment1 proj_num,
       ppa.project_status_code prj_status,
       (SELECT ooh.order_number
          FROM oe_order_headers_all   ooh,
               oe_transaction_types_v ott
         WHERE 1 = 1
           AND ooh.order_type_id = ott.transaction_type_id
           AND ott.org_id = intf.org_id
           AND ooh.header_id = intf.source_header_id) order_num,
       (SELECT ott.attribute5
          FROM oe_order_headers_all   ooh,
               oe_transaction_types_v ott
         WHERE 1 = 1
           AND ooh.order_type_id = ott.transaction_type_id
           AND ott.org_id = intf.org_id
           AND ooh.header_id = intf.source_header_id) ott_attr5,
       
       (SELECT ott.name
          FROM oe_order_headers_all   ooh,
               oe_transaction_types_v ott
         WHERE 1 = 1
           AND ooh.order_type_id = ott.transaction_type_id
           AND ott.org_id = intf.org_id
           AND ooh.header_id = intf.source_header_id) order_type,
       ppa.project_type,
       ppt.attribute7 ppt_attr7,
       intf.mfg_num,
       intf.sale_amount,
       intf.material,
       intf.labour,
       intf.subcon,
       intf.packing_freight,
       intf.*
  FROM --XXPA_COST_GCPM_INT_180622 intf,
       xxpa_cost_gcpm_int   intf,
       pa_tasks             pt,
       pa_tasks             top,
       pa_projects_all      ppa,
       pa_project_types_all ppt
 WHERE 1 = 1
   AND ppa.project_type = ppt.project_type
   AND ppa.project_id = pt.project_id
   AND pt.top_task_id = top.task_id
   AND pt.task_id = intf.task_id
   AND intf.org_id = 141--82--84 --84--SHE --82--HEA
      AND intf.eq_er_category = 'EQ'--'EQ'--'ER'--'PARTS'--'EQ'
   AND intf.mfg_num IN 
('TAC1314-TH',
'TAC1315-TH',
'TAC1316-TH',
'TAC1317-TH',
'TAC1318-TH',
'TAC1319-TH'
)
   --('ST03116-ID','ST03247-TH','')
   --('TFA0565-TH')
   --('LV1557-PL4','XU1428-BLK2-4','SBK0489-KW')--'SHE_Oversea_Assembly Parts'
   --('SAG0474-HK','JAC0061-PH','JAJ0044-MM')--'SHE_Oversea_Equipments
   --('SDB0143-PH','SS00457-HK','SUC0014-KW')--'SHE_Oversea_Spare Parts'
   --('SAG0066-PH','SAG0029-SG','SAE0042-SG','SAC0549-PH')--different so types
   --('SAG0432-SG')
      --('TFA0663-TH','TFA0694-TH','TFA0683-TH')--SHE ER
      --('JAC0004-PH','TAE0987-TH','SAG0431-HK')--SHE EQ
      --('TFA0565-TH')
      --('ST03070-TH','ST03116-ID','ST03247-TH')
      --('TFA0565-TH')
      --('TFA0931-TH')
      --('DQ0063-1')
      --('TAC0014-TH')
      --('TFA0565-TH')--('JBL0023-IN')--('TAJ0122-TH')--('JBL0023-IN')--('SBC0266-SG')      
      --('SBG0220-HK')
      --('SAG0432-SG')
      --('SBC0266-SG','SBC0256-SG','SAE0191-SG'/*'TAE0970-TH', 'TAE0969-TH', 'TAE0968-TH'*/)
      --('TFA0931-TH')
      --AND pt.task_number LIKE '%.D.11'
      --AND (pt.task_number NOT LIKE '%.EQ' AND pt.task_number NOT LIKE '%.ER')
      --AND intf.actual_month = to_date('2018-08-01', 'yyyy-mm-dd')
      --AND nvl(intf.subcon, 0) <> 0
      --AND ppa.segment1 = '11000144'--'213100127'
      --AND intf.additional_flag = '1'--'N'
      AND intf.creation_date <= to_date('2018-10-19', 'yyyy-mm-dd')
      --AND intf.subcon <> 0
   /*AND intf.group_id = (SELECT MAX(t2.group_id)
                          FROM xxpa_cost_gcpm_int t2
                         WHERE 1 = 1
                           AND t2.mfg_num = intf.mfg_num
                           AND t2.actual_month = intf.actual_month
                              AND t2.creation_date <= to_date('2018-10-19', 'yyyy-mm-dd')
                           AND t2.task_id = intf.task_id)*/
      
  /* AND EXISTS
 (SELECT 'Y'
          FROM oe_order_headers_all   ooh,
               oe_transaction_types_v ott
         WHERE 1 = 1
           AND ooh.order_type_id = ott.transaction_type_id
           AND ott.org_id = intf.org_id
           AND ooh.header_id = intf.source_header_id
           AND ott.name IN ('SHE_Oversea_Assembly Parts', 'SHE_Oversea_Equipments', 'SHE_Oversea_Spare Parts')
        
        )*/
 ORDER BY intf.mfg_num DESC,
          intf.actual_month      DESC;

--SELECT * FROM XXPA_COST_GCPM_INT_180622;

SELECT ott.*
  FROM oe_order_headers_all   ooh,
       oe_transaction_types_v ott
 WHERE 1 = 1
   AND ooh.order_type_id = ott.transaction_type_id
      --AND ott.org_id = intf.org_id
      --AND ooh.header_id = intf.source_header_id
   AND ooh.org_id = 84
   AND ooh.order_number = '22011623';

SELECT *
  FROM fnd_user fu
 WHERE 1 = 1
   AND fu.user_id IN (1133, 4088);

--SHE Subcon
SELECT --SUM(0 - XCFD.EXPENDITURE_AMOUNT) AMT
--intf.actual_month,
 xcfd.creation_date,
 xcfd.last_update_date,
 xcfd.expenditure_item_date expen_date,
 pt.task_number,
 ppa.segment1 proj_num,
 ppa.project_type,
 xcfd.org_id,
 xcfd.transfered_pa_flag trsfr,
 xcfd.cost_type,
 xcfd.expenditure_type,
 (0 - xcfd.expenditure_amount) amt,
 xcfd.expenditure_reference expen_rfr,
 xcfd.expenditure_reference
  FROM xxpa_cost_flow_dtls_all xcfd,
       pa_tasks                pt,
       pa_projects_all         ppa
 WHERE 1 = 1
   AND ppa.project_id = pt.project_id
   AND xcfd.task_id = pt.task_id
   AND substr(xcfd.expenditure_reference, 1, 7) = 'ACCRUAL'
   AND nvl(xcfd.transfered_pa_flag, 'N') = 'Y'
   AND xcfd.task_id = 4704925 --5704947--5705016--5705085--5705154--5705223--1888830--1102861--P_TASK_ID
   AND xcfd.org_id = 84 --P_ORG_ID
   AND xcfd.expenditure_item_date <= to_date('2018-03-01', 'yyyy-mm-dd') --P_END_DATE
   AND decode(cost_type,
              'FAC_FG',
              'SHE_FAC_ORG',
              'FAC_TO_HO_FG',
              'SHE_HQ_ORG',
              'FINAL_FG',
              decode(xcfd.org_id, 141, 'HET_HQ_ORG', 'SHE_HQ_ORG'), --Modify by jingjing 20180226 v5.00
              NULL) IN (SELECT ood.organization_name
                          FROM org_organization_definitions ood
                         WHERE ood.operating_unit = 84 /*P_ORG_ID*/
                        );

SELECT --SUM(0 - XCFD.EXPENDITURE_AMOUNT) AMT
--intf.actual_month,
/*xcfd.creation_date,
xcfd.last_update_date,
xcfd.expenditure_item_date expen_date,
 pt.task_number,
 ppa.segment1 proj_num,
 ppa.project_type,
 xcfd.org_id,
 xcfd.transfered_pa_flag trsfr,
 xcfd.cost_type,
 xcfd.expenditure_type,
 (0 - xcfd.expenditure_amount) amt,
 xcfd.expenditure_reference expen_rfr,
 xcfd.expenditure_reference*/
 SUM((0 - xcfd.expenditure_amount))
  FROM xxpa_cost_flow_dtls_all xcfd,
       pa_tasks                pt,
       pa_projects_all         ppa
 WHERE 1 = 1
   AND ppa.project_id = pt.project_id
   AND xcfd.task_id = pt.task_id
      --AND substr(xcfd.expenditure_reference, 1, 7) = 'ACCRUAL'
      --AND nvl(xcfd.transfered_pa_flag, 'N') = 'Y'
   AND xcfd.task_id = 4704925 --5704947--5705016--5705085--5705154--5705223--1888830--1102861--P_TASK_ID
   AND xcfd.org_id = 84 --P_ORG_ID
      --AND xcfd.expenditure_item_date <= to_date('2018-03-01', 'yyyy-mm-dd') --P_END_DATE
   AND decode(cost_type,
              'FAC_FG', --
              'SHE_FAC_ORG',
              'FAC_TO_HO_FG',
              'SHE_HQ_ORG',
              'FINAL_FG',
              decode(xcfd.org_id, 141, 'HET_HQ_ORG', 'SHE_HQ_ORG'), --Modify by jingjing 20180226 v5.00
              NULL) IN (SELECT ood.organization_name
                          FROM org_organization_definitions ood
                         WHERE ood.operating_unit = 84 /*P_ORG_ID*/
                        );

SELECT DISTINCT intf.org_id,
                intf.eq_er_category --intf.*--DISTINCT intf.creation_date
  FROM xxpa_cost_gcpm_int intf,
       pa_tasks           pt,
       pa_tasks           top,
       pa_projects_all    ppa
 WHERE 1 = 1
   AND ppa.project_id = pt.project_id
   AND pt.top_task_id = top.task_id
   AND pt.task_id = intf.task_id
      --AND intf.org_id = 82--84--SHE --82--HEA
   AND intf.eq_er_category = 'ER'
      --AND intf.mfg_num IN ('SBC0256-SG')--('SBC0266-SG')
      --('SBC0266-SG','SBC0256-SG','SAE0191-SG'/*'TAE0970-TH', 'TAE0969-TH', 'TAE0968-TH'*/)
      --AND pt.task_number LIKE '%.D.11'
      --AND (pt.task_number NOT LIKE '%.EQ' AND pt.task_number NOT LIKE '%.ER')
   AND intf.actual_month = to_date('2016-06-01', 'yyyy-mm-dd')
      --AND nvl(intf.subcon, 0) <> 0
      --AND ppa.segment1 = '213100127'
   AND intf.additional_flag = 'N'
/*   AND intf.group_id = (SELECT MAX(t2.group_id)
 FROM xxpa_cost_gcpm_int t2
WHERE 1 = 1
  AND t2.mfg_num = intf.mfg_num
  AND t2.actual_month = intf.actual_month
  AND t2.task_id = intf.task_id)*/
;

--org_id      Resp_id     Resp_app_id
--HBS 101     51249       660        
--HEA 82      50676       660
--HET 141     51272       20005
--SHE 84      50778       20005

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 51272,
                             resp_appl_id => 20005);
  mo_global.init('M');
  
END;*/
