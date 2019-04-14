SELECT 'AP_INVOICE' source_type,
       xal.accounting_date default_effective_date, --日期
       NULL doc_sequence_value, --凭证号
       nvl(ai.attribute1, '0') project_number, --项目编码
       gcc.segment3, --科目编码
       gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                             3,
                                             gcc.segment3) seg3_desc, --科目名称
       aid.description, --摘要
       xal.accounted_dr amt_dr, --借方
       xal.accounted_cr amt_cr --贷方
  FROM ap_invoice_lines_all         ail,
       ap_invoices_all              ai,
       xla.xla_transaction_entities xte,
       xla.xla_events               xe,
       xla.xla_ae_headers           xah,
       xla.xla_ae_lines             xal,
       xla.xla_distribution_links   xdl,
       ap_invoice_distributions_all aid,
       gl_code_combinations         gcc,
       gl_periods                   gp
 WHERE ai.invoice_id = ail.invoice_id
   AND ap_invoices_pkg.get_posting_status(ai.invoice_id) = 'Y' --已入账
   AND ai.set_of_books_id = xte.ledger_id
   AND ai.invoice_id = xte.source_id_int_1
   AND xte.entity_id = xe.entity_id
   AND xe.event_id = xah.event_id
   AND xal.ae_header_id = xah.ae_header_id
   AND xte.entity_code = 'AP_INVOICES'
   AND xal.application_id = 200
   AND xal.ae_header_id = xdl.ae_header_id
   AND xal.ae_line_num = xdl.ae_line_num
   AND xal.application_id = xdl.application_id
   AND xal.accounting_class_code = 'LIABILITY'
   AND xdl.event_id = aid.accounting_event_id
   AND ((xdl.source_distribution_id_num_1 = aid.invoice_distribution_id AND
       xdl.source_distribution_type = 'AP_INV_DIST') OR
       (xdl.applied_to_dist_id_num_1 = aid.prepay_distribution_id AND
       xdl.source_distribution_type = 'AP_PREPAY'))
   AND aid.invoice_id = ai.invoice_id
   AND aid.invoice_line_number = ail.line_number
      -- AND ail.line_type_lookup_code = 'ITEM'
   AND (nvl(xal.accounted_dr, 0) <> 0 OR nvl(xal.accounted_cr, 0) <> 0)
   AND xal.code_combination_id = gcc.code_combination_id
   AND gcc.segment3 = nvl(&p_acct_segment, gcc.segment3)
   AND nvl(ai.attribute1, '0') = nvl(NULL, nvl(ai.attribute1, '0'))
   AND gcc.segment3 LIKE '1604%'
   AND gcc.segment3 NOT LIKE '160499%'
   AND gp.period_set_name = 'ALAND_CAL' --艾兰得日历
   AND xal.accounting_date BETWEEN gp.start_date AND gp.end_date
      
   AND xal.ledger_id = 2021
   AND '2018-08' = '2018-08' --2018-08数据来源需包含AP发票
   AND gp.period_name = '2018-08'
UNION ALL
--来源于付款
SELECT 'AP_CHECK',
       xal.accounting_date,
       NULL doc_sequence_value, --凭证号
       nvl(ai.attribute1, '0') project_number, --项目编码
       gcc.segment3, --科目编码
       gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                             3,
                                             gcc.segment3) seg3_desc, --科目名称
       NULL description, --摘要
       xal.accounted_dr, --借方
       xal.accounted_cr --贷方
  FROM xla.xla_ae_headers           xah,
       xla.xla_ae_lines             xal,
       xla.xla_transaction_entities xte,
       ap_invoices_all              ai,
       ap_checks_all                ac,
       ap_invoice_payments_all      aip,
       gl_code_combinations         gcc,
       gl_periods                   gp
 WHERE xah.accounting_entry_status_code = 'F'
   AND xah.application_id = 200
   AND xte.ledger_id = 2021
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.application_id = xal.application_id
   AND xah.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xte.entity_code = 'AP_PAYMENTS'
   AND nvl(xte.source_id_int_1, -99) = ac.check_id
   AND ac.check_id = aip.check_id
   AND aip.invoice_id = ai.invoice_id
   AND xal.code_combination_id = gcc.code_combination_id
   AND gcc.segment3 = nvl(&p_acct_segment, gcc.segment3)
   AND nvl(ai.attribute1, '0') = nvl(NULL, nvl(ai.attribute1, '0'))
   AND gcc.segment3 LIKE '1604%'
   AND gcc.segment3 NOT LIKE '160499%'
   AND gp.period_set_name = 'ALAND_CAL' --艾兰得日历
   AND xal.accounting_date BETWEEN gp.start_date AND gp.end_date
      
   AND xal.ledger_id = 2021
   AND '2018-08' = '2018-08' --2018-08数据来源需包含AP福付款
   AND gp.period_name = '2018-08'
UNION ALL
SELECT 'GL',
       jh.default_effective_date,
       jh.doc_sequence_value,
       gcc.segment7 project_number,
       gcc.segment3,
       gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                             3,
                                             gcc.segment3) seg3_desc,
       jl.description,
       jl.accounted_dr amt_dr,
       jl.accounted_cr amt_cr
  FROM gl_je_headers            jh,
       gl_je_lines              jl,
       gl_code_combinations_kfv gcc
 WHERE 1 = 1
   AND jl.je_header_id = jh.je_header_id
   AND gcc.code_combination_id = jl.code_combination_id
   AND (jh.status = 'P' AND 'Y' = 'N' OR 'Y' = 'Y')
   AND jh.ledger_id = 2021
   AND jh.period_name = '2018-08'
   AND gcc.segment3 = nvl(&p_acct_segment, gcc.segment3)
   AND gcc.segment7 = nvl(NULL, gcc.segment7)
   AND gcc.segment3 LIKE '1604%'
   AND gcc.segment3 NOT LIKE '160499%'
   AND (('2018-08' = '2018-08' AND gcc.segment3 <> '1604040101') OR --2018-08期间1604040101科目数据从AP模块取数
       '2018-08' <> '2018-08')
   AND (nvl(jl.accounted_dr, 0) <> 0 OR nvl(jl.accounted_cr, 0) <> 0)
UNION ALL
--系统中缺失的9月份期初金额
SELECT 'QC',
       to_date('2018-08-31', 'YYYY-MM-DD') accounting_date,
       NULL doc_sequence_value,
       qc.project_num project_number,
       qc.account_segment,
       fv.description seg3_desc,
       '期初缺失数据' description,
       qc.account_balance amt_dr,
       NULL amt_cr
  FROM cux_gl_constru_prj_qc_bal qc,
       fnd_flex_value_sets       fvs,
       fnd_flex_values_vl        fv
 WHERE 1 = 1
   AND qc.account_segment = fv.flex_value
   AND fvs.flex_value_set_id = fv.flex_value_set_id
   AND fvs.flex_value_set_name = 'ALAND_COA_ACC'
   AND qc.ledger_id = 2021
   AND qc.period_name = '2018-08'
   AND qc.account_segment = nvl(&p_acct_segment, qc.account_segment)
   AND qc.project_num = nvl(NULL, qc.project_num)
 ORDER BY segment3,
          project_number,
          1;
