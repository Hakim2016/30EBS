
-- *********************************************************
-- �� Flashback query(���ز�ѯ)ԭ��
--  Oracle����undo��Ϣ������undo���ݣ�����һ���Զ�ȡ���������԰ѱ�����һ��ɾ��ǰ��ʱ���(��SCN)���Ӷ��������һء�

-- Flashback query(���ز�ѯ)ǰ��
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

-- ����undo_management = auto�������Զ�undo����AUM�����ò���Ĭ������Ϊ��auto��
-- Undo_retention = n(��),���þ���undo���ı���ʱ�䣬��ֵԽ�󣬾���ҪԽ���undo��ռ��֧�֡��޸�undo_retention���������£�
alter system set undo_retention = 900;

-- *********************************************************
-- ����ʵ�ַ�ʽ
-- 1.��ȡ����ɾ��ǰ��һ��ʱ����scn������
select to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss') time, to_char(dbms_flashback.get_system_change_number) scn from dual;
/*
TIME                    SCN
2010-06-29 23:03:14     1060499
*/

-- 2.��ѯ��ʱ��㣨��scn�������ݣ����£�
select * from t as of timestamp to_timestamp('2010-06-29 22:57:47', 'yyyy-mm-dd hh24:mi:ss');
select * from t as of scn 1060174;
SELECT * FROM oe_order_lines_all AS OF TIMESTAMP(systimestamp - INTERVAL '2' DAY); 
--�������ʹ��DAY��SECOND��MONTH ��minute 

-- ����ѯ�������ݣ����������С�Ҳ���ø�ֱ�ӵķ������磺
create table tab_test as 
select * from t of timestamp to_timestamp('2010-06-29 22:57:47', 'yyyy-mm-dd hh24:mi:ss');


/*
Falshback query��ѯ�ľ��ޣ�
1�� ����Falshback��5����ǰ�����ݡ�
2�� ���ز�ѯ�޷��ָ�����ṹ�ı�֮ǰ����Ϊ���ز�ѯʹ�õ��ǵ�ǰ�������ֵ䡣
3�� �ܵ�undo_retention������Ӱ�죬����undo_retention֮ǰ�����ݣ�Flashback����֤��Flashback�ɹ���
4�� ��drop,truncate�Ȳ���¼�ع��Ĳ��������ָܻ���
5�� ��ͨ�û�ʹ��dbms_flashback��������ͨ������Ա��Ȩ����������:
grant execute on dbms_flashback to scott;
*/
