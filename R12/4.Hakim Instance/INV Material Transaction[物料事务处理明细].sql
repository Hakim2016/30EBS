SELECT ood.organization_code,
       mmt.transaction_id,
       mtt.transaction_type_name,
       --mtt.transaction_action_id,
       ml_act.meaning transaction_action_name,
       mtt.transaction_source_type_id,
       mtst.transaction_source_type_name,
       msiv.segment1,
       mmt.subinventory_code,
       mmt.transfer_subinventory,
       -- locator
       mmt.transaction_date,
       mmt.transaction_quantity,
       mmt.source_code,
       mmt.transaction_reference,
       -- inv_object_genealogy.getsource(mmt.organization_id, mmt.transaction_source_type_id, mmt.transaction_source_id) reason_trx_source_name
       CASE
         WHEN mmt.transaction_source_type_id = 1 THEN
         -- PO
          (SELECT segment1
             FROM po_headers_all
            WHERE po_header_id = mmt.transaction_source_id)
         WHEN mmt.transaction_source_type_id IN (2, 8, 12) THEN
         -- SO,Internal Order,RMA
          (SELECT substr(concatenated_segments, 1, 30)
             FROM mtl_sales_orders_kfv
            WHERE sales_order_id = mmt.transaction_source_id)
         WHEN mmt.transaction_source_type_id = 4 THEN
         -- Move Orders
          (SELECT request_number
             FROM mtl_txn_request_headers
            WHERE header_id = mmt.transaction_source_id)
         WHEN mmt.transaction_source_type_id = 5 THEN
         -- WIP
          (SELECT we.wip_entity_name
             FROM wip_entities we
            WHERE we.wip_entity_id = mmt.transaction_source_id
              AND we.organization_id = mmt.organization_id)
         WHEN mmt.transaction_source_type_id = 6 THEN
         -- Account Alias
          (SELECT substr(concatenated_segments, 1, 30)
             FROM mtl_generic_dispositions_kfv
            WHERE disposition_id = mmt.transaction_source_id
              AND organization_id = mmt.organization_id)
         WHEN mmt.transaction_source_type_id = 7 THEN
         -- Internal Requisition
          (SELECT segment1
             FROM po_requisition_headers_all
            WHERE requisition_header_id = mmt.transaction_source_id)
         WHEN mmt.transaction_source_type_id = 9 THEN
         -- Cycle Count
          (SELECT cycle_count_header_name
             FROM mtl_cycle_count_headers
            WHERE cycle_count_header_id = mmt.transaction_source_id
              AND organization_id = mmt.organization_id)
         WHEN mmt.transaction_source_type_id = 10 THEN
         -- Physical Inventory
          (SELECT physical_inventory_name
             FROM mtl_physical_inventories
            WHERE physical_inventory_id = mmt.transaction_source_id
              AND organization_id = mmt.organization_id)
         WHEN mmt.transaction_source_type_id = 11 THEN
         -- Standard Cost Update
          (SELECT description
             FROM cst_cost_updates
            WHERE cost_update_id = mmt.transaction_source_id
              AND organization_id = mmt.organization_id)
         WHEN mmt.transaction_source_type_id = 13 THEN
         -- Inventory
          decode((SELECT COUNT(1)
                   FROM mtl_txn_request_lines mol
                  WHERE txn_source_id = mmt.transaction_source_id
                    AND organization_id = mmt.organization_id
                    AND EXISTS (SELECT NULL
                           FROM mtl_txn_request_headers
                          WHERE header_id = mol.header_id
                            AND move_order_type = 5
                            AND mol.transaction_source_type_id = 13)),
                 0,
                 NULL,
                 (SELECT wip_entity_name
                    FROM wip_entities
                   WHERE wip_entity_id = mmt.transaction_source_id
                     AND organization_id = mmt.organization_id))
       END reason_trx_source_name
  FROM apps.org_organization_definitions ood,
       apps.mtl_material_transactions    mmt,
       apps.mtl_transaction_types        mtt,
       apps.mfg_lookups                  ml_act,
       apps.mtl_txn_source_types         mtst,
       apps.mtl_system_items_b           msiv
 WHERE 1 = 1
   AND ood.organization_id = mmt.organization_id
   AND mmt.transaction_type_id = mtt.transaction_type_id
   AND ml_act.lookup_type(+) = 'MTL_TRANSACTION_ACTION'
   AND ml_act.lookup_code(+) = mmt.transaction_action_id
   AND mmt.transaction_source_type_id = mtst.transaction_source_type_id(+)
   AND mmt.organization_id = msiv.organization_id
   AND mmt.inventory_item_id = msiv.inventory_item_id
      --AND ood.organization_code = 'SG1'
      -- AND msiv.segment1 = '33519020-A-0000'
      /* AND mtt.transaction_type_name = 'PO Receipt'
      AND ml_act.meaning = 'Receipt into stores' --transaction_action_name */
      --AND mmt.transaction_source_type_id = 1
      --AND mtst.transaction_source_type_name = 'Purchase order'
   AND rownum < 10
   AND mmt.transaction_source_type_id = 13 -- (2, 8, 12)
;

