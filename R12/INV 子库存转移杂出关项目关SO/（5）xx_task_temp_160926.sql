--backup data
CREATE TABLE xxinv.xxinv_task_temp_160926 AS
SELECT * FROM xxinv_task_temp t;

--cleare data
TRUNCATE TABLE apps.xxinv_task_temp;--清空表

--insert data
DECLARE
  l_return_status VARCHAR2(1);
  l_msg_data      VARCHAR2(2000);
  TYPE contacts_type IS TABLE OF xxinv_task_temp%ROWTYPE;
  v_contacts contacts_type;
  CURSOR all_contacts_cur IS
    SELECT p.project_id,
           p.task_id,
           'P',
           NULL
      FROM xxom_wf_projects_all p; --步骤第一步被清空，且导入新数据

  --cursor的字段数要与循环插入的表中的字段数一致且一一对应

BEGIN
  OPEN all_contacts_cur;

  LOOP
    FETCH all_contacts_cur BULK COLLECT
      INTO v_contacts LIMIT 256;
  
    FOR i IN 1 .. v_contacts.count
    LOOP
      INSERT INTO xxinv_task_temp--循环数据执行插入xxinv_task_temp
      VALUES v_contacts(i); 
    END LOOP;
    EXIT WHEN all_contacts_cur%NOTFOUND;
  END LOOP;
  CLOSE all_contacts_cur;

dbms_output.put_line('S');
EXCEPTION
  WHEN OTHERS THEN
    l_return_status := fnd_api.g_ret_sts_error;
    dbms_output.put_line(l_return_status);
    l_msg_data      := SQLERRM;
    dbms_output.put_line(l_msg_data);
END;

