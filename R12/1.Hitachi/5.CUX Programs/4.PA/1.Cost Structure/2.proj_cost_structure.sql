--CURSOR lines_c(p_expenditure_type_id NUMBER) IS
SELECT pet.expenditure_type,
       xpcs.*
  FROM xxpa_proj_cost_structure xpcs,
       pa_expenditure_types     pet
 WHERE 1 = 1
   AND nvl(xpcs.disable_date, trunc(SYSDATE) + 1) > trunc(SYSDATE)
   AND xpcs.expenditure_type_id = pet.expenditure_type_id
--AND xpcs.expenditure_type_id = nvl(p_expenditure_type_id, xpcs.expenditure_type_id)
;

SELECT mc.*
  FROM mtl_categories_b mc
 WHERE 1 = 1
   AND mc.structure_id = 50350;
