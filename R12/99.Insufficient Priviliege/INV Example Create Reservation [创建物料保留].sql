PROCEDURE create_reservation(p_requirement_date IN DATE,
                             x_errbuf           OUT VARCHAR2,
                             x_retcode          OUT VARCHAR2) IS
  l_api_name CONSTANT VARCHAR2(30) := 'create_reservation';
  l_quantity_reserved NUMBER;
  l_reservation_id    NUMBER;
  l_return_status     VARCHAR2(200);
  l_msg_data          VARCHAR2(200);
  l_msg_count         NUMBER;
  l_s                 NUMBER;
  l_rsv_rec           inv_reservation_global.mtl_reservation_rec_type;
  l_serial_number     inv_reservation_global.serial_number_tbl_type;
  l_serial_number2    inv_reservation_global.serial_number_tbl_type;
  --
  exp_next EXCEPTION;
  --
  CURSOR cur_wip IS
    SELECT xpjt.wip_entity_id
      FROM xxwip_production_job_temp xpjt
     WHERE xpjt.session_id = g_session_id
     ORDER BY xpjt.schedule_start_date;
  --
  CURSOR cur_reserve(p_wip_entity_id NUMBER) IS
  --
    SELECT xmat.rowid,
           xmat.organization_id,
           xmat.wip_entity_id,
           xmat.component_item_id,
           xmat.operation_seq_num,
           xmat.repetitive_schedule_id,
           xmat.supply_subinventory,
           xmat.supply_locator_id,
           xmat.lot_number,
           msiv.primary_uom_code,
           xmat.qty_supplied,
           we.wip_entity_name,
           msiv.segment1 item_number
      FROM xxwip_material_available_temp xmat,
           mtl_system_items_vl           msiv,
           wip_entities                  we
     WHERE xmat.organization_id = msiv.organization_id
       AND xmat.component_item_id = msiv.inventory_item_id
       AND xmat.supply_subinventory IS NOT NULL
       AND xmat.group_id = g_group_id
       AND xmat.wip_entity_id = p_wip_entity_id
       AND xmat.organization_id = we.organization_id
       AND xmat.wip_entity_id = we.wip_entity_id
       AND nvl(xmat.qty_supplied, 0) > 0;
  l_item_number VARCHAR2(40);
