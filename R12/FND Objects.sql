SELECT o.object_name,'drop ' || o.object_type || ' ' || o.object_name || ';'
  FROM user_objects o
 WHERE o.object_name LIKE '%ZX%'--'%ENTITY%'
   AND o.object_type IN ('TABLE'/*, 'SEQUENCE', 'VIEW', 'SYNONYM'*/)
;

SELECT * FROM xxhkm_log xx WHERE 1=1 ;--AND 


SELECT *
  FROM dba_objects xx
 WHERE 1 = 1
   --AND xx.status = 'INVALID'
   AND xx.object_type IN ('TABLE', 'VIEW')
   AND xx.object_name LIKE 'ZX%'
   --AND xx.OBJECT_NAME = 'XXPA_COST_EXPORT_GCPM_PKG2'
   
   ;
