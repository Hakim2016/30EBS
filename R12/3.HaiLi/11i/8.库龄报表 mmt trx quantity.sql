SELECT nvl(SUM(m.transaction_quantity),
               0),
           nvl(SUM(nvl(transaction_quantity,
                       0) * nvl(cic.item_cost,
                                0)),
               0),
               ca.secondary_inventory_name
      /*INTO l_onhand_qty,
           l_onhand_amount*/
      FROM mtl_onhand_quantities     m,
           mtl_secondary_inventories ca,
           cst_item_costs            cic
     WHERE ca.organization_id = 1131--p_organization_id
       AND ca.organization_id = m.organization_id
       --AND ((p_inventory = 'ZC' AND ca.attribute4 = 'ZC') OR (p_inventory = 'ALL' AND 1 = 1))
       AND ca.secondary_inventory_name = m.subinventory_code
       AND m.inventory_item_id = 1770847--p_item_id
       AND cic.inventory_item_id = m.inventory_item_id
       AND cic.organization_id = m.organization_id
       AND EXISTS (SELECT NULL
              FROM system_parameter
             WHERE para_name = 'COST_TYPE_ID'
               AND para_value = to_char(cic.cost_type_id))
               GROUP BY ca.secondary_inventory_name;
