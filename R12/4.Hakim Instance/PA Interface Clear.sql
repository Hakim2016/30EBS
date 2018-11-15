
SELECT DISTINCT batch_name FROM pa_transaction_interface_all pa WHERE pa.org_id=84

CREATE TABLE xxpa.pa_trx_interface_all130902
AS
SELECT pa.*
  FROM pa_transaction_interface_all pa
 WHERE pa.transaction_rejection_code = 'PA_PROJECT_NOT_VALID'
   AND pa.org_id = 84
   --AND pa.batch_name IN ('CC02401996', 'CC00327292', 'CC02401995');


SELECT * FROM xxpa.pa_trx_interface_all130902;


UPDATE pa_transaction_interface_all pa
   SET pa.transaction_status_code    = 'P'
      ,pa.transaction_rejection_code = NULL
 WHERE pa.transaction_rejection_code = 'PA_PROJECT_NOT_VALID'
   AND pa.org_id = 84
   --AND pa.batch_name IN ('CC02401996', 'CC00327292', 'CC02401995')
   AND pa.txn_interface_id IN
       (SELECT txn_interface_id FROM xxpa.pa_trx_interface_all130902);
       
       
       SELECT * FROM pa_transaction_interface_all;
       

CREATE TABLE xxpa.pa_trx_interface_all13090201
AS
SELECT pa.*
  FROM pa_transaction_interface_all pa
 WHERE pa.transaction_rejection_code = 'PA_PROJECT_NOT_VALID'
   AND pa.org_id = 84
   --AND pa.batch_name IN ('CC02401996', 'CC00327292', 'CC02401995');


SELECT * FROM xxpa.pa_trx_interface_all13090201;


UPDATE pa_transaction_interface_all pa
   SET pa.transaction_status_code    = 'P'
      ,pa.transaction_rejection_code = NULL
 WHERE pa.transaction_rejection_code = 'PA_PROJECT_NOT_VALID'
   AND pa.org_id = 84
   --AND pa.batch_name IN ('CC02401996', 'CC00327292', 'CC02401995')
   AND pa.txn_interface_id IN
       (SELECT txn_interface_id FROM xxpa.pa_trx_interface_all13090201);
       
       
CREATE TABLE xxpa.pa_trx_interface_all13090202
AS
SELECT pa.*
  FROM pa_transaction_interface_all pa
 WHERE pa.transaction_rejection_code  IS NULL
   AND pa.org_id = 84
   --AND pa.batch_name IN ('CC02401996', 'CC00327292', 'CC02401995');


SELECT * FROM xxpa.pa_trx_interface_all13090202;


UPDATE pa_transaction_interface_all pa
   SET pa.transaction_status_code    = 'P'
      ,pa.transaction_rejection_code = NULL
 WHERE pa.transaction_rejection_code IS NULL 
   AND pa.org_id = 84
   --AND pa.batch_name IN ('CC02401996', 'CC00327292', 'CC02401995')
   AND pa.txn_interface_id IN
       (SELECT txn_interface_id FROM xxpa.pa_trx_interface_all13090202);
       
       
       
