SELECT gjh.ledger_id,
       gjh.period_name        期间,
       gjh.doc_sequence_value 票据编号,
       gjh.je_source,
       --gjh.je_category,
       gjl.je_line_num 行号,
       gjl.description 摘要,
       
       gcc.segment3 会计科目,
       gjh.currency_code 币种,
       gjl.accounted_dr 本币借,
       gjl.accounted_cr 本币贷,
       gjl.attribute5 供应商id,
       (SELECT aps.segment1
          FROM apps.ap_suppliers aps
         WHERE 1 = 1
           AND aps.vendor_id = gjl.attribute5) 供应商编号,
       (SELECT aps.vendor_name
          FROM apps.ap_suppliers aps
         WHERE 1 = 1
           AND aps.vendor_id = gjl.attribute5) 供应商名称 /*,
       --gjh.*,
       gjl.**/
  FROM apps.gl_je_headers_v      gjh,
       apps.gl_je_lines_v        gjl,
       apps.gl_code_combinations gcc
 WHERE 1 = 1
   AND gjh.ledger_id = 2021
      --AND gjl.ATTRIBUTE2 IS NOT NULL
      --AND gjl.ATTRIBUTE4 IS NOT NULL
      --AND gjl.ATTRIBUTE5 IS NOT NULL
      --AND gjh.je_source IN ('Spreadsheet', 'Manual')
      --AND gjh.je_category
      --AND gjh.currency_code = 'USD'
      --AND gjh.currency_conversion_rate = 1
      --AND gjh.currency_conversion_rate
      --AND gjh.currency_conversion_type
   AND gjh.je_header_id = gjl.je_header_id
   AND gjl.code_combination_id = gcc.code_combination_id
      --AND gcc.segment2 <> '0'
      --AND gcc.segment7 <> '0'
      AND gjh.created_by = 1179
      AND gcc.segment3 LIKE '1002%'/*IN (
      --'2241020101'
         --'1604040101'
      \*'1604070101',
      '1604010101',
      '1604030101',
      '1604020101',
      '1604050101',
      '1604060101'*\
      )*/
      --AND gjh.default_effective_date >= to_date('2018-08-01','yyyy-mm-dd')
      --AND gjh.default_effective_date <= to_date('2018-08-31','yyyy-mm-dd') + 0.99999
   /*AND gjh.default_effective_date >= to_date('2018-09-01', 'yyyy-mm-dd')
   AND gjh.default_effective_date <=
       to_date('2018-09-30', 'yyyy-mm-dd') + 0.99999*/
--AND gjh.posting_acct_seq_value = '101318110311'--'101318110292'
/*AND EXISTS

(SELECT 1
          FROM apps.ap_suppliers aps
         WHERE 1 = 1
           AND aps.vendor_id = gjl.attribute5
           AND aps.VENDOR_NAME = '国网江苏省电力有限公司靖江市供电分公司')*/
 ORDER BY gjh.doc_sequence_value;

SELECT DISTINCT
gjh.je_source,
t.USER_JE_SOURCE_NAME,
--t.JE_SOURCE_NAME,
gjh.je_category,
t2.JE_CATEGORY_NAME,
t2.USER_JE_CATEGORY_NAME
/*gjh.ledger_id,
       gjh.period_name 期间,
       gjh.doc_sequence_value 凭证编号,
       gjh.posting_acct_seq_value 过账凭证,
       gjh.**/
  FROM apps.gl_je_headers_v gjh,
  apps.gl_je_sources_tl t,
  apps.gl_je_categories_tl t2
 WHERE 1 = 1
 AND t.language = 'ZHS'
 AND t2.language = 'ZHS'
 AND gjh.je_source = t.je_source_key
 AND gjh.je_category = t2.JE_CATEGORY_KEY
   /*AND gjh.default_effective_date >= to_date('2018-09-01', 'yyyy-mm-dd')
   AND gjh.default_effective_date <=
       to_date('2018-09-30', 'yyyy-mm-dd') + 0.99999*/
   AND gjh.ledger_id = 2021
 --ORDER BY gjh.doc_sequence_value ASC
 ORDER BY gjh.je_source asc
 ;

SELECT * from apps.gl_je_categories_tl t2 where 1=1 
AND t2.language = 'ZHS';
