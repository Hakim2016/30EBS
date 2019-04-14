SELECT gl.name                   ledger_name,
       ap.check_number,ap.check_id,ap.void_date,
       ap.check_date             date1,
       sup.vendor_id,
       sup.segment1              vendor_code,
       sup.vendor_name,
       gcc.code_combination_id,
       gcc.concatenated_segments,
       gcc.segment3,
       /* gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,
       3,
       gcc.segment3) segment3_desc,*/
       xla_class.name event_class_name
       --,to_char(ap.check_number) doc_number
      ,
       NULL                doc_number,
       NULL                default_effective_date, --add by Orne.Dai 2019-02-22 增加GL日期
       NULL                description,
       xla_l.currency_code,
       xla_l.entered_dr    entered_dr,
       xla_l.entered_cr    entered_cr,
       xla_l.accounted_dr  accounted_dr,
       xla_l.accounted_cr  accounted_cr
/*SUM(xla_l.entered_dr) entered_dr,
SUM(xla_l.entered_cr) entered_cr,
SUM(xla_l.accounted_dr) accounted_dr,
SUM(xla_l.accounted_cr) accounted_cr*/
  FROM apps.gl_code_combinations_kfv gcc,
       xla.xla_ae_lines              xla_l,
       xla.xla_ae_headers            xla_h,
       ap.ap_suppliers               sup,
       applsys.fnd_lookup_values     flv2,
       gl.gl_ledgers                 gl,
       apps.xla_event_types_vl       xla_type,
       apps.xla_event_classes_vl     xla_class,
       xla.xla_transaction_entities  xla_e,
       ap.ap_checks_all              ap
 WHERE NOT EXISTS (SELECT 1
          FROM gl.gl_import_references gir,
               gl.gl_je_lines          jl
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
   AND ap.check_id = nvl(xla_e.source_id_int_1, -99)
   AND (EXISTS (SELECT 'X'
                  FROM applsys.fnd_lookup_values flv
                 WHERE flv.lookup_type = 'CUX_AP_VENDOR_DETAIL'
                   AND flv.lookup_code = gcc.segment3
                   AND flv.language(+) = userenv('lang')
                   AND flv.enabled_flag = 'Y'))
      -- AND ap_checks_pkg.get_posting_status(ap.check_id) = 'Y' --'已处理'
   AND 1 = 1
   AND gl.ledger_id = 2021
   AND to_char(xla_h.accounting_date, 'YYYY-MM') BETWEEN
       '2018-08' AND '2018-08'
   AND sup.vendor_id = nvl(1453, sup.vendor_id)
   AND gcc.segment3 = '2201010101'
   AND ap.void_date IS NULL
