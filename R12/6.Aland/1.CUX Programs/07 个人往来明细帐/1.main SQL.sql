SELECT 
gjh.DEFAULT_EFFECTIVE_DATE,
gcc.segment1 "公司",
gcc.segment2 Depart,
gjh.doc_sequence_value "凭证号", --凭证号
       gjl.je_line_num,
       gjl.description /*journal_desc*/ "行摘要", --摘要
       nvl(gjl.accounted_dr,
           0) /*accounted_dr*/ "借方本币", --借方本币
       nvl(gjl.accounted_cr,
           0) /*accounted_cr*/ "贷方本币", --贷方本币
       gjl.attribute4,
       (SELECT ppf.EMPLOYEE_NUMBER--ppf.last_name
          FROM apps.per_people_f ppf
         WHERE ppf.person_id = gjl.attribute4) "员工编号",
       (SELECT ppf.FULL_NAME--ppf.last_name
          FROM apps.per_people_f ppf
         WHERE ppf.person_id = gjl.attribute4) "员工",
       gjl.attribute5,
       (SELECT sup.SEGMENT1
          FROM apps.ap_suppliers sup
         WHERE sup.vendor_id = gjl.attribute5) "员工供应商编号",
       (SELECT sup.vendor_name
          FROM apps.ap_suppliers sup
         WHERE sup.vendor_id = gjl.attribute5) "员工供应商"/*vendor_name*/
         ,
         --员工供应商对应的员工id person id
         
       (SELECT ppf.PERSON_ID--sup.SEGMENT1
          FROM apps.ap_suppliers sup,
          apps.per_people_f ppf
         WHERE sup.vendor_id = gjl.attribute5
         AND 'EMP'||ppf.EMPLOYEE_NUMBER = sup.SEGMENT1) "员工供应商对应员工id"
         
  FROM apps.gl_je_headers        gjh,
       apps.gl_je_lines          gjl,
       apps.gl_code_combinations gcc
 WHERE gjh.je_header_id = gjl.je_header_id
   AND gjl.code_combination_id = gcc.code_combination_id
   AND gcc.segment3 = '1221010101' -- 其他应收款-个人
   AND gjh.status = 'P' --已过账
   AND gcc.segment1 = '101'
   AND 1 = 1
   --AND gjh.doc_sequence_value = '190101068'
   ORDER BY gjh.doc_sequence_value ;
