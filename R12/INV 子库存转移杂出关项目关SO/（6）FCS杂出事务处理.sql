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
alter table XXINV_TASK_TEMP add process_status varchar2(100);
alter table XXINV_TASK_TEMP add process_message varchar2(100);

select pt.task_number,t.* from XXINV_TASK_TEMP t ,pa_tasks pt
where t.process_status is not null
and t.task_id=pt.task_id;

select  fnd_profile.value('XXINV_USE_SO_COGS') from  dual;

select  fnd_profile.value('XXINV_MFG_PRJ_ISSUE') from dual;

select fnd_profile.value('INV_PROJ_MISC_TXN_EXP_TYPE') from dual;

select * from xxinv_proj_transfer_todo_fcs t where t.rowid='AAEdRPAAjAAPPKTAAA';

*/
/*
BEGIN
  fnd_global.apps_initialize(user_id => 3804, resp_id => 50778, resp_appl_id => 20005);
END;*/


DECLARE

  x_return_status  VARCHAR2(10);
  x_return_message VARCHAR2(4000);
  x_msg_count      NUMBER;

  c_status_success CONSTANT VARCHAR2(1) := 'S';
  c_status_error   CONSTANT VARCHAR2(1) := 'E';
  c_status_pending CONSTANT VARCHAR2(1) := 'P';

  c_status_success_stock CONSTANT VARCHAR2(10) := 'S_stock';
  c_status_error_stock   CONSTANT VARCHAR2(10) := 'E_stock';
  c_status_pending_stock CONSTANT VARCHAR2(10) := 'P_stock';

  l_onhand_qty       NUMBER;
  l_processd_count   NUMBER;
  l_time_point_start NUMBER;
  g_sysdate          DATE := SYSDATE;

  g_transaction_type_id NUMBER := 104/*to_number(fnd_profile.value('XXINV_MFG_PRJ_ISSUE'))*/;
  g_default_ship_acct CONSTANT VARCHAR2(240) := 'GS00.0.1145500000.421103030.0.0.0'/*fnd_profile.value('XXINV_DEFAULT_SHIPPING_ACCOUNT')*/;
  g_use_so_cogs       CONSTANT VARCHAR2(1) := fnd_profile.value('XXINV_USE_SO_COGS');

  CURSOR cur_line IS
    SELECT t.rowid row_id,
           -- to_number()
           t.organization_id,
           t.inventory_item_id,
           t.sub_inv,
           t.locator_id,
           t.quantity,
           -- t.uom,
           -- t.task_id,
           msi.primary_uom_code uom,
           task.project_id,
           to_number(milk.segment20) task_id
      FROM xxinv.xxinv_proj_transfer_todo_fcs t,  --前面已经清空，并且已经导入新数据
           mtl_item_locations_kfv             milk,
           mtl_system_items_b                 msi,
           xxinv_task_temp                    task   --上一步要清空的表，并且已经导入新数据 
     WHERE 1 = 1
       AND t.locator_id = milk.inventory_location_id
       AND nvl(t.process_status, c_status_pending) IN (c_status_pending, c_status_error_stock)
       AND t.organization_id = msi.organization_id
       AND t.inventory_item_id = msi.inventory_item_id
          -- AND ROWNUM<10
          -- AND t.rowid IN ('AAEdRPAAsAACsxGAAD')--AAEdRPAAsAACsxGAAA AAEdRPAAsAACsxGAAD
       AND to_number(milk.segment20) = task.task_id;

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

  FUNCTION get_expenditure_type RETURN VARCHAR2 IS
    l_expenditure_type pa_expenditure_types.expenditure_type%TYPE;
    l_exp_type_control NUMBER;
    CURSOR exp_type_cur IS
      SELECT pa.expenditure_type
        INTO l_expenditure_type
        FROM pa_expenditure_types pa
       WHERE 1 = 1
         AND pa.attribute1 = 'Y'
         AND rownum = 1;
  BEGIN
    -- Added by hand on 08-NOV-2012 BEGIN
    -- Get Project Miscellaneous Transaction Expenditure Type
    l_exp_type_control := nvl(to_number(fnd_profile.value('INV_PROJ_MISC_TXN_EXP_TYPE')), 1);
    -- if system derived, leave this value blank
    IF l_exp_type_control = 1 THEN
      RETURN NULL;
    END IF;
    -- Added by hand on 08-NOV-2012 END
    OPEN exp_type_cur;
    FETCH exp_type_cur
      INTO l_expenditure_type;
    CLOSE exp_type_cur;
    IF l_expenditure_type IS NULL THEN
      l_expenditure_type := 'Material';
    END IF;
    RETURN l_expenditure_type;
  END;

  PROCEDURE get_project_account_id(x_return_status   OUT NOCOPY VARCHAR2,
                                   x_msg_count       OUT NOCOPY NUMBER,
                                   x_msg_data        OUT NOCOPY VARCHAR2,
                                   p_project_id      IN NUMBER,
                                   p_organization_id IN NUMBER,
                                   p_order_header_id IN NUMBER,
                                   x_project_ccid    OUT NOCOPY NUMBER) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'GET_ACOUNT_ID';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
  
    v_segment               fnd_flex_ext.segmentarray;
    v_combination_segment   VARCHAR2(2000);
    l_chart_of_accounts_id  NUMBER;
    l_con_segment_delimiter VARCHAR2(1);
    l_loc_flexfield_id      NUMBER;
    l_error_msg             VARCHAR2(2000);
    l_has_result            BOOLEAN := FALSE;
    l_segment_number        NUMBER;
    l_project_number        pa_projects_all.segment1%TYPE;
  
    CURSOR so_cogs_cur IS
      SELECT gcc.segment1,
             gcc.segment2,
             gcc.segment3,
             gcc.segment4,
             gcc.segment5,
             gcc.segment6,
             gcc.segment7
        FROM oe_order_headers_all     ooh,
             oe_transaction_types_all ott,
             gl_code_combinations     gcc
       WHERE ooh.header_id = p_order_header_id
         AND ooh.order_type_id = ott.transaction_type_id
         AND ott.cost_of_goods_sold_account = gcc.code_combination_id;
  BEGIN
    x_return_status := 'S';
  
    -- Get project number
    SELECT segment1
      INTO l_project_number
      FROM pa_projects_all
     WHERE project_id = p_project_id;
  
    SELECT od.chart_of_accounts_id,
           f.concatenated_segment_delimiter
      INTO l_chart_of_accounts_id,
           l_con_segment_delimiter
      FROM org_organization_definitions od,
           fnd_id_flex_structures_vl    f
     WHERE 1 = 1
       AND od.chart_of_accounts_id = f.id_flex_num
       AND f.id_flex_code = 'GL#'
       AND od.organization_id = p_organization_id;
  
    -- If we setup profile to search COGS account
    -- from transaction type of the sales order
  
    IF g_use_so_cogs = 'Y' THEN
      OPEN so_cogs_cur;
      FETCH so_cogs_cur
        INTO v_segment(1),
             v_segment(2),
             v_segment(3),
             v_segment(4),
             v_segment(5),
             v_segment(6),
             v_segment(7);
      l_has_result := (so_cogs_cur%FOUND);
      CLOSE so_cogs_cur;
    END IF;
  
    -- If search failed, try to get default shipping account
    IF NOT l_has_result THEN
      dbms_output.put_line('SO NO RECORD');
    END IF;
    -- from profile
    IF ((NOT l_has_result) AND g_default_ship_acct IS NOT NULL) THEN
      BEGIN
        l_segment_number := fnd_flex_ext.breakup_segments(concatenated_segs => g_default_ship_acct,
                                                          delimiter         => l_con_segment_delimiter,
                                                          segments          => v_segment);
      EXCEPTION
        WHEN OTHERS THEN
          l_has_result := FALSE;
      END;
      l_has_result := TRUE;
    END IF;
  
    -- Raise error if nothing found
    IF NOT l_has_result THEN
      xxfnd_api.set_message('XXINV', 'XXINV_012E_002');
      RAISE fnd_api.g_exc_error;
    END IF;
  
    -- Replace project segment
    v_segment(5) := l_project_number;
    -- Re-combine account segments
    v_combination_segment := fnd_flex_ext.concatenate_segments(7, v_segment, l_con_segment_delimiter);
  
    IF fnd_flex_keyval.validate_segs(operation        => 'CHECK_COMBINATION', --'CREATE_COMBINATION',
                                     appl_short_name  => 'SQLGL',
                                     key_flex_code    => 'GL#',
                                     structure_number => l_chart_of_accounts_id,
                                     concat_segments  => v_combination_segment) THEN
      l_loc_flexfield_id := fnd_flex_ext.get_ccid(application_short_name => 'SQLGL',
                                                  key_flex_code          => 'GL#', --V_Flex_Code,
                                                  structure_number       => l_chart_of_accounts_id,
                                                  validation_date        => to_char(SYSDATE,
                                                                                    fnd_profile.value('ICX_DATE_FORMAT_MASK')),
                                                  concatenated_segments  => v_combination_segment);
    
      --  dbms_output.put_line('v_combination_segment:' || v_combination_segment);
    
    ELSE
      l_error_msg := fnd_flex_keyval.error_message;
    
      x_return_status := 'E';
      x_msg_data      := l_error_msg;
    
    END IF;
  
    x_project_ccid := l_loc_flexfield_id;
  
  EXCEPTION
  
    WHEN OTHERS THEN
      x_return_status := 'E';
      x_msg_data      := SQLERRM;
    
  END get_project_account_id;

  -- ==============
  -- proc_project_transfer
  -- ==============
  PROCEDURE issue_out_proj_stock(p_organization_id   IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_subinventory_code IN VARCHAR2,
                                 p_locator_id        IN NUMBER,
                                 
                                 p_transaction_quantity  IN NUMBER,
                                 p_transaction_uom       IN VARCHAR2,
                                 p_transaction_date      IN DATE DEFAULT SYSDATE,
                                 p_source_header_id      IN NUMBER,
                                 p_source_line_id        IN NUMBER,
                                 p_source_code           IN VARCHAR2 DEFAULT 'HAND BULK Transfer(' ||
                                                                             to_char(SYSDATE, 'DD-MON-YY') || ')',
                                 p_transaction_reference IN VARCHAR2 DEFAULT 'HAND BULK Transfer(' ||
                                                                             to_char(SYSDATE, 'DD-MON-YY') || ')',
                                 p_project_id            IN NUMBER,
                                 p_task_id               IN NUMBER,
                                 x_return_status         OUT VARCHAR2,
                                 x_return_message        OUT VARCHAR2) IS
    -- constant
  
    c_transaction_type_id NUMBER := to_number(fnd_profile.value('XXINV_MFG_PRJ_ISSUE'));
  
    l_expenditure_type VARCHAR2(100);
  
    l_transaction_source_type_id NUMBER;
    l_transaction_action_id      NUMBER;
    l_project_account_id         NUMBER;
  
    l_item_trx_rec  apps.mtl_transactions_interface%ROWTYPE;
    l_retval        NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_trans_count   NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  
    l_expenditure_type := get_expenditure_type;
  
    get_project_account_id(x_return_status   => x_return_status,
                           x_msg_count       => l_msg_count,
                           x_msg_data        => x_return_message,
                           p_project_id      => p_project_id,
                           p_organization_id => p_organization_id,
                           p_order_header_id => NULL,
                           x_project_ccid    => l_project_account_id);
  
    dbms_output.put_line('l_project_account_id:' || l_project_account_id);
  
    IF (l_return_status <> 'S') THEN
      x_return_status := 'E';
      RETURN;
    END IF;
  
    l_item_trx_rec                   := NULL;
    l_item_trx_rec.last_update_date  := SYSDATE;
    l_item_trx_rec.last_updated_by   := fnd_global.user_id;
    l_item_trx_rec.creation_date     := SYSDATE;
    l_item_trx_rec.created_by        := fnd_global.user_id;
    l_item_trx_rec.last_update_login := fnd_global.login_id;
  
    SELECT apps.mtl_material_transactions_s.nextval
      INTO l_item_trx_rec.transaction_interface_id
      FROM dual;
    l_item_trx_rec.transaction_type_id := c_transaction_type_id;
  
    SELECT transaction_source_type_id,
           transaction_action_id
      INTO l_transaction_source_type_id,
           l_transaction_action_id
      FROM mtl_transaction_types mtt
     WHERE 1 = 1
       AND mtt.transaction_type_id = c_transaction_type_id;
  
    l_item_trx_rec.transaction_source_type_id := l_transaction_source_type_id; -- Inventory.
  
    l_item_trx_rec.transaction_mode      := 3;
    l_item_trx_rec.process_flag          := 1;
    l_item_trx_rec.transaction_header_id := l_item_trx_rec.transaction_interface_id;
    l_item_trx_rec.organization_id       := p_organization_id;
    l_item_trx_rec.inventory_item_id     := p_inventory_item_id;
    l_item_trx_rec.subinventory_code     := p_subinventory_code;
    l_item_trx_rec.locator_id            := p_locator_id;
    l_item_trx_rec.transaction_quantity  := p_transaction_quantity * -1;
    l_item_trx_rec.transaction_uom       := p_transaction_uom;
    l_item_trx_rec.transaction_date      := p_transaction_date;
    l_item_trx_rec.source_code           := p_source_code;
    l_item_trx_rec.source_header_id      := p_source_header_id;
    l_item_trx_rec.source_line_id        := p_source_line_id;
    l_item_trx_rec.transaction_reference := p_transaction_reference;
  
    l_item_trx_rec.source_task_id    := p_task_id;
    l_item_trx_rec.source_project_id := p_project_id;
  
    l_item_trx_rec.distribution_account_id := l_project_account_id; --
    l_item_trx_rec.expenditure_type        := l_expenditure_type;
    l_item_trx_rec.pa_expenditure_org_id   := p_organization_id;
  
    INSERT INTO inv.mtl_transactions_interface--标准接口表不要清
    VALUES l_item_trx_rec;
  
    -- dbms_output.put_line('l_item_trx_rec.transaction_interface_id:'||l_item_trx_rec.transaction_interface_id);
  
    l_retval := inv_txn_manager_pub.process_transactions(p_api_version      => 1,
                                                         p_init_msg_list    => fnd_api.g_false,
                                                         p_commit           => fnd_api.g_false,
                                                         p_validation_level => fnd_api.g_valid_level_full,
                                                         x_return_status    => l_return_status,
                                                         x_msg_count        => l_msg_count,
                                                         x_msg_data         => l_msg_data,
                                                         x_trans_count      => l_trans_count,
                                                         p_table            => 1,
                                                         p_header_id        => l_item_trx_rec.transaction_interface_id);
  
    IF l_retval <> 0 THEN
      --get error message
      SELECT mti.error_code,
             mti.error_explanation
        INTO l_item_trx_rec.error_code,
             l_item_trx_rec.error_explanation
        FROM mtl_transactions_interface mti
       WHERE mti.transaction_interface_id = l_item_trx_rec.transaction_interface_id;
    
      DELETE mtl_transactions_interface mti
       WHERE 1 = 1
         AND mti.transaction_interface_id = l_item_trx_rec.transaction_interface_id;
      x_return_status  := fnd_api.g_ret_sts_error;
      x_return_message := l_msg_data || chr(10) || --
                          ' ERROR_CODE : ' || l_item_trx_rec.error_code || chr(10) || -- 
                          ' ERROR_EXPLANATION : ' || l_item_trx_rec.error_explanation;
    END IF;
  
  END issue_out_proj_stock;

