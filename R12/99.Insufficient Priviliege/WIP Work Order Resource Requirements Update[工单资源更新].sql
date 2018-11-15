DECLARE
  l_wip_entity_id     NUMBER;
  l_organization_id   NUMBER;
  l_operation_seq_num NUMBER;
  l_resource_seq_num  NUMBER;
  x_eam_res_rec       eam_process_wo_pub.eam_res_rec_type;
  l_return_status     VARCHAR2(10);
  x_mesg_token_tbl    eam_error_message_pvt.mesg_token_tbl_type;
  l_message           VARCHAR2(2000);
BEGIN
  l_wip_entity_id     := 860400;
  l_organization_id   := 86;
  l_operation_seq_num := 10;
  l_resource_seq_num  := 10;
  eam_res_utility_pvt.query_row(p_wip_entity_id     => l_wip_entity_id,
                                p_organization_id   => l_organization_id,
                                p_operation_seq_num => l_operation_seq_num,
                                p_resource_seq_num  => l_resource_seq_num,
                                x_eam_res_rec       => x_eam_res_rec,
                                x_return_status     => l_return_status);

  dbms_output.put_line(' l_return_status : ' || l_return_status);
  dbms_output.put_line(' x_eam_res_rec.usage_rate_or_amount : ' || x_eam_res_rec.wip_entity_id);
  dbms_output.put_line(' x_eam_res_rec.usage_rate_or_amount : ' || x_eam_res_rec.organization_id);
  dbms_output.put_line(' x_eam_res_rec.usage_rate_or_amount : ' || x_eam_res_rec.operation_seq_num);
  dbms_output.put_line(' x_eam_res_rec.usage_rate_or_amount : ' || x_eam_res_rec.resource_seq_num);
  dbms_output.put_line(' x_eam_res_rec.usage_rate_or_amount : ' || x_eam_res_rec.usage_rate_or_amount);

  x_eam_res_rec.wip_entity_id        := l_wip_entity_id;
  x_eam_res_rec.organization_id      := l_organization_id;
  x_eam_res_rec.operation_seq_num    := l_operation_seq_num;
  x_eam_res_rec.resource_seq_num     := l_resource_seq_num;
  x_eam_res_rec.usage_rate_or_amount := x_eam_res_rec.usage_rate_or_amount + 1;

  eam_res_utility_pvt.update_row(p_eam_res_rec    => x_eam_res_rec,
                                 x_mesg_token_tbl => x_mesg_token_tbl,
                                 x_return_status  => l_return_status);
  FOR l_index IN 1 .. x_mesg_token_tbl.count
  LOOP
    l_message := l_message || ' [' || --
                 x_mesg_token_tbl(l_index).message_text || --
                 '] ';
  END LOOP;
  dbms_output.put_line(' l_return_status : ' || l_return_status);

  dbms_output.put_line(' HEADER_ID                   : ' || x_eam_res_rec.header_id);
  dbms_output.put_line(' BATCH_ID                    : ' || x_eam_res_rec.batch_id);
  dbms_output.put_line(' ROW_ID                      : ' || x_eam_res_rec.row_id);
  dbms_output.put_line(' WIP_ENTITY_ID               : ' || x_eam_res_rec.wip_entity_id);
  dbms_output.put_line(' ORGANIZATION_ID             : ' || x_eam_res_rec.organization_id);
  dbms_output.put_line(' OPERATION_SEQ_NUM           : ' || x_eam_res_rec.operation_seq_num);
  dbms_output.put_line(' RESOURCE_SEQ_NUM            : ' || x_eam_res_rec.resource_seq_num);
  dbms_output.put_line(' RESOURCE_ID                 : ' || x_eam_res_rec.resource_id);
  dbms_output.put_line(' UOM_CODE                    : ' || x_eam_res_rec.uom_code);
  dbms_output.put_line(' BASIS_TYPE                  : ' || x_eam_res_rec.basis_type);
  dbms_output.put_line(' USAGE_RATE_OR_AMOUNT        : ' || x_eam_res_rec.usage_rate_or_amount);
  dbms_output.put_line(' ACTIVITY_ID                 : ' || x_eam_res_rec.activity_id);
  dbms_output.put_line(' SCHEDULED_FLAG              : ' || x_eam_res_rec.scheduled_flag);
  dbms_output.put_line(' FIRM_FLAG                   : ' || x_eam_res_rec.firm_flag);
  dbms_output.put_line(' ASSIGNED_UNITS              : ' || x_eam_res_rec.assigned_units);
  dbms_output.put_line(' MAXIMUM_ASSIGNED_UNITS      : ' || x_eam_res_rec.maximum_assigned_units);
  dbms_output.put_line(' AUTOCHARGE_TYPE             : ' || x_eam_res_rec.autocharge_type);
  dbms_output.put_line(' STANDARD_RATE_FLAG          : ' || x_eam_res_rec.standard_rate_flag);
  dbms_output.put_line(' APPLIED_RESOURCE_UNITS      : ' || x_eam_res_rec.applied_resource_units);
  dbms_output.put_line(' APPLIED_RESOURCE_VALUE      : ' || x_eam_res_rec.applied_resource_value);
  dbms_output.put_line(' START_DATE                  : ' || x_eam_res_rec.start_date);
  dbms_output.put_line(' COMPLETION_DATE             : ' || x_eam_res_rec.completion_date);
  dbms_output.put_line(' SCHEDULE_SEQ_NUM            : ' || x_eam_res_rec.schedule_seq_num);
  dbms_output.put_line(' SUBSTITUTE_GROUP_NUM        : ' || x_eam_res_rec.substitute_group_num);
  dbms_output.put_line(' REPLACEMENT_GROUP_NUM       : ' || x_eam_res_rec.replacement_group_num);
  dbms_output.put_line(' ATTRIBUTE_CATEGORY          : ' || x_eam_res_rec.attribute_category);
  dbms_output.put_line(' ATTRIBUTE1                  : ' || x_eam_res_rec.attribute1);
  dbms_output.put_line(' ATTRIBUTE2                  : ' || x_eam_res_rec.attribute2);
  dbms_output.put_line(' ATTRIBUTE3                  : ' || x_eam_res_rec.attribute3);
  dbms_output.put_line(' ATTRIBUTE4                  : ' || x_eam_res_rec.attribute4);
  dbms_output.put_line(' ATTRIBUTE5                  : ' || x_eam_res_rec.attribute5);
  dbms_output.put_line(' ATTRIBUTE6                  : ' || x_eam_res_rec.attribute6);
  dbms_output.put_line(' ATTRIBUTE7                  : ' || x_eam_res_rec.attribute7);
  dbms_output.put_line(' ATTRIBUTE8                  : ' || x_eam_res_rec.attribute8);
  dbms_output.put_line(' ATTRIBUTE9                  : ' || x_eam_res_rec.attribute9);
  dbms_output.put_line(' ATTRIBUTE10                 : ' || x_eam_res_rec.attribute10);
  dbms_output.put_line(' ATTRIBUTE11                 : ' || x_eam_res_rec.attribute11);
  dbms_output.put_line(' ATTRIBUTE12                 : ' || x_eam_res_rec.attribute12);
  dbms_output.put_line(' ATTRIBUTE13                 : ' || x_eam_res_rec.attribute13);
  dbms_output.put_line(' ATTRIBUTE14                 : ' || x_eam_res_rec.attribute14);
  dbms_output.put_line(' ATTRIBUTE15                 : ' || x_eam_res_rec.attribute15);
  dbms_output.put_line(' DEPARTMENT_ID               : ' || x_eam_res_rec.department_id);
  dbms_output.put_line(' REQUEST_ID                  : ' || x_eam_res_rec.request_id);
  dbms_output.put_line(' PROGRAM_APPLICATION_ID      : ' || x_eam_res_rec.program_application_id);
  dbms_output.put_line(' PROGRAM_ID                  : ' || x_eam_res_rec.program_id);
  dbms_output.put_line(' PROGRAM_UPDATE_DATE         : ' || x_eam_res_rec.program_update_date);
  dbms_output.put_line(' RETURN_STATUS               : ' || x_eam_res_rec.return_status);
  dbms_output.put_line(' TRANSACTION_TYPE            : ' || x_eam_res_rec.transaction_type);

END;
