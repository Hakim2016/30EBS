SELECT 
gjh.DEFAULT_EFFECTIVE_DATE,
gcc.segment1 "��˾",
gcc.segment2 Depart,
gjh.doc_sequence_value "ƾ֤��", --ƾ֤��
       gjl.je_line_num,
       gjl.description /*journal_desc*/ "��ժҪ", --ժҪ
       nvl(gjl.accounted_dr,
           0) /*accounted_dr*/ "�跽����", --�跽����
       nvl(gjl.accounted_cr,
           0) /*accounted_cr*/ "��������", --��������
       gjl.attribute4,
       (SELECT ppf.EMPLOYEE_NUMBER--ppf.last_name
          FROM apps.per_people_f ppf
         WHERE ppf.person_id = gjl.attribute4) "Ա�����",
       (SELECT ppf.FULL_NAME--ppf.last_name
          FROM apps.per_people_f ppf
         WHERE ppf.person_id = gjl.attribute4) "Ա��",
       gjl.attribute5,
       (SELECT sup.SEGMENT1
          FROM apps.ap_suppliers sup
         WHERE sup.vendor_id = gjl.attribute5) "Ա����Ӧ�̱��",
       (SELECT sup.vendor_name
          FROM apps.ap_suppliers sup
         WHERE sup.vendor_id = gjl.attribute5) "Ա����Ӧ��"/*vendor_name*/
         ,
         --Ա����Ӧ�̶�Ӧ��Ա��id person id
         
       (SELECT ppf.PERSON_ID--sup.SEGMENT1
          FROM apps.ap_suppliers sup,
          apps.per_people_f ppf
         WHERE sup.vendor_id = gjl.attribute5
         AND 'EMP'||ppf.EMPLOYEE_NUMBER = sup.SEGMENT1) "Ա����Ӧ�̶�ӦԱ��id"
         
  FROM apps.gl_je_headers        gjh,
       apps.gl_je_lines          gjl,
       apps.gl_code_combinations gcc
 WHERE gjh.je_header_id = gjl.je_header_id
   AND gjl.code_combination_id = gcc.code_combination_id
   AND gcc.segment3 = '1221010101' -- ����Ӧ�տ�-����
   AND gjh.status = 'P' --�ѹ���
   AND gcc.segment1 = '101'
   AND 1 = 1
   --AND gjh.doc_sequence_value = '190101068'
   ORDER BY gjh.doc_sequence_value ;
