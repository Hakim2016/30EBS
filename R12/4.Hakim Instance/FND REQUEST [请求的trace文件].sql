select vp.VALUE, '*' || fcr.oracle_process_id || '*' || '.trc'
  from v$parameter vp, fnd_concurrent_requests fcr
 where vp.NAME = 'user_dump_dest'
   and fcr.request_id = 11745986;
