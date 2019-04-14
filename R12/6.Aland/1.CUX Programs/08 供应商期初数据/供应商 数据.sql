SELECT *
  FROM (SELECT gl.name                   ledger_name,
               jh.default_effective_date date1,
               sup.vendor_id,
               sup.segment1              vendor_code,
               sup.vendor_name
               --,flv2.meaning vendor_type
              ,
               gcc.code_combination_id,
               gcc.concatenated_segments,
               gcc.segment3,
               gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                     3,
                                                     gcc.segment3) segment3_desc,
               '总帐往来' event_class_name,
               jh.doc_sequence_value doc_number,
               jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
               jl.description,
               jh.currency_code,
               SUM(jl.entered_dr) entered_dr,
               SUM(jl.entered_cr) entered_cr,
               SUM(jl.accounted_dr) accounted_dr,
               SUM(jl.accounted_cr) accounted_cr
          FROM gl_je_headers            jh,
               gl_je_lines              jl,
               gl_import_references     gir,
               gl_code_combinations_kfv gcc,
               fnd_lookup_values        flv,
               ap_suppliers             sup
               --,fnd_lookup_values        flv2
              ,
               gl_ledgers gl
         WHERE jl.je_header_id = jh.je_header_id
           AND gir.je_header_id(+) = jh.je_header_id
           AND gir.je_header_id IS NULL --来源为总帐
           AND jh.je_source <> 'Revaluation' --且来源不是Revaluation
           AND gcc.code_combination_id = jl.code_combination_id
           AND flv.lookup_type = 'CUX_AP_VENDOR_DETAIL'
           AND flv.lookup_code = gcc.segment3
           AND flv.language(+) = userenv('lang')
           AND flv.enabled_flag = 'Y'
              /* AND sup.vendor_type_lookup_code = flv2.lookup_code(+)
              AND flv2.lookup_type(+) = 'VENDOR TYPE'
              AND flv2.language(+) = userenv('lang')*/
           AND sup.vendor_id = jl.attribute5
           AND gl.ledger_id = jh.ledger_id
           AND jh.status = 'P'
           AND jh.ledger_id = 2021
           AND jh.period_name BETWEEN '2018-09' AND '2018-09'
           AND sup.vendor_id = nvl(NULL,
                                   sup.vendor_id)
         GROUP BY gl.name,
                  jh.default_effective_date,
                  sup.vendor_id,
                  sup.segment1,
                  sup.vendor_name
                  --,flv2.meaning 
                 ,
                  gcc.code_combination_id,
                  gcc.concatenated_segments,
                  gcc.segment3,
                  gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                        3,
                                                        gcc.segment3),
                  '总帐往来',
                  jh.doc_sequence_value,
                  jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
                  jl.description,
                  jh.currency_code
        UNION ALL
        --来源于为： AP 发票
        SELECT gl.name ledger_name,
               ap.invoice_date date1,
               sup.vendor_id,
               sup.segment1 vendor_code,
               sup.vendor_name,
               gcc.code_combination_id,
               gcc.concatenated_segments,
               gcc.segment3,
               gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                     3,
                                                     gcc.segment3) segment3_desc,
               xla_class.name event_class_name
               --,ap.invoice_num doc_number
              ,
               jh.doc_sequence_value doc_number,
               jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
               jl.description,
               jh.currency_code,
               SUM(xla_l.entered_dr) entered_dr,
               SUM(xla_l.entered_cr) entered_cr,
               SUM(xla_l.accounted_dr) accounted_dr,
               SUM(xla_l.accounted_cr) accounted_cr
          FROM gl_je_headers                jh,
               gl_je_lines                  jl,
               gl_code_combinations_kfv     gcc,
               gl_import_references         gir,
               xla_ae_lines                 xla_l,
               xla_ae_headers               xla_h,
               ap_suppliers                 sup,
               fnd_lookup_values            flv2,
               gl_ledgers                   gl,
               xla_event_types_vl           xla_type,
               xla_event_classes_vl         xla_class,
               xla.xla_transaction_entities xla_e,
               ap_invoices_all              ap
         WHERE jh.je_source = 'Payables'
           AND jl.je_header_id = jh.je_header_id
           AND gcc.code_combination_id = jl.code_combination_id
           AND gir.je_header_id = jl.je_header_id
           AND gir.je_line_num = jl.je_line_num
           AND xla_l.gl_sl_link_id = gir.gl_sl_link_id
           AND xla_l.gl_sl_link_table = gir.gl_sl_link_table
           AND xla_h.ae_header_id = xla_l.ae_header_id
           AND xla_h.application_id = xla_l.application_id
           AND sup.vendor_type_lookup_code = flv2.lookup_code(+)
           AND flv2.lookup_type(+) = 'VENDOR TYPE'
           AND flv2.language(+) = userenv('lang')
           AND sup.vendor_id = xla_l.party_id
           AND gl.ledger_id = jh.ledger_id
           AND xla_type.entity_code = 'AP_INVOICES'
           AND xla_type.event_type_code = xla_h.event_type_code
           AND xla_type.application_id = xla_h.application_id
           AND xla_class.application_id = xla_type.application_id
           AND xla_class.event_class_code = xla_type.event_class_code
           AND xla_e.entity_id = xla_h.entity_id
           AND xla_e.application_id = xla_h.application_id
           AND ap.invoice_id = nvl(xla_e.source_id_int_1,
                                   -99)
           AND ap.set_of_books_id = xla_e.ledger_id
           AND xla_e.entity_code = 'AP_INVOICES'
           AND (EXISTS (SELECT 'X'
                          FROM fnd_lookup_values flv
                         WHERE flv.lookup_type = 'CUX_AP_VENDOR_DETAIL'
                           AND flv.lookup_code = gcc.segment3
                           AND flv.language(+) = userenv('lang')
                           AND flv.enabled_flag = 'Y') /*OR
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         xla_l.accounting_class_code IN ('ACCRUAL'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ,'LIABILITY'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ,'PREPAID_EXPENSE')*/
               )
           AND jh.status = 'P'
           AND jh.ledger_id = 2021
           AND jh.period_name BETWEEN '2018-09' AND '2018-09'
           AND sup.vendor_id = nvl(NULL,
                                   sup.vendor_id)
         GROUP BY gl.name,
                  ap.invoice_date,
                  sup.vendor_id,
                  sup.segment1,
                  sup.vendor_name,
                  gcc.code_combination_id,
                  gcc.concatenated_segments,
                  gcc.segment3,
                  gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                        3,
                                                        gcc.segment3),
                  xla_class.name
                  --,ap.invoice_num
                 ,
                  jh.doc_sequence_value,
                  jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
                  jl.description,
                  jh.currency_code
        UNION ALL
        --add by Orne.Dai 2019-02-13 begin  
        --来源为AP发票且未传入总账
        SELECT gl.name ledger_name,
               ap.invoice_date date1,
               sup.vendor_id,
               sup.segment1 vendor_code,
               sup.vendor_name,
               gcc.code_combination_id,
               gcc.concatenated_segments,
               gcc.segment3,
               gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                     3,
                                                     gcc.segment3) segment3_desc,
               xla_class.name event_class_name
               --,ap.invoice_num doc_number
              ,
               NULL doc_number,
               NULL default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
               NULL description,
               xla_l.currency_code,
               SUM(xla_l.entered_dr) entered_dr,
               SUM(xla_l.entered_cr) entered_cr,
               SUM(xla_l.accounted_dr) accounted_dr,
               SUM(xla_l.accounted_cr) accounted_cr
          FROM gl_code_combinations_kfv     gcc,
               xla_ae_lines                 xla_l,
               xla_ae_headers               xla_h,
               ap_suppliers                 sup,
               fnd_lookup_values            flv2,
               gl_ledgers                   gl,
               xla_event_types_vl           xla_type,
               xla_event_classes_vl         xla_class,
               xla.xla_transaction_entities xla_e,
               ap_invoices_all              ap
         WHERE NOT EXISTS (SELECT 1
                  FROM gl_import_references gir,
                       gl_je_lines          jl
                 WHERE gir.gl_sl_link_id = xla_l.gl_sl_link_id
                   AND gir.gl_sl_link_table = xla_l.gl_sl_link_table
                   AND jl.je_header_id = gir.je_header_id
                   AND jl.je_line_num = gir.je_line_num)
           AND gcc.code_combination_id = xla_l.code_combination_id
              
           AND xla_h.ae_header_id = xla_l.ae_header_id
           AND xla_h.application_id = xla_l.application_id
           AND sup.vendor_type_lookup_code = flv2.lookup_code(+)
           AND flv2.lookup_type(+) = 'VENDOR TYPE'
           AND flv2.language(+) = userenv('lang')
           AND sup.vendor_id = xla_l.party_id
           AND gl.ledger_id = xla_e.ledger_id
           AND xla_type.entity_code = 'AP_INVOICES'
           AND xla_type.event_type_code = xla_h.event_type_code
           AND xla_type.application_id = xla_h.application_id
           AND xla_class.application_id = xla_type.application_id
           AND xla_class.event_class_code = xla_type.event_class_code
           AND xla_e.entity_id = xla_h.entity_id
           AND xla_e.application_id = xla_h.application_id
           AND ap.invoice_id = nvl(xla_e.source_id_int_1,
                                   -99)
           AND ap.set_of_books_id = xla_e.ledger_id
           AND xla_e.entity_code = 'AP_INVOICES'
           AND (EXISTS (SELECT 'X'
                          FROM fnd_lookup_values flv
                         WHERE flv.lookup_type = 'CUX_AP_VENDOR_DETAIL'
                           AND flv.lookup_code = gcc.segment3
                           AND flv.language(+) = userenv('lang')
                           AND flv.enabled_flag = 'Y'))
           AND ap_invoices_pkg.get_posting_status(ap.invoice_id) = 'Y' --已入账
           AND 1 = 1
           AND gl.ledger_id = 2021
           AND to_char(xla_h.accounting_date,
                       'YYYY-MM') BETWEEN '2018-09' AND '2018-09'
           AND sup.vendor_id = nvl(NULL,
                                   sup.vendor_id)
         GROUP BY gl.name,
                  ap.invoice_date,
                  sup.vendor_id,
                  sup.segment1,
                  sup.vendor_name,
                  gcc.code_combination_id,
                  gcc.concatenated_segments,
                  gcc.segment3,
                  gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                        3,
                                                        gcc.segment3),
                  xla_class.name
                  --,ap.invoice_num
                 ,
                  xla_l.currency_code
        --add by Orne.Dai 2019-02-13 end 
        UNION ALL
        --来源于为： AP 付款
        SELECT gl.name ledger_name,
               ap.check_date date1,
               sup.vendor_id,
               sup.segment1 vendor_code,
               sup.vendor_name,
               gcc.code_combination_id,
               gcc.concatenated_segments,
               gcc.segment3,
               gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                     3,
                                                     gcc.segment3) segment3_desc,
               xla_class.name event_class_name
               --,to_char(ap.check_number) doc_number
              ,
               jh.doc_sequence_value doc_number,
               jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
               jl.description,
               jh.currency_code,
               SUM(xla_l.entered_dr) entered_dr,
               SUM(xla_l.entered_cr) entered_cr,
               SUM(xla_l.accounted_dr) accounted_dr,
               SUM(xla_l.accounted_cr) accounted_cr
          FROM gl_je_headers                jh,
               gl_je_lines                  jl,
               gl_code_combinations_kfv     gcc,
               gl_import_references         gir,
               xla_ae_lines                 xla_l,
               xla_ae_headers               xla_h,
               ap_suppliers                 sup,
               fnd_lookup_values            flv2,
               gl_ledgers                   gl,
               xla_event_types_vl           xla_type,
               xla_event_classes_vl         xla_class,
               xla.xla_transaction_entities xla_e,
               ap_checks_all                ap
         WHERE jh.je_source = 'Payables'
           AND jl.je_header_id = jh.je_header_id
           AND gcc.code_combination_id = jl.code_combination_id
           AND gir.je_header_id = jl.je_header_id
           AND gir.je_line_num = jl.je_line_num
           AND xla_l.gl_sl_link_id = gir.gl_sl_link_id
           AND xla_l.gl_sl_link_table = gir.gl_sl_link_table
           AND xla_h.ae_header_id = xla_l.ae_header_id
           AND xla_h.application_id = xla_l.application_id
           AND sup.vendor_type_lookup_code = flv2.lookup_code(+)
           AND flv2.lookup_type(+) = 'VENDOR TYPE'
           AND flv2.language(+) = userenv('lang')
           AND sup.vendor_id = xla_l.party_id
           AND gl.ledger_id = jh.ledger_id
           AND xla_type.entity_code = 'AP_PAYMENTS'
           AND xla_type.event_type_code = xla_h.event_type_code
           AND xla_type.application_id = xla_h.application_id
           AND xla_class.application_id = xla_type.application_id
           AND xla_class.event_class_code = xla_type.event_class_code
           AND xla_e.entity_id = xla_h.entity_id
           AND xla_e.application_id = xla_h.application_id
           AND xla_e.entity_code = 'AP_PAYMENTS'
           AND ap.check_id = nvl(xla_e.source_id_int_1,
                                 -99)
              --AND ap.set_of_books_id = xla_E.LEDGER_ID
           AND (EXISTS (SELECT 'X'
                          FROM fnd_lookup_values flv
                         WHERE flv.lookup_type = 'CUX_AP_VENDOR_DETAIL'
                           AND flv.lookup_code = gcc.segment3
                           AND flv.language(+) = userenv('lang')
                           AND flv.enabled_flag = 'Y') /*OR
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         xla_l.accounting_class_code IN ('ACCRUAL'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ,'LIABILITY'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ,'PREPAID_EXPENSE')*/
               )
           AND jh.status = 'P'
           AND jh.ledger_id = 2021
           AND jh.period_name BETWEEN '2018-09' AND '2018-09'
           AND sup.vendor_id = nvl(NULL,
                                   sup.vendor_id)
         GROUP BY gl.name,
                  ap.check_date,
                  sup.vendor_id,
                  sup.segment1,
                  sup.vendor_name,
                  gcc.code_combination_id,
                  gcc.concatenated_segments,
                  gcc.segment3,
                  gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                        3,
                                                        gcc.segment3),
                  xla_class.name
                  --,ap.check_number
                 ,
                  jh.doc_sequence_value,
                  jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
                  jl.description,
                  jh.currency_code
        --add by Orne.Dai 2019-02-14 begin
        --来源为AP付款且未传入总账
        UNION ALL
        SELECT gl.name ledger_name,
               ap.check_date date1,
               sup.vendor_id,
               sup.segment1 vendor_code,
               sup.vendor_name,
               gcc.code_combination_id,
               gcc.concatenated_segments,
               gcc.segment3,
               gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                     3,
                                                     gcc.segment3) segment3_desc,
               xla_class.name event_class_name
               --,to_char(ap.check_number) doc_number
              ,
               NULL doc_number,
               NULL default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
               NULL description,
               xla_l.currency_code,
               SUM(xla_l.entered_dr) entered_dr,
               SUM(xla_l.entered_cr) entered_cr,
               SUM(xla_l.accounted_dr) accounted_dr,
               SUM(xla_l.accounted_cr) accounted_cr
          FROM gl_code_combinations_kfv     gcc,
               xla_ae_lines                 xla_l,
               xla_ae_headers               xla_h,
               ap_suppliers                 sup,
               fnd_lookup_values            flv2,
               gl_ledgers                   gl,
               xla_event_types_vl           xla_type,
               xla_event_classes_vl         xla_class,
               xla.xla_transaction_entities xla_e,
               ap_checks_all                ap
         WHERE NOT EXISTS (SELECT 1
                  FROM gl_import_references gir,
                       gl_je_lines          jl
                 WHERE gir.gl_sl_link_id = xla_l.gl_sl_link_id
                   AND gir.gl_sl_link_table = xla_l.gl_sl_link_table
                   AND jl.je_header_id = gir.je_header_id
                   AND jl.je_line_num = gir.je_line_num)
           AND gcc.code_combination_id = xla_l.code_combination_id
           AND xla_h.ae_header_id = xla_l.ae_header_id
           AND xla_h.application_id = xla_l.application_id
           AND sup.vendor_type_lookup_code = flv2.lookup_code(+)
           AND flv2.lookup_type(+) = 'VENDOR TYPE'
           AND flv2.language(+) = userenv('lang')
           AND sup.vendor_id = xla_l.party_id
           AND gl.ledger_id = xla_e.ledger_id
           AND xla_type.entity_code = 'AP_PAYMENTS'
           AND xla_type.event_type_code = xla_h.event_type_code
           AND xla_type.application_id = xla_h.application_id
           AND xla_class.application_id = xla_type.application_id
           AND xla_class.event_class_code = xla_type.event_class_code
           AND xla_e.entity_id = xla_h.entity_id
           AND xla_e.application_id = xla_h.application_id
           AND xla_e.entity_code = 'AP_PAYMENTS'
           AND ap.check_id = nvl(xla_e.source_id_int_1,
                                 -99)
           AND (EXISTS (SELECT 'X'
                          FROM fnd_lookup_values flv
                         WHERE flv.lookup_type = 'CUX_AP_VENDOR_DETAIL'
                           AND flv.lookup_code = gcc.segment3
                           AND flv.language(+) = userenv('lang')
                           AND flv.enabled_flag = 'Y'))
           AND ap_checks_pkg.get_posting_status(ap.check_id) = 'Y' --'已处理'
           AND 1 = 1
           AND gl.ledger_id = 2021
           AND to_char(xla_h.accounting_date,
                       'YYYY-MM') BETWEEN '2018-09' AND '2018-09'
           AND sup.vendor_id = nvl(NULL,
                                   sup.vendor_id)
         GROUP BY gl.name,
                  ap.check_date,
                  sup.vendor_id,
                  sup.segment1,
                  sup.vendor_name,
                  gcc.code_combination_id,
                  gcc.concatenated_segments,
                  gcc.segment3,
                  gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                        3,
                                                        gcc.segment3),
                  xla_class.name
                  --,ap.check_number
                 ,
                  xla_l.currency_code
        --add by Orne.Dai 2019-02-14 end
        UNION ALL
        --来源为库存
        SELECT gl.name leder_name,
               rcv.transaction_date date1,
               sup.vendor_id,
               sup.segment1 vendor_code,
               sup.vendor_name,
               gcc.code_combination_id,
               gcc.concatenated_segments,
               gcc.segment3,
               gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                     3,
                                                     gcc.segment3) segment3_desc,
               xla_class.name event_class_name
               --,rsh.receipt_num doc_number
              ,
               jh.doc_sequence_value doc_number,
               jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
               jl.description,
               jh.currency_code,
               SUM(xla_l.entered_dr) entered_dr,
               SUM(xla_l.entered_cr) entered_cr,
               SUM(xla_l.accounted_dr) accounted_dr,
               SUM(xla_l.accounted_cr) accounted_cr
          FROM gl_je_headers            jh,
               gl_je_lines              jl,
               gl_code_combinations_kfv gcc,
               gl_import_references     gir,
               xla_ae_lines             xla_l,
               xla_ae_headers           xla_h,
               gl_ledgers               gl,
               gmf_xla_extract_headers  gmf_h,
               gmf_rcv_accounting_txns  gmf_rcv,
               rcv_transactions         rcv,
               ap_suppliers             sup,
               xla_event_types_vl       xla_type,
               xla_event_classes_vl     xla_class,
               rcv_shipment_headers     rsh
         WHERE jh.je_source = 'Inventory'
              -- AND jh.name = '2018-06 接收 CNY'
           AND jl.je_header_id = jh.je_header_id
           AND gcc.code_combination_id = jl.code_combination_id
           AND gir.je_header_id = jl.je_header_id
           AND gir.je_line_num = jl.je_line_num
           AND xla_l.gl_sl_link_id = gir.gl_sl_link_id
           AND xla_l.gl_sl_link_table = gir.gl_sl_link_table
           AND xla_h.ae_header_id = xla_l.ae_header_id
           AND xla_h.application_id = xla_l.application_id
           AND xla_h.application_id = 555
           AND gl.ledger_id = jh.ledger_id
           AND gmf_h.event_id = xla_h.event_id
           AND gmf_rcv.accounting_txn_id = gmf_h.transaction_id
           AND rcv.transaction_id = gmf_rcv.rcv_transaction_id
           AND sup.vendor_id = rcv.vendor_id
              --AND xla_type.entity_code = 'INVENTORY'
           AND xla_type.event_type_code = xla_h.event_type_code
           AND xla_type.application_id = xla_h.application_id
           AND xla_class.application_id = xla_type.application_id
           AND xla_class.event_class_code = xla_type.event_class_code
           AND rsh.shipment_header_id = rcv.shipment_header_id
           AND (EXISTS (SELECT 'X'
                          FROM fnd_lookup_values flv
                         WHERE flv.lookup_type = 'CUX_AP_VENDOR_DETAIL'
                           AND flv.lookup_code = gcc.segment3
                           AND flv.language(+) = userenv('lang')
                           AND flv.enabled_flag = 'Y') /*OR
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      (xla_l.accounting_class_code IN ('ACCRUAL'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ,'LIABILITY'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ,'PREPAID_EXPENSE'))*/
               )
           AND jh.status = 'P'
           AND jh.ledger_id = 2021
           AND jh.period_name BETWEEN '2018-09' AND '2018-09'
           AND sup.vendor_id = nvl(NULL,
                                   sup.vendor_id)
         GROUP BY gl.name,
                  rcv.transaction_date,
                  sup.vendor_id,
                  sup.segment1,
                  sup.vendor_name,
                  gcc.code_combination_id,
                  gcc.concatenated_segments,
                  gcc.segment3,
                  gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
                                                        3,
                                                        gcc.segment3),
                  xla_class.name
                  --,rsh.receipt_num
                 ,
                  jh.doc_sequence_value,
                  jh.default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
                  jl.description,
                  jh.currency_code) tmp,
       cux_ap_supplier_qc_balance cas
 WHERE cas.account_segment = tmp.segment3
   AND cas.vendor_number = tmp.vendor_code
   AND cas.currency_code = tmp.currency_code
 ORDER BY segment3,
          date1;