BEGIN
  x_retcode := '0';
  FOR rec_wip IN cur_wip LOOP
    SAVEPOINT reserve1;
    BEGIN
      FOR rec IN cur_reserve(rec_wip.wip_entity_id) LOOP
        SELECT xxwip_material_supply_s.nextval INTO l_s FROM dual;
        l_rsv_rec.reservation_id                 := NULL;
        l_rsv_rec.requirement_date               := p_requirement_date;
        l_rsv_rec.organization_id                := rec.organization_id;
        l_rsv_rec.inventory_item_id              := rec.component_item_id;
        l_rsv_rec.demand_source_type_id          := 13;
        l_rsv_rec.demand_source_name             := rec.wip_entity_name;
        l_rsv_rec.demand_source_header_id        := NULL;
        l_rsv_rec.demand_source_line_id          := NULL;
        l_rsv_rec.demand_source_delivery         := NULL;
        l_rsv_rec.primary_uom_code               := NULL;
        l_rsv_rec.primary_uom_id                 := NULL;
        l_rsv_rec.secondary_uom_code             := NULL;
        l_rsv_rec.secondary_uom_id               := NULL;
        l_rsv_rec.reservation_uom_code           := rec.primary_uom_code;
        l_rsv_rec.reservation_uom_id             := NULL;
        l_rsv_rec.reservation_quantity           := rec.qty_supplied;
        l_rsv_rec.primary_reservation_quantity   := NULL;
        l_rsv_rec.secondary_reservation_quantity := NULL;
        l_rsv_rec.detailed_quantity              := NULL;
        l_rsv_rec.secondary_detailed_quantity    := NULL;
        l_rsv_rec.autodetail_group_id            := NULL;
        l_rsv_rec.external_source_code           := NULL;
        l_rsv_rec.external_source_line_id        := NULL;
        l_rsv_rec.supply_source_type_id          := 13;
        l_rsv_rec.supply_source_header_id        := NULL;
        l_rsv_rec.supply_source_line_id          := NULL;
        l_rsv_rec.supply_source_name             := l_s;
        l_rsv_rec.supply_source_line_detail      := NULL;
        l_rsv_rec.revision                       := NULL;
        l_rsv_rec.subinventory_code              := rec.supply_subinventory;
        l_rsv_rec.subinventory_id                := NULL;
        l_rsv_rec.locator_id                     := rec.supply_locator_id;
        l_rsv_rec.lot_number                     := rec.lot_number;
        l_rsv_rec.lot_number_id                  := NULL;
        l_rsv_rec.pick_slip_number               := NULL;
        l_rsv_rec.lpn_id                         := NULL;
        l_rsv_rec.attribute_category             := NULL;
        l_rsv_rec.attribute1                     := NULL;
        l_rsv_rec.attribute2                     := NULL;
        l_rsv_rec.attribute3                     := NULL;
        l_rsv_rec.attribute4                     := NULL;
        l_rsv_rec.attribute5                     := NULL;
        l_rsv_rec.attribute6                     := NULL;
        l_rsv_rec.attribute7                     := NULL;
        l_rsv_rec.attribute8                     := NULL;
        l_rsv_rec.attribute9                     := NULL;
        l_rsv_rec.attribute10                    := NULL;
        l_rsv_rec.attribute11                    := NULL;
        l_rsv_rec.attribute12                    := NULL;
        l_rsv_rec.attribute13                    := NULL;
        l_rsv_rec.attribute14                    := NULL;
        l_rsv_rec.attribute15                    := NULL;
        l_rsv_rec.ship_ready_flag                := NULL;
        l_rsv_rec.staged_flag                    := NULL;
        l_item_number                            := rec.item_number;
        inv_reservation_pub.create_reservation(p_api_version_number       => '1.0',
                                               p_init_msg_lst             => fnd_api.g_false,
                                               x_return_status            => l_return_status,
                                               x_msg_count                => l_msg_count,
                                               x_msg_data                 => l_msg_data,
                                               p_rsv_rec                  => l_rsv_rec,
                                               p_serial_number            => l_serial_number,
                                               x_serial_number            => l_serial_number2,
                                               p_partial_reservation_flag => fnd_api.g_false,
                                               p_force_reservation_flag   => fnd_api.g_false,
                                               p_validation_flag          => fnd_api.g_true,
                                               p_over_reservation_flag    => 0,
                                               x_quantity_reserved        => l_quantity_reserved,
                                               x_reservation_id           => l_reservation_id,
                                               p_partial_rsv_exists       => FALSE,
                                               p_substitute_flag          => FALSE);
        IF l_return_status <> 'S' THEN
          RAISE exp_next;
        ELSE
          INSERT INTO xxwip_material_supply xms
            (supply_id
            ,supply_type --added 2012.04.06 
            ,organization_id
            ,wip_entity_id
            ,inventory_item_id
            ,operation_seq_num
            ,repetitive_schedule_id
            ,subinventory_code
            ,locator_id
            ,lot_number
            ,quantity_reserved
            ,quantity_issued
            ,reservation_id
            ,object_version_number
            ,creation_date
            ,created_by
            ,last_updated_by
            ,last_update_date)
          VALUES
            (l_s
            ,'ISSUE'
            , --Added 2012.04.06
             rec.organization_id
            ,rec.wip_entity_id
            ,rec.component_item_id
            ,rec.operation_seq_num
            ,rec.repetitive_schedule_id
            ,rec.supply_subinventory
            ,rec.supply_locator_id
            ,rec.lot_number
            ,l_quantity_reserved
            ,NULL
            ,l_reservation_id
            ,1
            ,g_creation_date
            ,g_created_by
            ,g_last_updated_by
            ,g_last_updated_date);
          --
          UPDATE xxwip_material_available_temp xmat
             SET xmat.qty_supply_reserving = l_quantity_reserved
           WHERE xmat.rowid = rec.rowid;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN exp_next THEN
        ROLLBACK TO reserve1;
        UPDATE xxwip_material_available_temp xmat
           SET xmat.process_status  = 'E'
              ,xmat.process_message = substrb(fnd_msg_pub.get(p_msg_index => fnd_msg_pub.count_msg,
                                                              p_encoded   => fnd_api.g_false),
                                              1,
                                              200);
        x_retcode := '1';
        x_errbuf  := 'Item Number: ' || l_item_number || ', error msg: ' ||
                     substrb(fnd_msg_pub.get(p_msg_index => fnd_msg_pub.count_msg,
                                             p_encoded   => fnd_api.g_false),
                             1,
                             200);
    END;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => substrb(SQLERRM, 1, 240));
    x_retcode := '2';
    x_errbuf  := fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false);
END create_reservation;
