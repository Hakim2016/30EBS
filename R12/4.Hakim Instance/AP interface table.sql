/*
After data being created system AP, all record in Interface will be cleared
*/

SELECT *
  FROM iby.iby_external_payees_all
 WHERE payee_party_id = 465719;

SELECT *
  FROM ap_interface_rejections t
 WHERE 1 = 1
   AND t.creation_date > trunc(SYSDATE);

SELECT *
  FROM ap_invoices_interface intf
 WHERE 1 = 1
   AND intf.invoice_num = 'GE18060191HKM' --'GE18070129'
--AND intf.creation_date > TRUNC(SYSDATE)
--AND intf.invoice_id --= 175626--170596
--IN(2035854,2035855,2035856,2035857,2035858,2035859,2035860,2035861,2035862,2035863,2035864,2035865,2035866,2035867,2035868,2035869,2035870,2035871,2035872,2035873,2035874,2035875,2035876,2035877,2035878,2035879,2035880,2035881,2035882,2035883,2035884,2035885,2035886,2035887,2035888,2035889,2035890,2035891,2035892,2035893,2035894,2035895,2035896,2035897,2035898,2035899,2035900,2035901,2035844,2035845,2035846,2035847,2035848,2035849,2035850,2035851,2035852,2035853)
--FOR UPDATE
;

SELECT 
aphi.status,
aphi.*,
apli.*
  FROM ap_invoices_interface      aphi,
       ap_invoice_lines_interface apli
 WHERE 1 = 1
   AND aphi.invoice_id = apli.invoice_id
   AND aphi.invoice_num --= 'TG18090176' --'GE18070129'
IN (
--'655-RMS-0490854'
'TG18090176',	
'TG18090177',	
'TG18090178',	
'TG18090179',	
'TG18090180',	
'TG18090181',	
'TG18090182'
)
--IN('GE18060191','GE18060212','GE18060218','GE18060219','GE18060228','GE18070008','GE18070010','GE18070021','GE18070062','GE18070082','GE18070086','GE18070089','GE18070090','GE18070101','GE18070103','GE18070104','GE18070105','GE18070108','GE18070114','GE18070122','GE18070126','GE18070129','GE18070130','GE18070131','GE18070132','GE18070133','GE18070134','GE18070135','GE18070136','GE18070137','GE18070138','GE18070139','GE18070140','GE18070141','GE18070143','GE18070144','GE18070145','GE18070146','GE18070147','GE18070148','GE18070149','GE18070150','GE18070151','GE18070152','GE18070154','GE18070155','GE18070156','GE18070157','GE18070158','GE18070159','GE18070160','GE18070161','GE18070165','GE18070169','GE18070172','GE18070174','GE18070178','GE18070179')
;
