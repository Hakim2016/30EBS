--AP invoice v1.0

--AP with Project/Task
SELECT 
aph.attribute9,
aph.creation_date,
       aph.last_update_date,
       aph.payment_method_code,
       aph.invoice_type_lookup_code invoice_type,
       aph.invoice_id,
       aph.invoice_num,
       aph.invoice_amount,
       aph.amount_paid,
       aph.pay_curr_invoice_amount,
       aph.project_id,
       ppa.segment1                 proj_num,
       pt.task_number,
       aph.voucher_num,
       aph.*
  FROM apps.ap_invoices_all aph,
       apps.pa_projects_all ppa,
       apps.pa_tasks        pt
 WHERE 1 = 1
   AND aph.task_id = pt.task_id(+)
   AND aph.org_id = 221--82 --101 --141--82--101--82 --84--SHE--82 --HEA
   AND aph.project_id = ppa.project_id(+) --left join
   /*AND aph.invoice_num IN --= 'TOEQ001597'--'210-702-004' --'SG00043803*8' --'107/5350';--454220
      --('SPE-18000129')
       ('302210B1809001297'
)*/
--AND aph.invoice_num LIKE 'HKM%'
--AND aph.creation_date >= to_date('2018-06-01', 'yyyy-mm-dd')
--AND aph.invoice_type_lookup_code = 'PREPAYMENT'
 ORDER BY aph.invoice_id DESC

;

--ar haeder/ line
SELECT aph.invoice_id,
       apl.creation_date,
       apl.last_update_date,
       apl.last_updated_by,
       apl.description,
       apl.amount line_amt,
       aph.invoice_num,
       apl.line_type_lookup_code,
       aph.attribute_category,
       aph.attribute8,
       aph.*,
       apl.*
  FROM ap_invoices_all      aph,
       ap_invoice_lines_all apl
 WHERE 1 = 1
   AND aph.invoice_id = apl.invoice_id
   AND aph.org_id = 82 --101 --82
      --AND aph.invoice_num IN --LIKE 'USD%YUL%'
      --('GE18060191','GE18060212','GE18060218','GE18060219','GE18060228','GE18070008','GE18070010','GE18070021','GE18070062','GE18070082','GE18070086','GE18070089','GE18070090','GE18070101','GE18070103','GE18070104','GE18070105','GE18070108','GE18070114','GE18070122','GE18070126','GE18070129','GE18070130','GE18070131','GE18070132','GE18070133','GE18070134','GE18070135','GE18070136','GE18070137','GE18070138','GE18070139','GE18070140','GE18070141','GE18070143','GE18070144','GE18070145','GE18070146','GE18070147','GE18070148','GE18070149','GE18070150','GE18070151','GE18070152','GE18070154','GE18070155','GE18070156','GE18070157','GE18070158','GE18070159','GE18070160','GE18070161','GE18070165','GE18070169','GE18070172','GE18070174','GE18070178','GE18070179')
      --('SPE-18000129') --('GE18060191')--('GE18070129')
      --AND apl.amount <> 0
      --AND apl.line_number = 19
   AND aph.creation_date >= SYSDATE - 160
   AND aph.project_id IS NOT NULL
   AND aph.po_header_id IS NULL
 ORDER BY aph.invoice_num,
          apl.amount;

--SELECT * FROM  ap_invoice_distributions_all apd WHERE 1=1 AND apd.invoice_id = 2057357;
--ar haeder/ line/ distribution
SELECT aph.invoice_id,
       apl.creation_date,
       apl.last_update_date,
       apl.last_updated_by,
       apl.description,
       apl.amount line_amt,
       apd.amount,
       apd.base_amount, --��λ�ҽ�� functional amount
       aph.invoice_num,
       apl.line_type_lookup_code,
       aph.attribute_category,
       aph.attribute8,
       aph.*,
       apl.*
  FROM ap_invoices_all              aph,
       ap_invoice_lines_all         apl,
       ap_invoice_distributions_all apd
 WHERE 1 = 1
   AND apd.invoice_id = aph.invoice_id
   AND apd.invoice_line_number = apl.line_number
   AND aph.invoice_id = apl.invoice_id
   AND aph.org_id = 101 --82
   AND aph.invoice_num IN --LIKE 'USD%YUL%'
      --('GE18060191','GE18060212','GE18060218','GE18060219','GE18060228','GE18070008','GE18070010','GE18070021','GE18070062','GE18070082','GE18070086','GE18070089','GE18070090','GE18070101','GE18070103','GE18070104','GE18070105','GE18070108','GE18070114','GE18070122','GE18070126','GE18070129','GE18070130','GE18070131','GE18070132','GE18070133','GE18070134','GE18070135','GE18070136','GE18070137','GE18070138','GE18070139','GE18070140','GE18070141','GE18070143','GE18070144','GE18070145','GE18070146','GE18070147','GE18070148','GE18070149','GE18070150','GE18070151','GE18070152','GE18070154','GE18070155','GE18070156','GE18070157','GE18070158','GE18070159','GE18070160','GE18070161','GE18070165','GE18070169','GE18070172','GE18070174','GE18070178','GE18070179')
       ('SPE-18000129') --('GE18060191')--('GE18070129')
      --AND apl.amount <> 0
   AND apl.line_number = 19
 ORDER BY aph.invoice_num,
          apl.amount;

