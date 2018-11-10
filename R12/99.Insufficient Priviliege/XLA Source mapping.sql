SELECT xev.accounting_attribute_code,
       xev.accounting_attribute_name,
       xev.source_code,
       xev.source_name,
       xev.assignment_group_name,
       xad.extract_object_name,
       always_populated_flag,
       source_hash_id,
       product_rule_code
  FROM xla_evt_class_acct_attrs_fvl xev,
       xla_aad_sources              xad
 WHERE xev.event_class_code = 'WIP_MTL'
   AND xev.source_code = xad.source_code
   AND xev.event_class_code = xad.event_class_code
   AND default_flag = 'Y'
   AND assignment_level_code = 'EVT_CLASS_ONLY'
   AND xad.product_rule_code IN (SELECT product_rule_code
                                   FROM xla_acctg_method_rules
                                  WHERE application_id = '707'
                                    AND accounting_method_code IN (SELECT sla_accounting_method_code
                                                                     FROM gl_ledgers
                                                                    WHERE ledger_id = '2023'))
 ORDER BY accounting_attribute_code
;
