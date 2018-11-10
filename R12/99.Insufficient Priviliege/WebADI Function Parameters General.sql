/*
bne:page=BneCreateDoc&bne:language=US&bne:viewer=BNE:EXCEL2003%25&bne:reporting=N&bne:integrator=GENERAL_22_INTG&bne:layout=LAYOUT_7VHW1&bne:content=GENERAL_22_CNT&bne:noreview=Y


'bne:page=BneCreateDoc&' ||
'bne:language=US&' ||
'bne:viewer=BNE:EXCEL2003%25&' ||
'bne:reporting=N&' ||
'bne:integrator=GENERAL_22_INTG&' ||
'bne:layout=LAYOUT_7VHW1&' ||
'bne:content=GENERAL_22_CNT&' ||
'bne:noreview=Y'
*/

SELECT bni.user_name,
       -- bni.application_id,
       bni.integrator_code, --集成器code ,bni.user_name --集成器名称        
       blv.layout_code, --布局代码        
       --blv.user_name, --布局用户名称 
       bcv.content_code,
       'bne:page=BneCreateDoc&' || --
       'bne:language=US&' || --
       'bne:viewer=BNE:EXCEL2003%25&' || --
       'bne:reporting=N&' || --
       'bne:integrator=' || bni.integrator_code || '&' || --
       'bne:layout=' || blv.layout_code || '&' || --
       'bne:content=' || bcv.content_code || '&' || --
       'bne:noreview=Y' function_parameters
  FROM bne_integrators_vl bni,
       bne_layouts_vl     blv,
       bne_contents_vl    bcv
 WHERE 1 = 1 --bni.user_name LIKE 'XX%'
   AND bni.integrator_code IN ('GENERAL_25_INTG', 'GENERAL_1_INTG', 'GENERAL_22_INTG')
   AND blv.integrator_app_id = bni.application_id
   AND blv.integrator_code = bni.integrator_code
   AND bcv.integrator_app_id = bni.application_id
   AND bcv.integrator_code = bni.integrator_code
