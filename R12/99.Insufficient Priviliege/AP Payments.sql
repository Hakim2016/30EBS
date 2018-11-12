--How to Get Default Payment Method For Supplier from Back End(Database) (Doc ID 848023.1) 

--1.Use below below SQL query to find default payment method at supplier level-

SELECT ibeppm.payment_method_code
  FROM ap_suppliers            aps,
       iby_external_payees_all ibepa,
       iby_ext_party_pmt_mthds ibeppm
 WHERE aps.party_id = ibepa.payee_party_id(+)
   AND ibeppm.ext_pmt_party_id = ibepa.ext_payee_id
   AND ibepa.supplier_site_id IS NULL
   AND ibeppm.primary_flag = 'Y'
   AND aps.segment1 = 'FB00000284'--'FB00003696' --'<supplier Number>'
;
--2.Use below below SQL query to find default payment method at supplier site level- 


SELECT    
      apssa.vendor_site_id, 
  apssa.vendor_site_code, 
  ibeppm.payment_method_code 
FROM 
      ap_suppliers aps, 
      iby_external_payees_all ibepa, 
      iby_ext_party_pmt_mthds ibeppm, 
      ap_supplier_sites_all apssa 
WHERE aps.party_id=ibepa.payee_party_id AND 
      ibeppm.ext_pmt_party_id =ibepa.ext_payee_id AND 
      apssa.vendor_id= aps.vendor_id AND 
      ibepa.supplier_site_id is not null AND 
      ibeppm.primary_flag='Y' AND 
      aps.segment1='FB00003696'--'FB00000284'--'FB00003696'--'<Supplier Number>' 
GROUP BY  
      apssa.vendor_site_id, 
      apssa.vendor_site_code, 
      ibeppm.payment_method_code;
      
SELECT * FROM ap_suppliers aps
WHERE 1=1
AND aps.segment1='FB00003696';
