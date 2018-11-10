/*
dba_free_space 显示的是有free 空间的tablespace ，如果一个tablespace 的free 空间不连续，
那每段free空间都会在dba_free_space中存在一条记录。如果一个tablespace 有好几条记录，
说明表空间存在碎片，当采用字典管理的表空间碎片超过500就需要对表空间进行碎片整理。
*/
SELECT tablespace_name,
       SUM(bytes) 总字节数,
       MIN(bytes),
       MAX(bytes),
       COUNT(*)
  FROM dba_free_space
 GROUP BY tablespace_name;

-- count大于500 要考虑一下了 是否需要整理

-- 或者

SELECT a.tablespace_name,
       COUNT(1) 碎片量
  FROM dba_free_space  a,
       dba_tablespaces b
 WHERE a.tablespace_name = b.tablespace_name
--AND b.extent_management = 'DICTIONARY'
 GROUP BY a.tablespace_name
HAVING COUNT(1) > 20
 ORDER BY 2;

-- 表空间碎片整理语法：

ALTER tablespace [ tablespace_name ] coalesce;

-- 剩余表空间百分比

SELECT df.tablespace_name "表空间名",
       totalspace "总空间M",
       freespace "剩余空间M",
       round((1 - freespace / totalspace) * 100, 2) "使用率%"
  FROM (SELECT tablespace_name,
               round(SUM(bytes) / 1024 / 1024) totalspace
          FROM dba_data_files
         GROUP BY tablespace_name) df,
       (SELECT tablespace_name,
               round(SUM(bytes) / 1024 / 1024) freespace
          FROM dba_free_space
         GROUP BY tablespace_name) fs
 WHERE df.tablespace_name = fs.tablespace_name
 ORDER BY 1;

-- 回滚段命中率

SELECT rn.name,
       rs.gets 被访问次数,
       rs.waits 等待回退段块的次数,
       (rs.waits / rs.gets) * 100 命中率
  FROM v$rollstat rs,
       v$rollname rn;
