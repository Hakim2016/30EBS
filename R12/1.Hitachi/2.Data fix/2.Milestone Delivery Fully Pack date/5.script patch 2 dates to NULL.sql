--scripts v1.04
--v1.05 can process different so to same date
/*4 points need to change
mfg num
so/proj num
org_id
date 2018-09-01
backup table 20180907_1
*/
--check so
SELECT ool.attribute1,
       ool.attribute4,
       ool.*
  FROM oe_order_lines_all ool
 WHERE 1 = 1
   AND ool.ordered_item IN ('JDA0001-MY')
   AND EXISTS (SELECT 1
          FROM oe_order_headers_all ooh
         WHERE 1 = 1
           AND ooh.order_number IN ('53020003')
           AND ooh.org_id = 101
           AND ooh.header_id = ool.header_id)
 ORDER BY ool.line_number;

--check fully packed date
SELECT t.fully_packing_date,
       t.*
  FROM xxinv_mfg_full_packing_sts t
 WHERE t.mfg_number IN ('JDA0001-MY')
   AND t.org_id = 101;

--backup so line
CREATE TABLE oe_order_lines_all_20180907_1 AS
  SELECT ool.*
    FROM oe_order_lines_all ool
   WHERE 1 = 1
     AND ool.ordered_item IN ('JDA0001-MY')
     AND EXISTS (SELECT 1
            FROM oe_order_headers_all ooh
           WHERE 1 = 1
             AND ooh.order_number IN ('53020003')
             AND ooh.org_id = 101
             AND ooh.header_id = ool.header_id)
   ORDER BY ool.line_number;

SELECT *
  FROM oe_order_lines_all_20180907_1;

--backup xxinv_mfg_full_packing_sts
CREATE TABLE xxinv_mfg_packing_20180907_1 AS
  SELECT t.*
    FROM xxinv_mfg_full_packing_sts t
   WHERE t.mfg_number IN ('JDA0001-MY')
     AND t.org_id = 101;

SELECT *
  FROM xxinv_mfg_packing_20180907_1;

--update so line DFF4
UPDATE oe_order_lines_all ool
   SET ool.attribute4       = '', --'2018-09-01', 
       ool.last_update_date = SYSDATE --add by hakim 20180508
 WHERE 1 = 1
   AND ool.ordered_item IN ('JDA0001-MY')
   AND EXISTS (SELECT 1
          FROM oe_order_headers_all ooh
         WHERE 1 = 1
           AND ooh.order_number IN ('53020003')
           AND ooh.org_id = 101
           AND ooh.header_id = ool.header_id);

--update xxinv_mfg_full_packing_sts
UPDATE xxinv_mfg_full_packing_sts t
   SET t.fully_packing_date = NULL --to_date('2018-09-01', 'YYYY-MM-DD')
 WHERE t.mfg_number IN ('JDA0001-MY')
   AND t.org_id = 101;
;
/*
Submit request for this update
<XXPA:Project Status Update(BA)>
*/

SELECT xpmm.ba_fully_packing_date,
       xpmm.fully_delivery_date,
       xpmm.*
  FROM xxpa_proj_milestone_manage_all xpmm
 WHERE 1 = 1
   AND xpmm.mfg_num IN ('JDA0001-MY')
   AND xpmm.org_id = 101
;

CREATE TABLE xxpa_proj_ms_manage_20180907_1 AS
  SELECT *
    FROM xxpa_proj_milestone_manage_all xpmm
WHERE 1 = 1
   AND xpmm.mfg_num IN ('JDA0001-MY')
   AND xpmm.org_id = 101
   
   ;
   
SELECT *
  FROM xxpa_proj_ms_manage_20180907_1;
  
UPDATE xxpa_proj_milestone_manage_all xpmm
   SET xpmm.ba_fully_packing_date = NULL,
       xpmm.fully_delivery_date   = NULL,
       
       xpmm.last_updated_by     = fnd_global.user_id,
       xpmm.last_update_date    = SYSDATE,
       xpmm.program_update_date = SYSDATE
WHERE 1 = 1
   AND xpmm.mfg_num IN ('JDA0001-MY')
   AND xpmm.org_id = 101
;



