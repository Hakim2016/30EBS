SELECT &p_item_flex c_item_flex,
       pit.revision,
       &p_cat_flex c_cat_flex,
       pit.tag_number,
       pit.subinventory,
       &p_loc_flex c_loc_flex,
       loc.inventory_location_id loc_id,
       nvl(decode(pit.void_flag, 1, 0, 2, pit.tag_quantity_at_standard_uom), 0) quantity,
       --Modified by fandong.chen 2013-03-06 begin
       --msi.primary_uom_code uom,
       msi.primary_unit_of_measure uom,
       msi.inventory_item_id inventory_item_id,
       xxinv_physical_inv_pkg.get_uom2(msi.primary_unit_of_measure) uom2,
       inv_convert.inv_um_convert(msi.inventory_item_id,
                                  msi.primary_unit_of_measure,
                                  xxinv_physical_inv_pkg.get_uom2(msi.primary_unit_of_measure)) conversion_rate,
       --Modified by fandong.chen 2013-03-06 end    
       decode(mp.process_enabled_flag,
              'Y',
              round(nvl(mpa.actual_cost, 0), :c_ext_prec),
              round(nvl(pit.item_cost, 0), :c_ext_prec)) cost,
       ppx.last_name counted_by,
       decode(pit.item_cost, NULL, 1, 2) expense_flag,
       pit.parent_lpn_id parent_lpn_id,
       pit.outermost_lpn_id outermost_lpn_id,
       pit.cost_group_id cost_group_id,
       mpa.lot_number,
       mpa.system_quantity,
       mpa.system_quantity * decode(mp.process_enabled_flag,
                                    'Y',
                                    round(nvl(mpa.actual_cost, 0), :c_ext_prec),
                                    round(nvl(pit.item_cost, 0), :c_ext_prec)) onhand_amount,
       nvl(decode(pit.void_flag, 1, 0, 2, pit.tag_quantity_at_standard_uom), 0) - nvl(mpa.system_quantity, 0) adj_quantity_init,
       (nvl(decode(pit.void_flag, 1, 0, 2, pit.tag_quantity_at_standard_uom), 0) - nvl(mpa.system_quantity, 0)) *
       decode(mp.process_enabled_flag,
              'Y',
              round(nvl(mpa.actual_cost, 0), :c_ext_prec),
              round(nvl(pit.item_cost, 0), :c_ext_prec)) adj_amount,
       msi.description item_description,
       xxinv_common_utl.get_available_qty(msi.inventory_item_id,
                                          msi.organization_id,
                                          pit.subinventory,
                                          loc.inventory_location_id,
                                          mpa.lot_number,
                                          mpa.serial_number,
                                          'ATR') available_quantity
  FROM mtl_system_items_vl      msi,
       mtl_categories           mc,
       mtl_item_categories      mic,
       mtl_item_locations       loc,
       per_people_x             ppx,
       mtl_phy_inv_tags_cost_v  pit,
       mtl_parameters           mp,
       mtl_physical_adjustments mpa
 WHERE pit.organization_id = :p_org_id
   AND pit.physical_inventory_id = :p_phys_inv_id
   AND msi.organization_id = pit.organization_id
   AND mic.organization_id = pit.organization_id
   AND loc.organization_id(+) = pit.organization_id
   AND mp.organization_id = pit.organization_id
   AND pit.inventory_item_id = msi.inventory_item_id
   AND pit.inventory_item_id = mic.inventory_item_id
   AND mpa.organization_id(+) = pit.organization_id
   AND pit.inventory_item_id = mpa.inventory_item_id(+)
   AND pit.physical_inventory_id = mpa.physical_inventory_id(+)
   AND pit.adjustment_id = mpa.adjustment_id(+)
   AND mic.category_set_id = :p_category_set_id
   AND mic.category_id = mc.category_id
   AND pit.locator_id = loc.inventory_location_id(+)
   AND pit.counted_by_employee_id = ppx.person_id(+)
 &p_condition
      --Added by fandong.chen 2013-03-06 begin
   AND (:p_uom_type = 'NONE' OR
       (:p_uom_type = 'UOM1' AND xxinv_physical_inv_pkg.get_uom2(msi.primary_unit_of_measure) IS NULL OR
       :p_uom_type = 'UOM2' AND xxinv_physical_inv_pkg.get_uom2(msi.primary_unit_of_measure) IS NOT NULL))
--Added by fandong.chen 2013-03-06 end
 ORDER BY &c_order_by
