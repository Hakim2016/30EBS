/*==================================================
  Procedure Name:
    issue_out_proj_stock 
  Description:
    Do project issue under subinventories that have
    been marked as CLEANUP.

  ******************* WARNING **********************
    This procedure may empty all the availability re-
    lated to current project/task in subinventies 
    which is UNREVERSABLE or UNRECOVERABLE.
    Use it at your own risk. To enable this function,
    set profile XXINV_INV_PURGE_ENABLED as 'Y' at res-
    ponsibility level.
  **************************************************
  History:
    1.00    25-SEP-2012  hand   Creation
==================================================
alter table xxinv_task_temp add process_status varchar2(100);
alter table xxinv_task_temp add process_message varchar2(100);

select pt.task_number,t.* from xxinv_task_temp t ,pa_tasks pt
where t.process_status is not null
and t.task_id=pt.task_id;

select  fnd_profile.value('XXINV_USE_SO_COGS') from  dual;

select  fnd_profile.value('XXINV_MFG_PRJ_ISSUE') from dual;

select fnd_profile.value('INV_PROJ_MISC_TXN_EXP_TYPE') from dual;

select * from xxinv_transfer_todo_fcs t where t.rowid='AAEdRPAAjAAPPKTAAA';

*/

DECLARE

  x_return_status  VARCHAR2(10);
  x_return_message VARCHAR2(4000);
  x_msg_count      NUMBER;

  c_status_success CONSTANT VARCHAR2(1) := 'S';
  c_status_error   CONSTANT VARCHAR2(1) := 'E';
  c_status_pending CONSTANT VARCHAR2(1) := 'P';

  l_onhand_qty       NUMBER;
  l_processd_count   NUMBER;
  l_time_point_start NUMBER;
  g_sysdate          DATE := SYSDATE;
  l_project_num      VARCHAR2(100);

  l_exsits_flag VARCHAR2(100);

  CURSOR cur_line IS
    SELECT --t.project_id,
     pa.segment1,
     pa.project_id,
     pa.pm_product_code,
     t.rowid row_id
      FROM xxinv_task_temp    t,--前面已清空，并且已插入新数据
           pa_projects_all pa
     WHERE 1 = 1
     -- AND t.rowid = 'AAEcm6AAsAACrODAAC'
     -- AND ROWNUM<10
       AND t.project_id = pa.project_id
       AND nvl(t.process_status, c_status_pending) IN (c_status_pending, c_status_error);

  FUNCTION trim_en(p_var IN VARCHAR2) RETURN VARCHAR2 IS
    l_return VARCHAR2(4000);
  
  BEGIN
    l_return := REPLACE(p_var, chr(13), NULL);
    l_return := TRIM(l_return);
  
    RETURN l_return;
  END;

  FUNCTION dump_error_stack RETURN VARCHAR2 IS
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_msg_index_out NUMBER;
    x_msg_data      VARCHAR2(4000);
  BEGIN
    x_msg_data := NULL;
    fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
    FOR l_ind IN 1 .. l_msg_count
    LOOP
      fnd_msg_pub.get(p_msg_index     => l_ind,
                      p_encoded       => fnd_api.g_false,
                      p_data          => l_msg_data,
                      p_msg_index_out => l_msg_index_out);
    
      x_msg_data := ltrim(x_msg_data || ' ' || l_msg_data);
      IF lengthb(x_msg_data) > 1999 THEN
        x_msg_data := substrb(x_msg_data, 1, 1999);
        EXIT;
      END IF;
    END LOOP;
    RETURN x_msg_data;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Dump Error Message Error!';
  END dump_error_stack;

  -- ==============
  -- update project
  -- ==============
  PROCEDURE update_project(p_start_date      IN DATE,
                           p_end_date        IN DATE,
                           p_status          IN VARCHAR2,
                           p_project_id      IN NUMBER,
                           p_pm_product_code IN VARCHAR2,
                           x_return_status   OUT VARCHAR2,
                           x_msg_count       OUT NUMBER,
                           x_return_message  OUT VARCHAR2) IS
  
    l_responsibility_id NUMBER;
    l_user_id           NUMBER;
  
    l_workflow_started VARCHAR2(1);
   -- l_pm_product_code  VARCHAR2(100):='MSPROJECT';
    l_resp_id          NUMBER;
    l_appl_id          NUMBER;
    l_user_id          NUMBER := 2722;
  
    l_project_in       pa_project_pub.project_in_rec_type;
    l_project_out      pa_project_pub.project_out_rec_type;
    l_key_members      pa_project_pub.project_role_tbl_type;
    l_class_categories pa_project_pub.class_category_tbl_type;
  
    l_tasks_in  pa_project_pub.task_in_tbl_type;
    l_tasks_out pa_project_pub.task_out_tbl_type;
  
    l_return_status VARCHAR2(10);
  
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    
  /*  SELECT t.user_id
      INTO l_user_id
      FROM fnd_user t
     WHERE t.user_name = 'SYSADMIN';*/
    
     fnd_global.apps_initialize(user_id => 2761, resp_id => 50778, resp_appl_id => 20005);
     mo_global.init('PA');

  
