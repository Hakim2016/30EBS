CREATE OR REPLACE PACKAGE xxpa_proj_accrual_rep_pkg AS
function get_po_number(p_transaction_source         in varchar2,
                         p_document_header_id         in number,
                         p_orig_transaction_reference in varchar2,
                         p_expenditure_item_id        in number) return varchar2;

  PROCEDURE main(x_errbuf       OUT VARCHAR2,
                 x_retcode      OUT VARCHAR2,
                 p_period       IN VARCHAR2,
                 p_project_id   IN NUMBER,
                 p_top_task_id  IN NUMBER,
                 p_type         IN VARCHAR2,
                 p_accrual_type IN VARCHAR2);

END;
/
CREATE OR REPLACE PACKAGE BODY xxpa_proj_accrual_rep_pkg AS

  -- Accrual Type
  g_accrual_actual   VARCHAR2(150) := 'Actual';
  g_accrual_taken    VARCHAR2(150) := 'Taken';
  g_accrual_offset   VARCHAR2(150) := 'Offset';
  g_accrual_transfer VARCHAR2(150) := 'Transfer';
  g_accrual_balance  VARCHAR2(150) := 'Balance';

  g_sum_total_cost NUMBER := 0;
  TYPE total_tab IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  g_grand_tab total_tab;
  g_space     VARCHAR2(40) := '&nbsp';

  CURSOR exp_types_c IS
    SELECT expenditure_type FROM xxpa_exp_report_titles_v;
  /*SELECT DISTINCT t.expenditure_category    AS  expenditure_category,
                  t.report_exp_type         AS  expenditure_type
    FROM xxpa_proj_exp_items_tmp  t
   WHERE t.expenditure_type != 'Material'
  ORDER BY xxpa_reports_utils.get_title_seqnum(
             t.report_exp_type);*/

  CURSOR exp_types2_c IS
    SELECT expenditure_category, COUNT(expenditure_type) exp_type_cnt
      FROM xxpa_exp_report_titles_v
     GROUP BY expenditure_category
     ORDER BY xxpa_reports_utils.get_title_seqnum2(expenditure_category);
  /*SELECT t.expenditure_category             AS  expenditure_category,
         COUNT(DISTINCT t.report_exp_type)  AS  exp_type_cnt
    FROM xxpa_proj_exp_items_tmp  t
   WHERE t.expenditure_type != 'Material'
  GROUP BY t.expenditure_category
  ORDER BY xxpa_reports_utils.get_title_seqnum2(
             t.expenditure_category);*/

  PROCEDURE log(p_msg VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_msg);
  END;

  PROCEDURE output(p_msg VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_msg);
  END;

  PROCEDURE output2(p_column_title VARCHAR2) IS
    l_column_td    VARCHAR2(200) := ' <td rowspan=2 align=left>p_column_title</td>';
    l_column_title VARCHAR2(200);
  BEGIN
    l_column_title := REPLACE(l_column_td, 'p_column_title', p_column_title);
    output(l_column_title);
  END;

  PROCEDURE output3(p_column_title VARCHAR2) IS
    l_column_td    VARCHAR2(200) := ' <td align=left><b>p_column_title</b></td>';
    l_column_title VARCHAR2(200);
  BEGIN
    l_column_title := REPLACE(l_column_td, 'p_column_title', p_column_title);
    output(l_column_title);
  END;

  FUNCTION get_func_cost(p_project_id       NUMBER,
                         p_top_task_id      NUMBER,
                         p_expenditure_type VARCHAR2) RETURN NUMBER IS
    l_func_cost NUMBER;
  BEGIN

    l_func_cost := xxpa_reports_utils.get_func_cost(p_project_id,
                                                    p_top_task_id,
                                                    p_expenditure_type);

    RETURN l_func_cost;

  END;

  FUNCTION get_func_cost_hbs(p_project_id       NUMBER,
                             p_top_task_id      NUMBER,
                             p_expenditure_type VARCHAR2,
                             p_po_number        varchar2) RETURN NUMBER IS
    CURSOR cost_c(p_project_id       NUMBER,
                  p_top_task_id      NUMBER,
                  p_expenditure_type VARCHAR2,
                  p_po_number        varchar2) IS
      SELECT SUM(t.burden_cost)
        FROM xxpa.xxpa_proj_exp_items_tmp3 t
       WHERE 1 = 1
         AND t.expenditure_type NOT IN
             ('Material',
              'Material Overhead',
              'Resource',
              'Outsourcing',
              'Overhead')
         AND t.project_id = p_project_id
         AND t.top_task_id = p_top_task_id
         AND t.report_exp_type = p_expenditure_type
         and NVL(t.po_number, -999) = NVL(p_po_number, -999);

    CURSOR cost2_c(p_project_id  NUMBER,
                   p_top_task_id NUMBER,
                   p_category    VARCHAR2,
                   p_po_number   varchar2) IS
      SELECT SUM(t.burden_cost)
        FROM xxpa.xxpa_proj_exp_items_tmp3 t
       WHERE 1 = 1
         AND t.expenditure_type IN ('Material',
                                    'Material Overhead',
                                    'Resource',
                                    'Outsourcing',
                                    'Overhead')
         AND t.project_id = p_project_id
         AND t.top_task_id = p_top_task_id
         and t.po_number = p_po_number
         AND xxpa_reports_utils.get_material_category(xxpa_reports_utils.fun_get_report_exp_type(t.expenditure_item_id)) =
             p_category;

    l_func_cost NUMBER;
    l_addl_cost NUMBER;
    l_category  mtl_categories_b_kfv.concatenated_segments%TYPE;
  BEGIN

    OPEN cost_c(p_project_id,
                p_top_task_id,
                p_expenditure_type,
                p_po_number);
    FETCH cost_c
      INTO l_func_cost;
    IF cost_c%NOTFOUND THEN
      l_func_cost := NULL;
    END IF;
    CLOSE cost_c;

    l_func_cost := nvl(l_func_cost, 0);

    l_category := xxpa_reports_utils.get_material_category(p_expenditure_type);
    IF l_category IS NOT NULL THEN

      OPEN cost2_c(p_project_id, p_top_task_id, l_category, p_po_number);
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
  --get Original/Additional/JIP
  FUNCTION get_oaj(p_period IN VARCHAR2, p_top_task_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR cur IS
      SELECT xpmm.hand_over_date
        FROM xxpa_proj_milestone_manage_all xpmm
       WHERE xpmm.task_id = p_top_task_id;

    l_hand_over_date DATE;
    l_source         VARCHAR2(10);
    l_start_date     DATE;
    l_end_date       DATE;
  BEGIN

    OPEN cur;
    FETCH cur
      INTO l_hand_over_date;
    CLOSE cur;

    xxpa_reports_utils.get_period_date(p_period, l_start_date, l_end_date);
    l_end_date := trunc(l_end_date) + 0.99999;

    IF l_hand_over_date BETWEEN l_start_date AND l_end_date THEN
      l_source := 'Original';
    ELSIF l_hand_over_date < l_start_date THEN
      l_source := 'Additional';
    ELSE
      l_source := 'JIP';
    END IF;
    RETURN l_source;
  END get_oaj;

  FUNCTION get_fully_packing_date(p_top_task_id IN NUMBER) RETURN DATE IS

    CURSOR cur IS
      SELECT xpmm.ba_fully_packing_date
        FROM xxpa_proj_milestone_manage_all xpmm
       WHERE xpmm.task_id = p_top_task_id;

    l_fully_packing_date DATE;

  BEGIN

    OPEN cur;
    FETCH cur
      INTO l_fully_packing_date;
    CLOSE cur;

    RETURN l_fully_packing_date;

  END get_fully_packing_date;

  PROCEDURE output_value(p_column_value VARCHAR2) IS
    l_column_td    VARCHAR2(500) := ' <td align=left style="mso-number-format:\@">column_text</td>';
    l_column_value VARCHAR2(500);
  BEGIN
    l_column_value := REPLACE(l_column_td,
                              'column_text',
                              NVL(p_column_value, g_space));
    output(l_column_value);
  END;

  PROCEDURE output_value2(p_column_value VARCHAR2) IS
    l_column_td    VARCHAR2(500) := ' <td align=left><b>column_text</b></td>';
    l_column_value VARCHAR2(500);
  BEGIN
    l_column_value := REPLACE(l_column_td,
                              'column_text',
                              NVL(p_column_value, g_space));
    output(l_column_value);
  END;

  PROCEDURE output_amount(p_amount NUMBER) IS
    l_column_td    VARCHAR2(500) := ' <td align=right>column_text</td>';
    l_column_value VARCHAR2(500);
  BEGIN
    l_column_value := REPLACE(l_column_td,
                              'column_text',
                              NVL(xxpa_utils.format_amount(p_amount),
                                  g_space));
    output(l_column_value);
  END;

  PROCEDURE output_head(p_title        VARCHAR2,
                        p_accrual_type IN VARCHAR2,
                        p_type         IN VARCHAR2) IS
    l_seq_num NUMBER := 0;
    -- report title
    l_title VARCHAR2(500) := '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" >' ||
                             '<head> <title>p_title</title>' ||
                             ' <meta http-equiv="Content-Type" content="text/html; charset=GB2312">' ||
                             ' </head> <body>' ||
                             xxpa_reports_utils.get_title_style;

    -- column title
    l_column_title VARCHAR2(4000) := ' <table width=200% border=1 cellspacing=0 cellpadding=0' ||
                                     xxpa_reports_utils.get_table_style ||
                                     ' tyle="BORDER-COLLAPSE: collapse ">' ||
                                     ' <tr style="font-weight:bold;">';

  BEGIN

    l_title := REPLACE(l_title, 'p_title', p_title);
    output(l_title);
    output(l_column_title);
    output2('S/N');
    output2('MFG No');
    output2('Project No');
    output2('Project Name');
    output2('Fully Packing Period'); --Added by fandong.chen 20130703
    IF p_accrual_type = g_accrual_actual AND p_type = 'ER' THEN
      output2('Original/Additional/JIP');
    END IF;
    FOR one_type IN exp_types2_c LOOP
      l_seq_num := l_seq_num + 1;
      output(' <td colspan=' || one_type.exp_type_cnt || ' align=center>' ||
             one_type.expenditure_category || '</td>');
    END LOOP;
    output2('Total Cost');
    output('</tr>');

    FOR one_type IN exp_types_c LOOP
      output3(one_type.expenditure_type);
    END LOOP;
    IF l_seq_num = 0 THEN
      output('<tr></tr>');
    ELSE
      output('</tr>');
    END IF;

  END;

  PROCEDURE output_head_hbs(p_title        VARCHAR2,
                            p_accrual_type IN VARCHAR2,
                            p_type         IN VARCHAR2) IS
    l_seq_num NUMBER := 0;
    -- report title
    l_title VARCHAR2(500) := '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" >' ||
                             '<head> <title>p_title</title>' ||
                             ' <meta http-equiv="Content-Type" content="text/html; charset=GB2312">' ||
                             ' </head> <body>' ||
                             xxpa_reports_utils.get_title_style;

    -- column title
    l_column_title VARCHAR2(4000) := ' <table width=200% border=1 cellspacing=0 cellpadding=0' ||
                                     xxpa_reports_utils.get_table_style ||
                                     ' tyle="BORDER-COLLAPSE: collapse ">' ||
                                     ' <tr style="font-weight:bold;">';

  BEGIN

    l_title := REPLACE(l_title, 'p_title', p_title);
    output(l_title);
    output(l_column_title);
    output2('S/N');
    output2('MFG No');
    output2('Project No');
    output2('Project Name');
    output2('Fully Packing Period'); --Added by fandong.chen 20130703
    output2('PO No');
    IF p_accrual_type = g_accrual_actual AND p_type = 'ER' THEN
      output2('Original/Additional/JIP');
    END IF;
    FOR one_type IN exp_types2_c LOOP
      l_seq_num := l_seq_num + 1;
      output(' <td colspan=' || one_type.exp_type_cnt || ' align=center>' ||
             one_type.expenditure_category || '</td>');
    END LOOP;
    output2('Total Cost');
    output('</tr>');

    FOR one_type IN exp_types_c LOOP
      output3(one_type.expenditure_type);
    END LOOP;
    IF l_seq_num = 0 THEN
      output('<tr></tr>');
    ELSE
      output('</tr>');
    END IF;

  END;

  PROCEDURE output_body(p_project_id     NUMBER,
                        p_top_task_id    NUMBER,
                        p_seq_num        NUMBER,
                        p_mfg_number     VARCHAR2,
                        p_project_number VARCHAR2,
                        p_project_name   VARCHAR2,
                        p_period         IN VARCHAR2,
                        p_accrual_type   IN VARCHAR2,
                        p_type           IN VARCHAR2) IS
    l_func_cost    NUMBER;
    l_exp_type_tab total_tab;
    l_seq_num      NUMBER;
    l_total_cost   NUMBER;
  BEGIN

    l_seq_num    := 0;
    l_total_cost := 0;
    FOR one_type IN exp_types_c LOOP
      l_func_cost := get_func_cost(p_project_id,
                                   p_top_task_id,
                                   one_type.expenditure_type);
      l_func_cost := NVL(l_func_cost, 0);
      l_seq_num := l_seq_num + 1;
      l_exp_type_tab(l_seq_num) := l_func_cost;
      IF NOT g_grand_tab.exists(l_seq_num) THEN
        g_grand_tab(l_seq_num) := NVL(l_func_cost, 0);
      ELSE
        g_grand_tab(l_seq_num) := NVL(g_grand_tab(l_seq_num), 0) +
                                  NVL(l_func_cost, 0);
      END IF;

      l_total_cost := l_total_cost + NVL(l_func_cost, 0);
    END LOOP;
    g_sum_total_cost := g_sum_total_cost + NVL(l_total_cost, 0);

    IF nvl(l_total_cost, 0) <> 0 THEN
      --Added by fandong.chen 20130703

      output('<tr>');
      output_value(p_seq_num);
      output_value(p_mfg_number);
      output_value(p_project_number);
      output_value(p_project_name);
      output_value(to_char(get_fully_packing_date(p_top_task_id), 'MON-YY')); --Added by fandong.chen 20130703

      IF p_accrual_type = g_accrual_actual AND p_type = 'ER' THEN
        output_value(get_oaj(p_period, p_top_task_id));
      END IF;

      FOR i IN 1 .. l_exp_type_tab.count LOOP
        output_amount(l_exp_type_tab(i));
      END LOOP;
      output_amount(l_total_cost);
      output('</tr>');

    END IF;

  END;

  PROCEDURE output_body_hbs(p_project_id     NUMBER,
                            p_top_task_id    NUMBER,
                            p_seq_num        NUMBER,
                            p_mfg_number     VARCHAR2,
                            p_project_number VARCHAR2,
                            p_project_name   VARCHAR2,
                            p_period         IN VARCHAR2,
                            p_accrual_type   IN VARCHAR2,
                            p_type           IN VARCHAR2,
                            p_po_number      in varchar2) IS
    l_func_cost    NUMBER;
    l_exp_type_tab total_tab;
    l_seq_num      NUMBER;
    l_total_cost   NUMBER;
  BEGIN

    l_seq_num    := 0;
    l_total_cost := 0;
    FOR one_type IN exp_types_c LOOP
      l_func_cost := get_func_cost_hbs(p_project_id,
                                       p_top_task_id,
                                       one_type.expenditure_type,
                                       p_po_number);
      l_func_cost := NVL(l_func_cost, 0);
      l_seq_num := l_seq_num + 1;
      l_exp_type_tab(l_seq_num) := l_func_cost;
      IF NOT g_grand_tab.exists(l_seq_num) THEN
        g_grand_tab(l_seq_num) := NVL(l_func_cost, 0);
      ELSE
        g_grand_tab(l_seq_num) := NVL(g_grand_tab(l_seq_num), 0) +
                                  NVL(l_func_cost, 0);
      END IF;

      l_total_cost := l_total_cost + NVL(l_func_cost, 0);
    END LOOP;
    g_sum_total_cost := g_sum_total_cost + NVL(l_total_cost, 0);

    IF nvl(l_total_cost, 0) <> 0 THEN
      --Added by fandong.chen 20130703

      output('<tr>');
      output_value(p_seq_num);
      output_value(p_mfg_number);
      output_value(p_project_number);
      output_value(p_project_name);
      output_value(to_char(get_fully_packing_date(p_top_task_id), 'MON-YY')); --Added by fandong.chen 20130703
      output_value(p_po_number);

      IF p_accrual_type = g_accrual_actual AND p_type = 'ER' THEN
        output_value(get_oaj(p_period, p_top_task_id));
      END IF;

      FOR i IN 1 .. l_exp_type_tab.count LOOP
        output_amount(l_exp_type_tab(i));
      END LOOP;
      output_amount(l_total_cost);
      output('</tr>');

    END IF;

  END;

  PROCEDURE output_end IS
    l_end_html CONSTANT VARCHAR2(50) := '</table></body> </html>';
  BEGIN
    output(l_end_html);
  END;

  PROCEDURE generate_report_data(p_period       VARCHAR2,
                                 p_project_id   NUMBER,
                                 p_top_task_id  NUMBER,
                                 p_type         VARCHAR2,
                                 p_accrual_type VARCHAR2) IS
    l_task_type  pa_task_types.task_type%TYPE;
    l_start_date DATE;
    l_end_date   DATE;
  BEGIN

    xxpa_reports_utils.get_period_date(p_period, l_start_date, l_end_date);
    l_end_date := trunc(l_end_date) + 0.99999;

    IF p_type = 'EQ' THEN
      l_task_type := 'EQ COST';
    ELSIF p_type = 'ER' THEN
      l_task_type := 'ER COST';
    ELSE
      l_task_type := NULL;
    END IF;

    INSERT INTO xxpa_proj_exp_items_tmp
      (expenditure_item_id,
       org_id,
       project_id,
       top_task_id,
       task_id,
       inventory_item_id,
       expenditure_category,
       expenditure_type,
       burden_cost,
       report_exp_type)
      SELECT pei.expenditure_item_id AS expenditure_item_id,
             pei.org_id AS org_id,
             pei.project_id AS project_id,
             top.task_id AS top_task_id,
             pei.task_id AS task_id,
             pei.inventory_item_id AS inventory_item_id,
             pet.expenditure_category AS expenditure_category,
             pei.expenditure_type AS expenditure_type,
             DECODE(pei.system_linkage_function,
                    'ST',
                    DECODE(pa_security.view_labor_costs(pei.project_id),
                           'Y',
                           pei.burden_cost,
                           NULL),
                    'OT',
                    DECODE(pa_security.view_labor_costs(pei.project_id),
                           'Y',
                           pei.burden_cost,
                           NULL),
                    pei.burden_cost) AS burden_cost,
             DECODE(pet.attribute_category,
                    'HEA_OU',
                    NVL(pet.attribute15, pei.expenditure_type),
                    pei.expenditure_type) AS report_exp_type

        FROM pa_expenditure_items pei,
             pa_expenditure_types pet,
             pa_tasks             pt,
             pa_proj_elements     ppe,
             pa_task_types        ptt,
             pa_tasks             top,
             pa_projects_all      pa

       WHERE pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pt.task_id = ppe.proj_element_id
         AND ppe.type_id = ptt.task_type_id
         AND ptt.task_type = l_task_type
         AND pt.top_task_id = top.task_id
         AND pei.project_id = pa.project_id
         AND (p_accrual_type = g_accrual_balance AND
             pet.attribute14 IN (g_accrual_taken, g_accrual_offset) OR
             pet.attribute14 = p_accrual_type)
         AND (p_accrual_type = g_accrual_balance AND
             pei.expenditure_item_date <= l_end_date OR
             pei.expenditure_item_date >= l_start_date AND
             pei.expenditure_item_date <= l_end_date)
         AND pa.project_id = NVL(p_project_id, pa.project_id)
         AND top.task_id = NVL(p_top_task_id, top.task_id);

  END;

  function get_po_number(p_transaction_source         in varchar2,
                         p_document_header_id         in number,
                         p_orig_transaction_reference in varchar2,
                         p_expenditure_item_id        in number)
    return varchar2 is
    l_po_number varchar2(50);
  begin
    if p_transaction_source = 'PO RECEIPT' then
      begin
        select h.segment1
          into l_po_number
          from po_headers_all h
         where h.po_header_id = p_document_header_id;
      exception
        when others then
          l_po_number := null;
      end;
    elsif p_transaction_source = 'Inventory' then
      begin
        select ph.segment1
          into l_po_number
          from mtl_material_transactions mmt,
               rcv_transactions          rt,
               po_headers_all            ph
         where mmt.rcv_transaction_id = rt.transaction_id
           and rt.po_header_id = ph.po_header_id
           and mmt.transaction_id = p_orig_transaction_reference;
      exception
        when others then
          l_po_number := null;
      end;
    elsif p_transaction_source is null or
          p_transaction_source in ('Other Cost2', 'HBS_Oracle') then
      begin
        select substr(px.expenditure_comment,
                      1,
                      instr(px.expenditure_comment, '-', 1) - 1)
          into l_po_number
          from pa_expenditure_comments px

         where px.expenditure_item_id = p_expenditure_item_id;
      exception
        when others then
          l_po_number := null;
      end;
    else
      l_po_number := null;
    end if;
    return l_po_number;
  exception
    when others then
      return null;
  end;

  PROCEDURE generate_report_data_hbs(p_period       VARCHAR2,
                                     p_project_id   NUMBER,
                                     p_top_task_id  NUMBER,
                                     p_type         VARCHAR2,
                                     p_accrual_type VARCHAR2) IS
    l_task_type  pa_task_types.task_type%TYPE;
    l_start_date DATE;
    l_end_date   DATE;
  BEGIN

    xxpa_reports_utils.get_period_date(p_period, l_start_date, l_end_date);
    l_end_date := trunc(l_end_date) + 0.99999;

    IF p_type = 'EQ' THEN
      l_task_type := 'EQ COST';
    ELSIF p_type = 'ER' THEN
      l_task_type := 'ER COST';
    ELSE
      l_task_type := NULL;
    END IF;

    INSERT INTO xxpa.xxpa_proj_exp_items_tmp3
      (expenditure_item_id,
       org_id,
       project_id,
       top_task_id,
       task_id,
       inventory_item_id,
       expenditure_category,
       expenditure_type,
       burden_cost,
       report_exp_type,
       po_number)
      SELECT pei.expenditure_item_id AS expenditure_item_id,
             pei.org_id AS org_id,
             pei.project_id AS project_id,
             top.task_id AS top_task_id,
             pei.task_id AS task_id,
             pei.inventory_item_id AS inventory_item_id,
             pet.expenditure_category AS expenditure_category,
             pei.expenditure_type AS expenditure_type,
             DECODE(pei.system_linkage_function,
                    'ST',
                    DECODE(pa_security.view_labor_costs(pei.project_id),
                           'Y',
                           pei.burden_cost,
                           NULL),
                    'OT',
                    DECODE(pa_security.view_labor_costs(pei.project_id),
                           'Y',
                           pei.burden_cost,
                           NULL),
                    pei.burden_cost) AS burden_cost,
             DECODE(pet.attribute_category,
                    'HEA_OU',
                    NVL(pet.attribute15, pei.expenditure_type),
                    pei.expenditure_type) AS report_exp_type,
             get_po_number(pei.transaction_source,
                           pei.document_header_id,
                           pei.orig_transaction_reference,
                           pei.expenditure_item_id) po_number

        FROM pa_expenditure_items pei,
             pa_expenditure_types pet,
             pa_tasks             pt,
             pa_proj_elements     ppe,
             pa_task_types        ptt,
             pa_tasks             top,
             pa_projects_all      pa

       WHERE pei.expenditure_type = pet.expenditure_type
         AND pei.task_id = pt.task_id
         AND pt.task_id = ppe.proj_element_id
         AND ppe.type_id = ptt.task_type_id
         AND ptt.task_type = l_task_type
         AND pt.top_task_id = top.task_id
         AND pei.project_id = pa.project_id
         AND (p_accrual_type = g_accrual_balance AND
             pet.attribute14 IN (g_accrual_taken, g_accrual_offset) OR
             pet.attribute14 = p_accrual_type)
         AND (p_accrual_type = g_accrual_balance AND
             pei.expenditure_item_date <= l_end_date OR
             pei.expenditure_item_date >= l_start_date AND
             pei.expenditure_item_date <= l_end_date)
         AND pa.project_id = NVL(p_project_id, pa.project_id)
         AND top.task_id = NVL(p_top_task_id, top.task_id);

  END;

  PROCEDURE main(x_errbuf       OUT VARCHAR2,
                 x_retcode      OUT VARCHAR2,
                 p_period       IN VARCHAR2,
                 p_project_id   IN NUMBER,
                 p_top_task_id  IN NUMBER,
                 p_type         IN VARCHAR2,
                 p_accrual_type IN VARCHAR2) IS
    CURSOR lines_c IS
      SELECT DISTINCT m.top_task_id   AS top_task_id,
                      m.project_id    AS project_id,
                      top.task_number AS mfg_number,
                      pa.segment1     AS project_number,
                      pa.long_name    AS project_name

        FROM xxpa_proj_exp_items_tmp m, pa_tasks top, pa_projects_all pa
       WHERE m.top_task_id = top.task_id
         AND m.project_id = pa.project_id;

    CURSOR lines_hbs IS
      SELECT m.top_task_id   AS top_task_id,
             m.project_id    AS project_id,
             top.task_number AS mfg_number,
             pa.segment1     AS project_number,
             pa.long_name    AS project_name,
             m.po_number

        FROM xxpa.xxpa_proj_exp_items_tmp3 m,
             pa_tasks                      top,
             pa_projects_all               pa
       WHERE m.top_task_id = top.task_id
         AND m.project_id = pa.project_id
       GROUP BY m.top_task_id,
                m.project_id,
                top.task_number,
                pa.segment1,
                pa.long_name,
                m.po_number;

    l_seqnum   NUMBER;
    l_title    VARCHAR2(240);
    l_org_name varchar2(240) := fnd_global.ORG_NAME;
  BEGIN

    log('p_period:       ' || p_period);
    log('p_project_id:   ' || p_project_id);
    log('p_top_task_id:  ' || p_top_task_id);
    log('p_type:         ' || p_type);
    log('p_accrual_type: ' || p_accrual_type);
    if l_org_name like '%HBS%' THEN
      generate_report_data_hbs(p_period,
                               p_project_id,
                               p_top_task_id,
                               p_type,
                               p_accrual_type);

      IF p_accrual_type = g_accrual_actual THEN
        l_title := p_type || ' COST INCURRED FOR THE MONTH OF';
      ELSIF p_accrual_type IN
            (g_accrual_offset, g_accrual_taken, g_accrual_balance) THEN
        l_title := p_type || ' TOTAL ACCRUAL ' || upper(p_accrual_type) ||
                   ' FOR THE MONTH OF';
      ELSIF p_accrual_type = g_accrual_transfer THEN
        l_title := p_type || ' Transfer FOR THE MONTH OF';
      END IF;

      l_title := xxpa_reports_utils.get_title(l_title, p_period);

      output_head_hbs(l_title, p_accrual_type, p_type);

      l_seqnum := 0;

      FOR one_line IN lines_hbs LOOP
        LOG('===================');
        LOG(one_line.po_number);
        l_seqnum := l_seqnum + 1;
        output_body_hbs(one_line.project_id,
                        one_line.top_task_id,
                        l_seqnum,
                        one_line.mfg_number,
                        one_line.project_number,
                        one_line.project_name,
                        p_period,
                        p_accrual_type,
                        p_type,
                        one_line.po_number);

      END LOOP;

      -- Grand Total
      IF l_seqnum > 0 THEN
        output('<tr>');
        output_value(g_space);
        output_value(g_space);
        output_value(g_space);
        output_value(g_space);
        IF p_accrual_type = g_accrual_actual AND p_type = 'ER' THEN
          output_value(g_space);
        END IF;
        output_value(g_space);
        output_value2('Grand Total');
        FOR i IN 1 .. g_grand_tab.count LOOP
          output_amount(g_grand_tab(i));
        END LOOP;
        output_amount(g_sum_total_cost);
        output('</tr>');
      END IF;
    else

      generate_report_data(p_period,
                           p_project_id,
                           p_top_task_id,
                           p_type,
                           p_accrual_type);

      IF p_accrual_type = g_accrual_actual THEN
        l_title := p_type || ' COST INCURRED FOR THE MONTH OF';
      ELSIF p_accrual_type IN
            (g_accrual_offset, g_accrual_taken, g_accrual_balance) THEN
        l_title := p_type || ' TOTAL ACCRUAL ' || upper(p_accrual_type) ||
                   ' FOR THE MONTH OF';
      ELSIF p_accrual_type = g_accrual_transfer THEN
        l_title := p_type || ' Transfer FOR THE MONTH OF';
      END IF;

      l_title := xxpa_reports_utils.get_title(l_title, p_period);

      output_head(l_title, p_accrual_type, p_type);

      l_seqnum := 0;
      FOR one_line IN lines_c LOOP

        l_seqnum := l_seqnum + 1;
        output_body(one_line.project_id,
                    one_line.top_task_id,
                    l_seqnum,
                    one_line.mfg_number,
                    one_line.project_number,
                    one_line.project_name,
                    p_period,
                    p_accrual_type,
                    p_type);

      END LOOP;

      -- Grand Total
      IF l_seqnum > 0 THEN
        output('<tr>');
        output_value(g_space);
        output_value(g_space);
        output_value(g_space);
        output_value(g_space);
        IF p_accrual_type = g_accrual_actual AND p_type = 'ER' THEN
          output_value(g_space);
        END IF;
        output_value2('Grand Total');
        FOR i IN 1 .. g_grand_tab.count LOOP
          output_amount(g_grand_tab(i));
        END LOOP;
        output_amount(g_sum_total_cost);
        output('</tr>');
      END IF;
    end if;
    output_end;

  END;

END;
/
