/*==================================================
  Procedure Name :
      insert_rcv_transaction
  Description:
      insert into rcv transaction interface
  History:
      1.00  2012/05/03 Bao   Creation
==================================================*/
PROCEDURE insert_rcv_transaction(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_rcv_rec       IN po.rcv_transactions_interface%ROWTYPE,
                                 p_class_type    IN NUMBER) IS
  l_iface_rcv_rec po.rcv_transactions_interface%ROWTYPE;
  l_iface_lot_rec inv.mtl_transaction_lots_interface%ROWTYPE;
  l_iface_ser_rec inv.mtl_serial_numbers_interface%ROWTYPE;
  --
  l_api_name       CONSTANT VARCHAR2(30) := 'insert_rcv_transaction';
  l_savepoint_name CONSTANT VARCHAR2(30) := '';
  l_lot                 VARCHAR2(2000) := '';
  l_transaction_temp_id NUMBER;
  l_mtl_transaction_id  NUMBER;
  l_num                 NUMBER;
  l_org_id              NUMBER;
BEGIN
  --
  l_iface_rcv_rec := p_rcv_rec;
  --
  l_iface_rcv_rec.last_update_date  := g_last_update_date;
  l_iface_rcv_rec.last_updated_by   := g_last_updated_by;
  l_iface_rcv_rec.creation_date     := g_creation_date;
  l_iface_rcv_rec.created_by        := g_created_by;
  l_iface_rcv_rec.last_update_login := g_last_update_login;
  --
  SELECT rcv_transactions_interface_s.nextval
    INTO l_iface_rcv_rec.interface_transaction_id
    FROM dual;
  --
  IF (g_group_id IS NULL) THEN
    SELECT po.rcv_interface_groups_s.nextval
      INTO g_group_id
      FROM dual;
  END IF;
  --
  l_iface_rcv_rec.processing_status_code   := 'PENDING';
  l_iface_rcv_rec.transaction_status_code  := 'PENDING';
  l_iface_rcv_rec.processing_mode_code     := 'BATCH';
  l_iface_rcv_rec.receipt_source_code      := 'VENDOR';
  l_iface_rcv_rec.source_document_code     := 'PO';
  l_iface_rcv_rec.transaction_type         := 'DELIVER';
  l_iface_rcv_rec.auto_transact_code       := NULL;
  l_iface_rcv_rec.destination_type_code    := 'INVENTORY';
  l_iface_rcv_rec.transaction_date         := g_creation_date;
  l_iface_rcv_rec.validation_flag          := 'Y';
  l_iface_rcv_rec.interface_source_code    := g_mod_name;
  l_iface_rcv_rec.group_id                 := g_group_id;
  l_iface_rcv_rec.interface_source_line_id := l_iface_rcv_rec.interface_transaction_id;
  --
  INSERT INTO po.rcv_transactions_interface
  VALUES l_iface_rcv_rec;
  --
  log('class_type: ' || p_class_type);
  --
  IF (p_class_type <> 0) THEN
    SELECT inv.mtl_material_transactions_s.nextval
      INTO l_mtl_transaction_id
      FROM dual;
    --
    IF (p_class_type = 3) THEN
      l_transaction_temp_id := l_mtl_transaction_id;
    ELSE
      l_transaction_temp_id := NULL;
    END IF;
    --Lot Control
    IF (p_class_type = 1 OR p_class_type = 3) THEN
      l_iface_lot_rec.transaction_interface_id := l_mtl_transaction_id;
      l_iface_lot_rec.last_update_date         := g_last_update_date;
      l_iface_lot_rec.last_updated_by          := g_last_updated_by;
      l_iface_lot_rec.creation_date            := g_creation_date;
      l_iface_lot_rec.created_by               := g_created_by;
      l_iface_lot_rec.last_update_login        := g_last_update_login;
      l_iface_lot_rec.lot_number               := inv_lot_api_pub.auto_gen_lot(p_org_id            => fnd_profile.value('ORG_ID'),
                                                                               p_inventory_item_id => l_iface_rcv_rec.item_id,
                                                                               p_parent_lot_number => NULL,
                                                                               p_subinventory_code => NULL,
                                                                               p_locator_id        => NULL,
                                                                               p_api_version       => 1.0,
                                                                               x_return_status     => x_return_status,
                                                                               x_msg_count         => x_msg_count,
                                                                               x_msg_data          => x_msg_data);
      raise_exception(x_return_status);
      l_iface_lot_rec.transaction_quantity       := l_iface_rcv_rec.quantity;
      l_iface_lot_rec.primary_quantity           := l_iface_rcv_rec.quantity;
      l_iface_lot_rec.serial_transaction_temp_id := l_transaction_temp_id;
      l_iface_lot_rec.product_code               := 'RCV';
      l_iface_lot_rec.product_transaction_id     := l_iface_rcv_rec.interface_transaction_id;
      --
      INSERT INTO inv.mtl_transaction_lots_interface
      VALUES l_iface_lot_rec;
    END IF;
    --
    IF (p_class_type = 3) THEN
      --Both Lot and Serial Control
      l_lot := l_iface_lot_rec.lot_number;
    ELSE
      l_lot := NULL;
    END IF;
    --Serial Control
    IF (p_class_type = 2 OR p_class_type = 3) THEN
      l_iface_ser_rec.transaction_interface_id := l_mtl_transaction_id;
      l_iface_ser_rec.last_update_date         := g_last_update_date;
      l_iface_ser_rec.last_updated_by          := g_last_updated_by;
      l_iface_ser_rec.creation_date            := g_creation_date;
      l_iface_ser_rec.created_by               := g_created_by;
      l_iface_ser_rec.last_update_login        := g_last_update_login;
      l_iface_ser_rec.product_code             := 'RCV';
      l_iface_ser_rec.product_transaction_id   := l_iface_rcv_rec.interface_transaction_id;
      --
      --get org id
      SELECT ood.operating_unit
        INTO l_org_id
        FROM org_organization_definitions ood
       WHERE ood.organization_id = l_iface_rcv_rec.to_organization_id;
      l_num := inv_serial_number_pub.generate_serials(p_org_id    => l_org_id, --fnd_profile.value('ORG_ID'),
                                                      p_item_id   => l_iface_rcv_rec.item_id,
                                                      p_qty       => l_iface_rcv_rec.quantity,
                                                      p_wip_id    => NULL,
                                                      p_rev       => NULL,
                                                      p_lot       => l_lot,
                                                      x_start_ser => l_iface_ser_rec.fm_serial_number,
                                                      x_end_ser   => l_iface_ser_rec.to_serial_number,
                                                      x_proc_msg  => x_msg_data);
      --
      IF (l_num <> 0) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        raise_exception(x_return_status);
      END IF;
      --
      INSERT INTO inv.mtl_serial_numbers_interface
      VALUES l_iface_ser_rec;
    END IF;
  END IF;
END;
