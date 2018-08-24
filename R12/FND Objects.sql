SELECT 'drop ' || o.object_type || ' ' || o.object_name || ';'
  FROM user_objects o
 WHERE o.object_name LIKE 'XXHKM%'
   AND o.object_type IN ('TABLE', 'SEQUENCE', 'VIEW', 'SYNONYM')
;

SELECT * FROM xxhkm_log xx WHERE 1=1 ;--AND 


SELECT *
  FROM dba_objects xx
 WHERE 1 = 1
   AND xx.status = 'INVALID';
