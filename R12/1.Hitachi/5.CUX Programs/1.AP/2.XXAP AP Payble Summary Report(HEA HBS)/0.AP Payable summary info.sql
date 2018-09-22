/*
XXAPAPSR
XXAP:AP Payble Summary Report(HEA/HBS)
XXAP_AP_PAYBLE_RPT_PKG.MAIN

*/

--INSERT INTO xxap.xxap_payable_summary_temp
SELECT rownum,
       v1.*
  FROM (SELECT v.*
          FROM xxap_payable_summary_v v
         WHERE 1 = 1
           --AND gl_date >= trunc(nvl(p_date_from, gl_date))
           --AND gl_date <= trunc(nvl(p_date_to, gl_date)) + 0.99999
         ORDER BY po_number ASC NULLS LAST) v1;
