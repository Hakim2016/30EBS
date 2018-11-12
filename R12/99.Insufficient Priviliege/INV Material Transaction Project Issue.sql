/* 
 *  -- Create table
    create table XXINV.XXINV_PROJECT_ISSUE_SOURCE_TMP
    (
      organization_code VARCHAR2(3),
      item_number       VARCHAR2(40),
      subinventory_code VARCHAR2(40),
      locator           VARCHAR2(100),
      uom               VARCHAR2(20),
      qty               NUMBER,
      project_number    VARCHAR2(100),
      task_number       VARCHAR2(100)
    )
    tablespace ADDON_TS_TX_DATA;
    
    1¡¢delete all records in table XXINV.XXINV_PROJECT_ISSUE_SOURCE_TMP
    2¡¢insert into table pending data
    3¡¢run this script
    
    NOTE : If anyone record validate with error , this script will be doing nothing.
           The output panel will show the error message.
           Check the result with following script :
                      SELECT *
                    FROM mtl_transactions_interface_v t
                    --FROM mtl_transactions_interface t
                   WHERE t.creation_date > SYSDATE - 0.1
                    ORDER BY t.transaction_interface_id; 
           Show the success result with following script:
                    SELECT *
                    FROM mtl_material_transactions mmt
                   WHERE mmt.transaction_date > SYSDATE - 1
                   ORDER BY mmt.transaction_id;
*/

DECLARE
  --xxinv_wci_subinv_transfer_pkg
  -- constant
  c_project_segment       CONSTANT VARCHAR2(100) := 'PROJECT_SEGMENT';
  c_transaction_type_id   CONSTANT NUMBER := 111; -- Project Issue
  c_source_code           CONSTANT apps.mtl_transactions_interface.source_code%TYPE := 'FPART On-hand Clearance';
  c_source_header_id      CONSTANT apps.mtl_transactions_interface.source_header_id%TYPE := -1;
  c_source_line_id        CONSTANT apps.mtl_transactions_interface.source_line_id%TYPE := -1;
  c_transaction_reference CONSTANT apps.mtl_transactions_interface.transaction_reference%TYPE := 'FPART On-hand Clearance';
  c_expenditure_type      CONSTANT apps.mtl_transactions_interface.expenditure_type%TYPE := 'Material';
  c_operation             CONSTANT VARCHAR2(100) := 'CHECK_COMBINATION';
  c_appl_short_name       CONSTANT VARCHAR2(100) := 'INV';
  c_key_flex_code         CONSTANT VARCHAR2(100) := 'MTLL';
  c_structure_number      CONSTANT NUMBER := 101;

  l_item_trx_rec apps.mtl_transactions_interface%ROWTYPE;
  -- GS00.0.1145500000.534120015
  l_source_account    apps.gl_code_combinations_kfv.concatenated_segments%TYPE := 'GS00.0.1145500000.534120015.' ||
                                                                                  c_project_segment || '.0.0';
  l_project_segment   VARCHAR2(100);
  l_user_id           NUMBER;
  l_msg_error         VARCHAR2(2000);
  l_commit_flag       VARCHAR2(1) := 'Y';
  l_error_code        apps.mtl_transactions_interface.error_code%TYPE;
  l_error_explanation apps.mtl_transactions_interface.error_explanation%TYPE;

  -- exception
  e_error_raise EXCEPTION;

  CURSOR cur_data IS
    SELECT t.organization_code,
           t.item_number,
           t.subinventory_code,
           t.locator,
           t.uom,
           -1 * t.qty qty,
           t.project_number,
           t.task_number
      FROM xxinv.xxinv_project_issue_source_tmp t
    -- WHERE rownum = 1
    ;

