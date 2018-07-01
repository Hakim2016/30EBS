SELECT DISTINCT xte.entity_code,
                xte.application_id
--xte.* 
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1;

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id IN (200, 222, 275, 707);

SELECT *
  FROM xla_transaction_entities;

SELECT v.application_id app_id,
       fa.application_short_name app,
       v.entity_code,
       v.name,
       v.description,
       v.*
  FROM xla_entity_types_vl v,
       fnd_application     fa
 WHERE 1 = 1
   AND v.application_id = fa.application_id
 ORDER BY v.application_id;
