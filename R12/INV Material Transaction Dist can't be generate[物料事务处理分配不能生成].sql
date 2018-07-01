http://oracleappsdna.com/2011/10/how-costing-is-performed-on-inventory-material-transactions/
-- situation One(Cost Cutoff Date)
/*
Path : Inventory -> Setup -> Organizations -> Parameters -> Costing Information -> Cost Cutoff Date
Even though cost manager is running successfully to get the transactions costed, 
cost cutoff date must be greater than sysdate or null.

*/


-- situation Two
-- Once costed_flag is E, all the material transaction distributions of its organization  can't be generate
-- Author : PanJinlong

CREATE TABLE xxinv.xxinv_mmt_bk20150605 AS
SELECT mmt.*
  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   AND mmt.costed_flag = 'E';
   
UPDATE mtl_material_transactions mmt
   SET mmt.costed_flag = 'N'
 WHERE mmt.transaction_id IN (SELECT t.transaction_id
                                FROM xxinv.xxinv_mmt_bk20150605 t);


select * from xxinv.xxinv_mmt_bk20150605 t; -- 16672055
SELECT mmt.costed_flag,mmt.*
  FROM mtl_material_transactions mmt
 WHERE mmt.transaction_id IN (SELECT t.transaction_id
                                FROM xxinv.xxinv_mmt_bk20150605 t);


-- second
CREATE TABLE xxinv.xxinv_mmt_bk2015060501 AS
SELECT mmt.*
  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   AND mmt.transaction_type_id = 112
   AND mmt.transaction_source_id IS NULL;
   
 UPDATE mtl_material_transactions mmt
    SET mmt.costed_flag           = 'N',
        mmt.transaction_source_id =
        (SELECT gcc.code_combination_id
           FROM gl_code_combinations_kfv gcc
          WHERE gcc.concatenated_segments = 'FB00.000.1161500990.1146011000.11000432.0.0')
  WHERE mmt.transaction_id IN (SELECT t.transaction_id
                                 FROM xxinv.xxinv_mmt_bk2015060501 t);
 
 SELECT mmt.costed_flag,
        mmt.transaction_source_id,
        mmt.*
   FROM mtl_material_transactions mmt
  WHERE mmt.transaction_id IN (SELECT t.transaction_id
                                 FROM xxinv.xxinv_mmt_bk2015060501 t);
   
