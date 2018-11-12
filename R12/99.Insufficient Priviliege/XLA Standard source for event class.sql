SELECT xas.source_code,
       xst.name,
       xas.source_level_code,
       xas.extract_object_name,
       xas.extract_object_type_code
  FROM xla_aad_sources xas,
       xla_sources_tl  xst
 WHERE xas.source_code = xst.source_code
   AND xas.application_id = xst.application_id
   AND xas.event_class_code = 'WIP_MTL'
   AND xas.product_rule_code IN (SELECT product_rule_code
                                   FROM xla_acctg_method_rules
                                  WHERE application_id = '707'
                                    AND accounting_method_code IN (SELECT sla_accounting_method_code
                                                                     FROM gl_ledgers
                                                                    WHERE ledger_id = '2023'))
   AND xst.language = userenv('lang')
 ORDER BY source_level_code,
          extract_object_name,
          source_code;

SELECT xas.creation_date,
       xas.event_class_code,
       xas.*
  FROM xla_aad_sources xas
 WHERE 1 = 1
      --AND xas.event_class_code
   --AND xas.entity_code = 'MTL_ACCOUNTING_EVENTS'
   AND xas.extract_object_type_code = 'HEADER'
   --AND xas.event_class_code = 'WIP_MTL'
      AND xas.product_rule_code = 'SHE_COST_MANAGMENT'
   AND xas.product_rule_type_code = 'C';

SELECT rl.accounting_method_code,
       rl.product_rule_code,
       rl.* --product_rule_code
  FROM xla_acctg_method_rules rl
 WHERE application_id = '707'
   AND accounting_method_code IN (SELECT sla_accounting_method_code
                                    FROM gl_ledgers
                                   WHERE ledger_id = '2023');

SELECT * --sla_accounting_method_code
  FROM gl_ledgers
 WHERE ledger_id = '2023';
