SELECT *
  FROM fnd_new_messages fnm
 WHERE 1 = 1
   --AND fnm.message_name = 'XXINV_002E_043'
   AND fnm.message_text LIKE 
   'Transaction quantity must be greater than zero and not more than available quantity'
   --'Document sequence does not exist for the current document even though profile option Sequential Numbering is set to Partially Used.'
   --'%haven��t been invoiced fully%'
   --'%There are some lines without subinventory%'
   ;
