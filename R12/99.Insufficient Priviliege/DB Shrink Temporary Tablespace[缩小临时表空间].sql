-- Oracle 11g has a new view called DBA_TEMP_FREE_SPACE that displays information about temporary tablespace usage.
SELECT *
  FROM dba_temp_free_space;

/*
TABLESPACE_NAME                TABLESPACE_SIZE ALLOCATED_SPACE FREE_SPACE
------------------------------ --------------- --------------- ----------
TEMP                                  56623104        56623104   55574528

1 row selected.
*/

-- Armed with this information, you can perform an online shrink of a temporary tablespace using the ALTER TABLESPACE command.
ALTER tablespace temp shrink space keep 40m;

SELECT *
  FROM dba_temp_free_space;

/*
TABLESPACE_NAME                TABLESPACE_SIZE ALLOCATED_SPACE FREE_SPACE
------------------------------ --------------- --------------- ----------
TEMP                                  42991616         1048576   41943040

1 row selected.
*/

-- The shrink can also be directed to a specific tempfile using the TEMPFILE clause.
ALTER tablespace temp shrink tempfile '/u01/app/oracle/oradata/DB11G/temp01.dbf' keep 30m;

SELECT *
  FROM dba_temp_free_space;
/*
TABLESPACE_NAME                TABLESPACE_SIZE ALLOCATED_SPACE FREE_SPACE
------------------------------ --------------- --------------- ----------
TEMP                                  31522816           65536   31457280

1 row selected.
*/

-- The KEEP clause specifies the minimum size of the tablespace or tempfile. If this is omitted, 
-- the database will shrink the tablespace or tempfile to the smallest possible size.
ALTER tablespace temp shrink space;

SELECT *
  FROM dba_temp_free_space;

/*
TABLESPACE_NAME                TABLESPACE_SIZE ALLOCATED_SPACE FREE_SPACE
------------------------------ --------------- --------------- ----------
TEMP                                   1114112           65536    1048576

1 row selected.
*/
