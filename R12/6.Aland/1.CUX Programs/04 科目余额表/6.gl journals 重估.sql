SELECT gjh.period_name period_name,
       gjh.je_category,
       gjh.je_source,
       gjh.doc_sequence_value ∆æ÷§±‡∫≈,
       gjh.CREATION_DATE,
       gjh.name,
       gjh.currency_conversion_type ex_typ,
       gjh.currency_conversion_rate ex_rate,/*
       NVL(gjl.ACCOUNTED_DR,gjl.ACCOUNTED_CR)
       /NVL(gjl.ENTERED_DR,gjl.entered_cr) º∆À„ª„¬ ,*/
       gjl.je_line_num,
       gjh.ledger_id,
       gcc.segment3,
       gjh.currency_code,
       gjl.entered_dr,
       gjl.entered_cr,
       gjl.accounted_dr,
       gjl.accounted_cr
  FROM apps.gl_je_headers        gjh,
       apps.gl_je_lines          gjl,
       apps.gl_code_combinations gcc
 WHERE gjh.je_header_id = gjl.je_header_id
   AND gjl.code_combination_id = gcc.code_combination_id
   AND gjh.ledger_id = 2021 --’À≤æ
   AND gjh.status = 'P'
   AND gjh.period_name <= '2018-11'
   AND gcc.segment3 IN (
'1001030101',
'1002020501',
'1002020502',
'1002020602',
'1012040101',
'1407030101',
'2001020102',
'2001020103',
'6603020101',
'6603020101',
'6603020101'
   )
 ORDER BY gcc.segment3,
          gjh.period_name,
          gjh.doc_sequence_value,
          gjl.je_line_num;
