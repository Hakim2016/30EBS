--ACC&SUBACC
SELECT accv.flex_value acc,
       --subaccv.parent_flex_value_low,
       subaccv.flex_value subacc,
       --accv.flex_value_meaning,
       accv.description    desc_acc,
       subaccv.description desc_subacc,
       --substr(accv.compiled_value_attributes, 5, 1),
       decode(substr(accv.compiled_value_attributes, 5, 1),
              'A',
              'Asset',
              'R',
              'Revenue',
              'O',
              'Owners Equlity',
              'E',
              'Expense',
              'L',
              'Liability') cate,
       accs.flex_value_set_name,
       accv.SUMMARY_FLAG,
       accv.end_date_active
--,accs.*
--*
  FROM apps.fnd_flex_values_vl  accv,
       apps.fnd_flex_value_sets accs,
       apps.fnd_flex_values_vl  subaccv,
       apps.fnd_flex_value_sets subaccs
 WHERE 1 = 1
   AND accs.flex_value_set_name = 'ALAND_COA_ACC'--'HEA_ACCOUNT'
   AND accs.flex_value_set_id = accv.flex_value_set_id
   AND subaccs.flex_value_set_name = 'ALAND_COA_SUBACC'--'HEA_SUBACCOUNT'
   AND subaccs.flex_value_set_id = subaccv.flex_value_set_id
   AND accv.flex_value = subaccv.parent_flex_value_low
--AND accv.flex_value = '1161500990'--'1145400000'--'1161500990'
--AND accv.flex_value LIKE '%150101%'--= '1161500990'--'1145400000'--'1161500990'

--AND subaccv.flex_value = '1146011000'

 ORDER BY accv.flex_value,
          subaccv.flex_value;

--���Ŷα���
SELECT /*DISTINCT*/ accs.flex_value_set_name,
       accv.flex_value acc,
       --accv.flex_value_meaning,
       accv.description    desc_acc,
       accv.ATTRIBUTE2,
       accv.SUMMARY_FLAG
  FROM apps.fnd_flex_values_vl  accv,
       apps.fnd_flex_value_sets accs
 WHERE 1 = 1
   AND accs.flex_value_set_name LIKE 'ALAND_COA_DEPT%'
   AND accs.flex_value_set_id = accv.flex_value_set_id
   AND accv.SUMMARY_FLAG = 'N'
   AND accv.flex_value LIKE '101%'
   --AND accv.ATTRIBUTE2 IS NOT NULL
   --ORDER BY accv.flex_value
   ;
--��Ŀ�α���
SELECT /*DISTINCT*/ accs.flex_value_set_name,
       accv.flex_value acc,
       --accv.flex_value_meaning,
       accv.description    desc_acc,
       accv.SUMMARY_FLAG,
       accv.ATTRIBUTE2
  FROM apps.fnd_flex_values_vl  accv,
       apps.fnd_flex_value_sets accs
 WHERE 1 = 1
   AND accs.flex_value_set_name LIKE 'ALAND_COA_PRJ%'
   --AND accs.
   AND accs.flex_value_set_id = accv.flex_value_set_id
   --AND accv.ATTRIBUTE2 IS NOT NULL
   --ORDER BY accv.flex_value
   ;
   
   
--��Ŀ�α���
SELECT /*DISTINCT*/ accs.flex_value_set_name,
       accv.flex_value acc,
       --accv.flex_value_meaning,
       accv.description    desc_acc,
       accv.ATTRIBUTE2,
       v.parent_flex_value
  FROM apps.fnd_flex_values_vl  accv,
       apps.fnd_flex_value_sets accs,
       apps.fnd_flex_value_children_v v
 WHERE 1 = 1
   AND accs.flex_value_set_name LIKE 'ALAND_COA_ACC%'
   AND v.flex_value_set_id = accs.FLEX_VALUE_SET_ID
   AND v.
   AND accs.flex_value_set_id = accv.flex_value_set_id
   --AND accv.ATTRIBUTE2 IS NOT NULL
   --ORDER BY accv.flex_value
   ;
