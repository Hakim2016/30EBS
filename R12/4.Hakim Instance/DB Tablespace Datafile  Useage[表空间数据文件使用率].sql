-- datafile level
SELECT dt.tablespace_name,
       SUM(ddf.bytes / 1024 / 1024) over(PARTITION BY dt.tablespace_name) ts_total_size_mb,
       SUM(ddf.blocks) over(PARTITION BY dt.tablespace_name) ts_total_blocks,
       SUM(free.bytes / 1024 / 1024) over(PARTITION BY dt.tablespace_name) ts_free_size_mb,
       SUM(free.blocks) over(PARTITION BY dt.tablespace_name) ts_free_blocks,
       round((1 - --
             SUM(nvl(free.bytes, 0)) over(PARTITION BY dt.tablespace_name) / --
              SUM(nvl(ddf.bytes, 0)) over(PARTITION BY dt.tablespace_name)) * 100,
             2) "TS_USED_RATE(%)",
       NULL,
       ddf.file_id,
       ddf.bytes / 1024 / 1024 file_total_size_mb,
       ddf.blocks file_total_blocks,
       SUM(nvl(free.bytes, 0) / 1024 / 1024) over(PARTITION BY dt.tablespace_name, ddf.file_id) file_free_size_mb,
       SUM(nvl(free.blocks, 0)) over(PARTITION BY dt.tablespace_name, ddf.file_id) file_free_blocks,
       round((1 - --
             SUM(nvl(free.bytes, 0)) over(PARTITION BY dt.tablespace_name, ddf.file_id) / --
              SUM(nvl(ddf.bytes, 0)) over(PARTITION BY dt.tablespace_name, ddf.file_id)) * 100,
             2) "FILE_USED_RATE(%)",
       
       ddf.file_name
  FROM dba_tablespaces dt,
       dba_data_files ddf,
       (SELECT dfs.tablespace_name,
               dfs.file_id,
               SUM(dfs.bytes) bytes,
               SUM(dfs.blocks) blocks
          FROM dba_free_space dfs
         GROUP BY dfs.tablespace_name,
                  dfs.file_id) free
 WHERE 1 = 1
   AND dt.tablespace_name = ddf.tablespace_name
   AND ddf.file_id = free.file_id(+)
   AND ddf.tablespace_name = free.tablespace_name(+)
--AND dt.tablespace_name IN ( /*'APPS_TS_TX_IDX',*/ 'APPS_TS_TX_DATA')
 ORDER BY dt.tablespace_name,
          ddf.file_id;
