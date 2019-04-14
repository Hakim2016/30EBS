/*
BEGIN
  fnd_global.apps_initialize(user_id      => 1670
                            ,resp_id      => 50717
                            ,resp_appl_id => 20003); 
 mo_global.init('CUX');
 mo_global.set_policy_context('M',NULL);
END;
*/


/*prepaid_sql:SELECT * FROM (*/--三段逻辑
SELECT pv.vendor_id vendor_id,
       decode(ai.invoice_type_lookup_code,
              'PAYMENT REQUEST',
              NULL,
              pv.segment1) vendor_num,
       nvl(pv.vendor_name, hp.party_name) vendor_name /* bug 8394963 */,
       flv.meaning vendor_type,
       pvs.vendor_site_id,
       pvs.vendor_site_code vendor_site,
       ai.invoice_num,
       ai.invoice_id,
       xal.code_combination_id,
       fv.flex_value gl_code,
       fv.description gl_code_desc,
       decode('Y', 'Y', 'CNY', xal.currency_code) currency,
       nvl(decode('Y', 'Y', xal.entered_cr, xal.accounted_cr), 0) -
       nvl(decode('Y', 'Y', xal.entered_dr, xal.accounted_dr), 0) amount_sr,
       xah.ledger_id,
       xal.accounting_class_code,
       xah.gl_transfer_status_code,
       (SELECT MIN(xah.accounting_date)
          FROM xla_ae_headers xah, xla_transaction_entities xte
         WHERE xah.accounting_entry_status_code = 'F'
           AND xah.application_id = 200
           AND xah.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.entity_code = 'AP_INVOICES'
           AND nvl(xte.source_id_int_1, -99) = ai.invoice_id) gl_date,
       ai.invoice_date buss_date,
       (SELECT MAX(aps.due_date)
          FROM ap_payment_schedules aps
         WHERE aps.invoice_id = ai.invoice_id) end_date,
       trunc(to_date('2019-04-08', 'YYYY-MM-DD') -
             (SELECT MIN(xah.accounting_date)
                FROM xla_ae_headers xah, xla_transaction_entities xte
               WHERE xah.accounting_entry_status_code = 'F'
                 AND xah.application_id = 200
                 AND xah.application_id = xte.application_id
                 AND xah.entity_id = xte.entity_id
                 AND xte.entity_code = 'AP_INVOICES'
                 AND nvl(xte.source_id_int_1, -99) = ai.invoice_id)) gl_days,
       trunc(to_date('2019-04-08', 'YYYY-MM-DD') - ai.invoice_date) buss_days,
       NULL end_days,
       NULL org_id
  FROM xla.xla_ae_headers           xah,
       xla.xla_ae_lines             xal,
       xla.xla_transaction_entities xte,
       ap_invoices_all              ai,
       po_vendors                   pv,
       hz_parties                   hp, --customer
       po_vendor_sites_all          pvs,
       fnd_lookup_values_vl         flv,
       fnd_flex_value_sets          fvs,
       fnd_flex_values_vl           fv
 WHERE xah.accounting_entry_status_code = 'F'
   AND xah.application_id = 200
   AND xte.application_id = 200
   AND xte.entity_code = 'AP_INVOICES'
   AND xte.entity_id = xah.entity_id
      -- AND    xal.accounting_class_code = 'LIABILITY'
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.application_id = xal.application_id
   AND xte.ledger_id = xal.ledger_id --added by suu 2016.03.22 ledger_id
   AND xte.ledger_id = ai.set_of_books_id
   AND xte.source_id_int_1 = ai.invoice_id
   AND nvl(nvl(xal.accounted_cr, xal.accounted_dr), 0) <> 0
   AND ai.vendor_id = pv.vendor_id(+)
   AND pvs.vendor_site_id(+) = ai.vendor_site_id
   AND ai.party_id = hp.party_id(+)
   AND flv.lookup_code(+) = pv.vendor_type_lookup_code
   AND flv.lookup_type(+) = 'VENDOR TYPE'
   AND flv.enabled_flag(+) = 'Y'
   AND fvs.flex_value_set_id = fv.flex_value_set_id
   AND fvs.flex_value_set_id = 1016829
   AND fv.enabled_flag = 'Y'
      
   AND (xal.accounting_class_code = 'LIABILITY' AND EXISTS
        (SELECT 'X'
           FROM gl_code_combinations t
          WHERE t.code_combination_id = xal.code_combination_id
            AND segment3 = fv.flex_value))
   AND xah.gl_transfer_status_code = 'Y'
   AND xte.ledger_id = 2021
   AND mo_global.check_access(ai.org_id) = 'Y'
   AND xah.accounting_date <= to_date('2019-04-08', 'YYYY-MM-DD')
   ;
