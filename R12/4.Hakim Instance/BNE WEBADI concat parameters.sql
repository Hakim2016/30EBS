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

SELECT BNI.USER_NAME,
       -- bni.application_id,
       BNI.INTEGRATOR_CODE, --集成器code ,bni.user_name --集成器名称        
       BLV.LAYOUT_CODE, --布局代码        
       --blv.user_name, --布局用户名称 
       BCV.CONTENT_CODE,
       'bne:page=BneCreateDoc&' || --
       'bne:language=US&' || --
       'bne:viewer=BNE:EXCEL2007&' || --'bne:viewer=BNE:EXCEL2003%25&' || --
       'bne:reporting=N&' || --
       'bne:integrator=' || BNI.INTEGRATOR_CODE || '&' || --
       'bne:layout=' || BLV.LAYOUT_CODE || '&' || --
       'bne:content=' || BCV.CONTENT_CODE || '&' || --
       'bne:noreview=Y' FUNCTION_PARAMETERS
  FROM BNE_INTEGRATORS_VL BNI, BNE_LAYOUTS_VL BLV, BNE_CONTENTS_VL BCV
 WHERE 1 = 1 --bni.user_name LIKE 'XX%'
      --AND bni.integrator_code IN ('GENERAL_25_INTG', 'GENERAL_1_INTG', 'GENERAL_22_INTG')
   AND BLV.INTEGRATOR_APP_ID = BNI.APPLICATION_ID
   AND BLV.INTEGRATOR_CODE = BNI.INTEGRATOR_CODE
   AND BCV.INTEGRATOR_APP_ID = BNI.APPLICATION_ID
   AND BCV.INTEGRATOR_CODE = BNI.INTEGRATOR_CODE
   AND BNI.INTEGRATOR_CODE LIKE 'HDSP%'
 ORDER BY BNI.INTEGRATOR_CODE;

SELECT *
  FROM BNE_INTEGRATORS_VL BNI
 WHERE 1 = 1
   AND BNI.INTEGRATOR_CODE LIKE 'HDSP%';
   
SELECT * from BNE_LAYOUTS_VL bnl where 1=1 
AND bnl.LAYOUT_CODE LIKE 'HDSP%';

SELECT * from BNE_CONTENTS_VL BCV where 1=1 
AND bcv.CONTENT_CODE LIKE 'HDSP%';
