-- statistics
SELECT DISTINCT t.object_type,
                '''' || t.object_type || ''',',
                t.owner,
                COUNT(1) over(PARTITION BY t.owner, t.object_type),
                COUNT(1) over(PARTITION BY t.owner)
  FROM dba_objects t
 WHERE t.status IN ('INVALID')
 ORDER BY t.object_type;
 
-- compile method 1
SELECT decode(t.object_type,
              'PACKAGE BODY',
              'ALTER PACKAGE ' || t.owner || '.' || t.object_name || ' COMPILE BODY;',
              'TYPE BODY',
              'ALTER TYPE ' || t.owner || '.' || t.object_name || ' COMPILE BODY;',
              'JAVA CLASS',
              'ALTER ' || t.object_type || ' ' || t.owner || '."' || t.object_name || '" COMPILE;',
              'ALTER ' || t.object_type || ' ' || t.owner || '.' || t.object_name || ' COMPILE;') compile_command,
       COUNT(1) over(PARTITION BY t.owner, t.object_type) count_row,
       t.status,
       t.object_type,
       t.owner,
       t.object_name
  FROM dba_objects t
 WHERE t.status IN ('INVALID')
   AND t.object_type IN ('VIEW',
                         'PACKAGE',
                         'PACKAGE BODY',
                         'TYPE BODY',
                         'TRIGGER',
                         'MATERIALIZED VIEW',
                         'SYNONYM',
                         'VIEW',
                         'JAVA CLASS',
                         'FUNCTION',
                         'TYPE')
 ORDER BY decode(t.object_type, 'PACKAGE BODY', 100000, NULL) NULLS FIRST,
          COUNT(1) over(PARTITION BY t.owner, t.object_type),
          t.object_type;

-- compile method 2
-- note : used with caution , it is only usefull to small schema.
BEGIN
  dbms_utility.compile_schema('APPS');
END;
