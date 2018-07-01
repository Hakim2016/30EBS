--main coursor
/*CURSOR sales_cur IS*/
      SELECT ooh.header_id oe_header_id,
             ooh.order_number,
             pp.project_id,
             pp.long_name project_long_name,
             pp.project_type,
             terr.territory_short_name country,
             cust.customer_number,
             cust.customer_name,
             ooh.cust_po_number,
             ooh.transactional_curr_code currency_code,
             sah.remark,
             tt.task_id top_task_id,
             tt.task_number mfg_number,
             get_concat_model_types(ooh.header_id) "MODEL",
             -- Milestone information
             pmm.fully_delivery_date,
             pmm.hand_over_date,
             -- order line status
             oe_line_status_pub.get_line_status(ool.line_id, ool.flow_status_code) line_status,
             SUM(nvl(ool.ordered_quantity, 0) * nvl(sal.price_eq, 0)) amount_eq,
             SUM(nvl(ool.ordered_quantity, 0) * nvl(sal.price_er, 0)) amount_er,
             SUM(nvl(ool.ordered_quantity, 0) * nvl(sal.price_fm, 0)) amount_fm,
             SUM(get_billing_amount(ooh.header_id, ool.line_id, p_gl_date_to)) billing_amount
        FROM oe_order_headers               ooh,
             xxpjm_so_addtn_headers         sah,
             ar_customers                   cust,
             hz_cust_site_uses_all          ship_su,
             hz_party_sites                 ship_ps,
             hz_locations                   ship_loc,
             hz_cust_acct_sites_all         ship_cas,
             fnd_territories_vl             terr,
             oe_order_lines                 ool,
             pa_projects                    pp,
             pa_tasks                       pt,
             pa_tasks                       tt,
             xxpa_proj_milestone_manage_all pmm,
             xxpjm_so_addtn_lines           sal
       WHERE ooh.sold_to_org_id = cust.customer_id(+)
         AND ooh.invoice_to_org_id = ship_su.site_use_id(+)
         AND ship_su.cust_acct_site_id = ship_cas.cust_acct_site_id(+)
         AND ship_cas.party_site_id = ship_ps.party_site_id(+)
         AND ship_ps.location_id = ship_loc.location_id(+)
         AND ship_loc.country = terr.territory_code(+)
            /*AND NVL(ooh.cancelled_flag, 'N') != 'Y'*/
         AND ooh.header_id = ool.header_id
            /*AND NVL(ool.cancelled_flag, 'N') != 'Y'*/
         AND ooh.header_id = sah.so_header_id(+)
         AND ool.line_id = sal.so_line_id
         AND ool.project_id = pp.project_id
         AND ool.task_id = pt.task_id
         AND pt.top_task_id = tt.task_id
         AND tt.task_id = pmm.task_id(+)
            /*AND ooh.ordered_date <= p_gl_date_to*/
         AND (p_oe_header_id IS NULL OR p_oe_header_id = ooh.header_id)
         AND (pmm.hand_over_date IS NULL OR pmm.hand_over_date >= g_golive_date)
       GROUP BY ooh.header_id,
                ooh.order_number,
                pp.project_id,
                pp.long_name,
                pp.project_type,
                terr.territory_short_name,
                cust.customer_number,
                cust.customer_name,
                ooh.cust_po_number,
                ooh.transactional_curr_code,
                sah.remark,
                tt.task_id,
                tt.task_number,
                -- Milestone information
                pmm.fully_delivery_date,
                pmm.hand_over_date,
                oe_line_status_pub.get_line_status(ool.line_id, ool.flow_status_code)
       ORDER BY ooh.order_number,
                pp.long_name;
