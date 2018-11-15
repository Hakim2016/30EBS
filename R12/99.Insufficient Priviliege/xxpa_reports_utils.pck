CREATE OR REPLACE PACKAGE xxpa_reports_utils AS

  -- Sections
  g_domestic_sec NUMBER := 1;
  g_overseas_sec NUMBER := 2;
  g_parts_sec    NUMBER := 3;
  g_others_sec   NUMBER := 4;
  g_add_cost_sec NUMBER := 5;

  -- Types
  g_domestic VARCHAR2(30) := 'DOMESTIC';
  g_overseas VARCHAR2(30) := 'OVERSEAS';
  g_parts    VARCHAR2(30) := 'PARTS';

  PROCEDURE get_period_date(p_period_name IN VARCHAR2,
                            x_start_date  OUT DATE,
                            x_end_date    OUT DATE);

  PROCEDURE get_period_date2(p_period_name IN VARCHAR2,
                             x_start_date  OUT DATE,
                             x_end_date    OUT DATE);

  PROCEDURE generate_rev_cogs_dtls(p_start_date IN DATE,
                                   p_end_date   IN DATE,
                                   p_type       IN VARCHAR2,
                                   --p_je_category_name  IN   VARCHAR2,
                                   p_project_id    IN NUMBER,
                                   p_top_task_id   IN NUMBER,
                                   x_return_status OUT VARCHAR2,
                                   x_error_message OUT VARCHAR2);

  PROCEDURE generate_rev_cogs_dtls2(p_start_date    IN DATE,
                                    p_end_date      IN DATE,
                                    p_type          IN VARCHAR2,
                                    p_project_id    IN NUMBER,
                                    p_top_task_id   IN NUMBER,
                                    x_return_status OUT VARCHAR2,
                                    x_error_message OUT VARCHAR2);

  PROCEDURE get_parameter_value(p_start_project_id  IN NUMBER,
                                p_start_task_id     IN NUMBER,
                                p_end_project_id    IN NUMBER,
                                p_end_task_id       IN NUMBER,
                                p_period            IN VARCHAR2,
                                x_start_project_num OUT VARCHAR2,
                                x_end_project_num   OUT VARCHAR2,
                                x_start_mfg_num     OUT VARCHAR2,
                                x_end_mfg_num       OUT VARCHAR2,
                                x_start_date        OUT DATE,
                                x_end_date          OUT DATE);

  FUNCTION get_title(p_prefix VARCHAR2,
                     p_period VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_city(p_top_task_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_country(p_top_task_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_model(p_top_task_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_subtitle(p_section NUMBER) RETURN VARCHAR2;

  FUNCTION get_section(p_top_task_id NUMBER,
                       p_period      VARCHAR2) RETURN NUMBER;

  FUNCTION get_item_category(p_org_id            NUMBER,
                             p_inventory_item_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_material_category(p_expenditure_type VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_title_seqnum(p_report_exp_type VARCHAR2) RETURN NUMBER;

  FUNCTION get_title_seqnum2(p_expenditure_category VARCHAR2) RETURN NUMBER;

  FUNCTION get_func_cost(p_project_id       NUMBER,
                         p_top_task_id      NUMBER,
                         p_expenditure_type VARCHAR2) RETURN NUMBER;

  FUNCTION get_func_cost2(p_project_id       NUMBER,
                          p_top_task_id      NUMBER,
                          p_expenditure_type VARCHAR2,
                          p_activity_type    VARCHAR2) RETURN NUMBER;

  FUNCTION get_expenditure_category(p_report_title VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_title_style RETURN VARCHAR2;

  FUNCTION get_table_style RETURN VARCHAR2;

  FUNCTION get_cancelled_flag(p_top_task_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_sales_amount(p_top_task_id NUMBER,
                            p_end_date    DATE) RETURN NUMBER;

  FUNCTION get_report_exp_type(p_org_id            NUMBER,
                               p_inventory_item_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_exp_type(p_org_id            NUMBER,
                        p_inventory_item_id NUMBER) RETURN VARCHAR2;

  /* ==========================================================================
    *   Procedure Name: 
    *             fun_get_report_exp_type
    *
    *   DESCRIPTION : 
    *             get expenditure's expense type
    *
    *   HISTORY     :
    *     v4.0      2014-10-30       hand      Creation
  * ==========================================================================*/
  FUNCTION fun_get_report_exp_type(p_expenditure_item_id IN NUMBER) RETURN VARCHAR2;

  /* ==========================================================================
    *   Procedure Name: 
    *             fun_get_exp_type
    *
    *   DESCRIPTION : 
    *             get expenditure's expense type
    *
    *   HISTORY     :
    *     v4.0      2014-10-30       hand      Creation
  * ==========================================================================*/
  FUNCTION fun_get_exp_type(p_expenditure_item_id IN NUMBER) RETURN VARCHAR2;

END;
/
CREATE OR REPLACE PACKAGE BODY xxpa_reports_utils AS
  -- version :
  -- v1.0 create
  -- v2.0 update by jiaming.zhou 2014-08-27
  -- v3.0 update by hand  2014-09-10 back to v1.0
  -- v4.0 update by hand  2014-10-30 add function fun_get_exp_type
  -- v5.0 update by hand  2014-11-12 modify function 
  -- v6.0  2015-04-24          jinlong.pan   Update  HFG Project Account Switch , add new mapping account

  TYPE task_tbl IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  g_task_tbl task_tbl;

  g_ledger_id         NUMBER := fnd_profile.value('GL_SET_OF_BKS_ID');
  g_last_updated_by   NUMBER := fnd_global.user_id;
  g_created_by        NUMBER := fnd_global.user_id;
  g_last_update_login NUMBER := fnd_global.login_id;

  g_request_id   NUMBER := fnd_global.conc_request_id;
  g_prog_appl_id NUMBER := fnd_global.prog_appl_id;
  g_program_id   NUMBER := fnd_global.conc_program_id;
  g_pa_appl_id   NUMBER := xxfnd_const.appl_id_pa;

  g_null_category VARCHAR2(30) := 'Null';

  PROCEDURE get_period_date(p_period_name IN VARCHAR2,
                            x_start_date  OUT DATE,
                            x_end_date    OUT DATE) IS
    CURSOR date_c(p_period_name VARCHAR2) IS
      SELECT gps.start_date,
             gps.end_date
        FROM gl_period_statuses gps
       WHERE gps.application_id = 101
         AND gps.set_of_books_id = g_ledger_id
            --AND gps.closing_status         =  'O'
         AND gps.adjustment_period_flag = 'N'
         AND gps.period_name = p_period_name;
  
  BEGIN
  
    OPEN date_c(p_period_name);
    FETCH date_c
      INTO x_start_date,
           x_end_date;
    IF date_c%NOTFOUND THEN
      x_start_date := NULL;
      x_end_date   := NULL;
    END IF;
    CLOSE date_c;
  
  END;

  PROCEDURE get_period_date2(p_period_name IN VARCHAR2,
                             x_start_date  OUT DATE,
                             x_end_date    OUT DATE) IS
  BEGIN
    get_period_date(p_period_name, x_start_date, x_end_date);
    x_end_date := trunc(x_end_date) + 0.99999;
  END;

  PROCEDURE generate_rev_cogs_dtls(p_start_date    IN DATE,
                                   p_end_date      IN DATE,
                                   p_type          IN VARCHAR2,
                                   p_project_id    IN NUMBER,
                                   p_top_task_id   IN NUMBER,
                                   x_return_status OUT VARCHAR2,
                                   x_error_message OUT VARCHAR2) IS
  BEGIN
  
    x_return_status := fnd_api.g_ret_sts_success;
  
    DELETE FROM xxpa_proj_rev_cogs_tmp;
  
    IF p_type = 'EQ' THEN
    
      INSERT INTO xxpa_proj_rev_cogs_tmp
        (project_id,
         top_task_id,
         ae_header_id,
         entered_amount,
         accounted_amount,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login /*,
                                                                                                                                                                                                                                                                                                                                            program_application_id,
                                                                                                                                                                                                                                                                                                                                            program_id,
                                                                                                                                                                                                                                                                                                                                            program_update_date,
                                                                                                                                                                                                                                                                                                                                            request_id*/)
        SELECT pa.project_id,
               top.task_id,
               xah.ae_header_id,
               SUM(nvl(xal.entered_dr, 0) - nvl(xal.entered_cr, 0)),
               SUM(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)),
               SYSDATE,
               g_created_by,
               SYSDATE,
               g_last_updated_by,
               g_last_update_login /*,
                                                                                                                                                                                                                                                                                                             g_prog_appl_id,
                                                                                                                                                                                                                                                                                                             g_program_id,
                                                                                                                                                                                                                                                                                                             SYSDATE,
                                                                                                                                                                                                                                                                                                             g_request_id*/
          FROM xla_ae_headers       xah,
               xla_ae_lines         xal,
               gl_code_combinations gcc,
               pa_tasks             top,
               pa_projects          pa
        
         WHERE xah.application_id = g_pa_appl_id
           AND xah.je_category_name IN ('1', '2')
           AND xah.ae_header_id = xal.ae_header_id
           AND top.task_id = top.top_task_id
           AND top.project_id = pa.project_id
           AND xal.description = pa.segment1 || '.' || top.task_number || '.EQ'
           AND xal.code_combination_id = gcc.code_combination_id
              -- v6.0  2015-04-24          jinlong.pan   Update Begin
              -- AND gcc.segment3 != '6111010000'
           AND gcc.segment3 NOT IN ('6111010000', '6111009899')
              -- v6.0  2015-04-24          jinlong.pan   Update End
           AND (xah.je_category_name = '2' AND xal.accounting_class_code = 'REVENUE' OR
               xah.je_category_name = '1' AND xal.accounting_class_code = 'COST_OF_GOODS_SOLD')
              --AND xal.ae_line_num        =   1
           AND xah.accounting_date >= p_start_date
           AND xah.accounting_date <= p_end_date
              --AND xah.je_category_name   =   NVL(p_je_category_name, xah.je_category_name)
           AND pa.project_id = nvl(p_project_id, pa.project_id)
           AND top.task_id = nvl(p_top_task_id, top.task_id)
         GROUP BY pa.project_id,
                  top.task_id,
                  xah.ae_header_id;
    
    ELSIF p_type = 'ER' THEN
    
      INSERT INTO xxpa_proj_rev_cogs_tmp
        (project_id,
         top_task_id,
         ae_header_id,
         entered_amount,
         accounted_amount,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login /*,
                                                                                                                                                                                                                                                                                                                                            program_application_id,
                                                                                                                                                                                                                                                                                                                                            program_id,
                                                                                                                                                                                                                                                                                                                                            program_update_date,
                                                                                                                                                                                                                                                                                                                                            request_id*/)
        SELECT pa.project_id,
               top.task_id,
               xah.ae_header_id,
               SUM(nvl(xal.entered_dr, 0) - nvl(xal.entered_cr, 0)),
               SUM(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)),
               SYSDATE,
               g_created_by,
               SYSDATE,
               g_last_updated_by,
               g_last_update_login /*,
                                                                                                                                                                                                                                                                                                             g_prog_appl_id,
                                                                                                                                                                                                                                                                                                             g_program_id,
                                                                                                                                                                                                                                                                                                             SYSDATE,
                                                                                                                                                                                                                                                                                                             g_request_id*/
          FROM xla_ae_headers xah,
               xla_ae_lines   xal,
               pa_tasks       top,
               pa_projects    pa
        
         WHERE xah.application_id = g_pa_appl_id
           AND xah.je_category_name IN ('4')
           AND xah.ae_header_id = xal.ae_header_id
           AND top.task_id = top.top_task_id
           AND top.project_id = pa.project_id
           AND xal.description = pa.segment1 || '.' || top.task_number || '.ER'
           AND xal.accounting_class_code = 'REVENUE'
              --AND xal.ae_line_num        =   1
           AND xah.accounting_date >= p_start_date
           AND xah.accounting_date <= p_end_date
              --AND xah.je_category_name   =   NVL(p_je_category_name, xah.je_category_name)
           AND pa.project_id = nvl(p_project_id, pa.project_id)
           AND top.task_id = nvl(p_top_task_id, top.task_id)
         GROUP BY pa.project_id,
                  top.task_id,
                  xah.ae_header_id;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := SQLCODE || '-' || SQLERRM;
  END;

  PROCEDURE generate_rev_cogs_dtls2(p_start_date    IN DATE,
                                    p_end_date      IN DATE,
                                    p_type          IN VARCHAR2,
                                    p_project_id    IN NUMBER,
                                    p_top_task_id   IN NUMBER,
                                    x_return_status OUT VARCHAR2,
                                    x_error_message OUT VARCHAR2) IS
  BEGIN
  
    x_return_status := fnd_api.g_ret_sts_success;
  
    DELETE FROM xxpa_proj_rev_cogs_tmp;
  
    IF p_type IN ('EQ', 'ALL') THEN
    
      INSERT INTO xxpa_proj_rev_cogs_tmp
        (project_id,
         top_task_id,
         ae_header_id,
         entered_amount,
         accounted_amount,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login /*,
                                                                                                                                                                                                                                                                                                                                            program_application_id,
                                                                                                                                                                                                                                                                                                                                            program_id,
                                                                                                                                                                                                                                                                                                                                            program_update_date,
                                                                                                                                                                                                                                                                                                                                            request_id*/)
        SELECT pa.project_id,
               top.task_id,
               xah.ae_header_id,
               SUM(nvl(xal.entered_dr, 0) - nvl(xal.entered_cr, 0)),
               SUM(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)),
               SYSDATE,
               g_created_by,
               SYSDATE,
               g_last_updated_by,
               g_last_update_login /*,
                                                                                                                                                                                                                                                                                                             g_prog_appl_id,
                                                                                                                                                                                                                                                                                                             g_program_id,
                                                                                                                                                                                                                                                                                                             SYSDATE,
                                                                                                                                                                                                                                                                                                             g_request_id*/
          FROM xla_ae_headers       xah,
               xla_ae_lines         xal,
               gl_code_combinations gcc,
               pa_tasks             top,
               pa_projects          pa
        
         WHERE xah.application_id = g_pa_appl_id
           AND xah.je_category_name IN ('1', '2')
           AND xah.ae_header_id = xal.ae_header_id
           AND top.task_id = top.top_task_id
           AND top.project_id = pa.project_id
           AND xal.description = pa.segment1 || '.' || top.task_number || '.EQ'
           AND xal.code_combination_id = gcc.code_combination_id
              -- v6.0  2015-04-24          jinlong.pan   Update End
              -- AND gcc.segment3 != '6111010000'
           AND gcc.segment3 NOT IN ('6111010000', '6111009899')
              -- v6.0  2015-04-24          jinlong.pan   Update End
           AND (xah.je_category_name = '2' AND xal.accounting_class_code = 'REVENUE' OR
               xah.je_category_name = '1' AND xal.accounting_class_code = 'COST_OF_GOODS_SOLD')
              --AND xal.ae_line_num        =   1
           AND xah.accounting_date >= p_start_date
           AND xah.accounting_date <= p_end_date
              --AND xah.je_category_name   =   NVL(p_je_category_name, xah.je_category_name)
           AND pa.project_id = nvl(p_project_id, pa.project_id)
           AND top.task_id = nvl(p_top_task_id, top.task_id)
         GROUP BY pa.project_id,
                  top.task_id,
                  xah.ae_header_id;
    
    END IF;
  
    IF p_type IN ('ER', 'ALL') THEN
    
      INSERT INTO xxpa_proj_rev_cogs_tmp
        (project_id,
         top_task_id,
         ae_header_id,
         entered_amount,
         accounted_amount,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login /*,
                                                                                                                                                                                                                                                                                                                                            program_application_id,
                                                                                                                                                                                                                                                                                                                                            program_id,
                                                                                                                                                                                                                                                                                                                                            program_update_date,
                                                                                                                                                                                                                                                                                                                                            request_id*/)
        SELECT pa.project_id,
               top.task_id,
               xah.ae_header_id,
               SUM(nvl(xal.entered_dr, 0) - nvl(xal.entered_cr, 0)),
               SUM(nvl(xal.accounted_dr, 0) - nvl(xal.accounted_cr, 0)),
               SYSDATE,
               g_created_by,
               SYSDATE,
               g_last_updated_by,
               g_last_update_login /*,
                                                                                                                                                                                                                                                                                                             g_prog_appl_id,
                                                                                                                                                                                                                                                                                                             g_program_id,
                                                                                                                                                                                                                                                                                                             SYSDATE,
                                                                                                                                                                                                                                                                                                             g_request_id*/
          FROM xla_ae_headers xah,
               xla_ae_lines   xal,
               pa_tasks       top,
               pa_projects    pa
        
         WHERE xah.application_id = g_pa_appl_id
           AND xah.je_category_name IN ('4')
           AND xah.ae_header_id = xal.ae_header_id
           AND top.task_id = top.top_task_id
           AND top.project_id = pa.project_id
           AND xal.description = pa.segment1 || '.' || top.task_number || '.ER'
           AND xal.accounting_class_code = 'REVENUE'
              --AND xal.ae_line_num        =   1
           AND xah.accounting_date >= p_start_date
           AND xah.accounting_date <= p_end_date
              --AND xah.je_category_name   =   NVL(p_je_category_name, xah.je_category_name)
           AND pa.project_id = nvl(p_project_id, pa.project_id)
           AND top.task_id = nvl(p_top_task_id, top.task_id)
         GROUP BY pa.project_id,
                  top.task_id,
                  xah.ae_header_id;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := SQLCODE || '-' || SQLERRM;
  END;

  PROCEDURE get_project_task(p_project_id  IN NUMBER,
                             p_task_id     IN NUMBER,
                             x_project_num OUT VARCHAR2,
                             x_mfg_num     OUT VARCHAR2) IS
  BEGIN
  
    IF p_project_id IS NOT NULL THEN
      x_project_num := xxpa_utils.get_project_number(p_project_id);
    ELSE
      x_project_num := NULL;
    END IF;
  
    IF p_task_id IS NOT NULL THEN
      x_mfg_num := xxpa_utils.get_task_number(p_task_id);
    ELSE
      x_mfg_num := NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_project_num := NULL;
      x_mfg_num     := NULL;
  END;

  PROCEDURE get_parameter_value(p_start_project_id  IN NUMBER,
                                p_start_task_id     IN NUMBER,
                                p_end_project_id    IN NUMBER,
                                p_end_task_id       IN NUMBER,
                                p_period            IN VARCHAR2,
                                x_start_project_num OUT VARCHAR2,
                                x_end_project_num   OUT VARCHAR2,
                                x_start_mfg_num     OUT VARCHAR2,
                                x_end_mfg_num       OUT VARCHAR2,
                                x_start_date        OUT DATE,
                                x_end_date          OUT DATE) IS
  BEGIN
  
    get_project_task(p_start_project_id, p_start_task_id, x_start_project_num, x_start_mfg_num);
  
    get_project_task(p_end_project_id, p_end_task_id, x_end_project_num, x_end_mfg_num);
  
    get_period_date(p_period, x_start_date, x_end_date);
    x_end_date := trunc(x_end_date) + 0.99999;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_start_project_num := NULL;
      x_end_project_num   := NULL;
      x_start_mfg_num     := NULL;
      x_end_mfg_num       := NULL;
      x_start_date        := NULL;
      x_end_date          := NULL;
  END;

  FUNCTION get_title(p_prefix VARCHAR2,
                     p_period VARCHAR2) RETURN VARCHAR2 IS
    l_title      VARCHAR2(240);
    l_month_name VARCHAR2(30);
    l_year       NUMBER;
  BEGIN
  
    l_month_name := xxfnd_common_util.get_lookup_info(xxfnd_const.appl_xxpa,
                                                      'XXPA_DEFINE_MONTHS',
                                                      xxfnd_common_util.g_lookup_code,
                                                      substrb(p_period, 1, 3),
                                                      xxfnd_common_util.g_lookup_meaning);
    l_year       := substrb(p_period, 5, 2);
    l_title      := rtrim(p_prefix) || ' ' || l_month_name || ' ' || l_year;
  
    RETURN l_title;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_city(p_top_task_id NUMBER) RETURN VARCHAR2 IS
    CURSOR city_c(p_top_task_id NUMBER) IS
      SELECT hl.city
        FROM hz_cust_site_uses_all  hcsu,
             hz_party_sites         hps,
             hz_locations           hl,
             hz_cust_acct_sites_all hcas,
             oe_order_headers_all   ooh,
             oe_order_lines_all     ool,
             pa_tasks               pt
       WHERE hcsu.cust_acct_site_id = hcas.cust_acct_site_id
         AND hcsu.site_use_code = 'BILL_TO'
         AND hcas.party_site_id = hps.party_site_id
         AND hps.location_id = hl.location_id
         AND hcsu.site_use_id = ooh.invoice_to_org_id
         AND ooh.header_id = ool.header_id
         AND ool.task_id = pt.task_id
         AND pt.top_task_id = p_top_task_id;
  
    l_city hz_locations.city%TYPE;
  BEGIN
  
    OPEN city_c(p_top_task_id);
    FETCH city_c
      INTO l_city;
    IF city_c%NOTFOUND THEN
      l_city := NULL;
    END IF;
    CLOSE city_c;
  
    RETURN l_city;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_country(p_top_task_id NUMBER) RETURN VARCHAR2 IS
    CURSOR country_c(p_top_task_id NUMBER) IS
      SELECT ter.territory_short_name country
        FROM hz_cust_site_uses_all  hcsu,
             hz_party_sites         hps,
             hz_locations           hl,
             fnd_territories_vl     ter,
             hz_cust_acct_sites_all hcas,
             oe_order_headers_all   ooh,
             oe_order_lines_all     ool,
             pa_tasks               pt
       WHERE hcsu.cust_acct_site_id = hcas.cust_acct_site_id
         AND hcas.party_site_id = hps.party_site_id
         AND hps.location_id = hl.location_id
         AND hl.country = ter.territory_code
         AND hcsu.site_use_id = ooh.ship_to_org_id
         AND ooh.header_id = ool.header_id
         AND ool.project_id = pt.project_id
         AND ool.task_id = pt.task_id
         AND pt.top_task_id = p_top_task_id;
  
    l_country fnd_territories_vl.territory_short_name%TYPE;
  BEGIN
  
    OPEN country_c(p_top_task_id);
    FETCH country_c
      INTO l_country;
    IF country_c%NOTFOUND THEN
      l_country := NULL;
    END IF;
    CLOSE country_c;
  
    RETURN l_country;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_model(p_top_task_id NUMBER) RETURN VARCHAR2 IS
    CURSOR model_c(p_top_task_id NUMBER) IS
      SELECT xsol.model
        FROM xxpjm_so_addtn_lines_all xsol,
             oe_order_lines_all       ool,
             pa_tasks                 pt
       WHERE xsol.so_line_id = ool.line_id
         AND ool.task_id = pt.task_id
         AND pt.top_task_id = p_top_task_id;
  
    l_model xxpjm_so_addtn_lines_all.model%TYPE;
  BEGIN
  
    OPEN model_c(p_top_task_id);
    FETCH model_c
      INTO l_model;
    IF model_c%NOTFOUND THEN
      l_model := NULL;
    END IF;
    CLOSE model_c;
  
    RETURN l_model;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_subtitle(p_section NUMBER) RETURN VARCHAR2 IS
    l_subtitle VARCHAR2(240);
  BEGIN
  
    xxfnd_common_util.get_lookup_info(xxfnd_const.appl_xxpa,
                                      'XXPA_REPORT_SUBTITLE',
                                      xxfnd_common_util.g_lookup_code,
                                      p_section,
                                      xxfnd_common_util.g_lookup_meaning,
                                      l_subtitle);
  
    RETURN l_subtitle;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_section(p_top_task_id NUMBER,
                       p_period      VARCHAR2) RETURN NUMBER IS
    CURSOR min_period_c(p_top_task_id NUMBER) IS
      SELECT xxpa_utils.get_period_name(MIN(pei.expenditure_item_date))
        FROM pa_expenditure_items_all pei,
             pa_tasks                 pt
       WHERE EXISTS (SELECT NULL
                FROM xxpa_fg_completion_relation r
               WHERE r.transaction_source = pei.transaction_source
                 AND r.orig_transaction_reference = pei.orig_transaction_reference)
         AND pei.task_id = pt.task_id
         AND pt.top_task_id = p_top_task_id;
  
    CURSOR type_c(p_top_task_id NUMBER) IS
      SELECT xl.description
        FROM oe_order_lines_all      ool,
             oe_order_headers_all    ooh,
             oe_transaction_types_vl ott,
             pa_tasks                pt,
             xxpa_lookups            xl
       WHERE ool.header_id = ooh.header_id
         AND ool.task_id = pt.task_id
         AND ooh.order_type_id = ott.transaction_type_id
         AND xl.lookup_type = 'XXPA_REPORT_ORDER_TYPE'
         AND xl.enabled_flag = 'Y'
         AND trunc(SYSDATE) >= nvl(xl.start_date_active, trunc(SYSDATE))
         AND trunc(SYSDATE) <= nvl(xl.end_date_active, trunc(SYSDATE))
         AND xl.meaning = ott.name
         AND pt.top_task_id = p_top_task_id;
  
    CURSOR others_c(p_top_task_id NUMBER) IS
      SELECT 'Y'
        FROM pa_tasks        pt,
             pa_projects_all pa,
             xxpa_lookups    xl
       WHERE pt.project_id = pa.project_id
         AND xl.lookup_type = 'XXPA_EQ_REV_SPEC_PROJ_TYPES'
         AND xl.enabled_flag = 'Y'
         AND trunc(SYSDATE) >= nvl(xl.start_date_active, trunc(SYSDATE))
         AND trunc(SYSDATE) <= nvl(xl.end_date_active, trunc(SYSDATE))
         AND xl.meaning = pa.project_type
         AND pt.task_id = p_top_task_id;
  
    CURSOR proj_type_c(p_top_task_id NUMBER) IS
      SELECT pa.project_type
        FROM pa_tasks        pt,
             pa_projects_all pa
       WHERE pt.project_id = pa.project_id
         AND pt.task_id = p_top_task_id;
  
    l_min_period   gl_period_statuses.period_name%TYPE;
    l_type         xxpa_lookups.description%TYPE;
    l_section      NUMBER;
    l_others_flag  VARCHAR2(1);
    l_project_type pa_projects_all.project_type%TYPE;
  BEGIN
  
    IF g_task_tbl.exists(p_top_task_id) THEN
      l_section := g_task_tbl(p_top_task_id);
    ELSE
    
      OPEN min_period_c(p_top_task_id);
      FETCH min_period_c
        INTO l_min_period;
      CLOSE min_period_c;
    
      OPEN proj_type_c(p_top_task_id);
      FETCH proj_type_c
        INTO l_project_type;
      CLOSE proj_type_c;
    
      IF to_date(l_min_period, 'MON-YY') < to_date(p_period, 'MON-YY') OR
         l_project_type = 'Z' AND 'N' = xxpa_utils.get_exclude_flag(p_top_task_id) THEN
        g_task_tbl(p_top_task_id) := g_add_cost_sec;
        RETURN g_add_cost_sec;
      END IF;
    
      OPEN type_c(p_top_task_id);
      FETCH type_c
        INTO l_type;
      IF type_c%NOTFOUND THEN
        l_type := NULL;
      END IF;
      CLOSE type_c;
    
      IF l_type IS NOT NULL THEN
      
        IF l_type = g_domestic THEN
          l_section := g_domestic_sec;
        ELSIF l_type = g_overseas THEN
          l_section := g_overseas_sec;
        ELSIF l_type = g_parts THEN
          l_section := g_parts_sec;
        ELSE
          l_section := g_add_cost_sec;
        END IF;
      
      ELSE
      
        OPEN others_c(p_top_task_id);
        FETCH others_c
          INTO l_others_flag;
        IF others_c%NOTFOUND THEN
          l_others_flag := 'N';
        END IF;
        CLOSE others_c;
      
        IF l_others_flag = 'Y' THEN
          l_section := g_others_sec;
        ELSE
          l_section := g_add_cost_sec;
        END IF;
      
      END IF;
    
      g_task_tbl(p_top_task_id) := l_section;
    
    END IF;
  
    RETURN l_section;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_item_category(p_org_id            NUMBER,
                             p_inventory_item_id NUMBER) RETURN VARCHAR2 IS
    CURSOR cat_c(p_org_id            NUMBER,
                 p_inventory_item_id NUMBER) IS
      SELECT decode(mc.segment1,
                    g_null_category,
                    -- v3.0 update by hand  2014-09-10 back to v1.0 start
                    'PPO',
                    -- v3.0 update by hand  2014-09-10 back to v1.0 end
                    -- v2.0 update by jiaming.zhou 2014-08-27 start
                    --'PPO',
                    --'SOS',
                    -- v2.0 update by jiaming.zhou 2014-08-27 end
                    mc.segment1)
        FROM org_organization_definitions ood,
             mtl_item_categories          mic,
             mtl_categories_b             mc
       WHERE ood.operating_unit = p_org_id
         AND mic.inventory_item_id = p_inventory_item_id
         AND mic.organization_id = ood.organization_id
         AND mic.category_id = mc.category_id
         AND mc.structure_id = 50350;
  
    l_item_category mtl_categories_b_kfv.concatenated_segments%TYPE;
  BEGIN
  
    OPEN cat_c(p_org_id, p_inventory_item_id);
    FETCH cat_c
      INTO l_item_category;
    IF cat_c%NOTFOUND THEN
      l_item_category := NULL;
    END IF;
    CLOSE cat_c;
    -- v3.0 update by hand  2014-09-10 back to v1.0 start
    l_item_category := nvl(l_item_category, 'PPO');
    -- v3.0 update by hand  2014-09-10 back to v1.0 end
  
    -- v2.0 update by jiaming.zhou 2014-08-27 start
    --l_item_category := NVL(l_item_category, 'PPO');
    --l_item_category := NVL(l_item_category, 'SSO');
    -- v2.0 update by jiaming.zhou 2014-08-27 end  
  
    RETURN l_item_category;
  
  END;

  FUNCTION get_material_category(p_expenditure_type VARCHAR2) RETURN VARCHAR2 IS
    l_description xxpa_lookups.description%TYPE;
  BEGIN
  
    xxfnd_common_util.get_lookup_info(xxfnd_const.appl_xxpa,
                                      'XXPA_MATERIAL_EXP_TYPES',
                                      xxfnd_common_util.g_lookup_meaning,
                                      p_expenditure_type,
                                      xxfnd_common_util.g_lookup_desc,
                                      l_description);
  
    RETURN l_description;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_title_seqnum(p_report_exp_type VARCHAR2) RETURN NUMBER IS
    CURSOR seq_c(p_report_exp_type VARCHAR2) IS
      SELECT to_number(xl.lookup_code)
        FROM xxpa_lookups xl
       WHERE xl.lookup_type = 'XXPA_REPORT_TITLE_SEQ'
         AND xl.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND
             nvl(xl.end_date_active, trunc(SYSDATE))
         AND xl.meaning = p_report_exp_type;
  
    l_default_value CONSTANT NUMBER := 9999;
    l_seqnum NUMBER;
  BEGIN
  
    OPEN seq_c(p_report_exp_type);
    FETCH seq_c
      INTO l_seqnum;
    IF seq_c%NOTFOUND THEN
      l_seqnum := l_default_value;
    END IF;
    CLOSE seq_c;
  
    RETURN l_seqnum;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_default_value;
  END;

  FUNCTION get_title_seqnum2(p_expenditure_category VARCHAR2) RETURN NUMBER IS
    CURSOR seq_c(p_expenditure_category VARCHAR2) IS
      SELECT MIN(to_number(xl.lookup_code))
        FROM xxpa_lookups         xl,
             pa_expenditure_types pet
       WHERE xl.lookup_type = 'XXPA_REPORT_TITLE_SEQ'
         AND xl.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND
             nvl(xl.end_date_active, trunc(SYSDATE))
         AND xl.meaning = pet.attribute15
         AND pet.attribute_category = 'HEA_OU'
         AND pet.expenditure_category = p_expenditure_category;
  
    l_default_value CONSTANT NUMBER := 9999;
    l_seqnum NUMBER;
  BEGIN
  
    OPEN seq_c(p_expenditure_category);
    FETCH seq_c
      INTO l_seqnum;
    IF seq_c%NOTFOUND THEN
      l_seqnum := l_default_value;
    END IF;
    CLOSE seq_c;
  
    l_seqnum := nvl(l_seqnum, l_default_value);
  
    RETURN l_seqnum;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_default_value;
  END;

  FUNCTION get_func_cost(p_project_id       NUMBER,
                         p_top_task_id      NUMBER,
                         p_expenditure_type VARCHAR2) RETURN NUMBER IS
    CURSOR cost_c(p_project_id       NUMBER,
                  p_top_task_id      NUMBER,
                  p_expenditure_type VARCHAR2) IS
      SELECT SUM(t.burden_cost)
        FROM xxpa_proj_exp_items_tmp t
       WHERE 1 = 1
            -- v5.0 update by hand  2014-11-12 modify function Begin
            -- AND t.expenditure_type != 'Material'
         AND t.expenditure_type NOT IN ('Material', 'Material Overhead', 'Resource', 'Outsourcing', 'Overhead')
            -- v5.0 update by hand  2014-11-12 modify function End            
         AND t.project_id = p_project_id
         AND t.top_task_id = p_top_task_id
         AND t.report_exp_type = p_expenditure_type;
  
    CURSOR cost2_c(p_project_id  NUMBER,
                   p_top_task_id NUMBER,
                   p_category    VARCHAR2) IS
      SELECT SUM(t.burden_cost)
        FROM xxpa_proj_exp_items_tmp t
       WHERE 1 = 1
            -- v5.0 update by hand  2014-11-12 modify function Begin
            -- AND t.expenditure_type = 'Material'
         AND t.expenditure_type IN ('Material', 'Material Overhead', 'Resource', 'Outsourcing', 'Overhead')
            -- v5.0 update by hand  2014-11-12 modify function End            
         AND t.project_id = p_project_id
         AND t.top_task_id = p_top_task_id
            -- v5.0 update by hand  2014-11-12 modify function Begin
            -- AND xxpa_reports_utils.get_item_category(t.org_id, t.inventory_item_id) = p_category
         AND xxpa_reports_utils.get_material_category(xxpa_reports_utils.fun_get_report_exp_type(t.expenditure_item_id)) =
             p_category
      -- v5.0 update by hand  2014-11-12 modify function End  
      ;
  
    l_func_cost NUMBER;
    l_addl_cost NUMBER;
    l_category  mtl_categories_b_kfv.concatenated_segments%TYPE;
  BEGIN
  
    OPEN cost_c(p_project_id, p_top_task_id, p_expenditure_type);
    FETCH cost_c
      INTO l_func_cost;
    IF cost_c%NOTFOUND THEN
      l_func_cost := NULL;
    END IF;
    CLOSE cost_c;
  
    l_func_cost := nvl(l_func_cost, 0);
  
    l_category := xxpa_reports_utils.get_material_category(p_expenditure_type);
    IF l_category IS NOT NULL THEN
    
      OPEN cost2_c(p_project_id, p_top_task_id, l_category);
      FETCH cost2_c
        INTO l_addl_cost;
      CLOSE cost2_c;
    
      l_func_cost := l_func_cost + nvl(l_addl_cost, 0);
    
    END IF;
  
    RETURN nvl(l_func_cost, 0);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION get_func_cost2(p_project_id       NUMBER,
                          p_top_task_id      NUMBER,
                          p_expenditure_type VARCHAR2,
                          p_activity_type    VARCHAR2) RETURN NUMBER IS
    CURSOR cost_c(p_project_id       NUMBER,
                  p_top_task_id      NUMBER,
                  p_expenditure_type VARCHAR2,
                  p_activity_type    VARCHAR2) IS
      SELECT SUM(t.burden_cost)
        FROM xxpa_proj_exp_items_tmp2 t
       WHERE t.expenditure_type != 'Material'
         AND t.project_id = p_project_id
         AND t.top_task_id = p_top_task_id
         AND t.report_exp_type = p_expenditure_type
         AND t.activity_type = p_activity_type;
  
    CURSOR cost2_c(p_project_id    NUMBER,
                   p_top_task_id   NUMBER,
                   p_category      VARCHAR2,
                   p_activity_type VARCHAR2) IS
      SELECT SUM(t.burden_cost)
        FROM xxpa_proj_exp_items_tmp2 t
       WHERE t.expenditure_type = 'Material'
         AND t.project_id = p_project_id
         AND t.top_task_id = p_top_task_id
         AND xxpa_reports_utils.get_item_category(t.org_id, t.inventory_item_id) = p_category
         AND t.activity_type = p_activity_type;
  
    l_func_cost NUMBER;
    l_addl_cost NUMBER;
    l_category  mtl_categories_b_kfv.concatenated_segments%TYPE;
  BEGIN
  
    OPEN cost_c(p_project_id, p_top_task_id, p_expenditure_type, p_activity_type);
    FETCH cost_c
      INTO l_func_cost;
    IF cost_c%NOTFOUND THEN
      l_func_cost := NULL;
    END IF;
    CLOSE cost_c;
  
    l_func_cost := nvl(l_func_cost, 0);
  
    l_category := xxpa_reports_utils.get_material_category(p_expenditure_type);
    IF l_category IS NOT NULL THEN
    
      OPEN cost2_c(p_project_id, p_top_task_id, l_category, p_activity_type);
      FETCH cost2_c
        INTO l_addl_cost;
      CLOSE cost2_c;
    
      l_func_cost := l_func_cost + nvl(l_addl_cost, 0);
    
    END IF;
  
    RETURN nvl(l_func_cost, 0);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION get_expenditure_category(p_report_title VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cat_c(p_report_title VARCHAR2) IS
      SELECT pet.expenditure_category
        FROM pa_expenditure_types pet
       WHERE pet.attribute_category = 'HEA_OU'
         AND pet.attribute15 = p_report_title;
  
    l_no_exp_category      pa_expenditure_types.expenditure_category%TYPE;
    l_expenditure_category pa_expenditure_types.expenditure_category%TYPE;
  BEGIN
  
    l_no_exp_category := 'NO_EXP_CATEGORY_DEFINED';
    OPEN cat_c(p_report_title);
    FETCH cat_c
      INTO l_expenditure_category;
    IF cat_c%NOTFOUND THEN
      l_expenditure_category := NULL;
    END IF;
    CLOSE cat_c;
  
    RETURN nvl(l_expenditure_category, l_no_exp_category);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_title_style RETURN VARCHAR2 IS
    l_style VARCHAR2(240);
  BEGIN
    l_style := ' <p align=center style="font-family:''Calibri'';font-size:17px;font-weight:bold;">p_title</p> ';
    RETURN l_style;
  END;

  FUNCTION get_table_style RETURN VARCHAR2 IS
    l_style VARCHAR2(240);
  BEGIN
    l_style := ' style="font-family:''Calibri'';font-size:13px;" ';
    RETURN l_style;
  END;

  FUNCTION get_cancelled_flag(p_top_task_id NUMBER) RETURN VARCHAR2 IS
    CURSOR flag_c(p_top_task_id NUMBER) IS
      SELECT nvl(SUM(1), 0) line_cnt,
             nvl(SUM(decode(ool.flow_status_code, 'CANCELLED', 1, 0)), 0) cancelled_cnt
        FROM oe_order_lines_all ool,
             pa_tasks           pt
       WHERE ool.task_id = pt.task_id
         AND ool.project_id = pt.project_id
         AND pt.top_task_id = p_top_task_id;
  
    l_line_cnt       NUMBER;
    l_cancelled_cnt  NUMBER;
    l_cancelled_flag VARCHAR2(1);
  BEGIN
  
    OPEN flag_c(p_top_task_id);
    FETCH flag_c
      INTO l_line_cnt,
           l_cancelled_cnt;
    CLOSE flag_c;
  
    IF l_line_cnt = 0 OR l_line_cnt > l_cancelled_cnt THEN
      l_cancelled_flag := 'N';
    ELSE
      l_cancelled_flag := 'Y';
    END IF;
  
    RETURN l_cancelled_flag;
  
  END;

  FUNCTION get_currency_code(p_top_task_id NUMBER) RETURN VARCHAR2 IS
    CURSOR curr_c(p_top_task_id NUMBER) IS
      SELECT ooh.transactional_curr_code
        FROM oe_order_lines_all   ool,
             oe_order_headers_all ooh,
             pa_tasks             pt
       WHERE ool.header_id = ooh.header_id
         AND ool.task_id = pt.task_id
         AND pt.top_task_id = p_top_task_id;
  
    l_currency_code fnd_currencies_vl.currency_code%TYPE;
  BEGIN
  
    OPEN curr_c(p_top_task_id);
    FETCH curr_c
      INTO l_currency_code;
    CLOSE curr_c;
  
    RETURN l_currency_code;
  
  END;

  FUNCTION get_sales_amount(p_top_task_id NUMBER,
                            p_end_date    DATE) RETURN NUMBER IS
    l_currency_code fnd_currencies.currency_code%TYPE;
    l_sales_amount  NUMBER;
  BEGIN
  
    l_currency_code := get_currency_code(p_top_task_id);
    l_sales_amount  := nvl(xxpa_utils.get_amount2(p_top_task_id, xxpa_utils.g_eq_type), 0);
    l_sales_amount  := xxfnd_currency_pub.round_pa_amount(xxar_utils.convert_amount(l_currency_code,
                                                                                    xxpa_utils.get_currency_code,
                                                                                    p_end_date,
                                                                                    'Corporate',
                                                                                    l_sales_amount));
  
    RETURN l_sales_amount;
  
  END;

  FUNCTION get_report_exp_type(p_org_id            NUMBER,
                               p_inventory_item_id NUMBER) RETURN VARCHAR2 IS
    CURSOR rep_exp_type_c(p_item_category VARCHAR2) IS
      SELECT xl.meaning
        FROM xxpa_lookups xl
       WHERE xl.lookup_type = 'XXPA_MATERIAL_EXP_TYPES'
         AND xl.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND
             nvl(xl.end_date_active, trunc(SYSDATE))
         AND xl.description = p_item_category;
  
    l_item_category mtl_categories_b_kfv.concatenated_segments%TYPE;
    l_exp_type      pa_expenditure_types.attribute15%TYPE;
  BEGIN
  
    l_item_category := get_item_category(p_org_id, p_inventory_item_id);
    OPEN rep_exp_type_c(l_item_category);
    FETCH rep_exp_type_c
      INTO l_exp_type;
    IF rep_exp_type_c%NOTFOUND THEN
      l_exp_type := NULL;
    END IF;
    CLOSE rep_exp_type_c;
  
    RETURN l_exp_type;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_exp_type(p_org_id            NUMBER,
                        p_inventory_item_id NUMBER) RETURN VARCHAR2 IS
    CURSOR exp_type_c(p_item_category VARCHAR2) IS
      SELECT xl.tag
        FROM xxpa_lookups xl
       WHERE xl.lookup_type = 'XXPA_MATERIAL_EXP_TYPES'
         AND xl.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND
             nvl(xl.end_date_active, trunc(SYSDATE))
         AND xl.description = p_item_category;
  
    l_item_category mtl_categories_b_kfv.concatenated_segments%TYPE;
    l_exp_type      pa_expenditure_types.attribute15%TYPE;
  BEGIN
  
    l_item_category := get_item_category(p_org_id, p_inventory_item_id);
    OPEN exp_type_c(l_item_category);
    FETCH exp_type_c
      INTO l_exp_type;
    IF exp_type_c%NOTFOUND THEN
      l_exp_type := NULL;
    END IF;
    CLOSE exp_type_c;
  
    RETURN l_exp_type;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /* ==========================================================================
    *   Procedure Name: 
    *             fun_get_report_exp_type
    *
    *   DESCRIPTION : 
    *             get expenditure's expense type
    *
    *   HISTORY     :
    *     v4.0      2014-10-30       hand      Creation
  * ==========================================================================*/
  FUNCTION fun_get_report_exp_type(p_expenditure_item_id IN NUMBER) RETURN VARCHAR2 IS
    l_exp_type           VARCHAR2(240);
    l_addition_subtitle1 VARCHAR2(240) := 'LS Stock In';
    l_expenditure_type   VARCHAR2(240);
    l_cnt                NUMBER;
  BEGIN
  
    SELECT /*CASE
                                                                     WHEN jip.expenditure_type IN ('Material', 'Material Overhead', 'Resource', 'Outsourcing', 'Overhead') THEN
                                                                      decode(xxpa_reports_utils.get_item_category(jip.org_id, jip.inventory_item_id),
                                                                             --update by jiaming.zhou v3.0 start
                                                                             --'PPO',
                                                                             --'PPO/POM',
                                                                             --'SOS(B1N)',
                                                                             --'B1dN',
                                                                             'SOS(B' || chr(38) || 'N)',
                                                                             'B' || chr(38) || 'N',
                                                                             --update by jiaming.zhou v3.0 end
                                                                             'SOS',
                                                                             'SOS',
                                                                             --update by jiaming.zhou v3.0 start
                                                                             --'PPO/POM'
                                                                             'SOS'
                                                                             --update by jiaming.zhou v3.0 end
                                                                             )
                                                                     ELSE
                                                                      decode(pet.attribute_category, 'HEA_OU', nvl(pet.attribute15, jip.expenditure_type), jip.expenditure_type)
                                                                   END report_exp_type,*/
    
     CASE
       WHEN jip.expenditure_type IN ('Material', 'Material Overhead', 'Resource', 'Outsourcing', 'Overhead') THEN
       
        decode((SELECT pa.project_type
                 FROM pa_projects_all pa
                WHERE pa.project_id = jip.project_id),
               'LS',
               decode(sign(decode(jip.system_linkage_function,
                                  'ST',
                                  decode(pa_security.view_labor_costs(jip.project_id), 'Y', jip.burden_cost, NULL),
                                  'OT',
                                  decode(pa_security.view_labor_costs(jip.project_id), 'Y', jip.burden_cost, NULL),
                                  jip.burden_cost)),
                      -1,
                      l_addition_subtitle1,
                      CASE
                        WHEN jip.expenditure_type = 'Outsourcing' AND jip.system_linkage_function = 'WIP' AND
                             jip.transaction_source = 'Work In Process' THEN
                         l_addition_subtitle1
                        ELSE
                         decode(xxpa_reports_utils.get_item_category(jip.org_id, jip.inventory_item_id),
                                --update by jiaming.zhou v3.0 start
                                --'PPO',
                                --'PPO/POM',
                                --'SOS(B1N)',
                                --'B1dN',
                                'SOS(B' || chr(38) || 'N)',
                                'B' || chr(38) || 'N',
                                --update by jiaming.zhou v3.0 end
                                'SOS',
                                'SOS',
                                --update by jiaming.zhou v3.0 start
                                --'PPO/POM'
                                'SOS'
                                --update by jiaming.zhou v3.0 end
                                )
                      END),
               decode(xxpa_reports_utils.get_item_category(jip.org_id, jip.inventory_item_id),
                      --update by jiaming.zhou v3.0 start
                      --'PPO',
                      --'PPO/POM',
                      --'SOS(B1N)',
                      --'B1dN',
                      'SOS(B' || chr(38) || 'N)',
                      'B' || chr(38) || 'N',
                      --update by jiaming.zhou v3.0 end
                      'SOS',
                      'SOS',
                      --update by jiaming.zhou v3.0 start
                      --'PPO/POM'
                      'SOS'
                      --update by jiaming.zhou v3.0 end
                      ))
     
       ELSE
        decode(pet.attribute_category, 'HEA_OU', nvl(pet.attribute15, jip.expenditure_type), jip.expenditure_type)
     END report_exp_type,
     jip.expenditure_type
      INTO l_exp_type,
           l_expenditure_type
      FROM pa_expenditure_items_all jip,
           pa_expenditure_types     pet
     WHERE 1 = 1
       AND jip.expenditure_type = pet.expenditure_type
          -- AND jip.expenditure_type IN ('Material', 'Material Overhead', 'Resource', 'Outsourcing', 'Overhead')
       AND jip.expenditure_item_id = p_expenditure_item_id;
  
    IF l_expenditure_type IN ('Material', 'Material Overhead', 'Resource', 'Outsourcing', 'Overhead') THEN
      l_cnt := 0;
    
      SELECT COUNT(1)
        INTO l_cnt
        FROM pa_expenditure_items_all  pei,
             mtl_material_transactions mmt,
             rcv_transactions          rt
       WHERE pei.expenditure_item_id = p_expenditure_item_id --tmp.expenditure_item_id
         AND pei.transaction_source = 'Inventory'
         AND pei.orig_transaction_reference = mmt.transaction_id
         AND mmt.rcv_transaction_id = rt.transaction_id
         AND rt.po_distribution_id IS NOT NULL;
      IF l_cnt > 0 THEN
        l_exp_type := 'PPO/POM';
      END IF;
    
      --add by jiaming.zhou 2014-08-27 start v3.0
      /*UPDATE xxpa_proj_exp_items_tmp1 tmp
        SET report_exp_type = 'PPO/POM'
      WHERE expenditure_type IN ('Material', 'Material Overhead', 'Resource', 'Outsourcing', 'Overhead')
        AND EXISTS (SELECT 1
               FROM pa_expenditure_items_all  pei,
                    mtl_material_transactions mmt,
                    rcv_transactions          rt
              WHERE pei.expenditure_item_id = tmp.expenditure_item_id
                AND pei.transaction_source = 'Inventory'
                AND pei.orig_transaction_reference = mmt.transaction_id
                AND mmt.rcv_transaction_id = rt.transaction_id
                AND rt.po_distribution_id IS NOT NULL)
        AND request_id = g_request_id;*/
      --add by jiaming.zhou 2014-08-27 end v3.0
    
    END IF;
  
    RETURN l_exp_type;
  END fun_get_report_exp_type;

  /* ==========================================================================
    *   Procedure Name: 
    *             fun_get_exp_type
    *
    *   DESCRIPTION : 
    *             get expenditure's expense type
    *
    *   HISTORY     :
    *     v4.0      2014-10-30       hand      Creation
  * ==========================================================================*/
  FUNCTION fun_get_exp_type(p_expenditure_item_id IN NUMBER) RETURN VARCHAR2 IS
    l_exp_type           VARCHAR2(240);
    l_addition_subtitle1 VARCHAR2(240) := 'LS Stock In';
    l_expenditure_type   VARCHAR2(240);
    l_cnt                NUMBER;
    CURSOR exp_type_c(p_report_exp_type VARCHAR2) IS
      SELECT xl.tag
        FROM xxpa_lookups xl
       WHERE xl.lookup_type = 'XXPA_MATERIAL_EXP_TYPES'
         AND xl.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN nvl(xl.start_date_active, trunc(SYSDATE)) AND
             nvl(xl.end_date_active, trunc(SYSDATE))
         AND (xl.description = p_report_exp_type OR xl.meaning = p_report_exp_type);
  BEGIN
    l_exp_type := fun_get_report_exp_type(p_expenditure_item_id => p_expenditure_item_id);
  
    OPEN exp_type_c(p_report_exp_type => l_exp_type);
    FETCH exp_type_c
      INTO l_exp_type;
    IF exp_type_c%NOTFOUND THEN
      l_exp_type := NULL;
    END IF;
    CLOSE exp_type_c;
  
    RETURN l_exp_type;
  END fun_get_exp_type;

END;
/
