/*
IF20
XXOMB003
XXOM_CUSTOMER_INT
xxom_customer_outbound_pkg.goe_main
XXOM:Customer Information Outbound-GOE
*/

SELECT xx.creation_date,xx.*
  FROM xxom_customer_int xx
 WHERE 1 = 1
   AND xx.customer_number = 'HL00000192';
