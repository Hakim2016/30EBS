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
       accv.end_date_active
--,accs.*
--*
  FROM apps.fnd_flex_values_vl  accv,
       apps.fnd_flex_value_sets accs,
       apps.fnd_flex_values_vl  subaccv,
       apps.fnd_flex_value_sets subaccs
 WHERE 1 = 1
   AND accs.flex_value_set_name = 'HEA_ACCOUNT'
   AND accs.flex_value_set_id = accv.flex_value_set_id
   AND subaccs.flex_value_set_name = 'HEA_SUBACCOUNT'
   AND subaccs.flex_value_set_id = subaccv.flex_value_set_id
   AND accv.flex_value = subaccv.parent_flex_value_low
--AND accv.flex_value = '1161500990'--'1145400000'--'1161500990'
--AND accv.flex_value LIKE '%150101%'--= '1161500990'--'1145400000'--'1161500990'

--AND subaccv.flex_value = '1146011000'

 ORDER BY accv.flex_value,
          subaccv.flex_value;

SELECT accv.flex_value acc,
       --accv.flex_value_meaning,
       accv.description    desc_acc
  FROM apps.fnd_flex_values_vl  accv,
       apps.fnd_flex_value_sets accs
 WHERE 1 = 1
   AND accs.flex_value_set_name = 'HEA_ACCOUNT'
   AND accs.flex_value_set_id = accv.flex_value_set_id
   ORDER BY accv.flex_value;
