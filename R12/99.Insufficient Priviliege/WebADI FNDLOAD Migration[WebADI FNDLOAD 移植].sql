
-- FNDLOAD 移植 WebADI

-- FNDLOAD移植常用程序（功能，菜单，并发程序，值集等）已经使用的非常频繁，也非常成熟。具体的可以参考我之前的文章：《FNDLOAD的用法》
-- Oracle 也提供了针对WebADI移植的配置文件，不过配置文件路径放在$BNE_TOP/admin/import。对于定义的移植很简单，照下面做就行了：

-- Integrators
/*
FNDLOAD apps/apps_pwd 0 Y DOWNLOAD $BNE_TOP/admin/import/bneint.lct GENERAL_170_INTG.ldt BNE_INTEGRATORS INTEGRATOR_ASN="CUX" INTEGRATOR_CODE="GENERAL_170_INTG"
FNDLOAD apps/apps_pwd 0 Y UPLOAD $BNE_TOP/admin/import/bneint.lct GENERAL_170_INTG.ldt
*/

-- Layouts
/*
FNDLOAD apps/apps_pwd 0 Y DOWNLOAD $BNE_TOP/admin/import/bnelay.lct CUX_PRE_MTL.ldt BNE_LAYOUTS LAYOUT_ASN="CUX" LAYOUT_CODE="CUX_PRE_MTL"
FNDLOAD apps/apps_pwd 0 Y UPLOAD  $BNE_TOP/admin/import/bnelay.lct CUX_PRE_MTL.ldt 
*/

-- Mappings
/*
FNDLOAD apps/apps_pwd 0 Y DOWNLOAD $BNE_TOP/admin/import/bnemap.lct GENERAL_170_MAP.ldt BNE_MAPPINGS MAPPING_ASN="CUX" MAPPING_CODE="GENERAL_170_MAP"
FNDLOAD apps/apps_pwd 0 Y UPLOAD $BNE_TOP/admin/import/bnemap.lct GENERAL_170_MAP.ldt 
*/

-- Contents
/*
FNDLOAD apps/apps_pwd 0 Y DOWNLOAD $BNE_TOP/admin/import/bnecont.lct GENERAL_170_CNT.ldt BNE_CONTENTS CONTENT_ASN="CUX" CONTENT_CODE="GENERAL_170_CNT"
FNDLOAD apps/apps_pwd 0 Y UPLOAD $BNE_TOP/admin/import/bnecont.lct GENERAL_170_CNT.ldt 
*/

-- Parameters
/*
FNDLOAD apps/apps_pwd 0 Y DOWNLOAD $BNE_TOP/admin/import/bneparamlist.lct bneparamlist.ldt BNE_PARAM_LISTS INTEGRATOR_ASN="CUX" INTEGRATOR_CODE="GENERAL_170_INTG"
FNDLOAD apps/apps_pwd 0 Y UPLOAD $BNE_TOP/admin/import/bneparamlist.lct bneparamlist.ldt
*/

-- 至此，WebADI的相关定义已经顺利移植完毕。在网络上倒也可以找到一些文章，比如这个老兄，但是他少讲了一点，就是下面这点：

-- Security
/*
FNDLOAD apps/apps_pwd 0 Y DOWNLOAD $BNE_TOP/admin/import/bnesecurity.lct bnesecurity.ldt BNE_SECURED_OBJECTS SECURED_OBJECT_ASN="CUX" SECURED_OBJECT_CODE="GENERAL_170_INTG"
FNDLOAD apps/apps_pwd 0 Y UPLOAD $BNE_TOP/admin/import/bnesecurity.lct bnesecurity.ldt
*/

-- 定义完后，还需要设置安全性规则，否则您将永远无权限访问任何内容。

SELECT bni.user_name,
       -- bni.application_id,
       fa_bni.application_short_name,
       bni.integrator_code, --集成器code
       fa_blv.application_short_name,
       blv.layout_code, --布局代码
       fa_bmv.application_short_name,
       bmv.mapping_code,
       fa_bcv.application_short_name,
       bcv.content_code,
       -- Integrators
       'FNDLOAD apps/apps 0 Y DOWNLOAD $BNE_TOP/admin/import/bneint.lct ' || bni.integrator_code ||
       '.ldt BNE_INTEGRATORS INTEGRATOR_ASN="' || fa_bni.application_short_name || '" INTEGRATOR_CODE="' ||
       bni.integrator_code || '"' fndload_integrators,
       -- Layouts
       'FNDLOAD apps/apps 0 Y DOWNLOAD $BNE_TOP/admin/import/bnelay.lct ' || bni.integrator_code || '_LAYOUTS_' ||
       blv.layout_code || '.ldt BNE_LAYOUTS LAYOUT_ASN="' || fa_blv.application_short_name || '" LAYOUT_CODE="' ||
       blv.layout_code || '"' fndload_layouts,
       -- Mappings
       'FNDLOAD apps/apps 0 Y DOWNLOAD $BNE_TOP/admin/import/bnemap.lct ' || bni.integrator_code || '_MAP_' ||
       bmv.mapping_code || '.ldt BNE_MAPPINGS MAPPING_ASN="' || fa_bmv.application_short_name || '" MAPPING_CODE="' ||
       bmv.mapping_code || '"' fndload_mappings,
       -- Contents
       'FNDLOAD apps/apps 0 Y DOWNLOAD $BNE_TOP/admin/import/bnecont.lct ' || bni.integrator_code || '_CNT_' ||
       bcv.content_code || '.ldt BNE_CONTENTS CONTENT_ASN="' || fa_bcv.application_short_name || '" CONTENT_CODE="' ||
       bcv.content_code || '"' fndload_content,
       -- Parameters
       'FNDLOAD apps/apps 0 Y DOWNLOAD $BNE_TOP/admin/import/bneparamlist.lct ' || bni.integrator_code || '_PARAS' ||
       '.ldt BNE_PARAM_LISTS INTEGRATOR_ASN="' || fa_bni.application_short_name || '" INTEGRATOR_CODE="' ||
       bni.integrator_code || '"' fndload_parameters,
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
       bne_contents_vl    bcv,
       bne_mappings_vl    bmv,
       fnd_application_vl fa_bni,
       fnd_application_vl fa_blv,
       fnd_application_vl fa_bmv,
       fnd_application_vl fa_bcv
 WHERE 1 = 1 --bni.user_name LIKE 'XX%'
   AND bni.application_id = fa_bni.application_id
   AND bni.integrator_code IN ('GENERAL_10_INTG')
   AND blv.integrator_app_id = bni.application_id
   AND blv.integrator_code = bni.integrator_code
   AND blv.application_id = fa_blv.application_id
   AND bcv.integrator_app_id = bni.application_id
   AND bcv.integrator_code = bni.integrator_code
   AND bcv.application_id = fa_bcv.application_id
   AND bmv.integrator_app_id = bni.application_id
   AND bmv.integrator_code = bni.integrator_code
   AND bmv.application_id = fa_bmv.application_id;
