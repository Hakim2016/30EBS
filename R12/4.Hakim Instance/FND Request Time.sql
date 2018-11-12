SELECT fcr.request_id,
       fcr.request_date,
       fcr.argument_text,
       (fcr.actual_start_date - fcr.request_date) * 24 * 60 wait_time,
       (fcr.actual_completion_date - fcr.actual_start_date) * 24 * 60 run_time,
       fcr.ofile_size
  FROM fnd_concurrent_requests fcr, fnd_concurrent_programs_vl fcp
 WHERE fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcp.CONCURRENT_PROGRAM_NAME = 'XXPAPCCR'
