
SELECT 
gjh.period_name,
gjh.je_category,
gjh.doc_sequence_value,
gjh.name,
gcc.segment3,
--length(gjl.description),
--gjh.*,
gjl.*
--SUM(gjl.accounted_dr)-sum(gjl.accounted_cr)
  FROM apps.gl_je_headers_v gjh, apps.gl_je_lines_v gjl,
  gl_code_combinations gcc
 WHERE 1 = 1
 AND gjh.ledger_id =2021
   --AND gjh.currency_code <> 'CNY'
   --AND gjh.currency_conversion_rate = 1
      --AND gjh.currency_conversion_rate
      --AND gjh.currency_conversion_type
   AND gjh.je_header_id = gjl.je_header_id
   --AND gjl.description LIKE '10月招待面膜费用%'
   AND gjh.je_category LIKE 'Revaluation%'
   AND gjl.code_combination_id = gcc.CODE_COMBINATION_ID
   /*AND gcc.SEGMENT3 IN (
   --'1221010101','',''
   --'2241010101'
   --'2241020101'
   --'2241030101'
   --'6001010101'
   --'6301020101'
   '1604010101',
'1604020101',
'1604030101',
'1604040101',
'1604050101',
'1604060101',
'1604070101'
   )
   AND gjh.default_effective_date >= to_date('2018-08-01','yyyy-mm-dd')
   AND gjh.default_effective_date <= to_date('2018-08-31','yyyy-mm-dd') + 0.99999*/
   --AND gjh.default_effective_date >= to_date('2018-09-01','yyyy-mm-dd')
   --AND gjh.default_effective_date <= to_date('2018-09-30','yyyy-mm-dd') + 0.99999
   --AND gjh.posting_acct_seq_value = '101318110311'--'101318110292'
   --AND gjl.description IS NOT NULL
--ORDER BY length(gjl.description) DESC
