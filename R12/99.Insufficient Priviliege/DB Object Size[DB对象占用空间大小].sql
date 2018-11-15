-- 更准确
SELECT ds.owner,
       ds.segment_name,
       ds.segment_type,
       ds.partition_name,
       round(ds.bytes / (1024 * 1024), 2) size_mb,
       ds.tablespace_name
  FROM dba_segments ds
 WHERE 1 = 1
   AND ds.segment_name IN ('FND_LOG_MESSAGES', 'WF_ITEM_ACTIVITY_STATUSES_H', 'FND_LOBS');

-- 定期收集信息
SELECT dt.owner,
       dt.table_name,
       dt.tablespace_name,
       dt.status,
       dt.num_rows,
       dt.blocks,
       dt.blocks * 8 / 1024
  FROM dba_tables dt
 WHERE 1 = 1
   AND dt.table_name IN ('FND_LOG_MESSAGES', 'WF_ITEM_ACTIVITY_STATUSES_H', 'FND_LOBS');
