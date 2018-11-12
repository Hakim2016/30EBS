SELECT fcp.enabled_flag                  启用,
       fcpt.user_concurrent_program_name 程序名,
       fcp.concurrent_program_name       程序简称,
       fat_fcp.application_name          程序应用名,
       fcpt.description                  程序说明,

       --
       fet.user_executable_name 可执行,
       fe.executable_name       可执行简称,
       fat_fe.application_name  可执行应用名,
       fet.description          可执行说明,
       flv.meaning              执行方法,
       fe.execution_file_name   执行文件名
  FROM apps.fnd_concurrent_programs fcp,
       apps.fnd_application_tl      fat_fcp,
       fnd_concurrent_programs_tl   fcpt,
       apps.fnd_executables         fe,
       fnd_executables_tl           fet,
       apps.fnd_application_tl      fat_fe,
       fnd_lookup_values            flv
 WHERE 1 = 1
   AND fcp.concurrent_program_name LIKE 'Z%'
   AND fcp.concurrent_program_id = fcpt.concurrent_program_id
   AND fcpt.language = 'ZHS'
   AND fcp.application_id = fat_fcp.application_id
   AND fat_fcp.language = 'ZHS'
   AND fcp.executable_id = fe.executable_id
   AND fe.executable_id = fet.executable_id
   AND fet.language = 'ZHS'
   AND fe.application_id = fat_fe.application_id
   AND fat_fe.language = 'ZHS'
   AND flv.lookup_code = fe.execution_method_code
   AND flv.lookup_type = 'CP_EXECUTION_METHOD_CODE'
   AND flv.language = 'ZHS'
 ORDER BY fat_fcp.application_name,
          fcp.concurrent_program_name
