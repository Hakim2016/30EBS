
--IF80 info
--XXPA_COST_EXPORT_GCPM_PKG2;--.MAIN
/*
XXPAB008
XXPA_COST_GCPM_INT
XXPA:Project Cost Data Outbound
*/

SELECT *
  FROM xxpa_cost_gcpm_int xx
 WHERE 1 = 1
 AND xx.actual_month = to_date('2015-01-01','yyyy-mm-dd')
 AND xx.group_id <> 1327
 ORDER BY group_id DESC; -- AND
