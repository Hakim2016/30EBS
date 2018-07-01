DECLARE
  c_yes_flag       CONSTANT VARCHAR2(1) := 'Y';
  c_no_flag        CONSTANT VARCHAR2(1) := 'N';
  c_status_no      CONSTANT VARCHAR2(1) := 'N';
  c_status_pending CONSTANT VARCHAR2(1) := 'P';
  c_status_error   CONSTANT VARCHAR2(1) := 'E';
  c_status_success CONSTANT VARCHAR2(1) := 'S';

  CURSOR cur_validate IS
    SELECT t.rowid                row_id,
           t.organization_code    organization_code,
           t.wip_entity_name      wip_entity_name,
           t.operation_seq_num    operation_seq_num,
           t.department_code      department_code,
           t.resource_seq_num     resource_seq_num,
           t.resource_code        resource_code,
           t.opr_exists_flag,
           t.res_exists_flag,
           t.group_id,
           t.header_id,
           t.organization_id,
           t.wip_entity_id,
           t.department_id,
           t.count_point_type,
           t.backflush_flag,
           t.resource_id_new,
           t.resource_id_old,
           t.usage_rate_or_amount,
           t.assigned_units,
           t.autocharge_type,
           t.process_status,
           t.process_date,
           t.process_message
      FROM xxwip.xxwip_wo_update_datafix t
     WHERE 1 = 1
       AND nvl(t.process_status, c_status_no) = c_status_no;

  CURSOR cur_wo IS
    SELECT DISTINCT t.organization_id,
                    t.wip_entity_id
      FROM xxwip.xxwip_wo_update_datafix t
     WHERE 1 = 1
       AND nvl(t.process_status, c_status_no) = c_status_pending;

  CURSOR cur_operation(p_cur_wip_entity_id IN NUMBER) IS
    SELECT DISTINCT t.organization_id,
                    t.wip_entity_id,
                    t.operation_seq_num,
                    t.department_code,
                    t.opr_exists_flag
      FROM xxwip.xxwip_wo_update_datafix t
     WHERE 1 = 1
       AND t.wip_entity_id = p_cur_wip_entity_id
       AND nvl(t.process_status, c_status_no) = c_status_pending;

  l_count NUMBER;
  
  PROCEDURE proc_validate IS
    
  BEGIN
    
  END proc_validate;
  
  
BEGIN

  -- validate
  FOR rec_validate IN cur_validate
  LOOP
    rec_validate.process_status := c_status_pending;
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
        SELECT wor.resource_id,
               wor.assigned_units,
               wor.autocharge_type,
               wor.usage_rate_or_amount
          INTO rec_validate.resource_id_old,
               rec_validate.assigned_units,
               rec_validate.autocharge_type,
               rec_validate.usage_rate_or_amount
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
          SELECT br.resource_id
            INTO rec_validate.resource_id_new
            FROM bom_resources br
           WHERE 1 = 1
             AND br.organization_id = rec_validate.organization_id
             AND br.resource_code = rec_validate.resource_code;
        EXCEPTION
          WHEN OTHERS THEN
            rec_validate.process_status  := c_status_error;
            rec_validate.process_message := rec_validate.process_message || '[ ' || 'Resource Code is invalid' || ' ]';
        END;
      END IF;
    
    END IF;
  
    IF rec_validate.opr_exists_flag = c_no_flag THEN
      rec_validate.count_point_type := 1;
      rec_validate.backflush_flag   := 1;
    END IF;
  
    IF rec_validate.res_exists_flag = c_no_flag THEN
      rec_validate.assigned_units       := 1;
      rec_validate.autocharge_type      := 2;
      rec_validate.usage_rate_or_amount := 0;
    END IF;
  
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

END;
