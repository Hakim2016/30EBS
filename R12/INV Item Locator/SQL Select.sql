SELECT mlk.concatenated_segments,
       mlk.organization_id,
       mlk.segment19,
       mlk.segment20,
       xxinv_common_utl.get_key_concatenated_value('INV', 'MTLL', 101, mlk.inventory_location_id, mlk.organization_id),
       xxinv_common_utl.get_key_concatenated_desc('INV', 'MTLL', 101, mlk.inventory_location_id, mlk.organization_id)
       
  FROM mtl_item_locations_kfv mlk
 WHERE 1 = 1
   AND mlk.organization_id = 86
   AND mlk.segment19 IS NOT NULL;

SELECT *
  FROM xxinv_item_locations_kfv t
 WHERE t.concatenated_seg_values IS NOT NULL
   AND t.segment19 IS NOT NULL;

BEGIN
  apps.fnd_profile.put('MFG_ORGANIZATION_ID', 86);
END;
