/*
IF36
XXPAB003
DHR
XXPA_DESIGN_LABOR_INT
XXPA:Design Labor Hours Import
xxpa_labor_hours_import_pkg.design_main

Labor Hours Workbench
XXPAF003

*/

xxpa_labor_hours_import_pkg;--.design_main

SELECT *
  FROM xxpa_design_labor_int intf
 WHERE 1 = 1
   --AND intf.creation_date > to_date('2018-06-20 17:08:00', 'yyyy-mm-dd hh24:mi:ss')
      --AND intf.mfg_no = 'LN0732-L2'
      AND intf.source_group_indentify = 220180608161009
   AND intf.department IN ('Research ' || '&' || ' Development'/*, 'Product Design'*/)
   ;
   
   
--Labor hour workbench
SELECT v.mfg_number,
       v.department,
       v.expenditure_type,
       v.group_dsp,
       v.labor_rate,
       v.hours,
       v.labor_amount,
       v.*
  FROM xxpa_labor_hours_v v
 WHERE 1 = 1
   AND v.creation_date > to_date('2018-06-20 17:08:00', 'yyyy-mm-dd hh24:mi:ss') --to_date('2018-06-01', 'yyyy-mm-dd')
   AND v.department IN ('Research ' || '&' || ' Development' /*, 'Product Design'*/)
   ;

SELECT *
  FROM xxpa_labor_hours_all lha
 WHERE 1 = 1
   AND lha.creation_date > to_date('2018-01-01', 'yyyy-mm-dd')
   AND lha.department IN ('Research ' || '&' || ' Development'/*, 'Product Design'*/)
;

--XXPA_EXPENDITURE_COST_STRUCTURE(Table Value Set)
SELECT pet.expenditure_category,
       pet.unit_of_measure,
       pet.attribute3,
       pet.attribute4,
       pet.attribute11,
       pet.attribute12,
       pet.attribute13,
       pet.*
  FROM pa_expenditure_types pet
 WHERE 1 = 1
   AND pet.attribute_category = 'HEA_OU'
AND pet.attribute14 = 'Actual'
;

--XXPA_EXPENDITURE_ACTIVITY_TYPE(Independent Value Set)


--XXPA_EXP_TYPES_TITLE(Table VS)
SELECT xl.meaning,
       xl.*
  FROM xxpa_lookups xl
 WHERE xl.lookup_type = 'XXPA_REPORT_TITLE_SEQ'
   AND xl.enabled_flag = 'Y'
   AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND nvl(xl.end_date_active, trunc(SYSDATE))
 ORDER BY xl.meaning;


--XXPA_EXP_BUDGET_TYPES(Table VS)
SELECT *
  FROM pa_expenditure_types pei
 WHERE 1 = 1
   AND (pei.attribute1 IS NOT NULL OR pei.expenditure_type = 'MOS Transfer In ER')
 ORDER BY pei.expenditure_type;
 
--Resources
       --Resource Information
SELECT v.resource_id src_id,
       v.resource_code src_cd,
       v.description descp,
       v.unit_of_measure uom,
       v.resource_type src_type,
       --2 Person
       v.autocharge_type,
       --2 Manual
       v.expenditure_type,
       v.organization_id,
       v.attribute1,
       v.attribute2,--expenditure type
       (
       SELECT pet.expenditure_type FROM pa_expenditure_types pet
       WHERE 1=1
       AND pet.expenditure_type_id = v.attribute2
       ) expen_type,
       v.attribute3
  FROM bom_resources_v v
 WHERE 1 = 1
   AND v.resource_code IN 
   ('DS', 'E(R'||'&'||'D)', 'M(R'||'&'||'D)', 'VEC')--R&D
   --('HVF','ID','JDDM','P/C','RTMC','SW','UAG','VF')--Product Design
   ;
