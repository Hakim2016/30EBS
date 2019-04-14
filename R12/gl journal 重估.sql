SELECT gcc.segment2, gcc.*
  FROM gl_balances ba, gl_code_combinations gcc
 WHERE 1 = 1
   AND ba.ledger_id = 2021
   AND ba.period_name = '2018-08'
   AND ba.code_combination_id = gcc.code_combination_id
   AND gcc.segment3 = '1605020101';

--gl journals with journal line
SELECT --gjh.name journal,
 gjh.default_effective_date 时间,
 --gjh.org_id,
 gjh.ledger_id,
 (SELECT fu.user_name || pap.FULL_NAME
    FROM apps.fnd_user fu,
    APPS.PER_ALL_PEOPLE_F PAP
   WHERE 1 = 1
   AND FU.EMPLOYEE_ID = PAP.PERSON_ID
     AND fu.user_id = gjh.created_by) 用户,
 gjh.doc_sequence_value 单据编号,
 gjl.je_line_num 行号,
 gjh.description 说明,
 gjl.segment3 账户,
 gjh.currency_conversion_type 汇率类型,
 gjh.currency_conversion_rate 汇率值,
 gjh.currency_code 币种,
 nvl(1 / (decode(gjl.entered_dr, 0, 1, gjl.entered_dr) /
     decode(gjl.accounted_dr, 0, 1, gjl.accounted_dr)),
     1 / (decode(gjl.entered_cr, 0, 1, gjl.entered_cr) /
     decode(gjl.accounted_cr, 0, 1, gjl.accounted_cr))) rate,
 gjl.entered_dr,
 gjl.entered_cr,
 gjl.accounted_dr,
 gjl.accounted_cr/*,
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
 ORDER BY gjh.doc_sequence_value ASC, gjl.je_line_num;