BEGIN

  l_processd_count   := 0;
  l_time_point_start := dbms_utility.get_time;

  --

  fnd_global.apps_initialize(user_id => 3804, resp_id => 50778, resp_appl_id => 20005);

  fnd_msg_pub.initialize;

  dbms_output.put_line('g_default_ship_acct:' || g_default_ship_acct);
  dbms_output.put_line('g_use_so_cogs:' || g_use_so_cogs);

  FOR rec IN cur_line
  LOOP
    l_processd_count := l_processd_count + 1;
  
    -- onhand
    BEGIN
      SELECT nvl(SUM(moqd.primary_transaction_quantity), 0)
        INTO l_onhand_qty
        FROM mtl_onhand_quantities_detail moqd
       WHERE 1 = 1
         AND moqd.organization_id = rec.organization_id
         AND moqd.inventory_item_id = rec.inventory_item_id
         AND moqd.locator_id = rec.locator_id;
      IF l_onhand_qty < rec.quantity THEN
        x_return_status  := c_status_error_stock;
        x_return_message := 'The onhand is not enough ';
        GOTO next_record;
      END IF;
    END;
  
    -- constant
  
    issue_out_proj_stock(p_organization_id      => trim_en(rec.organization_id), --
                         p_inventory_item_id    => trim_en(rec.inventory_item_id), --
                         p_subinventory_code    => trim_en(rec.sub_inv), --
                         p_locator_id           => trim_en(rec.locator_id), --
                         p_transaction_quantity => trim_en(rec.quantity), --
                         p_transaction_uom      => trim_en(rec.uom),
                         p_transaction_date     => g_sysdate,
                         p_source_header_id     => trim_en(rec.task_id),
                         p_source_line_id       => trim_en(rec.task_id),
                         p_project_id           => trim_en(rec.project_id),
                         p_task_id              => trim_en(rec.task_id),
                         x_return_status        => x_return_status,
                         x_return_message       => x_return_message);
  
    IF x_return_status <> 'S' THEN
      x_return_message := x_return_message;
      x_return_status  := c_status_error_stock;
    ELSE
      x_return_status  := c_status_success_stock;
      x_return_message := x_return_message;
    END IF;
    GOTO next_record;
  
    <<next_record>>
  
    UPDATE xxinv.xxinv_proj_transfer_todo_fcs t
       SET t.process_status = x_return_status, t.process_message = x_return_message
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
