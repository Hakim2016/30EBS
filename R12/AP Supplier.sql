SELECT vdr.set_of_books_id,
       vdr.segment1,
       sits.vendor_site_code,
       --vdr.customer_num,
       vdr.vendor_id,
       vdr.segment1,
       vdr.vat_registration_num,
       vdr.*
  FROM ap_suppliers          vdr,
       ap_supplier_sites_all sits
 WHERE 1 = 1
   AND vdr.vendor_id = sits.vendor_id
   AND sits.ORG_ID = 1129--HNET
      --AND --vdr.vendor_name --= '25183'
   --AND vdr.segment1 IN ('FB00003549','GS00200893','GT00200893') --('GS00200893','GT00200893')
--AND vdr.vat_registration_num IN ('0135561014284','0015511407039')

--'0135561014284'
;

--Accounting
SELECT vdr.set_of_books_id,
       vdr.segment1,
       sits.vendor_site_code,
       --vdr.customer_num,
       vdr.vendor_id,
       vdr.segment1,
       vdr.vat_registration_num,
       vdr.*
  FROM ap_suppliers          vdr,
       ap_supplier_sites_all sits
 WHERE 1 = 1
   AND vdr.vendor_id = sits.vendor_id
   AND sits.ORG_ID = 1129--HNET
      --AND --vdr.vendor_name --= '25183'
   --AND vdr.segment1 IN ('FB00003549','GS00200893','GT00200893') --('GS00200893','GT00200893')
--AND vdr.vat_registration_num IN ('0135561014284','0015511407039')

;

SELECT *
  FROM ap_supplier_sites_all ss
 WHERE ss.vendor_id = 291015 --1058837 --16001
;