--UNION ALL
SELECT pv.vendor_id,
       decode(ac.vendor_id, '', NULL, pv.segment1) vendor_num,
       nvl(pv.vendor_name, hp.party_name) vendor_name,
       flv.meaning vendor_type,
       pvs.vendor_site_id,
       pvs.vendor_site_code vendor_site,
       ai.invoice_num,
       ai.invoice_id,
       xal.code_combination_id,
       fv.flex_value gl_code,
       fv.description gl_code_desc,
       decode('Y', 'Y', 'CNY', xal.currency_code) currency,
       nvl(decode('Y',
                  'Y',
                  xdl.unrounded_accounted_cr,
                  xdl.unrounded_entered_cr),
           0) - nvl(decode('Y',
                           'Y',
                           xdl.unrounded_accounted_dr,
                           xdl.unrounded_entered_dr),
                    0) amount_sr,
       xah.ledger_id,
       xal.accounting_class_code,
       xah.gl_transfer_status_code,
       (SELECT MIN(xah.accounting_date)
          FROM xla_ae_headers xah, xla_transaction_entities xte
         WHERE xah.accounting_entry_status_code = 'F'
           AND xah.application_id = 200
           AND xah.application_id = xte.application_id
           AND xah.entity_id = xte.entity_id
           AND xte.entity_code = 'AP_INVOICES'
           AND nvl(xte.source_id_int_1, -99) = ai.invoice_id) gl_date,
       ai.invoice_date buss_date,
       (SELECT MAX(aps.due_date)
          FROM ap_payment_schedules aps
         WHERE aps.invoice_id = aip.invoice_id
           AND aps.payment_num = aip.payment_num) end_date,
       trunc(to_date('2019-04-08', 'YYYY-MM-DD') -
             (SELECT MIN(xah.accounting_date)
                FROM xla_ae_headers xah, xla_transaction_entities xte
               WHERE xah.accounting_entry_status_code = 'F'
                 AND xah.application_id = 200
                 AND xah.application_id = xte.application_id
                 AND xah.entity_id = xte.entity_id
                 AND xte.entity_code = 'AP_INVOICES'
                 AND nvl(xte.source_id_int_1, -99) = ai.invoice_id)) gl_days,
       trunc(to_date('2019-04-08', 'YYYY-MM-DD') - ai.invoice_date) buss_days,
       NULL end_days,
       NULL org_id
  FROM xla_ae_headers           xah,
       xla_ae_lines             xal,
       xla_transaction_entities xte,
       ap_invoices_all          ai,
       ap_checks_all            ac,
       ap_invoice_payments_all  aip,
       ap_payment_history_all   apha,
       ap_payment_hist_dists    aphd,
       xla_distribution_links   xdl,
       po_vendors               pv,
       po_vendor_sites_all      pvs,
       hz_parties               hp --customer
      ,
       fnd_lookup_values_vl     flv,
       fnd_flex_value_sets      fvs,
       fnd_flex_values_vl       fv
 WHERE xah.accounting_entry_status_code = 'F'
   AND xah.application_id = 200
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.application_id = xal.application_id
   AND xah.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
      -- AND    xal.accounting_class_code = 'LIABILITY'
   AND xte.entity_code = 'AP_PAYMENTS'
   AND xte.ledger_id = xal.ledger_id --added by suu 2016.03.22 ledger_id
   AND xte.ledger_id = ai.set_of_books_id
   AND xah.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xal.application_id = xdl.application_id
   AND nvl(xte.source_id_int_1, -99) = ac.check_id
   AND ai.invoice_id = aip.invoice_id
   AND ac.check_id = aip.check_id
   AND aip.invoice_payment_id = aphd.invoice_payment_id
   AND apha.payment_history_id = aphd.payment_history_id
   AND xdl.source_distribution_type = 'AP_PMT_DIST'
   AND xdl.source_distribution_id_num_1 = aphd.payment_hist_dist_id
   AND ac.vendor_id = pv.vendor_id(+)
   AND ac.vendor_site_id = pvs.vendor_site_id(+)
   AND ac.party_id = hp.party_id(+)
   AND flv.lookup_code(+) = pv.vendor_type_lookup_code
   AND flv.lookup_type(+) = 'VENDOR TYPE'
   AND flv.enabled_flag(+) = 'Y'
   AND fvs.flex_value_set_id = fv.flex_value_set_id
   AND fvs.flex_value_set_id = 1016829
   AND fv.enabled_flag = 'Y'
      
   AND (xal.accounting_class_code = 'LIABILITY' AND EXISTS
        (SELECT 'X'
           FROM gl_code_combinations t
          WHERE t.code_combination_id = xal.code_combination_id
            AND segment3 = fv.flex_value))
   AND xah.gl_transfer_status_code = 'Y'
   AND xte.ledger_id = 2021
   AND mo_global.check_access(ai.org_id) = 'Y'
   AND xah.accounting_date <= to_date('2019-04-08', 'YYYY-MM-DD')
   ;
