SELECT pet.attribute15,
       pet.*
  FROM pa_expenditure_types pet
 WHERE 1 = 1
   AND pet.expenditure_category = 'FG Completion'--'FG Completion'--'FG Completion'
 ORDER BY pet.attribute15;
