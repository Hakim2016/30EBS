--get the package directly via short name
SELECT fef.user_executable_name,
       fef.executable_name,
       fef.application_name,
       fef.application_id,
       fef.execution_file_name,
       fef.*
  FROM fnd_executables_form_v fef
 WHERE 1 = 1
   AND fef.executable_name = 'XXPAPREFG';
