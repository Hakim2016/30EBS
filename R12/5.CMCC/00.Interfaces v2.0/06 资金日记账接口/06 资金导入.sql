--06 �ʽ��ռ��˵���ӿڱ�
SELECT itf.pri_key,
       hou.name,
       itf.last_update_date,
       itf.process_status_lookup_code ����״̬,
       itf.process_message            ������Ϣ,
       itf.amount,
       itf.bank_statement,
       itf.*
  FROM apps.hr_operating_units       hou,
       apps.cux_gl_ws_capital_je_itf itf
 WHERE itf.affiliation = hou.short_code
   /*AND itf.creation_date BETWEEN
       to_date('2018-10-30 18:00:00', 'YYYY-MM-DD HH24:MI:SS') AND
       to_date('2018-10-31 12:00:00', 'YYYY-MM-DD HH24:MI:SS') -- ����
      --AND itf.creation_date BETWEEN
      --    to_date('2018-10-31 12:00:00', 'YYYY-MM-DD HH24:MI:SS') AND to_date('2018-10-31 18:00:00', 'YYYY-MM-DD HH24:MI:SS') -- ҹ��
   AND itf.process_status_lookup_code = 'ERROR'
   AND hou.name LIKE '%ZJ%'*/
   and itf.bank_statement
   in(
--
--���Ҵ���
--�����ѽ����
SELECT /*itf.pri_key, */itf.bank_statement
  FROM apps.hr_operating_units       hou,
       apps.cux_gl_ws_capital_je_itf itf
 WHERE 1 = 1
   AND itf.affiliation = hou.short_code
   AND itf.process_status_lookup_code = 'ERROR'
   AND hou.name LIKE '%ZJ%'
   and not exists
   (
   select 1 from 
       apps.cux_gl_ws_capital_je_itf itf2
       where 1=1
       --and itf2.pri_key = itf.pri_key
       and itf2.bank_statement = itf.bank_statement
       and itf2.process_status_lookup_code <> 'ERROR'
   )
)
