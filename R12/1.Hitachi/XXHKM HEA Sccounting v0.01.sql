--20180804

--Conbine to one
SELECT t.seq,
       t.je_cate,
       (SELECT jc.user_je_category_name
          FROM gl_je_categories jc
         WHERE 1 = 1
           AND jc.je_category_name = t.je_cate --LIKE '%COGS%'
        --AND jc.user_je_category_name LIKE '%COGS%'
        ) u_je_cate,
       t.event_id,
       t.entity_id,
       t.event_class,
       t.event_type,
       t.entity_code,
       --t.source_id_int_1 src_id,
       --t.ledger_id,
       --xah.description,
       --xal.description,
       t.source_id_int_1 src_id,
       (SELECT jc.user_je_category_name
          FROM gl_je_categories jc
         WHERE 1 = 1
           AND jc.je_category_name = t.je_cate --LIKE '%COGS%'
        --AND jc.user_je_category_name LIKE '%COGS%'
        ) u_je_cate,
       (SELECT meaning
          FROM xla_lookups xlk
         WHERE 1 = 1
           AND xlk.lookup_code = t.acct_class --'WIP_VALUATION'--xal.accounting_class_code
           AND xlk.lookup_type = 'XLA_ACCOUNTING_CLASS') accouting_class,
       --t.acct_class,
       t.flag,
       substr(t.concatenated_segments,
              instr(t.concatenated_segments, '.', 1, 2) + 1,
              instr(t.concatenated_segments, '.', 1, 3) - instr(t.concatenated_segments, '.', 1, 2) - 1) acc,
       substr(t.account_desc,
              instr(t.account_desc, '.', 1, 2) + 1,
              instr(t.account_desc, '.', 1, 3) - instr(t.account_desc, '.', 1, 2) - 1) acc,
       substr(t.concatenated_segments,
              instr(t.concatenated_segments, '.', 1, 3) + 1,
              instr(t.concatenated_segments, '.', 1, 4) - instr(t.concatenated_segments, '.', 1, 3) - 1) subacc,
       substr(t.account_desc,
              instr(t.account_desc, '.', 1, 3) + 1,
              instr(t.account_desc, '.', 1, 4) - instr(t.account_desc, '.', 1, 3) - 1) subacc,
       substr(t.concatenated_segments,
              instr(t.concatenated_segments, '.', 1, 4) + 1,
              instr(t.concatenated_segments, '.', 1, 5) - instr(t.concatenated_segments, '.', 1, 4) - 1) seg3,
       substr(t.account_desc,
              instr(t.account_desc, '.', 1, 4) + 1,
              instr(t.account_desc, '.', 1, 5) - instr(t.account_desc, '.', 1, 4) - 1) seg3,
       --t.concatenated_segments,
       --t.account_desc,
       t.dr                    dr,
       t.cr                    cr,
       t.acct_rule,
       t.ae_line_num,
       t.ledger_id,
       t.concatenated_segments,
       t.account_desc
  FROM (
        ----10.CUX FG Completion(PA Expenditure)
        SELECT 10                    seq, --xdl.source_distribution_type,
                xah.je_category_name  je_cate, --Subledger Journal Entry
                xe.event_id,
                xect.name             event_class,
                xet.name              event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
                xte.transaction_number,
                xah.accounting_date,
                xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275 --PA
           AND xte.source_id_int_1 --= 15315881--15316832 --pa expenditure items
              --IN (15315881, 15316880, 15317881)
               IN (15318880)
           AND xte.entity_code = 'EXPENDITURES'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
           AND xdl.source_distribution_type = 'R' --pa_expenditure_items_all
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
        
        UNION ALL
        
        ----11.CUX EQ COGS
        SELECT 11                    seq, --xdl.source_distribution_type,
                xah.je_category_name  je_cate, --Subledger Journal Entry
                xah.description,
                xe.event_id,
                xect.name             event_class,
                xet.name              event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
                xte.transaction_number,
                xah.accounting_date,
                xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275 --PA
              --AND xte.source_id_int_1 = 15316832 --pa expenditure items
           AND xte.transaction_number = 'C1808050001' --'C15317881'
           AND xte.entity_code = 'MANUAL' --'EXPENDITURES'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
           AND xdl.source_distribution_type = 'XLA_MANUAL' --'R' --pa_expenditure_items_all
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
        UNION ALL
        
        ----12.CUX EQ Revenue
        SELECT 12                    seq, --xdl.source_distribution_type,
                xah.je_category_name  je_cate, --Subledger Journal Entry
                xe.event_id,
                xect.name             event_class,
                xet.name              event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
                xte.transaction_number,
                xah.accounting_date,
                xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275 --PA
              --AND xte.source_id_int_1 = 15316832 --pa expenditure items
           AND xte.transaction_number = 'D1808040001' --'C1808050001'--'C15317881'
           AND xte.entity_code = 'MANUAL' --'EXPENDITURES'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
           AND xdl.source_distribution_type = 'XLA_MANUAL' --'R' --pa_expenditure_items_all
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
        UNION ALL
        
        ----13.CUX ER COGS
        SELECT 13                    seq, --xdl.source_distribution_type,
                xah.je_category_name  je_cate, --Subledger Journal Entry
                xe.event_id,
                xect.name             event_class,
                xet.name              event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
                xte.transaction_number,
                xah.accounting_date,
                xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275 --PA
              AND xte.source_id_int_1 = 15319080--15316832 --pa expenditure items
           --AND xte.transaction_number = 'D1808040001' --'C1808050001'--'C15317881'
           AND xte.entity_code = 'EXPENDITURES'--'MANUAL' --'EXPENDITURES'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
           AND xdl.source_distribution_type = 'R'--'R' --pa_expenditure_items_all
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
           UNION ALL
           
        ----14.CUX ER Revenue
        SELECT 14                    seq, --xdl.source_distribution_type,
                xah.je_category_name  je_cate, --Subledger Journal Entry
                xah.description,
                xe.event_id,
                xect.name             event_class,
                xet.name              event_type,
                xah.product_rule_code acct_rule,
                xte.source_id_int_1,
                xah.ledger_id,
                --xah.description,
                --xal.description,
                xal.accounting_class_code acct_class,
                decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
                gcc.concatenated_segments,
                xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                xal.accounted_dr dr,
                xal.accounted_cr cr,
                xal.ae_line_num,
                xte.entity_code,
                xte.entity_id,
                xte.transaction_number,
                xah.accounting_date,
                xdl.source_distribution_type
          FROM xla.xla_transaction_entities xte,
                xla_events                   xe,
                xla_ae_headers               xah,
                xla_ae_lines                 xal,
                xla_distribution_links       xdl, --improve efficient
                gl_code_combinations_kfv     gcc,
                --event class/event type
                xla_event_classes_tl xect,
                xla_event_types_tl   xet
        
         WHERE 1 = 1
           AND xah.ae_header_id = xal.ae_header_id
           AND gcc.code_combination_id = xal.code_combination_id
           AND xe.entity_id = xte.entity_id
           AND xe.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.application_id = 275 --PA
              --AND xte.source_id_int_1 = 15319080--15316832 --pa expenditure items
           --AND xte.transaction_number = 'D1808040001' --'C1808050001'--'C15317881'
           AND xte.entity_code = 'MANUAL'--'EXPENDITURES'--'MANUAL' --'EXPENDITURES'
              --improve efficient
           AND xah.ae_header_id = xdl.ae_header_id
           AND xal.ae_line_num = xdl.ae_line_num
           AND xdl.application_id = xte.application_id
              ----
           AND xdl.source_distribution_type = 'XLA_MANUAL'--'R'--'R' --pa_expenditure_items_all
              --event class/ event type
           AND xet.language = userenv('LANG')
           AND xect.application_id = xe.application_id --707
           AND xet.application_id = xe.application_id --707
           AND xect.entity_code = xet.entity_code
           AND xet.entity_code = xte.entity_code
           AND xect.event_class_code = xet.event_class_code
           AND xect.language = userenv('LANG')
           AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'
        
        ) t
 ORDER BY t.seq,
          t.event_id,
          t.flag DESC,
          t.ae_line_num;
