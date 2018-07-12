/*
O
IF63
XXARB004
XXAR:Customer Outbound to HFG
XXAR_CUST_TO_HFG_INT
xxar_cust_to_hfg_pkg.hfg_main
*/

xxar_cust_to_hfg_pkg;--.hfg_main

SELECT * FROM XXAR_CUST_TO_HFG_INT intf
WHERE 1=1
ORDER BY intf.unique_id;
