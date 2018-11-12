----1、项目支出查询(PA_EXPENDITURE_ITEMS_ALL)
SELECT P.PROJECT_ID,
       P.SEGMENT1                     项目编号,
       P.NAME                         项目名称,
       P.PROJECT_TYPE                 项目类型,
       P.PROJECT_STATUS_CODE          项目状态,
       EI.creation_date               支出创建时间,
      
       
       
       EI.EXPENDITURE_TYPE  项目支出类型,
       
       EI.QUANTITY 支出数量,
       
       EI.BURDEN_COST 项目负担成本, 
       pcd.amount 分录金额,
        (Select nvl(Sum(ppala.current_asset_cost), 0)
          From Pa.Pa_Project_Asset_Lines_All    Ppala,
               pa.Pa_Project_Asset_Line_Details Ppald
         Where Ppala.Project_Asset_Line_Detail_Id =
               Ppald.Project_Asset_Line_Detail_Id
           And Ppald.Expenditure_Item_Id = ei.Expenditure_Item_Id
          ) 生成资产行金额,
       (Select nvl(Sum(ppala.current_asset_cost), 0)
          From Pa.Pa_Project_Asset_Lines_All    Ppala,
               pa.Pa_Project_Asset_Line_Details Ppald
         Where Ppala.Project_Asset_Line_Detail_Id(+) =
               Ppald.Project_Asset_Line_Detail_Id
           And Ppald.Expenditure_Item_Id = ei.Expenditure_Item_Id
           And ppala.transfer_status_code = 'T') 已转资金额,
       EI.EXPENDITURE_ITEM_DATE 项目支出日期,
       --PA_EXPENDITURES_UTILS.GET_LATEST_PA_DATE(EI.EXPENDITURE_ITEM_ID) 项目会计日期,
       pcd.pa_period_name,
       pcd.gl_period_name,
       --PA_EXPENDITURES_UTILS.GET_LATEST_GL_DATE(EI.EXPENDITURE_ITEM_ID) GL日期,
       MMT.TRANSACTION_DATE 事务处理日期,
       T.TASK_NUMBER                  任务编号,
       T.TASK_NAME                    任务名称,
        T.TASK_ID,
       t.wbs_level,
       t.parent_task_id,
       
       T.CARRYING_OUT_ORGANIZATION_ID 任务ORG_ID,
       pcd.gl_date,
       GCC1.SEGMENT1 || '.' || GCC1.SEGMENT2 || '.' || GCC1.SEGMENT3 || '.' ||
       GCC1.SEGMENT4 || '.' || GCC1.SEGMENT5 || '.' || GCC1.SEGMENT6 || '.' ||
       GCC1.SEGMENT7 DR,
       GCC2.SEGMENT1 || '.' || GCC2.SEGMENT2 || '.' || GCC2.SEGMENT3 || '.' ||
       GCC2.SEGMENT4 || '.' || GCC2.SEGMENT5 || '.' || GCC2.SEGMENT6 || '.' ||
       GCC2.SEGMENT7 CR,
       EI.TRANSACTION_SOURCE 事务处理来源,
       (select t1.expenditure_comment
          from apps.pa_expenditure_comments t1
         where t1.expenditure_item_id = ei.expenditure_item_id) 备注, ----项目支出查询的备注
       pl.meaning 模块连接,
       x.expenditure_group 支出批,
       decode(EI.TRANSACTION_SOURCE,
              'PO RECEIPT',
              x.orig_user_exp_txn_reference,
              null) 接收事务处理ID,
       decode(EI.TRANSACTION_SOURCE,
              'AP INVOICE',
              x.orig_user_exp_txn_reference, -- t.orig_exp_txn_reference1 = invoice_id
              null) 发票编号,
       MTT.TRANSACTION_TYPE_NAME 事务处理类型,
       MMT.TRANSACTION_ID,
       MSI.SEGMENT1 物料编码,
       MSI.DESCRIPTION 物料说明,
       MSI.ITEM_TYPE,
       L.MEANING 物料类型,
       DECODE(PT.PROJECT_TYPE_CLASS_CODE, 'CAPITAL', EI.BILLABLE_FLAG, NULL) 是否可资本化,
       DECODE(PT.PROJECT_TYPE_CLASS_CODE,
              'CAPITAL',
              DECODE(T.RETIREMENT_COST_FLAG,
                     'N',
                     EI.REVENUE_DISTRIBUTED_FLAG,
                     NULL),
              NULL) 已分组的CIP,
       T.ATTRIBUTE1 地点1,
       T.ATTRIBUTE2 地点2,
       T.ATTRIBUTE3 地点3,
       T.SERVICE_TYPE_CODE 任务服务类型,
       T.CHARGEABLE_FLAG 是否可计费,
       T.START_DATE 任务开始时间,
       T.COMPLETION_DATE 任务结束时间,
       PO.SEGMENT1 采购订单号,
       MMT.ATTRIBUTE10 LIS1,
       MMT.ATTRIBUTE11 LIS2,
       MMT.ATTRIBUTE1 LIS3,
       EI.EXPENDITURE_ID,
       EI.EXPENDITURE_ITEM_ID 支出项ID,
       ei.request_id,
       ei.last_update_date
       
  FROM apps.PA_PROJECTS_ALL                P,
       apps.PA_TASKS                       T,
       apps.PA_EXPENDITURE_ITEMS_ALL       EI,
       apps.PA_EXPENDITURES_ALL            X,
       apps.PA_PROJECT_TYPES_ALL           PT,
       apps.MTL_MATERIAL_TRANSACTIONS      MMT,
       apps.MTL_TRANSACTION_TYPES          MTT,
       apps.mtl_system_items_b             MSI,
       apps.PA_COST_DISTRIBUTION_LINES_ALL PCD,
       apps.FND_COMMON_LOOKUPS             L,
       apps.PO_HEADERS_ALL                 PO,
       apps.PA_LOOKUPS                     pl,
       apps.GL_CODE_COMBINATIONS           GCC1,
       apps.GL_CODE_COMBINATIONS           GCC2
 WHERE T.PROJECT_ID = P.PROJECT_ID
   AND EI.PROJECT_ID = P.PROJECT_ID
   AND P.PROJECT_TYPE = PT.PROJECT_TYPE
   AND P.ORG_ID = PT.ORG_ID
   AND EI.TASK_ID = T.TASK_ID
   AND EI.EXPENDITURE_ID = X.EXPENDITURE_ID
   AND MMT.TRANSACTION_SOURCE_ID = PO.PO_HEADER_ID(+)
   AND to_number(EI.ORIG_TRANSACTION_REFERENCE) = MMT.TRANSACTION_ID(+)
   AND EI.CC_PRVDR_ORGANIZATION_ID = MMT.ORGANIZATION_ID(+)
   AND MMT.TRANSACTION_TYPE_ID = MTT.TRANSACTION_TYPE_ID(+)
   AND MSI.ORGANIZATION_ID(+) = MMT.ORGANIZATION_ID
   AND MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID(+)
   AND EI.EXPENDITURE_ITEM_ID = PCD.EXPENDITURE_ITEM_ID(+)
   AND PCD.DR_CODE_COMBINATION_ID = GCC1.CODE_COMBINATION_ID(+)
   AND PCD.CR_CODE_COMBINATION_ID = GCC2.CODE_COMBINATION_ID(+)
   AND MSI.ITEM_TYPE = L.LOOKUP_CODE(+)
   AND L.LOOKUP_TYPE(+) = 'ITEM_TYPE'
      /* and t.task_number in ('23.A015.059','23.A015.058')*/
      
   and p.segment1 in  ('A08302210300013')



   --and t.carrying_out_organization_id = 128
