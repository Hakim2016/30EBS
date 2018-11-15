-- Item Property Update

/*
    1、CREATE TABLE XXINV.XXINV_ITEM_UPDATE_20150423
    (
          ORGANIZATION_CODE             VARCHAR2(3),
          ITEM_CODE                     VARCHAR2(40),
          INVENTORY_ITEM_STATUS_CODE    VARCHAR2(20),
          ORGANIZATION_ID               NUMBER,
          INVENTORY_ITEM_ID             NUMBER,
          PROCESS_STATUS                VARCHAR2(1),
          PROCESS_DATE                  DATE,
          PROCESS_MESSAGE               VARCHAR2(4000)

    ) tablespace ADDON_TS_TX_DATA;   
    comment on table XXINV.xxinv_item_update_20150423
      is 'Item INVENTORY_ITEM_STATUS_CODE Update';
    
    2、INSERT records into table.
    
    3、backup data
        Create table xxinv_item_bk150423 as
        SELECT *
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           AND EXISTS (SELECT 1
                  FROM xxinv.xxinv_item_update_20150423 t,
                       org_organization_definitions     ood
                 WHERE 1 = 1
                   AND t.organization_code = ood.organization_code
                   AND msi.organization_id = ood.organization_id
                   AND msi.segment1 = t.item_code);
    
    4、run this script    
*/

-- set serveroutput on size 1000000000; 

DECLARE
  l_item_rec      inv_item_grp.item_rec_type;
  x_item_rec      inv_item_grp.item_rec_type;
  x_error_tbl     inv_item_grp.error_tbl_type;
  x_return_status VARCHAR2(1);
  x_error_data    VARCHAR2(32767);
  c_org_code_gim  CONSTANT VARCHAR2(3) := 'GIM';
  c_enable_flag_n CONSTANT VARCHAR2(1) := 'N';

  c_process_e VARCHAR2(1) := 'E';
  c_process_s VARCHAR2(1) := 'S';
  c_process_p VARCHAR2(1) := 'P';

  CURSOR cur_data IS
    SELECT t.rowid row_id,
           t.organization_code,
           t.item_code,
           t.inventory_item_status_code,
           t.organization_id,
           t.inventory_item_id,
           t.process_status,
           t.process_date,
           t.process_message
      FROM xxinv.xxinv_item_update_20150423 t
     WHERE 1 = 1
       AND nvl(t.process_status, c_process_p) = c_process_p;

  -- timer
  l_begin_datetime DATE;
  -- counter
  l_counter NUMBER;
  -- exception
  e_error_excption EXCEPTION;
