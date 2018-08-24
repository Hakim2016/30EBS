--ACC&SUBACC
SELECT accv.flex_value acc,
       --subaccv.parent_flex_value_low,
       subaccv.flex_value subacc,
       --accv.flex_value_meaning,
       accv.description desc_acc,
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

--*
  FROM fnd_flex_values_vl  accv,
       fnd_flex_value_sets accs,
       fnd_flex_values_vl  subaccv,
       fnd_flex_value_sets subaccs
 WHERE 1 = 1
   AND accs.flex_value_set_name = 'SHE_ACCOUNT'
   AND accs.flex_value_set_id = accv.flex_value_set_id
   AND subaccs.flex_value_set_name = 'SHE_SUBACCOUNT'
   AND subaccs.flex_value_set_id = subaccv.flex_value_set_id
   AND accv.flex_value = subaccv.parent_flex_value_low

 ORDER BY accv.flex_value,
          subaccv.flex_value
