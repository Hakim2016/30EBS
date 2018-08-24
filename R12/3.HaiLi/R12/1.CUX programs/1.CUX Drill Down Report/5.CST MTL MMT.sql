/*CURSOR cur_mtl_data IS*/
--MTL׷��
SELECT DISTINCT xal.ae_header_id xal_header_id,
                xal.ae_line_num xal_line_id,
                xal.code_combination_id,
                (xal.ae_header_id || '-' || xal.ae_line_num) sla_flag, --sla��ʶ
                gjh.period_name, --   �ڼ�,
                gjs.user_je_source_name, -- ��Դ,
                gjc.user_je_category_name, -- ���,
                xentity_t.entity_code,
                xentity_t.name entity_cate_name, --  ����ʵ����������,
                --------------
                ec.event_class_code,
                ec.name             event_class, --�¼�����
                ----------------
                gjb.name        je_batch_name, --          �ռ�������,
                gjh.name        je_name, --        �ռ�����,
                gjl.je_line_num je_line_num, --      �ռ����к�,
                --��׷��
                xte.transaction_number transcation_num, --��������,
                xe.event_date event_date, -- �¼�����, --�¼�����
                xah.accounting_date gl_date, --gl����,
                xgl.name cate_name, --������, --������
                fnd_flex_ext.get_segs('SQLGL', 'GL#', xgl.chart_of_accounts_id, xal.code_combination_id) account, -- �˻�, --�˻�
                xla_oa_functions_pkg.get_ccid_description(xgl.chart_of_accounts_id, xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                nvl(xlp.meaning, xal.accounting_class_code) acc_class, --��Ʒ���, --��Ʒ���
                --��׷��
                xal.accounted_dr in_borrow, --���ʽ���, --���ʽ���
                xal.accounted_cr in_credit, --���ʴ���, --���ʴ���
                xal.currency_code in_currend, --�������, --�������
                xal.entered_dr out_borrow, --�������, --�������
                xal.entered_cr out_credit, --�������, --�������
                xal.description line_desc, --��˵��, --��˵��
                gjh.name je_cate_name, --    �ռ��ʷ�¼��, --�ռ��ʷ�¼��
                (nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)) in_net_amount, --���˾���
                xah.completed_date, --��ƽ�������,
                ------------------------------      
                --AP_INVOICES  AP��Ʊ     INVOICE_ID                   \
                --AP_PAYMENTS  AP����     CHECK_ID                      \
                --RECEIPTS     �տ�       CASH_RECEIPT_ID                �����������Ĵ����������ֱ� ��Դ��ID
                --TRANSACTIONS ������  ���۷�Ʊ CUSTOMER_TRX_ID       /
                xte.source_id_int_1 trans_source_id, --����Դ��Ӧid,
                ------------------------------
                xal.currency_conversion_rate /*, --�����ۻ���,
                                                                                                          --����MTL
                                                                                                          mmt.transaction_id transaction_flag, --�������ʶ,
                                                                                                          mtt.transaction_type_name transaction_cate, --����������,
                                                                                                          mmt.transaction_date, --����������,
                                                                                                          mtst.transaction_source_type_name trans_source_type, --��������Դ����,
                                                                                                          get_txn_source(mmt.transaction_id) transaction_source, -- ��������Դ,
                                                                                                          mtr.reason_name trans_reason, --������ԭ��,
                                                                                                          mmt.transaction_reference trans_reference, --������ο�,
                                                                                                          xah.completed_date, --��ƽ�������,
                                                                                                          cidv.gl_batch_id gl_batch, --gl��,
                                                                                                          mmt.subinventory_code, --�ӿ��,
                                                                                                          mmt.primary_quantity, --��Ҫ����
                                                                                                          mmt.transaction_uom primary_uom_code, --��Ҫ��λ
                                                                                                          mmt.locator_id, --��λid,
                                                                                                          cidv.revision, --�汾,
                                                                                                          mmt.department_id,
                                                                                                          mmt.inventory_item_id,
                                                                                                          mmt.organization_id*/

  FROM gl_je_batches    gjb,
       gl_je_headers    gjh,
       gl_je_lines      gjl,
       gl_je_sources_vl gjs,
       gl_je_categories gjc,
       --��׷��
       gl_import_references gir,
       --
       xla_ae_lines     xal,
       xla_lookups      xlp,
       xla_ae_headers   xah,
       xla_gl_ledgers_v xgl,
       --
       xla_events                   xe,
       xla.xla_transaction_entities xte,
       --�¼�����
       xla_event_types_tl   et,
       xla_event_classes_tl ec,
       --
       xla_entity_types_tl xentity_t /*,
                                                                                                 --����mtl
                                                                                                 mtl_material_transactions mmt,
                                                                                                 mtl_transaction_types     mtt,
                                                                                                 mtl_txn_source_types      mtst,
                                                                                                 mtl_transaction_reasons   mtr,
                                                                                                 cst_inv_distribution_v    cidv*/ --����

 WHERE 1 = 1
   AND gjb.je_batch_id = gjh.je_batch_id
   AND gjh.je_header_id = gjl.je_header_id
   AND gjh.je_source = gjs.je_source_name
   AND gjc.je_category_name = gjh.je_category
      --��׷��
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
      --�¼�����
   AND xe.application_id = et.application_id
   AND xe.event_type_code = et.event_type_code
   AND ec.application_id = et.application_id
   AND ec.entity_code = et.entity_code
   AND ec.event_class_code = et.event_class_code
   AND ec.language = userenv('LANG')
      /*--����mtl
      AND mmt.transaction_id = xte.source_id_int_1
      AND mmt.transaction_type_id = mtt.transaction_type_id
      AND mmt.transaction_source_type_id =
      mtst.transaction_source_type_id
      AND mmt.reason_id = mtr.reason_id(+) --�����ӣ���ֹû������ԭ��
      AND mmt.organization_id = cidv.organization_id
      AND mmt.transaction_id = cidv.transaction_id
      AND cidv.reference_account = xal.code_combination_id --����sla�˻�*/
      
      --����
   AND gjs.user_je_source_name IN ('Oracle Cost Management', 'Cost Management')
   AND gjh.je_category IN ('MTL', 'Inventory')
   AND gjh.period_name BETWEEN nvl(p_period_f, gjh.period_name) AND nvl(p_period_t, gjh.period_name)
   AND xah.accounting_date BETWEEN nvl(p_gl_date_f, xah.accounting_date) AND nvl(p_gl_date_t, xah.accounting_date)
      --
   AND xal.code_combination_id BETWEEN nvl(p_account_f, xal.code_combination_id) AND
       nvl(p_account_t, xal.code_combination_id)
      --
   AND gjb.name = nvl(p_batch_num, gjb.name)
      
   AND gjh.ledger_id = p_set_of_books_id --����

 ORDER BY xte.transaction_number,
          xal.accounted_dr,
          xal.accounted_cr;
          
