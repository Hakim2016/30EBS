在R12版本中月末关帐时经常会出现关不了的情况，而系统的异常报表的信息太过简单且不完全。结合项目本身发生的情况，做了以下的总结，希望能对公司其他R12项目有所启示。
R12月度关帐的要点：
检查SLA传送给GL的数据是否重复和丢失。
-- 检查SLA传送给GL的数据重复
  select aeh.gl_transfer_date,
         aeh.accounting_date, 
         aeh.description, 
         aeh.doc_sequence_value,
         cc.concatenated_segments,ael.*
  from   xla_ae_lines ael, xla_ae_headers aeh, gl_code_combinations_kfv cc
  where  ael.gl_sl_link_id in 
  (
  select gl_sl_link_id
    from APPS.gl_import_references
   where je_header_id in
         (select je_header_id
            from APPS.gl_je_headers
           where period_name = '2008-06')
   group by gl_sl_link_id
  having count(*)  = 2
  )
  and ael.ae_header_id=aeh.ae_header_id
  and ael.code_combination_id=cc.code_combination_id
如果存在则为传送给GL的数据重复。

-- 检查SLA传送给GL的数据是否缺失
SELECT xe.event_id, xh.ae_header_id
  FROM xla_events xe, xla_ae_headers xh
WHERE xe.event_id = xh.event_id
   AND xe.application_id = xh.application_id
   AND xh.accounting_entry_status_code = 'F'
   AND xe.event_status_code = 'P'
   AND xh.application_id = application_id -- (like 200 for AP, 222 for AR etc.,) 
   AND xh.upg_batch_id IS NULL
   AND xh.ledger_id = ledger_id -- give the ledger_id 
   AND NOT EXISTS
(SELECT 1
          FROM xla_ae_lines xl
         WHERE xl.ae_header_id = xh.ae_header_id
           AND xl.application_id = xh.application_id);
这个问题在oracle Doc ID:  Note:729296.1 Subject:  SLA: Accounting Data Missing from the SLA Tables 
碰到这样的问题需要installed R12 Fin RUP5 or the Subledger Accounting Critical Patches 这个在Doc已经
有了详细的介绍。

关闭AP的会计期：
  关闭AP的会计期的check主要是集中在xla这一块。

SELECT xte.*
  FROM xla.xla_events               xle,
       xla.xla_transaction_entities xte,
       gl_ledger_relationships      glr1,
       gl_ledger_relationships      glr2,
       xla.xla_ledger_options       xlo
WHERE xle.entity_id = xte.entity_id
   AND xle.application_id = xte.application_id
   AND xle.event_date BETWEEN to_date('2008-08-01', 'YYYY-MM-DD') AND
       to_date('2008-08-30', 'YYYY-MM-DD')
   AND glr2.target_ledger_id = p_ledger_id
   AND glr2.source_ledger_id = glr1.source_ledger_id
   AND glr2.application_id = glr1.application_id
   AND glr1.target_ledger_id = xlo.ledger_id
   AND xle.application_id = xlo.application_id
   AND xlo.capture_event_flag = 'Y'
   AND (glr1.target_ledger_id = xte.ledger_id OR
       glr1.primary_ledger_id = xte.ledger_id)
   AND (glr1.relationship_type_code = 'SUBLEDGER' OR
       (glr1.target_ledger_category_code = 'PRIMARY' AND
       glr1.relationship_type_code = 'NONE'))
   AND glr2.application_id = 101
   AND xte.application_id = p_application_id 
   AND xle.event_status_code IN ('I', 'U');

SELECT xte.*
  FROM xla.xla_ae_headers           aeh,
       xla.xla_transaction_entities xte,
       gl_ledger_relationships  glr1,
       gl_ledger_relationships  glr2
