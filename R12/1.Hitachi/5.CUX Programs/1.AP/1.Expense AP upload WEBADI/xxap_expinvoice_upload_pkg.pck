CREATE OR REPLACE PACKAGE xxap_expinvoice_upload_pkg IS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
     webadi_upload:process record uploaded by webadi,
                   validate the data and insert them
                   into tmp interface table
     main:conncurrent program to transfer datas
          from temp interface table to system standard
          interface table and call the ebs standard
          ap invoice import concurrent to create ap invoice
  Description:
    
  History:
     1.00 20120517   shiliang.yu       Creation
  ==================================================*/
  PROCEDURE webadi_upload(p_session_id IN NUMBER,
                          --
                          --
                          p_supplier_number IN VARCHAR2,
                          p_supplier_name   IN VARCHAR2,
                          p_account         IN VARCHAR2,
                          p_subaccount      IN VARCHAR2,
                          p_cost_center     IN VARCHAR2,
                          p_payment_method  IN VARCHAR2,
                          p_tax_rate_name   IN VARCHAR2,
                          p_tax_amount      IN NUMBER,
                          p_line_amount     IN NUMBER,
                          p_description     IN VARCHAR2,
                          p_invoice_number  IN VARCHAR2,
                          --                          p_invoice_amount         IN NUMBER,
                          p_invoice_date IN DATE,
                          p_gl_date      IN DATE,
                          /*                          p_rate_type              IN VARCHAR2,
                                                    p_exchange_date          IN DATE,
                                                    p_exchange_rate          IN VARCHAR2,
                                                    p_terms_date             IN DATE,                          
                                                    p_mdfy_tx_amnt_fnc_crrnc IN VARCHAR2,                          
                                                    p_dflt_dstrbtn_on_accnt  IN VARCHAR2,*/
                          p_project IN VARCHAR2,
                          p_task    IN VARCHAR2,
                          --                          p_expndte_itm_dt         IN DATE,
                          p_expndte_type IN VARCHAR2,
                          --
                          --p_gl_ledger_name  IN VARCHAR2,
                          p_ou_name IN VARCHAR2,
                          --p_company_code    IN VARCHAR2,
                          p_invoice_type     IN VARCHAR2,
                          p_terms            IN VARCHAR2,
                          p_supplier_site_c  IN VARCHAR2,
                          p_invoice_currency IN VARCHAR2,
                          p_rate_type        IN VARCHAR2,
                          --p_rate_date        IN date,
                          p_rate IN NUMBER);
  PROCEDURE main(errbuf     OUT VARCHAR2,
                 retcode    OUT NUMBER,
                 p_group_id IN NUMBER);
  FUNCTION get_account_desc(p_char_of_account_id IN NUMBER,
                            p_con_seg            IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION chk_operating_unit(p_operating_unit IN VARCHAR2) RETURN NUMBER;
END xxap_expinvoice_upload_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxap_expinvoice_upload_pkg IS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
     webadi_upload:process record uploaded by webadi,
                   validate the data and insert them
                   into tmp interface table
     main:conncurrent program to transfer datas
          from temp interface table to system standard
          interface table and call the ebs standard
          ap invoice import concurrent to create ap invoice
  Description:
    
  History:
     1.00 20120517   shiliang.yu       Creation
     2.00 20150226   yan.huang         update the chk_tax_rate_name
     3.00 20150303   zhe.yang          update the tax_amount
     4.00 20150828   Jinlong.Pan       update for adding Line Description
     4.01 20160303   Jinjin.Lv         update for Gl Date
  ==================================================*/
  g_org_id NUMBER;

  FUNCTION get_message(p_appl_name    IN VARCHAR2,
                       p_message_name IN VARCHAR2,
                       p_token1       IN VARCHAR2 DEFAULT NULL,
                       p_token1_value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    fnd_message.clear;
    fnd_message.set_name(p_appl_name, p_message_name);
    IF p_token1 IS NOT NULL THEN
      fnd_message.set_token(p_token1, p_token1_value);
    END IF;
    RETURN fnd_message.get;
  END get_message;

  FUNCTION get_chart_of_accounts_id(p_set_of_books_id IN NUMBER) RETURN NUMBER IS
    ln_chart_of_accounts_id NUMBER;
  BEGIN
    SELECT sob.chart_of_accounts_id
      INTO ln_chart_of_accounts_id
      FROM gl_sets_of_books sob
     WHERE sob.set_of_books_id = p_set_of_books_id;
    RETURN ln_chart_of_accounts_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_chart_of_accounts_id;

  FUNCTION get_loc_curr_code(p_set_of_books_id IN NUMBER) RETURN VARCHAR2 IS
    l_loc_curr_code VARCHAR2(10);
  BEGIN
    SELECT sob.currency_code
      INTO l_loc_curr_code
      FROM gl_sets_of_books sob
     WHERE sob.set_of_books_id = p_set_of_books_id;
    RETURN l_loc_curr_code;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_loc_curr_code;

  FUNCTION get_company_code(p_ou_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_company_code VARCHAR2(100);
  BEGIN
    SELECT gcc.segment1
      INTO l_company_code
      FROM financials_system_params_all f,
           gl_code_combinations         gcc,
           hr_operating_units           hou
     WHERE org_id = hou.organization_id
       AND gcc.code_combination_id = f.accts_pay_code_combination_id
       AND hou.name = p_ou_name;
    RETURN l_company_code;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_company_code;

  --
  FUNCTION get_code_combination_id(p_concatenated_segments IN VARCHAR2,
                                   p_chart_of_accounts_id  IN NUMBER) RETURN NUMBER IS
    l_code_combination_id NUMBER NULL;
    lv_err_msg            VARCHAR2(200);
  BEGIN
    --l_code_combination_id := 20004;
    l_code_combination_id := fnd_flex_ext.get_ccid(application_short_name => 'SQLGL',
                                                   key_flex_code          => 'GL#',
                                                   structure_number       => p_chart_of_accounts_id,
                                                   validation_date        => to_char(SYSDATE, fnd_flex_ext.date_format),
                                                   concatenated_segments  => p_concatenated_segments);
    lv_err_msg            := fnd_flex_ext.get_message;
    IF lv_err_msg IS NOT NULL THEN
      raise_application_error(-20001, lv_err_msg);
    END IF;
    RETURN l_code_combination_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_code_combination_id;

  FUNCTION chk_operating_unit(p_operating_unit IN VARCHAR2) RETURN NUMBER IS
    ln_op_id   NUMBER;
    lv_err_msg VARCHAR2(200);
  BEGIN
    SELECT organization_id
      INTO ln_op_id
      FROM hr_operating_units hou
     WHERE hou.name = p_operating_unit;
    RETURN ln_op_id;
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'operating unit name');
      raise_application_error(-20001, lv_err_msg);
  END chk_operating_unit;

  FUNCTION chk_invoice_type(p_invoice_type IN VARCHAR2) RETURN VARCHAR2 IS
    lv_invoice_type_code VARCHAR2(200);
    lv_error             VARCHAR2(200);
  BEGIN
    SELECT lookup_code
      INTO lv_invoice_type_code
      FROM ap_lc_invoice_types_v
     WHERE lookup_code NOT IN ('AWT', 'PAYMENT REQUEST', 'INVOICE REQUEST', 'CREDIT MEMO REQUEST')
       AND displayed_field = p_invoice_type
     ORDER BY decode(lookup_code, 'STANDARD', 1, 'MIXED', 99, 2),
              displayed_field;
    RETURN lv_invoice_type_code;
  EXCEPTION
    WHEN no_data_found THEN
      lv_error := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Invoice Type');
      raise_application_error(-20001, lv_error);
  END chk_invoice_type;

  PROCEDURE chk_supplier_name(p_supplier_name    IN VARCHAR2,
                              p_supplier_number  IN VARCHAR2,
                              x_vendor_id        OUT VARCHAR2,
                              x_vendor_site_code OUT VARCHAR2) IS
    lv_err_msg VARCHAR2(200);
    --l_vendor_number VARCHAR2(2000);
    l_count NUMBER;
  BEGIN
    SELECT /*segment1 supplier_number
                                                      ,*/
     vendor_id
      INTO /*l_vendor_number
           ,*/ x_vendor_id
      FROM ap_suppliers    pv,
           hz_parties      hzp, /*bug 8225059*/
           per_employees_x emp
     WHERE pv.party_id = hzp.party_id
       AND pv.enabled_flag = 'Y'
       AND /*bug 8225059*/
           pv.employee_id = emp.employee_id(+)
       AND trunc(SYSDATE) < nvl(trunc(pv.end_date_active), trunc(SYSDATE + 1))
       AND nvl(trunc(pv.start_date_active), trunc(SYSDATE)) <= trunc(SYSDATE)
          --AND pv.vendor_name = p_supplier_name
       AND pv.segment1 = p_supplier_number
       AND xxap_vendors_ap_pkg.get_num_active_pay_sites(vendor_id, /*82*/ g_org_id) > 0;
    /*    IF (l_vendor_number IS NOT NULL)
       OR (p_supplier_number IS NOT NULL) THEN
      IF l_vendor_number != p_supplier_number THEN
        lv_err_msg := get_message('XXAP'
                                 ,'XXAP_001E_001'
                                 ,'ITEM_NAME'
                                 ,'Supplier Number');
        raise_application_error(-20001
                               ,lv_err_msg);
      END IF;
    END IF;*/
    SELECT COUNT(1)
      INTO l_count
      FROM po_vendors
     WHERE vendor_type_lookup_code = 'EMPLOYEE'
       AND vendor_id = x_vendor_id;
    IF l_count > 0 THEN
      x_vendor_site_code := 'OFFICE';
    ELSE
      x_vendor_site_code := 'HEA';
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Supplier Name or Supplier Number');
      raise_application_error(-20001, lv_err_msg);
  END chk_supplier_name;
  --
  FUNCTION chk_supplier_site(p_vendor_site_code IN VARCHAR2,
                             p_vnedor_id        IN NUMBER,
                             p_ou_id            IN NUMBER) RETURN NUMBER IS
    ln_vendor_site_id NUMBER;
    lv_err_msg        VARCHAR2(200);
  BEGIN
    SELECT pov.vendor_site_id
      INTO ln_vendor_site_id
      FROM po_vendor_sites_all pov
    --,financials_system_params_all fsp
    --,hz_party_sites               h
    --,po_vendors                   pv
     WHERE pov.vendor_id = p_vnedor_id
          --AND pov.vendor_id = pv.vendor_id
          --AND h.party_site_id(+) = pov.party_site_id
          /*AND decode(pv.vendor_type_lookup_code
          ,'EMPLOYEE'
          ,'A'
          ,nvl(h.status
              ,'I')) = ('A')*/
       AND pov.pay_site_flag = 'Y'
       AND pov.org_id = nvl(p_ou_id, pov.org_id)
          --AND pov.org_id = fsp.org_id
       AND trunc(nvl(pov.inactive_date, SYSDATE + 1)) > trunc(SYSDATE)
       AND pov.vendor_site_code = p_vendor_site_code;
    --ORDER BY upper(vendor_site_code);
    RETURN ln_vendor_site_id;
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Supplier site');
      raise_application_error(-20001, lv_err_msg);
  END chk_supplier_site;

  PROCEDURE chk_gl_period_date(p_date IN DATE, p_date_name IN VARCHAR2) IS
    ln_count   NUMBER;
    lv_err_msg VARCHAR2(200);
  BEGIN
    if p_date_name = 'GL date' then
      SELECT COUNT(1)
        INTO ln_count
        FROM gl_period_statuses
       WHERE application_id = 101      --fnd_global.resp_appl_id modify by jinjin.lv 2016/03/03
            /*AND ((closing_status = 'N') AND
               (p_date BETWEEN start_date AND end_date))
            OR (p_date <= start_date)*/
         AND set_of_books_id = fnd_profile.value('GL_SET_OF_BKS_ID') --BY XINYU.DAI
         AND closing_status = 'O'
         AND p_date BETWEEN start_date AND end_date;
      IF ln_count <= 0 THEN
        lv_err_msg := 'Invalid ' || p_date_name || '.';
        raise_application_error(-20001, lv_err_msg);
      END IF;
    end if;
  END chk_gl_period_date;
  
  
  PROCEDURE chk_invoice_date(p_invoice_date IN VARCHAR2) IS
  BEGIN
    chk_gl_period_date(p_invoice_date, 'Invoice date');
  END chk_invoice_date;

  PROCEDURE chk_invoice_num(p_invoice_number IN VARCHAR2,
                            p_vendor_id      IN NUMBER,
                            p_org_id         IN NUMBER) IS
    ln_count_sys NUMBER;
    --ln_count_tmp NUMBER;
    lv_err_msg VARCHAR2(200);
    --lv_invoice_number VARCHAR2(200);
  BEGIN
    SELECT COUNT(1)
      INTO ln_count_sys
      FROM ap_invoices_all aia
     WHERE aia.invoice_num = TRIM(p_invoice_number)
       AND aia.vendor_id = p_vendor_id
       AND aia.org_id = p_org_id;
    IF ln_count_sys <> 0 THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_002');
      raise_application_error(-20001, lv_err_msg);
    END IF;
  END chk_invoice_num;

  /*PROCEDURE chk_invoice_currency(p_invoice_currency IN VARCHAR2) IS
    ln_count   NUMBER;
    lv_err_msg VARCHAR2(200);
  BEGIN
    SELECT COUNT(*)
      INTO ln_count
      FROM fnd_currencies_vl fcv
     WHERE fcv.enabled_flag = 'Y'
       AND fcv.currency_flag = 'Y'
       AND trunc(nvl(fcv.start_date_active
                    ,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(fcv.end_date_active
                    ,SYSDATE)) >= trunc(SYSDATE)
       AND fcv.currency_code = p_invoice_currency;
    IF ln_count <> 1 THEN
      lv_err_msg := get_message('XXAP'
                               ,'XXAP_001E_001'
                               ,'ITEM_NAME'
                               ,'Currency');
      raise_application_error(-20001
                             ,lv_err_msg);
    END IF;
  END chk_invoice_currency;*/

  PROCEDURE chk_gl_date(p_gl_date IN DATE) IS
  BEGIN
    chk_gl_period_date(p_gl_date, 'GL date');
  END chk_gl_date;

  /*PROCEDURE chk_rate_type(p_rate_type IN VARCHAR2) IS
    ln_count   NUMBER;
    lv_err_msg VARCHAR2(200);
  BEGIN
    IF p_rate_type IS NOT NULL THEN
      SELECT COUNT(1)
        INTO ln_count
        FROM gl_daily_conversion_types
       WHERE conversion_type != 'Period Average (Upgrade)'
         AND conversion_type != 'EMU FIXED'
         AND user_conversion_type = p_rate_type
       ORDER BY upper(user_conversion_type);
      IF ln_count = 0 THEN
        lv_err_msg := get_message('XXAP'
                                 ,'XXAP_001E_001'
                                 ,'ITEM_NAME'
                                 ,'Rate type');
        raise_application_error(-20001
                               ,lv_err_msg);
      END IF;
    ELSE
      lv_err_msg := get_message('XXAP'
                               ,'XXAP_001E_003'
                               ,'RATE_ITEM'
                               ,'Rate Type');
      raise_application_error(-20001
                             ,lv_err_msg);
    END IF;
  END chk_rate_type;*/

  /*PROCEDURE chk_exchange_date(p_exchange_date IN DATE) IS
    lv_err_msg VARCHAR2(200);
  BEGIN
    IF p_exchange_date IS NOT NULL THEN
      chk_gl_period_date(p_exchange_date
                        ,'Exchange date');
    ELSE
      lv_err_msg := get_message('XXAP'
                               ,'XXAP_001E_003'
                               ,'RATE_ITEM'
                               ,'Exchange date');
      raise_application_error(-20001
                             ,lv_err_msg);
    END IF;
  END chk_exchange_date;*/

  /*  PROCEDURE chk_exchange_rate(p_exchange_rate IN VARCHAR2) IS
    lv_err_msg VARCHAR2(200);
  BEGIN
    IF p_exchange_rate IS NOT NULL THEN
      IF p_exchange_rate <= 0 THEN
        lv_err_msg := get_message('XXAP'
                                 ,'XXAP_001E_001'
                                 ,'ITEM_NAME'
                                 ,'rate(must lagger than 0)');
        raise_application_error(-20001
                               ,lv_err_msg);
      ELSE
        lv_err_msg := get_message('XXAP'
                                 ,'XXAP_001E_003'
                                 ,'RATE_ITEM'
                                 ,'Exchange rate');
        raise_application_error(-20001
                               ,lv_err_msg);
      END IF;
    END IF;
  END chk_exchange_rate;*/

  /*PROCEDURE chk_terms_date(p_terms_date IN VARCHAR2) IS
  BEGIN
    IF p_terms_date IS NOT NULL THEN
      chk_gl_period_date(p_terms_date
                        ,'terms date');
    END IF;
  END chk_terms_date;*/

  FUNCTION chk_payment_method(p_payment_method IN VARCHAR2) RETURN VARCHAR2 IS
    lv_flex_value         VARCHAR2(200);
    lv_flex_value_meaning VARCHAR2(200);
    lv_err_msg            VARCHAR2(200);
  BEGIN
    SELECT ffvv.flex_value,
           ffvv.flex_value_meaning
      INTO lv_flex_value,
           lv_flex_value_meaning
      FROM fnd_flex_value_sets ffvs,
           fnd_flex_values_vl  ffvv
     WHERE ffvs.flex_value_set_name = 'XXHEA_PAYMENT METHOD'
       AND ffvv.flex_value_set_id = ffvs.flex_value_set_id
       AND ffvv.flex_value_meaning = p_payment_method;
    RETURN lv_flex_value;
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Payment method');
      raise_application_error(-20001, lv_err_msg);
  END chk_payment_method;

  --Default Distribution Account
  FUNCTION chk_dflt_dstrbtn_on_accnt(p_dflt_dstrbtn_on_accnt IN VARCHAR2,
                                     p_set_of_books_id       IN NUMBER) RETURN NUMBER IS
    ln_chart_of_acc_id NUMBER;
    ln_ccid            NUMBER;
    lv_err_msg         VARCHAR2(200);
  BEGIN
    ln_chart_of_acc_id := get_chart_of_accounts_id(p_set_of_books_id);
    ln_ccid            := get_code_combination_id(p_dflt_dstrbtn_on_accnt, ln_chart_of_acc_id);
    RETURN ln_ccid;
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Default Distribution Account');
      raise_application_error(-20001, lv_err_msg);
    
  END chk_dflt_dstrbtn_on_accnt;
  --Project
  FUNCTION chk_project(p_project               IN VARCHAR2,
                       p_ln_expenditure_org_id OUT NUMBER,
                       p_prj_flg               OUT BOOLEAN) RETURN NUMBER IS
    ln_project_id NUMBER;
    --lv_project_number VARCHAR2(200);
    lv_err_msg VARCHAR2(200);
  BEGIN
    IF p_project IS NOT NULL THEN
      SELECT ppev.project_id,
             ppev.expenditure_ou
        INTO ln_project_id,
             p_ln_expenditure_org_id
        FROM xxpa_projects_expend_v ppev
       WHERE ppev.project_number = p_project;
      p_prj_flg := TRUE;
      RETURN ln_project_id;
    ELSE
      p_prj_flg := FALSE;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Project Number');
      raise_application_error(-20001, SQLERRM || lv_err_msg);
  END chk_project;
  --Task
  FUNCTION chk_task(p_task       IN VARCHAR2,
                    p_project_id IN NUMBER) RETURN NUMBER IS
    ln_task_id NUMBER;
    lv_err_msg VARCHAR2(200);
  BEGIN
    IF p_task IS NOT NULL THEN
      SELECT task_id
        INTO ln_task_id
        FROM pa_tasks /*_expend_v*/
       WHERE project_id = p_project_id
         AND task_number = p_task;
    ELSE
      lv_err_msg := get_message('XXAP', 'XXAP_001E_004', 'PRJ_ITEM', 'Task Number');
      raise_application_error(-20001, lv_err_msg);
    END IF;
    RETURN ln_task_id;
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Task Number');
      raise_application_error(-20001, lv_err_msg);
  END chk_task;
  --Expenditure Item Date
  PROCEDURE chk_expndte_itm_dt(p_expndte_itm_dt IN DATE) IS
    lv_err_msg VARCHAR2(200);
  BEGIN
    IF p_expndte_itm_dt IS NOT NULL THEN
      chk_gl_period_date(p_expndte_itm_dt, 'Expenditure Item Date');
    ELSE
      lv_err_msg := get_message('XXAP', 'XXAP_001E_004', 'PRJ_ITEM', 'Expenditure Item Date');
      raise_application_error(-20001, lv_err_msg);
    END IF;
  END chk_expndte_itm_dt;
  --Expenditure Type
  PROCEDURE chk_expndte_type(p_expndte_type          IN VARCHAR2,
                             p_invoice_type_code     IN VARCHAR2,
                             p_expenditure_item_date IN DATE) IS
    ln_count   NUMBER;
    lv_err_msg VARCHAR2(200);
  BEGIN
    IF p_expndte_type IS NOT NULL THEN
      SELECT COUNT(1)
        INTO ln_count
        FROM pa_expenditure_types_expend_v
       WHERE system_linkage_function = decode(p_invoice_type_code, 'EXPENSE REPORT', 'ER', 'VI')
         AND (p_expenditure_item_date BETWEEN expnd_typ_start_date_active AND
             nvl(expnd_typ_end_date_active, p_expenditure_item_date))
         AND (SYSDATE BETWEEN sys_link_start_date_active AND nvl(sys_link_end_date_active, SYSDATE))
         AND expenditure_type = p_expndte_type;
      IF ln_count = 0 THEN
        lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Expenditure Type');
        raise_application_error(-20001, lv_err_msg);
      END IF;
    ELSE
      lv_err_msg := get_message('XXAP', 'XXAP_001E_004', 'PRJ_ITEM', 'Expenditure Type');
      raise_application_error(-20001, lv_err_msg);
    END IF;
  END chk_expndte_type;
  --Tax Rate Name
  PROCEDURE chk_tax_rate_name(p_tax_rate_name         IN VARCHAR2,
                              p_operating_unit        IN VARCHAR2, -- add by huangyan 2015-02-26
                              x_tax_rate_code         OUT VARCHAR2,
                              x_tax_status_code       OUT VARCHAR2,
                              x_tax_jurisdiction_code OUT VARCHAR2,
                              x_tax                   OUT VARCHAR2,
                              x_tax_regime_code       OUT VARCHAR2,
                              x_tax_rate              OUT VARCHAR2) IS
    lv_err_msg VARCHAR2(200);
  BEGIN
    /* SELECT DISTINCT tax_rate_code
                  ,tax_status_code
                  ,tax_jurisdiction_code
                  ,tax
                  ,tax_regime_code
                  ,percentage_rate
     INTO x_tax_rate_code
         ,x_tax_status_code
         ,x_tax_jurisdiction_code
         ,x_tax
         ,x_tax_regime_code
         ,x_tax_rate
     FROM zx_sco_rates_v
    WHERE active_flag = 'Y'
      AND (tax_class IS NULL OR tax_class = 'INPUT')
      AND effective_from <= SYSDATE
      AND (effective_to >= SYSDATE OR effective_to IS NULL)
      AND tax_rate_code = p_tax_rate_name;*/
    SELECT DISTINCT zrb.tax_rate_code, -- update by huangyan 2015-02-26
                    zrb.tax_status_code,
                    zrb.tax_jurisdiction_code,
                    zrb.tax,
                    zrb.tax_regime_code,
                    zrb.percentage_rate
      INTO x_tax_rate_code,
           x_tax_status_code,
           x_tax_jurisdiction_code,
           x_tax,
           x_tax_regime_code,
           x_tax_rate
      FROM zx_party_tax_profile ptp,
           hr_operating_units   hou,
           zx_sco_rates_v       zrb
     WHERE zrb.active_flag = 'Y'
       AND (zrb.tax_class IS NULL OR zrb.tax_class = 'INPUT')
       AND zrb.effective_from <= SYSDATE
       AND (zrb.effective_to >= SYSDATE OR zrb.effective_to IS NULL)
       AND ptp.party_type_code = 'OU'
       AND ptp.party_id = hou.organization_id
       AND ptp.party_tax_profile_id = zrb.content_owner_id
       AND zrb.tax_rate_code = p_tax_rate_name
       AND hou.name = p_operating_unit; -- end update by huangyan 2015-02-26
  EXCEPTION
    WHEN no_data_found THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Tax Rate Name');
      raise_application_error(-20001, lv_err_msg);
  END chk_tax_rate_name;

  FUNCTION chk_terms(p_terms IN VARCHAR2) RETURN NUMBER IS
    l_terms_id NUMBER;
    lv_err_msg VARCHAR2(200);
  BEGIN
    SELECT term_id
      INTO l_terms_id
      FROM ap_terms
     WHERE NAME = p_terms;
    RETURN l_terms_id;
  EXCEPTION
    WHEN OTHERS THEN
      lv_err_msg := get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'terms name');
      raise_application_error(-20001, lv_err_msg);
  END chk_terms;

  --Set env
  PROCEDURE set_policy_context(p_org_id IN NUMBER) IS
  BEGIN
    mo_global.set_policy_context(p_access_mode => 'S', p_org_id => p_org_id);
  END set_policy_context;

  PROCEDURE check_webadi_param(p_session_id       IN NUMBER,
                               p_operating_unit   IN VARCHAR2,
                               p_invoice_type     IN VARCHAR2,
                               p_supplier_number  IN VARCHAR2,
                               p_supplier_name    IN VARCHAR2,
                               p_supplier_site    IN VARCHAR2,
                               p_invoice_date     IN DATE,
                               p_invoice_number   IN VARCHAR2,
                               p_invoice_currency IN VARCHAR2,
                               --                               p_invoice_amount         IN NUMBER,
                               p_gl_date     IN DATE,
                               p_description IN VARCHAR2,
                               p_rate_type   IN VARCHAR2,
                               --p_rate_date          IN DATE,
                               p_rate           IN NUMBER,
                               p_terms          IN VARCHAR2,
                               p_payment_method IN VARCHAR2,
                               --                               p_mdfy_tx_amnt_fnc_crrnc IN VARCHAR2,
                               p_line_amount           IN NUMBER,
                               p_dflt_dstrbtn_on_accnt IN VARCHAR2,
                               p_project               IN VARCHAR2,
                               p_task                  IN VARCHAR2,
                               --                               p_expndte_itm_dt         IN DATE,
                               p_expndte_type      IN VARCHAR2,
                               p_tax_rate_name     IN VARCHAR2,
                               p_tax_amount        IN NUMBER,
                               x_tax_amount        OUT NUMBER,
                               x_tmp_header_rec    OUT xxap_invoices_interface%ROWTYPE,
                               x_tmp_lines_rec     OUT xxap_invoice_lines_interface%ROWTYPE,
                               x_tmp_tax_lines_rec OUT xxap_invoice_lines_interface%ROWTYPE,
                               x_line_only         OUT BOOLEAN) IS
    lv_not_null_error VARCHAR2(2000);
    --lv_invoice_type_code    VARCHAR2(200);
    --lv_fin_system_param_row financials_system_params_all%ROWTYPE;
    --lv_ap_system_param_row  ap_system_parameters_all%ROWTYPE;
    --ln_set_of_books_id      NUMBER;
    --lv_local_currency_code VARCHAR2(200);
    ln_invoice_line_count NUMBER;
    --ln_chart_of_accounts_id NUMBER;
    --ln_prject_id  number;
    --lv_segment_delimiter    varchar2(200);
    ln_old_invoice_id            NUMBER;
    lv_old_invc_type_lookup_code VARCHAR2(200);
    lb_tax_flag                  BOOLEAN;
    lb_prj_flg                   BOOLEAN;
    --
    lv_invoice_number        VARCHAR2(200);
    lv_tax_rate_code         VARCHAR2(200);
    lv_tax_status_code       VARCHAR2(200);
    lv_tax_jurisdiction_code VARCHAR2(200);
    lv_tax                   VARCHAR2(200);
    lv_tax_regime_code       VARCHAR2(200);
    lv_tax_rate              VARCHAR2(200);
    ln_tax_invoice_line_id   NUMBER;
    ln_set_of_books_id       NUMBER;
  
    l_exist_method_code       VARCHAR2(200);
    l_exist_invoice_date      DATE;
    l_exist_invoice_curr_code VARCHAR2(200);
    l_exist_terms_id          NUMBER;
    l_exist_gl_date           DATE;
    --add by zhe.yang v3.0 2015/3/3 15:41:41 start
    l_precision NUMBER;
    --add by zhe.yang v3.0 2015/3/3 15:43:04 end
  
  BEGIN
    x_tax_amount := 0;
    --raise_application_error(-20001,'debug:p_dflt_dstrbtn_on_accnt='||p_dflt_dstrbtn_on_accnt);
    IF p_invoice_number IS NULL THEN
      lv_invoice_number := to_char(SYSDATE, 'YYYYMMDDHH24MISS');
    ELSE
      lv_invoice_number := p_invoice_number;
    END IF;
    BEGIN
      -- CHECK IF THE HEAD IS ALREADY EXIST IN TEMP TABLE
      SELECT xii.invoice_id,
             xii.invoice_type_lookup_code,
             xii.gl_date,
             xii.attribute9 -- payment method
            ,
             xii.invoice_date,
             xii.invoice_currency_code,
             xii.terms_id,
             xii.gl_date
        INTO ln_old_invoice_id,
             lv_old_invc_type_lookup_code,
             x_tmp_header_rec.gl_date,
             l_exist_method_code,
             l_exist_invoice_date,
             l_exist_invoice_curr_code,
             l_exist_terms_id,
             l_exist_gl_date
        FROM xxap_invoices_interface xii
      --,ap_lc_invoice_types_v   alit
       WHERE xii.group_id = p_session_id
         AND xii.invoice_num = lv_invoice_number
            --AND xii.vendor_name = p_supplier_name;
         AND xii.vendor_num = p_supplier_number
         AND rownum = 1;
      /*AND xii.invoice_type_lookup_code = alit.lookup_code
      AND alit.displayed_field = p_invoice_type
      AND xii.gl_date = p_gl_date;*/
      x_line_only := TRUE;
    EXCEPTION
      WHEN no_data_found THEN
        x_line_only := FALSE;
    END;
    --NOT NULL CHECK START
    IF x_line_only = FALSE THEN
      --check operating unit
      IF p_operating_unit IS NULL THEN
        lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'Operating Unit');
        raise_application_error(-20001, lv_not_null_error);
      END IF;
      --invoice type
      IF p_invoice_type IS NULL THEN
        lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'Invoice Type');
        raise_application_error(-20001, lv_not_null_error);
      END IF;
      --p_trading_parttner
      IF /*p_supplier_name*/
       p_supplier_number IS NULL THEN
        lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'Trading parttner');
        raise_application_error(-20001, lv_not_null_error);
      END IF;
      --Invoice Date
      IF p_invoice_date IS NULL THEN
        lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'Invoice date');
        raise_application_error(-20001, lv_not_null_error);
      END IF;
      --Invoice Amount
      /*      IF p_invoice_amount IS NULL THEN
        lv_not_null_error := get_message('XXAP'
                                        ,'XXAP_001E_005'
                                        ,'ITEM'
                                        ,'Invoice Amount');
        raise_application_error(-20001
                               ,lv_not_null_error);
      END IF;*/
      --GL Date
      IF p_gl_date IS NULL THEN
        lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'GL Date');
        raise_application_error(-20001, lv_not_null_error);
      END IF;
      --Payment Method
      IF p_payment_method IS NULL THEN
        lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'Payment method');
        raise_application_error(-20001, lv_not_null_error);
      END IF;
    ELSE
      -- IF x_line_only = FALSE THEN
      -- true
      IF (nvl(l_exist_method_code, '$$') <> nvl(chk_payment_method(p_payment_method), '$$')) OR
         (nvl(l_exist_invoice_date, trunc(SYSDATE - 10000)) <> nvl(p_invoice_date, trunc(SYSDATE - 10000))) OR
         (nvl(l_exist_invoice_curr_code, '$$') <> nvl(p_invoice_currency, '$$')) OR
         (nvl(l_exist_terms_id, -999) <> nvl(chk_terms(p_terms), -999)) OR
         (nvl(l_exist_gl_date, trunc(SYSDATE - 10000)) <> nvl(p_gl_date, trunc(SYSDATE - 10000))) THEN
        --
        lv_not_null_error := 'Invalid header info,please check exist_payment_method,
                              exist_invoice_date, exist_invoice_curr_code,
                              exist_terms';
        raise_application_error(-20001, lv_not_null_error);
      
      END IF;
    
    END IF;
    --Line amount
    IF p_line_amount IS NULL THEN
      lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'Line Amount');
      raise_application_error(-20001, lv_not_null_error);
    END IF;
    --Default Distribution Account
    /*    IF p_dflt_dstrbtn_on_accnt IS NULL THEN
      lv_not_null_error := get_message('XXAP'
                                      ,'XXAP_001E_005'
                                      ,'ITEM'
                                      ,'Default Distribution Account');
      raise_application_error(-20001
                             ,lv_not_null_error);
    END IF;*/
    --Project parameter
    IF p_project IS NOT NULL THEN
      IF p_task IS NULL
        --OR p_expndte_itm_dt IS NULL
         OR p_expndte_type IS NULL THEN
        lv_not_null_error := get_message('XXAP', 'XXAP_001E_006');
        raise_application_error(-20001, lv_not_null_error);
      END IF;
    END IF;
    --Tax parameter
    IF p_tax_rate_name IS NOT NULL THEN
      lb_tax_flag := TRUE;
    END IF;
    --NOT NULL CHECK END
    --Operating unit
    x_tmp_header_rec.org_id := chk_operating_unit(p_operating_unit);
    g_org_id                := x_tmp_header_rec.org_id;
    --Set env
    ----cux_test_table_debug.insert_test_table(1,'Set env');
    set_policy_context(x_tmp_header_rec.org_id);
    BEGIN
      SELECT set_of_books_id
        INTO ln_set_of_books_id
        FROM financials_system_params_all
       WHERE org_id = x_tmp_header_rec.org_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, get_message('XXAP', 'XXAP_001E_007', 'ITEM', 'financial system parameters'));
    END;
    /*    BEGIN
      SELECT *
        INTO lv_ap_system_param_row
        FROM ap_system_parameters_all aspa
       WHERE aspa.org_id = x_tmp_header_rec.org_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,get_message('XXAP'
                                           ,'XXAP_001E_007'
                                           ,'ITEM'
                                           ,'AP parameters'));
    END;*/
    ----cux_test_table_debug.insert_test_table(2,'2');
    IF x_line_only = FALSE THEN
      --ln_set_of_books_id := lv_ap_system_param_row.set_of_books_id;
      x_tmp_header_rec.group_id := p_session_id;
      -- x_tmp_header_rec.vendor_name := p_supplier_name;
      x_tmp_header_rec.vendor_num := p_supplier_number;
      --      x_tmp_header_rec.vendor_site_code      := p_supplier_site;
      x_tmp_header_rec.invoice_date          := p_invoice_date;
      x_tmp_header_rec.invoice_num           := lv_invoice_number;
      x_tmp_header_rec.invoice_currency_code := p_invoice_currency;
      x_tmp_header_rec.gl_date               := p_gl_date;
      x_tmp_header_rec.description           := p_description;
      IF x_tmp_header_rec.invoice_currency_code <> get_loc_curr_code(ln_set_of_books_id) THEN
        IF (p_rate_type IS NULL /*OR p_rate_date IS NULL*/
           ) THEN
          lv_not_null_error := get_message('XXAP', 'XXAP_001E_005', 'ITEM', 'Rate infomation');
          raise_application_error(-20001, lv_not_null_error);
        END IF;
        x_tmp_header_rec.exchange_rate_type := p_rate_type;
        x_tmp_header_rec.exchange_date      := p_gl_date;
        x_tmp_header_rec.exchange_rate      := p_rate;
      END IF;
      --   x_tmp_header_rec.terms_date            := p_terms_date;
      x_tmp_header_rec.invoice_amount := p_line_amount;
      --      x_tmp_header_rec.attribute3            := p_payment_method;
      --      x_tmp_header_rec.attribute4 := p_mdfy_tx_amnt_fnc_crrnc;
      x_tmp_header_rec.source := 'MANUAL INVOICE ENTRY';
      --PARAM LOGIC CHECK START
      --Invoice type
      x_tmp_header_rec.invoice_type_lookup_code := chk_invoice_type(p_invoice_type);
      --Supplier Name(trading parttner)
      chk_supplier_name(x_tmp_header_rec.vendor_name,
                        x_tmp_header_rec.vendor_num,
                        x_tmp_header_rec.vendor_id,
                        x_tmp_header_rec.vendor_site_code);
      --Supplier site
      x_tmp_header_rec.vendor_site_code := p_supplier_site;
      x_tmp_header_rec.vendor_site_id   := chk_supplier_site(x_tmp_header_rec.vendor_site_code,
                                                             x_tmp_header_rec.vendor_id,
                                                             x_tmp_header_rec.org_id);
      --Invoice date
      chk_invoice_date(x_tmp_header_rec.invoice_date);
      --Invoice Number
      chk_invoice_num(x_tmp_header_rec.invoice_num, x_tmp_header_rec.vendor_id, x_tmp_header_rec.org_id);
    
      --Invoice Currency
    
      /*BEGIN
        SELECT currency_code
          INTO lv_local_currency_code
          FROM gl_sets_of_books
         WHERE set_of_books_id = lv_ap_system_param_row.set_of_books_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      IF x_tmp_header_rec.invoice_currency_code IS NULL THEN
        x_tmp_header_rec.invoice_currency_code := lv_local_currency_code;
      ELSE
        chk_invoice_currency(x_tmp_header_rec.invoice_currency_code);
      END IF;*/
      --GL Date
      chk_gl_date(x_tmp_header_rec.gl_date);
      /*IF x_tmp_header_rec.invoice_currency_code <> lv_local_currency_code THEN
        --Rate type
        chk_rate_type(x_tmp_header_rec.exchange_rate_type);
        --Exchange Date
        chk_exchange_date(x_tmp_header_rec.exchange_date);
        --Exchange rate
        chk_exchange_rate(x_tmp_header_rec.exchange_rate);
      END IF;
      --Terms Date
      chk_terms_date(x_tmp_header_rec.terms_date);*/
      --payment method--DFF9 in header
      x_tmp_header_rec.attribute9 := chk_payment_method(p_payment_method);
      --x_tmp_header_rec.payment_method_lookup_code := p_payment_method;
      SELECT xxap_invoices_interface_s.nextval
        INTO x_tmp_header_rec.invoice_id
        FROM dual;
      --terms name
      /*BEGIN
      SELECT term_id
        INTO x_tmp_header_rec.terms_id
        FROM ap_terms
       WHERE NAME = p_terms\*'IMMEDIATE'*\;
      EXCEPTION
        when others THEN
           raise_application_error(-20001
                                   ,get_message('XXAP'
                                               ,'XXAP_001E_001'
                                               ,'ITEM_NAME'
                                               ,'terms name'));
      END;*/
      x_tmp_header_rec.terms_id := chk_terms(p_terms);
    
    END IF;
    --Line
    ----cux_test_table_debug.insert_test_table(3,'Line');
    --x_tmp_lines_rec.session_id := p_session_id;
    IF x_line_only = FALSE THEN
      x_tmp_lines_rec.invoice_id := x_tmp_header_rec.invoice_id;
    ELSE
      x_tmp_lines_rec.invoice_id := ln_old_invoice_id;
    END IF;
    SELECT COUNT(*)
      INTO ln_invoice_line_count
      FROM xxap_invoice_lines_interface
     WHERE invoice_id = x_tmp_lines_rec.invoice_id;
    x_tmp_lines_rec.line_number      := ln_invoice_line_count + 1;
    x_tmp_lines_rec.amount           := p_line_amount;
    x_tmp_lines_rec.expenditure_type := p_expndte_type;
    -- 4.00 20150828   Jinlong.Pan Begin
    x_tmp_lines_rec.description := p_description;
    -- 4.00 20150828   Jinlong.Pan End
    --Default Distribution Account
    ----cux_test_table_debug.insert_test_table(0,'p_dflt_dstrbtn_on_accnt:'||p_dflt_dstrbtn_on_accnt||
    --':ln_set_of_books_id:'||
    --ln_set_of_books_id);  
    IF p_dflt_dstrbtn_on_accnt IS NOT NULL THEN
      x_tmp_lines_rec.dist_code_combination_id := chk_dflt_dstrbtn_on_accnt(p_dflt_dstrbtn_on_accnt, ln_set_of_books_id);
    END IF;
    --cux_test_table_debug.insert_test_table(0.1,'dist_code_combination_id'||x_tmp_lines_rec.dist_code_combination_id);
    --Project
    /*    x_tmp_lines_rec.project_id := chk_project(p_project
    ,x_tmp_lines_rec.expenditure_organization_id
    ,lb_prj_flg);*/
    BEGIN
      IF p_project IS NOT NULL THEN
        SELECT ppev.project_id,
               ppev.expenditure_ou
          INTO x_tmp_lines_rec.project_id,
               x_tmp_lines_rec.expenditure_organization_id
          FROM xxpa_projects_expend_v ppev
         WHERE ppev.project_number = p_project
           AND ppev.project_ou = g_org_id;
        lb_prj_flg := TRUE;
      ELSE
        lb_prj_flg := FALSE;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, get_message('XXAP', 'XXAP_001E_001', 'ITEM_NAME', 'Project Number'));
    END;
  
    --Task
    IF lb_prj_flg THEN
      --cux_test_table_debug.insert_test_table(4,'p_task:'||p_task||':'||
      --'x_tmp_lines_rec.project_id:'||
      --x_tmp_lines_rec.project_id);
    
      x_tmp_lines_rec.task_id               := chk_task(p_task, x_tmp_lines_rec.project_id);
      x_tmp_lines_rec.expenditure_item_date := x_tmp_header_rec.gl_date;
      --Expenditure Item Date
      --cux_test_table_debug.insert_test_table(5,'x_tmp_lines_rec.expenditure_item_date:'||
      --x_tmp_lines_rec.expenditure_item_date);
      chk_expndte_itm_dt(x_tmp_lines_rec.expenditure_item_date);
      --Expenditure type
      --cux_test_table_debug.insert_test_table(6,'Expenditure type:'||
      --x_tmp_lines_rec.expenditure_type||
      -- 'invoice_type_lookup_code:'||
      -- x_tmp_header_rec.invoice_type_lookup_code||
      --'x_tmp_lines_rec.expenditure_item_date:'||
      --x_tmp_lines_rec.expenditure_item_date
      --);
      IF x_line_only = FALSE THEN
        chk_expndte_type(x_tmp_lines_rec.expenditure_type,
                         x_tmp_header_rec.invoice_type_lookup_code,
                         x_tmp_lines_rec.expenditure_item_date);
      ELSE
        chk_expndte_type(x_tmp_lines_rec.expenditure_type,
                         lv_old_invc_type_lookup_code,
                         x_tmp_lines_rec.expenditure_item_date);
      
      END IF;
    END IF;
  
    --cux_test_table_debug.insert_test_table(7,'7'
    --);
    --Tax Rate Name
    IF lb_tax_flag THEN
      chk_tax_rate_name(p_tax_rate_name         => p_tax_rate_name,
                        p_operating_unit        => p_operating_unit -- add by huangyan 2015-02-26
                       ,
                        x_tax_rate_code         => lv_tax_rate_code,
                        x_tax_status_code       => lv_tax_status_code,
                        x_tax_jurisdiction_code => lv_tax_jurisdiction_code,
                        x_tax                   => lv_tax,
                        x_tax_regime_code       => lv_tax_regime_code,
                        x_tax_rate              => lv_tax_rate);
    
      x_tax_amount := nvl(p_tax_amount, (lv_tax_rate * p_line_amount / 100));
      --add by zhe.yang v3.0 2015/3/3 15:44:03 start
      SELECT t.precision
        INTO l_precision
        FROM fnd_currencies t
       WHERE t.currency_code = p_invoice_currency;
      x_tax_amount := round(x_tax_amount, l_precision);
      --add by zhe.yang v3.0 2015/3/3 15:55:09 end       
    END IF;
    --cux_test_table_debug.insert_test_table(8,'8'
    --);
    --
    SELECT xxap_invoice_lines_interface_s.nextval
      INTO x_tmp_lines_rec.invoice_line_id
      FROM dual;
    --PARAM LOGIC CHECK END
    --cux_test_table_debug.insert_test_table(9,'9'
    --);
    IF x_line_only = FALSE THEN
      x_tmp_header_rec.creation_date     := SYSDATE;
      x_tmp_header_rec.last_update_date  := SYSDATE;
      x_tmp_header_rec.created_by        := fnd_global.user_id;
      x_tmp_header_rec.last_updated_by   := fnd_global.user_id;
      x_tmp_header_rec.last_update_login := fnd_global.login_id;
    END IF;
    --
    x_tmp_lines_rec.creation_date         := SYSDATE;
    x_tmp_lines_rec.last_update_date      := SYSDATE;
    x_tmp_lines_rec.created_by            := fnd_global.user_id;
    x_tmp_lines_rec.last_updated_by       := fnd_global.user_id;
    x_tmp_lines_rec.last_update_login     := fnd_global.login_id;
    x_tmp_lines_rec.line_type_lookup_code := 'ITEM';
    --
    --cux_test_table_debug.insert_test_table(10,'10'
    --);
    IF lb_tax_flag THEN
      ln_tax_invoice_line_id := -1;
      BEGIN
        SELECT invoice_line_id
          INTO ln_tax_invoice_line_id
          FROM xxap_invoice_lines_interface
         WHERE invoice_id = x_tmp_lines_rec.invoice_id
           AND tax_rate_code = lv_tax_rate_code;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      --cux_test_table_debug.insert_test_table(11,'ln_tax_invoice_line_id:'||ln_tax_invoice_line_id
      --);
      IF ln_tax_invoice_line_id <> -1 THEN
        -- SUM UP THE SAME TAX CODE'S AMOUNT INTO ONE TAX LINE
        UPDATE xxap_invoice_lines_interface
           SET amount = amount + nvl(x_tax_amount, 0) /*p_tax_amount*/
         WHERE invoice_line_id = ln_tax_invoice_line_id;
      ELSE
        x_tmp_tax_lines_rec.invoice_id  := x_tmp_lines_rec.invoice_id;
        x_tmp_tax_lines_rec.line_number := x_tmp_lines_rec.line_number + 1;
        SELECT xxap_invoice_lines_interface_s.nextval
          INTO x_tmp_tax_lines_rec.invoice_line_id
          FROM dual;
        x_tmp_tax_lines_rec.line_type_lookup_code := 'TAX';
        --x_tmp_tax_lines_rec.tax_rate_code         := p_tax_rate_name;
        x_tmp_tax_lines_rec.creation_date         := SYSDATE;
        x_tmp_tax_lines_rec.last_update_date      := SYSDATE;
        x_tmp_tax_lines_rec.created_by            := fnd_global.user_id;
        x_tmp_tax_lines_rec.last_updated_by       := fnd_global.user_id;
        x_tmp_tax_lines_rec.last_update_login     := fnd_global.login_id;
        x_tmp_tax_lines_rec.tax_rate_code         := lv_tax_rate_code;
        x_tmp_tax_lines_rec.tax_status_code       := lv_tax_status_code;
        x_tmp_tax_lines_rec.tax_jurisdiction_code := lv_tax_jurisdiction_code;
        x_tmp_tax_lines_rec.tax                   := lv_tax;
        x_tmp_tax_lines_rec.tax_regime_code       := lv_tax_regime_code;
        x_tmp_tax_lines_rec.tax_rate              := lv_tax_rate;
        x_tmp_tax_lines_rec.amount                := nvl(x_tax_amount, 0) /*p_tax_amount*/
         ;
      END IF;
      --cux_test_table_debug.insert_test_table(12,'12'
      --);
      -- x_tmp_lines_rec.amount := x_tmp_lines_rec.amount - x_tax_amount/*p_tax_amount*/;
      x_tmp_header_rec.invoice_amount := x_tmp_lines_rec.amount + nvl(x_tax_amount, 0);
    END IF;
    --cux_test_table_debug.insert_test_table(13,'13'
    --);
  END check_webadi_param;

  PROCEDURE chk_account(p_account IN VARCHAR2) IS
    l_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO l_count
      FROM fnd_flex_value_sets ffvs,
           fnd_flex_values_vl  ffvv
     WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
       AND ffvs.flex_value_set_name = 'HEA_ACCOUNT'
       AND ffvv.enabled_flag = 'Y'
       AND ffvv.flex_value = p_account;
    IF l_count = 0 THEN
      raise_application_error(-20001, 'Invalid Account.');
    END IF;
  END chk_account;

  PROCEDURE chk_subaccount(p_subaccount IN VARCHAR2) IS
    l_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO l_count
      FROM fnd_flex_values_vl  ffvv,
           fnd_flex_value_sets ffvs
     WHERE (ffvs.flex_value_set_id = ffvv.flex_value_set_id)
       AND (ffvs.flex_value_set_name = 'HEA_SUBACCOUNT')
          --       AND (parent_flex_value_low = '08')
       AND ffvv.flex_value = p_subaccount
       AND ffvv.enabled_flag = 'Y';
    IF l_count = 0 THEN
      raise_application_error(-20001, 'Invalid SubAccount.');
    END IF;
  END chk_subaccount;

  PROCEDURE chk_cost_center(p_cost_center IN VARCHAR2) IS
    l_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO l_count
      FROM fnd_flex_value_sets ffvs,
           fnd_flex_values_vl  ffvv
     WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
       AND ffvs.flex_value_set_name = 'HEA_COST CENTER'
       AND ffvv.enabled_flag = 'Y'
       AND ffvv.flex_value = p_cost_center;
    IF l_count = 0 THEN
      raise_application_error(-20001, 'Invalid Cost Center.');
    END IF;
  END chk_cost_center;

  PROCEDURE chk_project(p_project VARCHAR2) IS
    l_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO l_count
      FROM fnd_flex_value_sets ffvs,
           fnd_flex_values_vl  ffvv
     WHERE ffvs.flex_value_set_id = ffvv.flex_value_set_id
       AND ffvs.flex_value_set_name = 'HEA_PROJECT'
       AND ffvv.enabled_flag = 'Y'
       AND ffvv.flex_value = p_project;
    IF l_count = 0 THEN
      raise_application_error(-20001, 'Invalid Project Segment.');
    END IF;
  END chk_project;

  PROCEDURE webadi_upload(p_session_id IN NUMBER,
                          --
                          --
                          p_supplier_number IN VARCHAR2,
                          p_supplier_name   IN VARCHAR2,
                          p_account         IN VARCHAR2,
                          p_subaccount      IN VARCHAR2,
                          p_cost_center     IN VARCHAR2,
                          p_payment_method  IN VARCHAR2,
                          p_tax_rate_name   IN VARCHAR2,
                          p_tax_amount      IN NUMBER,
                          p_line_amount     IN NUMBER,
                          p_description     IN VARCHAR2,
                          p_invoice_number  IN VARCHAR2,
                          --                          p_invoice_amount         IN NUMBER,
                          p_invoice_date IN DATE,
                          p_gl_date      IN DATE,
                          /*                          p_rate_type              IN VARCHAR2,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                p_exchange_date          IN DATE,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                p_exchange_rate          IN VARCHAR2,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                p_terms_date             IN DATE,                          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                p_mdfy_tx_amnt_fnc_crrnc IN VARCHAR2,                          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                p_dflt_dstrbtn_on_accnt  IN VARCHAR2,*/
                          p_project IN VARCHAR2,
                          p_task    IN VARCHAR2,
                          --                          p_expndte_itm_dt         IN DATE,
                          p_expndte_type IN VARCHAR2,
                          --
                          --p_gl_ledger_name  IN VARCHAR2,
                          p_ou_name IN VARCHAR2,
                          --p_company_code    IN VARCHAR2,
                          p_invoice_type     IN VARCHAR2,
                          p_terms            IN VARCHAR2,
                          p_supplier_site_c  IN VARCHAR2,
                          p_invoice_currency IN VARCHAR2,
                          p_rate_type        IN VARCHAR2,
                          --p_rate_date        IN date,
                          p_rate IN NUMBER) IS
    lr_ap_invoice_header_rec   xxap_invoices_interface%ROWTYPE;
    lr_ap_invoice_line_rec     xxap_invoice_lines_interface%ROWTYPE;
    lr_ap_invoice_tax_line_rec xxap_invoice_lines_interface%ROWTYPE;
    lb_line_only               BOOLEAN;
    --
    /*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
    l_operation_unit VARCHAR2(2000) := 'HEA_OU';
    --l_operation_unit VARCHAR2(2000) := 'HEA';
    /*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
    l_invoice_type          VARCHAR2(2000) := 'Standard';
    l_invoice_currency      VARCHAR2(2000) := 'SGD';
    l_dflt_dstrbtn_on_accnt VARCHAR(2000) := NULL;
    l_company_code          VARCHAR2(100);
    l_tax_amount            NUMBER;
    l_project_segment       VARCHAR2(40);
  BEGIN
    chk_account(p_account => p_account);
    chk_subaccount(p_subaccount => p_subaccount);
    chk_cost_center(p_cost_center => p_cost_center);
  
    l_project_segment := nvl(p_project, '0');
    chk_project(p_project => l_project_segment);
    IF p_cost_center IS NOT NULL AND p_account IS NOT NULL AND p_subaccount IS NOT NULL THEN
      l_company_code := get_company_code(p_ou_name);
      /*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
      l_dflt_dstrbtn_on_accnt :=  /*'FB00.'*/
       l_company_code || '.' || p_cost_center || '.' ||
                                --l_dflt_dstrbtn_on_accnt := '10.' || p_cost_center || '.' ||
                                /*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
                                 p_account || '.' || p_subaccount || '.' || l_project_segment || '.0.0';
    END IF;
  
    check_webadi_param(p_session_id       => p_session_id,
                       p_operating_unit   => p_ou_name /*l_operation_unit*/,
                       p_invoice_type     => p_invoice_type /*l_invoice_type*/,
                       p_supplier_number  => p_supplier_number,
                       p_supplier_name    => p_supplier_name,
                       p_supplier_site    => p_supplier_site_c /*l_supplier_site*/,
                       p_invoice_date     => p_invoice_date,
                       p_invoice_number   => p_invoice_number,
                       p_invoice_currency => p_invoice_currency /*l_invoice_currency*/
                       --                      ,p_invoice_amount         => p_invoice_amount
                      ,
                       p_gl_date     => p_gl_date,
                       p_description => p_description,
                       p_rate_type   => p_rate_type
                       --,p_rate_date              => p_rate_date
                      ,
                       p_rate           => p_rate,
                       p_terms          => p_terms,
                       p_payment_method => p_payment_method
                       --                      ,p_mdfy_tx_amnt_fnc_crrnc => p_mdfy_tx_amnt_fnc_crrnc
                      ,
                       p_line_amount           => p_line_amount,
                       p_dflt_dstrbtn_on_accnt => l_dflt_dstrbtn_on_accnt,
                       p_project               => p_project,
                       p_task                  => p_task
                       --                      ,p_expndte_itm_dt         => p_expndte_itm_dt
                      ,
                       p_expndte_type      => p_expndte_type,
                       p_tax_rate_name     => p_tax_rate_name,
                       p_tax_amount        => p_tax_amount,
                       x_tax_amount        => l_tax_amount,
                       x_tmp_header_rec    => lr_ap_invoice_header_rec,
                       x_tmp_lines_rec     => lr_ap_invoice_line_rec,
                       x_tmp_tax_lines_rec => lr_ap_invoice_tax_line_rec,
                       x_line_only         => lb_line_only);
    --cux_test_table_debug.insert_test_table(14,'14'
    --);
    --insert into temp header table
    IF lb_line_only = FALSE THEN
      INSERT INTO xxap_invoices_interface
      VALUES lr_ap_invoice_header_rec;
    ELSE
      UPDATE xxap_invoices_interface xii
         SET xii.invoice_amount = xii.invoice_amount +
                                 /*lr_ap_invoice_line_rec.amount*/
                                  p_line_amount + nvl(l_tax_amount, 0)
       WHERE xii.invoice_id = lr_ap_invoice_line_rec.invoice_id;
    END IF;
    --cux_test_table_debug.insert_test_table(15,'15'
    -- );
    --insert into temp lines table
    INSERT INTO xxap_invoice_lines_interface
    VALUES lr_ap_invoice_line_rec;
    IF lr_ap_invoice_tax_line_rec.invoice_line_id IS NOT NULL THEN
      --INSERT A TAX LINE
      INSERT INTO xxap_invoice_lines_interface
      VALUES lr_ap_invoice_tax_line_rec;
    END IF;
    --cux_test_table_debug.insert_test_table(16,'16'
    -- );
    --COMMIT;                                     
  END webadi_upload;
  --
  PROCEDURE process_request(errbuf     OUT VARCHAR2,
                            retcode    OUT NUMBER,
                            p_group_id IN NUMBER) IS
    ln_tmp_invoice_id NUMBER;
    ln_invoice_id     NUMBER;
    ln_invoice_amount NUMBER;
    ln_org_id         NUMBER;
    l_request_id      NUMBER;
  
    CURSOR get_invoice_head IS
      SELECT *
        FROM xxap_invoices_interface
       WHERE group_id = p_group_id;
    CURSOR get_invoice_lines IS
      SELECT *
        FROM xxap_invoice_lines_interface
       WHERE invoice_id = ln_tmp_invoice_id;
  BEGIN
    retcode := 0;
    errbuf  := NULL;
    FOR rec_head IN get_invoice_head
    LOOP
      ln_tmp_invoice_id := rec_head.invoice_id;
      ln_org_id         := rec_head.org_id;
    
      SELECT ap_invoices_interface_s.nextval
        INTO ln_invoice_id
        FROM dual;
      rec_head.invoice_id := ln_invoice_id;
      ln_invoice_amount   := 0;
    
      FOR rec_line IN get_invoice_lines
      LOOP
        SELECT ap_invoice_lines_interface_s.nextval
          INTO rec_line.invoice_line_id
          FROM dual;
        --SET INOVICE HEAD ID INTO LINE REC
        rec_line.invoice_id := rec_head.invoice_id;
        --INORDER TO IMPORT THE INVOIC INTO SYSTEM
        --INVOICE AMOUNT MUST EQUAL TO THE SUM(LINE_AMOUNT)
        ln_invoice_amount := rec_line.amount + ln_invoice_amount;
        INSERT INTO ap_invoice_lines_interface
        VALUES rec_line;
      END LOOP;
      INSERT INTO ap_invoices_interface
      VALUES rec_head;
    END LOOP;
    l_request_id := fnd_request.submit_request('SQLAP',
                                               'APXIIMPT',
                                               'Standard Submit',
                                               to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'),
                                               FALSE,
                                               to_char(ln_org_id),
                                               'MANUAL INVOICE ENTRY',
                                               to_char(p_group_id),
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               'Y',
                                               'Y',
                                               'Y',
                                               'N',
                                               NULL,
                                               NULL,
                                               NULL,
                                               chr(0));
    xxfnd_conc_utl.log_msg(p_msg => 'AP Invoice Import RequestId is:' || l_request_id);
    DELETE xxap_invoice_lines_interface
     WHERE invoice_id IN (SELECT invoice_id
                            FROM xxap_invoices_interface
                           WHERE group_id = p_group_id);
    DELETE xxap_invoices_interface
     WHERE group_id = p_group_id;
  END process_request;
  --
  PROCEDURE main(errbuf     OUT VARCHAR2,
                 retcode    OUT NUMBER,
                 p_group_id IN NUMBER) IS
  BEGIN
    --executeable name :XXAPEXPINVIMP
    xxfnd_conc_utl.log_header;
    process_request(errbuf, retcode, p_group_id);
    xxfnd_conc_utl.log_msg(p_msg => 'group_id = ' || p_group_id);
    xxfnd_conc_utl.log_footer;
  END main;

  FUNCTION get_account_desc(p_char_of_account_id IN NUMBER,
                            p_con_seg            IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*    dbms_output.put_line('p_char_of_account_id=' || p_char_of_account_id);
    dbms_output.put_line('p_con_seg=' || p_con_seg);*/
    IF fnd_flex_keyval.validate_segs(operation        => 'FIND_COMBINATION',
                                     appl_short_name  => 'SQLGL',
                                     key_flex_code    => 'GL#',
                                     structure_number => p_char_of_account_id,
                                     concat_segments  => p_con_seg,
                                     values_or_ids    => 'V') THEN
      RETURN fnd_flex_keyval.concatenated_descriptions;
    ELSE
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
END xxap_expinvoice_upload_pkg;
/
