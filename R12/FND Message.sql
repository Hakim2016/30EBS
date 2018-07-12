SELECT *
  FROM fnd_new_messages fnm
 WHERE 1 = 1
   --AND fnm.message_name = 'XXINV_002E_043'
   AND fnm.message_text LIKE 
   '%haven¡¯t been invoiced fully%'
   --'%There are some lines without subinventory%'
   ;
