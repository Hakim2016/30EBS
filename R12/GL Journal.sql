SELECT gcc.segment2, gcc.*
  FROM gl_balances ba, gl_code_combinations gcc
 WHERE 1 = 1
   AND ba.ledger_id = 2021
   AND ba.period_name = '2018-08'
   AND ba.code_combination_id = gcc.code_combination_id
   AND gcc.segment3 = '1605020101';

--gl journals with journal line
SELECT --gjh.name journal,
 gjh.default_effective_date ʱ��,
 gjh.period_name,
 --gjh.org_id,
 gjh.ledger_id,
 (SELECT fu.user_name || pap.full_name
    FROM apps.fnd_user fu, apps.per_all_people_f pap
   WHERE 1 = 1
     AND fu.employee_id = pap.person_id
     AND fu.user_id = gjh.created_by) �û�,
 gjh.doc_sequence_value ���ݱ��,
 gjl.je_line_num �к�,
 gjh.description ˵��,
 gjl.segment3 �˻�,
 gjh.currency_conversion_type ��������,
 gjh.currency_conversion_rate ����ֵ,
 gjh.currency_code ����,
 nvl(1 / (decode(gjl.entered_dr, 0, 1, gjl.entered_dr) /
     decode(gjl.accounted_dr, 0, 1, gjl.accounted_dr)),
     1 / (decode(gjl.entered_cr, 0, 1, gjl.entered_cr) /
     decode(gjl.accounted_cr, 0, 1, gjl.accounted_cr))) rate,
 gjl.entered_dr,
 gjl.entered_cr,
 gjl.accounted_dr,
 gjl.accounted_cr /*,
 1 / (decode(gjl.entered_dr, 0, 1, gjl.entered_dr) /
 decode(gjl.accounted_dr, 0, 1, gjl.accounted_dr)) rate1,
 1 / (decode(gjl.entered_cr, 0, 1, gjl.entered_cr) /
 decode(gjl.accounted_cr, 0, 1, gjl.accounted_cr)) rate2,
 --gjh.description,
 gjl.entered_dr,
 gjl.entered_cr,
 gjl.accounted_dr,
 gjl.accounted_cr,
 gjl.segment1,
 gjl.segment2,
 gjl.segment3,
 gjl.segment4,
 gjh.**/
--SUM(gjl.accounted_dr)-sum(gjl.accounted_cr)
  FROM apps.gl_je_headers_v gjh, apps.gl_je_lines_v gjl
 WHERE 1 = 1
   AND gjh.currency_code = 'USD'
      --AND gjh.currency_conversion_rate = 1
      --AND gjh.currency_conversion_rate
      --AND gjh.currency_conversion_type
   AND gjh.je_header_id = gjl.je_header_id
   AND gjh.ledger_id = 2021
      --AND gjl.segment3 /*LIKE '1192101%'*/--= '1605020101'
      --AND gjh.period_name = '2018-09'
      --AND gjl.segment3
      --AND gjh.description LIKE '%SG00050348*7%'--'%HS00101380HKM%'--
   AND (nvl(1 / (decode(gjl.entered_dr, 0, 1, gjl.entered_dr) /
            decode(gjl.accounted_dr, 0, 1, gjl.accounted_dr)),
            1 / (decode(gjl.entered_cr, 0, 1, gjl.entered_cr) /
            decode(gjl.accounted_cr, 0, 1, gjl.accounted_cr))) >= 7 OR
       nvl(1 / (decode(gjl.entered_dr, 0, 1, gjl.entered_dr) /
            decode(gjl.accounted_dr, 0, 1, gjl.accounted_dr)),
            1 / (decode(gjl.entered_cr, 0, 1, gjl.entered_cr) /
            decode(gjl.accounted_cr, 0, 1, gjl.accounted_cr))) <= 6)
      --AND gjl.segment3 <> '6603020101'
      /*AND ((gjl.entered_dr + gjl.accounted_dr <> 0) OR 
      
      )*/
   AND gjh.description LIKE '%����%'
 ORDER BY gjh.doc_sequence_value ASC, gjl.je_line_num;

SELECT gjh.doc_sequence_value,
       gcc.segment3,
       length(gjl.description),
       --gjh.*,
       gjl.*
--SUM(gjl.accounted_dr)-sum(gjl.accounted_cr)
  FROM apps.gl_je_headers_v gjh,
       apps.gl_je_lines_v   gjl,
       gl_code_combinations gcc
 WHERE 1 = 1
   AND gjh.ledger_id = 2021
   AND gjh.currency_code <> 'CNY'
      --AND gjh.currency_conversion_rate = 1
      --AND gjh.currency_conversion_rate
      --AND gjh.currency_conversion_type
   AND gjh.je_header_id = gjl.je_header_id
      --AND gjl.description LIKE '10���д���Ĥ����%'
   AND gjl.code_combination_id = gcc.code_combination_id
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
;

--�ռ�����Դ
SELECT /*DISTINCT*/
 gjh.period_name,
 gjh.je_source,
 gjh.je_category, --1 �ֹ�ƾ֤
 gjh.doc_sequence_value ƾ֤���,
 gjh.name,
 gjh.*
  FROM apps.gl_je_headers_v gjh
 WHERE 1 = 1
   AND gjh.ledger_id = 2021
   AND gjh.je_source IN ( /*'Payables'*/ 'Receivables')
   AND gjh.period_name <> '2018-08'
   ORDER BY gjh.period_name;

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id IN (200, 222);
