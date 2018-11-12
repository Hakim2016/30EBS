/*
backup script:
       CREATE TABLE xxbom.bom_operation_res_bk140415 AS
        SELECT *
          FROM apps.bom_operation_resources bores
         WHERE 1 = 1
              --AND rownum < 10001
           AND bores.schedule_flag = 2 -- No
           AND bores.autocharge_type = 1 -- 1-WIP move  2-Manual
           AND EXISTS (SELECT bor.routing_sequence_id,
                       ood.organization_code,
                       msib.segment1,
                       bor.description,
                       --substr(msib.segment1, -2, 2),
                       bor.cfm_routing_flag,
                       bos.operation_sequence_id,
                       bos.operation_seq_num,
                       bos.standard_operation_code,
                       bos.department_code
                  FROM apps.bom_operational_routings_v   bor,
                       apps.org_organization_definitions ood,
                       apps.mtl_system_items_b           msib,
                       apps.bom_operation_sequences_v    bos
                 WHERE 1 = 1
                      --AND bor.assembly_item_id = 286900
                   AND bor.organization_id = 86
                      --AND nvl(cfm_routing_flag, 2) = 2
                   AND bor.organization_id = ood.organization_id
                   AND bor.organization_id = msib.organization_id
                   AND bor.assembly_item_id = msib.inventory_item_id
                   AND bor.routing_sequence_id = bos.routing_sequence_id
                   AND bores.operation_sequence_id = bos.operation_sequence_id
                   AND substr(msib.segment1, -2, 2) NOT IN ('PS',
                                                            'CS',
                                                            'DM',
                                                            'DH',
                                                            'RS',
                                                            'JS',
                                                            'DC',
                                                            'IM',
                                                            'EP',
                                                            'SW',
                                                            'TM',
                                                            '-C',
                                                            '-D',
                                                            '-E',
                                                            '-I',
                                                            '-J',
                                                            '-K',
                                                            '-M',
                                                            '-P',
                                                            '-Q',
                                                            '-R',
                                                            '-S'));
*/

DECLARE
  -- Non-scalar parameters require additional processing 
  l_mesg_token_tbl       error_handler.mesg_token_tbl_type;
  x_rev_op_resource_rec  bom_rtg_pub.rev_op_resource_rec_type;
  x_rev_op_res_unexp_rec bom_rtg_pub.rev_op_res_unexposed_rec_type;
  x_mesg_token_tbl       error_handler.mesg_token_tbl_type;
  x_return_status        VARCHAR2(10);
  CURSOR cur_data IS
    SELECT bores.resource_seq_num,
           bores.operation_sequence_id,
           bores.acd_type
      FROM apps.bom_operation_resources bores
     WHERE 1 = 1
       --AND rownum < 10001
       AND bores.schedule_flag = 2 -- No
       AND bores.autocharge_type = 1 -- 1-WIP move  2-Manual
       AND EXISTS (SELECT bor.routing_sequence_id,
                   ood.organization_code,
                   msib.segment1,
                   bor.description,
                   --substr(msib.segment1, -2, 2),
                   bor.cfm_routing_flag,
                   bos.operation_sequence_id,
                   bos.operation_seq_num,
                   bos.standard_operation_code,
                   bos.department_code
              FROM apps.bom_operational_routings_v   bor,
                   apps.org_organization_definitions ood,
                   apps.mtl_system_items_b           msib,
                   apps.bom_operation_sequences_v    bos
             WHERE 1 = 1
                  --AND bor.assembly_item_id = 286900
               AND bor.organization_id = 86
                  --AND nvl(cfm_routing_flag, 2) = 2
               AND bor.organization_id = ood.organization_id
               AND bor.organization_id = msib.organization_id
               AND bor.assembly_item_id = msib.inventory_item_id
               AND bor.routing_sequence_id = bos.routing_sequence_id
               AND bores.operation_sequence_id = bos.operation_sequence_id
               AND substr(msib.segment1, -2, 2) NOT IN ('PS',
                                                        'CS',
                                                        'DM',
                                                        'DH',
                                                        'RS',
                                                        'JS',
                                                        'DC',
                                                        'IM',
                                                        'EP',
                                                        'SW',
                                                        'TM',
                                                        '-C',
                                                        '-D',
                                                        '-E',
                                                        '-I',
                                                        '-J',
                                                        '-K',
                                                        '-M',
                                                        '-P',
                                                        '-Q',
                                                        '-R',
                                                        '-S'));
  -- exception
  e_user_exp EXCEPTION;
  -- counter
  l_counter NUMBER;

  -- timer
  l_begin_datetime DATE;
