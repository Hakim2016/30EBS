/*CURSOR cur_ar_data IS*/
--AR追溯
SELECT DISTINCT xal.ae_header_id xal_header_id,
                xal.ae_line_num xal_line_id,
                (xal.ae_header_id || '-' || xal.ae_line_num) sla_flag, --sla标识
                gjh.period_name, -- 期间,
                gjs.user_je_source_name, --来源,
                gjc.user_je_category_name, --类别,
                xentity_t.entity_code,
                xentity_t.name entity_cate_name, -- 事务实体类型名称,
                gjb.name je_batch_name, --   日记账批名, --批
                gjh.name je_name, --   日记账名, --日记账分录
                gjl.je_line_num je_line_num, --   日记账行号,
                --行追溯
                xte.transaction_number transcation_num, --事务处理编号,
                xe.event_date event_date, --事件日期, --事件日期
                xah.accounting_date gl_date, --gl日期,
                xgl.name cate_name, --分类账, --分类账
                fnd_flex_ext.get_segs('SQLGL', 'GL#', xgl.chart_of_accounts_id, xal.code_combination_id) account, --账户, --账户
                xla_oa_functions_pkg.get_ccid_description(xgl.chart_of_accounts_id, xal.code_combination_id) account_desc, --账户说明, --账户说明
                nvl(xlp.meaning, xal.accounting_class_code) acc_class, --会计分类, --会计分类
                --行追溯
                xal.accounted_dr in_borrow, -- 入帐借项, --入帐借项
                xal.accounted_cr in_credit, --入帐贷项, --入帐贷项
                xal.currency_code in_currend, --输入币种, --输入币种
                xal.entered_dr out_borrow, --输入借项, --输入借项
                xal.entered_cr out_credit, --输入贷项, --输入贷项
                xal.description line_desc, --行说明, --行说明
                gjh.name je_cate_name, --日记帐分录名, --日记帐分录名
                (nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)) in_net_amount, --入账净额
                ------------------------------      
                --AP_INVOICES  AP发票     INVOICE_ID                   \
                --AP_PAYMENTS  AP付款     CHECK_ID                      \
                --RECEIPTS     收款       CASH_RECEIPT_ID                这里根据事务的处理类型来分辨 来源的ID
                --TRANSACTIONS 事务处理  销售发票 CUSTOMER_TRX_ID       /
                xte.source_id_int_1 trans_source_id --事务源对应id
------------------------------

  FROM gl_je_batches    gjb,
       gl_je_headers    gjh,
       gl_je_lines      gjl,
       gl_je_sources_vl gjs,
       gl_je_categories gjc,
       --行追溯
       gl_import_references gir,
       --
       xla_ae_lines     xal,
       xla_lookups      xlp,
       xla_ae_headers   xah,
       xla_gl_ledgers_v xgl,
       --
       xla_events                   xe,
       xla.xla_transaction_entities xte,
       xla_entity_types_tl          xentity_t

 WHERE 1 = 1
   AND gjb.je_batch_id = gjh.je_batch_id
   AND gjh.je_header_id = gjl.je_header_id
   AND gjh.je_source = gjs.je_source_name
   AND gjc.je_category_name = gjh.je_category
      --行追溯
   AND gir.je_header_id = gjh.je_header_id
   AND gir.je_line_num = gjl.je_line_num
      --
   AND xal.gl_sl_link_id = gir.gl_sl_link_id
   AND xal.gl_sl_link_table = gir.gl_sl_link_table
   AND xlp.lookup_code(+) = xal.accounting_class_code
   AND xlp.lookup_type(+) = 'XLA_ACCOUNTING_CLASS'
      --
   AND xah.ae_header_id = xal.ae_header_id
   AND xah.application_id = xal.application_id
      --
   AND xgl.ledger_id = xah.ledger_id
      --
   AND xe.event_id = xah.event_id
   AND xe.application_id = xah.application_id
      --
   AND xte.entity_id = xe.entity_id
   AND xte.application_id = xe.application_id
      --
   AND xentity_t.entity_code = xte.entity_code
   AND xentity_t.application_id = xte.application_id
   AND xentity_t.language = userenv('LANG')
      
      --参数
   AND gjh.je_source = 'Receivables' --不区分语言，直接取code
   AND gjh.period_name BETWEEN nvl(p_period_f, gjh.period_name) AND nvl(p_period_t, gjh.period_name)
   AND xah.accounting_date BETWEEN nvl(p_gl_date_f, xah.accounting_date) AND nvl(p_gl_date_t, xah.accounting_date)
      --
   AND xal.code_combination_id BETWEEN nvl(p_account_f, xal.code_combination_id) AND
       nvl(p_account_t, xal.code_combination_id)
      --
      
   AND gjb.name = nvl(p_batch_num, gjb.name)
      
   AND gjh.ledger_id = p_set_of_books_id --帐套

 ORDER BY xte.transaction_number,
          xal.accounted_dr,
          xal.accounted_cr;
