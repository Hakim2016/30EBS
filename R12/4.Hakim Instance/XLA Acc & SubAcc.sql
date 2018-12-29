--ACC&SUBACC
SELECT ACCV.FLEX_VALUE ACC,
       --subaccv.parent_flex_value_low,
       SUBACCV.FLEX_VALUE SUBACC,
       --accv.flex_value_meaning,
       ACCV.DESCRIPTION    DESC_ACC,
       SUBACCV.DESCRIPTION DESC_SUBACC,
       --substr(accv.compiled_value_attributes, 5, 1),
       DECODE(SUBSTR(ACCV.COMPILED_VALUE_ATTRIBUTES, 5, 1),
              'A',
              'Asset',
              'R',
              'Revenue',
              'O',
              'Owners Equlity',
              'E',
              'Expense',
              'L',
              'Liability') CATE,
       ACCS.FLEX_VALUE_SET_NAME,
       ACCV.END_DATE_ACTIVE
--,accs.*
--*
  FROM APPS.FND_FLEX_VALUES_VL  ACCV,
       APPS.FND_FLEX_VALUE_SETS ACCS,
       APPS.FND_FLEX_VALUES_VL  SUBACCV,
       APPS.FND_FLEX_VALUE_SETS SUBACCS
 WHERE 1 = 1
   AND ACCS.FLEX_VALUE_SET_NAME = 'HAKIM_VS_ACC' --'CMCC_COA_AC'--'HEA_ACCOUNT'
   AND ACCS.FLEX_VALUE_SET_ID = ACCV.FLEX_VALUE_SET_ID
   AND SUBACCS.FLEX_VALUE_SET_NAME = 'HAKIM_VS_SUBACC' --'CMCC_COA_SAC'--'HEA_SUBACCOUNT'
   AND SUBACCS.FLEX_VALUE_SET_ID = SUBACCV.FLEX_VALUE_SET_ID
   AND ACCV.FLEX_VALUE = SUBACCV.PARENT_FLEX_VALUE_LOW
--AND accv.flex_value LIKE '%150101%'--= '1161500990'--'1145400000'--'1161500990'
AND subaccv.flex_value = '1112009000'--'1146011000'

 ORDER BY ACCV.FLEX_VALUE, SUBACCV.FLEX_VALUE;

SELECT ACCV.FLEX_VALUE ACC,
       --accv.flex_value_meaning,
       ACCV.DESCRIPTION DESC_ACC,
       ACCV.ENABLED_FLAG,
       accv.END_DATE_ACTIVE
  FROM APPS.FND_FLEX_VALUE_SETS ACCS, APPS.FND_FLEX_VALUES_VL ACCV
 WHERE 1 = 1
   AND FLEX_VALUE_SET_NAME = 'HAKIM_VS_ACC'--'HAKIM_VS_SUBACC'
   AND ACCS.FLEX_VALUE_SET_ID = ACCV.FLEX_VALUE_SET_ID;