--IF63 Scripts
/*
v0.01 02-oct-2018
1.customer_number
2.backup table 20181002
*/

--backup the wrong data
CREATE TABLE xxar_cust_to_hfg_20181002
AS
SELECT intf.*
  FROM xxar_cust_to_hfg_int intf
 WHERE 1 = 1
   AND intf.customer_number IN ('FB00000586')
 ORDER BY intf.customer_number;
 
--check the backup
SELECT * FROM xxar_cust_to_hfg_20181002 xx WHERE 1=1; 

--delete the wrong date

DELETE FROM xxar_cust_to_hfg_int intf
 WHERE 1 = 1
   AND intf.customer_number IN ('FB00000586');

--inform user to modify the data or change the last update date
UPDATE hz_cust_accounts hca
   SET hca.last_update_date = SYSDATE
 WHERE 1 = 1
   AND hca.account_number = 'FB00000586';
