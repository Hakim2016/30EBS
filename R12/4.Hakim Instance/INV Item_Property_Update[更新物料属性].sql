-- Item Property Update

/*
    1、CREATE TABLE XXINV.XXINV_ITEM_UPDATE_20140317
    (
          organization_code             VARCHAR2(3),
          item_code                     VARCHAR2(40),
          purchasing_enabled_flag       VARCHAR2(1),
          mtl_transactions_enabled_flag VARCHAR2(1),
          stock_enabled_flag            VARCHAR2(1),
          build_in_wip_flag             VARCHAR2(1),
          update_flag                   VARCHAR2(1),
          message                       VARCHAR2(4000)

    ) tablespace ADDON_TS_TX_DATA;   
    comment on table XXINV.XXINV_ITEM_UPDATE_20140317
      is 'Ticket A03946 Item Property Update';
    
    2、INSERT records into table.
    
    3、run this script
    
    4、DROP TABLE XXINV.XXINV_ITEM_UPDATE_20140317;
*/

set serveroutput on size 1000000000; 

DECLARE
  l_item_rec      inv_item_grp.item_rec_type;
  x_item_rec      inv_item_grp.item_rec_type;
  x_error_tbl     inv_item_grp.error_tbl_type;
  x_return_status VARCHAR2(1);
  x_error_data    VARCHAR2(32767);
  c_org_code_gim  CONSTANT VARCHAR2(3) := 'GIM';
  c_enable_flag_n CONSTANT VARCHAR2(1) := 'N';

  CURSOR cur_data IS
    SELECT t.rowid row_id
          ,t.organization_code
          ,t.item_code
          ,nvl(t.purchasing_enabled_flag, c_enable_flag_n) purchasing_enabled_flag
          ,nvl(t.mtl_transactions_enabled_flag, c_enable_flag_n) mtl_transactions_enabled_flag
          ,nvl(t.stock_enabled_flag, c_enable_flag_n) stock_enabled_flag
          ,nvl(t.build_in_wip_flag, c_enable_flag_n) build_in_wip_flag
          ,t.update_flag
      FROM xxinv.xxinv_item_update_20140317 t
     WHERE t.message IS NULL;

  -- timer
  l_begin_datetime DATE;
  -- counter
  l_counter NUMBER;
  -- exception
  e_error_excption EXCEPTION;
BEGIN
  fnd_global.apps_initialize(user_id      => 1133,
                             resp_id      => 50778,
                             resp_appl_id => 20005);

  l_begin_datetime           := SYSDATE;
  l_counter                  := 0;
  l_item_rec.last_updated_by := 1133; -- HAND_ADMIN

  -- Item exists in organization_id = 86
  UPDATE xxinv.xxinv_item_update_20140317 t
     SET t.message = 'the item doesn''t exists in the organization'
   WHERE t.message IS NULL
     AND NOT EXISTS
   (SELECT 1
            FROM mtl_system_items_b msi, org_organization_definitions ood
           WHERE msi.organization_id = ood.organization_id
             AND ood.organization_code = t.organization_code
             AND msi.segment1 = t.item_code
          --AND ood.organization_code = c_org_code_gim
          );

  dbms_output.put_line(rpad('org', 10, ' ') || --
                       rpad('item_code', 20, ' ') || --
                       rpad('x_error_data', 50, ' '));
  FOR rec_data IN cur_data LOOP
  
    SELECT msi.inventory_item_id, msi.organization_id
      INTO l_item_rec.inventory_item_id, l_item_rec.organization_id
      FROM mtl_system_items_b msi, org_organization_definitions ood
     WHERE msi.organization_id = ood.organization_id
       AND ood.organization_code = rec_data.organization_code
       AND msi.segment1 = rec_data.item_code
    --AND ood.organization_code = c_org_code_gim
    ;
  
    l_item_rec.purchasing_enabled_flag       := rec_data.purchasing_enabled_flag;
    l_item_rec.mtl_transactions_enabled_flag := rec_data.mtl_transactions_enabled_flag;
    l_item_rec.stock_enabled_flag            := rec_data.stock_enabled_flag;
    l_item_rec.build_in_wip_flag             := rec_data.build_in_wip_flag;
  
    IF x_error_data IS NULL THEN
      inv_item_grp.update_item(p_commit           => fnd_api.g_false,
                               p_lock_rows        => fnd_api.g_true,
                               p_validation_level => fnd_api.g_valid_level_full,
                               p_item_rec         => l_item_rec,
                               x_item_rec         => x_item_rec,
                               x_return_status    => x_return_status,
                               x_error_tbl        => x_error_tbl);
      IF x_error_tbl.count > 0 THEN
        FOR i IN 1 .. x_error_tbl.count LOOP
          x_error_data := x_error_data || '[ TRANSACTION_ID : ' || x_error_tbl(i)
                         .transaction_id;
          x_error_data := x_error_data || '| UNIQUE_ID : ' || x_error_tbl(i)
                         .unique_id;
          x_error_data := x_error_data || '| MESSAGE_NAME : ' || x_error_tbl(i)
                         .message_name;
          x_error_data := x_error_data || '| MESSAGE_TEXT : ' || x_error_tbl(i)
                         .message_text;
          x_error_data := x_error_data || '| TABLE_NAME : ' || x_error_tbl(i)
                         .table_name;
          x_error_data := x_error_data || '| COLUMN_NAME : ' || x_error_tbl(i)
                         .column_name;
          x_error_data := x_error_data || '| ORGANIZATION_ID : ' || x_error_tbl(i)
                         .organization_id;
        END LOOP;
        --dbms_output.put_line(' x_error_data      : ' || x_error_data);
        dbms_output.put_line(rpad(rec_data.organization_code, 10, ' ') || --
                             rpad(rec_data.item_code, 20, ' ') || --
                             rpad(x_error_data, 50, ' '));
        RAISE e_error_excption;
      END IF;
    
      UPDATE xxinv.xxinv_item_update_20140317 t
         SET t.update_flag = 'Y'
       WHERE t.rowid = rec_data.row_id;
    ELSE
      dbms_output.put_line(rpad(rec_data.organization_code, 10, ' ') || --
                           rpad(rec_data.item_code, 20, ' ') || --
                           rpad(x_error_data, 50, ' '));
      RAISE e_error_excption;
    END IF;
    l_counter := l_counter + 1;
  
  END LOOP;

  dbms_output.put_line(' total rows :' || l_counter ||
                       ' rows.  Time-consuming : ' ||
                       (to_char(SYSDATE, 'SSSSS') -
                       to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
EXCEPTION
  WHEN e_error_excption THEN
    dbms_output.put_line('      Exception : ');
    dbms_output.put_line('   x_error_data : ' || x_error_data);
    dbms_output.put_line('              update record ' || l_counter ||
                         ' rows.  Time-consuming : ' ||
                         (to_char(SYSDATE, 'SSSSS') -
                         to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('      Exception : ');
    dbms_output.put_line('        ERRCODE : ' || SQLCODE);
    dbms_output.put_line('        SQLERRM : ' || SQLERRM);
    dbms_output.put_line('   x_error_data : ' || x_error_data);
    dbms_output.put_line('              update record ' || l_counter ||
                         ' rows.  Time-consuming : ' ||
                         (to_char(SYSDATE, 'SSSSS') -
                         to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
    ROLLBACK;
END;
/
