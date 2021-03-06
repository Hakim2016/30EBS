SELECT ppa.closed_date,
       ppa.segment1,
       ppa.project_type,
       ppa.name,
       pt.*
  FROM pa_projects_all ppa,
       pa_tasks        pt
 WHERE 1 = 1
   AND ppa.project_id = pt.project_id
      AND ppa.project_id 
      = 949441--2770903
      --IN(2770903,2770902,2751880,2751879,2751878,2743828,2743827,2743828,2746853,2743828)
--2803052
--2394211--2394210--2663642--2593410--2340212--1523038--136165--1431916
      --IN(2394210,2394211,2394212,2754887,2754888)
      --IN (2803054,2803053,2803052,2806053,2818057,2800054,2785962,2800055,2785962,2785962)
      --AND pt.task_number = 'TAC0523-TH' --'TAE0736-TH'--'TAE1072-TH.ER'
      --AND ppa.project_type = 'SHE HO_SHE Project'
   --AND ppa.segment1 = '217060080'--'11001296'--'2663642'--'12003056' --'21000473' --'21000400'--'21000056' --'21000769'--'215110107'
      --''3122306
      --'202474'--'23000461'--'202474'--'12003759'--'10101506'
      --AND pt.task_number LIKE '%.ER'
      --AND ppa.last_update_date > to_date('20180101','yyyymmdd')
      --AND ppa.closed_date IS NULL
   AND pt.task_id = pt.top_task_id
   --AND ppa.org_id = 84--82 --84
;
--2207196
SELECT ooh.order_number,
       ott.name         so_type,
       ool.ordered_item,
       top.task_number,
       pt.task_number,
       ppa.segment1     prj_num,
       ppa.project_type,
       --ool.project_id,
       --ool.task_id,
       ooh.*,
       ool.*
  FROM oe_order_headers_all   ooh,
       oe_order_lines_all     ool,
       oe_transaction_types_v ott,
       pa_projects_all        ppa,
       pa_tasks               pt,
       pa_tasks               top
 WHERE 1 = 1
   AND ooh.order_type_id = ott.transaction_type_id
   AND ott.org_id = ool.org_id
   AND ppa.project_id = ool.project_id
   AND pt.task_id = ool.task_id
   AND ppa.project_id = pt.project_id
   AND pt.top_task_id = top.task_id
   AND ooh.header_id = ool.header_id
      --AND upper(ott.name) LIKE '%DOMESTIC%'
      --AND ooh.order_number = '23000461' --'23000414'
   AND ott.name LIKE 'SHE%Oversea%Assembly%Parts'
   AND ool.org_id = 84 --82
   AND ooh.creation_date >= to_date('20170601', 'yyyymmdd')
--AND ppa.project_type IN ('J', 'P', 'V', 'W', 'A', 'F', 'M', 'N', 'Q', 'Y');
;

SELECT ppt.project_type,
       ppt.org_id,
       ppt.attribute8   fg_transfer,
       ppt.attribute9   cogs_clearing,
       ppt.attribute7   project_type
  FROM pa_project_types_all ppt
 WHERE 1 = 1
   AND ppt.org_id = 84
   AND (ppt.project_type IN ('SHE FAC_Assy Parts',
                             'SHE FAC_Elevator',
                             'SHE FAC_MTE Parts',
                             'SHE FAC_Prototype',
                             'SHE FAC_Spare Parts',
                             'SHE HO_HEA Project',
                             'SHE HO_INST Defect',
                             'SHE HO_Mix Project',
                             'SHE HO_SHE Project',
                             'SHE_Forecast') OR ppt.attribute9 = 'FAC FG Completion');

SELECT ppt.project_type,
       ppt.project_type_class_code,
       ppt.description,
       ppt.direct_flag,
       ppt.labor_invoice_format_id,
       ppt.non_labor_invoice_format_id,
       ppt.non_labor_bill_rate_org_id,
       ppt.non_labor_std_bill_rate_schdl,
       ppt.attribute1,
       ppt.*
  FROM pa_project_types_all ppt
 WHERE 1 = 1
      --AND ppt.attribute9 = 'FAC FG Completion'
   AND ppt.org_id = 82 --84--82
   AND ppt.project_type IN ('J', 'P', 'V', 'W', 'A', 'F', 'M', 'N', 'Q', 'Y')
   AND ppt.project_type IN ('J', 'P', 'V', 'W', 'Q');

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
