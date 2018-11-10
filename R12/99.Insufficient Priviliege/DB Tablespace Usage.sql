SELECT t.*
  FROM (SELECT d.tablespace_name
              ,space "SUM_SPACE(M)"
               ,blocks sum_blocks
               ,space - nvl(free_space, 0) "USED_SPACE(M)"
               ,round((1 - nvl(free_space, 0) / space) * 100, 2) "USED_RATE(%)"
               ,free_space "FREE_SPACE(M)"
          FROM (SELECT tablespace_name
                      ,round(SUM(bytes) / (1024 * 1024), 2) space
                      ,SUM(blocks) blocks
                  FROM dba_data_files
                 GROUP BY tablespace_name) d
              ,(SELECT tablespace_name
                      ,round(SUM(bytes) / (1024 * 1024), 2) free_space
                  FROM dba_free_space
                 GROUP BY tablespace_name) f
         WHERE d.tablespace_name = f.tablespace_name(+)
        UNION ALL --if have tempfile
        SELECT d.tablespace_name
              ,space "SUM_SPACE(M)"
               ,blocks sum_blocks
               ,used_space "USED_SPACE(M)"
               ,round(nvl(used_space, 0) / space * 100, 2) "USED_RATE(%)"
               ,space - used_space "FREE_SPACE(M)"
          FROM (SELECT tablespace_name
                      ,round(SUM(bytes) / (1024 * 1024), 2) space
                      ,SUM(blocks) blocks
                  FROM dba_temp_files
                 GROUP BY tablespace_name) d
              ,(SELECT tablespace
                      ,round(SUM(blocks * 8192) / (1024 * 1024), 2) used_space
                  FROM v$sort_usage
                 GROUP BY tablespace) f
         WHERE d.tablespace_name = f.tablespace(+)) t
 ORDER BY "USED_RATE(%)" DESC;
