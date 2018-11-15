
SELECT /*xms.reservation_id, xms.rowid,*/
 xms.*
  FROM xxwip_material_supply xms
 WHERE xms.wip_entity_id = 291567 /*p_wip_entity_id*/
   AND xms.organization_id = 86 /*p_organization_id*/
   AND xms.supply_type = 'ISSUE' -- Added 2012.04.06
   AND NOT EXISTS (SELECT 1
          FROM xxwip_sos_header       xsh,
               xxwip_sos_line         xsl,
               xxwip_sos_distribution xsd
         WHERE xsh.sos_header_id = xsl.sos_header_id
           AND xsl.sos_line_id = xsd.sos_line_id
           AND xsl.sos_header_id = xsd.sos_header_id
           AND xsh.enabled_flag = 'Y'
           AND xsd.supply_id = xms.supply_id);

/*PROCEDURE delete_reservation(p_session_id      IN NUMBER,
                   p_organization_id IN NUMBER,
                   x_errbuf          OUT VARCHAR2,
                   x_retcode         OUT VARCHAR2) IS
*/
DECLARE
  l_resr_count NUMBER := 0;
  -- p_session_id      NUMBER := 70337;
  p_wip_entity_id   NUMBER := 291567;
  p_organization_id NUMBER := 86;
  x_errbuf          VARCHAR2(2000);
  x_retcode         VARCHAR2(10);

  l_api_name CONSTANT VARCHAR2(30) := 'delete_reservation';
  l_quantity_reserved NUMBER;
  l_reservation_id    NUMBER;
  l_return_status     VARCHAR2(200);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;
  l_s                 NUMBER;
  l_rsv_rec           inv_reservation_global.mtl_reservation_rec_type;
  l_serial_number     inv_reservation_global.serial_number_tbl_type;
  l_errbuf            VARCHAR2(2000);
  l_retcode           VARCHAR2(20);
  exp_next EXCEPTION;
  --
  /*CURSOR cur_wip IS
  SELECT xpjt.wip_entity_id
    FROM xxwip_production_job_temp xpjt
   WHERE xpjt.session_id = p_session_id
   ORDER BY xpjt.schedule_start_date;*/
  --
  CURSOR cur_reserve(p_wip_entity_id NUMBER) IS
  --
    SELECT xms.reservation_id, xms.rowid
      FROM xxwip_material_supply xms
     WHERE xms.wip_entity_id = p_wip_entity_id
       AND xms.organization_id = p_organization_id
       AND xms.supply_type = 'ISSUE' -- Added 2012.04.06
       AND NOT EXISTS (SELECT 1
              FROM xxwip_sos_header       xsh,
                   xxwip_sos_line         xsl,
                   xxwip_sos_distribution xsd
             WHERE xsh.sos_header_id = xsl.sos_header_id
               AND xsl.sos_line_id = xsd.sos_line_id
               AND xsl.sos_header_id = xsd.sos_header_id
               AND xsh.enabled_flag = 'Y'
               AND xsd.supply_id = xms.supply_id)
       FOR UPDATE OF xms.supply_id NOWAIT;

