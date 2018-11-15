SELECT *
  FROM xdo_templates_vl t
 WHERE 1 = 1
   AND t.template_code LIKE 'XXARTAX%';

SELECT xl.lob_type,
       xl.application_short_name,
       xl.lob_code,
       xl.file_name,
       xtv.template_code,
       xtv.data_source_code,
       xtv.template_name
  FROM xdo_lobs         xl,
       xdo_templates_vl xtv
 WHERE 1 = 1
      --AND upper(xl.file_name) LIKE upper('XXARTAX%rtf')
   AND upper(xl.file_name) LIKE upper('%.rtf')
      --AND xl.file_name = 'XXOMEQPRT.rtf'
   AND xl.last_update_date > SYSDATE - 1
   AND xl.application_short_name = xtv.application_short_name(+)
   AND xl.lob_code = xtv.template_code(+)
 ORDER BY xtv.template_code;

SELECT xl.lob_type,
       xl.application_short_name,
       xl.lob_code,
       xl.file_name,
       xl.file_content_type,
       xl.xdo_file_type
  FROM xdo_lobs xl
 WHERE xl.last_update_date > SYSDATE - 1
   AND xl.xdo_file_type = 'RTF'
   AND xl.file_name = 'XXOMEQPRT.rtf'
 ORDER BY xl.file_name;

SELECT xtv.application_short_name,
       xtv.template_code,
       xtv.ds_app_short_name,
       xtv.data_source_code,
       xtv.template_name,
       --xl.lob_type,
       --xl.application_short_name,
       xl.xdo_file_type,
       xl.lob_code,
       --xl.language,
       --xl.territory,
       xl.file_name,
       xl.file_content_type
  FROM xdo_templates_vl xtv,
       xdo_lobs         xl
 WHERE 1 = 1
      -- AND xtv.application_short_name = 'XXOM'
      -- AND xtv.data_source_code = 'XXOMTIPRT'
   AND xtv.application_short_name = xl.application_short_name
   AND xtv.template_code = xl.lob_code
   AND upper(xl.file_name) IN ('XXOMDEPRT.RTF',
                               'XXOMEQPRT.RTF',
                               'XXOMFACDMCM.RTF',
                               'XXOMHODMCM.RTF',
                               'XXOMJBPRT.RTF',
                               'XXOMMAPRT.RTF',
                               'XXOMOSPRT.RTF');

SELECT *
  FROM xdo_templates_vl xtv
 WHERE 1 = 1
   AND xtv.template_code = 'XXOMEQPRT'
