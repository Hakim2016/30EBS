BEGIN
  fnd_global.apps_initialize(user_id      => 1670
                            ,resp_id      => 50717
                            ,resp_appl_id => 20003); 
 mo_global.init('CUX');
 mo_global.set_policy_context('M',NULL);
END;




SELECT /*ledger_name
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ,*/
 source_type
,segment3
,seg3_desc
,vendor_id
,vendor_code
,vendor_name
,currency_code
,decode(period_name
       ,'2018-08'
       ,entered_dr
       ,0) entered_dr
,decode(period_name
       ,'2018-08'
       ,entered_cr
       ,0) entered_cr
,decode(period_name
       ,'2018-08'
       ,accounted_dr
       ,0) accounted_dr
,decode(period_name
       ,'2018-08'
       ,accounted_cr
       ,0) accounted_cr
,decode(period_name
       ,'2018-08'
       ,0
       ,entered_dr) qc_entered_dr
, --期初输入借方
 decode(period_name
       ,'2018-08'
       ,0
       ,entered_cr) qc_entered_cr
, --期初输入贷方
 decode(period_name
       ,'2018-08'
       ,0
       ,accounted_dr) qc_accounted_dr
, --期初入账借方
 decode(period_name
       ,'2018-08'
       ,0
       ,accounted_cr) qc_accounted_cr --期初入账贷方
