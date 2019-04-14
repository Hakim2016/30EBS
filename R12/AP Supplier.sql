--客户是全局共享的，但对应的客户地址是OU屏蔽的
SELECT sits.org_id,
       sits.vendor_site_code 地点名称,
       --vdr.set_of_books_id,
       vdr.segment1,
       --vdr.customer_num,
       --vdr.vendor_id,
       vdr.vendor_name,/*
       --vdr.vat_registration_num,
       --sits.accts_pay_code_combination_id,
       gcc_Liability.segment3 Liability,
       gl_flexfields_pkg.get_description_sql(gcc_Liability.chart_of_accounts_id
                                                ,3
                                                ,gcc_Liability.segment3) Liability,
                 
       gcc_prepay.segment3 prepay,
       gl_flexfields_pkg.get_description_sql(gcc_prepay.chart_of_accounts_id
                                                ,3
                                                ,gcc_prepay.segment3) prepay,
       gcc_billpay.segment3 billpay,
       gl_flexfields_pkg.get_description_sql(gcc_billpay.chart_of_accounts_id
                                                ,3
                                                ,gcc_billpay.segment3) billpay,*/
       
       sits.distribution_set_id
/*,
vdr.**/
  FROM ap_suppliers vdr, ap_supplier_sites_all sits/*,
  gl_code_combinations gcc_Liability,
  gl_code_combinations gcc_PREPAY,
  gl_code_combinations gcc_BILLPAY*/
 WHERE 1 = 1
   AND vdr.vendor_id = sits.vendor_id/*
   AND sits.accts_pay_code_combination_id(+) = gcc_liability.CODE_COMBINATION_ID
   AND sits.prepay_code_combination_id(+) = gcc_prepay.CODE_COMBINATION_ID
   AND sits.FUTURE_DATED_PAYMENT_CCID(+) = gcc_billpay.CODE_COMBINATION_ID*/
      --AND sits.org_id = 7904--81--7904 --1129--HNET
      AND vdr.vendor_name LIKE '江苏裕生堂营养品有限公司'--'%雅博%'--'绵阳市泷财来可再生资源回收有限公司'--'%南通%'--= '25183'
   --AND vdr.segment1 LIKE '00003732' --'%3600%'--('FB00003549','GS00200893','GT00200893') --('GS00200893','GT00200893')
--AND vdr.vat_registration_num IN ('0135561014284','0015511407039')

--'0135561014284'

 ORDER BY vdr.vendor_id DESC;

SELECT vdr.vendor_type_lookup_code typ, vdr.*
  FROM ap_suppliers vdr
 WHERE 1 = 1
   --AND vdr.segment1 LIKE '%3600%'
   AND vdr.VENDOR_NAME = '绵阳市泷财来可再生资源回收有限公司'
--AND vdr.last_updated_by = 1014703
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