--UNION ALL--总账取数
SELECT 
jh.DOC_SEQUENCE_VALUE 凭证编号,
jl.JE_LINE_NUM,
sup.vendor_id vendor_id,
       sup.segment1 vendor_num,
       sup.vendor_name,
       flv.meaning vendor_type,
       sups.vendor_site_id,
       sups.vendor_site_code vendor_site,
       NULL invoice_num,
       NULL invoice_id,
       jl.code_combination_id,
       fv.flex_value gl_code,
       fv.description gl_code_desc,
       decode('Y', 'Y', 'CNY', jh.currency_code) currency,
       nvl(decode('Y', 'Y', jl.accounted_cr, jl.entered_cr), 0) -
       nvl(decode('Y', 'Y', jl.accounted_dr, jl.entered_dr), 0) amount_sr,
       jh.ledger_id,
       NULL accounting_class_code,
       NULL gl_transfer_status_code,
       NULL gl_date,
       NULL buss_date,
       gp.end_date end_date,
       trunc(to_date('2019-04-08', 'YYYY-MM-DD') - gp.end_date) gl_days,
       trunc(to_date('2019-04-08', 'YYYY-MM-DD') - gp.end_date) buss_days,
       trunc(to_date('2019-04-08', 'YYYY-MM-DD') - gp.end_date) end_days,
       NULL org_id
  FROM gl_je_headers            jh,
       gl_je_lines              jl,
       gl_code_combinations_kfv gcc,
       ap_suppliers             sup,
       fnd_lookup_values        flv,
       ap_supplier_sites_all    sups,
       fnd_flex_value_sets      fvs,
       fnd_flex_values_vl       fv,
       gl_periods               gp
 WHERE jl.je_header_id = jh.je_header_id
   AND gcc.code_combination_id = jl.code_combination_id
   AND sup.vendor_id = jl.attribute5
   AND flv.lookup_type(+) = 'VENDOR TYPE'
   AND flv.enabled_flag(+) = 'Y'
   AND flv.language(+) = userenv('LANG')
   AND flv.lookup_code(+) = sup.vendor_type_lookup_code
   AND sups.vendor_id = sup.vendor_id
   AND sups.vendor_site_code = '费用采购' --限制供应商地点为费用采购Added by wangyan@2019.03.19
   AND fvs.flex_value_set_id = fv.flex_value_set_id
   AND fvs.flex_value_set_id = 1016829
   AND fv.enabled_flag = 'Y'
   AND fv.flex_value = gcc.segment3
   AND jh.status = 'P'
   AND gcc.segment3 IN ('2241010101', '2241020101', '2241030101')
   AND nvl(jl.accounted_cr, jl.accounted_dr) <> 0
   AND jh.period_name = gp.period_name
   AND jh.ledger_id = 2021
   AND mo_global.check_access(sups.org_id) = 'Y'
   AND gp.end_date <= to_date('2019-04-08', 'YYYY-MM-DD')
   AND sup.vendor_name = '国网江苏省电力有限公司靖江市供电分公司'
   ;
--         ) order by  vendor_num,vendor_type
