/*
XXPAR043
XXPA:Project Wip Cost Analysis Detail
xxpa_wip_cost_souchi_dtl_pkg.main
*/

xxpa_wip_cost_souchi_dtl_pkg;--.main

SELECT *
  FROM xxpa_wip_cost_souchi_dtl_tmp
 WHERE 1 = 1
   AND 1 = 1;
   
--TRUNCATE TABLE xxpa.xxpa_wip_cost_souchi_dtl_tmp;

--ALTER TABLE xxpa.xxpa_wip_cost_souchi_dtl_tmp ADD request_id NUMBER;

CREATE INDEX xxpa.xxpa_wip_cost_souchi_dtl_N1 ON xxpa.xxpa_wip_cost_souchi_dtl_tmp
               (proj_no,
                task,
                group_parts,
                souchi,
                expen_cate,
                expen_type,
                gl_date);
