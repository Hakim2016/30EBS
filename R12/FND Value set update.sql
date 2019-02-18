--confirm the vs to be modified   
--after changing, need to recompile the flex
SELECT *
  FROM fnd_flex_values_tl t
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM fnd_flex_values b
         WHERE 1 = 1
           AND t.flex_value_id = b.flex_value_id
           AND b.flex_value = '2132000061' --'1189200061'
        
        );

--update the vs
UPDATE fnd_flex_values_tl t
   SET t.description = 'Materials Account Payable-Common/Reconciliation'
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          FROM fnd_flex_values b
         WHERE 1 = 1
           AND t.flex_value_id = b.flex_value_id
           AND b.flex_value = '2132000061' --'1189200061'
        
        );
COMMIT;
