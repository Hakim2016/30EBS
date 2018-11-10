--报账导入总账凭证信息接口表
SELECT 
itf.pri_key,
hou.name,
--itf.org_name,
itf.external_document_num 外部单据编号,
itf.creation_date,
itf.process_status_lookup_code 处理状态,
itf.process_message
,itf.*
  FROM apps.hr_operating_units         hou,
       apps.cux_gl_cmf_headers_itf itf
 WHERE itf.org_id = hou.organization_id
   --AND itf.creation_date > TRUNC(SYSDATE)+ 0.5
   --AND itf.creation_date between
     --  to_date('2018-11-01 18:00:00', 'YYYY-MM-DD HH24:MI:SS') and to_date('2018-11-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS') -- 日用
   --AND itf.creation_date BETWEEN
   --    to_date('2018-10-31 12:00:00', 'YYYY-MM-DD HH24:MI:SS') AND to_date('2018-10-31 18:00:00', 'YYYY-MM-DD HH24:MI:SS') -- 夜用
   AND itf.process_status_lookup_code = 'ERROR'
   AND hou.name LIKE '%ZJ%';