BEGIN
  l_counter        := 0;
  l_begin_datetime := SYSDATE;
  fnd_global.apps_initialize(user_id => 1393, resp_id => 50778, resp_appl_id => 20005);
  /*dbms_output.put_line(fnd_global.user_id);
  dbms_output.put_line(fnd_global.login_id);
  dbms_output.put_line(fnd_global.conc_program_id);
  dbms_output.put_line(fnd_global.prog_appl_id);
  dbms_output.put_line(fnd_global.conc_request_id);*/
  bom_rtg_globals.init_system_info_rec(x_mesg_token_tbl => l_mesg_token_tbl, --IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                       x_return_status  => x_return_status -- IN OUT NOCOPY VARCHAR2
                                       );

  FOR rec IN cur_data
  LOOP
    x_return_status := fnd_api.g_ret_sts_success;
    -- Call the procedure
    bom_op_res_util.query_row(p_resource_sequence_number => rec.resource_seq_num, --:p_resource_sequence_number,
                              p_operation_sequence_id    => rec.operation_sequence_id, --:p_operation_sequence_id,
                              p_acd_type                 => rec.acd_type, --:p_acd_type,
                              p_mesg_token_tbl           => l_mesg_token_tbl,
                              x_rev_op_resource_rec      => x_rev_op_resource_rec,
                              x_rev_op_res_unexp_rec     => x_rev_op_res_unexp_rec,
                              x_mesg_token_tbl           => x_mesg_token_tbl,
                              x_return_status            => x_return_status);
    IF x_return_status <> bom_rtg_globals.g_record_found THEN
      dbms_output.put_line('query_row RAISE EXCEPTION ');
      RAISE e_user_exp;
    END IF;
    x_rev_op_resource_rec.autocharge_type := '2'; --MANUAL
    -- dbms_output.put_line('  x_return_status : ' || x_return_status);
  
    bom_op_res_util.update_row(p_rev_op_resource_rec  => x_rev_op_resource_rec, --IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type               
                               p_rev_op_res_unexp_rec => x_rev_op_res_unexp_rec, --IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type               
                               x_mesg_token_tbl       => x_mesg_token_tbl, --IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type               
                               x_return_status        => x_return_status --IN OUT NOCOPY VARCHAR2
                               );
  
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      dbms_output.put_line('update_row RAISE EXCEPTION ');
      RAISE e_user_exp;
    END IF;
  
    l_counter := l_counter + 1;
    IF MOD(l_counter, 5000) = 0 THEN
      dbms_output.put_line('              SUCCESS UPDATED ROWS : ' || l_counter || ' rows.  Time-consuming : ' ||
                           (to_char(SYSDATE, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
    END IF;
  END LOOP;
  dbms_output.put_line('  Finally success updated rows : ' || l_counter || ' rows.  Time-consuming : ' ||
                       (to_char(SYSDATE, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
EXCEPTION
  WHEN e_user_exp THEN
    FOR i IN 1 .. nvl(x_mesg_token_tbl.count, 0)
    LOOP
      /* 
      TYPE Mesg_Token_Rec_Type IS RECORD
      (  message_name VARCHAR2(30)   := NULL
       , application_id VARCHAR2(3)  := NULL
       , message_text VARCHAR2(2000) := NULL
       , token_name   VARCHAR2(30)   := NULL
       , token_value  VARCHAR2(700)   := NULL
       , translate    BOOLEAN        := FALSE
       , message_type VARCHAR2(1)    := NULL
      );      
      TYPE Mesg_Token_Tbl_Type IS TABLE OF Mesg_Token_Rec_Type
              INDEX BY BINARY_INTEGER;
        */
      dbms_output.put_line('           message_name : ' || x_mesg_token_tbl(i).message_name);
      dbms_output.put_line('           application_id : ' || x_mesg_token_tbl(i).application_id);
      dbms_output.put_line('           message_text : ' || x_mesg_token_tbl(i).message_text);
      dbms_output.put_line('           token_name : ' || x_mesg_token_tbl(i).token_name);
      dbms_output.put_line('           token_value : ' || x_mesg_token_tbl(i).token_value);
      -- dbms_output.put_line('           translate : ' || x_mesg_token_tbl(i).translate);
      dbms_output.put_line('           message_type : ' || x_mesg_token_tbl(i).message_type);
    END LOOP;
    dbms_output.put_line('      Exception : e_user_exp');
    dbms_output.put_line('  Finally success updated rows : ' || l_counter || ' rows.  Time-consuming : ' ||
                         (to_char(SYSDATE, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('      Exception : OTHERS');
    dbms_output.put_line('        ERRCODE : ' || SQLCODE);
    dbms_output.put_line('        SQLERRM : ' || SQLERRM);
    dbms_output.put_line('  Finally success updated rows : ' || l_counter || ' rows.  Time-consuming : ' ||
                         (to_char(SYSDATE, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
    ROLLBACK;
END;
