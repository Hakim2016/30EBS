SELECT xxh.invoice_number,
             xxh.header_id, --Sales Invoices
             ooh.order_number so_number, --S/O# x
             ctl.sales_order, --S/O#
             xxl.line_number --update by gusenlin  2012-7-15
            , --Line#
             xxl.model_type model --update by gusenlin 2012-7-15
            , --Model
             abs(nvl(ctl.quantity_credited, ctl.quantity_invoiced)) quantity, --Quantity
             abs(abs(nvl(ctl.gross_unit_selling_price, ctl.unit_selling_price)) - ctl1.unit_selling_price) revised_unit_price, --Revised unit price
             ctl1.unit_selling_price original_unit_price, --Original unit price
             abs(abs(abs(nvl(ctl.gross_unit_selling_price, ctl.unit_selling_price)) - ctl1.unit_selling_price) -
                 ctl1.unit_selling_price) difference, --Difference
             abs(nvl(ctl.quantity_credited, ctl.quantity_invoiced)) *
             abs(abs(abs(nvl(ctl.gross_unit_selling_price, ctl.unit_selling_price)) - ctl1.unit_selling_price) -
                 ctl1.unit_selling_price) total_amount --Total amount
        FROM xxar_tax_invoice_headers  xxh,
             oe_order_headers_all      ooh,
             ra_customer_trx           ct,
             ra_customer_trx           ct1,
             xxar_tax_invoice_lines    xxl,
             ra_customer_trx_lines_all ctl,
             ra_customer_trx_lines_all ctl1,
             --oe_order_lines            ool,
             hz_cust_accounts hca,
             hz_parties       hp
       WHERE xxh.customer_id = hca.cust_account_id
         AND hca.party_id = hp.party_id
         AND xxh.oe_header_id = ooh.header_id
            --AND xxh.header_id = xxl.header_id
            --AND xxl.oe_line_id              = ool.line_id(+)
         AND ct.previous_customer_trx_id = ct1.customer_trx_id
         AND xxh.invoice_number = ct1.trx_number
         AND ctl.customer_trx_id = ct.customer_trx_id
            --AND ctl.line_number             = xxl.line_number
         AND ctl.line_type IN ('LINE', 'CB', 'CHARGES')
         AND ctl1.customer_trx_id = ct1.customer_trx_id
            --AND ctl1.line_number            = xxl.line_number
         AND ctl1.line_type IN ('LINE', 'CB', 'CHARGES')
            --
            --AND ctl.line_number = ctl1.line_number
         AND ctl.previous_customer_trx_line_id = ctl1.customer_trx_line_id
         AND ctl1.interface_line_attribute4 = xxl.line_id
         AND ct.customer_trx_id = 4022542/*p_customer_trx_id*/
            --AND xxl.header_id               = p_header_id
            --parameter
            --AND ctl.sales_order             = nvl(p_so_number, ctl.sales_order)
         AND ooh.header_id = nvl(1097/*p_oe_header_id*/, ooh.header_id)
      UNION ALL
      SELECT xxh.invoice_number,
             xxh.header_id, --Sales Invoices
             ooh.order_number so_number, --S/O# x
             ctl.sales_order, --S/O#
             NULL line_number --update by gusenlin  2012-7-15
            , --Line#
             NULL model --update by gusenlin 2012-7-15
            , --Model
             1 quantity, --Quantity
             abs(abs(nvl(ctl.gross_unit_selling_price, ctl.unit_selling_price)) - ctl1.unit_selling_price) revised_unit_price, --Revised unit price
             ctl1.unit_selling_price original_unit_price, --Original unit price
             abs(abs(abs(nvl(ctl.gross_unit_selling_price, ctl.unit_selling_price)) - ctl1.unit_selling_price) -
                 ctl1.unit_selling_price) difference, --Difference
             abs(nvl(ctl.quantity_credited, ctl.quantity_invoiced)) *
             abs(abs(abs(nvl(ctl.gross_unit_selling_price, ctl.unit_selling_price)) - ctl1.unit_selling_price) -
                 ctl1.unit_selling_price) total_amount --Total amount
        FROM xxar_tax_invoice_headers xxh,
             oe_order_headers_all     ooh,
             ra_customer_trx          ct,
             ra_customer_trx          ct1
             --,xxar_tax_invoice_lines    xxl
            ,
             ra_customer_trx_lines_all ctl,
             ra_customer_trx_lines_all ctl1,
             --oe_order_lines            ool,
             hz_cust_accounts hca,
             hz_parties       hp
       WHERE xxh.customer_id = hca.cust_account_id
         AND hca.party_id = hp.party_id
         AND xxh.oe_header_id = ooh.header_id
            --AND xxh.header_id = xxl.header_id
            --AND xxl.oe_line_id              = ool.line_id(+)
         AND ct.previous_customer_trx_id = ct1.customer_trx_id
         AND xxh.invoice_number = ct1.trx_number
         AND ctl.customer_trx_id = ct.customer_trx_id
            --AND ctl.line_number             = xxl.line_number
         AND ctl.line_type IN ('LINE', 'CB', 'CHARGES')
         AND ctl1.customer_trx_id = ct1.customer_trx_id
            --AND ctl1.line_number            = xxl.line_number
         AND ctl1.line_type IN ('LINE', 'CB', 'CHARGES')
            --
            --AND ctl.line_number = ctl1.line_number
         --AND ctl.description = 'Hea Interest Line'
         --AND ctl1.description = 'Hea Interest Line'
         AND ct.customer_trx_id = 4022542/*p_customer_trx_id*/
            --AND xxl.header_id               = p_header_id
            --parameter
            --AND ctl.sales_order             = nvl(p_so_number, ctl.sales_order)
         AND ooh.header_id = nvl(1097/*p_oe_header_id*/, ooh.header_id);
