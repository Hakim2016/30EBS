DECLARE

  CURSOR cur_data(p_cur_wip_entity_id IN NUMBER) IS
    SELECT wor.wip_entity_id,
           we.entity_type,
           we.primary_item_id,
           wor.operation_seq_num,
           wor.resource_seq_num,
           wor.organization_id,
           ood.organization_code,
           wor.resource_id,
           br.resource_code,
           wor.uom_code,
           wor.usage_rate_or_amount,
           wor.basis_type,
           wor.autocharge_type -- 2 Manual
      FROM wip_operation_resources      wor,
           bom_resources                br,
           wip_entities                 we,
           org_organization_definitions ood
     WHERE 1 = 1
       AND wor.organization_id = ood.organization_id
       AND we.wip_entity_id = wor.wip_entity_id
       AND wor.resource_id = br.resource_id
       AND br.resource_code NOT IN ('PLN')
       AND wor.wip_entity_id = p_cur_wip_entity_id;

  l_cst_txn_if_rec      wip_cost_txn_interface%ROWTYPE;
  l_costed_amount       NUMBER;
  l_new_amount          NUMBER;
  l_count               NUMBER;
  p_wip_entity_id       NUMBER;
  p_operation_seq_num   NUMBER;
  p_resource_seq_num    NUMBER;
  p_progress_percentage NUMBER := 100;
  p_source_code         VARCHAR2;
  p_source_line_id      VARCHAR2;
BEGIN
  l_count := 0;

  FOR rec_data IN cur_data(p_cur_wip_entity_id => p_wip_entity_id) LOOP
    SELECT nvl(SUM(tmp.transaction_quantity), 0)
      INTO l_costed_amount
      FROM (SELECT wt.transaction_quantity
              FROM wip_transactions wt
             WHERE 1 = 1
               AND wt.wip_entity_id = p_wip_entity_id
               AND wt.operation_seq_num = rec_data.operation_seq_num
               AND wt.resource_seq_num = rec_data.resource_seq_num
            UNION ALL
            SELECT wct.transaction_quantity
              FROM wip_cost_txn_interface wct
             WHERE 1 = 1
               AND wct.process_status NOT IN (3)
               AND wct.wip_entity_id = p_wip_entity_id
               AND wct.operation_seq_num = rec_data.operation_seq_num
               AND wct.resource_seq_num = rec_data.resource_seq_num) tmp;
  
    l_new_amount := rec_data.usage_rate_or_amount * p_progress_percentage / 100;
    IF p_progress_percentage IS NOT NULL AND
       (l_new_amount - l_costed_amount) <> 0 THEN
      l_cst_txn_if_rec.last_update_date     := SYSDATE;
      l_cst_txn_if_rec.last_updated_by      := fnd_global.user_id;
      l_cst_txn_if_rec.creation_date        := SYSDATE;
      l_cst_txn_if_rec.created_by           := fnd_global.user_id;
      l_cst_txn_if_rec.last_update_login    := fnd_global.login_id;
      l_cst_txn_if_rec.last_updated_by_name := fnd_global.user_name;
      l_cst_txn_if_rec.created_by_name      := fnd_global.user_name;
    
      l_cst_txn_if_rec.transaction_type     := 1;
      l_cst_txn_if_rec.process_phase        := 1;
      l_cst_txn_if_rec.process_status       := 1;
      l_cst_txn_if_rec.wip_entity_id        := rec_data.wip_entity_id;
      l_cst_txn_if_rec.primary_item_id      := rec_data.primary_item_id;
      l_cst_txn_if_rec.entity_type          := rec_data.entity_type;
      l_cst_txn_if_rec.organization_id      := rec_data.organization_id;
      l_cst_txn_if_rec.organization_code    := rec_data.organization_code;
      l_cst_txn_if_rec.operation_seq_num    := rec_data.operation_seq_num;
      l_cst_txn_if_rec.resource_seq_num     := rec_data.resource_seq_num;
      l_cst_txn_if_rec.basis_type           := rec_data.basis_type;
      l_cst_txn_if_rec.autocharge_type      := rec_data.autocharge_type;
      l_cst_txn_if_rec.transaction_date     := SYSDATE;
      l_cst_txn_if_rec.transaction_quantity := l_new_amount -
                                               l_costed_amount;
      l_cst_txn_if_rec.transaction_uom      := rec_data.uom_code;
      INSERT INTO wip_cost_txn_interface VALUES l_cst_txn_if_rec;
      l_count := l_count + 1;
    END IF;
  END LOOP;
END proc_wip_res_trx;