BEGIN
  l_msg_error                      := NULL;
  l_item_trx_rec                   := NULL;
  l_item_trx_rec.last_update_date  := SYSDATE;
  l_item_trx_rec.last_updated_by   := fnd_global.user_id;
  l_item_trx_rec.creation_date     := SYSDATE;
  l_item_trx_rec.created_by        := fnd_global.user_id;
  l_item_trx_rec.last_update_login := fnd_global.login_id;

  FOR rec_data IN cur_data
  LOOP
    l_msg_error := NULL;
    -- dbms_output.put_line(rpad(' ', 50, '='));
    dbms_output.put_line(rpad(rec_data.organization_code, 5, ' ') || --
                         rpad(rec_data.item_number, 30, ' ') || --
                         rpad(rec_data.subinventory_code, 10, ' ') || --
                         rpad(rec_data.locator, 30, ' ') || --
                         rpad(rec_data.uom, 5, ' ') || --
                         rpad(rec_data.qty, 5, ' ') || --
                         rpad(rec_data.project_number, 10, ' ') || --
                         rpad(rec_data.task_number, 20, ' '));
    -- organization validation
    BEGIN
      SELECT ood.organization_id
        INTO l_item_trx_rec.organization_id
        FROM apps.org_organization_definitions ood
       WHERE ood.organization_code = rec_data.organization_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '[organization_code(' || rec_data.organization_code || ')is not existed!]';
    END;
  
    -- secondary_inventory_name validation
    BEGIN
      SELECT msi.secondary_inventory_name
        INTO l_item_trx_rec.subinventory_code
        FROM apps.mtl_secondary_inventories msi
       WHERE msi.organization_id = l_item_trx_rec.organization_id
         AND msi.secondary_inventory_name = rec_data.subinventory_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '    [organization_code(' || rec_data.organization_code ||
                       ') doesn''t exist this subinventory code(' || rec_data.subinventory_code || ')]';
    END;
    -- item validation
    BEGIN
      SELECT msi.inventory_item_id
        INTO l_item_trx_rec.inventory_item_id
        FROM apps.mtl_system_items_b msi
       WHERE msi.segment1 = rec_data.item_number
         AND msi.organization_id = l_item_trx_rec.organization_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [organization_code(' || rec_data.organization_code ||
                       ') doesn''t exist this item(' || rec_data.item_number || ')]';
    END;
    -- uom validation
    BEGIN
      SELECT t.uom_code
        INTO l_item_trx_rec.transaction_uom
        FROM apps.mtl_units_of_measure t
       WHERE t.uom_code = rec_data.uom;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [transaction_uom(' || rec_data.uom || ') doesn''t exist]';
    END;
  
    -- locator validation
    IF rec_data.locator IS NOT NULL THEN
      apps.fnd_profile.put('MFG_ORGANIZATION_ID', l_item_trx_rec.organization_id);
      IF apps.fnd_flex_keyval.validate_segs(operation        => c_operation, --'CHECK_COMBINATION',
                                            appl_short_name  => c_appl_short_name, --'INV',
                                            key_flex_code    => c_key_flex_code, --'MTLL',
                                            structure_number => c_structure_number, --101,
                                            concat_segments  => rec_data.locator, --p_concat_segments, -- 'T1.0208.MFG1\.0\.EQ.',
                                            values_or_ids    => 'V') THEN
      
        SELECT mil.inventory_location_id
          INTO l_item_trx_rec.locator_id
          FROM apps.mtl_item_locations_kfv mil
         WHERE mil.organization_id = l_item_trx_rec.organization_id --86 \*p_organization_id*\
           AND mil.subinventory_code = rec_data.subinventory_code --'FPART' \*p_subinventory_code*\
           AND mil.concatenated_segments = apps.fnd_flex_keyval.concatenated_ids -- p_concat_segments
           AND mil.enabled_flag = 'Y';
        --dbms_output.put_line(l_item_trx_rec.locator_id);
      ELSE
        l_msg_error := l_msg_error || '[locator doesn''t exist]';
      END IF;
    END IF;
  
    -- project_number validation
    BEGIN
      SELECT ppa.project_id
        INTO l_item_trx_rec.source_project_id
        FROM apps.pa_projects_all ppa
       WHERE ppa.segment1 = rec_data.project_number;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [project_number(' || rec_data.project_number || ') doesn''t exist]';
    END;
  
    -- task number validation
    BEGIN
      SELECT pt.task_id
        INTO l_item_trx_rec.source_task_id
        FROM apps.pa_tasks pt
       WHERE pt.task_number = rec_data.task_number
         AND pt.project_id = l_item_trx_rec.source_project_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [task_number(' || rec_data.task_number || ') doesn''t exist]';
    END;
  
    -- on-hand quantity validation
    BEGIN
      SELECT DISTINCT ppa.segment1
        INTO l_project_segment
        FROM mtl_onhand_quantities_detail moqd,
             pa_projects_all              ppa
       WHERE moqd.project_id = ppa.project_id
         AND moqd.organization_id = l_item_trx_rec.organization_id
         AND moqd.inventory_item_id = l_item_trx_rec.inventory_item_id
         AND moqd.subinventory_code = l_item_trx_rec.subinventory_code
         AND moqd.locator_id = l_item_trx_rec.locator_id
         AND moqd.primary_transaction_quantity <> 0;
    EXCEPTION
      --WHEN no_data_found THEN
      WHEN too_many_rows THEN
        l_msg_error := l_msg_error || '   [on-hand quantity exist multiple project number]';
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [on-hand quantity don''t exist]';
    END;
  
    -- distribution_account validation
    BEGIN
      SELECT gcc.code_combination_id
        INTO l_item_trx_rec.distribution_account_id
        FROM apps.gl_code_combinations_kfv gcc
       WHERE gcc.concatenated_segments = REPLACE(l_source_account, c_project_segment, l_project_segment);
      dbms_output.put_line('Source : ' || REPLACE(l_source_account, c_project_segment, l_project_segment));
    EXCEPTION
      WHEN OTHERS THEN
        l_msg_error := l_msg_error || '   [distribution_account(' ||
                       REPLACE(l_source_account, c_project_segment, l_project_segment) || ') doesn''t exist]';
    END;
  
    IF l_msg_error IS NULL THEN
      SELECT apps.mtl_material_transactions_s.nextval
        INTO l_item_trx_rec.transaction_interface_id
        FROM dual;
      l_item_trx_rec.transaction_type_id   := c_transaction_type_id;
      l_item_trx_rec.transaction_mode      := 3;
      l_item_trx_rec.process_flag          := 1;
      l_item_trx_rec.transaction_header_id := l_item_trx_rec.transaction_interface_id;
      l_item_trx_rec.subinventory_code     := rec_data.subinventory_code;
      l_item_trx_rec.transaction_quantity  := rec_data.qty;
      l_item_trx_rec.transaction_uom       := rec_data.uom;
      l_item_trx_rec.transaction_date      := SYSDATE;
      l_item_trx_rec.expenditure_type      := c_expenditure_type;
      l_item_trx_rec.pa_expenditure_org_id := l_item_trx_rec.organization_id;
      l_item_trx_rec.transaction_source_id := l_item_trx_rec.distribution_account_id;
      /*l_item_trx_rec.distribution_account_id := l_distribution_account_id;
      l_item_trx_rec.locator_id              := l_locator_id;
      l_item_trx_rec.source_project_id       := 1;
      l_item_trx_rec.source_task_id          := 1;*/
      l_item_trx_rec.source_code           := c_source_code; --'TEST_ONLY';
      l_item_trx_rec.source_header_id      := c_source_header_id; --987654321;
      l_item_trx_rec.source_line_id        := c_source_line_id; --987654321;
      l_item_trx_rec.transaction_reference := c_transaction_reference;
    
      INSERT INTO inv.mtl_transactions_interface
      VALUES l_item_trx_rec;
    ELSE
      sys.dbms_output.put_line('             l_msg_error : ' || l_msg_error);
      --RAISE e_error_raise;
      l_commit_flag := 'N';
    END IF;
    dbms_output.put_line('');
  END LOOP;
  IF l_commit_flag <> 'Y' THEN
    ROLLBACK;
  END IF;
EXCEPTION
  WHEN e_error_raise THEN
    sys.dbms_output.put_line(' EXCEPTION : ' || l_msg_error);
    ROLLBACK;
  WHEN OTHERS THEN
    sys.dbms_output.put_line(' EXCEPTION : ' || l_msg_error);
    sys.dbms_output.put_line(' SQLCODE   : ' || SQLCODE);
    sys.dbms_output.put_line(' SQLERRM   : ' || SQLERRM);
    ROLLBACK;  
END;
