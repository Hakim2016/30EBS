--DN
/*
XXINVDNF
After pressing button "Confirm", submit a request "XXPAITCR"
Personalizations
1.Validate DN Completion Date(Function)
  "MFG Number Not Completion, Cannot issue DN."
  XXINV_DELIVERY_PROCESS_PKG.get_process_flag
                  (:dn_headers.project_id,
                  :dn_lines.ho_item,
                  :dn_headers.business_type) = 'N'
2.XXINVC002:Subinventory Authority(Form)
  Refer to the SQL below:
*/

/*
XXPAITCR
XXPA:Incomplete Transaction Check Report
XXPA_INCOMPLETE_TRX_CHECK_PKG.main
*/
XXPA_INCOMPLETE_TRX_CHECK_PKG;--.main


SELECT dnl.delivery_note_id dnh_id,
dnl.dn_line_id dnl_id,
--dnl.ho_item_id,
(SELECT msi.segment1 FROM mtl_system_items_b msi
WHERE 1=1
AND msi.inventory_item_id = dnl.ho_item_id
AND msi.organization_id = 85) ho_item,
--dnl.fac_item_id,
(SELECT msi.segment1 FROM mtl_system_items_b msi
WHERE 1=1
AND msi.inventory_item_id = dnl.fac_item_id
AND msi.organization_id = 86) ho_item,
       dnh.production_number pdo_num,
       dnh.delivery_note_num dn_num,
       dnh.do_number,
       dnh.order_number,
       dnh.order_type,
       ppa.segment1 prj_num,
       ppa.long_name,
       ppa.project_type,
       dnh.*

  FROM xxinv_dely_note_headers_v dnh,
       xxinv_dely_note_lines_all dnl,
       pa_projects_all ppa
 WHERE 1 = 1
   AND dnh.delivery_note_id = dnl.delivery_note_id
   AND dnh.project_id = ppa.project_id(+)
   AND dnh.delivery_note_num = 1401240--1011986
      /*AND dnh.order_type = --'SHE FAC_MTE Parts'
      'SHE_Job Order_Spare Parts'*/
      --AND dnh.production_number = '97000505'--'97000390'
   --AND dnh.creation_date > to_date('20180701', 'yyyymmdd')
   --AND dnh.created_by = 4270
   ;
   
--mapping of sn type & so type
SELECT DISTINCT dnh.order_type,
                dnh.business_type
--dnh.*

  FROM xxinv_dely_note_headers_v dnh
 WHERE 1 = 1
 ORDER BY dnh.business_type;

SELECT project_id,
       segment1,
       long_name,
       project_type,
       org_id
  FROM pa_projects
 ORDER BY segment1;
 
SELECT DISTINCT
       project_type
  FROM pa_projects;
      
SELECT COUNT(*)
  --INTO l_count
  FROM xxinv_dely_note_lines l
 WHERE l.delivery_note_id = 4264--:dn_headers.delivery_note_id
   AND ((p_stock_flag = 'OUT' AND l.subinventory_code IS NULL) OR
       (p_stock_flag = 'IN' AND l.to_subinventory_code IS NULL));

/*XXINVC002:Subinventory Authority*/
SELECT secondary_inventory_name,
       description
  FROM mtl_secondary_inventories
 WHERE ((organization_id = :parameter.in_org_id AND :dn_headers.status_code = 'STOCK_OUT') OR
       (organization_id = :parameter.out_org_id AND :dn_headers.status_code = 'CONFIRM'))
   AND nvl(disable_date, trunc(SYSDATE)) >= trunc(SYSDATE)
   AND (nvl(fnd_profile.value('XXINV:SUBINVENTORY AUTHORITY'), 'N') = 'N' OR EXISTS
        (SELECT 1
           FROM fnd_lookup_values_vl cla
          WHERE 1 = 1
            AND cla.lookup_type = 'XXINV_SUBINVENTORY_AUTHORITY'
            AND cla.enabled_flag = 'Y'
            AND cla.tag = secondary_inventory_name
            AND cla.description = fnd_profile.value('RESP_NAME')
            AND cla.attribute14 = 'Y'
            AND fnd_profile.value('XXINV:SUBINVENTORY AUTHORITY') = 'Y'
            AND SYSDATE BETWEEN nvl(cla.start_date_active, SYSDATE) AND nvl(cla.end_date_active, SYSDATE)))
 ORDER BY secondary_inventory_name;

--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50778,
                             resp_appl_id => 20005);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;
*/
