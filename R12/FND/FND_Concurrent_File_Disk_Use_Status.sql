-- detail
SELECT fcr.request_id,
       fcr.request_date,
       --fcp.concurrent_program_id,
       fcp.user_concurrent_program_name,
       nvl(fcr.ofile_size, 0) / 1024 / 1024 output_file_size_mb,
       nvl(fcr.lfile_size, 0) / 1024 / 1024 log_file_size_mb,
       (nvl(fcr.ofile_size, 0) + nvl(fcr.lfile_size, 0)) / 1024 / 1024 file_size_mb
  FROM apps.fnd_concurrent_requests    fcr,
       apps.fnd_concurrent_programs_vl fcp
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
 ORDER BY fcr.request_id DESC;

-- everydate every concurrent programs
SELECT trunc(fcr.request_date),
       fcp.user_concurrent_program_name,
       SUM(nvl(fcr.ofile_size, 0) / 1024 / 1024) output_file_size_mb,
       SUM(nvl(fcr.lfile_size, 0) / 1024 / 1024) log_file_size_mb,
       SUM((nvl(fcr.ofile_size, 0) + nvl(fcr.lfile_size, 0)) / 1024 / 1024) file_size_mb
  FROM apps.fnd_concurrent_requests    fcr,
       apps.fnd_concurrent_programs_vl fcp
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
 GROUP BY trunc(fcr.request_date),
          fcp.user_concurrent_program_name
 ORDER BY trunc(fcr.request_date) DESC,
          fcp.user_concurrent_program_name;

-- everydate
SELECT trunc(fcr.request_date),
       SUM(nvl(fcr.ofile_size, 0) / 1024 / 1024) output_file_size_mb,
       SUM(nvl(fcr.lfile_size, 0) / 1024 / 1024) log_file_size_mb,
       SUM((nvl(fcr.ofile_size, 0) + nvl(fcr.lfile_size, 0)) / 1024 / 1024) file_size_mb
  FROM apps.fnd_concurrent_requests    fcr,
       apps.fnd_concurrent_programs_vl fcp
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
 GROUP BY trunc(fcr.request_date)
 ORDER BY trunc(fcr.request_date) DESC;

-- every month
SELECT trunc(fcr.request_date, 'MM'),
       SUM(nvl(fcr.ofile_size, 0) / 1024 / 1024) output_file_size_mb,
       SUM(nvl(fcr.lfile_size, 0) / 1024 / 1024) log_file_size_mb,
       SUM((nvl(fcr.ofile_size, 0) + nvl(fcr.lfile_size, 0)) / 1024 / 1024) file_size_mb
  FROM apps.fnd_concurrent_requests    fcr,
       apps.fnd_concurrent_programs_vl fcp
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
 GROUP BY trunc(fcr.request_date, 'MM')
 ORDER BY trunc(fcr.request_date, 'MM') DESC;
