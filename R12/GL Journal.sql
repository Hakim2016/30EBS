SELECT gjh.name journal,
       gjh.description,
       gjh.*
  FROM gl_je_headers_v gjh
 WHERE 1 = 1
      --AND gjh.je_source = 'Manual'
      --AND gjh.ledger_id = 2041
   --AND gjh.je_header_id = 3115225
--AND gjh.period_name = 'DEC-17'
--AND gjh.description LIKE '%SG00050348*7%' --'%HS00101380HKM%'--
ORDER BY gjh.creation_date DESC
;

SELECT gjl.* --SUM(gjl.accounted_dr),SUM(gjl.accounted_cr)
  FROM gl_je_lines_v gjl
 WHERE 1 = 1
   AND gjl.segment3 = '1145400000'
   AND gjl.ledger_id = 2021
   AND gjl.period_name = 'NOV-18';

SELECT *
  FROM gl_je_headers_v gjh,
       gl_je_lines_v   gjl
 WHERE 1 = 1
   AND gjh.je_header_id = gjl.je_header_id
   AND gjh.je_header_id = 3115225;
