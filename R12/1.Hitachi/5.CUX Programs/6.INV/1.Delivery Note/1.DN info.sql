--DN
/*
XXINVDNF
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
SELECT dnh.production_number,
       dnh.delivery_note_num,
       dnh.do_number,
       
       dnh.*

  FROM xxinv_dely_note_headers_v dnh
 WHERE 1 = 1
   AND dnh.production_number = '97000390'
   AND dnh.creation_date > to_date('20180701', 'yyyymmdd');

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
