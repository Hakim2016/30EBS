--XXINV_AUTO_PUSH_MMT_PKG;
--check cost cutoff date
--check the status of cost manager
--check the stuck records in mmt
SELECT *
  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   AND mmt.costed_flag = 'E';

UPDATE mtl_material_transactions mmt
   SET mmt.costed_flag = 'N'
 WHERE 1 = 1
   AND mmt.costed_flag = 'E';
