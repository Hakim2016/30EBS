/*
IF70
HFG-->GSCM
XXOM:Customer Interface HFG (MK TO GSCM)
XXOM_CUSTOMER_MK_HFG_INTF


XXOMB009
xxom_customer_mk_intf_hfg_pkg.main
*/

--xxom_customer_mk_intf_hfg_pkg;--.main

SELECT *
  FROM xxom_customer_mk_hfg_intf xx
 WHERE 1 = 1
AND xx.process_status = 'E'
   AND xx.creation_date >= SYSDATE - 15;