/*    SELECT fr.responsibility_id,
           fr.application_id
      INTO l_resp_id,
           l_appl_id
      FROM fnd_responsibility_tl fr
     WHERE fr.responsibility_name = 'SHE PA Super User'
       AND fr.language = 'US';
  
    pa_interface_utils_pub.set_global_info(p_api_version_number => 1.0,
                                           p_responsibility_id  => l_resp_id,
                                           p_user_id            => l_user_id,
                                           p_msg_count          => x_msg_count,
                                           p_msg_data           => x_return_message,
                                           p_return_status      => l_return_status);
  
    IF (l_return_status <> 'S') THEN
      x_return_status  := 'E';
      x_return_message := dump_error_stack || dbms_utility.format_error_backtrace;
      RETURN;
    END IF;*/
    l_project_in.pa_project_id        := p_project_id;
    --l_project_in.pm_project_reference := p_project_num;
    l_project_in.project_status_code  := p_status;
    --l_project_in.completion_date      := p_end_date;
  
    pa_project_pub.update_project(p_api_version_number => 1.0,
                                  p_commit             => 'F',
                                  p_init_msg_list      => 'T',
                                  p_msg_count          => x_msg_count,
                                  p_msg_data           => x_return_message,
                                  p_return_status      => l_return_status,
                                  p_workflow_started   => l_workflow_started,
                                  p_pm_product_code    => p_pm_product_code,
                                  p_project_in         => l_project_in,
                                  p_project_out        => l_project_out,
                                  p_key_members        => l_key_members,
                                  p_class_categories   => l_class_categories,
                                  p_tasks_in           => l_tasks_in,
                                  p_tasks_out          => l_tasks_out);
  
    IF (l_return_status <> 'S') THEN
      x_return_status  := 'E';
      x_return_message := dump_error_stack || dbms_utility.format_error_backtrace;
    END IF;
  
  END update_project;

BEGIN

  l_processd_count   := 0;
  l_time_point_start := dbms_utility.get_time;

  --


 -- fnd_msg_pub.initialize;

  FOR rec IN cur_line
  LOOP
    l_processd_count := l_processd_count + 1;
  
    BEGIN
      SELECT 'Y'
        INTO l_exsits_flag
        FROM pa_projects_all pa
       WHERE pa.project_id = rec.project_id
         AND pa.project_status_code = 'CLOSED';
    EXCEPTION
      WHEN no_data_found THEN
        l_exsits_flag := 'N';
    END;
  
    IF l_exsits_flag = 'Y' THEN
      x_return_status  := c_status_error;
      x_return_message := '已经关闭';
      GOTO next_record;
    
    END IF;
  
    -- constant
  
    dbms_output.put_line('rec.project_id:' || rec.project_id);
    dbms_output.put_line('rec.pm_product_code:' || rec.pm_product_code);
  
    update_project(p_start_date     => NULL,
                   p_end_date       => g_sysdate,
                   p_status         => 'CLOSED',
                   p_project_id     => rec.project_id, --to_number(trim_en(rec.project_id)),
                   p_pm_product_code => rec.pm_product_code,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_return_message => x_return_message);
  
    IF x_return_status <> 'S' THEN
      x_return_message := x_return_message;
      x_return_status  := c_status_error;
    ELSE
      x_return_status  := c_status_success;
      x_return_message := x_return_message;
    END IF;
    GOTO next_record;
  
    <<next_record>>
  
    UPDATE xxinv_task_temp t
       SET t.process_status  = x_return_status,
           t.process_message = x_return_message || to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss')
     WHERE 1 = 1
       AND t.rowid = rec.row_id;
  
    IF MOD(l_processd_count, 100) = 0 THEN
      COMMIT;
    END IF;
    IF MOD(l_processd_count, 500) = 0 THEN
      dbms_output.put_line(l_processd_count || ' rows have been processed. Time-Consuming : ' ||
                           (dbms_utility.get_time - l_time_point_start) / 100);
    END IF;
  END LOOP;

  IF l_processd_count > 0 THEN
    COMMIT;
  END IF;

  dbms_output.put_line(' l_processd_count : ' || l_processd_count);
  dbms_output.put_line('Time-Consuming : ' || (dbms_utility.get_time - l_time_point_start) / 100);

END;
