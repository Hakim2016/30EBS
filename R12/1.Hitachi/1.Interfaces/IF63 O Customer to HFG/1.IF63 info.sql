/*
O
IF63
XXARB004
XXAR:Customer Outbound to HFG
XXAR_CUST_TO_HFG_INT
xxar_cust_to_hfg_pkg.hfg_main
*/

--xxar_cust_to_hfg_pkg;--.hfg_main

SELECT intf.request_id,
       intf.customer_number,
       intf.branch_code,
       intf.postal_code,
       --LENGTH(intf.postal_code),
       intf.creation_date,
       intf.interface_file_name,
       intf.recon_account,
       intf.*
--* 
  FROM xxar_cust_to_hfg_int intf
 WHERE 1 = 1
 --AND intf.name2 LIKE '%NIRLON%'
   AND intf.customer_number 
   LIKE 'HL%27'
    /*IN
     ('HL00000027')*/
   --('HL00000027')
   --('FB00000592','FB00000593')
   --('HL00000020')
   --('FB00000586')
   --('FB00000582')
   --('FB00000575', 'FB00000580', 'FB00000581','FB00000586')
--= 'FB00000575'
--AND LENGTH(intf.postal_code) = 5
 ORDER BY intf.unique_id DESC,
          intf.customer_number;
