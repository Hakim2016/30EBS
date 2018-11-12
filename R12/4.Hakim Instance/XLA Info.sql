SELECT xjt.accounting_line_code,
       xjt.accounting_attribute_code,
       xjt.accounting_attribute_name,
       xjt.source_code,
       xjt.source_name,
       xad.extract_object_name,
       xjt.assignment_group_name,
       always_populated_flag,
       source_hash_id,
       product_rule_code
  FROM xla_jlt_acct_attrs_fvl xjt,
       xla_aad_sources        xad
 WHERE xjt.event_class_code = 'WIP_MTL'
   AND product_rule_code IN (SELECT product_rule_code
                               FROM xla_acctg_method_rules
                              WHERE application_id = '707'
                                AND accounting_method_code IN (SELECT sla_accounting_method_code
                                                                 FROM gl_ledgers
                                                                WHERE ledger_id = '2023'))
   AND xjt.source_code = xad.source_code
   AND xjt.event_class_code = xad.event_class_code
 ORDER BY xjt.accounting_line_code,
          xjt.accounting_attribute_code
;
