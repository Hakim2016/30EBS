SELECT je_header_id,
       je_line_num,
       ae_header_id,
       accounting_date,
       doc_seq,
       source_id,
       entity_code,
       entered_dr,
       entered_cr,
       accounted_dr,
       accounted_cr,
       created_by
/*,cux_gl_common_pkg.drilldown_apar_info(1
,source_id
,entity_code) AS xlat*/
  FROM (SELECT gr.je_header_id,
               gr.je_line_num,
               ah.ae_header_id,
               ah.accounting_date,
               gjh.doc_sequence_value AS doc_seq,
               te.source_id_int_1 AS source_id,
               te.entity_code AS entity_code,
               SUM(al.entered_dr) AS entered_dr,
               SUM(al.entered_cr) AS entered_cr,
               SUM(al.accounted_dr) AS accounted_dr,
               SUM(al.accounted_cr) AS accounted_cr,
               MAX(al.created_by) AS created_by
          FROM gl_je_headers                gjh,
               gl_import_references         gr,
               xla.xla_ae_lines             al,
               xla.xla_ae_headers           ah,
               xla.xla_transaction_entities te
         WHERE te.entity_id = ah.entity_id
           AND te.application_id = ah.application_id
           AND ah.ae_header_id = al.ae_header_id
           AND ah.application_id = al.application_id
           AND al.application_id IN (707) --(200, 222)
           AND gr.gl_sl_link_table = al.gl_sl_link_table
           AND gr.gl_sl_link_id = al.gl_sl_link_id
           AND gr.je_header_id = gjh.je_header_id
           AND te.transaction_number = 48624778 --'DP-18000143'
         GROUP BY ah.ae_header_id,
                  gr.je_header_id,
                  gr.je_line_num,
                  ah.accounting_date,
                  gjh.doc_sequence_value,
                  te.source_id_int_1,
                  te.entity_code);
--gl journals with module info
SELECT te.transaction_number,
       gjh.name               h_name,
       gjb.name               b_name,
       gr.je_header_id,
       gr.je_line_num,
       ah.ae_header_id,
       ah.accounting_date,
       gjh.doc_sequence_value AS doc_seq,
       --te.entity_id,
       te.source_id_int_1     AS source_id,
       te.entity_code         AS entity_code,
       
       al.entered_dr,
       al.entered_cr,
       al.accounted_dr,
       al.accounted_cr
/*SUM(al.entered_dr) AS entered_dr,
SUM(al.entered_cr) AS entered_cr,
SUM(al.accounted_dr) AS accounted_dr,
SUM(al.accounted_cr) AS accounted_cr,
MAX(al.created_by) AS created_by*/
  FROM gl_je_headers                gjh,
       gl_je_batches                gjb,
       gl_import_references         gr,
       xla.xla_ae_lines             al,
       xla.xla_ae_headers           ah,
       xla.xla_transaction_entities te
 WHERE te.entity_id = ah.entity_id
   AND te.application_id = ah.application_id
   AND ah.ae_header_id = al.ae_header_id
   AND ah.application_id = al.application_id
      --AND al.application_id IN (707) --( /*200,*/ 222)
   AND gr.gl_sl_link_table = al.gl_sl_link_table
   AND gr.gl_sl_link_id = al.gl_sl_link_id
   AND gr.je_header_id = gjh.je_header_id
   AND gjh.je_batch_id = gjb.je_batch_id
   AND te.ledger_id = 2021
   AND ah.period_name = '2018-08'
      --AND te.transaction_number = '48624778'--'HKM18112803'--'DP-18000143'
      --AND te.source_id_int_1 = 5235833--69864747 --48624778
      --AND gjh.je_header_id = 3115225
      --AND ah.accounting_date = to_date('2018-04-24','YYYY-MM-DD')
      --AND te.entity_code = 'TRANSACTIONS'
      --AND al.entered_dr = 5068
   AND EXISTS (SELECT 1
          FROM gl_code_combinations gcc
         WHERE 1 = 1
           AND gcc.code_combination_id = al.code_combination_id
           --AND gcc.segment1 = 'FB00'
           AND gcc.segment3 = '1605020101'--'1145400000' --'5120010011'--'1145400000'--'5120010011'
        )
/*GROUP BY gjh.name,ah.ae_header_id,
gr.je_header_id,
gr.je_line_num,
ah.accounting_date,
gjh.doc_sequence_value,
te.source_id_int_1,
te.entity_code*/
 ORDER BY te.source_id_int_1,
          gr.je_line_num;
          
--gl journal only GL module
SELECT gjh.name journal,
       gjh.description,
       gjl.accounted_dr,
       gjl.accounted_cr,
       gjl.segment1,
       gjl.segment2,
       gjl.segment3,
       gjl.segment4,
       gjh.*
       --SUM(gjl.accounted_dr)-sum(gjl.accounted_cr)
  FROM gl_je_headers_v gjh, gl_je_lines_v gjl
 WHERE 1 = 1
   AND gjh.je_header_id = gjl.je_header_id
   AND gjl.segment3 = '1605020101'
   AND gjh.period_name = '2018-08'
--AND gjl.segment3
--AND gjh.description LIKE '%SG00050348*7%'--'%HS00101380HKM%'--
;