--modify by Orne.Dai 2019-01-28 end
FROM   (SELECT 'GL' source_type
              ,gl.name ledger_name
              ,gcc.segment3
              ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                    ,3
                                                    ,gcc.segment3) seg3_desc
              ,sup.vendor_id
              ,sup.segment1 vendor_code
              ,sup.vendor_name
              ,jh.currency_code
              ,SUM(nvl(jl.entered_dr
                      ,0)) entered_dr
              ,SUM(nvl(jl.entered_cr
                      ,0)) entered_cr
              ,SUM(nvl(jl.accounted_dr
                      ,0)) accounted_dr
              ,SUM(nvl(jl.accounted_cr
                      ,0)) accounted_cr
              ,jh.period_name --add by  Orne.Dai 2019-01-28        
        FROM   gl_je_headers            jh
              ,gl_je_lines              jl
              ,gl_import_references     gir
              ,gl_code_combinations_kfv gcc
              ,ap_suppliers             sup
              ,gl_ledgers               gl
        WHERE  jl.je_header_id = jh.je_header_id
        AND    gir.je_header_id(+) = jh.je_header_id
        AND    gir.je_header_id IS NULL --来源为总帐
        AND    jh.je_source <> 'Revaluation' --且来源不是Revaluation
        AND    gcc.code_combination_id = jl.code_combination_id
        AND    sup.vendor_id = jl.attribute5
        AND    gl.ledger_id = jh.ledger_id
        AND    jh.status = 'P'
        AND    jh.ledger_id = 2021
              --  AND jh.period_name = '2018-08'
        AND    jh.period_name <= '2018-08' --modify by Orne.Dai 2019-01-28 begin
        AND    sup.vendor_id = 1799
              --modify by Orne.Dai 2019-02-15 begin    
              --选择其他应付款  包含其他应付款，其他应付款 - 其他 , 其他应付款 - 往来，
              --AND gcc.segment3 = '2202010101' 
        AND    ((gcc.segment3 = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND gcc.segment3 IN ('2241010101'
                                                                 ,'2241020101'
                                                                 ,'2241030101')))
        --modify by Orne.Dai 2019-02-15 end
        GROUP  BY gl.name
                 ,gcc.segment3
                 ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                       ,3
                                                       ,gcc.segment3)
                 ,sup.vendor_id
                 ,sup.segment1
                 ,sup.vendor_name
                 ,jh.currency_code
                 ,jh.period_name --add by  Orne.Dai 2019-01-28  
        UNION ALL
        --来源于为： AP 发票
        SELECT 'AP_INVOICES' source_type
              ,gl.name ledger_name
              ,gcc.segment3
              ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                    ,3
                                                    ,gcc.segment3) seg3_desc
              ,sup.vendor_id
              ,sup.segment1 vendor_code
              ,sup.vendor_name
              ,jh.currency_code
              ,SUM(nvl(xla_l.entered_dr
                      ,0)) entered_dr
              ,SUM(nvl(xla_l.entered_cr
                      ,0)) entered_cr
              ,SUM(nvl(xla_l.accounted_dr
                      ,0)) accounted_dr
              ,SUM(nvl(xla_l.accounted_cr
                      ,0)) accounted_cr
              ,jh.period_name --add by  Orne.Dai 2019-01-28  
        FROM   gl_je_headers            jh
              ,gl_je_lines              jl
              ,gl_code_combinations_kfv gcc
              ,gl_import_references     gir
              ,xla_ae_lines             xla_l
              ,xla_ae_headers           xla_h
              ,ap_suppliers             sup
              ,fnd_lookup_values        flv2
              ,gl_ledgers               gl
              ,xla_event_types_vl       xla_type
              ,xla_event_classes_vl     xla_class
              ,xla_transaction_entities xla_e
              ,ap_invoices_all          ap
        WHERE  jh.je_source = 'Payables'
        AND    jl.je_header_id = jh.je_header_id
        AND    gcc.code_combination_id = jl.code_combination_id
        AND    gir.je_header_id = jl.je_header_id
        AND    gir.je_line_num = jl.je_line_num
        AND    xla_l.gl_sl_link_id = gir.gl_sl_link_id
        AND    xla_l.gl_sl_link_table = gir.gl_sl_link_table
        AND    xla_h.ae_header_id = xla_l.ae_header_id
        AND    xla_h.application_id = xla_l.application_id
        AND    sup.vendor_type_lookup_code = flv2.lookup_code(+)
        AND    flv2.lookup_type(+) = 'VENDOR TYPE'
        AND    flv2.language(+) = userenv('lang')
        AND    sup.vendor_id = xla_l.party_id
        AND    gl.ledger_id = jh.ledger_id
        AND    xla_type.entity_code = 'AP_INVOICES'
        AND    xla_type.event_type_code = xla_h.event_type_code
        AND    xla_type.application_id = xla_h.application_id
        AND    xla_class.application_id = xla_type.application_id
        AND    xla_class.event_class_code = xla_type.event_class_code
        AND    xla_e.entity_id = xla_h.entity_id
        AND    xla_e.application_id = xla_h.application_id
        AND    ap.invoice_id = nvl(xla_e.source_id_int_1
                                  ,-99)
        AND    ap.set_of_books_id = xla_e.ledger_id
        AND    xla_e.entity_code = 'AP_INVOICES'
        AND    jh.status = 'P'
        AND    jh.ledger_id = 2021
              --  AND jh.period_name = '2018-08'
        AND    jh.period_name <= '2018-08' --modify by Orne.Dai 2019-01-28 begin
        AND    sup.vendor_id = 1799
              --modify by Orne.Dai 2019-02-15 begin    
              --选择其他应付款  包含其他应付款，其他应付款 - 其他 , 其他应付款 - 往来，
              --AND gcc.segment3 = '2202010101' 
        AND    ((gcc.segment3 = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND gcc.segment3 IN ('2241010101'
                                                                 ,'2241020101'
                                                                 ,'2241030101')))
        --modify by Orne.Dai 2019-02-15 end
        GROUP  BY gl.name
                 ,gcc.segment3
                 ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                       ,3
                                                       ,gcc.segment3)
                 ,sup.vendor_id
                 ,sup.segment1
                 ,sup.vendor_name
                 ,jh.currency_code
                 ,jh.period_name --add by  Orne.Dai 2019-01-28  
        --add by Orne.Dai 2019-02-14 begin 
        --获取未入总账的数据
        UNION ALL
        --来源于为： AP 发票
        SELECT 'AP_INVOICES_XAL' source_type
              ,gl.name ledger_name
              ,gcc.segment3
              ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                    ,3
                                                    ,gcc.segment3) seg3_desc
              ,sup.vendor_id
              ,sup.segment1 vendor_code
              ,sup.vendor_name
              ,xla_l.currency_code
              ,SUM(nvl(xla_l.entered_dr
                      ,0)) entered_dr
              ,SUM(nvl(xla_l.entered_cr
                      ,0)) entered_cr
              ,SUM(nvl(xla_l.accounted_dr
                      ,0)) accounted_dr
              ,SUM(nvl(xla_l.accounted_cr
                      ,0)) accounted_cr
              ,to_char(xla_h.accounting_date
                      ,'YYYY-MM') period_name
        FROM   gl_code_combinations_kfv gcc
              ,
               
               xla_ae_lines             xla_l
              ,xla_ae_headers           xla_h
              ,ap_suppliers             sup
              ,fnd_lookup_values        flv2
              ,gl_ledgers               gl
              ,xla_event_types_vl       xla_type
              ,xla_event_classes_vl     xla_class
              ,xla_transaction_entities xla_e
              ,ap_invoices_all          ap
        WHERE  NOT EXISTS (SELECT 1
                FROM   gl_import_references gir
                      ,gl_je_lines          jl
                WHERE  gir.gl_sl_link_id = xla_l.gl_sl_link_id
                AND    gir.gl_sl_link_table = xla_l.gl_sl_link_table
                AND    jl.je_header_id = gir.je_header_id
                AND    jl.je_line_num = gir.je_line_num)
        AND    gcc.code_combination_id = xla_l.code_combination_id
        AND    xla_h.ae_header_id = xla_l.ae_header_id
        AND    xla_h.application_id = xla_l.application_id
        AND    sup.vendor_type_lookup_code = flv2.lookup_code(+)
        AND    flv2.lookup_type(+) = 'VENDOR TYPE'
        AND    flv2.language(+) = userenv('lang')
        AND    sup.vendor_id = xla_l.party_id
        AND    gl.ledger_id = xla_e.ledger_id
        AND    xla_type.entity_code = 'AP_INVOICES'
        AND    xla_type.event_type_code = xla_h.event_type_code
        AND    xla_type.application_id = xla_h.application_id
        AND    xla_class.application_id = xla_type.application_id
        AND    xla_class.event_class_code = xla_type.event_class_code
        AND    xla_e.entity_id = xla_h.entity_id
        AND    xla_e.application_id = xla_h.application_id
        AND    ap.invoice_id = nvl(xla_e.source_id_int_1
                                  ,-99)
        AND    ap.set_of_books_id = xla_e.ledger_id
        AND    xla_e.entity_code = 'AP_INVOICES'
        AND    ap_invoices_pkg.get_posting_status(ap.invoice_id) = 'Y' --已入账
        AND    1 = 1
        AND    gl.ledger_id = 2021
              --  AND jh.period_name = '2018-08'
        AND    to_char(xla_h.accounting_date
                      ,'YYYY-MM') <= '2018-08'
        AND    sup.vendor_id = 1799
              --modify by Orne.Dai 2019-02-15 begin    
              --选择其他应付款  包含其他应付款，其他应付款 - 其他 , 其他应付款 - 往来，
              --AND gcc.segment3 = '2202010101' 
        AND    ((gcc.segment3 = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND gcc.segment3 IN ('2241010101'
                                                                 ,'2241020101'
                                                                 ,'2241030101')))
        --modify by Orne.Dai 2019-02-15 end
        GROUP  BY gl.name
                 ,gcc.segment3
                 ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                       ,3
                                                       ,gcc.segment3)
                 ,sup.vendor_id
                 ,sup.segment1
                 ,sup.vendor_name
                 ,xla_l.currency_code
                 ,to_char(xla_h.accounting_date
                         ,'YYYY-MM')
        --add by Orne.Dai 2019-02-14 end
        UNION ALL
        --来源于为： AP 付款
        SELECT 'AP_PAYMENTS' source_type
              ,gl.name ledger_name
              ,gcc.segment3
              ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                    ,3
                                                    ,gcc.segment3) seg3_desc
              ,sup.vendor_id
              ,sup.segment1 vendor_code
              ,sup.vendor_name
              ,jh.currency_code
              ,SUM(nvl(xla_l.entered_dr
                      ,0)) entered_dr
              ,SUM(nvl(xla_l.entered_cr
                      ,0)) entered_cr
              ,SUM(nvl(xla_l.accounted_dr
                      ,0)) accounted_dr
              ,SUM(nvl(xla_l.accounted_cr
                      ,0)) accounted_cr
              ,jh.period_name --add by  Orne.Dai 2019-01-28  
        FROM   gl_je_headers            jh
              ,gl_je_lines              jl
              ,gl_code_combinations_kfv gcc
              ,gl_import_references     gir
              ,xla_ae_lines             xla_l
              ,xla_ae_headers           xla_h
              ,ap_suppliers             sup
              ,fnd_lookup_values        flv2
              ,gl_ledgers               gl
              ,xla_event_types_vl       xla_type
              ,xla_event_classes_vl     xla_class
              ,xla_transaction_entities xla_e
              ,ap_checks_all            ap
        WHERE  jh.je_source = 'Payables'
        AND    jl.je_header_id = jh.je_header_id
        AND    gcc.code_combination_id = jl.code_combination_id
        AND    gir.je_header_id = jl.je_header_id
        AND    gir.je_line_num = jl.je_line_num
        AND    xla_l.gl_sl_link_id = gir.gl_sl_link_id
        AND    xla_l.gl_sl_link_table = gir.gl_sl_link_table
        AND    xla_h.ae_header_id = xla_l.ae_header_id
        AND    xla_h.application_id = xla_l.application_id
        AND    sup.vendor_type_lookup_code = flv2.lookup_code(+)
        AND    flv2.lookup_type(+) = 'VENDOR TYPE'
        AND    flv2.language(+) = userenv('lang')
        AND    sup.vendor_id = xla_l.party_id
        AND    gl.ledger_id = jh.ledger_id
        AND    xla_type.entity_code = 'AP_PAYMENTS'
        AND    xla_type.event_type_code = xla_h.event_type_code
        AND    xla_type.application_id = xla_h.application_id
        AND    xla_class.application_id = xla_type.application_id
        AND    xla_class.event_class_code = xla_type.event_class_code
        AND    xla_e.entity_id = xla_h.entity_id
        AND    xla_e.application_id = xla_h.application_id
        AND    xla_e.entity_code = 'AP_PAYMENTS'
        AND    ap.check_id = nvl(xla_e.source_id_int_1
                                ,-99)
              --AND ap.set_of_books_id = xla_E.LEDGER_ID
        AND    jh.status = 'P'
        AND    jh.ledger_id = 2021
        AND    sup.vendor_id = 1799
              --  AND jh.period_name = '2018-08'
        AND    jh.period_name <= '2018-08' --modify by Orne.Dai 2019-01-28 begin
              --modify by Orne.Dai 2019-02-15 begin    
              --选择其他应付款  包含其他应付款，其他应付款 - 其他 , 其他应付款 - 往来，
              --AND gcc.segment3 = '2202010101' 
        AND    ((gcc.segment3 = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND gcc.segment3 IN ('2241010101'
                                                                 ,'2241020101'
                                                                 ,'2241030101')))
        --modify by Orne.Dai 2019-02-15 end
        GROUP  BY gl.name
                 ,gcc.segment3
                 ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                       ,3
                                                       ,gcc.segment3)
                 ,sup.vendor_id
                 ,sup.segment1
                 ,sup.vendor_name
                 ,jh.currency_code
                 ,jh.period_name --add by  Orne.Dai 2019-01-28  
        UNION ALL
        --add by Orne.Dai 2019-02-13 begin
        --获取未入总账的数据
        SELECT 'AP_PAYMENTS_XAL' source_type
              ,NULL ledger_name
              ,gcc.segment3
              ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                    ,3
                                                    ,gcc.segment3) seg3_desc
              ,sup.vendor_id
              ,sup.segment1 vendor_code
              ,sup.vendor_name
              ,
               
               xla_l.currency_code
              ,SUM(nvl(xla_l.entered_dr
                      ,0)) entered_dr
              ,SUM(nvl(xla_l.entered_cr
                      ,0)) entered_cr
              ,SUM(nvl(xla_l.accounted_dr
                      ,0)) accounted_dr
              ,SUM(nvl(xla_l.accounted_cr
                      ,0)) accounted_cr
              ,to_char(xla_h.accounting_date
                      ,'YYYY-MM') period_name
        FROM   gl_code_combinations_kfv     gcc
              ,xla_ae_lines                 xla_l
              ,xla_ae_headers               xla_h
              ,ap_suppliers                 sup
              ,fnd_lookup_values            flv2
              ,gl_ledgers                   gl
              ,xla_event_types_vl           xla_type
              ,xla_event_classes_vl         xla_class
              ,xla.xla_transaction_entities xla_e
              ,ap_checks_all                ap
        WHERE  NOT EXISTS (SELECT 1
                FROM   gl_import_references gir
                      ,gl_je_lines          jl
                WHERE  gir.gl_sl_link_id = xla_l.gl_sl_link_id
                AND    gir.gl_sl_link_table = xla_l.gl_sl_link_table
                AND    jl.je_header_id = gir.je_header_id
                AND    jl.je_line_num = gir.je_line_num)
        AND    gcc.code_combination_id = xla_l.code_combination_id
        AND    xla_h.ae_header_id = xla_l.ae_header_id
        AND    xla_h.application_id = xla_l.application_id
        AND    sup.vendor_type_lookup_code = flv2.lookup_code(+)
        AND    flv2.lookup_type(+) = 'VENDOR TYPE'
        AND    flv2.language(+) = userenv('lang')
        AND    sup.vendor_id = xla_l.party_id
        AND    gl.ledger_id = xla_e.ledger_id
              
        AND    xla_type.entity_code = 'AP_PAYMENTS'
        AND    xla_type.event_type_code = xla_h.event_type_code
        AND    xla_type.application_id = xla_h.application_id
        AND    xla_class.application_id = xla_type.application_id
        AND    xla_class.event_class_code = xla_type.event_class_code
        AND    xla_e.entity_id = xla_h.entity_id
        AND    xla_e.application_id = xla_h.application_id
        AND    xla_e.entity_code = 'AP_PAYMENTS'
              
        AND    ap.check_id = nvl(xla_e.source_id_int_1
                                ,-99)
        AND    ap_checks_pkg.get_posting_status(ap.check_id) = 'Y' --'已处理'
        AND    1 = 1
        AND    gl.ledger_id = 2021
        AND    sup.vendor_id = 1799
        AND    to_char(xla_h.accounting_date
                      ,'YYYY-MM') <= '2018-08'
              --modify by Orne.Dai 2019-02-15 begin    
              --选择其他应付款  包含其他应付款，其他应付款 - 其他 , 其他应付款 - 往来，
              --AND gcc.segment3 = '2202010101' 
        AND    ((gcc.segment3 = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND gcc.segment3 IN ('2241010101'
                                                                 ,'2241020101'
                                                                 ,'2241030101')))
        --modify by Orne.Dai 2019-02-15 end
        GROUP  BY gcc.segment3
                 ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                       ,3
                                                       ,gcc.segment3)
                 ,sup.vendor_id
                 ,sup.segment1
                 ,sup.vendor_name
                 ,xla_l.currency_code
                 ,xla_h.accounting_date
        --add by Orne.Dai 2019-02-13 end
        UNION ALL
        --来源为库存
        SELECT 'INV' source_type
              ,gl.name leder_name
              ,gcc.segment3
              ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                    ,3
                                                    ,gcc.segment3) seg3_desc
              ,sup.vendor_id
              ,sup.segment1 vendor_code
              ,sup.vendor_name
              ,jh.currency_code
              ,SUM(nvl(xla_l.entered_dr
                      ,0)) entered_dr
              ,SUM(nvl(xla_l.entered_cr
                      ,0)) entered_cr
              ,SUM(nvl(xla_l.accounted_dr
                      ,0)) accounted_dr
              ,SUM(nvl(xla_l.accounted_cr
                      ,0)) accounted_cr
              ,jh.period_name --add by  Orne.Dai 2019-01-28  
        FROM   gl_je_headers            jh
              ,gl_je_lines              jl
              ,gl_code_combinations_kfv gcc
              ,gl_import_references     gir
              ,xla_ae_lines             xla_l
              ,xla_ae_headers           xla_h
              ,gl_ledgers               gl
              ,gmf_xla_extract_headers  gmf_h
              ,gmf_rcv_accounting_txns  gmf_rcv
              ,rcv_transactions         rcv
              ,ap_suppliers             sup
              ,xla_event_types_vl       xla_type
              ,xla_event_classes_vl     xla_class
              ,rcv_shipment_headers     rsh
        WHERE  jh.je_source = 'Inventory'
              -- AND jh.name = '2018-06 接收 CNY'
        AND    jl.je_header_id = jh.je_header_id
        AND    gcc.code_combination_id = jl.code_combination_id
        AND    gir.je_header_id = jl.je_header_id
        AND    gir.je_line_num = jl.je_line_num
        AND    xla_l.gl_sl_link_id = gir.gl_sl_link_id
        AND    xla_l.gl_sl_link_table = gir.gl_sl_link_table
        AND    xla_h.ae_header_id = xla_l.ae_header_id
        AND    xla_h.application_id = xla_l.application_id
        AND    xla_h.application_id = 555
        AND    gl.ledger_id = jh.ledger_id
        AND    gmf_h.event_id = xla_h.event_id
        AND    gmf_rcv.accounting_txn_id = gmf_h.transaction_id
        AND    rcv.transaction_id = gmf_rcv.rcv_transaction_id
        AND    sup.vendor_id = rcv.vendor_id
              --AND xla_type.entity_code = 'INVENTORY'
        AND    xla_type.event_type_code = xla_h.event_type_code
        AND    xla_type.application_id = xla_h.application_id
        AND    xla_class.application_id = xla_type.application_id
        AND    xla_class.event_class_code = xla_type.event_class_code
        AND    rsh.shipment_header_id = rcv.shipment_header_id
        AND    jh.status = 'P'
        AND    jh.ledger_id = 2021
        AND    sup.vendor_id = 1799
              --  AND jh.period_name = '2018-08'
        AND    jh.period_name <= '2018-08' --modify by Orne.Dai 2019-01-28 begin
              --modify by Orne.Dai 2019-02-15 begin    
              --选择其他应付款  包含其他应付款，其他应付款 - 其他 , 其他应付款 - 往来，
              --AND gcc.segment3 = '2202010101' 
        AND    ((gcc.segment3 = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND gcc.segment3 IN ('2241010101'
                                                                 ,'2241020101'
                                                                 ,'2241030101')))
        --modify by Orne.Dai 2019-02-15 end
        GROUP  BY gl.name
                 ,gcc.segment3
                 ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                       ,3
                                                       ,gcc.segment3)
                 ,sup.vendor_id
                 ,sup.segment1
                 ,sup.vendor_name
                 ,jh.currency_code
                 ,jh.period_name --add by  Orne.Dai 2019-01-28  
        --add by Orne.Dai 2019-03-14 begin   
        UNION ALL
        SELECT 'FIX_DATA' source_type
              ,gl.name leder_name
              ,cas.account_segment
              ,ffv.description seg3_desc
              ,sup.vendor_id
              ,cas.vendor_number vendor_code
              ,cas.vendor_name
              ,cas.currency_code
              ,
               --修复数据皆为CNY币种，所以本币和外币相同
               nvl(cas.account_dr_diff
                  ,cas.account_dr) entered_dr
              ,nvl(cas.account_cr_diff
                  ,cas.account_cr) entered_cr
              ,nvl(cas.account_dr_diff
                  ,cas.account_dr) accounted_dr
              ,nvl(cas.account_cr_diff
                  ,cas.account_cr) account_cr
              ,cas.period_name
        FROM   cux_ap_supplier_qc_balance cas
              ,gl_ledgers                 gl
              ,ap_suppliers               sup
              ,fnd_flex_values_vl         ffv
              ,fnd_flex_value_sets        ffvs
        WHERE  cas.ledger_id = gl.ledger_id
        AND    sup.segment1 = cas.vendor_number
        AND    ffv.flex_value_set_id = ffvs.flex_value_set_id
        AND    ffvs.flex_value_set_name = 'ALAND_COA_ACC'
        AND    ffv.flex_value = cas.account_segment
        AND    sup.vendor_id = 1799
        AND    1 = 1
        AND    ((cas.account_segment = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND cas.account_segment IN ('2241010101'
                                                                        ,'2241020101'
                                                                        ,'2241030101')))
        /*               GROUP BY gl.name,
        cas.account_segment,
        ffv.description,
        cas.vendor_number,
        cas.vendor_name,
        cas.currency_code,
        cas.period_name --add by  Orne.Dai 2019-01-28  */
        
        )
