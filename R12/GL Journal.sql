SELECT gjh.name journal,
       gjh.description,
       gjh.*
  FROM gl_je_headers_v gjh
 WHERE 1 = 1
   AND gjh.description LIKE '%SG00050348*7%'--'%HS00101380HKM%'--
   ;
