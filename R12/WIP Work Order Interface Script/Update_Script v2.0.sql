/*
select * from xxwip.xxwip_wo_update_datafix t for update;

delete wip_job_schedule_interface t where t.group_id = 12345;
delete wip_job_dtls_interface t where t.group_id = 12345;

SELECT *
  FROM wip_job_schedule_interface t -- FOR UPDATE
 WHERE t.group_id = 12345;

SELECT *
  FROM wip_job_dtls_interface -- FOR UPDATE
;
*/
DECLARE
  c_yes_flag       CONSTANT VARCHAR2(1) := 'Y';
  c_no_flag        CONSTANT VARCHAR2(1) := 'N';
  c_status_no      CONSTANT VARCHAR2(1) := 'N';
  c_status_pending CONSTANT VARCHAR2(1) := 'P';
  c_status_error   CONSTANT VARCHAR2(1) := 'E';
  c_status_success CONSTANT VARCHAR2(1) := 'S';
  g_user_id         NUMBER;
  g_group_id        NUMBER;
  g_delete_group_id NUMBER;
  l_request_id      NUMBER;
  l_count           NUMBER;

  PROCEDURE proc_validate IS
    CURSOR cur_validate IS
      SELECT t.rowid                row_id,
             t.organization_code    organization_code,
             t.wip_entity_name      wip_entity_name,
             t.operation_seq_num    operation_seq_num,
             t.department_code      department_code,
             t.resource_seq_num     resource_seq_num,
             t.resource_code        resource_code,
             t.count_point_type,
             t.backflush_flag,
             t.usage_rate_or_amount,
             t.basis_type,
             t.scheduled,
             t.autocharge_meaning,
             t.opr_exists_flag,
             t.res_exists_flag,
             t.group_id,
             t.header_id,
             t.organization_id,
             t.wip_entity_id,
             t.department_id,
             t.resource_id_new,
             t.resource_id_old,
             t.assigned_units,
             t.autocharge_type,
             t.process_status,
             t.process_date,
             t.process_message
        FROM xxwip.xxwip_wo_update_datafix t
       WHERE 1 = 1
         AND nvl(t.process_status, c_status_no) = c_status_no;
  
    l_count NUMBER;
  BEGIN
    -- validate
    FOR rec_validate IN cur_validate
    LOOP
      rec_validate.process_status := c_status_pending;
      -- multi
      BEGIN
      
        SELECT c_status_error,
               rec_validate.process_message || '[ ' || 'this work order , operation , resource duplicate' || ' ]'
          INTO rec_validate.process_status,
               rec_validate.process_message
          FROM xxwip.xxwip_wo_update_datafix t
         WHERE 1 = 1
           AND t.rowid <> rec_validate.row_id
           AND t.organization_code = rec_validate.organization_code
           AND t.wip_entity_name = rec_validate.wip_entity_name
           AND t.operation_seq_num = rec_validate.operation_seq_num
           AND nvl(t.resource_seq_num, -1) = nvl(rec_validate.resource_seq_num, -1)
              -- AND nvl(t.process_status, c_status_no) = c_status_no
           AND rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      -- organization
      IF rec_validate.organization_code IS NULL THEN
        rec_validate.process_status  := c_status_error;
        rec_validate.process_message := rec_validate.process_message || '[ ' || 'Organization is null' || ' ]';
      ELSE
        BEGIN
          SELECT ood.organization_id
            INTO rec_validate.organization_id
            FROM org_organization_definitions ood
           WHERE 1 = 1
             AND ood.organization_code = rec_validate.organization_code;
        EXCEPTION
          WHEN OTHERS THEN
            rec_validate.process_status  := c_status_error;
            rec_validate.process_message := rec_validate.process_message || '[ ' || 'Organization is invalid' || ' ]';
        END;
      END IF;
      -- work order
      IF rec_validate.wip_entity_name IS NULL THEN
        rec_validate.process_status  := c_status_error;
        rec_validate.process_message := rec_validate.process_message || '[ ' || 'Work Order is null' || ' ]';
      ELSE
        BEGIN
          SELECT we.wip_entity_id
            INTO rec_validate.wip_entity_id
            FROM wip_entities we
           WHERE 1 = 1
             AND we.organization_id = rec_validate.organization_id
             AND we.wip_entity_name = rec_validate.wip_entity_name;
        EXCEPTION
          WHEN OTHERS THEN
            rec_validate.process_status  := c_status_error;
            rec_validate.process_message := rec_validate.process_message || '[ ' || 'Work Order is invalid' || ' ]';
        END;
      END IF;
      -- OPERATION_SEQ_NUM
      IF rec_validate.operation_seq_num IS NULL THEN
        rec_validate.process_status  := c_status_error;
        rec_validate.process_message := rec_validate.process_message || '[ ' || 'Operation seq num is null' || ' ]';
      ELSE
        SELECT COUNT(1)
          INTO l_count
          FROM wip_operations wo
         WHERE 1 = 1
           AND wo.wip_entity_id = rec_validate.wip_entity_id
           AND wo.operation_seq_num = rec_validate.operation_seq_num;
        IF l_count > 0 THEN
          rec_validate.opr_exists_flag := c_yes_flag;
        ELSE
          rec_validate.opr_exists_flag := c_no_flag;
        END IF;
      END IF;
      -- DEPARTMENT_CODE
      IF rec_validate.department_code IS NULL THEN
        rec_validate.process_status  := c_status_error;
        rec_validate.process_message := rec_validate.process_message || '[ ' || 'Department is null' || ' ]';
      ELSE
        BEGIN
          SELECT bd.department_id
            INTO rec_validate.department_id
            FROM bom_departments bd
           WHERE 1 = 1
             AND bd.organization_id = rec_validate.organization_id
             AND bd.department_code = rec_validate.department_code;
        EXCEPTION
          WHEN OTHERS THEN
            rec_validate.process_status  := c_status_error;
            rec_validate.process_message := rec_validate.process_message || '[ ' || 'Department is invalid' || ' ]';
        END;
      END IF;
      -- RESOURCE_SEQ_NUM 
      IF rec_validate.resource_seq_num IS NOT NULL THEN
        SELECT COUNT(1)
          INTO l_count
          FROM wip_operation_resources wor
         WHERE 1 = 1
           AND wor.wip_entity_id = rec_validate.wip_entity_id
           AND wor.operation_seq_num = rec_validate.operation_seq_num
           AND wor.resource_seq_num = rec_validate.resource_seq_num;
        IF l_count > 0 THEN
          rec_validate.res_exists_flag := c_yes_flag;
          SELECT wor.resource_id /*,
                                     wor.assigned_units,
                                     wor.autocharge_type,
                                     wor.usage_rate_or_amount*/
            INTO rec_validate.resource_id_old /*,
                                     rec_validate.assigned_units,
                                     rec_validate.autocharge_type,
                                     rec_validate.usage_rate_or_amount*/
            FROM wip_operation_resources wor
           WHERE 1 = 1
             AND wor.wip_entity_id = rec_validate.wip_entity_id
             AND wor.operation_seq_num = rec_validate.operation_seq_num
             AND wor.resource_seq_num = rec_validate.resource_seq_num;
        ELSE
          rec_validate.res_exists_flag := c_no_flag;
        END IF;
      
        -- RESOURCE_CODE
        IF rec_validate.resource_code IS NULL THEN
          rec_validate.process_status  := c_status_error;
          rec_validate.process_message := rec_validate.process_message || '[ ' || 'Resource Code is null' || ' ]';
        ELSE
          BEGIN
            /*SELECT br.resource_id
             INTO rec_validate.resource_id_new
             FROM bom_resources br
            WHERE 1 = 1
              AND br.organization_id = rec_validate.organization_id
              AND br.resource_code = rec_validate.resource_code;*/
          
            SELECT res.resource_id
              INTO rec_validate.resource_id_new
              FROM cst_activities           cst,
                   mtl_uom_conversions      muc,
                   bom_resources            res,
                   bom_department_resources bdr,
                   mfg_lookups              lup
             WHERE res.organization_id = rec_validate.organization_id
               AND nvl(res.disable_date, SYSDATE + 2) > SYSDATE
               AND res.resource_id = bdr.resource_id
               AND bdr.department_id = rec_validate.department_id
               AND res.resource_code = rec_validate.resource_code
               AND res.default_activity_id = cst.activity_id(+)
               AND nvl(cst.organization_id(+), rec_validate.organization_id) = rec_validate.organization_id
               AND nvl(cst.disable_date(+), SYSDATE + 2) > SYSDATE
               AND res.unit_of_measure = muc.uom_code
               AND muc.inventory_item_id = 0
               AND lookup_type = 'BOM_AUTOCHARGE_TYPE'
               AND lookup_code = nvl(res.autocharge_type, 1);
          EXCEPTION
            WHEN OTHERS THEN
              rec_validate.process_status  := c_status_error;
              rec_validate.process_message := rec_validate.process_message || '[ ' || 'Resource Code is invalid' || ' ]';
          END;
        END IF;
      
        -- AUTOCHARGE
        BEGIN
          SELECT mfl.lookup_code
            INTO rec_validate.autocharge_type
            FROM mfg_lookups mfl
           WHERE mfl.lookup_type = 'BOM_AUTOCHARGE_TYPE'
             AND upper(mfl.meaning) = upper(rec_validate.autocharge_meaning);
        EXCEPTION
          WHEN OTHERS THEN
            rec_validate.process_status  := c_status_error;
            rec_validate.process_message := rec_validate.process_message || '[ ' || 'AUTOCHARGE is invalid' || ' ]';
        END;
        -- Scheduled
        IF nvl(rec_validate.scheduled, 1) NOT IN (1, 2) THEN
          rec_validate.process_status  := c_status_error;
          rec_validate.process_message := rec_validate.process_message || '[ ' || 'Scheduled is invalid' || ' ]';
        ELSE
          rec_validate.scheduled := nvl(rec_validate.scheduled, 1);
        END IF;
      END IF;
    
      /*IF rec_validate.opr_exists_flag = c_no_flag THEN
        rec_validate.count_point_type := nvl(rec_validate.count_point_type, 1);
        rec_validate.backflush_flag   := nvl(rec_validate.backflush_flag, 1);
      END IF;
      
      IF rec_validate.res_exists_flag = c_no_flag THEN
        rec_validate.assigned_units       := nvl(rec_validate.assigned_units, 1);
        rec_validate.autocharge_type      := nvl(rec_validate.autocharge_type, 2);
        rec_validate.usage_rate_or_amount := nvl(rec_validate.usage_rate_or_amount, 0);
      END IF;*/
    
      rec_validate.count_point_type     := nvl(rec_validate.count_point_type, 1);
      rec_validate.backflush_flag       := nvl(rec_validate.backflush_flag, 1);
      rec_validate.assigned_units       := nvl(rec_validate.assigned_units, 1);
      rec_validate.autocharge_type      := nvl(rec_validate.autocharge_type, 2);
      rec_validate.usage_rate_or_amount := nvl(rec_validate.usage_rate_or_amount, 0);
    
      UPDATE xxwip.xxwip_wo_update_datafix t
         SET t.opr_exists_flag      = rec_validate.opr_exists_flag,
             t.res_exists_flag      = rec_validate.res_exists_flag,
             t.group_id             = rec_validate.group_id,
             t.header_id            = rec_validate.header_id,
             t.organization_id      = rec_validate.organization_id,
             t.wip_entity_id        = rec_validate.wip_entity_id,
             t.department_id        = rec_validate.department_id,
             t.count_point_type     = rec_validate.count_point_type,
             t.backflush_flag       = rec_validate.backflush_flag,
             t.resource_id_new      = rec_validate.resource_id_new,
             t.resource_id_old      = rec_validate.resource_id_old,
             t.usage_rate_or_amount = rec_validate.usage_rate_or_amount,
             t.assigned_units       = rec_validate.assigned_units,
             t.autocharge_type      = rec_validate.autocharge_type,
             t.process_status       = rec_validate.process_status,
             t.process_date         = SYSDATE,
             t.process_message      = rec_validate.process_message
       WHERE 1 = 1
         AND t.rowid = rec_validate.row_id;
    END LOOP;
  END proc_validate;

  -- process backup
  PROCEDURE proc_backup IS
  
  BEGIN
    -- operation
    INSERT INTO xxwip.xxwip_operations_bk150612
      SELECT *
        FROM wip_operations wo
       WHERE 1 = 1
         AND wo.wip_entity_id IN (SELECT t.wip_entity_id
                                    FROM xxwip.xxwip_wo_update_datafix t
                                   WHERE 1 = 1
                                     AND nvl(t.process_status, c_status_no) = c_status_pending);
    -- resource
    INSERT INTO xxwip.xxwip_resources_bk150612
      SELECT *
        FROM wip_operation_resources wor
       WHERE 1 = 1
         AND (wor.wip_entity_id) IN
             (SELECT t.wip_entity_id
                FROM xxwip.xxwip_wo_update_datafix t
               WHERE 1 = 1
                 AND nvl(t.process_status, c_status_no) = c_status_pending);
  
  END proc_backup;

  -- process delete resource
  PROCEDURE proc_delete_res IS
    CURSOR cur_wo IS
      SELECT DISTINCT t.organization_id,
                      t.wip_entity_id,
                      wdj.scheduled_start_date,
                      wdj.scheduled_completion_date
        FROM xxwip.xxwip_wo_update_datafix t,
             wip_discrete_jobs             wdj
       WHERE 1 = 1
         AND t.wip_entity_id = wdj.wip_entity_id
         AND nvl(t.process_status, c_status_no) = c_status_pending;
  
    CURSOR cur_res(p_cur_wip_entity_id IN NUMBER) IS
      SELECT wor.organization_id,
             wor.wip_entity_id,
             wor.operation_seq_num,
             wor.resource_seq_num,
             wor.resource_id
        FROM wip_operation_resources wor
       WHERE 1 = 1
         AND wor.wip_entity_id = p_cur_wip_entity_id
            -- AND wor.operation_seq_num = p_cur_operation_seq_num
         AND EXISTS (SELECT 1
                FROM xxwip.xxwip_wo_update_datafix t
               WHERE wor.wip_entity_id = t.wip_entity_id
                 AND wor.operation_seq_num = t.operation_seq_num
                 AND nvl(t.process_status, c_status_no) = c_status_pending);
  
    l_job_int wip_job_schedule_interface%ROWTYPE;
    l_res_int wip_job_dtls_interface%ROWTYPE;
  BEGIN
    FOR rec_wo IN cur_wo
    LOOP
      l_job_int := NULL;
      SELECT wip_job_schedule_interface_s.nextval
        INTO l_job_int.header_id
        FROM dual;
      l_job_int.last_update_date           := SYSDATE;
      l_job_int.last_updated_by            := g_user_id;
      l_job_int.creation_date              := SYSDATE;
      l_job_int.created_by                 := g_user_id;
      l_job_int.last_update_login          := -1;
      l_job_int.group_id                   := g_delete_group_id;
      l_job_int.organization_id            := rec_wo.organization_id;
      l_job_int.load_type                  := 3; -- 1 Create Standard Discrete Job /2 Create Pending Repetitive Schedule /3 Update Standard or Non-Standard Discrete Job /4 Create Non-Standard Discrete Job
      l_job_int.wip_entity_id              := rec_wo.wip_entity_id;
      l_job_int.process_phase              := 2; --2. validation, 3. EXPLOSION, 4. COMPLETION, 5. CREATION
      l_job_int.process_status             := 1; --1. pending 2. running, 3. error 4. complete 5. warning
      l_job_int.allow_explosion            := 'N';
      l_job_int.first_unit_start_date      := rec_wo.scheduled_start_date;
      l_job_int.first_unit_completion_date := rec_wo.scheduled_completion_date;
      l_job_int.scheduling_method          := 3; --scheduling method 1- Routing based; 2- Lead Time; 3- Manual
      l_job_int.last_unit_start_date       := rec_wo.scheduled_start_date;
      l_job_int.last_unit_completion_date  := rec_wo.scheduled_completion_date;
    
      INSERT INTO wip_job_schedule_interface
      VALUES l_job_int;
      FOR rec_res IN cur_res(p_cur_wip_entity_id => l_job_int.wip_entity_id)
      LOOP
        l_res_int                   := NULL;
        l_res_int.last_update_date  := SYSDATE;
        l_res_int.last_updated_by   := g_user_id;
        l_res_int.creation_date     := SYSDATE;
        l_res_int.created_by        := g_user_id;
        l_res_int.group_id          := l_job_int.group_id;
        l_res_int.parent_header_id  := l_job_int.header_id;
        l_res_int.organization_id   := rec_res.organization_id;
        l_res_int.operation_seq_num := rec_res.operation_seq_num;
        l_res_int.resource_seq_num  := rec_res.resource_seq_num;
        l_res_int.resource_id_old   := rec_res.resource_id;
        l_res_int.load_type         := 1; --load_type 1. resource 2. component 3. operation 4. multiple resource usage
        l_res_int.substitution_type := 1; --substitution_type  1.Delete, 2.Add 3.Change
        l_res_int.process_phase     := 2; --process_phase
        l_res_int.process_status    := 1; -- process_status
        INSERT INTO wip_job_dtls_interface
        VALUES l_res_int;
      END LOOP;
    END LOOP;
  
  END proc_delete_res;

  -- process
  PROCEDURE process IS
  
    CURSOR cur_wo IS
      SELECT DISTINCT t.organization_id,
                      t.wip_entity_id,
                      wdj.scheduled_start_date,
                      wdj.scheduled_completion_date
        FROM xxwip.xxwip_wo_update_datafix t,
             wip_discrete_jobs             wdj
       WHERE 1 = 1
         AND t.wip_entity_id = wdj.wip_entity_id
         AND nvl(t.process_status, c_status_no) = c_status_pending;
  
    CURSOR cur_opr(p_cur_wip_entity_id IN NUMBER) IS
      SELECT DISTINCT t.opr_exists_flag,
                      t.organization_id,
                      t.wip_entity_id,
                      t.operation_seq_num,
                      t.department_code,
                      t.department_id,
                      t.count_point_type,
                      t.backflush_flag
        FROM xxwip.xxwip_wo_update_datafix t
       WHERE 1 = 1
         AND t.wip_entity_id = p_cur_wip_entity_id
         AND nvl(t.process_status, c_status_no) = c_status_pending;
  
    CURSOR cur_res(p_cur_wip_entity_id     IN NUMBER,
                   p_cur_operation_seq_num IN NUMBER) IS
      SELECT t.res_exists_flag,
             t.organization_id,
             t.wip_entity_id,
             t.operation_seq_num,
             t.resource_seq_num,
             t.resource_code,
             t.resource_id_new,
             t.resource_id_old,
             t.usage_rate_or_amount,
             t.assigned_units,
             t.autocharge_type,
             t.basis_type,
             t.scheduled
        FROM xxwip.xxwip_wo_update_datafix t
       WHERE 1 = 1
         AND t.resource_seq_num IS NOT NULL
         AND t.wip_entity_id = p_cur_wip_entity_id
         AND t.operation_seq_num = p_cur_operation_seq_num
         AND nvl(t.process_status, c_status_no) = c_status_pending;
  
    l_res_count NUMBER;
    l_job_int   wip_job_schedule_interface%ROWTYPE;
    l_opr_int   wip_job_dtls_interface%ROWTYPE;
    l_res_int   wip_job_dtls_interface%ROWTYPE;
  BEGIN
  
    FOR rec_wo IN cur_wo
    LOOP
      l_job_int := NULL;
      SELECT wip_job_schedule_interface_s.nextval
        INTO l_job_int.header_id
        FROM dual;
      l_job_int.last_update_date           := SYSDATE;
      l_job_int.last_updated_by            := g_user_id;
      l_job_int.creation_date              := SYSDATE;
      l_job_int.created_by                 := g_user_id;
      l_job_int.last_update_login          := -1;
      l_job_int.group_id                   := g_group_id;
      l_job_int.organization_id            := rec_wo.organization_id;
      l_job_int.load_type                  := 3; -- 1 Create Standard Discrete Job /2 Create Pending Repetitive Schedule /3 Update Standard or Non-Standard Discrete Job /4 Create Non-Standard Discrete Job
      l_job_int.wip_entity_id              := rec_wo.wip_entity_id;
      l_job_int.process_phase              := 2; --2. validation, 3. EXPLOSION, 4. COMPLETION, 5. CREATION
      l_job_int.process_status             := 1; --1. pending 2. running, 3. error 4. complete 5. warning
      l_job_int.allow_explosion            := 'N';
      l_job_int.first_unit_start_date      := rec_wo.scheduled_start_date;
      l_job_int.first_unit_completion_date := rec_wo.scheduled_completion_date;
      l_job_int.scheduling_method          := 3; --scheduling method 1- Routing based; 2- Lead Time; 3- Manual
      l_job_int.last_unit_start_date       := rec_wo.scheduled_start_date;
      l_job_int.last_unit_completion_date  := rec_wo.scheduled_completion_date;
    
      INSERT INTO wip_job_schedule_interface
      VALUES l_job_int;
      FOR rec_opr IN cur_opr(p_cur_wip_entity_id => rec_wo.wip_entity_id)
      LOOP
        l_opr_int := NULL;
        IF rec_opr.opr_exists_flag = c_yes_flag THEN
          l_opr_int.substitution_type := 3; --substitution_type --substitution_type 1.Delete, 2.Add 3.Change
        ELSE
          l_opr_int.substitution_type := 2; --substitution_type --substitution_type 1.Delete, 2.Add 3.Change            
        END IF;
        l_opr_int.last_update_date  := SYSDATE;
        l_opr_int.last_updated_by   := g_user_id;
        l_opr_int.creation_date     := SYSDATE;
        l_opr_int.created_by        := g_user_id;
        l_opr_int.group_id          := l_job_int.group_id;
        l_opr_int.parent_header_id  := l_job_int.header_id;
        l_opr_int.organization_id   := rec_opr.organization_id;
        l_opr_int.operation_seq_num := rec_opr.operation_seq_num;
        l_opr_int.department_id     := rec_opr.department_id;
        l_opr_int.load_type         := 3; --load_type  --load_type 1. resource 2. component 3. operation 4. multiple resource usage
        l_opr_int.process_phase     := 2; --process_phase
        l_opr_int.process_status    := 1; -- process_status      
        l_opr_int.count_point_type  := rec_opr.count_point_type;
        l_opr_int.backflush_flag    := rec_opr.backflush_flag;
      
        INSERT INTO wip_job_dtls_interface
        VALUES l_opr_int;
      
        SELECT COUNT(1)
          INTO l_res_count
          FROM xxwip.xxwip_wo_update_datafix t
         WHERE 1 = 1
           AND t.resource_seq_num IS NOT NULL
           AND t.wip_entity_id = rec_opr.wip_entity_id
           AND t.operation_seq_num = rec_opr.operation_seq_num
           AND nvl(t.process_status, c_status_no) = c_status_pending;
        IF l_res_count > 0 THEN
          -- need insert rescource records
          FOR rec_res IN cur_res(p_cur_wip_entity_id     => rec_opr.wip_entity_id,
                                 p_cur_operation_seq_num => rec_opr.operation_seq_num)
          LOOP
            l_res_int := NULL;
            IF rec_res.res_exists_flag = c_yes_flag THEN
              l_res_int.substitution_type := 2; --substitution_type  1.Delete, 2.Add 3.Change
              l_res_int.resource_id_old   := rec_res.resource_id_old;
            ELSE
              l_res_int.substitution_type := 2; --substitution_type  1.Delete, 2.Add 3.Change
              l_res_int.resource_id_new   := NULL;
            END IF;
            l_res_int.last_update_date     := SYSDATE;
            l_res_int.last_updated_by      := g_user_id;
            l_res_int.creation_date        := SYSDATE;
            l_res_int.created_by           := g_user_id;
            l_res_int.group_id             := l_job_int.group_id;
            l_res_int.parent_header_id     := l_job_int.header_id;
            l_res_int.organization_id      := rec_res.organization_id;
            l_res_int.operation_seq_num    := rec_res.operation_seq_num;
            l_res_int.resource_seq_num     := rec_res.resource_seq_num;
            l_res_int.resource_id_new      := rec_res.resource_id_new;
            l_res_int.usage_rate_or_amount := rec_res.usage_rate_or_amount;
            l_res_int.assigned_units       := rec_res.assigned_units;
            l_res_int.autocharge_type      := rec_res.autocharge_type;
            l_res_int.basis_type           := rec_res.basis_type;
            l_res_int.standard_rate_flag   := 2;
            l_res_int.load_type            := 1; --load_type 1. resource 2. component 3. operation 4. multiple resource usage
            l_res_int.process_phase        := 2; --process_phase
            l_res_int.process_status       := 1; -- process_status
            l_res_int.scheduled_flag       := rec_res.scheduled; -- scheduled
            INSERT INTO wip_job_dtls_interface
            VALUES l_res_int;
          
            UPDATE xxwip.xxwip_wo_update_datafix t
               SET t.process_status  = c_status_success,
                   t.process_date    = SYSDATE,
                   t.process_message = NULL,
                   t.group_id        = l_job_int.group_id,
                   t.header_id       = l_job_int.header_id
             WHERE 1 = 1
               AND t.resource_seq_num IS NOT NULL
               AND t.wip_entity_id = rec_res.wip_entity_id
               AND t.operation_seq_num = rec_res.operation_seq_num
               AND t.resource_seq_num = rec_res.resource_seq_num
               AND nvl(t.process_status, c_status_no) = c_status_pending;
          
          END LOOP;
        ELSE
          -- update status
          UPDATE xxwip.xxwip_wo_update_datafix t
             SET t.process_status  = c_status_success,
                 t.process_date    = SYSDATE,
                 t.process_message = NULL,
                 t.group_id        = l_job_int.group_id,
                 t.header_id       = l_job_int.header_id
           WHERE 1 = 1
             AND t.wip_entity_id = rec_opr.wip_entity_id
             AND t.operation_seq_num = rec_opr.operation_seq_num
             AND nvl(t.process_status, c_status_no) = c_status_pending;
        END IF;
      END LOOP;
    END LOOP;
  END process;

  -- submit request
  PROCEDURE proc_submit_req(p_group_id   IN NUMBER,
                            x_request_id OUT NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_trx_request_id NUMBER;
    l_wait_req       BOOLEAN;
    l_child_phase    VARCHAR2(80);
    l_child_status   VARCHAR2(80);
    l_dev_phase      VARCHAR2(80);
    l_dev_status     VARCHAR2(80);
    l_message        VARCHAR2(2000);
  BEGIN
    x_request_id := fnd_request.submit_request('WIP',
                                               'WICMLP',
                                               NULL,
                                               NULL,
                                               FALSE,
                                               to_char(p_group_id), /* grp id*/
                                               to_char(wip_constants.full), /*validation lvl*/
                                               to_char(wip_constants.yes)); /* print report */
  
    -- Commit the insert
    COMMIT;
    IF x_request_id > 0 THEN
      l_wait_req := fnd_concurrent.wait_for_request(request_id => x_request_id,
                                                    INTERVAL   => 1,
                                                    max_wait   => 0,
                                                    phase      => l_child_phase,
                                                    status     => l_child_status,
                                                    dev_phase  => l_dev_phase,
                                                    dev_status => l_dev_status,
                                                    message    => l_message);
      dbms_output.put_line('---------------- ----------------');
      dbms_output.put_line('  x_request_id   : ' || x_request_id);
      dbms_output.put_line('  phase          : ' || l_child_phase);
      dbms_output.put_line('  status         : ' || l_child_status);
      dbms_output.put_line('  dev_phase      : ' || l_dev_phase);
      dbms_output.put_line('  dev_status     : ' || l_dev_status);
      dbms_output.put_line('  message        : ' || l_message);
      dbms_output.put_line('---------------- ----------------');
    END IF;
  END proc_submit_req;
BEGIN
  fnd_global.apps_initialize(user_id => 2722, resp_id => 50778, resp_appl_id => 20005);
  g_user_id         := 2722;
  g_group_id        := 12345;
  g_delete_group_id := 54321;
  -- process validate
  proc_validate;
  -- process backup
  proc_backup;
  -- process delete resource
  proc_delete_res;
  -- submit delete request
  COMMIT;
  SELECT COUNT(1)
    INTO l_count
    FROM wip_job_schedule_interface t
   WHERE 1 = 1
     AND t.group_id = g_delete_group_id;
  IF l_count > 0 THEN
    -- need to submit delete resource request
    dbms_output.put_line(' need to submit delete resource request');
    proc_submit_req(p_group_id   => g_delete_group_id, --
                    x_request_id => l_request_id);
    dbms_output.put_line(' delete resource request_id : ' || l_request_id);
  END IF;
  -- process;
  process;
  -- submit delete request
  COMMIT;
  SELECT COUNT(1)
    INTO l_count
    FROM wip_job_schedule_interface t
   WHERE 1 = 1
     AND t.group_id = g_group_id;
  IF l_count > 0 THEN
    -- need to submit request
    dbms_output.put_line(' need to submit request');
    proc_submit_req(p_group_id   => g_group_id, --
                    x_request_id => l_request_id);
    dbms_output.put_line(' process request_id : ' || l_request_id);
  END IF;

END;

/*SELECT *
  FROM xxwip.xxwip_wo_update_datafix t
  
SELECT *
  FROM wip_job_schedule_interface t
 WHERE t.group_id IN (12345, 54321);-- 54321  12345

SELECT *
  FROM wip_job_dtls_interface t
 WHERE t.group_id IN (12345, 54321); -- 54321  12345
*/