ORDER  BY vendor_id;


   SELECT 'AP_INVOICES_XAL' source_type
              ,gl.name ledger_name
              ,gcc.segment3
              ,ap.INVOICE_NUM
              ,gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id
                                                    ,3
                                                    ,gcc.segment3) seg3_desc
              ,sup.vendor_id
              ,sup.segment1 vendor_code
              ,sup.vendor_name
              ,xla_l.currency_code
              ,nvl(xla_l.entered_dr
                      ,0) entered_dr
              ,nvl(xla_l.entered_cr
                      ,0) entered_cr
              ,nvl(xla_l.accounted_dr
                      ,0) accounted_dr
              ,nvl(xla_l.accounted_cr
                      ,0) accounted_cr
              ,to_char(xla_h.accounting_date
                      ,'YYYY-MM') period_name
        FROM   gl_code_combinations_kfv gcc
              ,
               
               xla_ae_lines             xla_l
              ,xla_ae_headers           xla_h
              ,ap_suppliers             sup
              ,fnd_lookup_values        flv2
              ,gl_ledgers               gl
              ,xla_event_types_vl       xla_type
              ,xla_event_classes_vl     xla_class
              ,xla_transaction_entities xla_e
              ,ap_invoices_all          ap
        WHERE  NOT EXISTS (SELECT 1
                FROM   gl_import_references gir
                      ,gl_je_lines          jl
                WHERE  gir.gl_sl_link_id = xla_l.gl_sl_link_id
                AND    gir.gl_sl_link_table = xla_l.gl_sl_link_table
                AND    jl.je_header_id = gir.je_header_id
                AND    jl.je_line_num = gir.je_line_num)
        AND    gcc.code_combination_id = xla_l.code_combination_id
        AND    xla_h.ae_header_id = xla_l.ae_header_id
        AND    xla_h.application_id = xla_l.application_id
        AND    sup.vendor_type_lookup_code = flv2.lookup_code(+)
        AND    flv2.lookup_type(+) = 'VENDOR TYPE'
        AND    flv2.language(+) = userenv('lang')
        AND    sup.vendor_id = xla_l.party_id
        AND    gl.ledger_id = xla_e.ledger_id
        AND    xla_type.entity_code = 'AP_INVOICES'
        AND    xla_type.event_type_code = xla_h.event_type_code
        AND    xla_type.application_id = xla_h.application_id
        AND    xla_class.application_id = xla_type.application_id
        AND    xla_class.event_class_code = xla_type.event_class_code
        AND    xla_e.entity_id = xla_h.entity_id
        AND    xla_e.application_id = xla_h.application_id
        AND    ap.invoice_id = nvl(xla_e.source_id_int_1
                                  ,-99)
        AND    ap.set_of_books_id = xla_e.ledger_id
        AND    xla_e.entity_code = 'AP_INVOICES'
        AND    ap_invoices_pkg.get_posting_status(ap.invoice_id) = 'Y' --已入账
        AND    1 = 1
        AND    gl.ledger_id = 2021
              --  AND jh.period_name = '2018-08'
        AND    to_char(xla_h.accounting_date
                      ,'YYYY-MM') <= '2018-08'
        AND    sup.vendor_id = 1799
              --modify by Orne.Dai 2019-02-15 begin    
              --选择其他应付款  包含其他应付款，其他应付款 - 其他 , 其他应付款 - 往来，
              --AND gcc.segment3 = '2202010101' 
        AND    ((gcc.segment3 = '2202010101' AND '2202010101' <> '2241010101') OR
              ('2202010101' = '2241010101' AND gcc.segment3 IN ('2241010101'
                                                                 ,'2241020101'
                                                                 ,'2241030101'))) ;