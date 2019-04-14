SELECT t.je_source, t.*
  FROM ( /*CURSOR CUR_LINE IS*/
        --其他来源 排除了应付发票来源的日记账
        --直接取总账凭证上的数据即可
        SELECT gjh.period_name,
                gjh.name h_name,
                NULL invoice_num,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_COM' --g_aland_coa_comg
                    AND ffvv.flex_value = gcck.segment1) company,
                gcck.segment2 dept,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_DEPT' --g_aland_coa_dept
                    AND ffvv.flex_value = gcck.segment2) dept_des,
                gcck.segment3 acc,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_ACC' --g_aland_coa_acc
                    AND ffvv.flex_value = gcck.segment3) acc_des,
                gjl.attribute3 act_acc,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_ACC' --g_aland_coa_acc
                    AND ffvv.flex_value = gjl.attribute3) act_des,
                gjl.attribute5 sup_no,
                (SELECT pv.vendor_name
                   FROM po_vendors pv
                  WHERE pv.vendor_id = gjl.attribute5) sup_name,
                gjl.attribute4 ||
                (SELECT ppf.last_name
                   FROM per_people_f ppf
                  WHERE ppf.person_id = gjl.attribute4) person,
                to_char(gjh.doc_sequence_value) /*|| '-' || TO_CHAR(gjl.je_line_num)*/ doc_no,
                gjl.description,
                to_char(gjh.default_effective_date, 'YYYY-MM-DD') gl_date,
                gjh.currency_code,
                gjh.je_source,
                gjl.entered_dr,
                gjl.entered_cr,
                gjl.accounted_dr,
                gjl.accounted_cr,
                fu.description created_by
          FROM gl.gl_je_headers         gjh,
                gl.gl_je_lines           gjl,
                hr_operating_units       hou,
                gl_code_combinations_kfv gcck,
                fnd_user                 fu
         WHERE gjh.je_header_id = gjl.je_header_id
           AND gcck.code_combination_id = gjl.code_combination_id
           AND hou.set_of_books_id = gjh.ledger_id
           AND gjh.je_source <> 'Payables'
           AND fu.user_id = gjh.created_by
           AND gjh.ledger_id = 2021 --p_ledger_id
        /*AND lpad(gcck.segment2, 10, '0') BETWEEN
            nvl(p_dep_from, g_condition_min) AND nvl(p_dep_to, g_condition_max)
        AND gcck.segment3 IN
            (SELECT ffvv.flex_value_meaning
               FROM apps.fnd_flex_value_sets ffvs, apps.fnd_flex_values_vl ffvv
              WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                AND ffvv.enabled_flag = 'Y'
                AND SYSDATE BETWEEN nvl(start_date_active, SYSDATE) AND
                    nvl(end_date_active, SYSDATE)
                AND ffvs.flex_value_set_name = 'ALAND_COA_ACC'--g_aland_coa_acc
                   \*                       AND FFVV.DESCRIPTION LIKE '%费用%'*\
                AND substr(ffvv.compiled_value_attributes, 5, 1) = 'E'
                AND lpad(ffvv.flex_value_meaning, 10, '0') BETWEEN
                    nvl(p_acc_tit_from, g_condition_min) AND
                    nvl(p_acc_tit_to, g_condition_max))
        AND to_char(gjh.default_effective_date, 'YYYY-MM-DD') BETWEEN
            nvl(p_gl_date_from, g_period_min) AND
            nvl(p_gl_date_to, g_period_max)
        AND gjh.status = decode(p_not_post_include, 1, gjl.status, 'P')*/
        
        UNION ALL
        --应付账款来源
        --需要关联到子分类账获取还原科目，供应商编号，业务员
        SELECT gjh.period_name,
                gjh.name h_name,
                aia.invoice_num invoice_num,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_COM' --g_aland_coa_comg
                    AND ffvv.flex_value = gcck.segment1) company,
                gcck.segment2 dept,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_DEPT' --g_aland_coa_dept
                    AND ffvv.flex_value = gcck.segment2) dept_des,
                gcck.segment3 acc,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_ACC' --g_aland_coa_acc
                    AND ffvv.flex_value = gcck.segment3) acc_des,
                aid.attribute2 act_acc,
                (SELECT ffvv.description
                   FROM apps.fnd_flex_value_sets ffvs,
                        apps.fnd_flex_values_vl  ffvv
                  WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'ALAND_COA_ACC' --g_aland_coa_acc
                    AND ffvv.flex_value = aid.attribute2) act_des,
                to_char(aia.vendor_id) sup_no,
                (SELECT pv.vendor_name
                   FROM po_vendors pv
                  WHERE pv.vendor_id = aia.vendor_id) sup_name,
                aid.attribute4 ||
                (SELECT ppf.last_name
                   FROM per_people_f ppf
                  WHERE ppf.person_id = aid.attribute4) person,
                to_char(gjh.doc_sequence_value) doc_no,
                aid.description,
                to_char(gjh.default_effective_date, 'YYYY-MM-DD') gl_date,
                gjh.currency_code,
                gjh.je_source,
                xdl.unrounded_entered_dr entered_dr, ---revised by gujie 20180816
                xdl.unrounded_entered_cr entered_cr,
                xdl.unrounded_accounted_dr accounted_dr,
                xdl.unrounded_accounted_cr accounted_cr,
                fu1.description created_by
        /* XL.ENTERED_DR,
        XL.ENTERED_CR,
        XL.ACCOUNTED_DR,
        XL.ACCOUNTED_CR*/ ---revised by gujie 20180816
          FROM ap_invoices_all              aia,
                ap_invoice_distributions_all aid,
                gl_code_combinations_kfv     gcck,
                xla.xla_ae_headers           xh,
                xla.xla_ae_lines             xl,
                xla.xla_transaction_entities xte,
                gl_import_references         gir,
                gl_je_headers                gjh,
                xla_distribution_links       xdl,
                fnd_user                     fu1
         WHERE aid.invoice_id = aia.invoice_id
           AND aid.dist_code_combination_id = gcck.code_combination_id
           AND aid.line_type_lookup_code IN ('ITEM', 'ERV', 'IPV')
           AND aia.invoice_id = xte.source_id_int_1
           AND xh.ae_header_id = xl.ae_header_id
           AND xte.entity_id = xh.entity_id
           AND gir.gl_sl_link_id(+) = xl.gl_sl_link_id
           AND gir.je_header_id = gjh.je_header_id(+)
           AND xdl.ae_header_id = xl.ae_header_id
           AND xdl.ae_line_num = xl.ae_line_num
           AND xdl.applied_to_source_id_num_1 = aia.invoice_id
           AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id
           AND xl.code_combination_id = aid.dist_code_combination_id
           AND fu1.user_id = aia.created_by
           AND xh.ledger_id = 2021 --p_ledger_id
        /*AND lpad(gcck.segment2, 10, '0') BETWEEN
            nvl(p_dep_from, g_condition_min) AND nvl(p_dep_to, g_condition_max)
        AND gcck.segment3 IN
            (SELECT ffvv.flex_value_meaning
               FROM apps.fnd_flex_value_sets ffvs, apps.fnd_flex_values_vl ffvv
              WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
                AND ffvv.enabled_flag = 'Y'
                AND SYSDATE BETWEEN nvl(start_date_active, SYSDATE) AND
                    nvl(end_date_active, SYSDATE)
                AND ffvs.flex_value_set_name = 'ALAND_COA_ACC'--g_aland_coa_acc
                AND substr(ffvv.compiled_value_attributes, 5, 1) = 'E'
                AND lpad(ffvv.flex_value_meaning, 10, '0') BETWEEN
                    nvl(p_acc_tit_from, g_condition_min) AND
                    nvl(p_acc_tit_to, g_condition_max))
        AND to_char(gjh.default_effective_date, 'YYYY-MM-DD') BETWEEN
            nvl(p_gl_date_from, g_period_min) AND
            nvl(p_gl_date_to, g_period_max)
        AND gjh.status = decode(p_not_post_include, 1, gjh.status, 'P')*/
        ) t
 WHERE 1 = 1
      --AND t.period_name = '2018-08'
      --AND t.je_source = 'Payables'
      --AND t.sup_name IS NOT NULL
      --AND t.person IS NOT NULL
   AND t.act_des IS NOT NULL;


SELECT * from AP_INVOICE_DISTRIBUTIONS_V t where 1=1 AND t.attribute5 IS NOT NULL;
