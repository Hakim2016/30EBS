SELECT msi.segment1,
       hou.name organization_name,
       moq.organization_id,
       moq.subinventory_code,
       moq.locator_id,
       inv_project.get_locator(moq.locator_id, moq.organization_id) locator,
       SUM(moq.transaction_quantity) onhand_quantity
  FROM inv.mtl_onhand_quantities_detail moq,
       hr.hr_all_organization_units     hou,
       inv.mtl_system_items_b           msi
 WHERE moq.organization_id = hou.organization_id
      --AND    moq.inventory_item_id = 192680
   AND moq.inventory_item_id = msi.inventory_item_id
   AND msi.organization_id = moq.organization_id
   AND moq.organization_id = 86
   AND msi.segment1
      --= 'H-32610372-A'
       IN ('32722974-A-0000',
           '33350600-A-0000',
           '33444612-A-0000',
           'G0011626-A-0000',
           'H3000142-C-0000',
           'Q0001481-A-0000',
           'R311J00042',
           'S31901-A-0000',
           'S41366-C-0000')
--('H-32610372-A', 'H-1800018', 'H-32610372-A', '34261834-A', '34261834-A-0000')
 GROUP BY msi.segment1,
          hou.name,
          moq.organization_id,
          moq.subinventory_code,
          moq.locator_id
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
   AND o.name NOT LIKE '%������'
   AND msi.segment1 = '05020000000021';

SELECT msi.segment1,
       hou.name organization_name,
       moq.organization_id,
       moq.subinventory_code,
       moq.*
--SUM(moq.transaction_quantity) onhand_quantity
  FROM inv.mtl_onhand_quantities_detail moq,
       hr.hr_all_organization_units     hou,
       inv.mtl_system_items_b           msi
 WHERE moq.organization_id = hou.organization_id
      --AND    moq.inventory_item_id = 192680
   AND moq.inventory_item_id = msi.inventory_item_id
   AND msi.organization_id = moq.organization_id
   AND moq.organization_id = 86
   AND msi.segment1
      --= 'H-32610372-A'
       IN ('32722974-A-0000',
           '33350600-A-0000',
           '33444612-A-0000',
           'G0011626-A-0000',
           'H3000142-C-0000',
           'Q0001481-A-0000',
           'R311J00042',
           'S31901-A-0000',
           'S41366-C-0000')
--('H-32610372-A', 'H-1800018', 'H-32610372-A', '34261834-A', '34261834-A-0000')
/* GROUP BY msi.segment1,
hou.name,
moq.organization_id,
moq.subinventory_code*/
 ORDER BY hou.name;

inv_project.get_locator(mmt.locator_id, mmt.organization_id) locator

--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50778,
                             resp_appl_id => 20005);
  mo_global.init('M');
  FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;
*/
