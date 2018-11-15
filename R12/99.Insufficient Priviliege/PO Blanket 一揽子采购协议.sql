SELECT

 POH.SEGMENT1 AS PO编号,
 POH.TYPE_LOOKUP_CODE AS 类型,
 (SELECT /*pap.person_id,
           pap.party_id,*/
  --PAP.LAST_NAME ,
  --pap.first_name
   PAP.FULL_NAME
    FROM PER_ALL_PEOPLE_F PAP
   WHERE 1 = 1
     AND PAP.PERSON_ID = POH.AGENT_ID --9851--81
     AND PAP.EFFECTIVE_END_DATE > SYSDATE) AS 采购员,
 --POH.AGENT_ID AS 采购员,
 PV.VENDOR_NAME AS 供应商,
 (SELECT XX.NAME
    FROM AP_TERMS XX
   WHERE 1 = 1
     AND XX.TERM_ID =
         POH.TERMS_ID) AS 条款,
 --poh.TERMS_ID || 999999 AS 条款2,
 
 poh.start_date AS 协议日期,
 poh.end_date AS 到期日,
 POH.CANCEL_FLAG AS 已取消,
 POH.STATUS_LOOKUP_CODE AS 状态,
 POH.CURRENCY_CODE AS 币种,
 POL.LINE_NUM AS 行,
 (SELECT MC.SEGMENT3 || '.' || MC.SEGMENT4
    FROM MTL_CATEGORIES MC
   WHERE 1 = 1
     AND MC.CATEGORY_ID = --560--97238
        
         POL.CATEGORY_ID) AS 类别,
 --POL.CATEGORY_ID || 999999 AS 类别2,
 MSI.SEGMENT1           AS 物料,
 MSI.DESCRIPTION        AS 说明,
 POL.QUANTITY_COMMITTED AS 议定数量,
 
 --999999          AS 订货量,
 --999999          AS 接收数量,
 --999999          AS 开单数量,
 POL.UNIT_PRICE AS 单价,
 --999999          AS 发货价格,
 POL.UNIT_MEAS_LOOKUP_CODE AS 单位,
 POH.CANCEL_FLAG AS 已取消,
 (SELECT XX.NAME
    FROM AP_TERMS XX
   WHERE 1 = 1
     AND XX.TERM_ID =
        --10087
         POH.TERMS_ID) AS 付款条款
         ,poh.created_by

  FROM PO_HEADERS_ALL     POH,
       PO_LINES_ALL       POL,
       MTL_SYSTEM_ITEMS_B MSI,
       PO_VENDORS         PV,
       FND_USER           FU
 WHERE 1 = 1
   AND MSI.ORGANIZATION_ID = 1131 --828--1131 --pol.
   AND MSI.INVENTORY_ITEM_ID = POL.ITEM_ID
   AND POH.VENDOR_ID = PV.VENDOR_ID
      --AND poh.vendor_id = 379
   AND FU.USER_ID = POH.CREATED_BY
   AND POH.PO_HEADER_ID = POL.PO_HEADER_ID
      --AND poh.segment1 = '10062173'--'10000023'
   AND POH.ORG_ID = 1129 --808--1129 --101 --84 --101
      --AND poh.cancel_flag = 'N'
   --AND POH.APPROVED_FLAG = 'Y'
   AND POH.TYPE_LOOKUP_CODE = 'BLANKET'
      --AND poh.creation_date >= to_date('20170101', 'yyyymmdd')
   --AND POH.SEGMENT1 = '1343' --'3041'--'1343'--'1343'--'3041'--'1343' --'10000415' --'10026376' --'10000341' --'10051165'
--AND pol.unit_price = 27014
;
--82/84
