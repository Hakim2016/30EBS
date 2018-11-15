SELECT FFVS.FLEX_VALUE_SET_NAME,
       FFVV.FLEX_VALUE ACC,
       FFVV.FLEX_VALUE_MEANING,
       FFVV.DESCRIPTION,
       --substr(ffvv.compiled_value_attributes, 5, 1),
       DECODE(SUBSTR(FFVV.COMPILED_VALUE_ATTRIBUTES, 5, 1),
              'A',
              'Asset',
              'R',
              'E',
              'Expense',
              'L',
              'Liability') CATE,
              'Revenue',
              'O',
              'Owners Equlity',
       FFVS.*,
       FFVV.*

  FROM APPS.FND_FLEX_VALUE_SETS FFVS, APPS.FND_FLEX_VALUES_VL FFVV
 WHERE 1 = 1
   AND FFVS.FLEX_VALUE_SET_NAME LIKE 'CMCC_COA_SAC' --'%ACCOUNT%' --= 'HEA_ACCOUNT' --'XXHEA_PAYMENT METHOD'
   AND FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
--AND ffvv.flex_value_meaning = p_payment_method
--AND ROWNUM = 1
--AND FFVV.FLEX_VALUE LIKE '%1151010100%'
--AND ffvv.flex_value_meaning = '2121100000'
 ORDER BY FFVV.FLEX_VALUE_MEANING;

--Accounting setting
SELECT FFVS.DESCRIPTION,       
       FFVS.*
  FROM APPS.FND_FLEX_VALUE_SETS FFVS
 WHERE 1 = 1
   AND FFVS.FLEX_VALUE_SET_NAME LIKE 'CMCC%COA%';
