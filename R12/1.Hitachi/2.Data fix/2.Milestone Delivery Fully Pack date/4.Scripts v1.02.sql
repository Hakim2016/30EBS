--scripts v1.02
--check so
SELECT ool.attribute4,
       ool.*
  FROM oe_order_lines_all ool
 WHERE 1 = 1
   AND ool.ordered_item IN ('TEB0072-TH', 'TEB0073-TH')
   AND EXISTS (SELECT 1
          FROM oe_order_headers_all ooh
         WHERE 1 = 1
           AND ooh.order_number = '53020628'
           AND ooh.org_id = 101
           AND ooh.header_id = ool.header_id)
 ORDER BY ool.line_number;

--check fully packed date
  SELECT t.fully_packing_date, t.*
    FROM xxinv_mfg_full_packing_sts t
   WHERE t.mfg_number IN ('TEB0072-TH', 'TEB0073-TH')
     AND t.org_id = 101;

--backup so line
CREATE TABLE oe_order_lines_all_201805605_1 AS
  SELECT ool.*
    FROM oe_order_lines_all ool
   WHERE 1 = 1
   AND ool.ordered_item IN ('TEB0072-TH', 'TEB0073-TH')
   AND EXISTS (SELECT 1
          FROM oe_order_headers_all ooh
         WHERE 1 = 1
           AND ooh.order_number = '53020628'
           AND ooh.org_id = 101
           AND ooh.header_id = ool.header_id)
 ORDER BY ool.line_number;

SELECT *
  FROM oe_order_lines_all_201805605_1;

--backup xxinv_mfg_full_packing_sts
CREATE TABLE xxinv_mfg_packing_201805605_1 AS
  SELECT t.*
    FROM xxinv_mfg_full_packing_sts t
   WHERE t.mfg_number IN ('TEB0072-TH', 'TEB0073-TH')
     AND t.org_id = 101;

SELECT *
  FROM xxinv_mfg_packing_201805605_1;

--update so line DFF4
UPDATE oe_order_lines_all ool
   SET ool.attribute4 = '2018-06-02', 
       ool.last_update_date = SYSDATE --add by hakim 20180508
 WHERE 1 = 1
   AND ool.ordered_item IN ('TEB0072-TH', 'TEB0073-TH')
   AND EXISTS (SELECT 1
          FROM oe_order_headers_all ooh
         WHERE 1 = 1
           AND ooh.order_number = '53020628'
           AND ooh.org_id = 101
           AND ooh.header_id = ool.header_id);

--update xxinv_mfg_full_packing_sts
UPDATE xxinv_mfg_full_packing_sts t
   SET t.fully_packing_date = to_date('2018/06/02', 'YYYY/MM/DD')
   WHERE t.mfg_number IN ('TEB0072-TH', 'TEB0073-TH')
     AND t.org_id = 101;
;
