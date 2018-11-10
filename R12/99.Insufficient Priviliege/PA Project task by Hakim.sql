SELECT PPA.CLOSED_DATE,
       PPA.CREATION_DATE,
       PPA.TEMPLATE_FLAG,
       PPA.SEGMENT1 项目编号,
       PPA.PROJECT_TYPE,
       PPA.NAME,
       PT.*
  FROM APPS.PA_PROJECTS_ALL PPA, APPS.PA_TASKS PT
 WHERE 1 = 1
   AND PPA.PROJECT_ID = PT.PROJECT_ID
   AND PPA.TEMPLATE_FLAG <> 'Y'
      --AND ppa.project_id 
      --= 949441--2770903
      --IN(2770903,2770902,2751880,2751879,2751878,2743828,2743827,2743828,2746853,2743828)
      --AND pt.task_number = 'TAC0523-TH' --'TAE0736-TH'--'TAE1072-TH.ER'
      --AND ppa.project_type = 'SHE HO_SHE Project'
      --AND ppa.segment1 = '217060080'--'11001296'--'2663642'--'12003056' --'21000473' --'21000400'--'21000056' --'21000769'--'215110107'
      --AND pt.task_number LIKE '%.ER'
      --AND ppa.last_update_date > to_date('20180101','yyyymmdd')
      --AND ppa.closed_date IS NULL
   AND PPA.ORG_ID = 107 --302210
   AND PT.TASK_ID = PT.TOP_TASK_ID;
--查看所有的项目模板

SELECT PPA.SEGMENT1            项目编号,
       PPA.PROJECT_STATUS_CODE 状态,
       ppa.START_DATE,--事务处理持续时间开始
       --ppa.COMPLETION_DATE,--事务处理持续时间结束
       --ppa.ACTUAL_START_DATE,
       PPA.DESCRIPTION,
       PPA.PROJECT_TYPE,
       PPA.CREATION_DATE,
       PPA.*
  FROM APPS.PA_PROJECTS_ALL PPA
 WHERE 1 = 1
   AND PPA.TEMPLATE_FLAG <> 'Y'
   AND PPA.ORG_ID = 107 --302210
   AND NOT EXISTS (SELECT 1
          FROM APPS.PA_PROJECT_ASSETS_ALL PAS
         WHERE 1 = 1
           AND PAS.PROJECT_ID = PPA.PROJECT_ID);
--2207196
SELECT OOH.ORDER_NUMBER,
       OTT.NAME         SO_TYPE,
       OOL.ORDERED_ITEM,
       TOP.TASK_NUMBER,
       PT.TASK_NUMBER,
       PPA.SEGMENT1     PRJ_NUM,
       PPA.PROJECT_TYPE,
       --ool.project_id,
       --ool.task_id,
       OOH.*,
       OOL.*
  FROM OE_ORDER_HEADERS_ALL   OOH,
       OE_ORDER_LINES_ALL     OOL,
       OE_TRANSACTION_TYPES_V OTT,
       PA_PROJECTS_ALL        PPA,
       PA_TASKS               PT,
       PA_TASKS               TOP
 WHERE 1 = 1
   AND OOH.ORDER_TYPE_ID = OTT.TRANSACTION_TYPE_ID
   AND OTT.ORG_ID = OOL.ORG_ID
   AND PPA.PROJECT_ID = OOL.PROJECT_ID
   AND PT.TASK_ID = OOL.TASK_ID
   AND PPA.PROJECT_ID = PT.PROJECT_ID
   AND PT.TOP_TASK_ID = TOP.TASK_ID
   AND OOH.HEADER_ID = OOL.HEADER_ID
      --AND upper(ott.name) LIKE '%DOMESTIC%'
      --AND ooh.order_number = '23000461' --'23000414'
   AND OTT.NAME LIKE 'SHE%Oversea%Assembly%Parts'
   AND OOL.ORG_ID = 84 --82
   AND OOH.CREATION_DATE >= TO_DATE('20170601', 'yyyymmdd')
--AND ppa.project_type IN ('J', 'P', 'V', 'W', 'A', 'F', 'M', 'N', 'Q', 'Y');
;

SELECT PPT.PROJECT_TYPE,
       PPT.ORG_ID,
       PPT.ATTRIBUTE8   FG_TRANSFER,
       PPT.ATTRIBUTE9   COGS_CLEARING,
       PPT.ATTRIBUTE7   PROJECT_TYPE
  FROM PA_PROJECT_TYPES_ALL PPT
 WHERE 1 = 1
   AND PPT.ORG_ID = 84
   AND (PPT.PROJECT_TYPE IN ('SHE FAC_Assy Parts',
                             'SHE FAC_Elevator',
                             'SHE FAC_MTE Parts',
                             'SHE FAC_Prototype',
                             'SHE FAC_Spare Parts',
                             'SHE HO_HEA Project',
                             'SHE HO_INST Defect',
                             'SHE HO_Mix Project',
                             'SHE HO_SHE Project',
                             'SHE_Forecast') OR
       PPT.ATTRIBUTE9 = 'FAC FG Completion');

SELECT PPT.PROJECT_TYPE,
       PPT.PROJECT_TYPE_CLASS_CODE,
       PPT.DESCRIPTION,
       PPT.DIRECT_FLAG,
       PPT.LABOR_INVOICE_FORMAT_ID,
       PPT.NON_LABOR_INVOICE_FORMAT_ID,
       PPT.NON_LABOR_BILL_RATE_ORG_ID,
       PPT.NON_LABOR_STD_BILL_RATE_SCHDL,
       PPT.ATTRIBUTE1,
       PPT.*
  FROM PA_PROJECT_TYPES_ALL PPT
 WHERE 1 = 1
      --AND ppt.attribute9 = 'FAC FG Completion'
   AND PPT.ORG_ID = 82 --84--82
   AND PPT.PROJECT_TYPE IN
       ('J', 'P', 'V', 'W', 'A', 'F', 'M', 'N', 'Q', 'Y')
   AND PPT.PROJECT_TYPE IN ('J', 'P', 'V', 'W', 'Q');

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
