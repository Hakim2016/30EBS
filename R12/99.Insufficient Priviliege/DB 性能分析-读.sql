SELECT Disk_Reads DiskReads, Executions, SQL_ID, SQL_Text SQLText, 
   SQL_FullText SQLFullText 
FROM
(
   SELECT Disk_Reads, Executions, SQL_ID, LTRIM(SQL_Text) SQL_Text, 
      SQL_FullText, Operation, Options, 
      Row_Number() OVER 
         (Partition By sql_text ORDER BY Disk_Reads * Executions DESC) 
         KeepHighSQL
   FROM
   (
       SELECT Avg(Disk_Reads) OVER (Partition By sql_text) Disk_Reads, 
          Max(Executions) OVER (Partition By sql_text) Executions, 
          t.SQL_ID, sql_text, sql_fulltext, p.operation,p.options
       FROM v$sql t, v$sql_plan p
       WHERE t.hash_value=p.hash_value AND p.operation='TABLE ACCESS' 
       AND p.options='FULL' AND p.object_owner NOT IN ('SYS','SYSTEM')
       AND t.Executions > 1
   ) 
   ORDER BY DISK_READS * EXECUTIONS DESC
)
WHERE KeepHighSQL = 1
AND rownum <=5;
