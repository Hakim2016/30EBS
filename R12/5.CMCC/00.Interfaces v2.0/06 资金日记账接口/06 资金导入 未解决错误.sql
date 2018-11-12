--06 资金日记账导入接口表
SELECT itf.pri_key,
       hou.name,
       itf.last_update_date,
       itf.process_status_lookup_code 处理状态,
       itf.process_message            处理信息,
       itf.amount,
       itf.bank_statement,
       itf.*
  FROM apps.hr_operating_units       hou,
       apps.cux_gl_ws_capital_je_itf itf
 WHERE itf.affiliation = hou.short_code
   /*AND itf.creation_date BETWEEN
       to_date('2018-10-30 18:00:00', 'YYYY-MM-DD HH24:MI:SS') AND
       to_date('2018-10-31 12:00:00', 'YYYY-MM-DD HH24:MI:SS') -- 日用
      --AND itf.creation_date BETWEEN
      --    to_date('2018-10-31 12:00:00', 'YYYY-MM-DD HH24:MI:SS') AND to_date('2018-10-31 18:00:00', 'YYYY-MM-DD HH24:MI:SS') -- 夜用
   AND itf.process_status_lookup_code = 'ERROR'
   AND hou.name LIKE '%ZJ%'*/
   and itf.bank_statement
   in(
--
--先找错误
--过滤已解决的
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
