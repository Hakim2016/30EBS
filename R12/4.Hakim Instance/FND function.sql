SELECT fff.function_name, fff.user_function_name, fff.*
  FROM fnd_form_functions_vl fff
 WHERE 1 = 1
   AND fff.function_name LIKE 'HDSP%';
