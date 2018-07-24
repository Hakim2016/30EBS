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
         
--CURSOR cur_invoice_header(p_header_id NUMBER) IS
      SELECT xxh.bill_to_address1 bill_to_messrs,
             xxh.ship_to_address1 consigned_to_messrs,
             xxh.invoice_number,
             rtl.name             payment_term,
             --v11.0 added by Hankin Gu on 2017-04-26 begin
             rtl.description payment_term_des,
             --v11.0 added by Hankin Gu on 2017-04-26 end
             xxh.delivery_term,
             xxh.invoice_date  date_of_issue,
             -- Added by HY. at 2016.07.14.begin. v 4.0.
             DECODE('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    '10 Toh Guan Road East',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line1')) line_1,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'Hitachi Elevator Building',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line2')) line_2,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'Singapore 608597',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line3')) line_3,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'Main Line:(65)6416-1711       Fax:(65)6561-0766',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line4')) line_4,
             decode('HEA_OU'/*l_ou_name*/, 'HEA_OU', '  ', xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line5')) line_5,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'Co. Regestration No. 197201468W',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line6')) line_6,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'CRNO.  11468720000N',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line7')) line_7,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'GST Registration No. M2-0014504-6',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Line8')) line_8,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'Hitachi Elevator Asia Pte.Ltd.',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Company')) line_company,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'Hitachi Elevator Asia Pte. Ltd.',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Bottom Company')) line_bottom_company,
             decode('HEA_OU'/*l_ou_name*/, 'HEA_OU', '', xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Tax invoice|Bottom Company2')) line_bottom_company2,
             decode('HEA_OU'/*l_ou_name*/,
                    'HEA_OU',
                    'Regional Operations Group',
                    xxar_tax_invoice_print_pkg.get_line_info(p_perfix => 'HEA_OU'/*l_ou_name*/ || '|Credit Note|Bottom Company3')) line_bottom_company3,
             -- Added by HY. at 2016.07.14.end. v 4.0.
             xxh.due_date,
             xxh.lc_number,
             ooh.cust_po_number      your_ref,
             ooh.order_number        our_ref,
             xxh.etd_date,
             xxh.eta_date,
             xxh.ship_from,
             xxh.transpotation_code  via,
             xxh.remark,
             xxh.ship_remark, --v8.0 add by liudan 2017/03/27
             ppa.long_name           project_name,
             xxh.interest_rate,
             xxh.attribute3          case_number,
             xxh.header_id,
             xxh.currency_code,
             xxh.ship_to_site_use_id,
             xxh.bill_to_site_use_id,
             xxh.invoice_type_code,
             xxh.attention_party,
             xxh.customer_name,
             xxh.tax_rate,
             ooh.invoice_to_org_id,-----
             ooh.ship_to_org_id,
             xxh.attribute1          ship_to,
             xxh.attribute2          attn_to,
             xxh.org_id,
             xxh.customer_id,
             xxh.interest_amount
             -- add by jiaming.zhou 2013-08-14 start
            ,
             xxh.status_code
      -- add by jiaming.zhou 2013-08-14 end
        FROM xxar_tax_invoice_headers_v xxh,
             ra_terms_tl                rtl,
             oe_order_headers_all       ooh,
             pa_projects_all            ppa

       WHERE xxh.payment_term_id = rtl.term_id(+)
         AND xxh.oe_header_id = ooh.header_id
         AND xxh.project_id = ppa.project_id(+)
         AND rtl.language(+) = userenv('LANG')
         AND xxh.header_id = 10311--11128--nvl(p_header_id, xxh.header_id)
;

--CURSOR cur_addr IS
      SELECT hl.city || ',' || ftl.territory_short_name
        FROM hz_cust_acct_sites_all hcs,
             hz_cust_site_uses_all  hua,
             hz_party_sites         hps,
             hz_locations           hl,
             fnd_territories_vl     ftl
       WHERE hua.site_use_id = 15462--p_site_use_id
            --AND hcs.status = 'A'
         AND hcs.cust_acct_site_id = hua.cust_acct_site_id
            --AND hua.status = 'A'
         AND hps.party_site_id = hcs.party_site_id
         AND hps.location_id = hl.location_id
         AND hl.country = ftl.territory_code(+);
         
--CURSOR cur IS invoice to(Bill to)
      SELECT 
             hua.site_use_id,
             --hua.bill_to_site_use_id,
             hl.address1,
             hl.address2,
             hl.address3,
             hl.address4,
             hl.city,
             ftl.territory_short_name,
             hl.postal_code
        FROM hz_cust_acct_sites_all hcs,
             hz_cust_site_uses_all  hua,
             hz_party_sites         hps,
             hz_locations           hl,
             fnd_territories_vl     ftl
       WHERE hua.site_use_id --= --12356--15462--p_site_use_id
       IN (15462)
         AND hcs.cust_acct_site_id = hua.cust_acct_site_id
         AND hps.party_site_id = hcs.party_site_id
         AND hps.location_id = hl.location_id
         AND hl.country = ftl.territory_code(+);

SELECT * FROM xxar_tax_invoice_headers_v;

--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;*/