SELECT ood.organization_code,
       mmt.transaction_id,
       mtt.transaction_type_name,
       --mtt.transaction_action_id,
       ml_act.meaning transaction_action_name,
       mtt.transaction_source_type_id,
       mtst.transaction_source_type_name,
       msiv.segment1,
       mmt.subinventory_code,
       mmt.transfer_subinventory,
       -- locator
       mmt.transaction_date,
       mmt.transaction_quantity,
       mmt.source_code,
       mmt.transaction_reference,
       --inv_object_genealogy.getsource(mmt.organization_id, mmt.transaction_source_type_id, mmt.transaction_source_id) reason_trx_source_name,
       mmt.reason_trx_source_name
  FROM (SELECT mmt1.*,
               CASE
                 WHEN mmt1.transaction_source_type_id = 1 THEN
                 -- PO
                  (SELECT segment1
                     FROM po_headers_all
                    WHERE po_header_id = mmt1.transaction_source_id)
                 WHEN mmt1.transaction_source_type_id IN (2, 8, 12) THEN
                 -- SO,Internal Order,RMA
                  (SELECT substr(concatenated_segments, 1, 30)
                     FROM mtl_sales_orders_kfv
                    WHERE sales_order_id = mmt1.transaction_source_id)
                 WHEN mmt1.transaction_source_type_id = 4 THEN
                 -- Move Orders
                  (SELECT request_number
                     FROM mtl_txn_request_headers
                    WHERE header_id = mmt1.transaction_source_id)
                 WHEN mmt1.transaction_source_type_id = 5 THEN
                 -- WIP
                  (SELECT we.wip_entity_name
                     FROM wip_entities we
                    WHERE we.wip_entity_id = mmt1.transaction_source_id
                      AND we.organization_id = mmt1.organization_id)
                 WHEN mmt1.transaction_source_type_id = 6 THEN
                 -- Account Alias
                  (SELECT substr(concatenated_segments, 1, 30)
                     FROM mtl_generic_dispositions_kfv
                    WHERE disposition_id = mmt1.transaction_source_id
                      AND organization_id = mmt1.organization_id)
                 WHEN mmt1.transaction_source_type_id = 7 THEN
                 -- Internal Requisition
                  (SELECT segment1
                     FROM po_requisition_headers_all
                    WHERE requisition_header_id = mmt1.transaction_source_id)
                 WHEN mmt1.transaction_source_type_id = 9 THEN
                 -- Cycle Count
                  (SELECT cycle_count_header_name
                     FROM mtl_cycle_count_headers
                    WHERE cycle_count_header_id = mmt1.transaction_source_id
                      AND organization_id = mmt1.organization_id)
                 WHEN mmt1.transaction_source_type_id = 10 THEN
                 -- Physical Inventory
                  (SELECT physical_inventory_name
                     FROM mtl_physical_inventories
                    WHERE physical_inventory_id = mmt1.transaction_source_id
                      AND organization_id = mmt1.organization_id)
                 WHEN mmt1.transaction_source_type_id = 11 THEN
                 -- Standard Cost Update
                  (SELECT description
                     FROM cst_cost_updates
                    WHERE cost_update_id = mmt1.transaction_source_id
                      AND organization_id = mmt1.organization_id)
                 WHEN mmt1.transaction_source_type_id = 13 THEN
                 -- Inventory
                  decode((SELECT COUNT(1)
                           FROM mtl_txn_request_lines mol
                          WHERE txn_source_id = mmt1.transaction_source_id
                            AND organization_id = mmt1.organization_id
                            AND EXISTS (SELECT NULL
                                   FROM mtl_txn_request_headers
                                  WHERE header_id = mol.header_id
                                    AND move_order_type = 5
                                    AND mol.transaction_source_type_id = 13)),
                         0,
                         NULL,
                         (SELECT wip_entity_name
                            FROM wip_entities
                           WHERE wip_entity_id = mmt1.transaction_source_id
                             AND organization_id = mmt1.organization_id))
               END reason_trx_source_name
          FROM apps.mtl_material_transactions mmt1) mmt,
       apps.org_organization_definitions ood,
       -- apps.mtl_material_transactions    mmt,
       apps.mtl_transaction_types mtt,
       apps.mfg_lookups           ml_act,
       apps.mtl_txn_source_types  mtst,
       apps.mtl_system_items_b    msiv
 WHERE 1 = 1
   AND ood.organization_id = mmt.organization_id
   AND mmt.transaction_type_id = mtt.transaction_type_id
   AND ml_act.lookup_type(+) = 'MTL_TRANSACTION_ACTION'
   AND ml_act.lookup_code(+) = mmt.transaction_action_id
   AND mmt.transaction_source_type_id = mtst.transaction_source_type_id(+)
   AND mmt.organization_id = msiv.organization_id
   AND mmt.inventory_item_id = msiv.inventory_item_id
   AND ood.organization_code = 'SG1'
      -- AND msiv.segment1 = '33519020-A-0000'
      /* AND mtt.transaction_type_name = 'PO Receipt'
      AND ml_act.meaning = 'Receipt into stores' --transaction_action_name */
      --AND mmt.transaction_source_type_id = 1
      --AND mtst.transaction_source_type_name = 'Purchase order'
   AND rownum < 10
--AND mmt.transaction_source_type_id = 13 -- (2, 8, 12)
;