SELECT *
  FROM xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND xte.application_id = 200 --AP
   AND xte.source_id_int_1 = 1950245;

SELECT xal.entered_dr,
       xal.entered_cr,
       xte.*,
       xah.*,
       xal.*
  FROM xla.xla_transaction_entities xte,
       xla_ae_headers               xah,
       xla_ae_lines                 xal
 WHERE 1 = 1
   AND xah.entity_id = xte.entity_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xte.application_id = 200 --AP
   AND xte.source_id_int_1 = 1950245;

/*BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  
END;*/

SELECT aph.invoice_num,
       xah.event_id,
       xal.ae_line_num,
       xte.entity_code,
       apd.invoice_distribution_id  inv_dis_id,
       xdl.source_distribution_type src_dis_t,
       apd.line_type_lookup_code    dis_l_t,
       apd.posted_flag,
       xah.gl_transfer_date,
       apd.amount,
       xal.entered_dr,
       xal.entered_cr,
       xal.accounted_dr,
       xal.accounted_cr,
       --apd.amount_to_post,
       xah.*,
       xal.*,
       xdl.source_distribution_id_num_1,
       apl.line_number,
       apd.*,
       aph.*,
       apl.*
  FROM ap_invoices_all              aph,
       ap_invoice_lines_all         apl,
       ap_invoice_distributions_all apd,
       xla_distribution_links       xdl,
       xla_ae_headers               xah,
       xla_ae_lines                 xal,
       xla.xla_transaction_entities xte
 WHERE 1 = 1
   AND aph.invoice_id = apl.invoice_id
   AND aph.invoice_id = apd.invoice_id
   AND apl.line_number = apd.invoice_line_number
   AND apd.invoice_distribution_id = xdl.source_distribution_id_num_1
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xah.entity_id = xte.entity_id
   AND xah.ledger_id = xte.ledger_id
   AND xte.entity_code = 'AP_INVOICES'
   AND xdl.source_distribution_type = 'AP_INV_DIST'
   AND xdl.application_id = 200 --SQLAP
   AND xah.application_id = 200 --SQLAP
   AND xal.application_id = 200 --SQLAP
   AND xte.application_id = 200 --SQLAP
   AND aph.invoice_num = '210-702-004' --'18010016'--'SG00043803*7'
   AND aph.org_id = 82 --HEA
--AND apl.line_number = 1
--AND apd.invoice_distribution_id = 4737175
;

SELECT apd.invoice_distribution_id,
       apl.line_number,
       apd.amount,
       apd.amount_to_post,
       apd.line_type_lookup_code,
       apd.posted_flag,
       apd.*,
       aph.*,
       apl.*
  FROM ap_invoices_all              aph,
       ap_invoice_lines_all         apl,
       ap_invoice_distributions_all apd

 WHERE 1 = 1
   AND aph.invoice_id = apl.invoice_id
   AND aph.invoice_id = apd.invoice_id
   AND apl.line_number = apd.invoice_line_number
   AND aph.invoice_num = '10051165' --'210-702-004' --'18010016'--'SG00043803*7'
--AND aph.org_id = 82 --HEA
--AND apl.line_number = 11
--AND apd.amount <> 0
;
/* UPDATE ap_invoices_all aph
 SET aph.invoice_num = 'HKM18031302'--HKIM18021302
 WHERE 1=1
 AND aph.invoice_id = 1882328*/

SELECT FROM xla_transaction_entities xte,
            xla_ae_headers           xah,
            xla_ae_lines             xal
 WHERE 1 = 1
   AND xte.ledger_id = xah.ledger_id
   AND xte.entity_id = xah.entity_id;

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id = 200;

SELECT *
  FROM ap_interface_controls;
