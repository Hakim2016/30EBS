--for update

SELECT *
  FROM bne_stored_sql a
 WHERE 1 = 1
   AND a.creation_date > SYSDATE - 10
   AND a.content_code LIKE '%ITMFRCST%'
   FOR UPDATE;

SELECT bic.*
  FROM bne_interface_cols_b bic
 WHERE 1 = 1
 AND bic.creation_date > SYSDATE - 20
 AND application_id = 20009
   AND bic.interface_code LIKE 'ITMFRCST%' FOR UPDATE
   AND bic.interface_col_name = 'P_ACTION_TYPE'
   FOR UPDATE;
   
SELECT bic.*
  FROM bne_interface_cols_tl bic
 WHERE 1 = 1
 AND bic.creation_date > SYSDATE -20 
   AND bic.interface_code LIKE 'ITMFRCST%'
   
DELETE FROM bne_interface_cols_b bic
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%';
   
DELETE FROM bne_interface_cols_tl bic
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%'

SELECT *
  FROM bne_layouts_b blb
 WHERE 1 = 1
   AND blb.creation_date > SYSDATE - 20;
   
SELECT * 
FROM bne_mapping_lines bml
WHERE 1=1
AND bml.creation_date > SYSDATE - 20;


SELECT bic.*
  FROM bne_interface_cols_b bic
 WHERE 1 = 1
   --AND bic.interface_code LIKE '%ACTION%TYPE%'--'ITMFRCST%'
   AND bic.interface_col_name LIKE '%ACTION%TYPE%'
   AND bic;
   
SELECT * FROM bne_contents_b bcb
WHERE 1=1
AND bcb.param_list_code IN ('GENERAL_281_CNT_PL','MRP_FRCST_PARA_LST')
AND bcb.integrator_code LIKE '%DATE%';