BEGIN
  -- fnd_global.apps_initialize(1393, 50778, 20005);
  x_retcode := '0';
  -- FOR rec_wip IN cur_wip LOOP
  BEGIN
    SAVEPOINT unreserve1;
    --FOR rec IN cur_reserve(rec_wip.wip_entity_id) LOOP
    FOR rec IN cur_reserve(p_wip_entity_id) LOOP
      l_rsv_rec.reservation_id                 := rec.reservation_id;
      l_rsv_rec.requirement_date               := NULL;
      l_rsv_rec.organization_id                := NULL;
      l_rsv_rec.inventory_item_id              := NULL;
      l_rsv_rec.demand_source_type_id          := NULL;
      l_rsv_rec.demand_source_name             := NULL;
      l_rsv_rec.demand_source_header_id        := NULL;
      l_rsv_rec.demand_source_line_id          := NULL;
      l_rsv_rec.demand_source_delivery         := NULL;
      l_rsv_rec.primary_uom_code               := NULL;
      l_rsv_rec.primary_uom_id                 := NULL;
      l_rsv_rec.secondary_uom_code             := NULL;
      l_rsv_rec.secondary_uom_id               := NULL;
      l_rsv_rec.reservation_uom_code           := NULL;
      l_rsv_rec.reservation_uom_id             := NULL;
      l_rsv_rec.reservation_quantity           := NULL;
      l_rsv_rec.primary_reservation_quantity   := NULL;
      l_rsv_rec.secondary_reservation_quantity := NULL;
      l_rsv_rec.detailed_quantity              := NULL;
      l_rsv_rec.secondary_detailed_quantity    := NULL;
      l_rsv_rec.autodetail_group_id            := NULL;
      l_rsv_rec.external_source_code           := NULL;
      l_rsv_rec.external_source_line_id        := NULL;
      l_rsv_rec.supply_source_type_id          := NULL;
      l_rsv_rec.supply_source_header_id        := NULL;
      l_rsv_rec.supply_source_line_id          := NULL;
      l_rsv_rec.supply_source_name             := NULL;
      l_rsv_rec.supply_source_line_detail      := NULL;
      l_rsv_rec.revision                       := NULL;
      l_rsv_rec.subinventory_code              := NULL;
      l_rsv_rec.subinventory_id                := NULL;
      l_rsv_rec.locator_id                     := NULL;
      l_rsv_rec.lot_number                     := NULL;
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
      DELETE FROM xxwip_material_supply xms WHERE xms.rowid = rec.rowid;
    
      SELECT COUNT(1)
        INTO l_resr_count
        FROM mtl_reservations t
       WHERE t.reservation_id = rec.reservation_id;
      IF l_resr_count > 0 THEN
        inv_reservation_pub.delete_reservation(p_api_version_number => '1.0',
                                               p_init_msg_lst       => fnd_api.g_false,
                                               x_return_status      => l_return_status,
                                               x_msg_count          => l_msg_count,
                                               x_msg_data           => l_msg_data,
                                               p_rsv_rec            => l_rsv_rec,
                                               p_serial_number      => l_serial_number);
      
        dbms_output.put_line('  reservation_id :  ' || rec.reservation_id ||
                             '  l_return_status : ' || l_return_status);
      ELSE
        dbms_output.put_line('  reservation_id :  ' || rec.reservation_id ||
                             '在 mtl_reservations 中不存在!');
      END IF;
      IF l_return_status <> 'S' THEN
        --
        RAISE exp_next;
      ELSE
        NULL;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN exp_next THEN
      ROLLBACK TO unreserve1;
      x_retcode := '1';
  END;
  --END LOOP;
  IF x_retcode = '1' THEN
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => l_msg_count,
                              p_data    => l_msg_data);
    IF l_msg_count > 1 THEN
      l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last,
                                    p_encoded   => fnd_api.g_false);
    END IF;
    x_errbuf := substrb(l_msg_data, 1, 2000);
  END IF;
  --del xxwip_production_job_temp data
  /*xxwip_check_reserve_pkg.delete_temp(p_session_id => p_session_id,
  x_errbuf     => l_errbuf,
  x_retcode    => l_retcode);*/
  dbms_output.put_line('   x_retcode : ' || x_retcode);
  dbms_output.put_line('   x_errbuf  : ' || x_errbuf);
EXCEPTION
  WHEN OTHERS THEN
    --del xxwip_production_job_temp data
    /*xxwip_check_reserve_pkg.delete_temp(p_session_id => p_session_id,
    x_errbuf     => l_errbuf,
    x_retcode    => l_retcode);*/
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'XXWIP_CHECK_RESERVE_PKG' /*g_pkg_name*/,
                            p_procedure_name => 'delete_reservation' /*l_api_name*/,
                            p_error_text     => substrb(SQLERRM, 1, 240));
    xxfnd_conc_utl.log_message_list;
    x_retcode := '2';
    x_errbuf  := SQLERRM;
  
    dbms_output.put_line('  EXCEPTION x_retcode : ' || x_retcode);
    dbms_output.put_line('  EXCEPTION x_errbuf  : ' || x_errbuf);
END;
--END delete_reservation;
