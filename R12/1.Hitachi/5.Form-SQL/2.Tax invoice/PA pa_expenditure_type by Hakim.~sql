--pa expenditure type
/*
Name  Window Prompt Column  Value Set
Cost Structure  Cost Structure  ATTRIBUTE4  XXPA_EXPENDITURE_COST_STRUCTURE
Expenditure Type  Expenditure Type  ATTRIBUTE14 XXPA_EXPENDITURE_ACTIVITY_TYPE
Reporting Expenditure Type  Reporting Expenditure Type  ATTRIBUTE15 XXPA_EXP_TYPES_TITLE
Related Expenditure Type  Related Expenditure Type  ATTRIBUTE11 ¡¡
Budget Type Budget Type ATTRIBUTE3  XXPA_EXP_BUDGET_TYPES
Workers Rate  Workers Rate  ATTRIBUTE12 ¡¡
Staff Rate  Staff Rate  ATTRIBUTE13
*/




--Labor hour
--associated with department & resource. 



SELECT * FROM pa_expenditure_types pei
WHERE 1=1
AND pei.expenditure_type_id IN (10077,10036,10050,10049,10062); 

--Following is description flexfiled
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

