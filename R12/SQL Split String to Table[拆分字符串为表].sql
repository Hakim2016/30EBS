-- 
SELECT substrb(original_parameters,
               instrb(original_parameters, ',', 1, rownum) + 1,
               instrb(original_parameters, ',', 1, rownum + 1) - instrb(original_parameters, ',', 1, rownum) - 1) AS spilit_value
  FROM (SELECT ',' || 'ÅË,a,Áúf' || ',' AS original_parameters
          FROM dual)
CONNECT BY instrb(original_parameters, ',', 2, rownum) > 0;

-- 
SELECT substr(original_parameters,
              instr(original_parameters, ',', 1, rownum) + 1,
              instr(original_parameters, ',', 1, rownum + 1) - instr(original_parameters, ',', 1, rownum) - 1) AS spilit_value
  FROM (SELECT ',' || 'ÅË,a,Áú' || ',' AS original_parameters
          FROM dual)
CONNECT BY instr(original_parameters, ',', 2, rownum) > 0;