BEGIN
  --fnd_global.apps_initialize(user_id => 2657, resp_id => 50676, resp_appl_id => 660);

  l_begin_datetime           := SYSDATE;
  l_counter                  := 0;
  l_item_rec.last_updated_by := 2657; -- HAND_ADMIN

  UPDATE xxinv.xxinv_item_update_20150423 t
     SET t.organization_id =
         (SELECT ood.organization_id
            FROM org_organization_definitions ood
           WHERE t.organization_code = ood.organization_code)
   WHERE 1 = 1
     AND nvl(t.process_status, c_process_p) = c_process_p;

  UPDATE xxinv.xxinv_item_update_20150423 t
     SET t.inventory_item_id =
         (SELECT msi.inventory_item_id
            FROM mtl_system_items_b msi
           WHERE t.organization_id = msi.organization_id
             AND t.item_code = msi.segment1)
   WHERE 1 = 1
     AND nvl(t.process_status, c_process_p) = c_process_p;

  UPDATE xxinv.xxinv_item_update_20150423 t
     SET t.process_status  = c_process_e, --
         t.process_date    = SYSDATE,
         t.process_message = 'item status is invalid'
   WHERE 1 = 1
     AND nvl(t.process_status, c_process_p) = c_process_p
     AND NOT EXISTS (SELECT mit.inventory_item_status_code
            FROM mtl_item_status mit
           WHERE nvl(mit.disable_date, SYSDATE + 1) > SYSDATE
             AND mit.inventory_item_status_code <> 'Pending'
             AND mit.inventory_item_status_code = t.inventory_item_status_code);

  UPDATE xxinv.xxinv_item_update_20150423 t
     SET t.process_status  = c_process_e, --
         t.process_date    = SYSDATE,
         t.process_message = decode(t.organization_id, --
                                    NULL,
                                    'orgaznization is invalid',
                                    decode(t.inventory_item_id, NULL, 'item is invalid', 'others error'))
   WHERE 1 = 1
     AND nvl(t.process_status, c_process_p) = c_process_p
     AND (t.organization_id IS NULL OR t.inventory_item_id IS NULL);

  dbms_output.put_line(rpad('org', 10, ' ') || --
                       rpad('item_code', 20, ' ') || --
                       rpad('x_error_data', 50, ' '));
  FOR rec_data IN cur_data
  LOOP
  
    l_item_rec.organization_id            := rec_data.organization_id;
    l_item_rec.inventory_item_id          := rec_data.inventory_item_id;
    l_item_rec.inventory_item_status_code := rec_data.inventory_item_status_code;
  
    IF x_error_data IS NULL THEN
      inv_item_grp.update_item(p_commit           => fnd_api.g_false,
                               p_lock_rows        => fnd_api.g_true,
                               p_validation_level => fnd_api.g_valid_level_full,
                               p_item_rec         => l_item_rec,
                               x_item_rec         => x_item_rec,
                               x_return_status    => x_return_status,
                               x_error_tbl        => x_error_tbl);
      IF x_error_tbl.count > 0 THEN
        FOR i IN 1 .. x_error_tbl.count
        LOOP
          x_error_data := x_error_data || '[ TRANSACTION_ID : ' || x_error_tbl(i).transaction_id;
          x_error_data := x_error_data || '| UNIQUE_ID : ' || x_error_tbl(i).unique_id;
          x_error_data := x_error_data || '| MESSAGE_NAME : ' || x_error_tbl(i).message_name;
          x_error_data := x_error_data || '| MESSAGE_TEXT : ' || x_error_tbl(i).message_text;
          x_error_data := x_error_data || '| TABLE_NAME : ' || x_error_tbl(i).table_name;
          x_error_data := x_error_data || '| COLUMN_NAME : ' || x_error_tbl(i).column_name;
          x_error_data := x_error_data || '| ORGANIZATION_ID : ' || x_error_tbl(i).organization_id;
        END LOOP;
        --dbms_output.put_line(' x_error_data      : ' || x_error_data);
        dbms_output.put_line(rpad(rec_data.organization_code, 10, ' ') || --
                             rpad(rec_data.item_code, 20, ' ') || --
                             rpad(x_error_data, 50, ' '));
        RAISE e_error_excption;
      END IF;
    
      UPDATE xxinv.xxinv_item_update_20150423 t
         SET t.process_status = c_process_s
       WHERE t.rowid = rec_data.row_id;
    ELSE
      dbms_output.put_line(rpad(rec_data.organization_code, 10, ' ') || --
                           rpad(rec_data.item_code, 20, ' ') || --
                           rpad(x_error_data, 50, ' '));
      RAISE e_error_excption;
    END IF;
    l_counter := l_counter + 1;
    IF MOD(l_counter, 200) = 0 THEN
      COMMIT;
    END IF;
  END LOOP;

  dbms_output.put_line(' total rows :' || l_counter || ' rows.  Time-consuming : ' ||
                       (to_char(SYSDATE, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
EXCEPTION
  WHEN e_error_excption THEN
    dbms_output.put_line('      Exception : ');
    dbms_output.put_line('   x_error_data : ' || x_error_data);
    dbms_output.put_line('              update record ' || l_counter || ' rows.  Time-consuming : ' ||
                         (to_char(SYSDATE, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('      Exception : ');
    dbms_output.put_line('        ERRCODE : ' || SQLCODE);
    dbms_output.put_line('        SQLERRM : ' || SQLERRM);
    dbms_output.put_line('   x_error_data : ' || x_error_data);
    dbms_output.put_line('              update record ' || l_counter || ' rows.  Time-consuming : ' ||
                         (to_char(SYSDATE, 'SSSSS') - to_char(l_begin_datetime, 'SSSSS')) || ' seconds');
    ROLLBACK;
END;