--导数据的时候需要区分公司，限制org_id
   /*AND T.TASK_NUMBER in ('A028',
'A084')
   AND MSI.SEGMENT1 in ('50023529',
'50023529',
'50018151',
'50018117')*/

   --and mmt.transaction_id in ('119852024')  
   -- AND PO.SEGMENT1 in ('810008188') 
   --AND MMT.ATTRIBUTE1 in ('OBGZ2016041517383587')
   --and DECODE(PT.PROJECT_TYPE_CLASS_CODE, 'CAPITAL', EI.BILLABLE_FLAG, NULL) = 'N'
   --and EI.EXPENDITURE_ITEM_ID in ('33711025')
   --and  EI.EXPENDITURE_TYPE in ('技改-在安装设备')
   /*and  decode(EI.TRANSACTION_SOURCE,
              'AP INVOICE',
              x.orig_user_exp_txn_reference, -- t.orig_exp_txn_reference1 = invoice_id
              null)in ('21221403040101') --发票编号*/
  
/*      and pcd.gl_date between
      to_date('2013-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss') and
      to_date('2016-7-31 23:59:59', 'yyyy-mm-dd hh24:mi:ss')*/
     
      --and mmt.transaction_date<to_date('2016-04-20', 'yyyy-mm-dd')--从以前到4月19号
      --and MSI.DESCRIPTION like ('%6芯G.652D层绞式管道光缆%')
      
      
      
   and pl.lookup_type = 'TIMECARD TRANSLATION'
   and pl.lookup_code = ei.system_linkage_function;
--\12839330   
