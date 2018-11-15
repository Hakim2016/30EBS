--PA Interface
SELECT
--pa.created_by,
pa.org_id,
--pa.organization_id,--null for this field
pa.organization_name,
-- pa.creation_date,--null for this field
 pa.transaction_rejection_code,
 pa.transaction_status_code,
 pa.*
  FROM pa_transaction_interface_all pa
 WHERE 1 = 1
   AND pa.transaction_rejection_code IS NULL --= 'PA_PROJECT_NOT_VALID'
   AND pa.org_id = 84
   --AND pa.o
--AND pa.created_by IS NOT NULL

 --ORDER BY pa.creation_date DESC
;
