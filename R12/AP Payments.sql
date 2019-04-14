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
   AND aps.segment1 = '00000619'--'FB00000284'--'FB00003696' --'<supplier Number>'
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

SELECT 
apc.check_number,
apc.check_date,
apc.cleared_date,
apc.void_date,
apc.vendor_number,
apc.vendor_name,
apc.vendor_site_code,
apc.check_status,
apc.amount,
apc.control_amount,
apc.bank_account_name,
apc.bank_account_num,
apc.attribute3 Ʊ�ݺ�,
--apc.bank_account_type,

apc.* from ap_checks_v apc where 1=1 
AND apc.payment_method_code = 'BILLS_PAYABLE'
AND apc.check_status NOT IN ('Voided')
AND apc.org_id = 81
--AND apc.attribute3 = --'131030220100520180703218275442'
--'131030220100520180821241480353'
--'131331230003420180830247660584'
--'131331230003420180830247660710'
;

/*
BEGIN
  fnd_global.apps_initialize(user_id      => 1670
                            ,resp_id      => 50717
                            ,resp_appl_id => 20003); 
 mo_global.init('CUX');
 mo_global.set_policy_context('M',NULL);
END;
*/
