SELECT DISTINCT pet.expenditure_category, pet.expenditure_type
  FROM PA_EXPENDITURE_TYPES pet, PA_EXPENDITURE_ITEMS_ALL pei
 WHERE pet.expenditure_category IN ('Labour')--('Material', 'Material Overhead')
   AND pei.org_id = 84
   AND PEI.EXPENDITURE_TYPE = PET.EXPENDITURE_TYPE
 ORDER BY pet.expenditure_category, pet.expenditure_type;
