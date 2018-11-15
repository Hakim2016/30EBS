
-- *********************************************************
-- ※ Flashback query(闪回查询)原理
--  Oracle根据undo信息，利用undo数据，类似一致性读取方法，可以把表置于一个删除前的时间点(或SCN)，从而将数据找回。

-- Flashback query(闪回查询)前提
SELECT *
  FROM v$parameter vp
 WHERE 1 = 1
   AND vp.name LIKE 'undo%';
/*   
NUM  NAME  TYPE  VALUE  DISPLAY_VALUE  ISDEFAULT  ISSES_MODIFIABLE  ISSYS_MODIFIABLE  ISINSTANCE_MODIFIABLE  ISMODIFIED  ISADJUSTED  ISDEPRECATED  ISBASIC  DESCRIPTION  UPDATE_COMMENT  HASH
1335  undo_management  2  AUTO  AUTO  FALSE  FALSE  FALSE  FALSE  FALSE  FALSE  FALSE  FALSE  instance runs in SMU mode if TRUE, else in RBU mode   Required 11i setting  1401409411
1336  undo_tablespace  2  APPS_UNDOTS1  APPS_UNDOTS1  FALSE  FALSE  IMMEDIATE	TRUE	FALSE	FALSE	FALSE	TRUE	use/switch undo tablespace	 Required 11i setting	2692150816
1353	undo_retention	3	900	900	TRUE	FALSE	IMMEDIATE	TRUE	FALSE	FALSE	FALSE	FALSE	undo retention in seconds		3327480172
*/

-- 其中undo_management = auto，设置自动undo管理（AUM），该参数默认设置为：auto；
-- Undo_retention = n(秒),设置决定undo最多的保存时间，其值越大，就需要越多的undo表空间的支持。修改undo_retention的命令如下：
alter system set undo_retention = 900;

-- *********************************************************
-- 闪回实现方式
-- 1.获取数据删除前的一个时间点或scn，如下
select to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss') time, to_char(dbms_flashback.get_system_change_number) scn from dual;
/*
TIME                    SCN
2010-06-29 23:03:14     1060499
*/

-- 2.查询该时间点（或scn）的数据，如下：
select * from t as of timestamp to_timestamp('2010-06-29 22:57:47', 'yyyy-mm-dd hh24:mi:ss');
select * from t as of scn 1060174;
SELECT * FROM oe_order_lines_all AS OF TIMESTAMP(systimestamp - INTERVAL '2' DAY); 
--这里可以使用DAY、SECOND、MONTH 、minute 

-- 将查询到的数据，新增到表中。也可用更直接的方法，如：
create table tab_test as 
select * from t of timestamp to_timestamp('2010-06-29 22:57:47', 'yyyy-mm-dd hh24:mi:ss');


/*
Falshback query查询的局限：
1． 不能Falshback到5天以前的数据。
2． 闪回查询无法恢复到表结构改变之前，因为闪回查询使用的是当前的数据字典。
3． 受到undo_retention参数的影响，对于undo_retention之前的数据，Flashback不保证能Flashback成功。
4． 对drop,truncate等不记录回滚的操作，不能恢复。
5． 普通用户使用dbms_flashback包，必须通过管理员授权。命令如下:
grant execute on dbms_flashback to scott;
*/