WHERE aeh.ledger_id = glr2.target_ledger_id
   AND glr2.source_ledger_id = glr1.source_ledger_id
   AND glr2.application_id = glr1.application_id
   AND glr1.target_ledger_id = p_ledger_id
   AND glr1.application_id = 101
   AND xte.entity_id = aeh.entity_id
   AND xte.application_id = aeh.application_id
   AND aeh.gl_transfer_status_code IN ('N', 'E')
   AND aeh.accounting_date  BETWEEN to_date('2008-07-01', 'YYYY-MM-DD') AND
       to_date('2008-07-31', 'YYYY-MM-DD')
   AND xte.application_id = p_application_id ;

当上述的2SQL中存在值时，这个时候AP的会计期是关闭不了的。我们可以通过
xla.xla_transaction_entities.source_id_int_1，ENTITY_CODE 去找到相应的子帐数据。
如果ENTITY_CODE = 'AP_PAYMENTS'  则source_id_int_1 = AP_CHECKS_ALL.CHECK_ID
如果ENTITY_CODE = 'AP_INVOICES'  则source_id_int_1 = AP_INVOICES_ALL.INVOICE_ID
如果ENTITY_CODE = 'TRANSACTIONS' 则source_id_int_1 = RA_CUSTOMER_TRX_ALL.customer_trx_id
如果ENTITY_CODE = 'RECEIPTS'     则source_id_int_1 = AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID
如果ENTITY_CODE = 'ADJUSTMENTS'  则source_id_int_1 = AR_ADJUSTMENTS_ALL.ADJUSTMENT_ID

另外Oracle也提供了AP的异常检查的 Doc ID:  Note:437422.1 
Subject:  R12 Troubleshooting Closing Periods in Payables 
主要是以下几个方面：
•All payment batches must be confirmed 
•All transactions must be accounted 
•All accounting entries must be transferred to general ledger 
•All future dated payments which have reached maturity in the accounting period must have their 
     status updated to negotiable and be accounted
详细细节请参考Note:437422.1 以及上面的SQL语句就可以找到问题。其中check AP会计期的程序其实是调用
XLA_EVENTS_PUB_PKG.PERIOD_CLOSE程序真正的检查程序是XLA_PERIOD_CLOSE_EXP_PKG.check_period_close 。



关闭AR的会计期：
　关闭AR的会计期时，Oracle没有象关闭AP会计期那样严格，只是检查收款和发票的核销。

/* check for Revenue recognition */
SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS (SELECT /*+ ORDERED USE_NL(sys_org gld ct) */
         'x'
          FROM (SELECT org_id
                  FROM ar_system_parameters_all
                 WHERE set_of_books_id = :control.set_of_books_id
                   AND accounting_method <> 'CASH') sys_org,
               ra_cust_trx_line_gl_dist_all gld,
               ra_customer_trx_all ct
         WHERE gld.account_class = 'REC'
           AND gld.latest_rec_flag = 'Y'
           AND gld.account_set_flag = 'Y'
           AND gld.gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND ct.customer_trx_id = gld.customer_trx_id
           AND ct.complete_flag = 'Y'
           AND gld.org_id = sys_org.org_id
           AND ct.org_id = gld.org_id);

/*** 'Unposted Items Exist' ***/
SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS (SELECT 'x'
          FROM ar_adjustments_all adj
         WHERE adj.posting_control_id = -3
           AND adj.gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND nvl(adj.postable, 'Y') = 'Y'
           AND adj.org_id IN
               (SELECT org_id
                  FROM ar_system_parameters_all
                 WHERE set_of_books_id = :control.set_of_books_id
                   AND accounting_method <> 'CASH'));

SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS
(SELECT 'x'
          FROM ar_misc_cash_distributions_all
         WHERE posting_control_id = -3
           AND gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND (org_id IS NULL OR
               org_id IN
               (SELECT org_id
                   FROM ar_system_parameters_all
                  WHERE set_of_books_id = :control.set_of_books_id)));

SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS (SELECT /*+ ORDERED USE_NL(sys_org gl ct) */
         'x'
          FROM (SELECT org_id
                  FROM ar_system_parameters_all
                 WHERE set_of_books_id = :control.set_of_books_id
                   AND accounting_method <> 'CASH') sys_org,
               ra_cust_trx_line_gl_dist_all gl,
               ra_customer_trx_all ct
         WHERE gl.customer_trx_id = ct.customer_trx_id
           AND ct.complete_flag = 'Y'
           AND gl.account_set_flag = 'N'
           AND gl.gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND gl.posting_control_id = -3
           AND gl.set_of_books_id = :control.set_of_books_id
           AND ct.org_id = sys_org.org_id
           AND gl.org_id = ct.org_id);

SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS (SELECT /*+ ORDERED USE_NL(sys_org ra ct) */
         'x'
          FROM (SELECT org_id
                  FROM ar_system_parameters_all
                 WHERE set_of_books_id = :control.set_of_books_id) sys_org,
               ar_receivable_applications_all ra,
               ra_customer_trx_all ct
         WHERE ra.posting_control_id = -3
           AND ra.gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND nvl(ra.postable, 'Y') = 'Y'
           AND (ra.customer_trx_id = ct.customer_trx_id OR
               ra.applied_customer_trx_id = ct.customer_trx_id)
           AND ra.org_id = sys_org.org_id
           AND ra.org_id = ct.org_id);

SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS
(SELECT 'x'
          FROM ar_cash_receipt_history_all crh
         WHERE posting_control_id = -3
           AND gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND postable_flag = 'Y'
           AND (crh.org_id IS NULL OR
               crh.org_id IN
               (SELECT org_id
                   FROM ar_system_parameters_all
                  WHERE set_of_books_id = :control.set_of_books_id)));

SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS
(SELECT 'x'
          FROM ar_interim_cash_receipts_all icr
         WHERE icr.gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND (icr.org_id IS NULL OR
               icr.org_id IN
               (SELECT org_id
                   FROM ar_system_parameters_all
                  WHERE set_of_books_id = :control.set_of_books_id)));

SELECT COUNT(1)
  INTO temp
  FROM dual
WHERE EXISTS
(SELECT 'x'
          FROM ar_transaction_history_all trh
         WHERE trh.posting_control_id = -3
           AND trh.gl_date BETWEEN :gl_period_statuses.start_date AND
               :gl_period_statuses.end_date
           AND trh.postable_flag = 'Y'
           AND (trh.org_id IS NULL OR
               trh.org_id IN
               (SELECT sp.org_id
                   FROM ar_system_parameters_all sp
                  WHERE sp.set_of_books_id = :control.set_of_books_id)));
假如上面的Sql中有任何一个存在值，当期的会计期是关闭不了的。其实这些都是关闭AR
会计期的check条件。


关闭GL的会计期：
  关闭GL的会计期，没有AP/AR条件那么苛刻，只要验证以下SQL就可以了

SELECT xte.*
  FROM xla.xla_events               xle,
       xla.xla_transaction_entities xte,
       gl_ledger_relationships      glr1,
       gl_ledger_relationships      glr2,
       xla_ledger_options           xlo
WHERE xle.entity_id = xte.entity_id
   AND xle.application_id = xte.application_id
   AND xle.event_date BETWEEN to_date('2008-07-01', 'YYYY-MM-DD') AND
       to_date('2008-07-31', 'YYYY-MM-DD')
   AND glr2.target_ledger_id = 2022
   AND glr2.source_ledger_id = glr1.source_ledger_id
   AND glr2.application_id = glr1.application_id
   AND glr1.target_ledger_id = xlo.ledger_id
   AND xle.application_id = xlo.application_id
   AND xlo.capture_event_flag = 'Y'
   AND (glr1.target_ledger_id = xte.ledger_id OR
       glr1.primary_ledger_id = xte.ledger_id)
   AND (glr1.relationship_type_code = 'SUBLEDGER' OR
       (glr1.target_ledger_category_code = 'PRIMARY' AND
       glr1.relationship_type_code = 'NONE'))
   AND glr2.application_id = 101
   AND xle.event_status_code IN ('I', 'U');
