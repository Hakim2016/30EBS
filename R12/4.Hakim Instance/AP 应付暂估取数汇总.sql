SELECT con_po_number  "合同/采购订单编号"
      ,nvl(con_name
          ,po_name) "合同/采购订单名称"
     ,NVL((SELECT DISTINCT cac.vendor_name
                   FROM cux_ap_con_iface cac
                  WHERE cac.con_num = con_po_number) 
               ,(SELECT DISTINCT cap.vendor_name
                   FROM cux_ap_po_iface cap
                  WHERE cap.po_num = con_po_number)) con_po_vendor_name
      ,SUM(nvl(dr_amount
              ,0)) "借方金额（本位币）"
      ,SUM(nvl(cr_amount
              ,0)) "贷方金额（本位币）"
  FROM (
        
        SELECT aila.attribute1 con_po_number
               ,(SELECT DISTINCT cac.con_name
                   FROM cux_ap_con_iface cac
                  WHERE cac.con_num = aila.attribute1) con_name
               ,(SELECT DISTINCT cap.po_name
                   FROM cux_ap_po_iface cap
                  WHERE cap.po_num = aila.attribute1) po_name
               ,aia.invoice_num
               ,aila.line_number
               ,aia.gl_date
               ,nvl(aids.base_amount
                   ,aids.amount) dr_amount
               ,0 cr_amount
          FROM ap_invoices_all              aia
               ,ap_invoice_lines_all         aila
               ,ap_invoice_distributions_all aids
               ,gl_code_combinations         gcc
         WHERE ap_invoices_pkg.get_approval_status(aia.invoice_id
                                                  ,aia.invoice_amount
                                                  ,aia.payment_status_flag
                                                  ,aia.invoice_type_lookup_code) <>
               'CANCELLED'
           AND aia.invoice_type_lookup_code = 'STANDARD'
           AND aia.gl_date < to_date('2014-11-23'
                                    ,'YYYY-MM-DD')
           AND aia.invoice_id = aila.invoice_id
           AND aia.invoice_id = aids.invoice_id
           AND aila.line_number = aids.invoice_line_number
           AND aids.dist_code_combination_id = gcc.code_combination_id
           AND gcc.segment3 = '220298010101'
        
        UNION ALL
        
        SELECT DISTINCT aila.attribute1 con_po_number
                       ,(SELECT DISTINCT cac.con_name
                           FROM cux_ap_con_iface cac
                          WHERE cac.con_num = aila.attribute1) con_name
                       ,(SELECT DISTINCT cap.po_name
                           FROM cux_ap_po_iface cap
                          WHERE cap.po_num = aila.attribute1) po_name
                       ,aia.invoice_num
                       ,0 line_number
                       ,aia.gl_date
                       ,0 dr_amount
                       ,nvl(aia.base_amount
                           ,aia.invoice_amount) cr_amount
          FROM ap_invoices_all      aia
              ,ap_invoice_lines_all aila
              ,gl_code_combinations gcc
         WHERE ap_invoices_pkg.get_approval_status(aia.invoice_id
                                                  ,aia.invoice_amount
                                                  ,aia.payment_status_flag
                                                  ,aia.invoice_type_lookup_code) <>
               'CANCELLED'
           AND aia.invoice_type_lookup_code = 'STANDARD'
           AND aia.gl_date < to_date('2014-11-23'
                                    ,'YYYY-MM-DD')
           AND aia.accts_pay_code_combination_id = gcc.code_combination_id
           AND gcc.segment3 = '220298010101'
           AND aia.invoice_id = aila.invoice_id
        
        UNION ALL
        
        SELECT con_po_number
              ,(SELECT DISTINCT cac.con_name
                  FROM cux_ap_con_iface cac
                 WHERE cac.con_num = con_po_number) con_name
              ,(SELECT DISTINCT cap.po_name
                  FROM cux_ap_po_iface cap
                 WHERE cap.po_num = con_po_number) po_name
              ,'' invoice_num
              ,0 line_number
              ,to_date('2099-12-12'
                      ,'YYYY-MM-DD') gl_date
              ,SUM(nvl(dr_amount
                      ,0)) dr_amount
              ,SUM(nvl(cr_amount
                      ,0)) cr_amount
          FROM (
                
                SELECT nvl(mmt.attribute4
                           ,mmt.attribute5) con_po_number
                       ,decode(sign(cid.base_transaction_value)
                              ,1
                              ,cid.base_transaction_value
                              ,0) dr_amount
                       ,decode(sign(cid.base_transaction_value)
                              ,-1
                              ,abs(cid.base_transaction_value)
                              ,0) cr_amount
                  FROM mtl_material_transactions mmt
                       ,cst_inv_distribution_v    cid
                       ,gl_code_combinations      gcc
                 WHERE mmt.transaction_id = cid.transaction_id
                   AND cid.reference_account = gcc.code_combination_id
                   AND mmt.transaction_date <
                       to_date('2014-11-23'
                              ,'YYYY-MM-DD')
                   AND gcc.segment3 = '220298010101')
         GROUP BY con_po_number)
 WHERE 1 = 1
 GROUP BY con_po_number
         ,con_name
         ,po_name
 ORDER BY con_po_number
