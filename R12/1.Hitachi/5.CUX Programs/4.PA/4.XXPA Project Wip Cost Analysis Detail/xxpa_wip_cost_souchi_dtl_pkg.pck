CREATE OR REPLACE PACKAGE xxpa_wip_cost_souchi_dtl_pkg IS

  /*==================================================
  Program Name:
      xxpa_wip_cost_souchi_dtl_pkg
  Description:
      This program provide concurrent main procedure to perform:
  History:
      1.00  2017-04-06 21:54:10  Steven.Wang  Creation        
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

  g_type_text   CONSTANT VARCHAR2(40) := 'TEXT';
  g_type_amount CONSTANT VARCHAR2(40) := 'AMOUNT';

  g_begin_date DATE := SYSDATE;
  FUNCTION generate_gp_souchi(p_expenditure_item_id IN NUMBER) RETURN VARCHAR2;
  --main
  PROCEDURE main(x_errbuf          OUT VARCHAR2,
                 x_retcode         OUT VARCHAR2,
                 p_organization_id IN VARCHAR2,
                 p_date_from       IN VARCHAR2,
                 p_date_to         IN VARCHAR2,
                 p_project_id      IN NUMBER,
                 p_top_task_id     IN NUMBER,
                 p_project_id2     IN NUMBER,
                 p_top_task_id2    IN NUMBER,
                 p_project_id3     IN NUMBER,
                 p_top_task_id3    IN NUMBER,
                 p_project_id4     IN NUMBER,
                 p_top_task_id4    IN NUMBER,
                 p_project_id5     IN NUMBER,
                 p_top_task_id5    IN NUMBER,
                 p_group_part      IN VARCHAR2);

END xxpa_wip_cost_souchi_dtl_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxpa_wip_cost_souchi_dtl_pkg IS

  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxpa_wip_cost_souchi_dtl_pkg
  Description:
      This program provide concurrent main procedure to perform:
  History:
      1.00  2017-04-06 21:54:10  Steven.Wang  Creation
      2.00  2017-10-30 00:00:00  Jingjing.He  Update adjust the order of some solumns
                                              enter multipule MFGs at one time
      3.00  2018-04-05 16:31:45  Jingjing.he
      3.01  2018-07-30           Hakim        add log                                                
  ==================================================*/

  g_org_name     VARCHAR2(40);
  g_group_part   VARCHAR2(240);
  g_ou_name      VARCHAR2(40);
  g_date_from    DATE;
  g_date_to      DATE;
  g_project_id   NUMBER;
  g_top_task_id  NUMBER;
  g_project_id2  NUMBER;
  g_top_task_id2 NUMBER; --add by jingjing.he 2017-10-30
  g_project_id3  NUMBER; --add by jingjing.he 2017-10-30
  g_top_task_id3 NUMBER; --add by jingjing.he 2017-10-30
  g_project_id4  NUMBER; --add by jingjing.he 2017-10-30
  g_top_task_id4 NUMBER; --add by jingjing.he 2017-10-30
  g_project_id5  NUMBER; --add by jingjing.he 2017-10-30
  g_top_task_id5 NUMBER; --add by jingjing.he 2017-10-30
  --g_user_id         NUMBER := fnd_global.user_id;
  --g_sysdate         DATE := SYSDATE;
  --g_login_id        NUMBER := fnd_global.login_id;
  g_pkg_name        VARCHAR2(30) := 'XXPA_WIP_COST_SOUCHI_DTL_PKG';
  g_org_id          NUMBER;
  g_organization_id NUMBER;
  TYPE v_souchi IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;
  t_souchi v_souchi;
  TYPE v_group_part IS TABLE OF VARCHAR2(300) INDEX BY VARCHAR2(10);
  t_group_part v_group_part;
  TYPE item_gp_type IS RECORD(
    gp     VARCHAR2(240),
    souchi VARCHAR2(240));
  TYPE v_item_gp IS TABLE OF item_gp_type INDEX BY BINARY_INTEGER;
  t_item_gp v_item_gp;

  PROCEDURE output(p_msg VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_msg);
  END;

  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_content);
  END log;

  FUNCTION transform_text(p_column_text VARCHAR2) RETURN VARCHAR2 IS
    l_column_text VARCHAR2(500);
  BEGIN
  
    l_column_text := REPLACE(REPLACE(REPLACE(REPLACE(p_column_text, '&', '&amp;'), '>', '&gt;'), '<', '&lt;'),
                             '"',
                             '&quot;');
  
    RETURN l_column_text;
  
  END;
  PROCEDURE output_head( -- report title
                        p_title VARCHAR2) IS
    -- report title
    l_title VARCHAR2(2000) := '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" >' ||
                              '<head> <title>p_title</title>' ||
                              ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8">' ||
                              '<style>  .cell{font-family:Arial} *{font-size:10.0pt;mso-font-charset:134;}  .cell{border:solid 1px; border-color:#000000;}</style>' ||
                              ' </head> <body>' ||
                              ' <p align=center style="font-weight:bold;"><font size="4">p_title</font></p>';
  
    -- request title
    /* l_request_parameters VARCHAR2(1000) := ' <table width=100% border=0 cellspacing=0 cellpadding=0' ||
    ' tyle="BORDER-COLLAPSE: collapse ">' ||
    ' <tr style="font-weight:bold;">';*/
  
    -- column title
    l_column_title VARCHAR2(4000) := ' <table width=100% border=1 cellspacing=0 cellpadding=0' ||
                                     ' tyle="BORDER-COLLAPSE: collapse ">';
  
    /*  l_column_td VARCHAR2(200) := ' <td align=left><font size="3">p_column_title</font></td>';
    */
    /* l_head_html VARCHAR2(5200);*/
  
    /* l_req_para_sql VARCHAR2(240) := 'BEGIN
      xxfnd_html_pub2.output_req_para(:1);
    END;';*/
    /*    l_col_para_sql VARCHAR2(240) := 'BEGIN
      xxfnd_html_pub2.output_col_title(:1);
    END;';*/
  
  BEGIN
  
    -- Report Title
    l_title := REPLACE(l_title, 'p_title', p_title);
    output(l_title);
  
    output(l_column_title);
  
  END;

  PROCEDURE output_col_title(p_column_title VARCHAR2,
                             p_col_span     NUMBER DEFAULT 1) IS
    l_column_td    VARCHAR2(200) := ' <td align=left colspan=cols_pan ><font size="3">p_column_title</font></td>';
    l_column_title VARCHAR2(300);
  BEGIN
    IF p_column_title IS NOT NULL THEN
    
      l_column_td    := REPLACE(l_column_td, 'cols_pan', p_col_span);
      l_column_title := REPLACE(l_column_td, 'p_column_title', nvl(p_column_title, g_space));
      output(l_column_title);
    END IF;
  END;

  PROCEDURE output_text(p_column_text VARCHAR2,
                        p_bold_flag   VARCHAR2 := 'N') IS
    l_column_td    VARCHAR2(500) := ' <td align=left >column_text</td>';
    l_column_b_td  VARCHAR2(500) := ' <td align=left ><b>column_text</b></td>';
    l_column_text  VARCHAR2(500);
    l_column_text2 VARCHAR2(500);
  BEGIN
  
    l_column_text := transform_text(p_column_text);
  
    IF p_bold_flag = 'Y' THEN
      l_column_text2 := REPLACE(l_column_b_td, 'column_text', nvl(l_column_text, g_space));
    ELSE
      l_column_text2 := REPLACE(l_column_td, 'column_text', nvl(l_column_text, g_space));
    END IF;
    output(l_column_text2);
  
  END;

  PROCEDURE output_amount(p_amount    VARCHAR2,
                          p_bold_flag VARCHAR2 := 'N') IS
    l_column_td   VARCHAR2(500) := ' <td align=right>column_text</td>';
    l_column_b_td VARCHAR2(500) := ' <td align=right><b>column_text</b></td>';
    l_column_text VARCHAR2(500);
  BEGIN
  
    IF p_bold_flag = 'Y' THEN
      l_column_text := REPLACE(l_column_b_td, 'column_text', nvl(xxpa_utils.format_amount(p_amount), g_space));
    ELSE
      l_column_text := REPLACE(l_column_td, 'column_text', nvl(xxpa_utils.format_amount(p_amount), g_space));
    END IF;
    output(l_column_text);
  
  END;

  PROCEDURE output_column(p_column_text VARCHAR2,
                          p_column_type VARCHAR2) IS
  BEGIN
  
    IF p_column_text != chr(0) OR p_column_text IS NULL THEN
      IF p_column_type = g_type_text THEN
        output_text(p_column_text);
      ELSIF p_column_type = g_type_amount THEN
        output_amount(p_column_text);
      END IF;
    END IF;
  
  END output_column;

  FUNCTION get_assembly_gp(p_expenditure_item_id IN NUMBER,
                           p_inventory_item_id   IN NUMBER,
                           p_organization_id     IN NUMBER,
                           p_project_id          IN NUMBER,
                           p_task_id             IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_assembly_gp2 IS
      SELECT msc.category_concat_segs gp,
             msib.attribute20         souchi
        FROM wip_requirement_operations wro,
             wip_discrete_jobs          wdj,
             apps.mtl_system_items_b    msib,
             apps.mtl_item_categories_v msc
       WHERE msc.inventory_item_id = wdj.primary_item_id
         AND msc.organization_id = wdj.organization_id
         AND msib.inventory_item_id = wdj.primary_item_id
         AND msib.organization_id = wdj.organization_id
         AND msc.category_set_name = 'GSCM Item Category Set'
         AND wdj.wip_entity_id = wro.wip_entity_id
         AND wdj.organization_id = wro.organization_id
         AND wro.inventory_item_id = p_inventory_item_id
         AND wro.organization_id = p_organization_id
         AND wdj.project_id = p_project_id
         AND wdj.task_id = p_task_id
       ORDER BY msib.segment1 ASC;
    CURSOR cur_inv_item IS
      SELECT msc.category_concat_segs gp,
             msib.attribute20         souchi,
             msib.item_type
        FROM apps.mtl_item_categories_v msc,
             apps.mtl_system_items_b    msib
       WHERE msc.inventory_item_id = p_inventory_item_id
         AND msc.organization_id = p_organization_id
         AND msib.inventory_item_id = p_inventory_item_id
         AND msib.organization_id = p_organization_id
         AND msc.category_set_name = 'GSCM Item Category Set';
  BEGIN
  
    log(to_char(SYSDATE, 'yyyymmddhh24miss'));
    log(p_inventory_item_id);
  
    IF t_item_gp.exists(p_inventory_item_id) THEN
      t_souchi(p_expenditure_item_id) := t_item_gp(p_inventory_item_id).souchi;
      RETURN t_item_gp(p_inventory_item_id).gp;
    END IF;
  
    FOR rec_inv IN cur_inv_item
    LOOP
      IF rec_inv.item_type = 'FG' THEN
        t_souchi(p_expenditure_item_id) := rec_inv.souchi;
        t_item_gp(p_inventory_item_id).souchi := rec_inv.souchi;
        t_item_gp(p_inventory_item_id).gp := rec_inv.gp;
        RETURN rec_inv.gp;
        EXIT;
      ELSE
        FOR rec_gp IN cur_assembly_gp2
        LOOP
          t_souchi(p_expenditure_item_id) := rec_gp.souchi;
          t_item_gp(p_inventory_item_id).souchi := rec_gp.souchi;
          t_item_gp(p_inventory_item_id).gp := rec_gp.gp;
          RETURN rec_gp.gp;
          EXIT;
        END LOOP;
      END IF;
    END LOOP;
  
    t_souchi(p_expenditure_item_id) := NULL;
  
    RETURN NULL;
  END get_assembly_gp;

  FUNCTION generate_gp_souchi(p_expenditure_item_id IN NUMBER) RETURN VARCHAR2 IS
  
    l_gp       VARCHAR2(240);
    l_souchi   VARCHAR2(240);
    l_wip_type VARCHAR2(240);
    CURSOR cur_gp_souchi IS
      SELECT t.expenditure_item_id,
             t.project_id,
             t.task_id,
             t.transaction_source,
             t.system_linkage_function,
             t.orig_transaction_reference,
             t.attribute9                 gp,
             t.attribute1                 souchi,
             t.document_distribution_id
        FROM pa.pa_expenditure_items_all t
       WHERE t.expenditure_item_id = p_expenditure_item_id;
    CURSOR cur_mmt(p_orig_transaction_reference IN NUMBER) IS
      SELECT mmt.transaction_type_id,
             mmt.transaction_source_type_id,
             mmt.inventory_item_id,
             mmt.transaction_source_id,
             mmt.organization_id,
             mmt.trx_source_line_id
        FROM apps.mtl_material_transactions mmt
       WHERE p_orig_transaction_reference = mmt.transaction_id;
    CURSOR cur_inv(p_document_distribution_id IN NUMBER) IS
      SELECT pda.po_distribution_id,
             pda.destination_type_code,
             pda.req_distribution_id,
             ail.attribute15                 ail_attribute15,
             ail.attribute1                  ail_attribute1,
             prl.attribute1                  prl_attribute1,
             pda.attribute15                 pda_attribute15,
             prl.attribute2                  prl_attribute2,
             pda.attribute1                  pda_attribute1,
             pla.item_id,
             pda.destination_organization_id
        FROM apps.ap_invoice_distributions_all aid,
             apps.ap_invoice_lines_all         ail,
             apps.po_lines_all                 pla,
             apps.po_distributions_all         pda,
             po_req_distributions_all          prd,
             po_requisition_lines_all          prl
       WHERE p_document_distribution_id = aid.invoice_distribution_id
         AND aid.po_distribution_id = pda.po_distribution_id(+)
         AND pda.req_distribution_id = prd.distribution_id(+)
         AND prd.requisition_line_id = prl.requisition_line_id(+)
         AND aid.invoice_id = ail.invoice_id
         AND aid.invoice_line_number = ail.line_number
         AND pda.po_line_id = pla.po_line_id(+);
  
    CURSOR cur_wip(p_orig_transaction_reference IN NUMBER) IS
      SELECT msc.category_concat_segs gp,
             msib.attribute20         souchi
        FROM apps.wip_transactions      wt,
             apps.mtl_system_items_b    msib,
             apps.mtl_item_categories_v msc,
             apps.wip_discrete_jobs     wdj
       WHERE wt.transaction_id = p_orig_transaction_reference
         AND wt.wip_entity_id = wdj.wip_entity_id
         AND wt.organization_id = wdj.organization_id
         AND msib.inventory_item_id = wdj.primary_item_id
         AND msib.organization_id = wdj.organization_id
         AND msc.inventory_item_id = wdj.primary_item_id
         AND msc.organization_id = wdj.organization_id
         AND msc.category_set_name = 'GSCM Item Category Set';
    CURSOR cur_inv_wip(p_transaction_source_id IN NUMBER,
                       p_organization_id       IN NUMBER) IS
      SELECT msc.category_concat_segs gp,
             msib.attribute20         souchi
        FROM apps.mtl_item_categories_v msc,
             apps.mtl_system_items_b    msib,
             apps.wip_discrete_jobs     wdj
       WHERE msc.inventory_item_id = wdj.primary_item_id
         AND msc.organization_id = wdj.organization_id
         AND msib.inventory_item_id = wdj.primary_item_id
         AND msib.organization_id = wdj.organization_id
         AND msc.category_set_name = 'GSCM Item Category Set'
         AND p_transaction_source_id = wdj.wip_entity_id
         AND p_organization_id = wdj.organization_id;
  
  BEGIN
    FOR rec IN cur_gp_souchi
    LOOP
      IF rec.transaction_source = 'Inventory' THEN
        FOR rec_mmt IN cur_mmt(rec.orig_transaction_reference)
        LOOP
        
          IF rec_mmt.transaction_type_id = 52 THEN
            --sale pick
            l_wip_type := 'WIP6';
            SELECT ool.attribute5
              INTO l_gp
              FROM apps.oe_order_lines_all ool
             WHERE rec_mmt.trx_source_line_id = ool.line_id;
          ELSIF rec_mmt.transaction_source_type_id = 5 THEN
            --wip
            l_wip_type := 'WIP1';
            FOR rec_inv_wip IN cur_inv_wip(rec_mmt.transaction_source_id, rec_mmt.organization_id)
            LOOP
              l_gp     := rec_inv_wip.gp;
              l_souchi := rec_inv_wip.souchi;
            END LOOP;
          ELSE
            --others
            l_wip_type := 'WIP1';
            l_gp       := get_assembly_gp(p_expenditure_item_id => rec.expenditure_item_id,
                                          p_inventory_item_id   => rec_mmt.inventory_item_id,
                                          p_organization_id     => rec_mmt.organization_id,
                                          p_project_id          => rec.project_id,
                                          p_task_id             => rec.task_id);
            l_souchi   := t_souchi(p_expenditure_item_id);
          END IF;
        
        END LOOP;
      ELSIF rec.transaction_source = 'Work In Process' THEN
        l_wip_type := 'WIP2';
        FOR rec_wip IN cur_wip(rec.orig_transaction_reference)
        LOOP
          l_gp     := rec_wip.gp;
          l_souchi := rec_wip.souchi;
        END LOOP;
      ELSIF rec.system_linkage_function = 'PJ' THEN
        l_wip_type := 'WIP3';
        l_gp       := rec.gp;
        l_souchi   := rec.souchi;
      ELSIF rec.system_linkage_function = 'VI' THEN
        FOR rec_inv IN cur_inv(rec.document_distribution_id)
        LOOP
          IF rec_inv.po_distribution_id IS NULL THEN
            l_wip_type := 'WIP7';
            l_gp       := rec_inv.ail_attribute15;
            l_souchi   := rec_inv.ail_attribute1;
          ELSIF rec_inv.item_id IS NOT NULL THEN
            l_wip_type := 'WIP11';
            l_gp       := get_assembly_gp(p_expenditure_item_id => rec.expenditure_item_id,
                                          p_inventory_item_id   => rec_inv.item_id,
                                          p_organization_id     => rec_inv.destination_organization_id,
                                          p_project_id          => rec.project_id,
                                          p_task_id             => rec.task_id);
            l_souchi   := t_souchi(p_expenditure_item_id);
          ELSIF rec_inv.req_distribution_id IS NULL THEN
            l_wip_type := 'WIP4';
            l_gp       := rec_inv.pda_attribute15;
            l_souchi   := rec_inv.pda_attribute1;
          ELSE
            l_wip_type := 'WIP5';
            l_gp       := nvl(rec_inv.prl_attribute1, rec_inv.pda_attribute15);
            l_souchi   := nvl(rec_inv.prl_attribute2, rec_inv.pda_attribute1);
          END IF;
        END LOOP;
      END IF;
    
    END LOOP;
    t_souchi(p_expenditure_item_id) := l_souchi;
    RETURN l_gp;
  
  END generate_gp_souchi;

  PROCEDURE split_group_part(p_group_part IN VARCHAR2) IS
  
    l_sep_pos   NUMBER;
    l_sep       VARCHAR2(10) := ',';
    l_start_idx NUMBER := 1;
    l_str       VARCHAR2(240);
  BEGIN
    l_sep_pos := instr(p_group_part, l_sep);
    WHILE (l_sep_pos > 0)
    LOOP
    
      l_str := substr(p_group_part, l_start_idx, l_sep_pos - l_start_idx);
      l_start_idx := l_sep_pos + 1;
      l_sep_pos := instr(p_group_part, l_sep, l_start_idx);
      t_group_part(l_str) := 'Y';
      --INSERT INTO XXPA_WIP_COST_GP_TEMP (gp) VALUES (l_str);
    END LOOP;
    l_str := substr(p_group_part, l_start_idx, length(p_group_part) - l_start_idx + 1);
    t_group_part(l_str) := 'Y';
    --INSERT INTO XXPA_WIP_COST_GP_TEMP (gp) VALUES (l_str);
  
  END split_group_part;

  PROCEDURE collect_data(p_project_id  IN NUMBER,
                         p_top_task_id IN NUMBER) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'collect_data';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_collect_data01';
    l_group_part                   VARCHAR2(240);
    l_xxpa_wip_cost_souchi_dtl_tmp xxpa_wip_cost_souchi_dtl_tmp%ROWTYPE;
  
    l_souchi VARCHAR2(240);
  
    CURSOR cur(p_project_id  NUMBER,
               p_top_task_id NUMBER) IS
      SELECT /*+  leading(cdl) index(cdl PA_COST_DISTRIBUTION_LINES_N8)*/
       'WIP' TYPE,
       hou.name org,
       to_char(pei.expenditure_item_id) expenditure_item_id,
       pa.project_type,
       pa.segment1 proj_no,
       
       mfg.task_number mfg,
       pt.task_number task,
       xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id) group_parts,
       pet.expenditure_category expen_cate,
       xxpa_proj_exp_item_ref_pkg.get_expen_type(p_expenditure_item_id => pei.expenditure_item_id,
                                                 p_organization_id     => hou.organization_id) expen_type,
       cdl.gl_date,
       pei.project_currency_code,
       pei.quantity qty,
       xxpa_proj_exp_item_ref_pkg.get_mfg_source(pei.project_id, mfg.task_number) mfg_source,
       xxpa_proj_exp_item_ref_pkg.get_project_status(pei.project_id) project_status,
       xxpa_proj_exp_item_ref_pkg.get_mfg_spec(mfg.task_number) mfg_spec,
       pei.project_burdened_cost amt,
       pei.project_burdened_cost currency_amt,
       xei.po_number po_number,
       
       xei.po_line po_line,
       xei.transaction_source transaction_source,
       xei.orginal_trans_ref orginal_trans_ref,
       xei.original_user_expnd_transf_ref original_user_expnd_transf_ref,
       xei.expenditure_group expenditure_batch,
       xei.expenditure_comment expenditure_comment,
       xei.dff dff,
       xxpa_proj_exp_item_ref_pkg.get_transaction_type(pei.expenditure_item_id, 'WIP', NULL) transaction_type,
       xxpa_proj_exp_item_ref_pkg.get_material_job(pei.expenditure_item_id, 'WIP', NULL) job_number,
       xxpa_proj_exp_item_ref_pkg.get_item_number('WIP', pei.expenditure_item_id, NULL) item_number,
       xxpa_proj_exp_item_ref_pkg.get_material_job_type(pei.expenditure_item_id, 'WIP', NULL) job_type,
       NULL so_invoice,
       xxpa_proj_exp_item_ref_pkg.get_project_long_name(pei.project_id) project_long_name,
       pt.project_id,
       pt.task_id,
       NULL souchi
        FROM apps.pa_expenditure_items_all  pei,
             apps.pa_expenditures_all       pe,
             apps.pa_expenditure_types      pet,
             apps.hr_organization_units     hou,
             apps.pa_projects_all           pa,
             apps.pa_project_types_all      ppt,
             apps.pa_tasks                  pt,
             apps.pa_tasks                  mfg,
             pa_cost_distribution_lines_all cdl,
             apps.xxpa_exp_items_expend_v   xei
       WHERE nvl(pei.override_to_organization_id, pe.incurred_by_organization_id) = hou.organization_id
         AND pei.expenditure_id = pe.expenditure_id
         AND pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pei.project_id = pa.project_id
         AND pt.top_task_id = mfg.task_id
         AND pa.project_type = ppt.project_type
         AND pet.expenditure_category != 'FG Completion'
            /* AND nvl(ppt.attribute7, -1) != 'OVERSEA'*/
         AND cdl.line_type <> 'I'
         AND (cdl.expenditure_item_id = pei.expenditure_item_id)
         AND pei.expenditure_item_id = xei.expenditure_item_id(+)
         AND hou.name = g_org_name
         AND (cdl.gl_date >= g_date_from OR g_date_from IS NULL)
         AND cdl.gl_date <= g_date_to
            --modify by jingjing.he 2017-10-30 start
         AND ((pa.project_id = p_project_id OR p_project_id IS NULL) AND
              (pt.top_task_id = p_top_task_id OR p_top_task_id IS NULL))
      --modify by jingjing.he 2017-10-30 end
      
      /*AND (EXISTS (SELECT 1
         FROM xxpa_wip_cost_gp_temp xwg
        WHERE xwg.gp =
              xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id)) OR
      g_group_part IS NULL)*/
      /*UNION ALL
      
      SELECT xpan.type TYPE,
             xpan.org,
             to_char(xpan.expenditure_item_id) expenditure_item_id,
             -- xpan.expenditure_item_id,
             xpan.project_type,
             xpan.proj_no,
             xpan.mfg,
             xpan.task,
             xpan.group_parts,
             xpan.expen_cate,
             xpan.expen_type,
             xpan.gl_date,
             xpan.currency_code project_currency_code,
             xpan.qty,
             xxpa_proj_exp_item_ref_pkg.get_mfg_source(xpan.project_id,
                                                       xpan.mfg) mfg_source,
             xxpa_proj_exp_item_ref_pkg.get_project_status(xpan.project_id) project_status,
             xxpa_proj_exp_item_ref_pkg.get_mfg_spec(xpan.mfg) mfg_spec,
             xpan.amt,
             xpan.currency_amt,
             NULL po_number,
             NULL po_line,
             NULL transaction_source,
             xpan.transaction_id || '' orginal_trans_ref,
             NULL riginal_user_expnd_transf_ref,
             NULL expenditure_batch,
             NULL expenditure_comment,
             NULL dff,
             NULL transaction_type,
             xpan.job job_number
             
            ,
             xxpa_proj_exp_item_ref_pkg.get_item_number(NULL,
                                                        NULL,
                                                        xpan.transaction_id) item_number,
             xpan.job_type,
             NULL so_invoice,
             xxpa_proj_exp_item_ref_pkg.get_project_long_name(xpan.project_id) project_long_name,
             xpan.project_id,
             xpan.task_id,
             xpan.souchi
        FROM xxpa_wip_cost_souchi_ne_v xpan
       WHERE xpan.org = g_org_name
         AND (xpan.gl_date >= g_date_from OR g_date_from IS NULL)
         AND xpan.gl_date <= g_date_to
         AND (xpan.project_id = g_project_id OR g_project_id IS NULL)
         AND (xpan.top_task_id = g_top_task_id OR g_top_task_id IS NULL)
         AND (EXISTS
              (SELECT 1
                 FROM xxpa_wip_cost_gp_temp xwg
                WHERE xwg.gp = xpan.group_parts) OR g_group_part IS NULL)*/
      ;
    --for performance same sql different hint
    CURSOR cur_project(p_project_id  NUMBER,
                       p_top_task_id NUMBER) IS
      SELECT 'WIP' TYPE,
             hou.name org,
             to_char(pei.expenditure_item_id) expenditure_item_id,
             pa.project_type,
             pa.segment1 proj_no,
             mfg.task_number mfg,
             pt.task_number task,
             xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id) group_parts,
             pet.expenditure_category expen_cate,
             xxpa_proj_exp_item_ref_pkg.get_expen_type(p_expenditure_item_id => pei.expenditure_item_id,
                                                       p_organization_id     => hou.organization_id) expen_type,
             cdl.gl_date,
             pei.project_currency_code,
             pei.quantity qty,
             xxpa_proj_exp_item_ref_pkg.get_mfg_source(pei.project_id, mfg.task_number) mfg_source,
             xxpa_proj_exp_item_ref_pkg.get_project_status(pei.project_id) project_status,
             xxpa_proj_exp_item_ref_pkg.get_mfg_spec(mfg.task_number) mfg_spec,
             pei.project_burdened_cost amt,
             pei.project_burdened_cost currency_amt,
             xei.po_number po_number,
             
             xei.po_line po_line,
             xei.transaction_source transaction_source,
             xei.orginal_trans_ref orginal_trans_ref,
             xei.original_user_expnd_transf_ref original_user_expnd_transf_ref,
             xei.expenditure_group expenditure_batch,
             xei.expenditure_comment expenditure_comment,
             xei.dff dff,
             xxpa_proj_exp_item_ref_pkg.get_transaction_type(pei.expenditure_item_id, 'WIP', NULL) transaction_type,
             xxpa_proj_exp_item_ref_pkg.get_material_job(pei.expenditure_item_id, 'WIP', NULL) job_number,
             xxpa_proj_exp_item_ref_pkg.get_item_number('WIP', pei.expenditure_item_id, NULL) item_number,
             xxpa_proj_exp_item_ref_pkg.get_material_job_type(pei.expenditure_item_id, 'WIP', NULL) job_type,
             NULL so_invoice,
             xxpa_proj_exp_item_ref_pkg.get_project_long_name(pei.project_id) project_long_name,
             pt.project_id,
             pt.task_id,
             NULL souchi
        FROM apps.pa_expenditure_items_all  pei,
             apps.pa_expenditures_all       pe,
             apps.pa_expenditure_types      pet,
             apps.hr_organization_units     hou,
             apps.pa_projects_all           pa,
             apps.pa_project_types_all      ppt,
             apps.pa_tasks                  pt,
             apps.pa_tasks                  mfg,
             pa_cost_distribution_lines_all cdl,
             apps.xxpa_exp_items_expend_v   xei
       WHERE nvl(pei.override_to_organization_id, pe.incurred_by_organization_id) = hou.organization_id
         AND pei.expenditure_id = pe.expenditure_id
         AND pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pei.project_id = pa.project_id
         AND pt.top_task_id = mfg.task_id
         AND pa.project_type = ppt.project_type
         AND pet.expenditure_category != 'FG Completion'
            /* AND nvl(ppt.attribute7, -1) != 'OVERSEA'*/
         AND cdl.line_type <> 'I'
         AND (cdl.expenditure_item_id = pei.expenditure_item_id)
         AND pei.expenditure_item_id = xei.expenditure_item_id(+)
         AND hou.name = g_org_name
         AND (cdl.gl_date >= g_date_from OR g_date_from IS NULL)
         AND cdl.gl_date <= g_date_to
            --modify by jingjing.he 2017-10-30 start
         AND ((pa.project_id = p_project_id OR p_project_id IS NULL) AND
              (pt.top_task_id = p_top_task_id OR p_top_task_id IS NULL))
      --modify by jingjing.he 2017-10-30 end
      
      /*UNION ALL
      
      SELECT xpan.type TYPE,
             xpan.org,
             to_char(xpan.expenditure_item_id) expenditure_item_id,
             -- xpan.expenditure_item_id,
             xpan.project_type,
             xpan.proj_no,
             xpan.mfg,
             xpan.task,
             xpan.group_parts,
             xpan.expen_cate,
             xpan.expen_type,
             xpan.gl_date,
             xpan.currency_code project_currency_code,
             xpan.qty,
             xxpa_proj_exp_item_ref_pkg.get_mfg_source(xpan.project_id,
                                                       xpan.mfg) mfg_source,
             xxpa_proj_exp_item_ref_pkg.get_project_status(xpan.project_id) project_status,
             xxpa_proj_exp_item_ref_pkg.get_mfg_spec(xpan.mfg) mfg_spec,
             xpan.amt,
             xpan.currency_amt,
             NULL po_number,
             NULL po_line,
             NULL transaction_source,
             xpan.transaction_id || '' orginal_trans_ref,
             NULL riginal_user_expnd_transf_ref,
             NULL expenditure_batch,
             NULL expenditure_comment,
             NULL dff,
             NULL transaction_type,
             xpan.job job_number
             
            ,
             xxpa_proj_exp_item_ref_pkg.get_item_number(NULL,
                                                        NULL,
                                                        xpan.transaction_id) item_number,
             xpan.job_type,
             NULL so_invoice,
             xxpa_proj_exp_item_ref_pkg.get_project_long_name(xpan.project_id) project_long_name,
             xpan.project_id,
             xpan.task_id,
             xpan.souchi
        FROM xxpa_wip_cost_souchi_ne_v xpan
       WHERE xpan.org = g_org_name
         AND (xpan.gl_date >= g_date_from OR g_date_from IS NULL)
         AND xpan.gl_date <= g_date_to
         AND (xpan.project_id = g_project_id OR g_project_id IS NULL)
         AND (xpan.top_task_id = g_top_task_id OR g_top_task_id IS NULL)
         AND (EXISTS
              (SELECT 1
                 FROM xxpa_wip_cost_gp_temp xwg
                WHERE xwg.gp = xpan.group_parts) OR g_group_part IS NULL)*/
      ;
  
    /*    CURSOR cur_tmp IS
    SELECT *
      FROM xxpa_wip_cost_souchi_dtl_tmp t
     WHERE 1 = 1
       AND t.request_id = g_request_id
     ORDER BY t.proj_no,
              t.task,
              t.group_parts,
              t.souchi,
              t.expen_cate,
              t.expen_type,
              t.gl_date;*/
  
  BEGIN
    /*    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;*/
  
    /*output_head('Project Wip Cost Analysis Detail');
    log('10. ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
    output('<tr bgcolor="#FFAF60">');
    output_col_title('Org');
    output_col_title('Project Type');
    output_col_title('Proj No'); --todo1
    output_col_title('Task'); --todo2
    output_col_title('Parts'); --todo3
    output_col_title('Souchi'); --todo4
    output_col_title('Expen Cate'); --todo5
    output_col_title('Expen Type'); --todo6
    output_col_title('Gl Date'); --todo7
    output_col_title('Project Status');
    output_col_title('Mfg');
    output_col_title('Project Currency Code');
    output_col_title('Quantity');
    output_col_title('Amt');
    output_col_title('Currency Amt');
    output_col_title('Expenditure Item Id');
    output_col_title('Expenditure Batch');
    output_col_title('Transaction Source');
    output_col_title('Orginal Trans Ref');
    output_col_title('Original User Expnd Transf Ref');
    output_col_title('Transaction Type');
    output_col_title('Job Number');
    output_col_title('Po Number');
    output_col_title('Po Line');
    --output_col_title('Mfg Model');
    
    output_col_title('Mfg Spec');
    output_col_title('Comment');
    output_col_title('Item Number');
    output_col_title('Dff');
    
    output_col_title('Job Type');
    output_col_title('So Invoice');
    output_col_title('Project Long Name');
    output('</tr>');
    log('20. ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));*/
  
    --10 create a tmp table
    --20 insert these data in the tmp table
    --30 get the data from the tmp table
  
    --DELETE FROM xxpa_wip_cost_souchi_dtl_tmp;
    IF p_project_id IS NOT NULL OR p_top_task_id IS NOT NULL THEN
      FOR rec IN cur_project(p_project_id, p_top_task_id)
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id); --modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          IF rec.expenditure_item_id IS NOT NULL THEN
            l_souchi := t_souchi(rec.expenditure_item_id);
          ELSE
            l_souchi := rec.souchi;
          END IF;
          l_xxpa_wip_cost_souchi_dtl_tmp.type                           := rec.type;
          l_xxpa_wip_cost_souchi_dtl_tmp.org                            := rec.org;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_item_id            := rec.expenditure_item_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_type                   := rec.project_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.proj_no                        := rec.proj_no;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg                            := rec.mfg;
          l_xxpa_wip_cost_souchi_dtl_tmp.task                           := rec.task;
          l_xxpa_wip_cost_souchi_dtl_tmp.group_parts                    := rec.group_parts;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_cate                     := rec.expen_cate;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_type                     := rec.expen_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.gl_date                        := rec.gl_date;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_currency_code          := rec.project_currency_code;
          l_xxpa_wip_cost_souchi_dtl_tmp.qty                            := rec.qty;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_source                     := rec.mfg_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_status                 := rec.project_status;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_spec                       := rec.mfg_spec;
          l_xxpa_wip_cost_souchi_dtl_tmp.amt                            := rec.amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.currency_amt                   := rec.currency_amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_number                      := rec.po_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_line                        := rec.po_line;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_source             := rec.transaction_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.orginal_trans_ref              := rec.orginal_trans_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.original_user_expnd_transf_ref := rec.original_user_expnd_transf_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_batch              := rec.expenditure_batch;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_comment            := rec.expenditure_comment;
          l_xxpa_wip_cost_souchi_dtl_tmp.dff                            := rec.dff;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_type               := rec.transaction_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_number                     := rec.job_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.item_number                    := rec.item_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_type                       := rec.job_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.so_invoice                     := rec.so_invoice;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_long_name              := rec.project_long_name;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_id                     := rec.project_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.task_id                        := rec.task_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.souchi                         := l_souchi;
          l_xxpa_wip_cost_souchi_dtl_tmp.request_id                     := g_request_id;
        
          INSERT INTO xxpa_wip_cost_souchi_dtl_tmp
          VALUES l_xxpa_wip_cost_souchi_dtl_tmp;
        
        END IF;
      END LOOP;
    ELSE
      FOR rec IN cur(p_project_id, p_top_task_id)
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id);--modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          IF rec.expenditure_item_id IS NOT NULL THEN
            l_souchi := t_souchi(rec.expenditure_item_id);
          ELSE
            l_souchi := rec.souchi;
          END IF;
          l_xxpa_wip_cost_souchi_dtl_tmp.type                           := rec.type;
          l_xxpa_wip_cost_souchi_dtl_tmp.org                            := rec.org;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_item_id            := rec.expenditure_item_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_type                   := rec.project_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.proj_no                        := rec.proj_no;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg                            := rec.mfg;
          l_xxpa_wip_cost_souchi_dtl_tmp.task                           := rec.task;
          l_xxpa_wip_cost_souchi_dtl_tmp.group_parts                    := rec.group_parts;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_cate                     := rec.expen_cate;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_type                     := rec.expen_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.gl_date                        := rec.gl_date;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_currency_code          := rec.project_currency_code;
          l_xxpa_wip_cost_souchi_dtl_tmp.qty                            := rec.qty;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_source                     := rec.mfg_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_status                 := rec.project_status;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_spec                       := rec.mfg_spec;
          l_xxpa_wip_cost_souchi_dtl_tmp.amt                            := rec.amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.currency_amt                   := rec.currency_amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_number                      := rec.po_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_line                        := rec.po_line;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_source             := rec.transaction_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.orginal_trans_ref              := rec.orginal_trans_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.original_user_expnd_transf_ref := rec.original_user_expnd_transf_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_batch              := rec.expenditure_batch;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_comment            := rec.expenditure_comment;
          l_xxpa_wip_cost_souchi_dtl_tmp.dff                            := rec.dff;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_type               := rec.transaction_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_number                     := rec.job_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.item_number                    := rec.item_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_type                       := rec.job_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.so_invoice                     := rec.so_invoice;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_long_name              := rec.project_long_name;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_id                     := rec.project_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.task_id                        := rec.task_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.souchi                         := l_souchi;
          l_xxpa_wip_cost_souchi_dtl_tmp.request_id                     := g_request_id;
        
          INSERT INTO xxpa_wip_cost_souchi_dtl_tmp
          VALUES l_xxpa_wip_cost_souchi_dtl_tmp;
        END IF;
      END LOOP;
    
    END IF;
  
    --COMMIT;
    /*  
        FOR rec IN cur_tmp
        LOOP
          output('<tr>');
          \*      output_column(rec.type, g_type_text);*\
          output_column(rec.org, g_type_text);
        
          output_column(rec.project_type, g_type_text);
          output_column(rec.proj_no, g_type_text); --todo1
          output_column(rec.task, g_type_text); --todo2
          output_column(rec.group_parts, g_type_text); --todo3
          output_column(rec.souchi, g_type_text); --souchi
          \*output_column(rec.completion_date, g_type_text);
          output_column(rec.first_invoice_date, g_type_text);*\
          output_column(rec.expen_cate, g_type_text); --todo5
          output_column(rec.expen_type, g_type_text); --todo6
          output_column(rec.gl_date, g_type_text); --todo7
          output_column(rec.project_status, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.project_currency_code, g_type_text);
          output_column(rec.qty, g_type_text);
          output_column(round(rec.amt, 2), g_type_text);
          output_column(round(rec.currency_amt, 2), g_type_text);
          output_column(rec.expenditure_item_id, g_type_text);
          output_column(rec.expenditure_batch, g_type_text);
          output_column(rec.transaction_source, g_type_text);
          output_column(rec.orginal_trans_ref, g_type_text);
          output_column(rec.original_user_expnd_transf_ref, g_type_text);
          output_column(rec.transaction_type, g_type_text);
          output_column(rec.job_number, g_type_text);
          output_column(rec.po_number, g_type_text);
          output_column(rec.po_line, g_type_text);
          \*output_column(rec.mfg_source, g_type_text);*\
          \*output_column(rec.model, g_type_text);*\
          output_column(rec.mfg_spec, g_type_text);
          output_column(rec.expenditure_comment, g_type_text);
          output_column(rec.item_number, g_type_text);
          output_column(rec.dff, g_type_text);
          output_column(rec.job_type, g_type_text);
          output_column(rec.so_invoice, g_type_text);
          output_column(rec.project_long_name, g_type_text);
          output('</tr>');
        END LOOP;
    */
    /*IF g_project_id IS NOT NULL OR g_top_task_id IS NOT NULL THEN
      FOR rec IN cur_project
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id); --modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          log('project_type = ' || rec.project_type);
          log('project_id = ' || rec.project_id);
          log('task_id = ' || rec.task_id);
          log('expen_type = ' || rec.expen_type || '>>>>');
          log('expenditure_item_id = ' || rec.expenditure_item_id);
          output('<tr>');
          \*      output_column(rec.type, g_type_text);*\
          output_column(rec.org, g_type_text);
        
          output_column(rec.project_type, g_type_text);
          output_column(rec.proj_no, g_type_text); --todo1
          output_column(rec.task, g_type_text); --todo2
          output_column(l_group_part, g_type_text); --todo3
          IF rec.expenditure_item_id IS NOT NULL THEN
            output_column(t_souchi(rec.expenditure_item_id), g_type_text);
          ELSE
            output_column(rec.souchi, g_type_text); --souchi
          END IF; --todo4
          \*output_column(rec.completion_date, g_type_text);
          output_column(rec.first_invoice_date, g_type_text);*\
          output_column(rec.expen_cate, g_type_text); --todo5
          output_column(rec.expen_type, g_type_text); --todo6
          output_column(rec.gl_date, g_type_text); --todo7
          output_column(rec.project_status, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.project_currency_code, g_type_text);
          output_column(rec.qty, g_type_text);
          output_column(round(rec.amt, 2), g_type_text);
          output_column(round(rec.currency_amt, 2), g_type_text);
          output_column(rec.expenditure_item_id, g_type_text);
          output_column(rec.expenditure_batch, g_type_text);
          output_column(rec.transaction_source, g_type_text);
          output_column(rec.orginal_trans_ref, g_type_text);
          output_column(rec.original_user_expnd_transf_ref, g_type_text);
          output_column(rec.transaction_type, g_type_text);
          output_column(rec.job_number, g_type_text);
          output_column(rec.po_number, g_type_text);
          output_column(rec.po_line, g_type_text);
          \*output_column(rec.mfg_source, g_type_text);*\
          \*output_column(rec.model, g_type_text);*\
          output_column(rec.mfg_spec, g_type_text);
          output_column(rec.expenditure_comment, g_type_text);
          output_column(rec.item_number, g_type_text);
          output_column(rec.dff, g_type_text);
          output_column(rec.job_type, g_type_text);
          output_column(rec.so_invoice, g_type_text);
          output_column(rec.project_long_name, g_type_text);
          output('</tr>');
        END IF;
      END LOOP;
    ELSE
      FOR rec IN cur
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id);--modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          \*          log(rec.project_type);
          log(rec.project_id);
          log(rec.task_id);*\
          log('project_type = ' || rec.project_type);
          log('project_id = ' || rec.project_id);
          log('task_id = ' || rec.task_id);
          log('expen_type = ' || rec.expen_type || '>>>>');
          log('expenditure_item_id = ' || rec.expenditure_item_id);
          output('<tr>');
          \*      output_column(rec.type, g_type_text);*\
          output_column(rec.org, g_type_text);
        
          output_column(rec.project_type, g_type_text);
          output_column(rec.proj_no, g_type_text); --todo1
          output_column(rec.task, g_type_text); --todo2
          output_column(l_group_part, g_type_text); --todo3
          IF rec.expenditure_item_id IS NOT NULL THEN
            output_column(t_souchi(rec.expenditure_item_id), g_type_text);
          ELSE
            output_column(rec.souchi, g_type_text); --souchi
          END IF; --todo4
          \*output_column(rec.completion_date, g_type_text);
          output_column(rec.first_invoice_date, g_type_text);*\
          output_column(rec.expen_cate, g_type_text); --todo5
          output_column(rec.expen_type, g_type_text); --todo6
          output_column(rec.gl_date, g_type_text); --todo7
          output_column(rec.project_status, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.project_currency_code, g_type_text);
          output_column(rec.qty, g_type_text);
          output_column(round(rec.amt, 2), g_type_text);
          output_column(round(rec.currency_amt, 2), g_type_text);
          output_column(rec.expenditure_item_id, g_type_text);
          output_column(rec.expenditure_batch, g_type_text);
          output_column(rec.transaction_source, g_type_text);
          output_column(rec.orginal_trans_ref, g_type_text);
          output_column(rec.original_user_expnd_transf_ref, g_type_text);
          output_column(rec.transaction_type, g_type_text);
          output_column(rec.job_number, g_type_text);
          output_column(rec.po_number, g_type_text);
          output_column(rec.po_line, g_type_text);
          \*output_column(rec.mfg_source, g_type_text);*\
          \*output_column(rec.model, g_type_text);*\
          output_column(rec.mfg_spec, g_type_text);
          output_column(rec.expenditure_comment, g_type_text);
          output_column(rec.item_number, g_type_text);
          output_column(rec.dff, g_type_text);
          output_column(rec.job_type, g_type_text);
          output_column(rec.so_invoice, g_type_text);
          output_column(rec.project_long_name, g_type_text);
          output('</tr>');
        END IF;
      END LOOP;
    
    END IF;*/
    /*    DELETE FROM xxpa_wip_cost_souchi_dtl_tmp t
    WHERE 1 = 1
      AND t.request_id = g_request_id;*/
    -- API end body
    -- end activity, include debug message hint to exit api
    /*    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                             p_api_name  => l_api_name,
                             x_msg_count => x_msg_count,
                             x_msg_data  => x_msg_data);
    
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_error,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
      
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      WHEN OTHERS THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);*/
  END collect_data;

  PROCEDURE process_request(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_group_part                   VARCHAR2(240);
    l_xxpa_wip_cost_souchi_dtl_tmp xxpa_wip_cost_souchi_dtl_tmp%ROWTYPE;
  
    l_souchi VARCHAR2(240);
  
    CURSOR cur IS
      SELECT t.type,
             t.org,
             t.expenditure_item_id,
             t.project_type,
             t.proj_no,
             t.mfg,
             t.task,
             t.group_parts,
             t.expen_cate,
             t.expen_type,
             t.gl_date,
             t.project_currency_code,
             t.qty,
             t.mfg_source,
             t.project_status,
             t.mfg_spec,
             t.amt,
             t.currency_amt,
             t.po_number,
             t.po_line,
             t.transaction_source,
             t.orginal_trans_ref,
             t.original_user_expnd_transf_ref,
             t.expenditure_batch,
             t.expenditure_comment,
             t.dff,
             t.transaction_type,
             t.job_number,
             t.item_number,
             t.job_type,
             t.so_invoice,
             t.project_long_name,
             t.project_id,
             t.task_id,
             t.souchi
      
        FROM (SELECT /*+  leading(cdl) index(cdl PA_COST_DISTRIBUTION_LINES_N8)*/
               'WIP' TYPE,
               hou.name org,
               to_char(pei.expenditure_item_id) expenditure_item_id,
               pa.project_type,
               pa.segment1 proj_no,
               
               mfg.task_number mfg,
               pt.task_number task,
               xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id) group_parts,
               pet.expenditure_category expen_cate,
               xxpa_proj_exp_item_ref_pkg.get_expen_type(p_expenditure_item_id => pei.expenditure_item_id,
                                                         p_organization_id     => hou.organization_id) expen_type,
               cdl.gl_date,
               pei.project_currency_code,
               pei.quantity qty,
               xxpa_proj_exp_item_ref_pkg.get_mfg_source(pei.project_id, mfg.task_number) mfg_source,
               xxpa_proj_exp_item_ref_pkg.get_project_status(pei.project_id) project_status,
               xxpa_proj_exp_item_ref_pkg.get_mfg_spec(mfg.task_number) mfg_spec,
               pei.project_burdened_cost amt,
               pei.project_burdened_cost currency_amt,
               xei.po_number po_number,
               
               xei.po_line po_line,
               xei.transaction_source transaction_source,
               xei.orginal_trans_ref orginal_trans_ref,
               xei.original_user_expnd_transf_ref original_user_expnd_transf_ref,
               xei.expenditure_group expenditure_batch,
               xei.expenditure_comment expenditure_comment,
               xei.dff dff,
               xxpa_proj_exp_item_ref_pkg.get_transaction_type(pei.expenditure_item_id, 'WIP', NULL) transaction_type,
               xxpa_proj_exp_item_ref_pkg.get_material_job(pei.expenditure_item_id, 'WIP', NULL) job_number,
               xxpa_proj_exp_item_ref_pkg.get_item_number('WIP', pei.expenditure_item_id, NULL) item_number,
               xxpa_proj_exp_item_ref_pkg.get_material_job_type(pei.expenditure_item_id, 'WIP', NULL) job_type,
               NULL so_invoice,
               xxpa_proj_exp_item_ref_pkg.get_project_long_name(pei.project_id) project_long_name,
               pt.project_id,
               pt.task_id,
               NULL souchi
                FROM apps.pa_expenditure_items_all  pei,
                     apps.pa_expenditures_all       pe,
                     apps.pa_expenditure_types      pet,
                     apps.hr_organization_units     hou,
                     apps.pa_projects_all           pa,
                     apps.pa_project_types_all      ppt,
                     apps.pa_tasks                  pt,
                     apps.pa_tasks                  mfg,
                     pa_cost_distribution_lines_all cdl,
                     apps.xxpa_exp_items_expend_v   xei
               WHERE nvl(pei.override_to_organization_id, pe.incurred_by_organization_id) = hou.organization_id
                 AND pei.expenditure_id = pe.expenditure_id
                 AND pei.expenditure_type = pet.expenditure_type
                 AND pei.task_id = pt.task_id
                 AND pei.project_id = pa.project_id
                 AND pt.top_task_id = mfg.task_id
                 AND pa.project_type = ppt.project_type
                 AND pet.expenditure_category != 'FG Completion'
                    /* AND nvl(ppt.attribute7, -1) != 'OVERSEA'*/
                 AND cdl.line_type <> 'I'
                 AND (cdl.expenditure_item_id = pei.expenditure_item_id)
                 AND pei.expenditure_item_id = xei.expenditure_item_id(+)
                 AND hou.name = g_org_name
                 AND (cdl.gl_date >= g_date_from OR g_date_from IS NULL)
                 AND cdl.gl_date <= g_date_to
                    --modify by jingjing.he 2017-10-30 start
                 AND (((pa.project_id = g_project_id OR g_project_id IS NULL) AND
                      (pt.top_task_id = g_top_task_id OR g_top_task_id IS NULL)) OR
                      ((pa.project_id = g_project_id2 OR g_project_id2 IS NULL) AND
                      (pt.top_task_id = g_top_task_id2 OR g_top_task_id2 IS NULL)) OR
                      ((pa.project_id = g_project_id3 OR g_project_id3 IS NULL) AND
                      (pt.top_task_id = g_top_task_id3 OR g_top_task_id3 IS NULL)) OR
                      ((pa.project_id = g_project_id4 OR g_project_id4 IS NULL) AND
                      (pt.top_task_id = g_top_task_id4 OR g_top_task_id4 IS NULL)) OR
                      ((pa.project_id = g_project_id5 OR g_project_id5 IS NULL) AND
                      (pt.top_task_id = g_top_task_id5 OR g_top_task_id5 IS NULL)))
              --modify by jingjing.he 2017-10-30 end
              ) t
      --add by jingjing 2018-03-21 start
      /*ORDER BY t.proj_no,
      t.task,
      t.group_parts,
      t.souchi,
      t.expen_cate,
      t.expen_type,
      t.gl_date*/
      --add order by logic
      --add by jingjing 2018-03-21 end
      /*AND (EXISTS (SELECT 1
         FROM xxpa_wip_cost_gp_temp xwg
        WHERE xwg.gp =
              xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id)) OR
      g_group_part IS NULL)*/
      /*UNION ALL
      
      SELECT xpan.type TYPE,
             xpan.org,
             to_char(xpan.expenditure_item_id) expenditure_item_id,
             -- xpan.expenditure_item_id,
             xpan.project_type,
             xpan.proj_no,
             xpan.mfg,
             xpan.task,
             xpan.group_parts,
             xpan.expen_cate,
             xpan.expen_type,
             xpan.gl_date,
             xpan.currency_code project_currency_code,
             xpan.qty,
             xxpa_proj_exp_item_ref_pkg.get_mfg_source(xpan.project_id,
                                                       xpan.mfg) mfg_source,
             xxpa_proj_exp_item_ref_pkg.get_project_status(xpan.project_id) project_status,
             xxpa_proj_exp_item_ref_pkg.get_mfg_spec(xpan.mfg) mfg_spec,
             xpan.amt,
             xpan.currency_amt,
             NULL po_number,
             NULL po_line,
             NULL transaction_source,
             xpan.transaction_id || '' orginal_trans_ref,
             NULL riginal_user_expnd_transf_ref,
             NULL expenditure_batch,
             NULL expenditure_comment,
             NULL dff,
             NULL transaction_type,
             xpan.job job_number
             
            ,
             xxpa_proj_exp_item_ref_pkg.get_item_number(NULL,
                                                        NULL,
                                                        xpan.transaction_id) item_number,
             xpan.job_type,
             NULL so_invoice,
             xxpa_proj_exp_item_ref_pkg.get_project_long_name(xpan.project_id) project_long_name,
             xpan.project_id,
             xpan.task_id,
             xpan.souchi
        FROM xxpa_wip_cost_souchi_ne_v xpan
       WHERE xpan.org = g_org_name
         AND (xpan.gl_date >= g_date_from OR g_date_from IS NULL)
         AND xpan.gl_date <= g_date_to
         AND (xpan.project_id = g_project_id OR g_project_id IS NULL)
         AND (xpan.top_task_id = g_top_task_id OR g_top_task_id IS NULL)
         AND (EXISTS
              (SELECT 1
                 FROM xxpa_wip_cost_gp_temp xwg
                WHERE xwg.gp = xpan.group_parts) OR g_group_part IS NULL)*/
      ;
    --for performance same sql different hint
    CURSOR cur_project IS
      SELECT t.type,
             t.org,
             t.expenditure_item_id,
             t.project_type,
             t.proj_no,
             t.mfg,
             t.task,
             t.group_parts,
             t.expen_cate,
             t.expen_type,
             t.gl_date,
             t.project_currency_code,
             t.qty,
             t.mfg_source,
             t.project_status,
             t.mfg_spec,
             t.amt,
             t.currency_amt,
             t.po_number,
             t.po_line,
             t.transaction_source,
             t.orginal_trans_ref,
             t.original_user_expnd_transf_ref,
             t.expenditure_batch,
             t.expenditure_comment,
             t.dff,
             t.transaction_type,
             t.job_number,
             t.item_number,
             t.job_type,
             t.so_invoice,
             t.project_long_name,
             t.project_id,
             t.task_id,
             t.souchi
      
        FROM (SELECT 'WIP' TYPE,
                     hou.name org,
                     to_char(pei.expenditure_item_id) expenditure_item_id,
                     pa.project_type,
                     pa.segment1 proj_no,
                     mfg.task_number mfg,
                     pt.task_number task,
                     xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id) group_parts,
                     pet.expenditure_category expen_cate,
                     xxpa_proj_exp_item_ref_pkg.get_expen_type(p_expenditure_item_id => pei.expenditure_item_id,
                                                               p_organization_id     => hou.organization_id) expen_type,
                     cdl.gl_date,
                     pei.project_currency_code,
                     pei.quantity qty,
                     xxpa_proj_exp_item_ref_pkg.get_mfg_source(pei.project_id, mfg.task_number) mfg_source,
                     xxpa_proj_exp_item_ref_pkg.get_project_status(pei.project_id) project_status,
                     xxpa_proj_exp_item_ref_pkg.get_mfg_spec(mfg.task_number) mfg_spec,
                     pei.project_burdened_cost amt,
                     pei.project_burdened_cost currency_amt,
                     xei.po_number po_number,
                     
                     xei.po_line po_line,
                     xei.transaction_source transaction_source,
                     xei.orginal_trans_ref orginal_trans_ref,
                     xei.original_user_expnd_transf_ref original_user_expnd_transf_ref,
                     xei.expenditure_group expenditure_batch,
                     xei.expenditure_comment expenditure_comment,
                     xei.dff dff,
                     xxpa_proj_exp_item_ref_pkg.get_transaction_type(pei.expenditure_item_id, 'WIP', NULL) transaction_type,
                     xxpa_proj_exp_item_ref_pkg.get_material_job(pei.expenditure_item_id, 'WIP', NULL) job_number,
                     xxpa_proj_exp_item_ref_pkg.get_item_number('WIP', pei.expenditure_item_id, NULL) item_number,
                     xxpa_proj_exp_item_ref_pkg.get_material_job_type(pei.expenditure_item_id, 'WIP', NULL) job_type,
                     NULL so_invoice,
                     xxpa_proj_exp_item_ref_pkg.get_project_long_name(pei.project_id) project_long_name,
                     pt.project_id,
                     pt.task_id,
                     NULL souchi
                FROM apps.pa_expenditure_items_all  pei,
                     apps.pa_expenditures_all       pe,
                     apps.pa_expenditure_types      pet,
                     apps.hr_organization_units     hou,
                     apps.pa_projects_all           pa,
                     apps.pa_project_types_all      ppt,
                     apps.pa_tasks                  pt,
                     apps.pa_tasks                  mfg,
                     pa_cost_distribution_lines_all cdl,
                     apps.xxpa_exp_items_expend_v   xei
               WHERE nvl(pei.override_to_organization_id, pe.incurred_by_organization_id) = hou.organization_id
                 AND pei.expenditure_id = pe.expenditure_id
                 AND pei.expenditure_type = pet.expenditure_type
                 AND pei.task_id = pt.task_id
                 AND pei.project_id = pa.project_id
                 AND pt.top_task_id = mfg.task_id
                 AND pa.project_type = ppt.project_type
                 AND pet.expenditure_category != 'FG Completion'
                    /* AND nvl(ppt.attribute7, -1) != 'OVERSEA'*/
                 AND cdl.line_type <> 'I'
                 AND (cdl.expenditure_item_id = pei.expenditure_item_id)
                 AND pei.expenditure_item_id = xei.expenditure_item_id(+)
                 AND hou.name = g_org_name
                 AND (cdl.gl_date >= g_date_from OR g_date_from IS NULL)
                 AND cdl.gl_date <= g_date_to
                    --modify by jingjing.he 2017-10-30 start
                 AND (((pa.project_id = g_project_id OR g_project_id IS NULL) AND
                      (pt.top_task_id = g_top_task_id OR g_top_task_id IS NULL)) OR
                      ((pa.project_id = g_project_id2 OR g_project_id2 IS NULL) AND
                      (pt.top_task_id = g_top_task_id2 OR g_top_task_id2 IS NULL)) OR
                      ((pa.project_id = g_project_id3 OR g_project_id3 IS NULL) AND
                      (pt.top_task_id = g_top_task_id3 OR g_top_task_id3 IS NULL)) OR
                      ((pa.project_id = g_project_id4 OR g_project_id4 IS NULL) AND
                      (pt.top_task_id = g_top_task_id4 OR g_top_task_id4 IS NULL)) OR
                      ((pa.project_id = g_project_id5 OR g_project_id5 IS NULL) AND
                      (pt.top_task_id = g_top_task_id5 OR g_top_task_id5 IS NULL)))
              --modify by jingjing.he 2017-10-30 end
              ) t
      --add order by logic by jingjing20180322 start
      /*ORDER BY t.proj_no,
      t.task,
      t.group_parts,
      t.souchi,
      t.expen_cate,
      t.expen_type,
      t.gl_date*/
      --add order by logic by jingjing20180322 end
      /*UNION ALL
      
      SELECT xpan.type TYPE,
             xpan.org,
             to_char(xpan.expenditure_item_id) expenditure_item_id,
             -- xpan.expenditure_item_id,
             xpan.project_type,
             xpan.proj_no,
             xpan.mfg,
             xpan.task,
             xpan.group_parts,
             xpan.expen_cate,
             xpan.expen_type,
             xpan.gl_date,
             xpan.currency_code project_currency_code,
             xpan.qty,
             xxpa_proj_exp_item_ref_pkg.get_mfg_source(xpan.project_id,
                                                       xpan.mfg) mfg_source,
             xxpa_proj_exp_item_ref_pkg.get_project_status(xpan.project_id) project_status,
             xxpa_proj_exp_item_ref_pkg.get_mfg_spec(xpan.mfg) mfg_spec,
             xpan.amt,
             xpan.currency_amt,
             NULL po_number,
             NULL po_line,
             NULL transaction_source,
             xpan.transaction_id || '' orginal_trans_ref,
             NULL riginal_user_expnd_transf_ref,
             NULL expenditure_batch,
             NULL expenditure_comment,
             NULL dff,
             NULL transaction_type,
             xpan.job job_number
             
            ,
             xxpa_proj_exp_item_ref_pkg.get_item_number(NULL,
                                                        NULL,
                                                        xpan.transaction_id) item_number,
             xpan.job_type,
             NULL so_invoice,
             xxpa_proj_exp_item_ref_pkg.get_project_long_name(xpan.project_id) project_long_name,
             xpan.project_id,
             xpan.task_id,
             xpan.souchi
        FROM xxpa_wip_cost_souchi_ne_v xpan
       WHERE xpan.org = g_org_name
         AND (xpan.gl_date >= g_date_from OR g_date_from IS NULL)
         AND xpan.gl_date <= g_date_to
         AND (xpan.project_id = g_project_id OR g_project_id IS NULL)
         AND (xpan.top_task_id = g_top_task_id OR g_top_task_id IS NULL)
         AND (EXISTS
              (SELECT 1
                 FROM xxpa_wip_cost_gp_temp xwg
                WHERE xwg.gp = xpan.group_parts) OR g_group_part IS NULL)*/
      ;
  
    CURSOR cur_tmp IS
      SELECT *
        FROM xxpa_wip_cost_souchi_dtl_tmp t
       WHERE 1 = 1
         AND t.request_id = g_request_id
       ORDER BY t.proj_no,
                t.task,
                t.group_parts,
                t.souchi,
                t.expen_cate,
                t.expen_type,
                t.gl_date;
  
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    output_head('Project Wip Cost Analysis Detail');
    log('10. ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
    output('<tr bgcolor="#FFAF60">');
    output_col_title('Org');
    output_col_title('Project Type');
    output_col_title('Proj No'); --todo1
    output_col_title('Task'); --todo2
    output_col_title('Parts'); --todo3
    output_col_title('Souchi'); --todo4
    output_col_title('Expen Cate'); --todo5
    output_col_title('Expen Type'); --todo6
    output_col_title('Gl Date'); --todo7
    output_col_title('Project Status');
    output_col_title('Mfg');
    output_col_title('Project Currency Code');
    output_col_title('Quantity');
    output_col_title('Amt');
    output_col_title('Currency Amt');
    output_col_title('Expenditure Item Id');
    output_col_title('Expenditure Batch');
    output_col_title('Transaction Source');
    output_col_title('Orginal Trans Ref');
    output_col_title('Original User Expnd Transf Ref');
    output_col_title('Transaction Type');
    output_col_title('Job Number');
    output_col_title('Po Number');
    output_col_title('Po Line');
    --output_col_title('Mfg Model');
  
    output_col_title('Mfg Spec');
    output_col_title('Comment');
    output_col_title('Item Number');
    output_col_title('Dff');
  
    output_col_title('Job Type');
    output_col_title('So Invoice');
    output_col_title('Project Long Name');
    output('</tr>');
    log('20. ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
  
    --10 create a tmp table
    --20 insert these data in the tmp table
    --30 get the data from the tmp table
  
    --DELETE FROM xxpa_wip_cost_souchi_dtl_tmp;
    IF g_project_id IS NOT NULL OR g_top_task_id IS NOT NULL THEN
      FOR rec IN cur_project
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id); --modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          IF rec.expenditure_item_id IS NOT NULL THEN
            l_souchi := t_souchi(rec.expenditure_item_id);
          ELSE
            l_souchi := rec.souchi;
          END IF;
          l_xxpa_wip_cost_souchi_dtl_tmp.type                           := rec.type;
          l_xxpa_wip_cost_souchi_dtl_tmp.org                            := rec.org;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_item_id            := rec.expenditure_item_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_type                   := rec.project_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.proj_no                        := rec.proj_no;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg                            := rec.mfg;
          l_xxpa_wip_cost_souchi_dtl_tmp.task                           := rec.task;
          l_xxpa_wip_cost_souchi_dtl_tmp.group_parts                    := rec.group_parts;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_cate                     := rec.expen_cate;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_type                     := rec.expen_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.gl_date                        := rec.gl_date;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_currency_code          := rec.project_currency_code;
          l_xxpa_wip_cost_souchi_dtl_tmp.qty                            := rec.qty;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_source                     := rec.mfg_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_status                 := rec.project_status;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_spec                       := rec.mfg_spec;
          l_xxpa_wip_cost_souchi_dtl_tmp.amt                            := rec.amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.currency_amt                   := rec.currency_amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_number                      := rec.po_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_line                        := rec.po_line;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_source             := rec.transaction_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.orginal_trans_ref              := rec.orginal_trans_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.original_user_expnd_transf_ref := rec.original_user_expnd_transf_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_batch              := rec.expenditure_batch;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_comment            := rec.expenditure_comment;
          l_xxpa_wip_cost_souchi_dtl_tmp.dff                            := rec.dff;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_type               := rec.transaction_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_number                     := rec.job_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.item_number                    := rec.item_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_type                       := rec.job_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.so_invoice                     := rec.so_invoice;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_long_name              := rec.project_long_name;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_id                     := rec.project_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.task_id                        := rec.task_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.souchi                         := l_souchi;
          l_xxpa_wip_cost_souchi_dtl_tmp.request_id                     := g_request_id;
        
          INSERT INTO xxpa_wip_cost_souchi_dtl_tmp
          VALUES l_xxpa_wip_cost_souchi_dtl_tmp;
        
        END IF;
      END LOOP;
    ELSE
      FOR rec IN cur
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id);--modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          IF rec.expenditure_item_id IS NOT NULL THEN
            l_souchi := t_souchi(rec.expenditure_item_id);
          ELSE
            l_souchi := rec.souchi;
          END IF;
          l_xxpa_wip_cost_souchi_dtl_tmp.type                           := rec.type;
          l_xxpa_wip_cost_souchi_dtl_tmp.org                            := rec.org;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_item_id            := rec.expenditure_item_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_type                   := rec.project_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.proj_no                        := rec.proj_no;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg                            := rec.mfg;
          l_xxpa_wip_cost_souchi_dtl_tmp.task                           := rec.task;
          l_xxpa_wip_cost_souchi_dtl_tmp.group_parts                    := rec.group_parts;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_cate                     := rec.expen_cate;
          l_xxpa_wip_cost_souchi_dtl_tmp.expen_type                     := rec.expen_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.gl_date                        := rec.gl_date;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_currency_code          := rec.project_currency_code;
          l_xxpa_wip_cost_souchi_dtl_tmp.qty                            := rec.qty;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_source                     := rec.mfg_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_status                 := rec.project_status;
          l_xxpa_wip_cost_souchi_dtl_tmp.mfg_spec                       := rec.mfg_spec;
          l_xxpa_wip_cost_souchi_dtl_tmp.amt                            := rec.amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.currency_amt                   := rec.currency_amt;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_number                      := rec.po_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.po_line                        := rec.po_line;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_source             := rec.transaction_source;
          l_xxpa_wip_cost_souchi_dtl_tmp.orginal_trans_ref              := rec.orginal_trans_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.original_user_expnd_transf_ref := rec.original_user_expnd_transf_ref;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_batch              := rec.expenditure_batch;
          l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_comment            := rec.expenditure_comment;
          l_xxpa_wip_cost_souchi_dtl_tmp.dff                            := rec.dff;
          l_xxpa_wip_cost_souchi_dtl_tmp.transaction_type               := rec.transaction_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_number                     := rec.job_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.item_number                    := rec.item_number;
          l_xxpa_wip_cost_souchi_dtl_tmp.job_type                       := rec.job_type;
          l_xxpa_wip_cost_souchi_dtl_tmp.so_invoice                     := rec.so_invoice;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_long_name              := rec.project_long_name;
          l_xxpa_wip_cost_souchi_dtl_tmp.project_id                     := rec.project_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.task_id                        := rec.task_id;
          l_xxpa_wip_cost_souchi_dtl_tmp.souchi                         := l_souchi;
          l_xxpa_wip_cost_souchi_dtl_tmp.request_id                     := g_request_id;
        
          INSERT INTO xxpa_wip_cost_souchi_dtl_tmp
          VALUES l_xxpa_wip_cost_souchi_dtl_tmp;
        END IF;
      END LOOP;
    
    END IF;
  
    --COMMIT;
  
    FOR rec IN cur_tmp
    LOOP
      output('<tr>');
      /*      output_column(rec.type, g_type_text);*/
      output_column(rec.org, g_type_text);
    
      output_column(rec.project_type, g_type_text);
      output_column(rec.proj_no, g_type_text); --todo1
      output_column(rec.task, g_type_text); --todo2
      output_column(rec.group_parts, g_type_text); --todo3
      output_column(rec.souchi, g_type_text); --souchi
      /*output_column(rec.completion_date, g_type_text);
      output_column(rec.first_invoice_date, g_type_text);*/
      output_column(rec.expen_cate, g_type_text); --todo5
      output_column(rec.expen_type, g_type_text); --todo6
      output_column(rec.gl_date, g_type_text); --todo7
      output_column(rec.project_status, g_type_text);
      output_column(rec.mfg, g_type_text);
      output_column(rec.project_currency_code, g_type_text);
      output_column(rec.qty, g_type_text);
      output_column(round(rec.amt, 2), g_type_text);
      output_column(round(rec.currency_amt, 2), g_type_text);
      output_column(rec.expenditure_item_id, g_type_text);
      output_column(rec.expenditure_batch, g_type_text);
      output_column(rec.transaction_source, g_type_text);
      output_column(rec.orginal_trans_ref, g_type_text);
      output_column(rec.original_user_expnd_transf_ref, g_type_text);
      output_column(rec.transaction_type, g_type_text);
      output_column(rec.job_number, g_type_text);
      output_column(rec.po_number, g_type_text);
      output_column(rec.po_line, g_type_text);
      /*output_column(rec.mfg_source, g_type_text);*/
      /*output_column(rec.model, g_type_text);*/
      output_column(rec.mfg_spec, g_type_text);
      output_column(rec.expenditure_comment, g_type_text);
      output_column(rec.item_number, g_type_text);
      output_column(rec.dff, g_type_text);
      output_column(rec.job_type, g_type_text);
      output_column(rec.so_invoice, g_type_text);
      output_column(rec.project_long_name, g_type_text);
      output('</tr>');
    END LOOP;
  
    /*IF g_project_id IS NOT NULL OR g_top_task_id IS NOT NULL THEN
      FOR rec IN cur_project
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id); --modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          log('project_type = ' || rec.project_type);
          log('project_id = ' || rec.project_id);
          log('task_id = ' || rec.task_id);
          log('expen_type = ' || rec.expen_type || '>>>>');
          log('expenditure_item_id = ' || rec.expenditure_item_id);
          output('<tr>');
          \*      output_column(rec.type, g_type_text);*\
          output_column(rec.org, g_type_text);
        
          output_column(rec.project_type, g_type_text);
          output_column(rec.proj_no, g_type_text); --todo1
          output_column(rec.task, g_type_text); --todo2
          output_column(l_group_part, g_type_text); --todo3
          IF rec.expenditure_item_id IS NOT NULL THEN
            output_column(t_souchi(rec.expenditure_item_id), g_type_text);
          ELSE
            output_column(rec.souchi, g_type_text); --souchi
          END IF; --todo4
          \*output_column(rec.completion_date, g_type_text);
          output_column(rec.first_invoice_date, g_type_text);*\
          output_column(rec.expen_cate, g_type_text); --todo5
          output_column(rec.expen_type, g_type_text); --todo6
          output_column(rec.gl_date, g_type_text); --todo7
          output_column(rec.project_status, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.project_currency_code, g_type_text);
          output_column(rec.qty, g_type_text);
          output_column(round(rec.amt, 2), g_type_text);
          output_column(round(rec.currency_amt, 2), g_type_text);
          output_column(rec.expenditure_item_id, g_type_text);
          output_column(rec.expenditure_batch, g_type_text);
          output_column(rec.transaction_source, g_type_text);
          output_column(rec.orginal_trans_ref, g_type_text);
          output_column(rec.original_user_expnd_transf_ref, g_type_text);
          output_column(rec.transaction_type, g_type_text);
          output_column(rec.job_number, g_type_text);
          output_column(rec.po_number, g_type_text);
          output_column(rec.po_line, g_type_text);
          \*output_column(rec.mfg_source, g_type_text);*\
          \*output_column(rec.model, g_type_text);*\
          output_column(rec.mfg_spec, g_type_text);
          output_column(rec.expenditure_comment, g_type_text);
          output_column(rec.item_number, g_type_text);
          output_column(rec.dff, g_type_text);
          output_column(rec.job_type, g_type_text);
          output_column(rec.so_invoice, g_type_text);
          output_column(rec.project_long_name, g_type_text);
          output('</tr>');
        END IF;
      END LOOP;
    ELSE
      FOR rec IN cur
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id);--modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          \*          log(rec.project_type);
          log(rec.project_id);
          log(rec.task_id);*\
          log('project_type = ' || rec.project_type);
          log('project_id = ' || rec.project_id);
          log('task_id = ' || rec.task_id);
          log('expen_type = ' || rec.expen_type || '>>>>');
          log('expenditure_item_id = ' || rec.expenditure_item_id);
          output('<tr>');
          \*      output_column(rec.type, g_type_text);*\
          output_column(rec.org, g_type_text);
        
          output_column(rec.project_type, g_type_text);
          output_column(rec.proj_no, g_type_text); --todo1
          output_column(rec.task, g_type_text); --todo2
          output_column(l_group_part, g_type_text); --todo3
          IF rec.expenditure_item_id IS NOT NULL THEN
            output_column(t_souchi(rec.expenditure_item_id), g_type_text);
          ELSE
            output_column(rec.souchi, g_type_text); --souchi
          END IF; --todo4
          \*output_column(rec.completion_date, g_type_text);
          output_column(rec.first_invoice_date, g_type_text);*\
          output_column(rec.expen_cate, g_type_text); --todo5
          output_column(rec.expen_type, g_type_text); --todo6
          output_column(rec.gl_date, g_type_text); --todo7
          output_column(rec.project_status, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.project_currency_code, g_type_text);
          output_column(rec.qty, g_type_text);
          output_column(round(rec.amt, 2), g_type_text);
          output_column(round(rec.currency_amt, 2), g_type_text);
          output_column(rec.expenditure_item_id, g_type_text);
          output_column(rec.expenditure_batch, g_type_text);
          output_column(rec.transaction_source, g_type_text);
          output_column(rec.orginal_trans_ref, g_type_text);
          output_column(rec.original_user_expnd_transf_ref, g_type_text);
          output_column(rec.transaction_type, g_type_text);
          output_column(rec.job_number, g_type_text);
          output_column(rec.po_number, g_type_text);
          output_column(rec.po_line, g_type_text);
          \*output_column(rec.mfg_source, g_type_text);*\
          \*output_column(rec.model, g_type_text);*\
          output_column(rec.mfg_spec, g_type_text);
          output_column(rec.expenditure_comment, g_type_text);
          output_column(rec.item_number, g_type_text);
          output_column(rec.dff, g_type_text);
          output_column(rec.job_type, g_type_text);
          output_column(rec.so_invoice, g_type_text);
          output_column(rec.project_long_name, g_type_text);
          output('</tr>');
        END IF;
      END LOOP;
    
    END IF;*/
    DELETE FROM xxpa_wip_cost_souchi_dtl_tmp t
     WHERE 1 = 1
       AND t.request_id = g_request_id;
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
    
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END process_request;

  PROCEDURE process_request2(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_group_part                   VARCHAR2(240);
    l_xxpa_wip_cost_souchi_dtl_tmp xxpa_wip_cost_souchi_dtl_tmp%ROWTYPE;
  
    l_souchi VARCHAR2(240);
    /*  
        CURSOR cur IS
          SELECT t.type,
                 t.org,
                 t.expenditure_item_id,
                 t.project_type,
                 t.proj_no,
                 t.mfg,
                 t.task,
                 t.group_parts,
                 t.expen_cate,
                 t.expen_type,
                 t.gl_date,
                 t.project_currency_code,
                 t.qty,
                 t.mfg_source,
                 t.project_status,
                 t.mfg_spec,
                 t.amt,
                 t.currency_amt,
                 t.po_number,
                 t.po_line,
                 t.transaction_source,
                 t.orginal_trans_ref,
                 t.original_user_expnd_transf_ref,
                 t.expenditure_batch,
                 t.expenditure_comment,
                 t.dff,
                 t.transaction_type,
                 t.job_number,
                 t.item_number,
                 t.job_type,
                 t.so_invoice,
                 t.project_long_name,
                 t.project_id,
                 t.task_id,
                 t.souchi
          
            FROM (SELECT \*+  leading(cdl) index(cdl PA_COST_DISTRIBUTION_LINES_N8)*\
                   'WIP' TYPE,
                   hou.name org,
                   to_char(pei.expenditure_item_id) expenditure_item_id,
                   pa.project_type,
                   pa.segment1 proj_no,
                   
                   mfg.task_number mfg,
                   pt.task_number task,
                   xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id) group_parts,
                   pet.expenditure_category expen_cate,
                   xxpa_proj_exp_item_ref_pkg.get_expen_type(p_expenditure_item_id => pei.expenditure_item_id,
                                                             p_organization_id     => hou.organization_id) expen_type,
                   cdl.gl_date,
                   pei.project_currency_code,
                   pei.quantity qty,
                   xxpa_proj_exp_item_ref_pkg.get_mfg_source(pei.project_id, mfg.task_number) mfg_source,
                   xxpa_proj_exp_item_ref_pkg.get_project_status(pei.project_id) project_status,
                   xxpa_proj_exp_item_ref_pkg.get_mfg_spec(mfg.task_number) mfg_spec,
                   pei.project_burdened_cost amt,
                   pei.project_burdened_cost currency_amt,
                   xei.po_number po_number,
                   
                   xei.po_line po_line,
                   xei.transaction_source transaction_source,
                   xei.orginal_trans_ref orginal_trans_ref,
                   xei.original_user_expnd_transf_ref original_user_expnd_transf_ref,
                   xei.expenditure_group expenditure_batch,
                   xei.expenditure_comment expenditure_comment,
                   xei.dff dff,
                   xxpa_proj_exp_item_ref_pkg.get_transaction_type(pei.expenditure_item_id, 'WIP', NULL) transaction_type,
                   xxpa_proj_exp_item_ref_pkg.get_material_job(pei.expenditure_item_id, 'WIP', NULL) job_number,
                   xxpa_proj_exp_item_ref_pkg.get_item_number('WIP', pei.expenditure_item_id, NULL) item_number,
                   xxpa_proj_exp_item_ref_pkg.get_material_job_type(pei.expenditure_item_id, 'WIP', NULL) job_type,
                   NULL so_invoice,
                   xxpa_proj_exp_item_ref_pkg.get_project_long_name(pei.project_id) project_long_name,
                   pt.project_id,
                   pt.task_id,
                   NULL souchi
                    FROM apps.pa_expenditure_items_all  pei,
                         apps.pa_expenditures_all       pe,
                         apps.pa_expenditure_types      pet,
                         apps.hr_organization_units     hou,
                         apps.pa_projects_all           pa,
                         apps.pa_project_types_all      ppt,
                         apps.pa_tasks                  pt,
                         apps.pa_tasks                  mfg,
                         pa_cost_distribution_lines_all cdl,
                         apps.xxpa_exp_items_expend_v   xei
                   WHERE nvl(pei.override_to_organization_id, pe.incurred_by_organization_id) = hou.organization_id
                     AND pei.expenditure_id = pe.expenditure_id
                     AND pei.expenditure_type = pet.expenditure_type
                     AND pei.task_id = pt.task_id
                     AND pei.project_id = pa.project_id
                     AND pt.top_task_id = mfg.task_id
                     AND pa.project_type = ppt.project_type
                     AND pet.expenditure_category != 'FG Completion'
                        \* AND nvl(ppt.attribute7, -1) != 'OVERSEA'*\
                     AND cdl.line_type <> 'I'
                     AND (cdl.expenditure_item_id = pei.expenditure_item_id)
                     AND pei.expenditure_item_id = xei.expenditure_item_id(+)
                     AND hou.name = g_org_name
                     AND (cdl.gl_date >= g_date_from OR g_date_from IS NULL)
                     AND cdl.gl_date <= g_date_to
                        --modify by jingjing.he 2017-10-30 start
                     AND (((pa.project_id = g_project_id OR g_project_id IS NULL) AND
                          (pt.top_task_id = g_top_task_id OR g_top_task_id IS NULL)) OR
                          ((pa.project_id = g_project_id2 OR g_project_id2 IS NULL) AND
                          (pt.top_task_id = g_top_task_id2 OR g_top_task_id2 IS NULL)) OR
                          ((pa.project_id = g_project_id3 OR g_project_id3 IS NULL) AND
                          (pt.top_task_id = g_top_task_id3 OR g_top_task_id3 IS NULL)) OR
                          ((pa.project_id = g_project_id4 OR g_project_id4 IS NULL) AND
                          (pt.top_task_id = g_top_task_id4 OR g_top_task_id4 IS NULL)) OR
                          ((pa.project_id = g_project_id5 OR g_project_id5 IS NULL) AND
                          (pt.top_task_id = g_top_task_id5 OR g_top_task_id5 IS NULL)))
                  --modify by jingjing.he 2017-10-30 end
                  ) t
          --add by jingjing 2018-03-21 start
          \*ORDER BY t.proj_no,
          t.task,
          t.group_parts,
          t.souchi,
          t.expen_cate,
          t.expen_type,
          t.gl_date*\
          --add order by logic
          --add by jingjing 2018-03-21 end
          \*AND (EXISTS (SELECT 1
             FROM xxpa_wip_cost_gp_temp xwg
            WHERE xwg.gp =
                  xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id)) OR
          g_group_part IS NULL)*\
          \*UNION ALL
          
          SELECT xpan.type TYPE,
                 xpan.org,
                 to_char(xpan.expenditure_item_id) expenditure_item_id,
                 -- xpan.expenditure_item_id,
                 xpan.project_type,
                 xpan.proj_no,
                 xpan.mfg,
                 xpan.task,
                 xpan.group_parts,
                 xpan.expen_cate,
                 xpan.expen_type,
                 xpan.gl_date,
                 xpan.currency_code project_currency_code,
                 xpan.qty,
                 xxpa_proj_exp_item_ref_pkg.get_mfg_source(xpan.project_id,
                                                           xpan.mfg) mfg_source,
                 xxpa_proj_exp_item_ref_pkg.get_project_status(xpan.project_id) project_status,
                 xxpa_proj_exp_item_ref_pkg.get_mfg_spec(xpan.mfg) mfg_spec,
                 xpan.amt,
                 xpan.currency_amt,
                 NULL po_number,
                 NULL po_line,
                 NULL transaction_source,
                 xpan.transaction_id || '' orginal_trans_ref,
                 NULL riginal_user_expnd_transf_ref,
                 NULL expenditure_batch,
                 NULL expenditure_comment,
                 NULL dff,
                 NULL transaction_type,
                 xpan.job job_number
                 
                ,
                 xxpa_proj_exp_item_ref_pkg.get_item_number(NULL,
                                                            NULL,
                                                            xpan.transaction_id) item_number,
                 xpan.job_type,
                 NULL so_invoice,
                 xxpa_proj_exp_item_ref_pkg.get_project_long_name(xpan.project_id) project_long_name,
                 xpan.project_id,
                 xpan.task_id,
                 xpan.souchi
            FROM xxpa_wip_cost_souchi_ne_v xpan
           WHERE xpan.org = g_org_name
             AND (xpan.gl_date >= g_date_from OR g_date_from IS NULL)
             AND xpan.gl_date <= g_date_to
             AND (xpan.project_id = g_project_id OR g_project_id IS NULL)
             AND (xpan.top_task_id = g_top_task_id OR g_top_task_id IS NULL)
             AND (EXISTS
                  (SELECT 1
                     FROM xxpa_wip_cost_gp_temp xwg
                    WHERE xwg.gp = xpan.group_parts) OR g_group_part IS NULL)*\
          ;
        --for performance same sql different hint
        CURSOR cur_project IS
          SELECT t.type,
                 t.org,
                 t.expenditure_item_id,
                 t.project_type,
                 t.proj_no,
                 t.mfg,
                 t.task,
                 t.group_parts,
                 t.expen_cate,
                 t.expen_type,
                 t.gl_date,
                 t.project_currency_code,
                 t.qty,
                 t.mfg_source,
                 t.project_status,
                 t.mfg_spec,
                 t.amt,
                 t.currency_amt,
                 t.po_number,
                 t.po_line,
                 t.transaction_source,
                 t.orginal_trans_ref,
                 t.original_user_expnd_transf_ref,
                 t.expenditure_batch,
                 t.expenditure_comment,
                 t.dff,
                 t.transaction_type,
                 t.job_number,
                 t.item_number,
                 t.job_type,
                 t.so_invoice,
                 t.project_long_name,
                 t.project_id,
                 t.task_id,
                 t.souchi
          
            FROM (SELECT 'WIP' TYPE,
                         hou.name org,
                         to_char(pei.expenditure_item_id) expenditure_item_id,
                         pa.project_type,
                         pa.segment1 proj_no,
                         mfg.task_number mfg,
                         pt.task_number task,
                         xxpa_wip_cost_souchi_dtl_pkg.generate_gp_souchi(p_expenditure_item_id => pei.expenditure_item_id) group_parts,
                         pet.expenditure_category expen_cate,
                         xxpa_proj_exp_item_ref_pkg.get_expen_type(p_expenditure_item_id => pei.expenditure_item_id,
                                                                   p_organization_id     => hou.organization_id) expen_type,
                         cdl.gl_date,
                         pei.project_currency_code,
                         pei.quantity qty,
                         xxpa_proj_exp_item_ref_pkg.get_mfg_source(pei.project_id, mfg.task_number) mfg_source,
                         xxpa_proj_exp_item_ref_pkg.get_project_status(pei.project_id) project_status,
                         xxpa_proj_exp_item_ref_pkg.get_mfg_spec(mfg.task_number) mfg_spec,
                         pei.project_burdened_cost amt,
                         pei.project_burdened_cost currency_amt,
                         xei.po_number po_number,
                         
                         xei.po_line po_line,
                         xei.transaction_source transaction_source,
                         xei.orginal_trans_ref orginal_trans_ref,
                         xei.original_user_expnd_transf_ref original_user_expnd_transf_ref,
                         xei.expenditure_group expenditure_batch,
                         xei.expenditure_comment expenditure_comment,
                         xei.dff dff,
                         xxpa_proj_exp_item_ref_pkg.get_transaction_type(pei.expenditure_item_id, 'WIP', NULL) transaction_type,
                         xxpa_proj_exp_item_ref_pkg.get_material_job(pei.expenditure_item_id, 'WIP', NULL) job_number,
                         xxpa_proj_exp_item_ref_pkg.get_item_number('WIP', pei.expenditure_item_id, NULL) item_number,
                         xxpa_proj_exp_item_ref_pkg.get_material_job_type(pei.expenditure_item_id, 'WIP', NULL) job_type,
                         NULL so_invoice,
                         xxpa_proj_exp_item_ref_pkg.get_project_long_name(pei.project_id) project_long_name,
                         pt.project_id,
                         pt.task_id,
                         NULL souchi
                    FROM apps.pa_expenditure_items_all  pei,
                         apps.pa_expenditures_all       pe,
                         apps.pa_expenditure_types      pet,
                         apps.hr_organization_units     hou,
                         apps.pa_projects_all           pa,
                         apps.pa_project_types_all      ppt,
                         apps.pa_tasks                  pt,
                         apps.pa_tasks                  mfg,
                         pa_cost_distribution_lines_all cdl,
                         apps.xxpa_exp_items_expend_v   xei
                   WHERE nvl(pei.override_to_organization_id, pe.incurred_by_organization_id) = hou.organization_id
                     AND pei.expenditure_id = pe.expenditure_id
                     AND pei.expenditure_type = pet.expenditure_type
                     AND pei.task_id = pt.task_id
                     AND pei.project_id = pa.project_id
                     AND pt.top_task_id = mfg.task_id
                     AND pa.project_type = ppt.project_type
                     AND pet.expenditure_category != 'FG Completion'
                        \* AND nvl(ppt.attribute7, -1) != 'OVERSEA'*\
                     AND cdl.line_type <> 'I'
                     AND (cdl.expenditure_item_id = pei.expenditure_item_id)
                     AND pei.expenditure_item_id = xei.expenditure_item_id(+)
                     AND hou.name = g_org_name
                     AND (cdl.gl_date >= g_date_from OR g_date_from IS NULL)
                     AND cdl.gl_date <= g_date_to
                        --modify by jingjing.he 2017-10-30 start
                     AND (((pa.project_id = g_project_id OR g_project_id IS NULL) AND
                          (pt.top_task_id = g_top_task_id OR g_top_task_id IS NULL)) OR
                          ((pa.project_id = g_project_id2 OR g_project_id2 IS NULL) AND
                          (pt.top_task_id = g_top_task_id2 OR g_top_task_id2 IS NULL)) OR
                          ((pa.project_id = g_project_id3 OR g_project_id3 IS NULL) AND
                          (pt.top_task_id = g_top_task_id3 OR g_top_task_id3 IS NULL)) OR
                          ((pa.project_id = g_project_id4 OR g_project_id4 IS NULL) AND
                          (pt.top_task_id = g_top_task_id4 OR g_top_task_id4 IS NULL)) OR
                          ((pa.project_id = g_project_id5 OR g_project_id5 IS NULL) AND
                          (pt.top_task_id = g_top_task_id5 OR g_top_task_id5 IS NULL)))
                  --modify by jingjing.he 2017-10-30 end
                  ) t
          --add order by logic by jingjing20180322 start
          \*ORDER BY t.proj_no,
          t.task,
          t.group_parts,
          t.souchi,
          t.expen_cate,
          t.expen_type,
          t.gl_date*\
          --add order by logic by jingjing20180322 end
          \*UNION ALL
          
          SELECT xpan.type TYPE,
                 xpan.org,
                 to_char(xpan.expenditure_item_id) expenditure_item_id,
                 -- xpan.expenditure_item_id,
                 xpan.project_type,
                 xpan.proj_no,
                 xpan.mfg,
                 xpan.task,
                 xpan.group_parts,
                 xpan.expen_cate,
                 xpan.expen_type,
                 xpan.gl_date,
                 xpan.currency_code project_currency_code,
                 xpan.qty,
                 xxpa_proj_exp_item_ref_pkg.get_mfg_source(xpan.project_id,
                                                           xpan.mfg) mfg_source,
                 xxpa_proj_exp_item_ref_pkg.get_project_status(xpan.project_id) project_status,
                 xxpa_proj_exp_item_ref_pkg.get_mfg_spec(xpan.mfg) mfg_spec,
                 xpan.amt,
                 xpan.currency_amt,
                 NULL po_number,
                 NULL po_line,
                 NULL transaction_source,
                 xpan.transaction_id || '' orginal_trans_ref,
                 NULL riginal_user_expnd_transf_ref,
                 NULL expenditure_batch,
                 NULL expenditure_comment,
                 NULL dff,
                 NULL transaction_type,
                 xpan.job job_number
                 
                ,
                 xxpa_proj_exp_item_ref_pkg.get_item_number(NULL,
                                                            NULL,
                                                            xpan.transaction_id) item_number,
                 xpan.job_type,
                 NULL so_invoice,
                 xxpa_proj_exp_item_ref_pkg.get_project_long_name(xpan.project_id) project_long_name,
                 xpan.project_id,
                 xpan.task_id,
                 xpan.souchi
            FROM xxpa_wip_cost_souchi_ne_v xpan
           WHERE xpan.org = g_org_name
             AND (xpan.gl_date >= g_date_from OR g_date_from IS NULL)
             AND xpan.gl_date <= g_date_to
             AND (xpan.project_id = g_project_id OR g_project_id IS NULL)
             AND (xpan.top_task_id = g_top_task_id OR g_top_task_id IS NULL)
             AND (EXISTS
                  (SELECT 1
                     FROM xxpa_wip_cost_gp_temp xwg
                    WHERE xwg.gp = xpan.group_parts) OR g_group_part IS NULL)*\
          ;
    */
    CURSOR cur_tmp IS
      SELECT *
        FROM xxpa_wip_cost_souchi_dtl_tmp t
       WHERE 1 = 1
         AND t.request_id = g_request_id
       ORDER BY t.proj_no,
                t.task,
                t.group_parts,
                t.souchi,
                t.expen_cate,
                t.expen_type,
                t.gl_date;
  
  BEGIN
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  
    output_head('Project Wip Cost Analysis Detail');
    log('10. ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
    output('<tr bgcolor="#FFAF60">');
    output_col_title('Org');
    output_col_title('Project Type');
    output_col_title('Proj No'); --todo1
    output_col_title('Task'); --todo2
    output_col_title('Parts'); --todo3
    output_col_title('Souchi'); --todo4
    output_col_title('Expen Cate'); --todo5
    output_col_title('Expen Type'); --todo6
    output_col_title('Gl Date'); --todo7
    output_col_title('Project Status');
    output_col_title('Mfg');
    output_col_title('Project Currency Code');
    output_col_title('Quantity');
    output_col_title('Amt');
    output_col_title('Currency Amt');
    output_col_title('Expenditure Item Id');
    output_col_title('Expenditure Batch');
    output_col_title('Transaction Source');
    output_col_title('Orginal Trans Ref');
    output_col_title('Original User Expnd Transf Ref');
    output_col_title('Transaction Type');
    output_col_title('Job Number');
    output_col_title('Po Number');
    output_col_title('Po Line');
    --output_col_title('Mfg Model');
  
    output_col_title('Mfg Spec');
    output_col_title('Comment');
    output_col_title('Item Number');
    output_col_title('Dff');
  
    output_col_title('Job Type');
    output_col_title('So Invoice');
    output_col_title('Project Long Name');
    output('</tr>');
    log('20. ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
  
    --10 create a tmp table
    --20 insert these data in the tmp table
    --30 get the data from the tmp table
    /*  
        --DELETE FROM xxpa_wip_cost_souchi_dtl_tmp;
        IF g_project_id IS NOT NULL OR g_top_task_id IS NOT NULL THEN
          FOR rec IN cur_project
          LOOP
            l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id); --modify by jingjing 20180321
            IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
              IF rec.expenditure_item_id IS NOT NULL THEN
                l_souchi := t_souchi(rec.expenditure_item_id);
              ELSE
                l_souchi := rec.souchi;
              END IF;
              l_xxpa_wip_cost_souchi_dtl_tmp.type                           := rec.type;
              l_xxpa_wip_cost_souchi_dtl_tmp.org                            := rec.org;
              l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_item_id            := rec.expenditure_item_id;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_type                   := rec.project_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.proj_no                        := rec.proj_no;
              l_xxpa_wip_cost_souchi_dtl_tmp.mfg                            := rec.mfg;
              l_xxpa_wip_cost_souchi_dtl_tmp.task                           := rec.task;
              l_xxpa_wip_cost_souchi_dtl_tmp.group_parts                    := rec.group_parts;
              l_xxpa_wip_cost_souchi_dtl_tmp.expen_cate                     := rec.expen_cate;
              l_xxpa_wip_cost_souchi_dtl_tmp.expen_type                     := rec.expen_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.gl_date                        := rec.gl_date;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_currency_code          := rec.project_currency_code;
              l_xxpa_wip_cost_souchi_dtl_tmp.qty                            := rec.qty;
              l_xxpa_wip_cost_souchi_dtl_tmp.mfg_source                     := rec.mfg_source;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_status                 := rec.project_status;
              l_xxpa_wip_cost_souchi_dtl_tmp.mfg_spec                       := rec.mfg_spec;
              l_xxpa_wip_cost_souchi_dtl_tmp.amt                            := rec.amt;
              l_xxpa_wip_cost_souchi_dtl_tmp.currency_amt                   := rec.currency_amt;
              l_xxpa_wip_cost_souchi_dtl_tmp.po_number                      := rec.po_number;
              l_xxpa_wip_cost_souchi_dtl_tmp.po_line                        := rec.po_line;
              l_xxpa_wip_cost_souchi_dtl_tmp.transaction_source             := rec.transaction_source;
              l_xxpa_wip_cost_souchi_dtl_tmp.orginal_trans_ref              := rec.orginal_trans_ref;
              l_xxpa_wip_cost_souchi_dtl_tmp.original_user_expnd_transf_ref := rec.original_user_expnd_transf_ref;
              l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_batch              := rec.expenditure_batch;
              l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_comment            := rec.expenditure_comment;
              l_xxpa_wip_cost_souchi_dtl_tmp.dff                            := rec.dff;
              l_xxpa_wip_cost_souchi_dtl_tmp.transaction_type               := rec.transaction_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.job_number                     := rec.job_number;
              l_xxpa_wip_cost_souchi_dtl_tmp.item_number                    := rec.item_number;
              l_xxpa_wip_cost_souchi_dtl_tmp.job_type                       := rec.job_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.so_invoice                     := rec.so_invoice;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_long_name              := rec.project_long_name;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_id                     := rec.project_id;
              l_xxpa_wip_cost_souchi_dtl_tmp.task_id                        := rec.task_id;
              l_xxpa_wip_cost_souchi_dtl_tmp.souchi                         := l_souchi;
              l_xxpa_wip_cost_souchi_dtl_tmp.request_id                     := g_request_id;
            
              INSERT INTO xxpa_wip_cost_souchi_dtl_tmp
              VALUES l_xxpa_wip_cost_souchi_dtl_tmp;
            
            END IF;
          END LOOP;
        ELSE
          FOR rec IN cur
          LOOP
            l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id);--modify by jingjing 20180321
            IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
              IF rec.expenditure_item_id IS NOT NULL THEN
                l_souchi := t_souchi(rec.expenditure_item_id);
              ELSE
                l_souchi := rec.souchi;
              END IF;
              l_xxpa_wip_cost_souchi_dtl_tmp.type                           := rec.type;
              l_xxpa_wip_cost_souchi_dtl_tmp.org                            := rec.org;
              l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_item_id            := rec.expenditure_item_id;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_type                   := rec.project_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.proj_no                        := rec.proj_no;
              l_xxpa_wip_cost_souchi_dtl_tmp.mfg                            := rec.mfg;
              l_xxpa_wip_cost_souchi_dtl_tmp.task                           := rec.task;
              l_xxpa_wip_cost_souchi_dtl_tmp.group_parts                    := rec.group_parts;
              l_xxpa_wip_cost_souchi_dtl_tmp.expen_cate                     := rec.expen_cate;
              l_xxpa_wip_cost_souchi_dtl_tmp.expen_type                     := rec.expen_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.gl_date                        := rec.gl_date;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_currency_code          := rec.project_currency_code;
              l_xxpa_wip_cost_souchi_dtl_tmp.qty                            := rec.qty;
              l_xxpa_wip_cost_souchi_dtl_tmp.mfg_source                     := rec.mfg_source;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_status                 := rec.project_status;
              l_xxpa_wip_cost_souchi_dtl_tmp.mfg_spec                       := rec.mfg_spec;
              l_xxpa_wip_cost_souchi_dtl_tmp.amt                            := rec.amt;
              l_xxpa_wip_cost_souchi_dtl_tmp.currency_amt                   := rec.currency_amt;
              l_xxpa_wip_cost_souchi_dtl_tmp.po_number                      := rec.po_number;
              l_xxpa_wip_cost_souchi_dtl_tmp.po_line                        := rec.po_line;
              l_xxpa_wip_cost_souchi_dtl_tmp.transaction_source             := rec.transaction_source;
              l_xxpa_wip_cost_souchi_dtl_tmp.orginal_trans_ref              := rec.orginal_trans_ref;
              l_xxpa_wip_cost_souchi_dtl_tmp.original_user_expnd_transf_ref := rec.original_user_expnd_transf_ref;
              l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_batch              := rec.expenditure_batch;
              l_xxpa_wip_cost_souchi_dtl_tmp.expenditure_comment            := rec.expenditure_comment;
              l_xxpa_wip_cost_souchi_dtl_tmp.dff                            := rec.dff;
              l_xxpa_wip_cost_souchi_dtl_tmp.transaction_type               := rec.transaction_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.job_number                     := rec.job_number;
              l_xxpa_wip_cost_souchi_dtl_tmp.item_number                    := rec.item_number;
              l_xxpa_wip_cost_souchi_dtl_tmp.job_type                       := rec.job_type;
              l_xxpa_wip_cost_souchi_dtl_tmp.so_invoice                     := rec.so_invoice;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_long_name              := rec.project_long_name;
              l_xxpa_wip_cost_souchi_dtl_tmp.project_id                     := rec.project_id;
              l_xxpa_wip_cost_souchi_dtl_tmp.task_id                        := rec.task_id;
              l_xxpa_wip_cost_souchi_dtl_tmp.souchi                         := l_souchi;
              l_xxpa_wip_cost_souchi_dtl_tmp.request_id                     := g_request_id;
            
              INSERT INTO xxpa_wip_cost_souchi_dtl_tmp
              VALUES l_xxpa_wip_cost_souchi_dtl_tmp;
            END IF;
          END LOOP;
        
        END IF;
    */
    --COMMIT;
  
    FOR rec IN cur_tmp
    LOOP
      output('<tr>');
      /*      output_column(rec.type, g_type_text);*/
      output_column(rec.org, g_type_text);
    
      output_column(rec.project_type, g_type_text);
      output_column(rec.proj_no, g_type_text); --todo1
      output_column(rec.task, g_type_text); --todo2
      output_column(rec.group_parts, g_type_text); --todo3
      output_column(rec.souchi, g_type_text); --souchi
      /*output_column(rec.completion_date, g_type_text);
      output_column(rec.first_invoice_date, g_type_text);*/
      output_column(rec.expen_cate, g_type_text); --todo5
      output_column(rec.expen_type, g_type_text); --todo6
      output_column(rec.gl_date, g_type_text); --todo7
      output_column(rec.project_status, g_type_text);
      output_column(rec.mfg, g_type_text);
      output_column(rec.project_currency_code, g_type_text);
      output_column(rec.qty, g_type_text);
      output_column(round(rec.amt, 2), g_type_text);
      output_column(round(rec.currency_amt, 2), g_type_text);
      output_column(rec.expenditure_item_id, g_type_text);
      output_column(rec.expenditure_batch, g_type_text);
      output_column(rec.transaction_source, g_type_text);
      output_column(rec.orginal_trans_ref, g_type_text);
      output_column(rec.original_user_expnd_transf_ref, g_type_text);
      output_column(rec.transaction_type, g_type_text);
      output_column(rec.job_number, g_type_text);
      output_column(rec.po_number, g_type_text);
      output_column(rec.po_line, g_type_text);
      /*output_column(rec.mfg_source, g_type_text);*/
      /*output_column(rec.model, g_type_text);*/
      output_column(rec.mfg_spec, g_type_text);
      output_column(rec.expenditure_comment, g_type_text);
      output_column(rec.item_number, g_type_text);
      output_column(rec.dff, g_type_text);
      output_column(rec.job_type, g_type_text);
      output_column(rec.so_invoice, g_type_text);
      output_column(rec.project_long_name, g_type_text);
      output('</tr>');
    END LOOP;
  
    /*IF g_project_id IS NOT NULL OR g_top_task_id IS NOT NULL THEN
      FOR rec IN cur_project
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id); --modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          log('project_type = ' || rec.project_type);
          log('project_id = ' || rec.project_id);
          log('task_id = ' || rec.task_id);
          log('expen_type = ' || rec.expen_type || '>>>>');
          log('expenditure_item_id = ' || rec.expenditure_item_id);
          output('<tr>');
          \*      output_column(rec.type, g_type_text);*\
          output_column(rec.org, g_type_text);
        
          output_column(rec.project_type, g_type_text);
          output_column(rec.proj_no, g_type_text); --todo1
          output_column(rec.task, g_type_text); --todo2
          output_column(l_group_part, g_type_text); --todo3
          IF rec.expenditure_item_id IS NOT NULL THEN
            output_column(t_souchi(rec.expenditure_item_id), g_type_text);
          ELSE
            output_column(rec.souchi, g_type_text); --souchi
          END IF; --todo4
          \*output_column(rec.completion_date, g_type_text);
          output_column(rec.first_invoice_date, g_type_text);*\
          output_column(rec.expen_cate, g_type_text); --todo5
          output_column(rec.expen_type, g_type_text); --todo6
          output_column(rec.gl_date, g_type_text); --todo7
          output_column(rec.project_status, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.project_currency_code, g_type_text);
          output_column(rec.qty, g_type_text);
          output_column(round(rec.amt, 2), g_type_text);
          output_column(round(rec.currency_amt, 2), g_type_text);
          output_column(rec.expenditure_item_id, g_type_text);
          output_column(rec.expenditure_batch, g_type_text);
          output_column(rec.transaction_source, g_type_text);
          output_column(rec.orginal_trans_ref, g_type_text);
          output_column(rec.original_user_expnd_transf_ref, g_type_text);
          output_column(rec.transaction_type, g_type_text);
          output_column(rec.job_number, g_type_text);
          output_column(rec.po_number, g_type_text);
          output_column(rec.po_line, g_type_text);
          \*output_column(rec.mfg_source, g_type_text);*\
          \*output_column(rec.model, g_type_text);*\
          output_column(rec.mfg_spec, g_type_text);
          output_column(rec.expenditure_comment, g_type_text);
          output_column(rec.item_number, g_type_text);
          output_column(rec.dff, g_type_text);
          output_column(rec.job_type, g_type_text);
          output_column(rec.so_invoice, g_type_text);
          output_column(rec.project_long_name, g_type_text);
          output('</tr>');
        END IF;
      END LOOP;
    ELSE
      FOR rec IN cur
      LOOP
        l_group_part := rec.group_parts; --generate_gp_souchi(p_expenditure_item_id => rec.expenditure_item_id);--modify by jingjing 20180321
        IF t_group_part.exists(l_group_part) OR g_group_part IS NULL THEN
          \*          log(rec.project_type);
          log(rec.project_id);
          log(rec.task_id);*\
          log('project_type = ' || rec.project_type);
          log('project_id = ' || rec.project_id);
          log('task_id = ' || rec.task_id);
          log('expen_type = ' || rec.expen_type || '>>>>');
          log('expenditure_item_id = ' || rec.expenditure_item_id);
          output('<tr>');
          \*      output_column(rec.type, g_type_text);*\
          output_column(rec.org, g_type_text);
        
          output_column(rec.project_type, g_type_text);
          output_column(rec.proj_no, g_type_text); --todo1
          output_column(rec.task, g_type_text); --todo2
          output_column(l_group_part, g_type_text); --todo3
          IF rec.expenditure_item_id IS NOT NULL THEN
            output_column(t_souchi(rec.expenditure_item_id), g_type_text);
          ELSE
            output_column(rec.souchi, g_type_text); --souchi
          END IF; --todo4
          \*output_column(rec.completion_date, g_type_text);
          output_column(rec.first_invoice_date, g_type_text);*\
          output_column(rec.expen_cate, g_type_text); --todo5
          output_column(rec.expen_type, g_type_text); --todo6
          output_column(rec.gl_date, g_type_text); --todo7
          output_column(rec.project_status, g_type_text);
          output_column(rec.mfg, g_type_text);
          output_column(rec.project_currency_code, g_type_text);
          output_column(rec.qty, g_type_text);
          output_column(round(rec.amt, 2), g_type_text);
          output_column(round(rec.currency_amt, 2), g_type_text);
          output_column(rec.expenditure_item_id, g_type_text);
          output_column(rec.expenditure_batch, g_type_text);
          output_column(rec.transaction_source, g_type_text);
          output_column(rec.orginal_trans_ref, g_type_text);
          output_column(rec.original_user_expnd_transf_ref, g_type_text);
          output_column(rec.transaction_type, g_type_text);
          output_column(rec.job_number, g_type_text);
          output_column(rec.po_number, g_type_text);
          output_column(rec.po_line, g_type_text);
          \*output_column(rec.mfg_source, g_type_text);*\
          \*output_column(rec.model, g_type_text);*\
          output_column(rec.mfg_spec, g_type_text);
          output_column(rec.expenditure_comment, g_type_text);
          output_column(rec.item_number, g_type_text);
          output_column(rec.dff, g_type_text);
          output_column(rec.job_type, g_type_text);
          output_column(rec.so_invoice, g_type_text);
          output_column(rec.project_long_name, g_type_text);
          output('</tr>');
        END IF;
      END LOOP;
    
    END IF;*/
    DELETE FROM xxpa_wip_cost_souchi_dtl_tmp t
     WHERE 1 = 1
       AND t.request_id = g_request_id;
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
    
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END process_request2;

  PROCEDURE main(x_errbuf          OUT VARCHAR2,
                 x_retcode         OUT VARCHAR2,
                 p_organization_id IN VARCHAR2,
                 p_date_from       IN VARCHAR2,
                 p_date_to         IN VARCHAR2,
                 p_project_id      IN NUMBER,
                 p_top_task_id     IN NUMBER,
                 p_project_id2     IN NUMBER, --add by jingjing.he 2017-10-30
                 p_top_task_id2    IN NUMBER, --add by jingjing.he 2017-10-30
                 p_project_id3     IN NUMBER, --add by jingjing.he 2017-10-30
                 p_top_task_id3    IN NUMBER, --add by jingjing.he 2017-10-30
                 p_project_id4     IN NUMBER, --add by jingjing.he 2017-10-30
                 p_top_task_id4    IN NUMBER, --add by jingjing.he 2017-10-30
                 p_project_id5     IN NUMBER, --add by jingjing.he 2017-10-30
                 p_top_task_id5    IN NUMBER, --add by jingjing.he 2017-10-30
                 p_group_part      IN VARCHAR2) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  BEGIN
  
    g_date_from    := trunc(fnd_conc_date.string_to_date(p_date_from));
    g_date_to      := trunc(fnd_conc_date.string_to_date(p_date_to)) + 0.99999;
    g_project_id   := p_project_id;
    g_top_task_id  := p_top_task_id;
    g_project_id2  := p_project_id2; --add by jingjing.he 2017-10-30
    g_top_task_id2 := p_top_task_id2; --add by jingjing.he 2017-10-30
    g_project_id3  := p_project_id3; --add by jingjing.he 2017-10-30
    g_top_task_id3 := p_top_task_id3; --add by jingjing.he 2017-10-30
    g_project_id4  := p_project_id4; --add by jingjing.he 2017-10-30
    g_top_task_id4 := p_top_task_id4; --add by jingjing.he 2017-10-30
    g_project_id5  := p_project_id5; --add by jingjing.he 2017-10-30
    g_top_task_id5 := p_top_task_id5; --add by jingjing.he 2017-10-30
    g_group_part   := p_group_part;
    IF g_group_part IS NOT NULL THEN
      split_group_part(p_group_part);
    END IF;
  
    SELECT ood.operating_unit,
           ood.organization_id,
           hou.name,
           ood.organization_name
      INTO g_org_id,
           g_organization_id,
           g_ou_name,
           g_org_name
      FROM org_organization_definitions ood,
           hr_operating_units           hou
     WHERE ood.operating_unit = hou.organization_id
       AND ood.organization_id = p_organization_id;
    --
    /*
      generate_gp_souchi(g_org_id);
    */
    --
    log('g_request_id      : ' || g_request_id);
    log('g_org_name      : ' || g_org_name);
    log('g_date_from     : ' || g_date_from);
    log('g_date_to       : ' || g_date_to);
    log('g_project_id    : ' || g_project_id);
    log('g_mfg_number    : ' || g_top_task_id);
    log('g_project_id2    : ' || g_project_id2);
    log('g_mfg_number2    : ' || g_top_task_id2);
    log('g_project_id3    : ' || g_project_id3);
    log('g_mfg_number3    : ' || g_top_task_id3);
    log('g_project_id4    : ' || g_project_id4);
    log('g_mfg_number4    : ' || g_top_task_id4);
    log('g_project_id5    : ' || g_project_id5);
    log('g_mfg_number5    : ' || g_top_task_id5);
    log('g_group_part    : ' || g_group_part);
  
    log('Start print ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
    IF g_project_id IS NULL AND g_top_task_id IS NOT NULL THEN
      SELECT pt.project_id
        INTO g_project_id
        FROM pa_tasks pt
       WHERE pt.task_id = g_top_task_id;
      --add by jingjing.he 2017-10-30 start
      IF g_project_id2 IS NULL AND g_top_task_id2 IS NOT NULL THEN
        SELECT pt.project_id
          INTO g_project_id2
          FROM pa_tasks pt
         WHERE pt.task_id = g_top_task_id2;
      
        IF g_project_id3 IS NULL AND g_top_task_id3 IS NOT NULL THEN
          SELECT pt.project_id
            INTO g_project_id3
            FROM pa_tasks pt
           WHERE pt.task_id = g_top_task_id3;
        
          IF g_project_id4 IS NULL AND g_top_task_id4 IS NOT NULL THEN
            SELECT pt.project_id
              INTO g_project_id4
              FROM pa_tasks pt
             WHERE pt.task_id = g_top_task_id4;
          
            IF g_project_id5 IS NULL AND g_top_task_id5 IS NOT NULL THEN
              SELECT pt.project_id
                INTO g_project_id5
                FROM pa_tasks pt
               WHERE pt.task_id = g_top_task_id5;
            END IF;
          END IF;
        END IF;
      END IF;
      --add by jingjing.he 2017-10-30 end
    END IF;
  
    --collect data
    --IF 
    g_project_id   := p_project_id;
    g_top_task_id  := p_top_task_id;
    g_project_id2  := p_project_id2; --add by jingjing.he 2017-10-30
    g_top_task_id2 := p_top_task_id2; --add by jingjing.he 2017-10-30
    g_project_id3  := p_project_id3; --add by jingjing.he 2017-10-30
    g_top_task_id3 := p_top_task_id3; --add by jingjing.he 2017-10-30
    g_project_id4  := p_project_id4; --add by jingjing.he 2017-10-30
    g_top_task_id4 := p_top_task_id4; --add by jingjing.he 2017-10-30
    g_project_id5  := p_project_id5; --add by jingjing.he 2017-10-30
    g_top_task_id5 := p_top_task_id5;
  
    IF g_project_id IS NOT NULL THEN
      collect_data(g_project_id, g_top_task_id);
      
      IF g_project_id2 IS NOT NULL THEN
        collect_data(g_project_id2, g_top_task_id2);
        
        IF g_project_id3 IS NOT NULL THEN
          collect_data(g_project_id3, g_top_task_id3);
          
          IF g_project_id4 IS NOT NULL THEN
            collect_data(g_project_id4, g_top_task_id4);
            
            IF g_project_id5 IS NOT NULL THEN
              collect_data(g_project_id5, g_top_task_id5);
              
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  
    process_request2(p_init_msg_list => fnd_api.g_true,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data);
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    log('End print ' || to_char(SYSDATE, 'YYYY-MON-DD HH24:MI:SS'));
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      xxfnd_conc_utl.log_message_list;
      x_retcode := '1';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      x_errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      x_retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      x_errbuf := l_msg_data;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                              p_procedure_name => 'MAIN',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      x_retcode := '2';
      x_errbuf  := SQLERRM;
  END main;

END xxpa_wip_cost_souchi_dtl_pkg;
/
