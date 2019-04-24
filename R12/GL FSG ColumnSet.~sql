--v1.0 列集 及 相关 行集 列集都存在于一张表中
SELECT *
  FROM rg_report_axis_sets_v v
 WHERE 1 = 1
   AND v.name LIKE '%资产%列集'--'CUX%'
;

SELECT 
rc.sequence
,rc.position
,rc.display_format
,rs.column_set_header
--,r.name
--,r.description
,rs.name
,rs.DESCRIPTION
,rs.axis_set_type
,rs.*
,rc.* from 
       rg_report_axis_sets_v   rs --行集/列集
      ,
       rg_report_axes_v        rc --行/列
       where 1=1 
       AND rs.axis_set_id = rc.axis_set_id
       AND rs.name = '资产负债表列集';


--1.Accounting Assignments
SELECT rs.name,
       acc_sgn.axis_seq,
       --r.name,
       r.description,
       acc_sgn.sign,
       acc_sgn.dr_cr_net_code,
       acc_sgn.segment3_low,
       acc_sgn.segment3_high,
       acc_sgn.*
  FROM rg_report_axis_contents acc_sgn --account assignments
      ,
       rg_report_axis_sets_v   rs --行集/列集
      ,
       rg_report_axes_v        r --行/列
 WHERE 1 = 1
   AND rs.axis_set_id(+) = acc_sgn.axis_set_id
   AND r.axis_set_id = rs.axis_set_id
   AND r.sequence = acc_sgn.axis_seq
   --AND rs.name LIKE '%列集'
--AND acc_sgn.axis_set_id = 4000
--AND acc_sgn.axis_seq = 3
 ORDER BY acc_sgn.axis_seq;
