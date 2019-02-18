SELECT vdr.set_of_books_id,
       vdr.segment1,
       sits.vendor_site_code,
       --vdr.customer_num,
       vdr.vendor_id,
       vdr.segment1,
       vdr.vat_registration_num,
       vdr.*
  FROM ap_suppliers vdr, ap_supplier_sites_all sits
 WHERE 1 = 1
   AND vdr.vendor_id = sits.vendor_id
   AND sits.org_id = 7904 --1129--HNET
--AND --vdr.vendor_name --= '25183'
--AND vdr.segment1 IN ('FB00003549','GS00200893','GT00200893') --('GS00200893','GT00200893')
--AND vdr.vat_registration_num IN ('0135561014284','0015511407039')

--'0135561014284'

 ORDER BY vdr.vendor_id DESC;

SELECT vdr.vendor_type_lookup_code typ, vdr.*
  FROM ap_suppliers vdr
 WHERE 1 = 1
   AND vdr.last_updated_by = 1014703
 ORDER BY vdr.vendor_id DESC;

SELECT *
  FROM hz_parties hp
 WHERE 1 = 1
   AND hp.last_updated_by = 1014703
 ORDER BY hp.party_id DESC;

SELECT *
  FROM ap_supplier_sites_all ss
 WHERE ss.vendor_id = 291015 --1058837 --16001
;
