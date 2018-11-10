SELECT pv.vendor_id vendor_id,
       pvsa.vendor_site_id vendor_site_id,
       pv.vendor_name vendor_name,
       pvsa.vendor_site_code vendor_site_code,
       pvsa.org_id org_id,
       pv.segment1 vendor_code,
       pvc.area_code || pvc.phone vendor_phone,
       pvc.fax_area_code || pvc.fax vendor_fax,
       pvsa.terms_id terms_id,
       pvsa.vat_code vat_code,
       pvc.last_name || pvc.middle_name || pvc.first_name contact_man
  FROM po_vendors          pv,
       po_vendor_sites_all pvsa,
       po_vendor_contacts  pvc
 WHERE pv.vendor_id = pvsa.vendor_id(+)
   AND pvsa.vendor_site_id = pvc.vendor_site_id(+)
   AND pv.vendor_id = 965725 --593
--AND pv.segment1 = 'HL00000004'
 ORDER BY org_id DESC;

SELECT pv.segment1,
       pv.vendor_name,
       pv.creation_date,
       pv.attribute_category,
       pv.start_date_active,
       pv.end_date_active,
       pv.enabled_flag,
       --pv.customer_num,
       --pv.set_of_books_id,
       pv.*
  FROM po_vendors pv
 WHERE 1 = 1
      --AND pv.segment1 = 'HL00000004'
      --AND pv.ENABLED_FLAG = 'Y'
      --AND pv.vendor_id = 593
   AND pv.end_date_active IS NOT NULL
--AND 
;
