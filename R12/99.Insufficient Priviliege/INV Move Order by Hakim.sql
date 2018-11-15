SELECT *
  FROM mtl_txn_request_headers_v mvh,
       mtl_txn_request_lines_v   mvl
 WHERE 1 = 1
   AND mvh.header_id = mvl.header_id
   AND mvh.request_number = '3149164';


SELECT header_id,
       organization_id,
       to_account_id,
       header_status,
       request_number,
       description,
       move_order_type,
       transaction_type_id,
       transaction_type_name,
       ship_to_location_id,
       from_subinventory_code,
       to_subinventory_code,
       date_required,
       status_date,
       last_updated_by,
       last_update_login,
       last_update_date,
       created_by,
       creation_date,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute_category
  FROM mtl_txn_request_headers_v
 WHERE organization_id = 83
   AND (move_order_type NOT IN (7, 8) AND nvl(transaction_type_id, 1) <> 52)
   AND (request_number = '3149164')
 ORDER BY request_number;

SELECT lpn_id,
       line_id,
       header_id,
       organization_id,
       inventory_item_id,
       from_locator_id,
       to_account_id,
       quantity_detailed,
       secondary_quantity_detailed,
       reason_id,
       project_id,
       task_id,
       transaction_header_id,
       line_number,
       revision,
       transaction_type_name,
       date_required,
       uom_code,
       quantity,
       quantity_delivered,
       secondary_quantity,
       secondary_quantity_delivered,
       grade_code,
       from_subinventory_code,
       lpn_number,
       from_cost_group_id,
       lot_number,
       unit_number,
       serial_number_start,
       serial_number_end,
       to_subinventory_code,
       to_locator_id,
       to_cost_group_id,
       location_required_flag,
       transaction_type_id,
       reference,
       txn_source_id,
       status_date,
       last_updated_by,
       last_update_login,
       last_update_date,
       line_status,
       created_by,
       creation_date,
       request_id,
       reference_id,
       program_application_id,
       reference_type_code,
       program_id,
       program_update_date,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute_category,
       transaction_source_type_id,
       txn_source_line_id,
       txn_source_line_detail_id,
       primary_quantity,
       to_organization_id,
       pick_strategy_id,
       put_away_strategy_id,
       from_sub_locator_type,
       from_sub_asset,
       to_sub_locator_type,
       ship_to_location_id
  FROM mtl_txn_request_lines_v
 WHERE (header_id = 3149164)
 ORDER BY line_number;


--select * from fnd_user fu where fu.user_name = 'HAND_HKM';
--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  --mo_global.init('M');
  FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 83);
  
END;*/
