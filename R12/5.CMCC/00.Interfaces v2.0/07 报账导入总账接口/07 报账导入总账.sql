--报账导入总账凭证信息接口表
SELECT 
itf.pri_key,
itfl.line_number line_num,
hou.name,
--itf.org_name,
itf.external_document_num 外部单据编号,
itf.last_update_date,
--itf.creation_date,
itf.process_status_lookup_code 头处理状态,
itf.process_message,
itfl.process_status_lookup_code 行处理状态,
itfl.process_message
,itf.*
  FROM apps.hr_operating_units         hou,
       apps.cux_gl_cmf_headers_itf itf,
       apps.cux_gl_cmf_lines_itf_v itfl
 WHERE itf.org_id = hou.organization_id
 and itf.header_id = itfl.header_id
 and itfl.process_status_lookup_code <> 'SUCCESS'
   --AND itf.creation_date > TRUNC(SYSDATE)+ 0.5
   --AND itf.creation_date between
     --  to_date('2018-11-01 18:00:00', 'YYYY-MM-DD HH24:MI:SS') and to_date('2018-11-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS') -- 日用
   --AND itf.creation_date BETWEEN
   --    to_date('2018-10-31 12:00:00', 'YYYY-MM-DD HH24:MI:SS') AND to_date('2018-10-31 18:00:00', 'YYYY-MM-DD HH24:MI:SS') -- 夜用
   and itf.external_document_num not in 
   ('AP_R_0322_2018-09_001')
   and itf.pri_key in 
   (
   select itf.pri_key
  FROM apps.hr_operating_units         hou,
       apps.cux_gl_cmf_headers_itf itf
 WHERE itf.org_id = hou.organization_id
 AND itf.process_status_lookup_code <> 'SUCCESS'
   AND hou.name LIKE '%ZJ%'
   and not exists (
   select 1 from 
       apps.cux_gl_cmf_headers_itf itf2
       where 1=1
       and itf2.pri_key = itf.pri_key
       and itf2.process_status_lookup_code = 'SUCCESS'
   )
   )
   ;
   
   
   select * from    apps.cux_gl_cmf_lines_itf_v itfl;
