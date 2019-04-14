--SR for ACC 1605020101
--6. Please execute the following scripts and upload the data in Excel: 

--6.1 
SELECT kfv.concatenated_segments,
       gjh.je_category,
       gjh.je_source,
       gjh.currency_code,
       gjl.*
  FROM gl_je_lines gjl, gl_je_headers gjh, gl_code_combinations_kfv kfv
 WHERE gjl.code_combination_id = kfv.code_combination_id
   AND gjl.code_combination_id IN
       (SELECT code_combination_id
          FROM gl_code_combinations
         WHERE chart_of_accounts_id = 50388--'&chart_of_account'
           --AND segment1 = '&segment1'--101
           --AND segment2 = '&segment2'
           AND segment3 = '1605020101'--'&segment3'
           --AND segment4 = '&segment4'
           --AND segment5 = '&segment5'
           --AND segment6 = '&segment6'
           )
   AND gjl. effective_date BETWEEN to_date('01-08-18', 'dd-mm-yy') AND
       to_date('31-08-18 ', 'dd-mm-yy')
   AND gjl.ledger_id = 2021--'&ledger_id'
   AND gjh.je_header_id = gjl.je_header_id;

--6.2 
SELECT kfv.concatenated_segments, kfv.gl_account_type, bl.*
  FROM gl_code_combinations_kfv kfv, gl_balances bl
 WHERE kfv.code_combination_id = bl.code_combination_id
   AND bl.code_combination_id IN
       (SELECT code_combination_id
          FROM gl_code_combinations
         WHERE chart_of_accounts_id = 50388--'&chart_of_account'
           --AND segment1 = '&segment1'
           --AND segment2 = '&segment2'
           AND segment3 = '1605020101'--'&segment3'
           --AND segment4 = '&segment4'
           --AND segment5 = '&segment5'
           --AND segment6 = '&segment6'
           )
   AND bl.period_name = '2018-08'--'&period_name'
   AND bl.ledger_id = 2021--'&ledger_id'
   AND bl.actual_flag = 'A'
   AND bl.template_id IS NULL;

SELECT * from gl_sets_of_books where 1=1 ;
