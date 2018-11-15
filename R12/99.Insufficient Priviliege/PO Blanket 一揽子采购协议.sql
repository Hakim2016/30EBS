SELECT

 POH.SEGMENT1 AS PO���,
 POH.TYPE_LOOKUP_CODE AS ����,
 (SELECT /*pap.person_id,
           pap.party_id,*/
  --PAP.LAST_NAME ,
  --pap.first_name
   PAP.FULL_NAME
    FROM PER_ALL_PEOPLE_F PAP
   WHERE 1 = 1
     AND PAP.PERSON_ID = POH.AGENT_ID --9851--81
     AND PAP.EFFECTIVE_END_DATE > SYSDATE) AS �ɹ�Ա,
 --POH.AGENT_ID AS �ɹ�Ա,
 PV.VENDOR_NAME AS ��Ӧ��,
 (SELECT XX.NAME
    FROM AP_TERMS XX
   WHERE 1 = 1
     AND XX.TERM_ID =
         POH.TERMS_ID) AS ����,
 --poh.TERMS_ID || 999999 AS ����2,
 
 poh.start_date AS Э������,
 poh.end_date AS ������,
 POH.CANCEL_FLAG AS ��ȡ��,
 POH.STATUS_LOOKUP_CODE AS ״̬,
 POH.CURRENCY_CODE AS ����,
 POL.LINE_NUM AS ��,
 (SELECT MC.SEGMENT3 || '.' || MC.SEGMENT4
    FROM MTL_CATEGORIES MC
   WHERE 1 = 1
     AND MC.CATEGORY_ID = --560--97238
        
         POL.CATEGORY_ID) AS ���,
 --POL.CATEGORY_ID || 999999 AS ���2,
 MSI.SEGMENT1           AS ����,
 MSI.DESCRIPTION        AS ˵��,
 POL.QUANTITY_COMMITTED AS �鶨����,
 
 --999999          AS ������,
 --999999          AS ��������,
 --999999          AS ��������,
 POL.UNIT_PRICE AS ����,
 --999999          AS �����۸�,
 POL.UNIT_MEAS_LOOKUP_CODE AS ��λ,
 POH.CANCEL_FLAG AS ��ȡ��,
 (SELECT XX.NAME
    FROM AP_TERMS XX
   WHERE 1 = 1
     AND XX.TERM_ID =
        --10087
         POH.TERMS_ID) AS ��������
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
