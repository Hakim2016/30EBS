CREATE OR REPLACE PACKAGE xxpa_proj_cogs_mon_rpt3_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPA_PROJ_COGS_MONTHLY_RPT_PKG
  Description:
      This program provide concurrent main procedure to perform:
      
  History:
      1.00  2013-7-2 21:07:19  Senlin.Gu  Creation
      2.00  2017-2-6 21:07:19  Steven.Wang  Modify for tuning
  ==================================================*/

  g_tab         VARCHAR2(1) := chr(9);
  g_change_line VARCHAR2(2) := chr(10) || chr(13);
  g_line        VARCHAR2(150) := rpad('-', 150, '-');
  g_space       VARCHAR2(40) := '&nbsp';

  g_last_updated_date DATE := SYSDATE;
  g_last_updated_by   NUMBER := fnd_global.user_id;
  g_creation_date     DATE := SYSDATE;
  g_created_by        NUMBER := fnd_global.user_id;
  g_last_update_login NUMBER := fnd_global.login_id;

  g_request_id NUMBER := fnd_global.conc_request_id;
  g_session_id NUMBER := userenv('sessionid');

  --add  by steven.wang 2016-12-14 start
  FUNCTION get_cogs_gp(p_detial_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION get_cogs_gp1(p_wip_entity_id   IN NUMBER,
                        p_organization_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION get_expen_type(p_inventory_item_id    IN NUMBER,
                          p_organization_id      IN NUMBER,
                          p_expenditure_type     IN VARCHAR2,
                          p_expenditure_category IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION transfer_period(p_period_name IN VARCHAR2) RETURN DATE;

  --main
  PROCEDURE main(x_errbuf       OUT VARCHAR2,
                 x_retcode      OUT VARCHAR2,
                 p_org_name     IN VARCHAR2,
                 p_period       IN VARCHAR2,
                 p_summary_by   IN VARCHAR2,
                 p_profile_base IN VARCHAR2);

  PROCEDURE collect_data;
  PROCEDURE mail_main(errbuf       OUT VARCHAR2,
                      retcode      OUT VARCHAR2,
                      p_request_id IN NUMBER);
END xxpa_proj_cogs_mon_rpt3_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxpa_proj_cogs_mon_rpt3_pkg AS
  /*==================================================
  Program Name:
      XXPA_PROJ_COGS_MONTHLY_RPT_PKG
  Description:
      This program provide concurrent main procedure to perform:
  
  History:
      1.00  2013-7-2 21:07:19  Senlin.Gu  Creation
      2.00  2017-2-6 21:07:19  Steven.Wang  Modify for tuning
      3.00  2017-3-6 liudan modify for het hardcoding and cr
      4.00  2017-12-06 steven.wang for performance tuning
      5.00  2018-01-24 jingjinghe update invalid month
  ==================================================*/
  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'xxpa_proj_cogs_mon_rpt3_pkg';
  -- Debug Enabled
  l_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');

  g_group_by_mfg  VARCHAR2(40) := 'MFG';
  g_group_by_task VARCHAR2(40) := 'Task';

  g_from_email VARCHAR2(150);
  g_smtp_host  VARCHAR2(150);

  g_fac_org VARCHAR2(40) := 'SHE_FAC_ORG';
  g_hq_org  VARCHAR2(40) := 'SHE_HQ_ORG';
  g_het_org VARCHAR2(40) := 'HET_HQ_ORG';
  /*  l_last_min_id NUMBER;
  l_last_max_id NUMBER;*/

  g_gscm_item_category VARCHAR2(50) := 'GSCM Item Category Set';

  g_summary_by       VARCHAR2(40);
  g_org_name         VARCHAR2(40);
  g_period           VARCHAR2(40);
  g_period_date      DATE;
  g_period_date_from DATE;
  g_round            NUMBER := 2;
  g_date_format      VARCHAR2(30) := 'YYYY-MON-DD HH24:MI:SS';
  g_profile_base     VARCHAR2(50);

  g_profit_type0 VARCHAR2(50) := '0.Current Period Invoice Amount(THB)';
  g_profit_type1 VARCHAR2(50) := 'Price(THB)';
  g_profit_type2 VARCHAR2(50) := 'Invoice(THB)';

  g_invoice_amt_type1 VARCHAR2(50) := '0.Current Period Invoice Amount';
  g_invoice_amt_type2 VARCHAR2(50) := '2.Invoice';
  g_price_type        VARCHAR2(50) := '1.Price';
  g_cogs_type         VARCHAR2(50) := '3.COGS';

  g_type_text   CONSTANT VARCHAR2(40) := 'TEXT';
  g_type_amount CONSTANT VARCHAR2(40) := 'AMOUNT';

  --output
  PROCEDURE output(p_content VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_content);
  END output;

  PROCEDURE output_column(p_column_text VARCHAR2, p_column_type VARCHAR2) IS
  BEGIN
    xxpa_proj_cost_rpt_pub.output_column(p_column_text, p_column_type);
  END;

  PROCEDURE output_col_title(p_column_title VARCHAR2,
                             p_col_span     NUMBER DEFAULT 1) IS
  BEGIN
    xxpa_proj_cost_rpt_pub.output_col_title(p_column_title, p_col_span);
  END;

  --log
  PROCEDURE log(p_content VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_content);
  END log;
  --add  by steven.wang 2016-12-14 start
  FUNCTION get_cogs_gp(p_detial_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_project IS
      SELECT msc.category_concat_segs
        FROM xxpa_cost_flow_dtls_all    xcfd,
             apps.mtl_item_categories_v msc,
             wip_entities               we,
             wip_discrete_jobs          wdj
       WHERE xcfd.cost_detail_id = p_detial_id
         AND xcfd.orig_expenditure_type = we.wip_entity_name
         AND xcfd.expenditure_org_id = wdj.organization_id
         AND we.wip_entity_id = wdj.wip_entity_id
         AND msc.inventory_item_id = wdj.primary_item_id
         AND msc.organization_id = wdj.organization_id
         AND msc.category_set_name = g_gscm_item_category;
    l_group_parts VARCHAR2(240);
  BEGIN
    OPEN cur_project;
    FETCH cur_project
      INTO l_group_parts;
    CLOSE cur_project;
    RETURN l_group_parts;
  END;
  FUNCTION get_cogs_gp1(p_wip_entity_id   IN NUMBER,
                        p_organization_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_project IS
      SELECT msc.category_concat_segs
        FROM apps.mtl_item_categories_v msc, wip_discrete_jobs wdj
       WHERE p_wip_entity_id = wdj.wip_entity_id
         AND wdj.organization_id = p_organization_id
         AND msc.inventory_item_id = wdj.primary_item_id
         AND msc.organization_id = wdj.organization_id
         AND msc.category_set_name = g_gscm_item_category;
    l_group_parts VARCHAR2(240);
  BEGIN
    OPEN cur_project;
    FETCH cur_project
      INTO l_group_parts;
    CLOSE cur_project;
    RETURN l_group_parts;
  END;
  FUNCTION get_expen_type(p_inventory_item_id    IN NUMBER,
                          p_organization_id      IN NUMBER,
                          p_expenditure_type     IN VARCHAR2,
                          p_expenditure_category IN VARCHAR2) RETURN VARCHAR2 IS
    l_inventory_item_id    NUMBER;
    l_expenditure_category VARCHAR2(80);
    l_category             VARCHAR2(240);
  
  BEGIN
  
    IF p_inventory_item_id IS NULL THEN
      RETURN p_expenditure_type;
    ELSE
      IF p_expenditure_category = 'Material' THEN
        l_category := xxpa_project_cost_detail_pkg.get_category(1100000044, --GSCM COST Set
                                                                p_inventory_item_id,
                                                                p_organization_id);
        IF l_category IS NULL OR l_category = 'NULL' THEN
          RETURN p_expenditure_type;
        ELSE
          RETURN l_category;
        END IF;
      ELSE
        RETURN p_expenditure_type;
      END IF;
    END IF;
  END get_expen_type;
  --add  by steven.wang 2016-12-14 end
  PROCEDURE insert_tmp(p_type         VARCHAR2,
                       p_org          VARCHAR2,
                       p_exp_id       NUMBER,
                       p_project_type VARCHAR2,
                       p_project_id   NUMBER,
                       p_task_id      NUMBER,
                       p_top_task_id  NUMBER,
                       p_proj_no      VARCHAR2,
                       p_mfg          VARCHAR2,
                       p_task         VARCHAR2,
                       p_group_parts  VARCHAR2,
                       p_expen_cate   VARCHAR2,
                       p_expen_type   VARCHAR2,
                       p_gl_date      DATE,
                       p_currency     VARCHAR2,
                       p_quantity     NUMBER,
                       p_amt          NUMBER,
                       p_currency_amt NUMBER) IS
  BEGIN
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
    VALUES
      (p_type,
       p_org,
       p_exp_id,
       p_project_type,
       p_project_id,
       p_task_id,
       p_top_task_id,
       p_proj_no,
       p_mfg,
       p_task,
       p_group_parts,
       p_expen_cate,
       p_expen_type,
       p_gl_date,
       p_currency,
       p_quantity,
       p_amt,
       p_currency_amt);
  EXCEPTION
    WHEN OTHERS THEN
      log('Exception in insert_tmp [When others then] ' || SQLERRM);
      RAISE;
  END;

  PROCEDURE collect_0_invoice_amout IS
    CURSOR cur_invoice IS
      SELECT 'Invoice Amount' TYPE,
             --UPDATE by liudan 2017/3/6  begin for het hardcoding begin
             ppt.attribute6 org,
             --decode(ppt.attribute7, 'OVERSEA', 'SHE_FAC_ORG', 'SHE_HQ_ORG') org,
             --end update by liudan 2017/3/6
             NULL expenditure_item_id,
             ppa.project_type,
             ppa.project_id,
             pt.task_id,
             pt.top_task_id,
             ppa.segment1 proj_no,
             mfg.task_number mfg,
             pt.task_number task,
             ool.attribute5 group_parts,
             '0.Current Period Invoice Amount' expen_cate,
             '0.Current Period Invoice Amount' expen_type,
             xdh.transaction_date gl_date,
             NULL gl_period_name,
             xdh.transaction_date gl_date_condition2,
             xdh.currency_code,
             xdl.quantity,
             round((xdl.amount *
                   decode(xdh.currency_code,
                           'THB',
                           1,
                           nvl(nvl(gd.conversion_rate,
                                   (SELECT gd2.conversion_rate
                                      FROM gl_daily_rates gd2
                                    -- start modify by gusenlin 2013-03-05  update to type  SHEAR
                                    --WHERE gd2.conversion_type = '1001' --SHARP
                                     WHERE gd2.conversion_type = '1002' --SHARP
                                          --END
                                       AND gd2.from_currency =
                                           xdh.currency_code
                                       AND gd2.to_currency = 'THB'
                                       AND gd2.conversion_date =
                                           (SELECT MAX(gd3.conversion_date)
                                              FROM gl_daily_rates gd3
                                             WHERE gd3.conversion_type =
                                                   gd2.conversion_type
                                               AND gd3.from_currency =
                                                   gd2.from_currency
                                               AND gd3.to_currency =
                                                   gd2.to_currency
                                               AND gd3.conversion_date <=
                                                   trunc(xdh.transaction_date)))),
                               1))),
                   2) amt,
             round(xdl.amount, 2) currency_amt
        FROM apps.oe_order_lines_all          ool,
             apps.pa_projects_all             ppa,
             apps.pa_tasks                    pt,
             apps.pa_tasks                    mfg,
             apps.hr_organization_units       ho,
             apps.xxom_do_invoice_headers_all xdh,
             apps.xxom_do_invoice_lines_all   xdl,
             apps.pa_project_types_all        ppt,
             apps.gl_daily_rates              gd,
             apps.pa_periods_all              pp
       WHERE ppa.project_type = ppt.project_type
         AND ool.project_id = ppa.project_id
         AND ppa.org_id = ho.organization_id
         AND ppa.project_id = pt.project_id
         AND ool.task_id = pt.task_id
         AND pt.top_task_id = mfg.task_id
         AND pt.project_id = mfg.project_id
         AND xdh.header_id = xdl.header_id
         AND xdl.oe_line_id = ool.line_id
         AND ool.project_id = ppa.project_id
         AND ool.task_id = pt.task_id
            --AND ppt.attribute7 IN ('OVERSEA', 'COMPLETE SET', 'DOMESTIC', 'MIX') remove by liudan 2017/03/07
            -- update by gusenlin 2013-09-10  add FAC EQ
         AND xdh.document_type = 'TAXINV'
         AND xdh.status_code NOT IN ('DRAFT', 'CANCELLED')
         AND xdh.currency_code = gd.from_currency(+)
            --[ start modify by gusenlin 2013-03-27 ]
            --AND trunc(xdh.transaction_date) = gd.conversion_date(+)
            --AND gd.conversion_type(+) = '1001' --SHARP
         AND trunc(xdh.currency_conversion_date) = gd.conversion_date(+)
         AND gd.conversion_type(+) = '1002' --SHARP   update to type  SHEAR
            --[ end modify by gusenlin 2013-03-27 ]
         AND gd.to_currency(+) = 'THB'
            --update by liudan 2017/03/06 begin
            --AND ppa.org_id = 84
         AND ppa.org_id = fnd_global.org_id
            --end update by liudan 2017/03/06
         AND xdh.transaction_date <= trunc(pp.end_date) + 0.99999
         AND xdh.transaction_date >= pp.start_date
         AND ppa.org_id = pp.org_id
            --update by liudan 2017/03/06 begin
            /* AND DECODE(ppt.attribute7,
            'OVERSEA',
            'SHE_FAC_ORG',
            'FAC EQ',
            'SHE_FAC_ORG',
            'SHE_HQ_ORG') = g_org_name*/
         AND ppt.attribute6 = g_org_name
            --end update by liudan 2017/03/06
         AND pp.gl_period_name = g_period
      
      UNION ALL
      --DOMESTIC\MIX\MTE --Sales Price
      SELECT 'Invoice Amount' type_code,
             'SHE_FAC_ORG' NAME,
             NULL expenditure_item_id,
             ppa.project_type,
             ppa.project_id,
             pt.task_id,
             pt.top_task_id,
             ppa.segment1,
             mfg.task_number mfg_number,
             pt.task_number,
             NULL group_parts,
             '0.Current Period Invoice Amount' expen_cate,
             '0.Current Period Invoice Amount' expen_type,
             trunc(xdn.out_transaction_date) gl_date,
             NULL gl_period_name,
             trunc(xdn.out_transaction_date) gl_date_condition2,
             'THB' currency,
             xdl.quantity,
             round((xdl.quantity * xdl.price), 2),
             round((xdl.quantity * xdl.price), 2)
        FROM apps.xxinv_dely_note_headers_all xdn,
             apps.xxinv_dely_note_lines_all   xdl,
             apps.hr_organization_units       ho,
             apps.pa_projects_all             ppa,
             apps.pa_tasks                    pt,
             apps.pa_tasks                    mfg
       WHERE xdn.org_id = ho.organization_id
         AND xdn.delivery_note_id = xdl.delivery_note_id
         AND xdn.project_id = ppa.project_id
         AND xdn.task_id = pt.task_id
         AND pt.top_task_id = mfg.task_id
         AND pt.project_id = mfg.project_id
         AND ppa.org_id = 84
            
         AND 'SHE_FAC_ORG' = g_org_name
         AND xdn.out_transaction_date <= g_period_date
         AND xdn.out_transaction_date >= g_period_date_from;
  BEGIN
    FOR rec IN cur_invoice LOOP
      insert_tmp(rec.type,
                 rec.org,
                 rec.expenditure_item_id,
                 rec.project_type,
                 rec.project_id,
                 rec.task_id,
                 rec.top_task_id,
                 rec.proj_no,
                 rec.mfg,
                 rec.task,
                 rec.group_parts,
                 rec.expen_cate,
                 rec.expen_type,
                 rec.gl_date,
                 rec.currency_code,
                 rec.quantity,
                 rec.amt,
                 rec.currency_amt);
    END LOOP;
  END;

  PROCEDURE collect_cogs IS
    CURSOR cur_cogs IS
      SELECT xpc.type,
             xpc.org,
             xpc.expenditure_item_id,
             xpc.project_type,
             xpc.project_id,
             xpc.task_id,
             xpc.proj_no,
             xpc.mfg,
             xpc.task,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xpc.task_id) top_task_id,
             xpc.group_parts,
             xpc.expen_cate,
             xpc.expen_type,
             xpc.gl_date,
             xpc.gl_period_name,
             NULL gl_date_condition2,
             xpc.project_currency_code,
             xpc.quantity,
             xpc.amt,
             xpc.currency_amt
        FROM xxpa_project_cogs_v xpc
       WHERE xpc.gl_period_name = g_period
         AND xpc.org = g_org_name;
  BEGIN
    FOR rec IN cur_cogs LOOP
      insert_tmp(rec.type,
                 rec.org,
                 rec.expenditure_item_id,
                 rec.project_type,
                 rec.project_id,
                 rec.task_id,
                 rec.top_task_id,
                 rec.proj_no,
                 rec.mfg,
                 rec.task,
                 rec.group_parts,
                 rec.expen_cate,
                 rec.expen_type,
                 rec.gl_date,
                 rec.project_currency_code,
                 rec.quantity,
                 rec.amt,
                 rec.currency_amt);
    END LOOP;
  END;

  PROCEDURE collect_wip_group IS
    l_last_min_id NUMBER;
    l_last_max_id NUMBER;
  BEGIN
    --
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_his a
       SET a.last_min_id = a.last_max_id,
           a.last_max_id =least(last_max_id+2000000,
           (SELECT MAX(xcd.cost_detail_id) FROM xxpa_cost_flow_dtls_all xcd))
     WHERE a.source_type = 'WIP_GROUP';
  
    SELECT nvl(MAX(a.last_min_id), 0), nvl(MAX(a.last_max_id), 0)
      INTO l_last_min_id, l_last_max_id
      FROM xxpa.xxpa_proj_cogs_mon_rpt3_his a
     WHERE a.source_type = 'WIP_GROUP';
  
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_itm
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt,
       expenditure_category,
       attribute7,
       transaction_id,
       request_id,
       cst_period_date,
       cst_flag,
       org_id,
       update_request_id,
       creation_date,
       last_update_date)
      SELECT /*+ leading(xcfd) use_nl(pei,pt,pa,mfg,pe)*/ 'WIP_GROUP' TYPE,
             hou.name org,
             pei.expenditure_item_id,
             pa.project_type,
             pa.project_id,
             pt.task_id,
             pa.segment1 proj_no,
             mfg.task_number mfg,
             pt.task_number task,
             '' group_parts,
             pet.expenditure_category expen_cate,
             xxpa_proj_cogs_mon_rpt3_pkg.get_expen_type(p_inventory_item_id    => pei.inventory_item_id,
                                                        p_organization_id      => hou.organization_id,
                                                        p_expenditure_type     => pei.expenditure_type,
                                                        p_expenditure_category => pet.expenditure_category) expen_type,
             pei.expenditure_item_date gl_date,
             pei.project_currency_code,
             pei.quantity,
             pei.project_burdened_cost amt,
             pei.project_burdened_cost currency_amt,
             NULL,
             NULL,
             NULL,
             g_request_id request_id,
             (SELECT MIN(transfer_period(xcfd.period_name))--MIN(to_date(xcfd.period_name, 'MON-YY'))--modify by jingjing 2018-02-01
                FROM xxpa_cost_flow_dtls_all xcfd
               WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                 AND xcfd.transfered_pa_flag = 'Y'
                 AND xcfd.source_line_id = pei.expenditure_item_id) cst_period_date,
             CASE
               WHEN (SELECT MIN(transfer_period(xcfd.period_name))--MIN(to_date(xcfd.period_name, 'MON-YY'))--modify by jingjing 2018-02-01
                       FROM xxpa_cost_flow_dtls_all xcfd
                      WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                        AND xcfd.transfered_pa_flag = 'Y'
                        AND xcfd.source_line_id = pei.expenditure_item_id) IS NULL THEN
                'N'
               ELSE
                'Y'
             END cst_flag,
             pei.org_id,
             NULL,
             SYSDATE,
             SYSDATE
        FROM apps.pa_expenditure_items_all pei,
             apps.pa_expenditures_all      pe,
             apps.pa_expenditure_types     pet,
             apps.hr_organization_units    hou,
             apps.pa_projects_all          pa,
             apps.pa_project_types_all     ppt,
             apps.pa_tasks                 pt,
             apps.pa_tasks                 mfg
       WHERE nvl(pei.override_to_organization_id,
                 pe.incurred_by_organization_id) = hou.organization_id
         AND pei.expenditure_id = pe.expenditure_id
         AND pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pei.project_id = pa.project_id
         AND pt.top_task_id = mfg.task_id
         AND pa.project_type = ppt.project_type
         AND pet.expenditure_category != 'FG Completion'
         AND nvl(ppt.attribute7, -1) != 'OVERSEA'
         AND EXISTS
       (SELECT 1
                FROM xxpa_cost_flow_dtls_all xcfd
               WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                 AND xcfd.source_line_id = pei.expenditure_item_id
                 AND xcfd.cost_detail_id > l_last_min_id
                 AND xcfd.cost_detail_id <= l_last_max_id)
         AND NOT EXISTS
       (SELECT 1
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm A
               WHERE A.EXPENDITURE_ITEM_ID = pei.expenditure_item_id
               AND a.type='WIP_GROUP');
    log('collect_wip_group:count1: ' || SQL%ROWCOUNT);
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_itm pei
       SET pei.cst_period_date =
           (SELECT MIN(transfer_period(xcfd.period_name))--MIN(to_date(xcfd.period_name, 'MON-YY'))--modify by jingjing 2018-02-01
              FROM xxpa_cost_flow_dtls_all xcfd
             WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
               AND xcfd.source_line_id = pei.expenditure_item_id
               AND xcfd.transfered_pa_flag = 'Y'),
           update_request_id   = g_request_id,
           last_update_date    = SYSDATE,
           cst_flag = CASE
                        WHEN (SELECT MIN(transfer_period(xcfd.period_name))--MIN(to_date(xcfd.period_name, 'MON-YY'))--modify by jingjing 2018-02-01
                                FROM xxpa_cost_flow_dtls_all xcfd
                               WHERE xcfd.source_table =
                                     'PA_EXPENDITURE_ITEMS_ALL'
                                 AND xcfd.source_line_id =
                                     pei.expenditure_item_id
                                 AND xcfd.transfered_pa_flag = 'Y') IS NULL THEN
                         'N'
                        ELSE
                         'Y'
                      END
     WHERE pei.cst_flag = 'N'
       AND pei.type = 'WIP_GROUP';

    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM (SELECT 'WIP0' TYPE,
                     pei.org,
                     pei.expenditure_item_id,
                     pei.project_type,
                     pei.project_id,
                     pei.task_id,
                     pei.proj_no,
                     pei.mfg,
                     pei.task,
                     pei.group_parts,
                     pei.expen_cate,
                     pei.expen_type,
                     pei.gl_date,
                     pp.gl_period_name,
                     pei.project_currency_code,
                     pei.quantity,
                     pei.amt,
                     pei.currency_amt
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm pei, pa_periods_all pp
               WHERE pei.org_id = pp.org_id
                 AND pei.org = g_org_name
                 AND pp.gl_period_name = g_period
                 AND pei.gl_date <= pp.end_date
                 AND pei.type = 'WIP_GROUP'
                 AND pei.cst_flag = 'Y'
                 AND pei.cst_period_date <= transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/) xccaw--modify by jingjing 2018-02-01
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count_tmp ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group1 IS
    l_last_min_id NUMBER;
    l_last_max_id NUMBER;
  BEGIN
    RETURN; --add by steven.wang@20171121
    --
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_his a
       SET a.last_min_id = a.last_max_id,
           a.last_max_id =
           (SELECT MAX(xcd.cost_detail_id) FROM xxpa_cost_flow_dtls_all xcd)
     WHERE a.source_type = 'WIP_GROUP1';
  
    SELECT nvl(MAX(a.last_min_id), 0), nvl(MAX(a.last_max_id), 0)
      INTO l_last_min_id, l_last_max_id
      FROM xxpa.xxpa_proj_cogs_mon_rpt3_his a
     WHERE a.source_type = 'WIP_GROUP1';
  
    INSERT /*+ append_parallel(c,4)*/
    INTO xxpa.xxpa_proj_cogs_mon_rpt3_itm c --add by steven.wang@20171121
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt,
       expenditure_category,
       attribute7,
       transaction_id,
       request_id,
       cst_period_date,
       cst_flag,
       org_id,
       update_request_id,
       creation_date,
       last_update_date)
      SELECT /*'WIP'*/
       'WIP_GROUP1' TYPE,
       hou.name org,
       pei.expenditure_item_id,
       pa.project_type,
       pa.project_id,
       pt.task_id,
       pa.segment1 proj_no,
       mfg.task_number mfg,
       pt.task_number task,
       '' group_parts,
       pet.expenditure_category expen_cate,
       pei.expenditure_type expen_type,
       pei.expenditure_item_date gl_date,
       pei.project_currency_code,
       pei.quantity,
       pei.project_burdened_cost amt,
       pei.project_burdened_cost currency_amt,
       NULL,
       NULL,
       NULL,
       g_request_id request_id,
       (SELECT min(transfer_period(xcfd.period_name))--MIN(to_date(xcfd.period_name, 'MON-YY'))--modify by jingjing 2018-02-01
          FROM xxpa_cost_flow_dtls_all xcfd
         WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
           AND xcfd.transfered_pa_flag = 'Y'
           AND xcfd.source_line_id = pei.expenditure_item_id) cst_period_date,
       CASE
         WHEN (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
                 FROM xxpa_cost_flow_dtls_all xcfd
                WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                  AND xcfd.transfered_pa_flag = 'Y'
                  AND xcfd.source_line_id = pei.expenditure_item_id) IS NULL THEN
          'N'
         ELSE
          'Y'
       END cst_flag,
       pei.org_id,
       NULL,
       SYSDATE,
       SYSDATE
        FROM apps.pa_expenditure_items_all pei,
             apps.pa_expenditures_all      pe,
             apps.pa_expenditure_types     pet,
             apps.hr_organization_units    hou,
             apps.pa_projects_all          pa,
             apps.pa_project_types_all     ppt,
             apps.pa_tasks                 pt,
             apps.pa_tasks                 mfg
       WHERE nvl(pei.override_to_organization_id,
                 pe.incurred_by_organization_id) = hou.organization_id
         AND pei.expenditure_id = pe.expenditure_id
         AND pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pei.project_id = pa.project_id
         AND pt.top_task_id = mfg.task_id
         AND pa.project_type = ppt.project_type
         AND pet.expenditure_category != 'FG Completion'
         AND nvl(ppt.attribute7, -1) = 'OVERSEA'
         AND NOT EXISTS
       (SELECT 1
                FROM xxpa_proj_cogs_mon_expect_v /*20170130 xxpa_oversea_expect_v*/ xoe
               WHERE xoe.expenditure_item_id = pei.expenditure_item_id)
         AND pei.expenditure_item_id IN
             (SELECT xcfd.source_line_id
                FROM xxpa_cost_flow_dtls_all xcfd
               WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                    --AND xcfd.source_line_id = pei.expenditure_item_id --add by steven.wang@20171121
                 AND xcfd.cost_detail_id > l_last_min_id
                 AND xcfd.cost_detail_id <= l_last_max_id);
  
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_itm pei
       SET pei.cst_period_date =
           (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
              FROM xxpa_cost_flow_dtls_all xcfd
             WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
               AND xcfd.source_line_id = pei.expenditure_item_id
               AND xcfd.transfered_pa_flag = 'Y'),
           update_request_id   = g_request_id,
           last_update_date    = SYSDATE,
           cst_flag = CASE
                        WHEN (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
                                FROM xxpa_cost_flow_dtls_all xcfd
                               WHERE xcfd.source_table =
                                     'PA_EXPENDITURE_ITEMS_ALL'
                                 AND xcfd.source_line_id =
                                     pei.expenditure_item_id
                                 AND xcfd.transfered_pa_flag = 'Y') IS NULL THEN
                         'N'
                        ELSE
                         'Y'
                      END
     WHERE pei.cst_flag = 'N'
       AND pei.type = 'WIP_GROUP1';
  
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             (SELECT 'WIP1' TYPE,
                     pei.org,
                     pei.expenditure_item_id,
                     pei.project_type,
                     pei.project_id,
                     pei.task_id,
                     pei.proj_no,
                     pei.mfg,
                     pei.task,
                     pei.group_parts,
                     pei.expen_cate,
                     pei.expen_type,
                     pei.gl_date,
                     pp.gl_period_name,
                     pei.project_currency_code,
                     pei.quantity,
                     pei.amt,
                     pei.currency_amt
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm pei, pa_periods_all pp
               WHERE pei.org_id = pp.org_id
                 AND pei.org = g_org_name
                 AND pp.gl_period_name = g_period
                 AND pei.gl_date <= pp.end_date
                 AND pei.type = 'WIP_GROUP1'
                 AND pei.cst_flag = 'Y'
                 AND NOT EXISTS
               (SELECT 1
                        FROM xxpa_proj_cogs_mon_expect_v /* 20170130 xxpa_oversea_expect_v*/ xoe
                       WHERE xoe.expenditure_item_id =
                             pei.expenditure_item_id)
                 AND pei.cst_period_date <= transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/) xccaw--modify by jingjing 2018-02-01
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group2 IS
    l_last_min_id NUMBER;
    l_last_max_id NUMBER;
  BEGIN
    --
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_his a
       SET a.last_min_id = a.last_max_id,
           a.last_max_id =least(last_max_id+2000000,
           (SELECT MAX(xcd.expenditure_item_id)
              FROM pa_expenditure_items_all xcd))
     WHERE a.source_type = 'WIP_GROUP2';
    SELECT nvl(MAX(a.last_min_id), 0), nvl(MAX(a.last_max_id), 0)
      INTO l_last_min_id, l_last_max_id
      FROM xxpa.xxpa_proj_cogs_mon_rpt3_his a
     WHERE a.source_type = 'WIP_GROUP2';
    --/*+ append_parallel(c,4)*/
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_itm c
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt,
       expenditure_category,
       attribute7,
       transaction_id,
       request_id,
       cst_period_date,
       cst_flag,
       org_id,
       update_request_id,
       creation_date,
       last_update_date)
      SELECT /*+ leading(pei) use_nl(pei,pe,mmt,wdj,we,pa,pet,pt)*/
       'WIP_GROUP2' TYPE,
       hou.name org,
       pei.expenditure_item_id,
       pa.project_type,
       pa.project_id,
       pt.task_id,
       pa.segment1 proj_no,
       mfg.task_number mfg,
       pt.task_number task,
       msc.category_concat_segs group_parts,
       pet.expenditure_category expen_cate,
       pei.expenditure_type expen_type,
       pei.expenditure_item_date gl_date,
       pei.project_currency_code,
       pei.quantity,
       pei.project_burdened_cost amt,
       pei.project_burdened_cost currency_amt,
       pet.expenditure_category,
       nvl(ppt.attribute7, -1) attribute7,
       mmt.transaction_id,
       g_request_id request_id,
       (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
          FROM xxpa_cost_flow_dtls_all xcfd, mtl_transaction_accounts mta
         WHERE xcfd.source_table = 'MTL_TRANSACTION_ACCOUNTS'
           AND xcfd.source_line_id = mta.inv_sub_ledger_id
           AND xcfd.transfered_pa_flag = 'Y'
           AND mmt.transaction_id = mta.transaction_id) cst_period_date,
       CASE
         WHEN (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
                 FROM xxpa_cost_flow_dtls_all  xcfd,
                      mtl_transaction_accounts mta
                WHERE xcfd.source_table = 'MTL_TRANSACTION_ACCOUNTS'
                  AND xcfd.source_line_id = mta.inv_sub_ledger_id
                  AND xcfd.transfered_pa_flag = 'Y'
                  AND mmt.transaction_id = mta.transaction_id) IS NULL THEN
          'N'
         ELSE
          'Y'
       END cst_flag,
       pa.org_id,
       NULL,
       SYSDATE,
       SYSDATE
        FROM apps.pa_expenditure_items_all  pei,
             apps.pa_expenditures_all       pe,
             apps.pa_expenditure_types      pet,
             apps.hr_organization_units     hou,
             apps.pa_projects_all           pa,
             apps.pa_project_types_all      ppt,
             apps.pa_tasks                  pt,
             apps.pa_tasks                  mfg,
             apps.mtl_material_transactions mmt,
             apps.wip_entities              we,
             apps.mtl_item_categories_v     msc,
             apps.wip_discrete_jobs         wdj
       WHERE pet.expenditure_category != 'FG Completion'
         AND nvl(pei.override_to_organization_id,
                 pe.incurred_by_organization_id) = hou.organization_id
         AND pei.expenditure_id = pe.expenditure_id
         AND pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pei.project_id = pa.project_id
         AND pt.top_task_id = mfg.task_id
         AND pa.project_type = ppt.project_type
         AND pei.transaction_source = 'Inventory'
         AND nvl(ppt.attribute7, -1) = 'OVERSEA'
         AND pei.orig_transaction_reference = mmt.transaction_id
         AND mmt.organization_id = hou.organization_id
         AND msc.inventory_item_id = wdj.primary_item_id
         AND msc.organization_id = wdj.organization_id
         AND msc.category_set_name = 'GSCM Item Category Set'
         AND mmt.organization_id = hou.organization_id
         AND mmt.transaction_source_id = wdj.wip_entity_id
         AND wdj.wip_entity_id = we.wip_entity_id
         AND wdj.project_id = /*pa --modify by steven.wang@20171123*/
             pei.project_id
         AND wdj.task_id = /*pa --modify by steven.wang@20171123*/
             pei.task_id
         AND pei.expenditure_item_id > l_last_min_id
         AND pei.expenditure_item_id <= l_last_max_id;
    log('collect_wip_group2:count1: ' || SQL%ROWCOUNT);
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_itm pei
       SET pei.cst_period_date =
           (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
              FROM xxpa_cost_flow_dtls_all  xcfd,
                   mtl_transaction_accounts mta
             WHERE xcfd.source_table = 'MTL_TRANSACTION_ACCOUNTS'
               AND xcfd.source_line_id = mta.inv_sub_ledger_id
               AND xcfd.transfered_pa_flag = 'Y'
               AND pei.transaction_id = mta.transaction_id),
           update_request_id   = g_request_id,
           last_update_date    = SYSDATE,
           cst_flag            = 'Y'
     WHERE pei.cst_flag = 'N'
       AND pei.type = 'WIP_GROUP2'
       AND EXISTS
     (SELECT 1
              FROM xxpa_cost_flow_dtls_all  xcfd,
                   mtl_transaction_accounts mta
             WHERE xcfd.source_table = 'MTL_TRANSACTION_ACCOUNTS'
               AND xcfd.source_line_id = mta.inv_sub_ledger_id
               AND xcfd.transfered_pa_flag = 'Y'
               AND pei.transaction_id = mta.transaction_id
               AND ROWNUM = 1 /*--add by steven.wang@20171123*/
            );

    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             (SELECT 'WIP2' TYPE,
                     pei.org,
                     pei.expenditure_item_id,
                     pei.project_type,
                     pei.project_id,
                     pei.task_id,
                     pei.proj_no,
                     pei.mfg,
                     pei.task,
                     pei.group_parts,
                     pei.expen_cate,
                     pei.expen_type,
                     pei.gl_date,
                     pp.gl_period_name,
                     pei.project_currency_code,
                     pei.quantity,
                     pei.amt,
                     pei.currency_amt
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm pei, pa_periods_all pp
               WHERE pei.org_id = pp.org_id
                 AND pei.org = g_org_name
                 AND pp.gl_period_name = g_period
                    --AND pei.request_id=g_request_id
                 AND pei.cst_flag = 'Y'
                 AND pei.type = 'WIP_GROUP2'
                 AND pei.gl_date <= pp.end_date
                 AND pei.cst_period_date <= transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/) xccaw--modify by jingjing 2018-02-01
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END collect_wip_group2;
  PROCEDURE collect_wip_group3 IS
    l_last_min_id NUMBER;
    l_last_max_id NUMBER;
  BEGIN
  
    --
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_his a
       SET a.last_min_id = a.last_max_id,
           a.last_max_id =least(last_max_id+2000000,
           (SELECT MAX(xcd.cost_detail_id) FROM xxpa_cost_flow_dtls_all xcd))
     WHERE a.source_type = 'WIP_GROUP3';
  
    SELECT nvl(MAX(a.last_min_id), 0), nvl(MAX(a.last_max_id), 0)
      INTO l_last_min_id, l_last_max_id
      FROM xxpa.xxpa_proj_cogs_mon_rpt3_his a
     WHERE a.source_type = 'WIP_GROUP3';
    --/*+ append_parallel(c,4)*/
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_itm c --add by steven.wang@20171121
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt,
       expenditure_category,
       attribute7,
       transaction_id,
       request_id,
       cst_period_date,
       cst_flag,
       org_id,
       update_request_id,
       creation_date,
       last_update_date)
      SELECT /*+ leading(xcfd) use_nl(pei,wt)*/ --add by steven.wang@20171121
       'WIP_GROUP3' TYPE,
       hou.name org,
       pei.expenditure_item_id,
       ppa.project_type,
       ppa.project_id,
       pt.task_id,
       ppa.segment1 proj_no,
       mfg.task_number mfg,
       pt.task_number task,
       msc.category_concat_segs group_parts,
       pet.expenditure_category expen_cate,
       pei.expenditure_type expen_type,
       pei.expenditure_item_date gl_date,
       
       pei.project_currency_code,
       pei.quantity,
       pei.project_burdened_cost amt,
       pei.project_burdened_cost currency_amt,
       NULL,
       NULL,
       NULL,
       g_request_id request_id,
       (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
          FROM xxpa_cost_flow_dtls_all xcfd
         WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
           AND xcfd.transfered_pa_flag = 'Y'
           AND xcfd.source_line_id = pei.expenditure_item_id) cst_period_date,
       CASE
         WHEN (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
                 FROM xxpa_cost_flow_dtls_all xcfd
                WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                  AND xcfd.transfered_pa_flag = 'Y'
                  AND xcfd.source_line_id = pei.expenditure_item_id) IS NULL THEN
          'N'
         ELSE
          'Y'
       END cst_flag,
       pei.org_id,
       NULL,
       SYSDATE,
       SYSDATE
        FROM apps.wip_transactions         wt,
             apps.pa_expenditure_items_all pei,
             apps.hr_organization_units    hou,
             apps.pa_projects_all          ppa,
             apps.pa_project_types_all     ppt,
             apps.pa_tasks                 pt,
             apps.pa_tasks                 mfg,
             apps.mtl_item_categories_v    msc,
             apps.pa_expenditure_types     pet,
             apps.wip_discrete_jobs        wdj /*,
                                           apps.wip_entities             we -- --modified by steven.wang@20171214 */
       WHERE 1 = 1
         AND wt.transaction_id = pei.orig_transaction_reference
         AND pei.transaction_source = 'Work In Process'
         AND wt.project_id = pei.project_id
         AND wt.task_id = pei.task_id
         AND wt.organization_id = hou.organization_id
         AND pei.project_id = ppa.project_id
         AND ppa.project_type = ppt.project_type
         AND pet.expenditure_category != 'FG Completion'
         AND ppt.attribute7 = 'OVERSEA'
         AND pei.task_id = pt.task_id
         AND pt.top_task_id = mfg.task_id
         AND wt.wip_entity_id = wdj.wip_entity_id
         AND wt.organization_id = wdj.organization_id
         AND msc.inventory_item_id = wdj.primary_item_id
         AND msc.organization_id = wdj.organization_id
         AND msc.category_set_name = 'GSCM Item Category Set'
         AND pei.expenditure_type = pet.expenditure_type
            /*  AND wt.wip_entity_id = we.wip_entity_id -- --modified by steven.wang@20171214*/
         AND pei.expenditure_item_id IN
             (SELECT xcfd.source_line_id
                FROM xxpa_cost_flow_dtls_all xcfd
               WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                    -- AND xcfd.source_line_id = pei.expenditure_item_id
                 AND xcfd.cost_detail_id > l_last_min_id
                 AND xcfd.cost_detail_id <= l_last_max_id)
         AND NOT EXISTS
       (SELECT 1
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm A
               WHERE A.EXPENDITURE_ITEM_ID = pei.expenditure_item_id
               AND a.type='WIP_GROUP3');
    log('collect_wip_group:count3: ' || SQL%ROWCOUNT);
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_itm pei
       SET pei.cst_period_date =
           (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
              FROM xxpa_cost_flow_dtls_all xcfd
             WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
               AND xcfd.source_line_id = pei.expenditure_item_id
               AND xcfd.transfered_pa_flag = 'Y'),
           update_request_id   = g_request_id,
           last_update_date    = SYSDATE,
           cst_flag = CASE
                        WHEN (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
                                FROM xxpa_cost_flow_dtls_all xcfd
                               WHERE xcfd.source_table =
                                     'PA_EXPENDITURE_ITEMS_ALL'
                                 AND xcfd.source_line_id =
                                     pei.expenditure_item_id
                                 AND xcfd.transfered_pa_flag = 'Y') IS NULL THEN
                         'N'
                        ELSE
                         'Y'
                      END
     WHERE pei.cst_flag = 'N'
       AND pei.type = 'WIP_GROUP3';

    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              SELECT 'WIP3' TYPE,
                      pei.org,
                      pei.expenditure_item_id,
                      pei.project_type,
                      pei.project_id,
                      pei.task_id,
                      pei.proj_no,
                      pei.mfg,
                      pei.task,
                      pei.group_parts,
                      pei.expen_cate,
                      pei.expen_type,
                      pei.gl_date,
                      pp.gl_period_name,
                      pei.project_currency_code,
                      pei.quantity,
                      pei.amt,
                      pei.currency_amt
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm pei, pa_periods_all pp
               WHERE 1 = 1
                 AND pei.org_id = pp.org_id
                 AND pei.org = g_org_name
                 AND pp.gl_period_name = g_period
                 AND pei.cst_flag = 'Y'
                 AND pei.type = 'WIP_GROUP3'
                 AND pei.gl_date <= pp.end_date
                 AND pei.cst_period_date <= transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/) xccaw--modify by jingjing 2018-02-01
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group4 IS
    l_last_min_id NUMBER;
    l_last_max_id NUMBER;
  BEGIN
  
    --
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_his a
       SET a.last_min_id = a.last_max_id,
           a.last_max_id =least(last_max_id+2000000,
           (SELECT MAX(xcd.cost_detail_id) FROM xxpa_cost_flow_dtls_all xcd))
     WHERE a.source_type = 'WIP_GROUP4';
  
    SELECT nvl(MAX(a.last_min_id), 0), nvl(MAX(a.last_max_id), 0)
      INTO l_last_min_id, l_last_max_id
      FROM xxpa.xxpa_proj_cogs_mon_rpt3_his a
     WHERE a.source_type = 'WIP_GROUP4';
    --/*+ append_parallel(c,4)*/
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_itm c
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt,
       expenditure_category,
       attribute7,
       transaction_id,
       request_id,
       cst_period_date,
       cst_flag,
       org_id,
       update_request_id,
       creation_date,
       last_update_date)
      SELECT /*+ leading(xcfd) use_nl(pei,pt,pa,mfg,pe)*/
       'WIP_GROUP4' TYPE,
       hou.name org,
       pei.expenditure_item_id,
       pa.project_type,
       pa.project_id,
       pt.task_id,
       pa.segment1 proj_no,
       mfg.task_number mfg,
       pt.task_number task,
       pei.attribute9 group_parts,
       pet.expenditure_category expen_cate,
       pei.expenditure_type expen_type,
       pei.expenditure_item_date gl_date,
       
       pei.project_currency_code,
       pei.quantity,
       pei.project_burdened_cost amt,
       pei.project_burdened_cost currency_amt,
       NULL,
       NULL,
       NULL,
       g_request_id request_id,
       (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
          FROM xxpa_cost_flow_dtls_all xcfd
         WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
           AND xcfd.transfered_pa_flag = 'Y'
           AND xcfd.source_line_id = pei.expenditure_item_id) cst_period_date,
       CASE
         WHEN (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
                 FROM xxpa_cost_flow_dtls_all xcfd
                WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                  AND xcfd.transfered_pa_flag = 'Y'
                  AND xcfd.source_line_id = pei.expenditure_item_id) IS NULL THEN
          'N'
         ELSE
          'Y'
       END cst_flag,
       pei.org_id,
       NULL,
       SYSDATE,
       SYSDATE
      
        FROM apps.pa_expenditure_items_all pei,
             apps.pa_expenditures_all      pe,
             apps.pa_expenditure_types     pet,
             apps.hr_organization_units    hou,
             apps.pa_projects_all          pa,
             apps.pa_project_types_all     ppt,
             apps.pa_tasks                 pt,
             apps.pa_tasks                 mfg
       WHERE nvl(pei.override_to_organization_id,
                 pe.incurred_by_organization_id) = hou.organization_id
         AND pei.expenditure_id = pe.expenditure_id
         AND pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pei.project_id = pa.project_id
         AND pt.top_task_id = mfg.task_id
         AND pa.project_type = ppt.project_type
         AND pet.expenditure_category != 'FG Completion'
         AND nvl(ppt.attribute7, -1) = 'OVERSEA'
         AND pei.system_linkage_function = 'PJ'
         AND EXISTS
       (SELECT 1
                FROM xxpa_cost_flow_dtls_all xcfd
               WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                 AND xcfd.source_line_id = pei.expenditure_item_id
                 AND xcfd.cost_detail_id > l_last_min_id
                 AND xcfd.cost_detail_id <= l_last_max_id)
         AND NOT EXISTS
       (SELECT 1
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm A
               WHERE A.EXPENDITURE_ITEM_ID = pei.expenditure_item_id
               AND a.type='WIP_GROUP4');
    log('collect_wip_group:count4: ' || SQL%ROWCOUNT);
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_itm pei
       SET pei.cst_period_date =
           (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
              FROM xxpa_cost_flow_dtls_all xcfd
             WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
               AND xcfd.source_line_id = pei.expenditure_item_id
               AND xcfd.transfered_pa_flag = 'Y'),
           update_request_id   = g_request_id,
           last_update_date    = SYSDATE,
           cst_flag = CASE
                        WHEN (SELECT min(transfer_period(xcfd.period_name))/*MIN(to_date(xcfd.period_name, 'MON-YY'))*/--modify by jingjing 2018-02-01
                                FROM xxpa_cost_flow_dtls_all xcfd
                               WHERE xcfd.source_table =
                                     'PA_EXPENDITURE_ITEMS_ALL'
                                 AND xcfd.source_line_id =
                                     pei.expenditure_item_id
                                 AND xcfd.transfered_pa_flag = 'Y') IS NULL THEN
                         'N'
                        ELSE
                         'Y'
                      END
     WHERE pei.cst_flag = 'N'
       AND pei.type = 'WIP_GROUP4';
   INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              SELECT 'WIP4' TYPE,
                      pei.org,
                      pei.expenditure_item_id,
                      pei.project_type,
                      pei.project_id,
                      pei.task_id,
                      pei.proj_no,
                      pei.mfg,
                      pei.task,
                      pei.group_parts,
                      pei.expen_cate,
                      pei.expen_type,
                      pei.gl_date,
                      pp.gl_period_name,
                      pei.project_currency_code,
                      pei.quantity,
                      pei.amt,
                      pei.currency_amt
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm pei, pa_periods_all pp
               WHERE pei.org_id = pp.org_id
                 AND pei.org = g_org_name
                 AND pp.gl_period_name = g_period
                 AND pei.gl_date <= pp.end_date
                 AND pei.cst_period_date <= transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/--modify by jingjing 2018-02-01
                 AND pei.cst_flag = 'Y'
                 AND pei.type = 'WIP_GROUP4') xccaw
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group5 IS
  BEGIN
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              ---AP INVOICE RELATED PO THAT HAVING MARK GROUP PARTS
              SELECT 'WIP5' TYPE,
                      ho.name org,
                      ei.expenditure_item_id,
                      p.project_type,
                      p.project_id,
                      t.task_id,
                      p.segment1 proj_no,
                      t1.task_number mfg,
                      t.task_number task,
                      pda.attribute15 group_parts,
                      pet.expenditure_category expen_cate,
                      ei.expenditure_type expen_type,
                      ei.expenditure_item_date gl_date,
                      pp.gl_period_name,
                      ei.project_currency_code,
                      ei.quantity,
                      ei.project_burdened_cost amt,
                      ei.project_burdened_cost currency_amt
                FROM apps.pa_projects_all              p,
                      apps.pa_tasks                     t,
                      apps.pa_expenditure_items_all     ei,
                      apps.pa_expenditures_all          x,
                      apps.pa_expenditure_types         pet,
                      apps.pa_project_types_all         pt,
                      apps.hr_all_organization_units    ho,
                      apps.pa_tasks                     t1,
                      apps.ap_invoice_distributions_all aid,
                      apps.po_distributions_all         pda,
                      pa_periods_all                    pp
               WHERE 1 = 1
                 AND t.project_id = p.project_id
                 AND p.project_id = t1.project_id
                 AND t.top_task_id = t1.task_id
                 AND ei.project_id = p.project_id
                 AND ei.task_id = t.task_id
                 AND ei.expenditure_type = pet.expenditure_type
                 AND p.project_type = pt.project_type
                 AND nvl(pt.attribute7, '-1') = 'OVERSEA'
                 AND pet.expenditure_category != 'FG Completion'
                 AND ei.expenditure_id = x.expenditure_id
                 AND ei.system_linkage_function = 'VI' --Supplier Invoices
                 AND ei.document_distribution_id =
                     aid.invoice_distribution_id
                 AND aid.po_distribution_id = pda.po_distribution_id
                 AND pda.destination_type_code = 'EXPENSE'
                 AND pda.req_distribution_id IS NULL
                 AND nvl(ei.override_to_organization_id,
                         x.incurred_by_organization_id) = ho.organization_id
                 AND p.org_id = pp.org_id
                 AND ho.name = g_org_name
                 AND pp.gl_period_name = g_period
                 AND ei.expenditure_item_date <= pp.end_date
                 AND EXISTS
               (SELECT 1
                        FROM xxpa_cost_flow_dtls_all xcfd
                       WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                         AND xcfd.source_line_id = ei.expenditure_item_id
                            --modify by gusenlin 2013-04-10 start
                         AND xcfd.transfered_pa_flag = 'Y'
                            --modify by gusenlin 2013-04-10 end
                         AND transfer_period(xcfd.period_name)/*to_date(xcfd.period_name, 'MON-YY')*/ <=
                             transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/)) xccaw--modify by jingjing 2018-02-01
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group6 IS
  BEGIN
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              SELECT 'WIP6' TYPE,
                      ho.name org,
                      ei.expenditure_item_id,
                      p.project_type,
                      p.project_id,
                      t.task_id,
                      p.segment1 proj_no,
                      t1.task_number mfg,
                      t.task_number task
                      --modify by gusenlin 2013-03-06
                      --,prl.attribute1 group_parts
                      --if po has pr ,first catch pr dff ,if pr dff is null, catch pod dff
                     ,
                      nvl(prl.attribute1, pda.attribute15) group_parts
                      --end
                     ,
                      pet.expenditure_category expen_cate,
                      ei.expenditure_type      expen_type,
                      ei.expenditure_item_date gl_date,
                      pp.gl_period_name,
                      ei.project_currency_code,
                      ei.quantity,
                      ei.project_burdened_cost amt,
                      ei.project_burdened_cost currency_amt
                FROM pa_projects_all              p,
                      pa_tasks                     t,
                      pa_expenditure_items_all     ei,
                      pa_expenditures_all          x,
                      pa_expenditure_types         pet,
                      pa_project_types_all         pt,
                      hr_all_organization_units    ho,
                      pa_tasks                     t1,
                      ap_invoice_distributions_all aid,
                      po_distributions_all         pda,
                      po_req_distributions_all     prd,
                      po_requisition_lines_all     prl,
                      pa_periods_all               pp
               WHERE 1 = 1
                 AND pt.org_id = p.org_id
                 AND t.project_id = p.project_id
                 AND p.project_id = t1.project_id
                 AND t.top_task_id = t1.task_id
                 AND ei.project_id = p.project_id
                 AND ei.task_id = t.task_id
                 AND p.project_type = pt.project_type
                 AND nvl(pt.attribute7, '-1') = 'OVERSEA'
                 AND pet.expenditure_category != 'FG Completion'
                 AND ei.expenditure_id = x.expenditure_id
                 AND ei.system_linkage_function = 'VI' --Supplier Invoices
                 AND ei.document_distribution_id =
                     aid.invoice_distribution_id
                 AND aid.po_distribution_id = pda.po_distribution_id
                 AND pda.req_distribution_id = prd.distribution_id
                 AND prd.requisition_line_id = prl.requisition_line_id
                 AND pda.destination_type_code = 'EXPENSE'
                    --AND prl.attribute1 = pet.attribute15
                 AND ei.expenditure_type = pet.expenditure_type
                 AND nvl(ei.override_to_organization_id,
                         x.incurred_by_organization_id) = ho.organization_id
                 AND p.org_id = pp.org_id
                 AND ho.name = g_org_name
                 AND pp.gl_period_name = g_period
                 AND ei.expenditure_item_date <= pp.end_date
                 AND EXISTS
               (SELECT 1
                        FROM xxpa_cost_flow_dtls_all xcfd
                       WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                         AND xcfd.source_line_id = ei.expenditure_item_id
                            --modify by gusenlin 2013-04-10 start
                         AND xcfd.transfered_pa_flag = 'Y'
                            --modify by gusenlin 2013-04-10 end
                         AND transfer_period(xcfd.period_name)/*to_date(xcfd.period_name, 'MON-YY')*/ <=
                             transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/)) xccaw
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group7 IS
  BEGIN
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              SELECT 'WIP7' TYPE,
                      hou.name org,
                      pei.expenditure_item_id,
                      pa.project_type,
                      pa.project_id,
                      pt.task_id,
                      pa.segment1 proj_no,
                      mfg.task_number mfg,
                      pt.task_number task,
                      ool.attribute5 group_parts,
                      pet.expenditure_category expen_cate,
                      pei.expenditure_type expen_type,
                      pei.expenditure_item_date gl_date,
                      pp.gl_period_name,
                      pei.project_currency_code,
                      pei.quantity,
                      pei.project_burdened_cost amt,
                      pei.project_burdened_cost currency_amt
                FROM apps.pa_expenditure_items_all  pei,
                      apps.pa_expenditures_all       pe,
                      apps.pa_expenditure_types      pet,
                      apps.hr_organization_units     hou,
                      apps.pa_projects_all           pa,
                      apps.pa_project_types_all      ppt,
                      apps.pa_tasks                  pt,
                      apps.pa_tasks                  mfg,
                      apps.mtl_material_transactions mmt,
                      apps.oe_order_lines_all        ool,
                      pa_periods_all                 pp
               WHERE nvl(pei.override_to_organization_id,
                         pe.incurred_by_organization_id) =
                     hou.organization_id
                 AND pei.expenditure_id = pe.expenditure_id
                 AND pei.expenditure_type = pet.expenditure_type
                 AND pei.task_id = pt.task_id
                 AND pei.project_id = pa.project_id
                 AND pt.top_task_id = mfg.task_id
                 AND pa.project_type = ppt.project_type
                 AND pet.expenditure_category != 'FG Completion'
                 AND nvl(ppt.attribute7, -1) = 'OVERSEA'
                 AND pei.transaction_source = 'Inventory'
                 AND pei.orig_transaction_reference = mmt.transaction_id
                 AND mmt.transaction_type_id = 52 --Sales Order Pick
                 AND mmt.organization_id = hou.organization_id
                 AND mmt.trx_source_line_id = ool.line_id
                 AND ool.project_id = pa.project_id
                 AND ool.task_id = pt.task_id
                 AND pa.org_id = pp.org_id
                 AND hou.name = g_org_name
                 AND pp.gl_period_name = g_period
                 AND pei.expenditure_item_date <= pp.end_date
                 AND EXISTS
               (SELECT 1
                        FROM xxpa_cost_flow_dtls_all xcfd
                       WHERE xcfd.source_table = 'MTL_MATERIAL_TRANSACTIONS'
                         AND xcfd.source_line_id = mmt.transfer_transaction_id
                            --modify by gusenlin 2013-04-10 start
                         AND xcfd.transfered_pa_flag = 'Y'
                            --modify by gusenlin 2013-04-10 end
                         AND transfer_period(xcfd.period_name)/*to_date(xcfd.period_name, 'MON-YY')*/ <=
                             transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/)) xccaw--modify by jingjing 2018-02-01
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group8 IS
  BEGIN
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              --sales pick
              SELECT 'WIP8' TYPE,
                      hou.name org,
                      pei.expenditure_item_id,
                      pa.project_type,
                      pa.project_id,
                      pt.task_id,
                      pa.segment1 proj_no,
                      mfg.task_number mfg,
                      pt.task_number task,
                      ool.attribute5 group_parts,
                      pet.expenditure_category expen_cate,
                      pei.expenditure_type expen_type,
                      pei.expenditure_item_date gl_date,
                      pp.gl_period_name,
                      pei.project_currency_code,
                      pei.quantity,
                      pei.project_burdened_cost amt,
                      pei.project_burdened_cost currency_amt
                FROM apps.pa_expenditure_items_all  pei,
                      apps.pa_expenditures_all       pe,
                      apps.pa_expenditure_types      pet,
                      apps.hr_organization_units     hou,
                      apps.pa_projects_all           pa,
                      apps.pa_project_types_all      ppt,
                      apps.pa_tasks                  pt,
                      apps.pa_tasks                  mfg,
                      apps.mtl_material_transactions mmt,
                      apps.oe_order_lines_all        ool,
                      pa_periods_all                 pp
               WHERE nvl(pei.override_to_organization_id,
                         pe.incurred_by_organization_id) =
                     hou.organization_id
                 AND pei.expenditure_id = pe.expenditure_id
                 AND pei.expenditure_type = pet.expenditure_type
                 AND pei.task_id = pt.task_id
                 AND pei.project_id = pa.project_id
                 AND pt.top_task_id = mfg.task_id
                 AND pa.project_type = ppt.project_type
                 AND pet.expenditure_category != 'FG Completion'
                 AND nvl(ppt.attribute7, -1) = 'OVERSEA'
                 AND pei.transaction_source = 'Inventory'
                 AND pei.orig_transaction_reference = mmt.transaction_id
                 AND mmt.transaction_type_id = 52 --Sales Order Pick
                 AND mmt.organization_id = hou.organization_id
                 AND mmt.trx_source_line_id = ool.line_id
                 AND ool.project_id = pa.project_id
                 AND ool.task_id = pt.task_id
                 AND pa.org_id = pp.org_id
                 AND hou.name = g_org_name
                 AND pp.gl_period_name = g_period
                 AND pei.expenditure_item_date <= pp.end_date
                 AND EXISTS
               (SELECT 1
                        FROM xxpa_cost_flow_dtls_all xcfd
                       WHERE xcfd.source_table = 'MTL_MATERIAL_TRANSACTIONS'
                         AND xcfd.source_line_id = mmt.transaction_id
                            --modify by gusenlin 2013-04-10 start
                         AND xcfd.transfered_pa_flag = 'Y'
                            --modify by gusenlin 2013-04-10 end
                         AND transfer_period(xcfd.period_name)/*to_date(xcfd.period_name, 'MON-YY')*/ <=
                             transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/)) xccaw--modify by jingjing 2018-02-01
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group9 IS
  BEGIN
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              --sales pick
              --Design Hours
              SELECT 'WIP9' TYPE,
                      hou.name org,
                      pei.expenditure_item_id,
                      pa.project_type,
                      pa.project_id,
                      pt.task_id,
                      pa.segment1 proj_no,
                      mfg.task_number mfg,
                      pt.task_number task,
                      decode(ppt.attribute7,
                             'OVERSEA',
                             decode(pei.transaction_source,
                                    'Work In Process',
                                    (SELECT msc.category_concat_segs
                                       FROM mtl_item_categories_v msc,
                                            wip_transactions      wt,
                                            wip_discrete_jobs     wdj
                                      WHERE pei.transaction_source =
                                            'Work In Process'
                                        AND pei.orig_transaction_reference =
                                            wt.transaction_id
                                        AND wt.wip_entity_id = wdj.wip_entity_id
                                        AND wt.organization_id =
                                            wdj.organization_id
                                        AND msc.inventory_item_id =
                                            wdj.primary_item_id
                                        AND msc.organization_id =
                                            wdj.organization_id
                                        AND msc.category_set_name =
                                            'GSCM Item Category Set'),
                                    pei.attribute9)) group_parts,
                      'Z1.' || pet.expenditure_category expen_cate,
                      decode(pei.expenditure_type,
                             'Prod. Direct Labour',
                             'Z1.Prod. Hours',
                             'FAC - DES Overhead',
                             'Z1.DES Hours',
                             'DES Overhead',
                             'Z1.DES Hours') expen_type,
                      pei.expenditure_item_date gl_date,
                      pp.gl_period_name,
                      pei.project_currency_code,
                      pei.quantity,
                      pei.quantity amt,
                      pei.quantity currency_amt
                FROM apps.pa_expenditure_items_all pei,
                      apps.pa_expenditures_all      pe,
                      apps.pa_expenditure_types     pet,
                      apps.hr_organization_units    hou,
                      apps.pa_projects_all          pa,
                      apps.pa_project_types_all     ppt,
                      apps.pa_tasks                 pt,
                      apps.pa_tasks                 mfg,
                      pa_periods_all                pp
               WHERE nvl(pei.override_to_organization_id,
                         pe.incurred_by_organization_id) =
                     hou.organization_id
                 AND pei.expenditure_id = pe.expenditure_id
                 AND pei.expenditure_type = pet.expenditure_type
                 AND pei.task_id = pt.task_id
                 AND pei.project_id = pa.project_id
                 AND pt.top_task_id = mfg.task_id
                 AND pa.project_type = ppt.project_type
                 AND pet.expenditure_type IN
                     ('Prod. Direct Labour',
                      'FAC - DES Overhead',
                      'DES Overhead')
                 AND pa.org_id = pp.org_id
                 AND hou.name = g_org_name
                 AND pp.gl_period_name = g_period
                 AND pei.expenditure_item_date <= pp.end_date
                 AND EXISTS
               (SELECT 1
                        FROM xxpa_cost_flow_dtls_all xcfd
                       WHERE xcfd.source_table = 'PA_EXPENDITURE_ITEMS_ALL'
                         AND xcfd.source_line_id = pei.expenditure_item_id
                            --modify by gusenlin 2013-04-10 start
                         AND xcfd.transfered_pa_flag = 'Y'
                            --modify by gusenlin 2013-04-10 end
                         AND xcfd.expenditure_item_date <= pp.end_date)) xccaw
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;
  PROCEDURE collect_wip_group10 IS
  BEGIN
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT xccaw.type,
             xccaw.org,
             NULL expenditure_item_id,
             xccaw.project_type,
             xccaw.project_id,
             xccaw.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id) top_task_id,
             xccaw.proj_no,
             xccaw.mfg,
             xccaw.task,
             xccaw.group_parts,
             xccaw.expen_cate,
             xccaw.expen_type,
             NULL gl_date,
             xccaw.project_currency_code,
             NULL quantity,
             SUM(round(xccaw.amt, g_round)) amt,
             SUM(xccaw.currency_amt) currency_amt
        FROM /*xxpa_cogs_cost_analysis_wip_v*/
             ( ---WIP RESOURCE AND OVERHEAD
              SELECT 'WIP10' TYPE,
                      hou.name org,
                      NULL expenditure_item_id,
                      pa.project_type,
                      pa.project_id,
                      pt.task_id,
                      pa.segment1 proj_no,
                      mfg.task_number mfg,
                      pt.task_number task,
                      NULL group_parts,
                      'Other Material' expen_cate,
                      'Other Material' expen_type,
                      mmt.transaction_date gl_date,
                      pp.gl_period_name,
                      'THB' project_currency_code,
                      -1 * mmt.primary_quantity,
                      -1 * (mmt.actual_cost * mmt.primary_quantity) amt,
                      -1 * (mmt.actual_cost * mmt.primary_quantity) currency_amt
                FROM apps.mtl_material_transactions mmt,
                      apps.hr_organization_units     hou,
                      apps.pa_projects_all           pa,
                      apps.pa_project_types_all      ppt,
                      apps.pa_tasks                  pt,
                      apps.pa_tasks                  mfg,
                      --apps.org_acct_periods          oap,
                      pa_periods_all pp,
                      xxpa_lookups   xl
               WHERE mmt.organization_id = hou.organization_id
                 AND mmt.source_code = 'DN Out'
                 AND mmt.source_task_id = pt.task_id
                 AND mmt.source_project_id = pa.project_id
                 AND pt.top_task_id = mfg.task_id
                 AND pa.project_type = ppt.project_type
                    --AND oap.acct_period_id = mmt.acct_period_id
                 AND xl.lookup_type = 'XXPA_FAC_SP_MAINTENANCE'
                 AND xl.meaning = ppt.project_type
                 AND xl.enabled_flag = 'Y'
                 AND pa.org_id = pp.org_id
                 AND hou.name = g_org_name
                 AND pp.gl_period_name = g_period
                 AND mmt.transaction_date <= (pp.end_date + 0.99999) --update by gusenlin 1104
                    --update by liudan 2017/03/06 for hardcoding begin
                    --AND pa.org_id = 84
                 AND pa.org_id = fnd_global.org_id
              --end update by liudan 2017/03/06
              ) xccaw
       GROUP BY xccaw.type,
                xccaw.org,
                xccaw.project_type,
                xccaw.project_id,
                xccaw.task_id,
                xccaw.proj_no,
                xccaw.mfg,
                xccaw.task,
                xccaw.group_parts,
                xccaw.expen_cate,
                xccaw.expen_type,
                xccaw.project_currency_code;
  
    log('collect_wip_group:count ' || SQL%ROWCOUNT);
  END;

  /*
  PROCEDURE collect_wip
  IS
   \* CURSOR cur_wip
    IS
      SELECT  xccaw.type,
              xccaw.org,
              xccaw.expenditure_item_id,
              xccaw.project_type,
              xccaw.project_id,
              xccaw.task_id,
              (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id)top_task_id,
              xccaw.proj_no,
              xccaw.mfg,
              xccaw.task,
              xccaw.group_parts,
              xccaw.expen_cate,
              xccaw.expen_type,
              xccaw.gl_date,
              xccaw.gl_period_name,
              NULL gl_date_condition2,
              xccaw.project_currency_code,
              xccaw.quantity,
              xccaw.amt,
              xccaw.currency_amt
        FROM xxpa_cogs_cost_analysis_wip_v xccaw
       WHERE xccaw.org             = g_org_name
         AND xccaw.gl_period_name  = g_period;*\
  BEGIN
    INSERT INTO xxpa_proj_cogs_mon_rpt3_tmp
        (TYPE
        ,org
        ,expenditure_item_id
        ,project_type
        ,project_id
        ,task_id
        ,top_task_id
        ,proj_no
        ,mfg
        ,task
        ,group_parts
        ,expen_cate
        ,expen_type
        ,gl_date
        ,project_currency_code
        ,quantity
        ,amt
        ,currency_amt)
     SELECT  xccaw.type,
              xccaw.org,
              xccaw.expenditure_item_id,
              xccaw.project_type,
              xccaw.project_id,
              xccaw.task_id,
              (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xccaw.task_id)top_task_id,
              xccaw.proj_no,
              xccaw.mfg,
              xccaw.task,
              xccaw.group_parts,
              xccaw.expen_cate,
              xccaw.expen_type,
              xccaw.gl_date,
              xccaw.project_currency_code,
              xccaw.quantity,
              xccaw.amt,
              xccaw.currency_amt
        FROM xxpa_cogs_cost_analysis_wip_v xccaw
       WHERE 1=1
         AND xccaw.gl_period_name  = g_period
         AND xccaw.org             = g_org_name;
  
    log('collect_wip:count ' || SQL%ROWCOUNT);
  END;
  */
  PROCEDURE collect_sales_invoice IS
    CURSOR cur_sales_invoice IS
      SELECT xdca.type_code TYPE,
             xdca.name org,
             xdca.expenditure_item_id -- The data in this filed is null
            ,
             xdca.project_type,
             xdca.project_id,
             xdca.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xdca.task_id) top_task_id,
             xdca.segment1 proj_no,
             xdca.mfg_number mfg,
             xdca.task_number task,
             xdca.group_parts,
             xdca.expen_cate,
             xdca.expen_type,
             xdca.gl_date,
             xdca.gl_period_name,
             NULL gl_date_condition2,
             xdca.currency_code,
             xdca.quantity,
             xdca.base_amt amt,
             xdca.currency_amt
        FROM xxpa_detail_cost_analysis_v xdca
       WHERE xdca.gl_period_name = g_period
         AND xdca.name = g_org_name;
  BEGIN
    FOR rec IN cur_sales_invoice LOOP
      insert_tmp(rec.type,
                 rec.org,
                 rec.expenditure_item_id,
                 rec.project_type,
                 rec.project_id,
                 rec.task_id,
                 rec.top_task_id,
                 rec.proj_no,
                 rec.mfg,
                 rec.task,
                 rec.group_parts,
                 rec.expen_cate,
                 rec.expen_type,
                 rec.gl_date,
                 rec.currency_code,
                 rec.quantity,
                 rec.amt,
                 rec.currency_amt);
    END LOOP;
  END;

  PROCEDURE collect_accrual IS
    CURSOR collect_accrual IS
      SELECT /*+ index(xcfd XXPA_COST_FLOW_DTLS_ALL_N5)*/ --add by steven.wang@20171124 add hint for performance
       'ACCRUAL' TYPE,
       --update by liudan 2017/03/06 for het hardcoding begin
       /*decode(cost_type,
       'FAC_FG',
       'SHE_FAC_ORG',
       'FAC_TO_HO_FG',
       'SHE_HQ_ORG',
       'FINAL_FG',
       'SHE_HQ_ORG',
       NULL) org,*/
       decode(cost_type,
              'FAC_FG',
              'SHE_FAC_ORG',
              'FAC_TO_HO_FG',
              'SHE_HQ_ORG',
              'FINAL_FG',
              decode(hou.name, 'HET_OU', 'HET_HQ_ORG', 'SHE_HQ_ORG'),
              NULL) org,
       --end update by liudan 2017/03/06
       
       xcfd.source_line_id expenditure_item_id,
       pa.project_type,
       pa.project_id,
       pt.task_id,
       pt.top_task_id,
       pa.segment1 proj_no,
       mfg.task_number mfg,
       pt.task_number task,
       pet.attribute15 group_parts,
       'Z1.Accrual(B)' expen_cate,
       'Z1.Accrual(B)' expen_type,
       xcfd.expenditure_item_date gl_date,
       xcfd.period_name gl_period_name
       --,to_date(xcfd.period_name,'MON-YY') gl_period_name_accrual
      ,
       NULL project_currency_code,
       NULL quantity,
       0 - xcfd.expenditure_amount amt,
       0 - xcfd.expenditure_amount currency_amt
        FROM xxpa_cost_flow_dtls_all xcfd,
             pa_projects_all         pa,
             pa_tasks                pt,
             pa_tasks                mfg,
             pa_expenditure_types    pet,
             hr_operating_units      hou --add by liudan 2017/03/06
       WHERE xcfd.project_id = pa.project_id
         AND xcfd.org_id = pa.org_id
         AND xcfd.task_id = pt.task_id
         AND xcfd.mfg_id = mfg.task_id
         AND xcfd.expenditure_type = pet.expenditure_type
         AND substr(xcfd.expenditure_reference, 1, 7) = 'ACCRUAL'
         AND nvl(xcfd.transfered_pa_flag, 'N') = 'Y'
            --update by liudan 2017/03/06 for het hardcoding begin
         AND pa.org_id = hou.organization_id
            --AND pa.org_id = 84
         AND pa.org_id = fnd_global.org_id
            --end update by liudan 2017/03/06  for het hardcoding
            
         AND xcfd.expenditure_item_date <=
             last_day(transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/) --update by gusenlin 2013-11-04
             --modify by jingjing 2018-02-01
         AND --update by liudan 2017/03/06 for het hardcoding begin
            /*decode(cost_type,
            'FAC_FG',
            'SHE_FAC_ORG',
            'FAC_TO_HO_FG',
            'SHE_HQ_ORG',
            'FINAL_FG',
            'SHE_HQ_ORG',
            NULL) org,*/
             decode(cost_type,
                    'FAC_FG',
                    'SHE_FAC_ORG',
                    'FAC_TO_HO_FG',
                    'SHE_HQ_ORG',
                    'FINAL_FG',
                    decode(hou.name, 'HET_OU', 'HET_HQ_ORG', 'SHE_HQ_ORG'),
                    NULL) = g_org_name;
    --end update by liudan 2017/03/06
  BEGIN
    FOR rec IN collect_accrual LOOP
      insert_tmp(rec.type,
                 rec.org,
                 rec.expenditure_item_id,
                 rec.project_type,
                 rec.project_id,
                 rec.task_id,
                 rec.top_task_id,
                 rec.proj_no,
                 rec.mfg,
                 rec.task,
                 rec.group_parts,
                 rec.expen_cate,
                 rec.expen_type,
                 rec.gl_date,
                 rec.project_currency_code,
                 rec.quantity,
                 rec.amt,
                 rec.currency_amt);
    END LOOP;
  END;

  PROCEDURE collect_manully_fg IS
    CURSOR cur_manully_fg IS
      SELECT xemf.type,
             xemf.org,
             xemf.expenditure_item_id,
             xemf.project_type,
             xemf.project_id,
             xemf.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = xemf.task_id) top_task_id,
             xemf.proj_no,
             xemf.mfg,
             xemf.task,
             xxpa_proj_exp_item_ref_pkg.get_mfg_source(xemf.project_id,
                                                       xemf.mfg) mfg_source,
             xxpa_proj_exp_item_ref_pkg.get_project_status(xemf.project_id) project_status,
             xxpa_proj_exp_item_ref_pkg.get_mfg_spec(xemf.mfg) mfg_spec,
             xemf.group_parts,
             xemf.expen_cate,
             xemf.expen_type,
             xemf.gl_date,
             NULL gl_period_name,
             xemf.gl_date gl_date_condition2,
             xemf.project_currency_code,
             -xemf.quantity quantity,
             -xemf.amt amt,
             -xemf.currency_amt currency_amt
        FROM xxpa_cogs_exp_manully_fg_v xemf
       WHERE xemf.gl_date <= g_period_date
         AND xemf.gl_date >= to_date('NOV-2012', 'MON-YYYY')
         AND xemf.org = g_org_name;
  
  BEGIN
    FOR rec IN cur_manully_fg LOOP
      insert_tmp(rec.type,
                 rec.org,
                 rec.expenditure_item_id,
                 rec.project_type,
                 rec.project_id,
                 rec.task_id,
                 rec.top_task_id,
                 rec.proj_no,
                 rec.mfg,
                 rec.task,
                 rec.group_parts,
                 rec.expen_cate,
                 rec.expen_type,
                 rec.gl_date,
                 rec.project_currency_code,
                 rec.quantity,
                 rec.amt,
                 rec.currency_amt);
    END LOOP;
  END;

  PROCEDURE collect_wip1 IS
    l_last_min_id NUMBER;
    l_last_max_id NUMBER;
  BEGIN
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_his a
       SET a.last_min_id = a.last_max_id,
           a.last_max_id =least(last_max_id+2000000,
           (SELECT MAX(xcd.cost_detail_id) FROM xxpa_cost_flow_dtls_all xcd))
     WHERE a.source_type = 'WIP100';
  
    SELECT nvl(MAX(a.last_min_id), 0), nvl(MAX(a.last_max_id), 0)
      INTO l_last_min_id, l_last_max_id
      FROM xxpa.xxpa_proj_cogs_mon_rpt3_his a
     WHERE a.source_type = 'WIP100';
  
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_itm
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt,
       expenditure_category,
       attribute7,
       transaction_id,
       request_id,
       cst_period_date,
       cst_flag,
       org_id,
       update_request_id,
       creation_date,
       last_update_date)
      SELECT 'WIP100' TYPE,
             ood.organization_name org,
             mta.transaction_id expenditure_item_id,
             ppa.project_type,
             ppa.project_id,
             pt.task_id,
             ppa.segment1 proj_no,
             mfg.task_number mfg,
             pt.task_number task,
             /** xxpa_proj_exp_item_ref_pkg **/
             decode(nvl(ppt.attribute7, -1),
                    'OVERSEA',
                    xxpa_proj_cogs_mon_rpt3_pkg.get_cogs_gp(xcfd.cost_detail_id),
                    '') group_parts,
             'Other Material' expen_cate,
             'Other Material' expen_type,
             xcfd.expenditure_item_date gl_date,
             NULL project_currency_code,
             NULL quantity,
             0 - xcfd.expenditure_amount amt,
             0 - xcfd.expenditure_amount currency_amt,
             NULL,
             NULL,
             xcfd.cost_detail_id,
             g_request_id request_id,
             NULL cst_period_date,
             CASE
               WHEN xcfd.transfered_pa_flag = 'N' THEN
                'P'
               ELSE
                'Y'
             END cst_flag,
             ppa.org_id,
             NULL,
             SYSDATE,
             SYSDATE
        FROM org_organization_definitions ood,
             xxpa_cost_flow_dtls_all      xcfd,
             mtl_transaction_accounts     mta,
             pa_projects_all              ppa,
             pa_project_types_all         ppt,
             pa_tasks                     mfg,
             pa_tasks                     pt
       WHERE xcfd.source_table = 'MTL_TRANSACTION_ACCOUNTS'
         AND xcfd.source_line_id = mta.inv_sub_ledger_id
         AND xcfd.project_type = ppt.project_type
         AND xcfd.expenditure_org_id = ood.organization_id
         AND xcfd.project_id = ppa.project_id
         AND xcfd.mfg_id = mfg.task_id
         AND xcfd.task_id = pt.task_id
         AND xcfd.cost_detail_id > l_last_min_id
         AND xcfd.cost_detail_id <= l_last_max_id
         AND NOT EXISTS
       (SELECT 1
                FROM apps.pa_expenditure_items_all pei
               WHERE /*to_number(*/
               pei.orig_transaction_reference /*)*/
               = to_char(mta.transaction_id)
            AND pei.transaction_source = 'Inventory');
    log('collect_wip_100:count1: ' || SQL%ROWCOUNT);
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_itm pei
       SET update_request_id = g_request_id,
           last_update_date  = SYSDATE,
           cst_flag          = 'N'
     WHERE pei.cst_flag IN ('Y', 'P')
       AND pei.type = 'WIP100'
       AND (EXISTS (SELECT 1
                      FROM apps.pa_expenditure_items_all pei1
                     WHERE pei1.orig_transaction_reference =
                           to_char(pei.expenditure_item_id)
                       AND pei1.transaction_source = 'Inventory'));
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_itm pei
       SET update_request_id = g_request_id,
           last_update_date  = SYSDATE,
           cst_flag          = 'Y'
     WHERE pei.cst_flag IN ('P')
       AND pei.type = 'WIP100'
       AND (EXISTS (SELECT 1
                      FROM xxpa_cost_flow_dtls_all xcfd
                     WHERE xcfd.cost_detail_id = pei.transaction_id
                       AND xcfd.transfered_pa_flag = 'Y'));
  
    INSERT INTO xxpa.xxpa_proj_cogs_mon_rpt3_tmp
      (TYPE,
       org,
       expenditure_item_id,
       project_type,
       project_id,
       task_id,
       top_task_id,
       proj_no,
       mfg,
       task,
       group_parts,
       expen_cate,
       expen_type,
       gl_date,
       project_currency_code,
       quantity,
       amt,
       currency_amt)
      SELECT 'WIP100' TYPE,
             pei.org,
             pei.expenditure_item_id,
             pei.project_type,
             pei.project_id,
             pei.task_id,
             (SELECT top_task_id
                FROM pa_tasks pt
               WHERE pt.task_id = pei.task_id) top_task_id,
             pei.proj_no,
             pei.mfg,
             pei.task,
             pei.group_parts,
             pei.expen_cate,
             pei.expen_type,
             pei.gl_date,
             pei.project_currency_code,
             pei.quantity,
             pei.amt,
             pei.currency_amt
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_itm pei, pa_periods_all pp
       WHERE pei.org_id = pp.org_id
         AND pei.org = g_org_name
         AND pp.gl_period_name = g_period
         AND pei.gl_date <= pp.end_date
         AND pei.type = 'WIP100'
         AND pei.cst_flag = 'Y';
  
    log('Collect_wip1:count 2 ' || SQL%ROWCOUNT);
  END;

  FUNCTION get_long_name(p_project_id NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_long_name IS
      SELECT long_name
        FROM pa_projects_all
       WHERE project_id = p_project_id;
  
    l_project_long_name VARCHAR2(240);
  BEGIN
    OPEN cur_long_name;
    FETCH cur_long_name
      INTO l_project_long_name;
    CLOSE cur_long_name;
    RETURN l_project_long_name;
  END;

  FUNCTION get_sum_by_task(p_project_id  NUMBER,
                           p_task_id     NUMBER,
                           p_group_parts VARCHAR2,
                           p_sum_type    VARCHAR2) RETURN NUMBER IS
    CURSOR amt IS
      SELECT SUM(amt)
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
       WHERE (group_parts IS NULL AND p_group_parts IS NULL OR
             group_parts = p_group_parts)
         AND type_cate = p_sum_type
         AND project_id = p_project_id
         AND task_id = p_task_id;
  
    l_amt NUMBER;
  BEGIN
    OPEN amt;
    FETCH amt
      INTO l_amt;
    CLOSE amt;
    RETURN round(nvl(l_amt, 0), g_round);
  END;

  FUNCTION get_sum_by_mfg(p_project_id  NUMBER,
                          p_top_task_id NUMBER,
                          p_group_parts VARCHAR2,
                          p_sum_type    VARCHAR2) RETURN NUMBER IS
    CURSOR amt IS
      SELECT SUM(amt)
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
       WHERE (group_parts IS NULL AND p_group_parts IS NULL OR
             group_parts = p_group_parts)
         AND type_cate = p_sum_type
         AND project_id = p_project_id
         AND top_task_id = p_top_task_id;
  
    l_amt NUMBER;
  BEGIN
    OPEN amt;
    FETCH amt
      INTO l_amt;
    CLOSE amt;
    RETURN round(nvl(l_amt, 0), g_round);
  END;

  FUNCTION get_amt_by_expen_type(p_project_id  NUMBER,
                                 p_key         NUMBER,
                                 p_group_parts VARCHAR2,
                                 p_expen_cate  VARCHAR2,
                                 p_expen_type  VARCHAR2) RETURN NUMBER IS
    CURSOR cur_mfg IS
      SELECT SUM(amt) amt
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
       WHERE (group_parts IS NULL AND p_group_parts IS NULL OR
             group_parts = p_group_parts)
         AND expen_cate = p_expen_cate
         AND expen_type = p_expen_type
         AND project_id = p_project_id
         AND top_task_id = p_key;
  
    CURSOR cur_task IS
      SELECT SUM(amt) amt
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
       WHERE (group_parts IS NULL AND p_group_parts IS NULL OR
             group_parts = p_group_parts)
         AND expen_cate = p_expen_cate
         AND expen_type = p_expen_type
         AND project_id = p_project_id
         AND task_id = p_key;
  
    l_amt NUMBER;
  BEGIN
  
    IF g_summary_by = g_group_by_mfg THEN
      OPEN cur_mfg;
      FETCH cur_mfg
        INTO l_amt;
      CLOSE cur_mfg;
    
    ELSE
    
      OPEN cur_task;
      FETCH cur_task
        INTO l_amt;
      CLOSE cur_task;
    
    END IF;
  
    RETURN round(nvl(l_amt, 0), g_round);
  END;

  FUNCTION get_profit_amt(p_cogs_amt     NUMBER,
                          p_invoice_amt0 NUMBER,
                          p_invoice_amt2 NUMBER,
                          p_price_amt    NUMBER) RETURN NUMBER IS
    l_profit_amt NUMBER;
  BEGIN
  
    IF g_profile_base = g_profit_type0 THEN
      IF nvl(p_invoice_amt0, 0) = 0 THEN
        l_profit_amt := 0;
      ELSE
        l_profit_amt := nvl(p_cogs_amt, 0) / p_invoice_amt0;
      END IF;
    
    ELSIF g_profile_base = g_profit_type1 THEN
    
      IF nvl(p_invoice_amt2, 0) = 0 THEN
        l_profit_amt := 0;
      ELSE
        l_profit_amt := nvl(p_cogs_amt, 0) / p_price_amt;
      END IF;
    
    ELSIF g_profile_base = g_profit_type2 THEN
    
      IF nvl(p_price_amt, 0) = 0 THEN
        l_profit_amt := 0;
      ELSE
        l_profit_amt := nvl(p_cogs_amt, 0) / p_invoice_amt2;
      END IF;
    
    ELSE
      l_profit_amt := 0;
    END IF;
  
    RETURN round(nvl(l_profit_amt, 0), g_round);
  END;

  PROCEDURE collect_data IS
  
  BEGIN
  
    --10. collect the data
    log('10.05 collect_wip1  type WIP100          ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip1;
    COMMIT;
    log('10.3 collect_wip   type WIP_GROUP          ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group;
    COMMIT;
    log('10.4 collect_wip_group1             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group1;
    COMMIT;
    log('10.5 collect_wip_group2             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group2;
    COMMIT;
    log('10.6 collect_wip_group3             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group3;
    COMMIT;
    log('10.7 collect_wip_group4             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group4;
    COMMIT;

    log('10.8 collect_0_invoice_amout ' || to_char(SYSDATE, g_date_format));
    collect_0_invoice_amout;
    COMMIT;
    log('10.9 collect_cogs            ' || to_char(SYSDATE, g_date_format));
    collect_cogs;
    COMMIT;
    log('10.10 collect_wip_group4             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group5;
    COMMIT;
    log('10.11 collect_wip_group5             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group6;
    COMMIT;
    log('10.12 collect_wip_group6             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group7;
    COMMIT;
    log('10.13 collect_wip_group7             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group8;
    COMMIT;
    log('10.14 collect_wip_group8             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group9;
    COMMIT;
    log('10.15 collect_wip_group9             ' ||
        to_char(SYSDATE, g_date_format));
    collect_wip_group10;
    COMMIT;
    log('10.16 collect_sales_invoice   ' ||
        to_char(SYSDATE, g_date_format));
    collect_sales_invoice;
    COMMIT;
    log('10.17 collect_accrual         ' ||
        to_char(SYSDATE, g_date_format));
    collect_accrual;
    COMMIT;
    log('10.18 collect_manully_fg      ' ||
        to_char(SYSDATE, g_date_format));
    collect_manully_fg;
    COMMIT;
    log('10.19 end                     ' ||
        to_char(SYSDATE, g_date_format));
  
    UPDATE xxpa.xxpa_proj_cogs_mon_rpt3_tmp xpc
       SET xpc.amt       = round(xpc.amt, g_round),
           xpc.type_cate = decode(xpc.type,
                                  'FG',
                                  'FG',
                                  'COGS',
                                  g_cogs_type,
                                  'Sales Price',
                                  '1.Sales Price',
                                  'Invoice Amount',
                                  '0.Invoice Amount',
                                  'ACCRUAL',
                                  'Z1.ACCRUAL',
                                  'Manully',
                                  'Z2.Manully',
                                  'MANUAL_AP',
                                  'MANUAL_AP',
                                  'Z1.Prod. Hours',
                                  'Z1.Prod. Hours',
                                  'Z1.DES Hours',
                                  'Z1.DES Hours',
                                  'WIP');
    log('Total data :' || SQL%ROWCOUNT);
  
    DELETE FROM xxpa.xxpa_cogs_expen_type_temp;
  
    INSERT INTO xxpa.xxpa_cogs_expen_type_temp
      SELECT type_cate, expen_cate, expen_type, 'Y'
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
       GROUP BY type_cate, expen_cate, expen_type
       ORDER BY type_cate, expen_cate, expen_type ASC;
  
  EXCEPTION
    WHEN OTHERS THEN
      log('Exception in collect_data [When others then] ' || SQLERRM);
      RAISE;
  END collect_data;

  PROCEDURE print_header IS
    CURSOR cur_type IS
      SELECT TYPE, COUNT(1) col_span
        FROM xxpa.xxpa_cogs_expen_type_temp
       GROUP BY TYPE
       ORDER BY TYPE ASC;
  
    CURSOR cur_cate IS
      SELECT TYPE, expen_cate, COUNT(DISTINCT expen_type) col_span
        FROM xxpa.xxpa_cogs_expen_type_temp
       GROUP BY TYPE, expen_cate
       ORDER BY TYPE, expen_cate ASC;
  
    CURSOR cur_expen_type IS
      SELECT TYPE, expen_cate, expen_type
        FROM xxpa.xxpa_cogs_expen_type_temp
       ORDER BY TYPE, expen_cate, expen_type ASC;
  BEGIN
  
    xxpa_proj_cost_rpt_pub.output_head('Project COGS Monthly Report');
  
    --header line 1
    xxpa_proj_cost_rpt_pub.output_tr;
    IF g_summary_by = g_group_by_mfg THEN
      output_col_title(g_space, 9);
    ELSE
      output_col_title(g_space, 10);
    END IF;
    FOR rec IN cur_type LOOP
      output_col_title(rec.type, rec.col_span);
      IF rec.type = g_cogs_type THEN
        output_col_title(g_space);
      END IF;
    END LOOP;
  
    output('</tr>');
  
    --header line 2
    xxpa_proj_cost_rpt_pub.output_tr;
    IF g_summary_by = g_group_by_mfg THEN
      output_col_title(g_space, 8);
    ELSE
      output_col_title(g_space, 9);
    END IF;
    output_col_title('Expen Cate');
    FOR rec IN cur_cate LOOP
      output_col_title(rec.expen_cate, rec.col_span);
      IF rec.type = g_cogs_type THEN
        output_col_title('Profit&Loss(%)');
      END IF;
    END LOOP;
    output('</tr>');
  
    --header line 3
    xxpa_proj_cost_rpt_pub.output_tr;
  
    IF g_summary_by = g_group_by_mfg THEN
      output_col_title(g_space, 8);
    ELSE
      output_col_title(g_space, 9);
    END IF;
  
    output_col_title('Expen Type');
  
    FOR rec IN cur_expen_type LOOP
      output_col_title(rec.expen_type);
      IF rec.type = g_cogs_type THEN
        output_col_title(g_space);
      END IF;
    END LOOP;
  
    output('</tr>');
  
    --header line 4
    xxpa_proj_cost_rpt_pub.output_tr;
  
    output_col_title('Project Type');
    output_col_title('Group Parts');
    output_col_title('MFG');
    IF g_summary_by = g_group_by_task THEN
      output_col_title('Task');
    END IF;
    output_col_title('Proj No');
    output_col_title('Project Status');
    output_col_title('Project Long Name');
    output_col_title('Mfg Spec');
    output_col_title('Mfg Source');
    output_col_title(g_space);
  
    FOR rec IN cur_expen_type LOOP
      output_col_title(g_space);
      IF rec.type = g_cogs_type THEN
        output_col_title(g_space);
      END IF;
    END LOOP;
  
    output('</tr>');
  END;

  PROCEDURE print_report IS
  
    CURSOR cur_expen_type IS
      SELECT TYPE, expen_cate, expen_type
        FROM xxpa.xxpa_cogs_expen_type_temp
       ORDER BY TYPE, expen_cate, expen_type ASC;
  
    CURSOR cur_sales_mfg IS
      SELECT xsimv.ar_invoice_number,
             (0 - xsimv.ar_line_amount_thb - xsimv.ar_tax_amount_thb) amt1,
             (0 - xsimv.ar_line_amount_thb - xsimv.ar_tax_amount_thb) amt2
        FROM xxar_sales_invoices_mfg_v xsimv
       WHERE xsimv.gl_date <= g_period_date
         AND xsimv.gl_date >= g_period_date_from
         AND tax_invoice_status = 'Invoiced'
         AND xsimv.have_mfg = 'N'
         AND (xsimv.last_invoice_flag = 'Y' OR g_org_name = g_fac_org)
         AND EXISTS
       (SELECT 1
                FROM fnd_flex_values_vl ffv, fnd_flex_value_sets ffs
               WHERE ffv.flex_value_set_id = ffs.flex_value_set_id
                 AND ffs.flex_value_set_name = 'XXPA_SALES_MFG_AR_TYPE'
                 AND ffv.enabled_flag = 'Y'
                 AND SYSDATE BETWEEN nvl(ffv.start_date_active, SYSDATE) AND
                     nvl(ffv.end_date_active + 0.99999, SYSDATE)
                 AND ffv.flex_value = xsimv.ar_type
                 AND ffv.description = g_org_name)
       ORDER BY xsimv.ar_invoice_number DESC;
  
    CURSOR cur_detail IS
      SELECT project_id,
             proj_no,
             task_id,
             mfg,
             task,
             group_parts,
             project_type
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
       GROUP BY project_id,
                proj_no,
                task_id,
                mfg,
                task,
                group_parts,
                project_type
       ORDER BY project_type, group_parts, mfg, task, proj_no ASC;
  
    CURSOR cur_detail_by_mfg IS
      SELECT project_id,
             proj_no,
             top_task_id,
             mfg,
             group_parts,
             project_type
        FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
       GROUP BY project_id,
                proj_no,
                top_task_id,
                mfg,
                group_parts,
                project_type
       ORDER BY project_type, group_parts, mfg, proj_no ASC;
  
    CURSOR cur_amt(p_project_id  NUMBER,
                   p_key         NUMBER,
                   p_group_parts VARCHAR2) IS
      SELECT TYPE,
             expen_cate,
             expen_type,
             SUM(amt) amt,
             SUM(currency_amt) currency_amt,
             MAX(project_currency_code) currency
        FROM (SELECT TYPE,
                     expen_cate,
                     expen_type,
                     NULL       amt,
                     NULL       currency_amt,
                     NULL       project_currency_code
                FROM xxpa.xxpa_cogs_expen_type_temp
               WHERE base_flag = 'Y'
              UNION ALL
              SELECT type_cate,
                     expen_cate,
                     expen_type,
                     amt,
                     currency_amt,
                     project_currency_code
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
               WHERE (group_parts IS NULL AND p_group_parts IS NULL OR
                     group_parts = p_group_parts)
                 AND project_id = p_project_id
                 AND task_id = p_key)
       GROUP BY TYPE, expen_cate, expen_type
       ORDER BY TYPE, expen_cate, expen_type ASC;
  
    CURSOR cur_amt_by_mfg(p_project_id  NUMBER,
                          p_key         NUMBER,
                          p_group_parts VARCHAR2) IS
      SELECT TYPE,
             expen_cate,
             expen_type,
             SUM(amt) amt,
             SUM(currency_amt) currency_amt,
             MAX(project_currency_code) currency
        FROM (SELECT TYPE,
                     expen_cate,
                     expen_type,
                     NULL       amt,
                     NULL       currency_amt,
                     NULL       project_currency_code
                FROM xxpa.xxpa_cogs_expen_type_temp
               WHERE base_flag = 'Y'
              UNION ALL
              SELECT type_cate,
                     expen_cate,
                     expen_type,
                     amt,
                     currency_amt,
                     project_currency_code
                FROM xxpa.xxpa_proj_cogs_mon_rpt3_tmp
               WHERE (group_parts IS NULL AND p_group_parts IS NULL OR
                     group_parts = p_group_parts)
                 AND project_id = p_project_id
                 AND top_task_id = p_key)
       GROUP BY TYPE, expen_cate, expen_type
       ORDER BY TYPE, expen_cate, expen_type ASC;
  
    l_accual_amt      NUMBER;
    l_wip_balance     NUMBER;
    l_wip_amt         NUMBER;
    l_accural_balance NUMBER;
    l_wip_offset      NUMBER;
    l_print_row_flag  VARCHAR2(1);
  
    l_cogs_amt      NUMBER;
    l_invoice_amt_0 NUMBER;
    l_invoice_amt_2 NUMBER;
    l_price         NUMBER;
    l_profit_amt    NUMBER;
  
    l_cogs_column    NUMBER;
    l_invoice_column NUMBER;
  BEGIN
  
    print_header;
  
    IF g_summary_by = g_group_by_task THEN
    
      FOR rec IN cur_detail LOOP
      
        l_invoice_amt_0  := NULL;
        l_invoice_amt_2  := NULL;
        l_price          := NULL;
        l_cogs_amt       := NULL;
        l_cogs_column    := NULL;
        l_invoice_column := NULL;
      
        l_print_row_flag := 'Y';
      
        l_cogs_column    := get_amt_by_expen_type(p_project_id  => rec.project_id,
                                                  p_key         => rec.task_id,
                                                  p_group_parts => rec.group_parts,
                                                  p_expen_cate  => g_cogs_type,
                                                  p_expen_type  => g_cogs_type);
        l_invoice_column := get_amt_by_expen_type(p_project_id  => rec.project_id,
                                                  p_key         => rec.task_id,
                                                  p_group_parts => rec.group_parts,
                                                  p_expen_cate  => g_invoice_amt_type1,
                                                  p_expen_type  => g_invoice_amt_type1);
      
        IF g_org_name = g_fac_org THEN
          IF nvl(l_cogs_column, 0) != 0 OR
             nvl(l_invoice_column, 0) != 0 AND nvl(l_cogs_column, 0) = 0 THEN
            l_print_row_flag := 'Y';
          ELSE
            l_print_row_flag := 'N';
          END IF;
        ELSIF g_org_name = g_hq_org THEN
          IF nvl(l_cogs_column, 0) != 0 THEN
            l_print_row_flag := 'Y';
          ELSE
            l_print_row_flag := 'N';
          END IF;
          --add by liudan 2017/03/06 for het hardcoding begin
        ELSIF g_org_name = g_het_org THEN
          IF nvl(l_cogs_column, 0) != 0 THEN
            l_print_row_flag := 'Y';
          ELSE
            l_print_row_flag := 'N';
          END IF;
          --end add by liudan 2017/03/06
        ELSE
        
          l_print_row_flag := 'N';
        END IF;
      
        /*l_wip_amt := nvl(get_sum_by_task(p_project_id  => rec.project_id,
                                     p_task_id         => rec.task_id,
                                     p_group_parts     => rec.group_parts,
                                     p_sum_type        => g_wip),0);
        
        l_accual_amt := nvl(get_sum_by_task(p_project_id   => rec.project_id,
                                     p_task_id      => rec.task_id,
                                     p_group_parts  => rec.group_parts,
                                     p_sum_type     => g_accrual_type),0);
        
        IF l_wip_amt<= l_accual_amt THEN
          l_wip_offset := l_wip_amt;
        ELSE
          l_wip_offset := l_accual_amt;
        END IF;
        
        IF l_wip_offset <=0 THEN
          l_wip_offset := 0 ;
        END IF;
        
        l_wip_balance := l_wip_amt - l_wip_offset;
        l_accural_balance := l_accual_amt -l_wip_offset;
        
        IF l_wip_balance = 0 AND l_accural_balance = 0 THEN
           l_print_row_flag :='N';
        END IF;*/
      
        IF l_print_row_flag = 'Y' THEN
        
          output('<tr>');
          output_column(rec.project_type, g_type_text);
          output_column(rec.group_parts, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.task, g_type_text);
          output_column(rec.proj_no, g_type_text);
          output_column(xxpa_proj_exp_item_ref_pkg.get_project_status(rec.project_id),
                        g_type_text);
          output_column(get_long_name(rec.project_id), g_type_text);
          output_column(xxpa_proj_exp_item_ref_pkg.get_mfg_spec(rec.mfg),
                        g_type_text);
          output_column(xxpa_proj_exp_item_ref_pkg.get_mfg_source(rec.project_id,
                                                                  rec.mfg),
                        g_type_text);
        
          output_column('', g_type_text);
        
          FOR amt IN cur_amt(p_project_id  => rec.project_id,
                             p_key         => rec.task_id,
                             p_group_parts => rec.group_parts) LOOP
          
            IF amt.expen_type = g_invoice_amt_type1 THEN
              l_invoice_amt_0 := amt.amt;
            ELSIF amt.expen_type = g_invoice_amt_type2 THEN
              l_invoice_amt_2 := amt.amt;
            ELSIF amt.expen_type = g_price_type THEN
              l_price := amt.amt;
            ELSIF amt.expen_type = g_cogs_type THEN
              l_cogs_amt := amt.amt;
            END IF;
          
            output_column(amt.amt, g_type_text);
            /*IF amt.expen_type IN ('Price', 'Invoice') THEN
              output_column(amt.currency_amt, g_type_text);
              output_column(amt.currency, g_type_text);
            END IF;*/
            IF amt.type = g_cogs_type THEN
              l_profit_amt := get_profit_amt(p_cogs_amt     => l_cogs_amt,
                                             p_invoice_amt0 => l_invoice_amt_0,
                                             p_invoice_amt2 => l_invoice_amt_2,
                                             p_price_amt    => l_price);
              output_column(l_profit_amt, g_type_text);
            END IF;
          
          END LOOP;
        
          output('</tr>');
        
        END IF;
      END LOOP;
    
    ELSE
    
      FOR rec IN cur_detail_by_mfg LOOP
      
        l_invoice_amt_0  := NULL;
        l_invoice_amt_2  := NULL;
        l_price          := NULL;
        l_cogs_amt       := NULL;
        l_cogs_column    := NULL;
        l_invoice_column := NULL;
      
        l_print_row_flag := 'Y';
      
        l_cogs_column    := get_amt_by_expen_type(p_project_id  => rec.project_id,
                                                  p_key         => rec.top_task_id,
                                                  p_group_parts => rec.group_parts,
                                                  p_expen_cate  => g_cogs_type,
                                                  p_expen_type  => g_cogs_type);
        l_invoice_column := get_amt_by_expen_type(p_project_id  => rec.project_id,
                                                  p_key         => rec.top_task_id,
                                                  p_group_parts => rec.group_parts,
                                                  p_expen_cate  => g_invoice_amt_type1,
                                                  p_expen_type  => g_invoice_amt_type1);
      
        IF g_org_name = g_fac_org THEN
          IF nvl(l_cogs_column, 0) != 0 OR
             nvl(l_invoice_column, 0) != 0 AND nvl(l_cogs_column, 0) = 0 THEN
            l_print_row_flag := 'Y';
          ELSE
            l_print_row_flag := 'N';
          END IF;
        
        ELSIF g_org_name = g_hq_org THEN
          IF nvl(l_cogs_column, 0) != 0 THEN
            l_print_row_flag := 'Y';
          ELSE
            l_print_row_flag := 'N';
          END IF;
        
          --add by liudan 2017/03/06 for het hardcoding begin
        ELSIF g_org_name = g_het_org THEN
          IF nvl(l_cogs_column, 0) != 0 THEN
            l_print_row_flag := 'Y';
          ELSE
            l_print_row_flag := 'N';
          END IF;
          --end add by liudan 2017/03/06
        ELSE
          l_print_row_flag := 'N';
        END IF;
        /*l_wip_amt := get_sum_by_mfg(p_project_id   => rec.project_id,
                                    p_top_task_id  => rec.top_task_id,
                                    p_group_parts  => rec.group_parts,
                                    p_sum_type     => g_wip);
        
        l_accual_amt := get_sum_by_mfg(p_project_id   => rec.project_id,
                                       p_top_task_id  => rec.top_task_id,
                                       p_group_parts  => rec.group_parts,
                                       p_sum_type     => g_accrual_type);
        
        
        IF l_wip_amt<= l_accual_amt THEN
          l_wip_offset := l_wip_amt;
        ELSE
          l_wip_offset := l_accual_amt;
        END IF;
        
        IF l_wip_offset <=0 THEN
          l_wip_offset := 0 ;
        END IF;
        
        l_wip_balance := l_wip_amt - l_wip_offset;
        l_accural_balance := l_accual_amt -l_wip_offset;
        
        IF l_wip_balance = 0 AND l_accural_balance = 0 THEN
           l_print_row_flag :='N';
        END IF;*/
      
        IF l_print_row_flag = 'Y' THEN
          output('<tr>');
          output_column(rec.project_type, g_type_text);
          output_column(rec.group_parts, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.proj_no, g_type_text);
          output_column(xxpa_proj_exp_item_ref_pkg.get_project_status(rec.project_id),
                        g_type_text);
          output_column(get_long_name(rec.project_id), g_type_text);
          output_column(xxpa_proj_exp_item_ref_pkg.get_mfg_spec(rec.mfg),
                        g_type_text);
          output_column(xxpa_proj_exp_item_ref_pkg.get_mfg_source(rec.project_id,
                                                                  rec.mfg),
                        g_type_text);
        
          output_column('', g_type_text);
        
          FOR amt IN cur_amt_by_mfg(p_project_id  => rec.project_id,
                                    p_key         => rec.top_task_id,
                                    p_group_parts => rec.group_parts) LOOP
          
            --output_column(amt.amt, g_type_text);
            /*IF amt.expen_type IN ('Price', 'Invoice') THEN
              output_column(amt.currency_amt, g_type_text);
              output_column(amt.currency, g_type_text);
            END IF;*/
          
            IF amt.expen_type = g_invoice_amt_type1 THEN
              l_invoice_amt_0 := amt.amt;
            ELSIF amt.expen_type = g_invoice_amt_type2 THEN
              l_invoice_amt_2 := amt.amt;
            ELSIF amt.expen_type = g_price_type THEN
              l_price := amt.amt;
            ELSIF amt.expen_type = g_cogs_type THEN
              l_cogs_amt := amt.amt;
            END IF;
          
            output_column(amt.amt, g_type_text);
            /*IF amt.expen_type IN ('Price', 'Invoice') THEN
              output_column(amt.currency_amt, g_type_text);
              output_column(amt.currency, g_type_text);
            END IF;*/
            IF amt.type = g_cogs_type THEN
              l_profit_amt := get_profit_amt(p_cogs_amt     => l_cogs_amt,
                                             p_invoice_amt0 => l_invoice_amt_0,
                                             p_invoice_amt2 => l_invoice_amt_2,
                                             p_price_amt    => l_price);
              output_column(l_profit_amt, g_type_text);
            END IF;
          
          END LOOP;
        
          output('</tr>');
        END IF;
      
      END LOOP;
    
    END IF;
  
    log('20.1 Start to report sales mfg ' ||
        to_char(SYSDATE, g_date_format));
  
    FOR sales_mfg IN cur_sales_mfg LOOP
      output('<tr>');
      output_column('', g_type_text);
      output_column('', g_type_text);
      IF g_summary_by = g_group_by_task THEN
        output_column('', g_type_text);
      END IF;
      output_column('', g_type_text);
      output_column('', g_type_text);
      output_column(sales_mfg.ar_invoice_number, g_type_text);
      output_column('', g_type_text);
      output_column('', g_type_text);
      output_column('', g_type_text);
      output_column('', g_type_text);
    
      FOR rec IN cur_expen_type LOOP
        IF rec.expen_type = g_invoice_amt_type1 THEN
          output_column(round(sales_mfg.amt1, g_round), g_type_text);
        ELSIF rec.expen_type = g_invoice_amt_type2 THEN
          output_column(round(sales_mfg.amt2, g_round), g_type_text);
        ELSE
          output_column('', g_type_text);
        END IF;
      
      END LOOP;
      output('</tr>');
    END LOOP;
  
    log('20.2 End to report sales mfg ' || to_char(SYSDATE, g_date_format));
  
    log('20.4. ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
    xxpa_proj_cost_rpt_pub.output_end;
  
  END;

  --add by jingjinghe 20180124 begin
  FUNCTION transfer_period(p_period_name IN VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN to_date(p_period_name, 'MON-YY');
  EXCEPTION
    WHEN OTHERS THEN
      RETURN to_date(p_period_name, 'YY-MON');
  END transfer_period;
  --add by jingjinghe 20180124 end

  PROCEDURE main(x_errbuf       OUT VARCHAR2,
                 x_retcode      OUT VARCHAR2,
                 p_org_name     IN VARCHAR2,
                 p_period       IN VARCHAR2,
                 p_summary_by   IN VARCHAR2,
                 p_profile_base IN VARCHAR2) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_request_id    NUMBER;
  BEGIN
    g_summary_by       := p_summary_by;
    g_org_name         := p_org_name;
    g_period           := p_period;
    g_period_date      := last_day(transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/) + 0.99999;
    g_period_date_from := transfer_period(g_period)/*to_date(g_period, 'MON-YY')*/;--modify by jingjing 2018-02-01
    g_profile_base     := p_profile_base;
  
    log('g_org_name         : ' || g_org_name);
    log('g_period           : ' || g_period);
    log('g_period_date      : ' || g_period_date);
    log('g_period_date_from : ' || g_period_date);
    log('g_summary_by       : ' || g_summary_by);
    log('g_profile_base     : ' || g_profile_base);
  
    log('10 collect ' || to_char(SYSDATE, g_date_format));
    collect_data;

    log('20 print   ' || to_char(SYSDATE, g_date_format));
    print_report;
  
    log('30 end     ' || to_char(SYSDATE, g_date_format));
  
    /*l_request_id := fnd_request.submit_request('XXPA', --short code
                                               'XXPAPCMRMAIL', --
                                               '',
                                               '',
                                               FALSE,
                                               g_request_id);
    COMMIT;
    IF l_request_id IS NULL OR l_request_id = 0 THEN
      xxfnd_api.set_message(p_app_name     => 'FND',
                            p_msg_name     => 'FND_GENERIC_MESSAGE',
                            p_token1       => 'MESSAGE',
                            p_token1_value => 'Submit Email Request Fail');
      RAISE fnd_api.g_exc_error;
    END IF;*/
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END main;
  /*Procedure Name:
        init_global
    Description:
        This procedure initializes global variables
    History:
        1.00  2016/7/27   hankin.gu     Creation
  ==================================================*/
  PROCEDURE init_global IS
  BEGIN
    -- get workflow outbound server name and reply-to address
    SELECT MAX(decode(lkp.lookup_code, 'OUTBOUND_SERVER_NAME', lkp.meaning)),
           MAX(decode(lkp.lookup_code, 'REPLY_TO', lkp.meaning))
      INTO g_smtp_host, g_from_email
      FROM xxfnd_lookups lkp
     WHERE lkp.lookup_type = 'XXFND_WF_MAILER_PARAMETER'
       AND lkp.enabled_flag = 'Y'
       AND SYSDATE >= nvl(lkp.start_date_active, trunc(SYSDATE))
       AND SYSDATE < nvl(lkp.end_date_active, trunc(SYSDATE) + 1);
  EXCEPTION
    WHEN no_data_found THEN
      xxfnd_conc_utl.log_msg('Lookup XXFND_WF_MAILER_PARAMETER is not setup properly.');
      RAISE fnd_api.g_exc_error;
  END init_global;
  PROCEDURE mail_main(errbuf       OUT VARCHAR2,
                      retcode      OUT VARCHAR2,
                      p_request_id IN NUMBER) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  
    l_receipts VARCHAR2(2000);
    l_cc       VARCHAR2(2000);
    l_bcc      VARCHAR2(2000);
    l_subject  VARCHAR2(200) := 'XXPA:Project COGS Monthly Report(SHE)';
    CURSOR cur_recipients IS
      SELECT flv.meaning
        FROM fnd_lookup_values_vl flv
       WHERE 1 = 1
         AND flv.lookup_type = 'XXPA_MON_DATA_EMAIL_ADDRESS'
         AND flv.enabled_flag = 'Y'
         AND SYSDATE BETWEEN flv.start_date_active AND
             nvl(flv.end_date_active, SYSDATE);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body
    init_global;
    xxbom_mail_attachment_pkg.init_global;
    FOR r IN cur_recipients LOOP
      IF l_receipts IS NULL THEN
        l_receipts := r.meaning;
      ELSE
        l_receipts := l_receipts || ',' || r.meaning;
      END IF;
    
    END LOOP;
    -- Call the procedure
    log('l_recipients:' || l_receipts);
    log('g_from_email:' || g_from_email);
    log('l_subject:' || l_subject);
    log('p_request_id:' || p_request_id);
    xxbom_mail_attachment_pkg.attachment_mail(p_sender         => g_from_email,
                                              p_recipients     => l_receipts,
                                              p_cc             => NULL,
                                              p_bcc            => NULL,
                                              p_subject        => l_subject,
                                              p_body           => 'Please check out the attachment for results of the report. ',
                                              p_directory      => NULL,
                                              p_request_id     => p_request_id,
                                              p_mime_type      => NULL,
                                              p_destcset       => NULL,
                                              x_process_status => l_return_status,
                                              x_process_msg    => l_msg_data);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    -- conc end body
    -- concurrent footer log
    xxfnd_conc_utl.log_footer;
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '1';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first,
                                             p_encoded   => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first,
                                             p_encoded   => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                              p_procedure_name => 'MAIL_MAIN',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END mail_main;

END xxpa_proj_cogs_mon_rpt3_pkg;
/
