SELECT ACR.RECEIPT_DATE, ACR.AMOUNT, ACR.*
  FROM AR_CASH_RECEIPTS_ALL ACR
 WHERE 1 = 1
      --AND acr.cash_receipt_id = 1004 --1000
   AND ACR.RECEIPT_NUMBER = '1700000592' --'HKMTOAP013160' --'2800000018'
   AND ACR.ORG_ID = 82
--AND acr.creation_date >= to_date('20180925','yyyymmdd')

;

SELECT XE.EVENT_ID,
       XE.ENTITY_ID,
       XE.EVENT_TYPE_CODE,
       XTE.ENTITY_CODE,
       XTE.TRANSACTION_NUMBER,
       XE.EVENT_STATUS_CODE   EVT_STS,
       XE.PROCESS_STATUS_CODE PRC_STS,
       XTE.*
  FROM XLA_EVENTS XE, XLA.XLA_TRANSACTION_ENTITIES XTE, XLA_AE_HEADERS XAH
 WHERE 1 = 1
   AND XTE.ENTITY_ID = XAH.ENTITY_ID
   AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
   AND XE.ENTITY_ID = XTE.ENTITY_ID
   AND XE.APPLICATION_ID = XTE.APPLICATION_ID
   AND XE.APPLICATION_ID = 222 --707
      --AND xe.creation_date >= trunc(SYSDATE)
   AND XE.EVENT_ID > 29975865;

SELECT *
  FROM XLA.XLA_TRANSACTION_ENTITIES XTE
 WHERE 1 = 1
   AND XTE.APPLICATION_ID = 222
      --AND xte.entity_code = 'RECEIPTS'
      --AND xte.source_id_int_1 = 1297914
   AND XTE.CREATION_DATE >= TRUNC(SYSDATE) - 2;

SELECT XE.CREATION_DATE, XE.*
  FROM XLA_EVENTS XE
 WHERE 1 = 1
   AND XE.APPLICATION_ID = 222 --707
   AND XE.CREATION_DATE >= TRUNC(SYSDATE) - 2
   AND XE.EVENT_ID > 29975865;
