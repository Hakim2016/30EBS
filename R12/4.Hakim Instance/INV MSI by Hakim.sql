SELECT msi.segment1,
       msi.description,
       --INV_PROJECT.GET_LOCATOR(msi.LOCATOR_ID, msi.ORGANIZATION_ID) LOCATOR,
       msi.purchasing_item_flag,
        msi.inventory_item_flag,
       msi.*
  FROM mtl_system_items_b msi
 WHERE 1 = 1
   --AND msi.creation_date > SYSDATE - 60 --trunc(SYSDATE, 'yyyy')
   --AND msi.organization_id = 83--83
   --AND msi.inventory_item_id = 15221846
   --AND msi.segment1 LIKE 'SBL0043-SG-R-L#ARS0028'--'94001921-TM'--'L#GSW0303_001'--'R111J00526'--'TAE0736-TH'--'S31901-A-0000'--'34261834%A%000'
   --AND msi.organization_id IN (85, 86)--= 85 
   --AND msi.purchasing_item_flag = 'Y'
   --AND msi.inventory_item_flag = 'Y'
   --AND msi.description = 'HATCH DOOR ASSY(OUG-10T-1350-2PCO60, 2S/2F)'
   ;
   
INV_PROJECT.GET_LOCATOR(MMT.LOCATOR_ID, MMT.ORGANIZATION_ID) LOCATOR

--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  \*fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);*\
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;*/
