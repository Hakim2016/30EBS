/*
dba_free_space ��ʾ������free �ռ��tablespace �����һ��tablespace ��free �ռ䲻������
��ÿ��free�ռ䶼����dba_free_space�д���һ����¼�����һ��tablespace �кü�����¼��
˵����ռ������Ƭ���������ֵ����ı�ռ���Ƭ����500����Ҫ�Ա�ռ������Ƭ����
*/
SELECT tablespace_name,
       SUM(bytes) ���ֽ���,
       MIN(bytes),
       MAX(bytes),
       COUNT(*)
  FROM dba_free_space
 GROUP BY tablespace_name;

-- count����500 Ҫ����һ���� �Ƿ���Ҫ����

-- ����

SELECT a.tablespace_name,
       COUNT(1) ��Ƭ��
  FROM dba_free_space  a,
       dba_tablespaces b
 WHERE a.tablespace_name = b.tablespace_name
--AND b.extent_management = 'DICTIONARY'
 GROUP BY a.tablespace_name
HAVING COUNT(1) > 20
 ORDER BY 2;

-- ��ռ���Ƭ�����﷨��

ALTER tablespace [ tablespace_name ] coalesce;

-- ʣ���ռ�ٷֱ�

SELECT df.tablespace_name "��ռ���",
       totalspace "�ܿռ�M",
       freespace "ʣ��ռ�M",
       round((1 - freespace / totalspace) * 100, 2) "ʹ����%"
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

-- �ع���������

SELECT rn.name,
       rs.gets �����ʴ���,
       rs.waits �ȴ����˶ο�Ĵ���,
       (rs.waits / rs.gets) * 100 ������
  FROM v$rollstat rs,
       v$rollname rn;
