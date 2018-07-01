DECLARE
  l_api_name       CONSTANT VARCHAR2(30) := 'upd_component_subinv';
  l_savepoint_name CONSTANT VARCHAR2(30) := NULL;

  l_operation_seq_num NUMBER;
  l_res_counter       INTEGER := 0;

  l_exists_flag VARCHAR2(100);
  l_job_rec     wip_job_schedule_interface%ROWTYPE;

  l_component_rec wip_job_dtls_interface%ROWTYPE;

  l_wip_entity_id NUMBER;

  l_subinv_code           VARCHAR2(100);
  l_souchiban             VARCHAR2(100);
  l_part                  VARCHAR2(100);
  x_return_status         VARCHAR2(100);
  x_msg_data              VARCHAR2(100);
  l_request_id            NUMBER := 99999999;
  l_organization_id       NUMBER := 86;
  g_user_id               NUMBER := 2722;
  l_required_quantity     NUMBER;
  l_quantity_per_assembly NUMBER;

  CURSOR cur_component(p_wip_entity_id NUMBER) IS
    SELECT *
      FROM wip_requirement_op_20161221 a
     WHERE a.wip_entity_id = p_wip_entity_id;

BEGIN
  -- start activity to create savepoint, check compatibility

  FOR REC IN ( SELECT DISTINCT A.WIP_ENTITY_ID
                FROM wip_requirement_op_20161221 A
                where a.wip_entity_id=1767911 ) LOOP
  
    l_job_rec.creation_date    := SYSDATE;
    l_job_rec.created_by       := g_user_id;
    l_job_rec.last_update_date := SYSDATE;
    l_job_rec.last_updated_by  := g_user_id;
  
    l_job_rec.process_phase  := 2;
    l_job_rec.process_status := 1;
    l_job_rec.wip_entity_id  := REC.WIP_ENTITY_ID;
    l_job_rec.load_type      := 3; --update
  
    l_job_rec.organization_id := l_organization_id;
  
    l_job_rec.group_id  := l_request_id;
    l_job_rec.header_id := l_request_id;
  
    INSERT INTO wip_job_schedule_interface VALUES l_job_rec;
  
    --component
    FOR r_component IN cur_component(REC.WIP_ENTITY_ID) LOOP
    
      l_component_rec.creation_date         := SYSDATE;
      l_component_rec.created_by            := g_user_id;
      l_component_rec.last_update_date      := SYSDATE;
      l_component_rec.last_updated_by       := g_user_id;
      l_component_rec.organization_id       := l_organization_id;
      l_component_rec.operation_seq_num     := r_component.operation_seq_num;
      l_component_rec.inventory_item_id_old := r_component.inventory_item_id;
      l_component_rec.group_id              := L_request_id;
      l_component_rec.parent_header_id      := L_request_id;
    
      l_component_rec.load_type := 2; --load_type 1. resource 2. component 3. operation 4. multiple resource usage
      IF r_component.flag = 'DEL' THEN
        l_component_rec.substitution_type := 1; -- 1.Delete, 2.Add 3.Change
      ELSE
        l_component_rec.substitution_type     := 3; -- 1.Delete, 2.Add 3.Change  
        l_component_rec.quantity_per_assembly := r_component.quantity_per_assembly;
        l_component_rec.required_quantity     := r_component.required_quantity;
      END IF;
    
      l_component_rec.process_phase  := 2;
      l_component_rec.process_status := 1;
    
      INSERT INTO wip_job_dtls_interface VALUES l_component_rec;
    
    END LOOP;
  
    --operation
  
    wip_massload_pub.massloadjobs(p_groupid         => l_request_id,
                                  p_validationlevel => fnd_api.g_valid_level_full,
                                  p_commitflag      => 1,
                                  x_returnstatus    => x_return_status,
                                  x_errormsg        => x_msg_data);
  
    IF x_return_status <> 'S' THEN
      FOR r_e IN (SELECT e.error
                    FROM wip_interface_errors       e,
                         wip_job_schedule_interface t
                   WHERE e.interface_id = t.interface_id
                     AND t.group_id = l_request_id) LOOP
        dbms_output.put_line(r_e.error);
      END LOOP;
    END IF;
    COMMIT;
    DELETE FROM WIP.wip_job_schedule_interface t
     WHERE t.group_id = 99999999;
    DELETE FROM wip_job_dtls_interface t WHERE t.group_id = 99999999;
  END LOOP;

END;