/*
SHE 2023 50352
HBS 2041 50370
HEA 2021 50351
HET 2061 50390
*/

SELECT *
  FROM gl_sets_of_books xx
 WHERE 1 = 1;

----11.CUX EQ COGS
SELECT 11                    seq, --xdl.source_distribution_type,
       xah.je_category_name  je_cate, --Subledger Journal Entry
       xe.event_id,
       xect.name             event_class,
       xet.name              event_type,
       xah.product_rule_code acct_rule,
       xte.source_id_int_1,
       xah.ledger_id,
       --xah.description,
       --xal.description,
       xal.accounting_class_code acct_class,
       decode(xal.accounted_dr, NULL, 'CR', 'DR') flag,
       gcc.concatenated_segments,
       xla_oa_functions_pkg.get_ccid_description( /*xgl.chart_of_accounts_id*/ 50352, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
       xal.accounted_dr dr,
       xal.accounted_cr cr,
       xal.ae_line_num,
       xte.entity_code,
       xte.entity_id,
       xte.transaction_number,
       xah.accounting_date,
       xte.source_id_int_1,
       xdl.source_distribution_type
  FROM xla.xla_transaction_entities xte,
       xla_events                   xe,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla_distribution_links       xdl, --improve efficient
       gl_code_combinations_kfv     gcc,
       --event class/event type
       xla_event_classes_tl xect,
       xla_event_types_tl   xet

 WHERE 1 = 1
   AND xah.ae_header_id = xal.ae_header_id
   AND gcc.code_combination_id = xal.code_combination_id
   AND xe.entity_id = xte.entity_id
   AND xe.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xte.application_id = 275 --PA
      --AND xte.source_id_int_1 = 15316832 --pa expenditure items
   AND xte.transaction_number = 'C15317881'
   AND xte.entity_code = 'MANUAL' --'EXPENDITURES'
      --improve efficient
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xdl.application_id = xte.application_id
      ----
   AND xdl.source_distribution_type = 'XLA_MANUAL' --'R' --pa_expenditure_items_all
      --event class/ event type
   AND xet.language = userenv('LANG')
   AND xect.application_id = xe.application_id --707
   AND xet.application_id = xe.application_id --707
   AND xect.entity_code = xet.entity_code
   AND xet.entity_code = xte.entity_code
   AND xect.event_class_code = xet.event_class_code
   AND xect.language = userenv('LANG')
   AND xet.event_type_code = xe.event_type_code --'WIP_COMP_ISSUE'

--AND xah.ae_header_id = 24596702
;

SELECT *
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
      --AND xte.entity_code = 'EXPENDITURES'
   AND xte.application_id = 275
   AND xte.creation_date >= to_date('03-AUG-2018 17:00:23', 'dd-mon-yyyy hh24:mi:ss')
   AND xte.creation_date >= to_date('03-AUG-2018 19:20:54', 'dd-mon-yyyy hh24:mi:ss')
--AND xte.created_by = 4270
;
/*
--INSTR()   
SELECT instr('SHE.Default.Manufacturing Department .RES ABSORP FIELD COST_PRO.Default.Default.Default', '.', 1, 3)
  FROM dual;

\*
t.concatenated_segments
start:instr(t.concatenated_segments, '.',1,2)+1
end:(t.concatenated_segments, '.',1,3)-1
length of string:end-start

substr(t.concatenated_segments,instr(t.concatenated_segments, '.',1,2)+1,
instr(t.concatenated_segments, '.',1,3)-instr(t.concatenated_segments, '.',1,2)
) acc
*\
SELECT instr('GS00.0.1145500000.421103030.215110107.0.0', '.', 1, 2)
  FROM dual;
SELECT instr('GS00.0.1145500000.421103030.215110107.0.0', '.', 1, 3)
  FROM dual;
SELECT substr('GS00.0.1145500000.421103030.215110107.0.0', 8, 10)
  FROM dual;
*/
