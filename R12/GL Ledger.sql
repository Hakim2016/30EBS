SELECT lg.ledger_id,
       lg.name                       ledger_name,
       lg.short_name                 ledger_short_name,
       cfgdet.object_id              legal_entity_id,
       le.name                       legal_entity_name,
       reg.location_id               location_id,
       hrloctl.location_code         location_code,
       hrloctl.description           location_description,
       lg.ledger_category_code,
       lg.currency_code,
       lg.chart_of_accounts_id,
       lg.period_set_name,
       lg.accounted_period_type,
       lg.sla_accounting_method_code,
       lg.sla_accounting_method_type,
       lg.bal_seg_value_option_code,
       lg.bal_seg_column_name,
       lg.bal_seg_value_set_id,
       cfg.acctg_environment_code,
       cfg.configuration_id,
       rs.primary_ledger_id,
       rs.relationship_enabled_flag
  FROM gl_ledger_config_details primdet,
       gl_ledgers               lg,
       gl_ledger_relationships  rs,
       gl_ledger_configurations cfg,
       gl_ledger_config_details cfgdet,
       xle_entity_profiles      le,
       xle_registrations        reg,
       hr_locations_all_tl      hrloctl
 WHERE rs.application_id = 101
   AND ((rs.target_ledger_category_code = 'SECONDARY' AND
       rs.relationship_type_code <> 'NONE') OR
       (rs.target_ledger_category_code = 'PRIMARY' AND
       rs.relationship_type_code = 'NONE') OR
       (rs.target_ledger_category_code = 'ALC' AND
       rs.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')))
   AND lg.ledger_id = rs.target_ledger_id
   AND lg.ledger_category_code = rs.target_ledger_category_code
   AND nvl(lg.complete_flag, 'Y') = 'Y'
   AND primdet.object_id = rs.primary_ledger_id
   AND primdet.object_type_code = 'PRIMARY'
   AND primdet.setup_step_code = 'NONE'
   AND cfg.configuration_id = primdet.configuration_id
   AND cfgdet.configuration_id(+) = cfg.configuration_id
   AND cfgdet.object_type_code(+) = 'LEGAL_ENTITY'
   AND le.legal_entity_id(+) = cfgdet.object_id
   AND reg.source_id(+) = cfgdet.object_id
   AND reg.source_table(+) = 'XLE_ENTITY_PROFILES'
   AND reg.identifying_flag(+) = 'Y'
   AND hrloctl.location_id(+) = reg.location_id
   AND hrloctl.language(+) = userenv('LANG');

SELECT lg.ledger_id, --分类帐 
       cfgdet.object_id legal_entity_id, --法人实体     
       lg.currency_code,
       lg.chart_of_accounts_id,
       rs.primary_ledger_id
  FROM gl_ledger_config_details primdet,
       gl_ledgers               lg,
       gl_ledger_relationships  rs,
       gl_ledger_configurations cfg,
       gl_ledger_config_details cfgdet
 WHERE 1 = 1
   AND rs.application_id = 101 --101为总账GL应用 
   AND ((rs.target_ledger_category_code = 'SECONDARY' AND
       rs.relationship_type_code <> 'NONE') OR
       (rs.target_ledger_category_code = 'PRIMARY' AND
       rs.relationship_type_code = 'NONE') OR
       (rs.target_ledger_category_code = 'ALC' AND
       rs.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')))
   AND lg.ledger_id = rs.target_ledger_id
   AND lg.ledger_category_code = rs.target_ledger_category_code
   AND nvl(lg.complete_flag, 'Y') = 'Y'
   AND primdet.object_id = rs.primary_ledger_id
   AND primdet.object_type_code = 'PRIMARY'
   AND primdet.setup_step_code = 'NONE'
   AND cfg.configuration_id = primdet.configuration_id
   AND cfgdet.configuration_id(+) = cfg.configuration_id
   AND cfgdet.object_type_code(+) = 'LEGAL_ENTITY';
