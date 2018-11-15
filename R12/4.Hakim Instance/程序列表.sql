SELECT fcp.enabled_flag                  ����,
       fcpt.user_concurrent_program_name ������,
       fcp.concurrent_program_name       ������,
       fat_fcp.application_name          ����Ӧ����,
       fcpt.description                  ����˵��,

       --
       fet.user_executable_name ��ִ��,
       fe.executable_name       ��ִ�м��,
       fat_fe.application_name  ��ִ��Ӧ����,
       fet.description          ��ִ��˵��,
       flv.meaning              ִ�з���,
       fe.execution_file_name   ִ���ļ���
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
