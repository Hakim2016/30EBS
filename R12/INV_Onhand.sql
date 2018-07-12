SELECT msi.segment1,
       hou.name organization_name,
       moq.organization_id,
       moq.subinventory_code,
       SUM(moq.transaction_quantity) onhand_quantity
  FROM inv.mtl_onhand_quantities_detail moq,
       hr.hr_all_organization_units     hou,
       inv.mtl_system_items_b           msi
 WHERE moq.organization_id = hou.organization_id
      --AND    moq.inventory_item_id = 192680
   AND moq.inventory_item_id = msi.inventory_item_id
   AND msi.organization_id = moq.organization_id
      --AND    moq.organization_id = 86
   AND msi.segment1
      --= 'H-32610372-A'
       IN ('H-32610372-A', 'H-1800018', 'H-32610372-A', '34261834-A', '34261834-A-0000')
 GROUP BY msi.segment1,
          hou.name,
          moq.organization_id,
          moq.subinventory_code
 ORDER BY hou.name;

SELECT *
  FROM inv.mtl_system_items_b msi
 WHERE 1 = 1
   AND msi.organization_id = 83
   AND msi.segment1 = '120E126W';

SELECT *
  FROM inv.mtl_secondary_inventories sub
 WHERE sub.secondary_inventory_name LIKE '301%'
   AND sub.organization_id = 522;

SELECT nvl(SUM(transaction_quantity), 0)
  FROM mtl_onhand_quantities moq
 WHERE organization_id = 21
   AND inventory_item_id = 22133
   AND moq.subinventory_code = '301'
 GROUP BY moq.organization_id,
          moq.subinventory_code,
          moq.inventory_item_id;

SELECT msi.organization_id,
       msi.inventory_item_id,
       msi.description
  FROM inv.mtl_system_items  msi,
       hr_organization_units o
 WHERE msi.organization_id = o.organization_id
   AND o.attribute2 = 2
   AND o.name NOT LIKE '%´úÏú²Ö'
   AND msi.segment1 = '05020000000021';
