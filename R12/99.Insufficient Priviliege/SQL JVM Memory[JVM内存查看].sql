--->SQL 
SELECT service_id,
       developer_parameters
  FROM fnd_cp_services
 WHERE service_id = (SELECT manager_type
                       FROM fnd_concurrent_queues
                      WHERE concurrent_queue_name = 'FNDCPOPP');
--->Result    J:oracle.apps.fnd.cp.gsf.GSMServiceController:-mx1024m
