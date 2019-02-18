SELECT B.name,
       A1.SEGMENT1 || '.' || A1.SEGMENT2 || '.' || A1.SEGMENT3 || '.' ||
       A1.SEGMENT4 || '.' || A1.SEGMENT5 || '.' || A1.SEGMENT6 || '.' ||
       A1.SEGMENT7 || '.' || A1.SEGMENT8 || '.' || A1.SEGMENT9 �����˻�,
       A2.SEGMENT1 || '.' || A2.SEGMENT2 || '.' || A2.SEGMENT3 || '.' ||
       A2.SEGMENT4 || '.' || A2.SEGMENT5 || '.' || A2.SEGMENT6 || '.' ||
       A2.SEGMENT7 || '.' || A2.SEGMENT8 || '.' || A2.SEGMENT9 �����˻�
       ,t.*
  FROM APPS.RCV_PARAMETERS         T,
       APPS.GL_CODE_COMBINATIONS_V A1,
       APPS.GL_CODE_COMBINATIONS_V A2,
       APPS.HR_ORGANIZATION_UNITS  B
 WHERE T.RECEIVING_ACCOUNT_ID = A1.CODE_COMBINATION_ID
   AND T.CLEARING_ACCOUNT_ID = A2.CODE_COMBINATION_ID
   AND T.ORGANIZATION_ID = B.organization_id;
