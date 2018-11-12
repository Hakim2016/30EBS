--lookups
SELECT userenv('LANG'),
       f.*
  FROM fnd_lookup_values f
 WHERE f.lookup_type = 'XXPA_EXPENDITURE_TYPE_TRANSFER' --'IEA_TRANSACTION_STATUS'
   --AND f.language = 'US';
and userenv('LANG') != f.language;

--value sets
SELECT 
vs.flex_value_set_id,
vs.flex_value_set_name,
vs.validation_type,
tb.id_column_name,
tb.meaning_column_name,
decode(tb.value_column_name,  
                  tb.id_column_name,  
                  'NULL',  
                  tb.value_column_name) value_column_name,
                  tb.application_table_name,
                  tb.additional_where_clause  
FROM  FND_FLEX_VALUE_SETS vs,
FND_FLEX_VALIDATION_TABLES tb
WHERE 1=1
AND vs.flex_value_set_id = tb.flex_value_set_id
AND vs.flex_value_set_name IN ('XXPA_EXPENDITURE_TYPE_TRANSFER', 'XXPA_FG_COMPLETION_STATUS', 'XXPA_EXPENDITURE_TYPE_COGS');

--gl_lookups

select fv.FLEX_VALUE
  from fnd_flex_values_vl         fv,
       fnd_flex_values_tl         ft,
       fnd_flex_value_rule_usages fru,
       fnd_flex_value_rule_lines  frl
 where fv.flex_value_set_id = 1009604
   and fv.FLEX_VALUE_id = ft.flex_value_id
   and language = 'ZHS'
   and fv.FLEX_VALUE_SET_ID = frl.flex_value_set_id
   and fv.FLEX_VALUE_SET_ID = fru.flex_value_set_id
   and fru.flex_value_rule_id = frl.flex_value_rule_id
   and fv.FLEX_VALUE >= frl.flex_value_low
   and fv.FLEX_VALUE <= frl.flex_value_high
   and fru.responsibility_id = $ :profiles$.resp_id

select * from fnd_flex_value_rules
select * from fnd_flex_value_rules_tl
select * from fnd_flex_value_rule_lines
select * from fnd_flex_value_rule_usages fru

select fv.FLEX_VALUE from fnd_flex_values_vl fv,fnd_flex_values_tl ft,fnd_flex_value_rule_usages fru,fnd_flex_value_rule_lines frl where fv.flex_value_set_id = 1009604 and fv.FLEX_VALUE_id = ft.flex_value_id and language = 'ZHS' and fv.FLEX_VALUE_SET_ID = frl.flex_value_set_id and fv.FLEX_VALUE_SET_ID = fru.flex_value_set_id and fru.flex_value_rule_id = frl.flex_value_rule_id and fv.FLEX_VALUE >= frl.flex_value_low and fv.FLEX_VALUE <= frl.flex_value_high and fru.responsibility_id = $:profiles$.resp_id

--由安全性取值，注意值集需选安全性
SELECT FV.FLEX_VALUE
  FROM FND_FLEX_VALUES_VL         FV,
       FND_FLEX_VALUES_TL         FT,
       FND_FLEX_VALUE_RULE_USAGES FRU,
       FND_FLEX_VALUE_RULE_LINES  FRL,
       FND_FLEX_VALUE_SETS        FFVS
 WHERE FV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
   AND FFVS.FLEX_VALUE_SET_NAME = 'CHINALIFERE_COMPANY'
   AND FV.FLEX_VALUE_ID = FT.FLEX_VALUE_ID
   AND FV.FLEX_VALUE_SET_ID = FRL.FLEX_VALUE_SET_ID
   AND FV.FLEX_VALUE_SET_ID = FRU.FLEX_VALUE_SET_ID
   AND FRU.FLEX_VALUE_RULE_ID = FRL.FLEX_VALUE_RULE_ID
   AND FV.FLEX_VALUE >= FRL.FLEX_VALUE_LOW
   AND FV.FLEX_VALUE <= FRL.FLEX_VALUE_HIGH
   AND FRU.RESPONSIBILITY_ID = :$PROFILES$.RESP_ID
   AND FT.LANGUAGE = USERENV('lang')
 ORDER BY FV.FLEX_VALUE

select * from financials_system_parameters

begin
fnd_client_info.set_org_context(121);
end;
