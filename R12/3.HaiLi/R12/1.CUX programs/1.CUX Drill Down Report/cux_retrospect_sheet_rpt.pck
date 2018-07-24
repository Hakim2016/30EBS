CREATE OR REPLACE PACKAGE cux_retrospect_sheet_rpt IS

  -- ==============================================
  -- Copyright (C) Hand Enterprise Solutions Co.,Ltd.
  --                   AllRights Reserved
  -- ===============================================

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ������������Դ
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/

  FUNCTION get_txn_source(p_transaction_id IN NUMBER) RETURN VARCHAR2;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿���Ʊ�������տ�����տ��š��տ�����
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_receipt_details(p_receipt_id      IN NUMBER,
                                x_receipt_num     OUT VARCHAR2,
                                x_receipt_date    OUT DATE,
                                x_receipt_method  OUT VARCHAR2,
                                x_receipt_comment OUT VARCHAR2);

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ������֯��ȡ��Ӧ������
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  FUNCTION get_set_of_books_id(p_org_id IN NUMBER) RETURN NUMBER;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿��·�Ʊ���������Ϳͻ����ͻ��ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_rcp_trans_vendor(p_cust_trx_id    IN NUMBER,
                                 x_cust_name      OUT VARCHAR2,
                                 x_cust_site_code OUT VARCHAR2,
                                 x_cust_number    OUT VARCHAR2);

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿���Ʊ�����Ϳͻ����ͻ��ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_receipt_vendor(p_receipt_id     IN NUMBER,
                               x_cust_name      OUT VARCHAR2,
                               x_cust_site_code OUT VARCHAR2,
                               x_cust_number    OUT VARCHAR2);

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡ��λ
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  FUNCTION get_locator(p_locator_id      IN NUMBER,
                       p_organization_id IN NUMBER) RETURN VARCHAR2;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡ����
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  FUNCTION get_depart_code(p_dept_id IN NUMBER) RETURN VARCHAR2;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡ���Ϻ�����˵��
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_item_detail(p_item_id         IN NUMBER,
                            p_organization_id IN NUMBER,
                            x_item_code       OUT VARCHAR2,
                            x_item_desc       OUT VARCHAR2);

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿��¸������͹�Ӧ�̡���Ӧ�̵ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_pay_vendor(p_check_id         IN NUMBER,
                           x_vendor_name      OUT VARCHAR2,
                           x_vendor_site_code OUT VARCHAR2);

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿��²ɹ���Ʊ���͹�Ӧ�̡���Ӧ�̵ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_purching_vendor(p_invoice_id       IN NUMBER,
                                x_vendor_name      OUT VARCHAR2,
                                x_vendor_site_code OUT VARCHAR2);

  PROCEDURE main(errbuf  OUT VARCHAR2,
                 retcode OUT VARCHAR2,
                 --
                 p_org_id      IN NUMBER, --org_id
                 p_report_type IN VARCHAR2, -- ��������
                 p_period_f    IN VARCHAR2, --�ڼ��
                 p_period_t    IN VARCHAR2, --�ڼ���
                 p_gl_date_f   IN VARCHAR2, --GL���ڴ�
                 p_gl_date_t   IN VARCHAR2, --GL������
                 p_account_f   IN NUMBER, --VARCHAR2, --�˻���
                 p_account_t   IN NUMBER, --VARCHAR2, --�˻���
                 p_batch_num   IN VARCHAR2 --�ռ�������
                 );
END cux_retrospect_sheet_rpt;
/
CREATE OR REPLACE PACKAGE BODY cux_retrospect_sheet_rpt IS

  -- ==============================================
  -- Copyright (C) Hand Enterprise Solutions Co.,Ltd.
  --                   AllRights Reserved
  -- ===============================================
  -- ==============================================
  -- System         : Oracle Application Add_on Development
  -- Module         : PACKAGE
  -- Package Name   : cux_retrospect_sheet_rpt
  -- Description    : �ռ���׷�ݶ�sheetҳ����
  -- Language       : PL/SQL
  -- Version        : 1.0.0
  -- Change History : 2018/04/20 xu.wei
  -- ===============================================
  g_pkg_name VARCHAR2(30) := 'cux_retrospect_sheet_rpt';

  PROCEDURE log(p_log IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log,
                      p_log);
  END log;

  PROCEDURE raise_exception(p_return_status VARCHAR2) IS
  BEGIN
    IF p_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF p_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END raise_exception;

  PROCEDURE output(p_msg IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output,
                      p_msg);
    dbms_output.put_line(p_msg);
  END output;

  PROCEDURE output_parameter(p_prompt VARCHAR2,
                             p_value  VARCHAR2) IS
  BEGIN
    output(cux_fnd_xml_utl.get_tag_start('parameter'));
    output(cux_fnd_xml_utl.get_tag('prompt',
                                   p_prompt));
    output(cux_fnd_xml_utl.get_tag('value',
                                   p_value));
    output(cux_fnd_xml_utl.get_tag_end);
  END;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡ����
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  FUNCTION get_depart_code(p_dept_id IN NUMBER) RETURN VARCHAR2 IS
  
    l_dept_code VARCHAR2(240);
  BEGIN
    SELECT bd.department_code
      INTO l_dept_code
      FROM bom_departments bd
     WHERE 1 = 1
           AND bd.department_id = p_dept_id;
    RETURN l_dept_code;
  EXCEPTION
    WHEN OTHERS THEN
      l_dept_code := NULL;
      RETURN l_dept_code;
    
  END get_depart_code;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡ��λ
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  FUNCTION get_locator(p_locator_id      IN NUMBER,
                       p_organization_id IN NUMBER) RETURN VARCHAR2 IS
  
    l_locator_name VARCHAR2(240);
  BEGIN
  
    SELECT mil.segment1
      INTO l_locator_name
      FROM mtl_item_locations mil
     WHERE mil.inventory_location_id = p_locator_id
           AND mil.organization_id = p_organization_id;
    RETURN l_locator_name;
  EXCEPTION
    WHEN OTHERS THEN
      l_locator_name := NULL;
      RETURN l_locator_name;
    
  END get_locator;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡ���Ϻ�����˵��
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_item_detail(p_item_id         IN NUMBER,
                            p_organization_id IN NUMBER,
                            x_item_code       OUT VARCHAR2,
                            x_item_desc       OUT VARCHAR2) IS
  
  BEGIN
    SELECT msi.segment1,
           msi.description
      INTO x_item_code,
           x_item_desc
      FROM mtl_system_items_b msi
     WHERE 1 = 1
           AND msi.inventory_item_id = p_item_id
           AND msi.organization_id = p_organization_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_item_code := NULL;
      x_item_desc := NULL;
    
  END get_item_detail;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ����OU��ȡ��Ӧ������
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  FUNCTION get_set_of_books_id(p_org_id IN NUMBER) RETURN NUMBER IS
  
    l_set_of_books_id NUMBER := NULL;
  BEGIN
    SELECT hou.set_of_books_id
      INTO l_set_of_books_id
      FROM hr_operating_units hou
     WHERE 1 = 1
           AND hou.organization_id = p_org_id;
    RETURN l_set_of_books_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_set_of_books_id := NULL;
      RETURN l_set_of_books_id;
    
  END get_set_of_books_id;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿��·�Ʊ���������Ϳͻ����ͻ��ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_rcp_trans_vendor(p_cust_trx_id    IN NUMBER,
                                 x_cust_name      OUT VARCHAR2,
                                 x_cust_site_code OUT VARCHAR2,
                                 x_cust_number    OUT VARCHAR2) IS
  
  BEGIN
    SELECT hp.party_name,
           rct.bill_to_site_use_id,
           hca.account_number
      INTO x_cust_name,
           x_cust_site_code,
           x_cust_number
      FROM ra_customer_trx_all   rct,
           hz_cust_accounts      hca,
           hz_parties            hp,
           hz_cust_site_uses_all hcs
     WHERE 1 = 1
           AND rct.bill_to_customer_id = hca.cust_account_id(+)
           AND hca.party_id = hp.party_id(+)
           AND rct.bill_to_site_use_id = hcs.site_use_id(+)
           AND rct.org_id = hcs.org_id(+)
           AND rct.customer_trx_id = p_cust_trx_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_cust_name      := NULL;
      x_cust_site_code := NULL;
      x_cust_number    := NULL;
    
  END get_rcp_trans_vendor;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿���Ʊ�������տ�����տ��š��տ�����
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_receipt_details(p_receipt_id      IN NUMBER,
                                x_receipt_num     OUT VARCHAR2,
                                x_receipt_date    OUT DATE,
                                x_receipt_method  OUT VARCHAR2,
                                x_receipt_comment OUT VARCHAR2) IS
  
  BEGIN
    SELECT acr.receipt_number,
           acr.receipt_date,
           arm.name,
           acr.comments
      INTO x_receipt_num,
           x_receipt_date,
           x_receipt_method,
           x_receipt_comment
      FROM ar_cash_receipts_all acr,
           ar_receipt_methods   arm
     WHERE 1 = 1
           AND acr.receipt_method_id = arm.receipt_method_id
           AND acr.cash_receipt_id = p_receipt_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_receipt_num     := NULL;
      x_receipt_date    := NULL;
      x_receipt_method  := NULL;
      x_receipt_comment := NULL;
  END get_receipt_details;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿���Ʊ�����Ϳͻ����ͻ��ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_receipt_vendor(p_receipt_id     IN NUMBER,
                               x_cust_name      OUT VARCHAR2,
                               x_cust_site_code OUT VARCHAR2,
                               x_cust_number    OUT VARCHAR2) IS
  
  BEGIN
    SELECT party.party_name,
           site_uses.location,
           party.party_number
      INTO x_cust_name,
           x_cust_site_code,
           x_cust_number
      FROM ar_cash_receipts_all  acr,
           hz_cust_accounts      cust,
           hz_parties            party,
           hz_cust_site_uses_all site_uses
    
     WHERE acr.pay_from_customer = cust.cust_account_id(+)
           AND cust.party_id = party.party_id(+)
           AND acr.customer_site_use_id = site_uses.site_use_id(+)
           AND acr.org_id = site_uses.org_id(+)
           AND acr.cash_receipt_id = p_receipt_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_cust_name      := NULL;
      x_cust_site_code := NULL;
      x_cust_number    := NULL;
    
  END;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿��²ɹ���Ʊ���͹�Ӧ�̡���Ӧ�̵ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_purching_vendor(p_invoice_id       IN NUMBER,
                                x_vendor_name      OUT VARCHAR2,
                                x_vendor_site_code OUT VARCHAR2) IS
  
  BEGIN
    SELECT pv.vendor_name,
           pvs.vendor_site_code
      INTO x_vendor_name,
           x_vendor_site_code
      FROM ap_invoices_all     aia,
           po_vendors          pv,
           po_vendor_sites_all pvs
     WHERE 1 = 1
           AND aia.vendor_id = pv.vendor_id
           AND aia.vendor_site_id = pvs.vendor_site_id
           AND aia.invoice_id = p_invoice_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_vendor_name      := NULL;
      x_vendor_site_code := NULL;
    
  END;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ��ȡӦ���˿��¸������͹�Ӧ�̡���Ӧ�̵ص�
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_pay_vendor(p_check_id         IN NUMBER,
                           x_vendor_name      OUT VARCHAR2,
                           x_vendor_site_code OUT VARCHAR2) IS
  
  BEGIN
    SELECT aca.vendor_name,
           aca.vendor_site_code
      INTO x_vendor_name,
           x_vendor_site_code
      FROM ap_checks_all aca
     WHERE 1 = 1
           AND aca.check_id = p_check_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_vendor_name      := NULL;
      x_vendor_site_code := NULL;
    
  END get_pay_vendor;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       ������������Դ
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/

  FUNCTION get_txn_source(p_transaction_id IN NUMBER) RETURN VARCHAR2 IS
    g_debug_mode VARCHAR2(120) := 'Y';
    po                  CONSTANT NUMBER := 1;
    sales_order         CONSTANT NUMBER := 2;
    account             CONSTANT NUMBER := 3;
    move_order          CONSTANT NUMBER := 4;
    wip_job_or_schedule CONSTANT NUMBER := 5;
    account_alias       CONSTANT NUMBER := 6;
    requisition         CONSTANT NUMBER := 7;
    internal_order      CONSTANT NUMBER := 8;
    cycle_count         CONSTANT NUMBER := 9;
    physical_inventory  CONSTANT NUMBER := 10;
    cost_update         CONSTANT NUMBER := 11;
    rma                 CONSTANT NUMBER := 12;
    inventory           CONSTANT NUMBER := 13;
    --Layer_cost_update CONSTANT NUMBER := 15;
    prjcontracts CONSTANT NUMBER := 16;
    v_process_phase      VARCHAR2(30);
    n_organization_id    NUMBER;
    n_txn_source_type_id NUMBER;
    n_txn_source_id      NUMBER;
    v_txn_source_name    mtl_material_transactions.transaction_source_name%TYPE;
    x_txn_source         VARCHAR2(120);
  BEGIN
    v_process_phase := 'Fetch txn infomation';
    -- get transaction information
    SELECT mmt.organization_id,
           mmt.transaction_source_type_id,
           mmt.transaction_source_id,
           mmt.transaction_source_name
      INTO n_organization_id,
           n_txn_source_type_id,
           n_txn_source_id,
           v_txn_source_name
      FROM mtl_material_transactions mmt
     WHERE mmt.transaction_id = p_transaction_id;
    IF n_txn_source_type_id = cost_update THEN
      v_process_phase := 'Cost Update';
      SELECT description
        INTO x_txn_source
        FROM cst_cost_updates
       WHERE cost_update_id = n_txn_source_id;
    ELSIF n_txn_source_type_id = cycle_count THEN
      v_process_phase := 'Cycle Count';
      SELECT cycle_count_header_name
        INTO x_txn_source
        FROM mtl_cycle_count_headers
       WHERE cycle_count_header_id = n_txn_source_id
             AND organization_id = n_organization_id;
    ELSIF (n_txn_source_type_id = inventory OR n_txn_source_type_id >= 100) THEN
      v_process_phase := 'Inventory';
      x_txn_source    := v_txn_source_name;
    ELSIF n_txn_source_type_id = physical_inventory THEN
      v_process_phase := 'Physical Inventory';
      SELECT physical_inventory_name
        INTO x_txn_source
        FROM mtl_physical_inventories
       WHERE physical_inventory_id = n_txn_source_id
             AND organization_id = n_organization_id;
    ELSIF n_txn_source_type_id = po THEN
      v_process_phase := 'PO';
      SELECT nvl(poh.segment1,
                 poh.segment1)
        INTO x_txn_source
        FROM po_headers_all poh
       WHERE poh.po_header_id = n_txn_source_id;
    ELSIF n_txn_source_type_id = prjcontracts THEN
      v_process_phase := 'PrjContracts';
      SELECT contract_number
        INTO x_txn_source
        FROM okc_k_headers_b
       WHERE id = n_txn_source_id;
    ELSIF n_txn_source_type_id = requisition THEN
      v_process_phase := 'Requisition';
      SELECT segment1
        INTO x_txn_source
        FROM po_requisition_headers_all
       WHERE requisition_header_id = n_txn_source_id;
    ELSIF n_txn_source_type_id = wip_job_or_schedule THEN
      v_process_phase := 'WIP Job or Schedule';
      SELECT wip_entity_name
        INTO x_txn_source
        FROM wip_entities
       WHERE wip_entity_id = n_txn_source_id
             AND organization_id = n_organization_id;
    ELSIF n_txn_source_type_id = move_order THEN
      v_process_phase := 'Move Order';
      SELECT request_number
        INTO x_txn_source
        FROM mtl_txn_request_headers
       WHERE header_id = n_txn_source_id
             AND organization_id = n_organization_id;
    ELSIF ((n_txn_source_type_id = sales_order) OR
          (n_txn_source_type_id = internal_order) OR
          (n_txn_source_type_id = rma)) THEN
      v_process_phase := 'Sales Order';
      SELECT concatenated_segments
        INTO x_txn_source
        FROM mtl_sales_orders_kfv
       WHERE sales_order_id = n_txn_source_id;
    ELSIF n_txn_source_type_id = account_alias THEN
      v_process_phase := 'Account Alias';
      SELECT concatenated_segments
        INTO x_txn_source
        FROM mtl_generic_dispositions_kfv
       WHERE disposition_id = n_txn_source_id;
    ELSIF n_txn_source_type_id = account THEN
      v_process_phase := 'Account';
      SELECT concatenated_segments
        INTO x_txn_source
        FROM gl_code_combinations_kfv
       WHERE code_combination_id = n_txn_source_id;
    ELSE
      v_process_phase := 'Others';
      x_txn_source    := NULL;
    END IF;
    RETURN x_txn_source;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      IF g_debug_mode = 'Y' THEN
        dbms_output.put_line('GET_TXN_SOURCE: ' || SQLERRM);
        dbms_output.put_line('Process phase : ' || v_process_phase);
      END IF;
      RETURN NULL;
  END;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       process_request_xml
  *   DESCRIPTION: 
  *       ��ȡmtl������Ϣ
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_mtl_dist_detail(p_transaction_id IN NUMBER,
                                p_ccid_mtl       IN NUMBER,
                                p_match_amount   IN NUMBER, --sla���ƥ������н��
                                x_gl_batch_mtl   OUT NUMBER,
                                x_revision_mtl   OUT VARCHAR2,
                                x_unit_cost_mtl  OUT NUMBER) IS
  
  BEGIN
    SELECT cidv.gl_batch_id gl_batch,
           cidv.revision,
           cidv.unit_cost
      INTO x_gl_batch_mtl,
           x_revision_mtl,
           x_unit_cost_mtl
    
      FROM cst_inv_distribution_v cidv
     WHERE cidv.transaction_id = p_transaction_id
           AND cidv.base_transaction_value = p_match_amount
           AND cidv.reference_account = p_ccid_mtl;
  EXCEPTION
    WHEN OTHERS THEN
      x_gl_batch_mtl  := NULL;
      x_revision_mtl  := NULL;
      x_unit_cost_mtl := NULL;
    
  END get_mtl_dist_detail;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       process_request_xml
  *   DESCRIPTION: 
  *       ��ȡmtl��Ϣ
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/
  PROCEDURE get_mtl_detail(p_transaction_type_id    IN NUMBER, --1����֯��ת�� 2������������
                           p_transaction_id         IN NUMBER,
                           x_transaction_flag_mtl   OUT NUMBER, --�������ʶ,
                           x_transaction_cate_mtl   OUT VARCHAR2, --����������,
                           x_transaction_date_mtl   OUT DATE, --����������,
                           x_trans_source_type_mtl  OUT VARCHAR2, --��������Դ����,
                           x_transaction_source_mtl OUT VARCHAR2, -- ��������Դ,
                           x_trans_reason_mtl       OUT VARCHAR2, --������ԭ��,
                           x_trans_reference_mtl    OUT VARCHAR2, --������ο�,
                           x_subinventory_code_mtl  OUT VARCHAR2, --�ӿ��,
                           x_primary_quantity_mtl   OUT NUMBER, --��Ҫ����
                           x_primary_uom_code_mtl   OUT VARCHAR2, --��Ҫ��λ
                           x_locator_mtl            OUT VARCHAR2, --��λ
                           x_department_mtl         OUT VARCHAR2, --����
                           x_item_code_mtl          OUT VARCHAR2, --����
                           x_item_desc_mtl          OUT VARCHAR2 --����˵��
                           ) IS
  
    l_locator_id        NUMBER;
    l_department_id     NUMBER;
    l_inventory_item_id NUMBER;
    l_organization_id   NUMBER;
  BEGIN
    --��֯��ת��
    IF p_transaction_type_id = 1 THEN
      BEGIN
        SELECT mmt.transfer_transaction_id transaction_flag, --�������ʶ,
               mtt.transaction_type_name transaction_cate, --����������,
               mmt.transaction_date, --����������,
               mtst.transaction_source_type_name trans_source_type, --��������Դ����,
               get_txn_source(mmt.transaction_id) transaction_source, -- ��������Դ,
               mtr.reason_name trans_reason, --������ԭ��,
               mmt.transaction_reference trans_reference, --������ο�,
               mmt.subinventory_code, --�ӿ��,
               mmt.primary_quantity, --��Ҫ����
               mmt.transaction_uom primary_uom_code, --��Ҫ��λ
               mmt.locator_id, --��λid,
               mmt.department_id,
               mmt.inventory_item_id,
               mmt.organization_id
          INTO x_transaction_flag_mtl,
               x_transaction_cate_mtl,
               x_transaction_date_mtl,
               x_trans_source_type_mtl,
               x_transaction_source_mtl,
               x_trans_reason_mtl,
               x_trans_reference_mtl,
               x_subinventory_code_mtl,
               x_primary_quantity_mtl,
               x_primary_uom_code_mtl,
               l_locator_id,
               l_department_id,
               l_inventory_item_id,
               l_organization_id
          FROM mtl_material_transactions mmt,
               mtl_transaction_types     mtt,
               mtl_txn_source_types      mtst,
               mtl_transaction_reasons   mtr
        
         WHERE 1 = 1
               AND mmt.transaction_type_id = mtt.transaction_type_id
               AND mmt.transaction_source_type_id =
               mtst.transaction_source_type_id
               AND mmt.reason_id = mtr.reason_id(+)
               AND mmt.transfer_transaction_id = p_transaction_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_transaction_flag_mtl   := NULL;
          x_transaction_cate_mtl   := NULL;
          x_transaction_date_mtl   := NULL;
          x_trans_source_type_mtl  := NULL;
          x_transaction_source_mtl := NULL;
          x_trans_reason_mtl       := NULL;
          x_trans_reference_mtl    := NULL;
          x_subinventory_code_mtl  := NULL;
          x_primary_quantity_mtl   := NULL;
          x_primary_uom_code_mtl   := NULL;
          l_locator_id             := NULL;
          l_department_id          := NULL;
          l_inventory_item_id      := NULL;
          l_organization_id        := NULL;
      END;
      --��ȡ��λ
      x_locator_mtl := get_locator(l_locator_id,
                                   l_organization_id);
    
      --��ȡ����
      x_department_mtl := get_depart_code(l_department_id);
      --��ȡ����/˵��
      get_item_detail(l_inventory_item_id,
                      l_organization_id,
                      x_item_code_mtl,
                      x_item_desc_mtl);
      --���� 
    ELSIF p_transaction_type_id = 2 THEN
      BEGIN
        SELECT mmt.transfer_transaction_id transaction_flag, --�������ʶ,
               mtt.transaction_type_name transaction_cate, --����������,
               mmt.transaction_date, --����������,
               mtst.transaction_source_type_name trans_source_type, --��������Դ����,
               get_txn_source(mmt.transaction_id) transaction_source, -- ��������Դ,
               mtr.reason_name trans_reason, --������ԭ��,
               mmt.transaction_reference trans_reference, --������ο�,
               mmt.subinventory_code, --�ӿ��,
               mmt.primary_quantity, --��Ҫ����
               mmt.transaction_uom primary_uom_code, --��Ҫ��λ
               mmt.locator_id, --��λid,
               mmt.department_id,
               mmt.inventory_item_id,
               mmt.organization_id
          INTO x_transaction_flag_mtl,
               x_transaction_cate_mtl,
               x_transaction_date_mtl,
               x_trans_source_type_mtl,
               x_transaction_source_mtl,
               x_trans_reason_mtl,
               x_trans_reference_mtl,
               x_subinventory_code_mtl,
               x_primary_quantity_mtl,
               x_primary_uom_code_mtl,
               l_locator_id,
               l_department_id,
               l_inventory_item_id,
               l_organization_id
          FROM mtl_material_transactions mmt,
               mtl_transaction_types     mtt,
               mtl_txn_source_types      mtst,
               mtl_transaction_reasons   mtr
        
         WHERE 1 = 1
               AND mmt.transaction_type_id = mtt.transaction_type_id
               AND mmt.transaction_source_type_id =
               mtst.transaction_source_type_id
               AND mmt.reason_id = mtr.reason_id(+)
               AND mmt.transaction_id = p_transaction_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_transaction_flag_mtl   := NULL;
          x_transaction_cate_mtl   := NULL;
          x_transaction_date_mtl   := NULL;
          x_trans_source_type_mtl  := NULL;
          x_transaction_source_mtl := NULL;
          x_trans_reason_mtl       := NULL;
          x_trans_reference_mtl    := NULL;
          x_subinventory_code_mtl  := NULL;
          x_primary_quantity_mtl   := NULL;
          x_primary_uom_code_mtl   := NULL;
          l_locator_id             := NULL;
          l_department_id          := NULL;
          l_inventory_item_id      := NULL;
          l_organization_id        := NULL;
      END;
      --��ȡ��λ
      x_locator_mtl := get_locator(l_locator_id,
                                   l_organization_id);
    
      --��ȡ����
      x_department_mtl := get_depart_code(l_department_id);
      --��ȡ����/˵��
      get_item_detail(l_inventory_item_id,
                      l_organization_id,
                      x_item_code_mtl,
                      x_item_desc_mtl);
    END IF;
  
  END get_mtl_detail;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       process_request_xml
  *   DESCRIPTION: 
  *       ����xml
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/

  PROCEDURE process_request_xml(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2,
                                --
                                p_set_of_books_id IN NUMBER, --����
                                p_report_type     IN VARCHAR2, -- ��������
                                p_period_f        IN VARCHAR2, --�ڼ��
                                p_period_t        IN VARCHAR2, --�ڼ���
                                p_gl_date_f       IN DATE, --GL���ڴ�
                                p_gl_date_t       IN DATE, --GL������
                                p_account_f       IN NUMBER, --VARCHAR2, --�˻���
                                p_account_t       IN NUMBER, --VARCHAR2, --�˻���
                                p_batch_num       IN VARCHAR2 --�ռ�������
                                ) IS
  
    l_api_name CONSTANT VARCHAR2(30) := 'process_request';
    g_farmat VARCHAR2(240) := 'yyyy/mm/dd hh24:mi:ss';
  
    l_vendor_name      VARCHAR2(240);
    l_vendor_site_code VARCHAR2(240);
    l_cust_name        VARCHAR2(240);
    l_cust_site_code   VARCHAR2(240);
    l_cust_number      VARCHAR2(240);
    l_item_code        VARCHAR2(240);
    l_item_desc        VARCHAR2(240);
    l_locator          VARCHAR2(240);
    l_dept_code        VARCHAR2(240);
    l_primary_code     VARCHAR2(240);
    l_primary_desc     VARCHAR2(240);
    l_receipt_num      VARCHAR2(240);
    l_receipt_date     DATE;
    l_receipt_method   VARCHAR2(240);
    l_receipt_comment  VARCHAR2(240);
    g_charset          VARCHAR2(100) := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
    --
    l_transaction_flag_mtl   VARCHAR2(240);
    l_transaction_cate_mtl   VARCHAR2(240); --����������,
    l_transaction_date_mtl   DATE; --����������,
    l_trans_source_type_mtl  VARCHAR2(240); --��������Դ����,
    l_transaction_source_mtl VARCHAR2(240); -- ��������Դ,
    l_trans_reason_mtl       VARCHAR2(240); --������ԭ��,
    l_trans_reference_mtl    VARCHAR2(240); --������ο�,
    l_subinventory_code_mtl  VARCHAR2(240); --�ӿ��,
    l_primary_quantity       NUMBER; --��Ҫ����
    l_primary_uom_code_mtl   VARCHAR2(240); --��Ҫ��λ
    l_locator_mtl            VARCHAR2(240); --��λ
    l_department_mtl         VARCHAR2(240); --����
    l_item_code_mtl          VARCHAR2(240); --����
    l_item_desc_mtl          VARCHAR2(240);
    l_gl_batch_mtl           NUMBER;
    l_revision_mtl           VARCHAR2(240);
    l_unit_cost_mtl          NUMBER;
    --����sla���ƥ������н��
    l_match_amount NUMBER;
  
    --=================AP׷��SQL==========================
    CURSOR cur_ap_data IS
      SELECT DISTINCT xal.ae_header_id xal_header_id,
                      xal.ae_line_num xal_line_id,
                      (xal.ae_header_id || '-' || xal.ae_line_num) sla_flag, --sla��ʶ
                      gjh.period_name, --     �ڼ�,
                      gjs.user_je_source_name, --  ��Դ,
                      gjc.user_je_category_name, --���,
                      xentity_t.entity_code,
                      xentity_t.name entity_cate_name, --  ����ʵ����������,
                      gjb.name je_batch_name, --  �ռ�������,
                      gjh.name je_name, --      �ռ�����,
                      gjl.je_line_num je_line_num, --      �ռ����к�,
                      --��׷��
                      xte.transaction_number transcation_num, --��������,
                      xe.event_date event_date, --�¼�����
                      xah.accounting_date gl_date, --gl����,
                      xgl.name cate_name, --������, --������
                      fnd_flex_ext.get_segs('SQLGL',
                                            'GL#',
                                            xgl.chart_of_accounts_id,
                                            xal.code_combination_id) account, --  --�˻�, --�˻�
                      xla_oa_functions_pkg.get_ccid_description(xgl.chart_of_accounts_id,
                                                                xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                      nvl(xlp.meaning,
                          xal.accounting_class_code) acc_class, --��Ʒ���, --��Ʒ���
                      --��׷��
                      xal.accounted_dr in_borrow, -- ���ʽ���, --���ʽ���
                      xal.accounted_cr in_credit, --���ʴ���, --���ʴ���
                      xal.currency_code in_currend, -- �������, --�������
                      xal.entered_dr out_borrow, -- �������, --�������
                      xal.entered_cr out_credit, --�������, --�������
                      (nvl(xal.accounted_dr,
                           0) - nvl(xal.accounted_cr,
                                     0)) in_net_amount, --���˾���
                      xal.ae_line_num, --�к�
                      xal.description line_desc, --��˵��, --��˵��
                      gjh.name je_cate_name, -- �ռ��ʷ�¼��, --�ռ��ʷ�¼��
                      ------------------------------      
                      --AP_INVOICES  AP��Ʊ     INVOICE_ID                   \
                      --AP_PAYMENTS  AP����     CHECK_ID                      \
                      --RECEIPTS     �տ�       CASH_RECEIPT_ID                �����������Ĵ����������ֱ� ��Դ��ID
                      --TRANSACTIONS ������  ���۷�Ʊ CUSTOMER_TRX_ID       /
                      xte.source_id_int_1 trans_source_id -- ����Դ��Ӧid
      ------------------------------
      
        FROM gl_je_batches    gjb,
             gl_je_headers    gjh,
             gl_je_lines      gjl,
             gl_je_sources_vl gjs,
             gl_je_categories gjc,
             --��׷��
             gl_import_references gir,
             --
             xla_ae_lines     xal,
             xla_lookups      xlp,
             xla_ae_headers   xah,
             xla_gl_ledgers_v xgl,
             --
             xla_events                   xe,
             xla.xla_transaction_entities xte,
             xla_entity_types_tl          xentity_t
      
       WHERE 1 = 1
             AND gjb.je_batch_id = gjh.je_batch_id
             AND gjh.je_header_id = gjl.je_header_id
             AND gjh.je_source = gjs.je_source_name
             AND gjc.je_category_name = gjh.je_category
            --��׷��
             AND gir.je_header_id = gjh.je_header_id
             AND gir.je_line_num = gjl.je_line_num
            --
             AND xal.gl_sl_link_id = gir.gl_sl_link_id
             AND xal.gl_sl_link_table = gir.gl_sl_link_table
             AND xlp.lookup_code(+) = xal.accounting_class_code
             AND xlp.lookup_type(+) = 'XLA_ACCOUNTING_CLASS'
            --
             AND xah.ae_header_id = xal.ae_header_id
             AND xah.application_id = xal.application_id
            --
             AND xgl.ledger_id = xah.ledger_id
            --
             AND xe.event_id = xah.event_id
             AND xe.application_id = xah.application_id
            --
             AND xte.entity_id = xe.entity_id
             AND xte.application_id = xe.application_id
            --
             AND xentity_t.entity_code = xte.entity_code
             AND xentity_t.application_id = xte.application_id
             AND xentity_t.language = userenv('LANG')
            
            --����
             AND gjh.je_source = 'Payables' --���������ԣ�ֱ��ȡcode
             AND gjh.period_name BETWEEN
             nvl(p_period_f,
                     gjh.period_name) AND
             nvl(p_period_t,
                 gjh.period_name)
             AND xah.accounting_date BETWEEN
             nvl(p_gl_date_f,
                     xah.accounting_date) AND
             nvl(p_gl_date_t,
                 xah.accounting_date)
            --
             AND xal.code_combination_id BETWEEN
             nvl(p_account_f,
                     xal.code_combination_id) AND
             nvl(p_account_t,
                 xal.code_combination_id)
            --
            
             AND gjb.name = nvl(p_batch_num,
                                gjb.name)
            --
            
             AND gjh.ledger_id = p_set_of_books_id --����
      
       ORDER BY xte.transaction_number,
                xal.accounted_dr,
                xal.accounted_cr;
  
    --=======================================================
    --===================AR׷��SQL===========================
    CURSOR cur_ar_data IS
    --AR׷��
      SELECT DISTINCT xal.ae_header_id xal_header_id,
                      xal.ae_line_num xal_line_id,
                      (xal.ae_header_id || '-' || xal.ae_line_num) sla_flag, --sla��ʶ
                      gjh.period_name, -- �ڼ�,
                      gjs.user_je_source_name, --��Դ,
                      gjc.user_je_category_name, --���,
                      xentity_t.entity_code,
                      xentity_t.name entity_cate_name, -- ����ʵ����������,
                      gjb.name je_batch_name, --   �ռ�������, --��
                      gjh.name je_name, --   �ռ�����, --�ռ��˷�¼
                      gjl.je_line_num je_line_num, --   �ռ����к�,
                      --��׷��
                      xte.transaction_number transcation_num, --��������,
                      xe.event_date event_date, --�¼�����, --�¼�����
                      xah.accounting_date gl_date, --gl����,
                      xgl.name cate_name, --������, --������
                      fnd_flex_ext.get_segs('SQLGL',
                                            'GL#',
                                            xgl.chart_of_accounts_id,
                                            xal.code_combination_id) account, --�˻�, --�˻�
                      xla_oa_functions_pkg.get_ccid_description(xgl.chart_of_accounts_id,
                                                                xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                      nvl(xlp.meaning,
                          xal.accounting_class_code) acc_class, --��Ʒ���, --��Ʒ���
                      --��׷��
                      xal.accounted_dr in_borrow, -- ���ʽ���, --���ʽ���
                      xal.accounted_cr in_credit, --���ʴ���, --���ʴ���
                      xal.currency_code in_currend, --�������, --�������
                      xal.entered_dr out_borrow, --�������, --�������
                      xal.entered_cr out_credit, --�������, --�������
                      xal.description line_desc, --��˵��, --��˵��
                      gjh.name je_cate_name, --�ռ��ʷ�¼��, --�ռ��ʷ�¼��
                      (nvl(xal.accounted_dr,
                           0) - nvl(xal.accounted_cr,
                                     0)) in_net_amount, --���˾���
                      ------------------------------      
                      --AP_INVOICES  AP��Ʊ     INVOICE_ID                   \
                      --AP_PAYMENTS  AP����     CHECK_ID                      \
                      --RECEIPTS     �տ�       CASH_RECEIPT_ID                �����������Ĵ����������ֱ� ��Դ��ID
                      --TRANSACTIONS ������  ���۷�Ʊ CUSTOMER_TRX_ID       /
                      xte.source_id_int_1 trans_source_id --����Դ��Ӧid
      ------------------------------
      
        FROM gl_je_batches    gjb,
             gl_je_headers    gjh,
             gl_je_lines      gjl,
             gl_je_sources_vl gjs,
             gl_je_categories gjc,
             --��׷��
             gl_import_references gir,
             --
             xla_ae_lines     xal,
             xla_lookups      xlp,
             xla_ae_headers   xah,
             xla_gl_ledgers_v xgl,
             --
             xla_events                   xe,
             xla.xla_transaction_entities xte,
             xla_entity_types_tl          xentity_t
      
       WHERE 1 = 1
             AND gjb.je_batch_id = gjh.je_batch_id
             AND gjh.je_header_id = gjl.je_header_id
             AND gjh.je_source = gjs.je_source_name
             AND gjc.je_category_name = gjh.je_category
            --��׷��
             AND gir.je_header_id = gjh.je_header_id
             AND gir.je_line_num = gjl.je_line_num
            --
             AND xal.gl_sl_link_id = gir.gl_sl_link_id
             AND xal.gl_sl_link_table = gir.gl_sl_link_table
             AND xlp.lookup_code(+) = xal.accounting_class_code
             AND xlp.lookup_type(+) = 'XLA_ACCOUNTING_CLASS'
            --
             AND xah.ae_header_id = xal.ae_header_id
             AND xah.application_id = xal.application_id
            --
             AND xgl.ledger_id = xah.ledger_id
            --
             AND xe.event_id = xah.event_id
             AND xe.application_id = xah.application_id
            --
             AND xte.entity_id = xe.entity_id
             AND xte.application_id = xe.application_id
            --
             AND xentity_t.entity_code = xte.entity_code
             AND xentity_t.application_id = xte.application_id
             AND xentity_t.language = userenv('LANG')
            
            --����
             AND gjh.je_source = 'Receivables' --���������ԣ�ֱ��ȡcode
             AND gjh.period_name BETWEEN
             nvl(p_period_f,
                     gjh.period_name) AND
             nvl(p_period_t,
                 gjh.period_name)
             AND xah.accounting_date BETWEEN
             nvl(p_gl_date_f,
                     xah.accounting_date) AND
             nvl(p_gl_date_t,
                 xah.accounting_date)
            --
             AND xal.code_combination_id BETWEEN
             nvl(p_account_f,
                     xal.code_combination_id) AND
             nvl(p_account_t,
                 xal.code_combination_id)
            --
            
             AND gjb.name = nvl(p_batch_num,
                                gjb.name)
            
             AND gjh.ledger_id = p_set_of_books_id --����
      
       ORDER BY xte.transaction_number,
                xal.accounted_dr,
                xal.accounted_cr;
  
    --========================================================
    --===================WIP׷��SQL===========================
    CURSOR cur_wip_data IS
      SELECT DISTINCT xal.ae_header_id xal_header_id,
                      xal.ae_line_num xal_line_id,
                      xal.code_combination_id,
                      (xal.ae_header_id || '-' || xal.ae_line_num) sla_flag, --sla��ʶ
                      gjh.period_name, -- �ڼ�,
                      gjs.user_je_source_name, -- ��Դ,
                      gjc.user_je_category_name, --���,
                      xentity_t.entity_code,
                      xentity_t.name entity_cate_name, --����ʵ����������,
                      --------------
                      /* ec.event_class_code,
                      ec.name             event_class, --�¼�����*/
                      ----------------
                      gjb.name        je_batch_name, --     �ռ�������,
                      gjh.name        je_name, --         �ռ�����,
                      gjl.je_line_num je_line_num, --         �ռ����к�,
                      --��׷��
                      xte.transaction_number transcation_num, --��������,
                      xe.event_date event_date, --�¼�����, --�¼�����
                      xah.accounting_date gl_date, --gl����,
                      xgl.name cate_name, --������, --������
                      fnd_flex_ext.get_segs('SQLGL',
                                            'GL#',
                                            xgl.chart_of_accounts_id,
                                            xal.code_combination_id) account, -- �˻�, --�˻�
                      xla_oa_functions_pkg.get_ccid_description(xgl.chart_of_accounts_id,
                                                                xal.code_combination_id) account_desc, -- �˻�˵��, --�˻�˵��
                      nvl(xlp.meaning,
                          xal.accounting_class_code) acc_class, -- ��Ʒ���, --��Ʒ���
                      --��׷��
                      xal.accounted_dr in_borrow, --���ʽ���, --���ʽ���
                      xal.accounted_cr in_credit, -- ���ʴ���, --���ʴ���
                      xal.currency_code in_currend, --�������, --�������
                      xal.entered_dr out_borrow, -- �������, --�������
                      xal.entered_cr out_credit, --  �������, --�������
                      xal.description line_desc, -- ��˵��, --��˵��
                      gjh.name je_cate_name, --   �ռ��ʷ�¼��, --�ռ��ʷ�¼��
                      (nvl(xal.accounted_dr,
                           0) - nvl(xal.accounted_cr,
                                     0)) in_net_amount, --���˾���
                      xah.completed_date, -- ��ƽ�������,
                      xal.ae_line_num, --  ��,
                      ------------------------------      
                      --AP_INVOICES  AP��Ʊ     INVOICE_ID                   \
                      --AP_PAYMENTS  AP����     CHECK_ID                      \
                      --RECEIPTS     �տ�       CASH_RECEIPT_ID                �����������Ĵ����������ֱ� ��Դ��ID
                      --TRANSACTIONS ������  ���۷�Ʊ CUSTOMER_TRX_ID       /
                      xte.source_id_int_1 trans_source_id, --����Դ��Ӧid,
                      ------------------------------
                      xal.currency_conversion_rate, --�����ۻ���,
                      --����WIP
                      wt.transaction_date, -- ����������,
                      wt.transaction_id      transaction_flag, --  �������ʶ,
                      ml1.meaning            transaction_cate, --        ����������,
                      cdv.line_type_name, --    ������,
                      cdv.gl_batch_id        gl_batch, --  gl��,
                      cdv.operation_seq_num, -- ����,
                      cdv.primary_uom, -- ��λ,
                      cdv.primary_quantity, -- ��Ҫ����,
                      cdv.unit_cost, --   ��λ�ɱ�,
                      NULL                   trans_source_type, --    ��������Դ����,
                      cdv.transaction_source, --��������Դ,
                      cdv.reason_name        trans_reason, --   ������ԭ��,
                      cdv.reference          trans_reference, --     ������ο�,
                      
                      cdv.primary_item_id, --  װ���id,
                      cdv.organization_id,
                      cdv.basis, --  ��׼,
                      cdv.department_code, --  ����,
                      cdv.resource_seq_num, -- ��Դ���,
                      cdv.resource_code, --   ��Դ,
                      we.wip_entity_name -- ����
      
        FROM gl_je_batches    gjb,
             gl_je_headers    gjh,
             gl_je_lines      gjl,
             gl_je_sources_vl gjs,
             gl_je_categories gjc,
             --��׷��
             gl_import_references gir,
             --
             xla_ae_lines     xal,
             xla_lookups      xlp,
             xla_ae_headers   xah,
             xla_gl_ledgers_v xgl,
             --
             xla_events                   xe,
             xla.xla_transaction_entities xte,
             --�¼�����
             /* xla_event_types_tl   et,
             xla_event_classes_tl ec,*/
             xla_entity_types_tl xentity_t,
             --����wip
             wip_transactions   wt,
             mfg_lookups        ml1,
             cst_distribution_v cdv, --WIP����������
             wip_entities       we
      
       WHERE 1 = 1
             AND gjb.je_batch_id = gjh.je_batch_id
             AND gjh.je_header_id = gjl.je_header_id
             AND gjh.je_source = gjs.je_source_name
             AND gjc.je_category_name = gjh.je_category
            --��׷��
             AND gir.je_header_id = gjh.je_header_id
             AND gir.je_line_num = gjl.je_line_num
            --
             AND xal.gl_sl_link_id = gir.gl_sl_link_id
             AND xal.gl_sl_link_table = gir.gl_sl_link_table
             AND xlp.lookup_code(+) = xal.accounting_class_code
             AND xlp.lookup_type(+) = 'XLA_ACCOUNTING_CLASS'
            --
             AND xah.ae_header_id = xal.ae_header_id
             AND xah.application_id = xal.application_id
            --
             AND xgl.ledger_id = xah.ledger_id
            --
             AND xe.event_id = xah.event_id
             AND xe.application_id = xah.application_id
            --
             AND xte.entity_id = xe.entity_id
             AND xte.application_id = xe.application_id
            --
             AND xentity_t.entity_code = xte.entity_code
             AND xentity_t.application_id = xte.application_id
             AND xentity_t.language = userenv('LANG')
            --�¼�����
            /*AND xe.application_id = et.application_id
            AND xe.event_type_code = et.event_type_code
            AND ec.application_id = et.application_id
            AND ec.entity_code = et.entity_code
            AND ec.event_class_code = et.event_class_code
            AND ec.language = userenv('LANG')*/
            --����wip
             AND xte.source_id_int_1 = wt.transaction_id
             AND ml1.lookup_type = 'WIP_TRANSACTION_TYPE'
             AND ml1.lookup_code = wt.transaction_type
             AND wt.transaction_id = cdv.transaction_id
             AND wt.organization_id = cdv.organization_id
             AND cdv.reference_account = xal.code_combination_id --����sla�ʻ�
            --
             AND wt.wip_entity_id = we.wip_entity_id
            
            --����
             AND gjh.je_source = 'Cost Management'
             AND gjh.je_category = 'WIP'
             AND gjh.period_name BETWEEN
             nvl(p_period_f,
                     gjh.period_name) AND
             nvl(p_period_t,
                 gjh.period_name)
             AND xah.accounting_date BETWEEN
             nvl(p_gl_date_f,
                     xah.accounting_date) AND
             nvl(p_gl_date_t,
                 xah.accounting_date)
            --
             AND xal.code_combination_id BETWEEN
             nvl(p_account_f,
                     xal.code_combination_id) AND
             nvl(p_account_t,
                 xal.code_combination_id)
            --
            
             AND gjb.name = nvl(p_batch_num,
                                gjb.name)
            
             AND gjh.ledger_id = p_set_of_books_id --����
       ORDER BY xte.transaction_number,
                xal.accounted_dr,
                xal.accounted_cr;
  
    --========================================================
    --===================MTL׷��SQL===========================
    CURSOR cur_mtl_data IS
    --MTL׷��
      SELECT DISTINCT xal.ae_header_id xal_header_id,
                      xal.ae_line_num xal_line_id,
                      xal.code_combination_id,
                      (xal.ae_header_id || '-' || xal.ae_line_num) sla_flag, --sla��ʶ
                      gjh.period_name, --   �ڼ�,
                      gjs.user_je_source_name, -- ��Դ,
                      gjc.user_je_category_name, -- ���,
                      xentity_t.entity_code,
                      xentity_t.name entity_cate_name, --  ����ʵ����������,
                      --------------
                      ec.event_class_code,
                      ec.name             event_class, --�¼�����
                      ----------------
                      gjb.name        je_batch_name, --          �ռ�������,
                      gjh.name        je_name, --        �ռ�����,
                      gjl.je_line_num je_line_num, --      �ռ����к�,
                      --��׷��
                      xte.transaction_number transcation_num, --��������,
                      xe.event_date event_date, -- �¼�����, --�¼�����
                      xah.accounting_date gl_date, --gl����,
                      xgl.name cate_name, --������, --������
                      fnd_flex_ext.get_segs('SQLGL',
                                            'GL#',
                                            xgl.chart_of_accounts_id,
                                            xal.code_combination_id) account, -- �˻�, --�˻�
                      xla_oa_functions_pkg.get_ccid_description(xgl.chart_of_accounts_id,
                                                                xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                      nvl(xlp.meaning,
                          xal.accounting_class_code) acc_class, --��Ʒ���, --��Ʒ���
                      --��׷��
                      xal.accounted_dr in_borrow, --���ʽ���, --���ʽ���
                      xal.accounted_cr in_credit, --���ʴ���, --���ʴ���
                      xal.currency_code in_currend, --�������, --�������
                      xal.entered_dr out_borrow, --�������, --�������
                      xal.entered_cr out_credit, --�������, --�������
                      xal.description line_desc, --��˵��, --��˵��
                      gjh.name je_cate_name, --    �ռ��ʷ�¼��, --�ռ��ʷ�¼��
                      (nvl(xal.accounted_dr,
                           0) - nvl(xal.accounted_cr,
                                     0)) in_net_amount, --���˾���
                      xah.completed_date, --��ƽ�������,
                      ------------------------------      
                      --AP_INVOICES  AP��Ʊ     INVOICE_ID                   \
                      --AP_PAYMENTS  AP����     CHECK_ID                      \
                      --RECEIPTS     �տ�       CASH_RECEIPT_ID                �����������Ĵ����������ֱ� ��Դ��ID
                      --TRANSACTIONS ������  ���۷�Ʊ CUSTOMER_TRX_ID       /
                      xte.source_id_int_1 trans_source_id, --����Դ��Ӧid,
                      ------------------------------
                      xal.currency_conversion_rate /*, --�����ۻ���,
                                                                                                          --����MTL
                                                                                                          mmt.transaction_id transaction_flag, --�������ʶ,
                                                                                                          mtt.transaction_type_name transaction_cate, --����������,
                                                                                                          mmt.transaction_date, --����������,
                                                                                                          mtst.transaction_source_type_name trans_source_type, --��������Դ����,
                                                                                                          get_txn_source(mmt.transaction_id) transaction_source, -- ��������Դ,
                                                                                                          mtr.reason_name trans_reason, --������ԭ��,
                                                                                                          mmt.transaction_reference trans_reference, --������ο�,
                                                                                                          xah.completed_date, --��ƽ�������,
                                                                                                          cidv.gl_batch_id gl_batch, --gl��,
                                                                                                          mmt.subinventory_code, --�ӿ��,
                                                                                                          mmt.primary_quantity, --��Ҫ����
                                                                                                          mmt.transaction_uom primary_uom_code, --��Ҫ��λ
                                                                                                          mmt.locator_id, --��λid,
                                                                                                          cidv.revision, --�汾,
                                                                                                          mmt.department_id,
                                                                                                          mmt.inventory_item_id,
                                                                                                          mmt.organization_id*/
      
        FROM gl_je_batches    gjb,
             gl_je_headers    gjh,
             gl_je_lines      gjl,
             gl_je_sources_vl gjs,
             gl_je_categories gjc,
             --��׷��
             gl_import_references gir,
             --
             xla_ae_lines     xal,
             xla_lookups      xlp,
             xla_ae_headers   xah,
             xla_gl_ledgers_v xgl,
             --
             xla_events                   xe,
             xla.xla_transaction_entities xte,
             --�¼�����
             xla_event_types_tl   et,
             xla_event_classes_tl ec,
             --
             xla_entity_types_tl xentity_t /*,
                                                                                                 --����mtl
                                                                                                 mtl_material_transactions mmt,
                                                                                                 mtl_transaction_types     mtt,
                                                                                                 mtl_txn_source_types      mtst,
                                                                                                 mtl_transaction_reasons   mtr,
                                                                                                 cst_inv_distribution_v    cidv*/ --����
      
       WHERE 1 = 1
             AND gjb.je_batch_id = gjh.je_batch_id
             AND gjh.je_header_id = gjl.je_header_id
             AND gjh.je_source = gjs.je_source_name
             AND gjc.je_category_name = gjh.je_category
            --��׷��
             AND gir.je_header_id = gjh.je_header_id
             AND gir.je_line_num = gjl.je_line_num
            --
             AND xal.gl_sl_link_id = gir.gl_sl_link_id
             AND xal.gl_sl_link_table = gir.gl_sl_link_table
             AND xlp.lookup_code(+) = xal.accounting_class_code
             AND xlp.lookup_type(+) = 'XLA_ACCOUNTING_CLASS'
            --
             AND xah.ae_header_id = xal.ae_header_id
             AND xah.application_id = xal.application_id
            --
             AND xgl.ledger_id = xah.ledger_id
            --
             AND xe.event_id = xah.event_id
             AND xe.application_id = xah.application_id
            --
             AND xte.entity_id = xe.entity_id
             AND xte.application_id = xe.application_id
            --
             AND xentity_t.entity_code = xte.entity_code
             AND xentity_t.application_id = xte.application_id
             AND xentity_t.language = userenv('LANG')
            --�¼�����
             AND xe.application_id = et.application_id
             AND xe.event_type_code = et.event_type_code
             AND ec.application_id = et.application_id
             AND ec.entity_code = et.entity_code
             AND ec.event_class_code = et.event_class_code
             AND ec.language = userenv('LANG')
            /*--����mtl
            AND mmt.transaction_id = xte.source_id_int_1
            AND mmt.transaction_type_id = mtt.transaction_type_id
            AND mmt.transaction_source_type_id =
            mtst.transaction_source_type_id
            AND mmt.reason_id = mtr.reason_id(+) --�����ӣ���ֹû������ԭ��
            AND mmt.organization_id = cidv.organization_id
            AND mmt.transaction_id = cidv.transaction_id
            AND cidv.reference_account = xal.code_combination_id --����sla�˻�*/
            
            --����
             AND gjs.user_je_source_name IN
             ('Oracle Cost Management',
                  'Cost Management')
             AND gjh.je_category IN ('MTL',
                                     'Inventory')
             AND gjh.period_name BETWEEN
             nvl(p_period_f,
                     gjh.period_name) AND
             nvl(p_period_t,
                 gjh.period_name)
             AND xah.accounting_date BETWEEN
             nvl(p_gl_date_f,
                     xah.accounting_date) AND
             nvl(p_gl_date_t,
                 xah.accounting_date)
            --
             AND xal.code_combination_id BETWEEN
             nvl(p_account_f,
                     xal.code_combination_id) AND
             nvl(p_account_t,
                 xal.code_combination_id)
            --
             AND gjb.name = nvl(p_batch_num,
                                gjb.name)
            
             AND gjh.ledger_id = p_set_of_books_id --����
      
       ORDER BY xte.transaction_number,
                xal.accounted_dr,
                xal.accounted_cr;
  
    --========================================================
    --===================recevice׷��SQL======================
    CURSOR cur_rcv_data IS
      SELECT DISTINCT xal.ae_header_id xal_header_id,
                      xal.ae_line_num xal_line_id,
                      (xal.ae_header_id || '-' || xal.ae_line_num) sla_flag, --sla��ʶ
                      gjh.period_name, --     �ڼ�,
                      gjs.user_je_source_name, --  ��Դ,
                      gjc.user_je_category_name, --���,
                      xentity_t.entity_code,
                      xentity_t.name entity_cate_name, --  ����ʵ����������,
                      gjb.name je_batch_name, --  �ռ�������,
                      gjh.name je_name, --      �ռ�����,
                      gjl.je_line_num je_line_num, --      �ռ����к�,
                      --��׷��
                      xte.transaction_number transcation_num, --��������,
                      xe.event_date event_date, --�¼�����
                      xah.accounting_date gl_date, --gl����,
                      xgl.name cate_name, --������, --������
                      fnd_flex_ext.get_segs('SQLGL',
                                            'GL#',
                                            xgl.chart_of_accounts_id,
                                            xal.code_combination_id) account, --  --�˻�, --�˻�
                      xla_oa_functions_pkg.get_ccid_description(xgl.chart_of_accounts_id,
                                                                xal.code_combination_id) account_desc, --�˻�˵��, --�˻�˵��
                      nvl(xlp.meaning,
                          xal.accounting_class_code) acc_class, --��Ʒ���, --��Ʒ���
                      --��׷��
                      xal.accounted_dr in_borrow, -- ���ʽ���, --���ʽ���
                      xal.accounted_cr in_credit, --���ʴ���, --���ʴ���
                      xal.currency_code in_currend, -- �������, --�������
                      xal.entered_dr out_borrow, -- �������, --�������
                      xal.entered_cr out_credit, --�������, --�������
                      (nvl(xal.accounted_dr,
                           0) - nvl(xal.accounted_cr,
                                     0)) in_net_amount, --���˾���
                      xal.ae_line_num, --�к�
                      xal.description line_desc, --��˵��, --��˵��
                      gjh.name je_cate_name, -- �ռ��ʷ�¼��, --�ռ��ʷ�¼��
                      ------------------------------      
                      --AP_INVOICES  AP��Ʊ     INVOICE_ID                   \
                      --AP_PAYMENTS  AP����     CHECK_ID                      \
                      --RECEIPTS     �տ�       CASH_RECEIPT_ID                �����������Ĵ����������ֱ� ��Դ��ID
                      --TRANSACTIONS ������  ���۷�Ʊ CUSTOMER_TRX_ID       /
                      xte.source_id_int_1 trans_source_id, -- ����Դ��Ӧid
                      ------------------------------
                      --����������
                      rsh.receipt_num, --���պ�
                      rt.transaction_type, --����������
                      rt.transaction_date,
                      rt.quantity          transact_qty, --����
                      msi.segment1         item_code, --����
                      rsl.item_description, --��������
                      pv.segment1          vendor_num, --��Ӧ�̱��
                      pv.vendor_name, --��Ӧ��
                      --
                      ph.segment1        order_num, --������
                      rt.unit_of_measure transact_uom
      
        FROM gl_je_batches    gjb,
             gl_je_headers    gjh,
             gl_je_lines      gjl,
             gl_je_sources_vl gjs,
             gl_je_categories gjc,
             --��׷��
             gl_import_references gir,
             --
             xla_ae_lines     xal,
             xla_lookups      xlp,
             xla_ae_headers   xah,
             xla_gl_ledgers_v xgl,
             --
             xla_events                   xe,
             xla.xla_transaction_entities xte,
             xla_entity_types_tl          xentity_t,
             --����������
             rcv_transactions     rt,
             rcv_shipment_headers rsh,
             rcv_shipment_lines   rsl,
             mtl_system_items_b   msi,
             po_vendors           pv,
             --
             po_headers_all ph
      
       WHERE 1 = 1
             AND gjb.je_batch_id = gjh.je_batch_id
             AND gjh.je_header_id = gjl.je_header_id
             AND gjh.je_source = gjs.je_source_name
             AND gjc.je_category_name = gjh.je_category
            --��׷��
             AND gir.je_header_id = gjh.je_header_id
             AND gir.je_line_num = gjl.je_line_num
            --
             AND xal.gl_sl_link_id = gir.gl_sl_link_id
             AND xal.gl_sl_link_table = gir.gl_sl_link_table
             AND xlp.lookup_code(+) = xal.accounting_class_code
             AND xlp.lookup_type(+) = 'XLA_ACCOUNTING_CLASS'
            --
             AND xah.ae_header_id = xal.ae_header_id
             AND xah.application_id = xal.application_id
            --
             AND xgl.ledger_id = xah.ledger_id
            --
             AND xe.event_id = xah.event_id
             AND xe.application_id = xah.application_id
            --
             AND xte.entity_id = xe.entity_id
             AND xte.application_id = xe.application_id
            --
             AND xentity_t.entity_code = xte.entity_code
             AND xentity_t.application_id = xte.application_id
             AND xentity_t.language = userenv('LANG')
            --����������
             AND xte.source_id_int_1 = rt.transaction_id
             AND rsh.shipment_header_id = rt.shipment_header_id
             AND rsl.shipment_line_id = rt.shipment_line_id
             AND rsl.item_id = msi.inventory_item_id
             AND rt.organization_id = msi.organization_id
             AND rt.vendor_id = pv.vendor_id
            --
             AND ph.po_header_id(+) = rt.po_header_id
            
            --����
             AND gjh.je_source = 'Cost Management' --���������ԣ�ֱ��ȡcode
             AND gjh.je_category = 'Receiving'
            
             AND gjh.period_name BETWEEN
             nvl(p_period_f,
                     gjh.period_name) AND
             nvl(p_period_t,
                 gjh.period_name)
             AND xah.accounting_date BETWEEN
             nvl(p_gl_date_f,
                     xah.accounting_date) AND
             nvl(p_gl_date_t,
                 xah.accounting_date)
            --
             AND xal.code_combination_id BETWEEN
             nvl(p_account_f,
                     xal.code_combination_id) AND
             nvl(p_account_t,
                 xal.code_combination_id)
            --
            
             AND gjb.name = nvl(p_batch_num,
                                gjb.name)
            
             AND gjh.ledger_id = p_set_of_books_id --����
      
       ORDER BY xte.transaction_number,
                xal.accounted_dr,
                xal.accounted_cr;
  
  BEGIN
    /*x_return_status := cux_api.start_activity(p_pkg_name      => g_pkg_name,
                                              p_api_name      => l_api_name,
                                              p_init_msg_list => p_init_msg_list);
    
    raise_exception(x_return_status);*/
  
    --body
    cux_conc_utl.log_header;
  
    -- output(cux_fnd_xml_utl.get_file_start('UTF-8'));
    output(cux_fnd_xml_utl.get_file_start(g_charset));
    output(cux_fnd_xml_utl.get_tag_start('reports'));
    --
    output(cux_fnd_xml_utl.get_tag_start('sheet'));
    IF userenv('LANG') = 'ZHS' THEN
      output(cux_fnd_xml_utl.get_tag('sheet_name',
                                     '�ռ���׷����ϸ����'));
    ELSIF userenv('LANG') = 'US' THEN
      output(cux_fnd_xml_utl.get_tag('sheet_name',
                                     'CUX_Drill Down report'));
    END IF;
    output(cux_fnd_xml_utl.get_tag_start('header'));
    --���ݱ��������ж��������
    IF p_report_type = 'AP' THEN
    
      FOR rec_ap_data IN cur_ap_data LOOP
        --����Ӧ���ʿ�����ж�ȡ����Ƿ�Ʊ�ϵĹ�Ӧ��
        l_vendor_name      := NULL;
        l_vendor_site_code := NULL;
        /*log(rec_ap_data.user_je_category_name ||
        ' rec_ap_data.trans_source_id: ' ||
        rec_ap_data.trans_source_id);*/
        IF rec_ap_data.user_je_category_name IN
           ('����',
            'Payments') THEN
          get_pay_vendor(rec_ap_data.trans_source_id,
                         l_vendor_name,
                         l_vendor_site_code);
        
        ELSIF rec_ap_data.user_je_category_name IN
              ('�ɹ���Ʊ',
               'Purchase Invoices') THEN
          get_purching_vendor(rec_ap_data.trans_source_id,
                              l_vendor_name,
                              l_vendor_site_code);
        END IF;
      
        --�������
        output(cux_fnd_xml_utl.get_tag_start('ap_group')); --������
      
        output(cux_fnd_xml_utl.get_tag('transcation_num',
                                       rec_ap_data.transcation_num)); --��������
        -----
        output(cux_fnd_xml_utl.get_tag('acc_class_ap',
                                       rec_ap_data.acc_class)); --��Ʒ���
        output(cux_fnd_xml_utl.get_tag('user_je_category_name_ap',
                                       rec_ap_data.user_je_category_name)); --���
      
        -----
        ---
        output(cux_fnd_xml_utl.get_tag('xal_header_id_ap',
                                       rec_ap_data.xal_header_id)); --xal_header_id
        output(cux_fnd_xml_utl.get_tag('xal_line_id_ap',
                                       rec_ap_data.xal_line_id)); --xal_line_id
        output(cux_fnd_xml_utl.get_tag('sla_flag_ap',
                                       rec_ap_data.sla_flag)); --sla_flag
        --
        output(cux_fnd_xml_utl.get_tag('gl_date',
                                       to_char(rec_ap_data.gl_date,
                                               g_farmat))); --GL����
        output(cux_fnd_xml_utl.get_tag('vendor_name',
                                       l_vendor_name)); --��Ӧ������
        output(cux_fnd_xml_utl.get_tag('vendor_site_code',
                                       l_vendor_site_code)); --��Ӧ�̵ص�
      
        output(cux_fnd_xml_utl.get_tag('account',
                                       rec_ap_data.account)); --�˻�
        output(cux_fnd_xml_utl.get_tag('account_desc_ap',
                                       rec_ap_data.account_desc)); --�˻�˵��                               
        output(cux_fnd_xml_utl.get_tag('in_borrow',
                                       rec_ap_data.in_borrow)); --���ʽ���
        output(cux_fnd_xml_utl.get_tag('in_credit',
                                       rec_ap_data.in_credit)); --���ʴ���
        --
        output(cux_fnd_xml_utl.get_tag('in_net_amount_ap',
                                       rec_ap_data.in_net_amount)); --���ʾ���
        --
        output(cux_fnd_xml_utl.get_tag('in_currend',
                                       rec_ap_data.in_currend)); --�������                         
      
        output(cux_fnd_xml_utl.get_tag('out_borrow',
                                       rec_ap_data.out_borrow)); --�������
        output(cux_fnd_xml_utl.get_tag('out_credit',
                                       rec_ap_data.out_credit)); --�������
        output(cux_fnd_xml_utl.get_tag('ae_line_num_ap',
                                       rec_ap_data.ae_line_num)); --�к�
        output(cux_fnd_xml_utl.get_tag('line_desc_ap',
                                       rec_ap_data.line_desc)); --��˵��
      
        output(cux_fnd_xml_utl.get_tag('je_name',
                                       rec_ap_data.je_name)); --�ռ�������
        output(cux_fnd_xml_utl.get_tag('event_date',
                                       to_char(rec_ap_data.event_date,
                                               g_farmat))); --�¼�����
      
        output(cux_fnd_xml_utl.get_tag('line_desc',
                                       rec_ap_data.line_desc)); --��˵��
        output(cux_fnd_xml_utl.get_tag('dis_line_num',
                                       NULL)); --��Ʊ�����к�
        output(cux_fnd_xml_utl.get_tag('dis_line_type',
                                       NULL)); --��Ʊ����������
        output(cux_fnd_xml_utl.get_tag('tax_code',
                                       NULL)); --˰��
      
        output(cux_fnd_xml_utl.get_tag_end);
      
      END LOOP;
    
      --======================================================
      --AR׷��Sheetҳ
      --======================================================
    ELSIF p_report_type = 'AR' THEN
    
      FOR rec_ar_data IN cur_ar_data LOOP
        --����Ӧ���ʿ�����ж�ȡ�տ�Ƿ�Ʊ�ϵĿͻ�
        l_cust_name       := NULL;
        l_cust_site_code  := NULL;
        l_cust_number     := NULL;
        l_receipt_num     := NULL;
        l_receipt_date    := NULL;
        l_receipt_method  := NULL;
        l_receipt_comment := NULL;
        /*log(rec_ar_data.sla_flag || '  ' ||
        rec_ar_data.user_je_category_name ||
        ' rec_ar_data.trans_source_id: ' ||
        rec_ar_data.trans_source_id);*/
        IF rec_ar_data.user_je_category_name IN
           ('��ҵ�վ�',
            'Trade Receipts',
            'Receipts',
            '�տ�') THEN
          get_receipt_vendor(rec_ar_data.trans_source_id,
                             l_cust_name,
                             l_cust_site_code,
                             l_cust_number);
        
          --��ȡ�տ���Ϣ
          get_receipt_details(rec_ar_data.trans_source_id,
                              l_receipt_num,
                              l_receipt_date,
                              l_receipt_method,
                              l_receipt_comment);
        ELSIF rec_ar_data.user_je_category_name IN
              ('���۷�Ʊ',
               'Sales Invoices',
               'Credit Memos') THEN
          get_rcp_trans_vendor(rec_ar_data.trans_source_id,
                               l_cust_name,
                               l_cust_site_code,
                               l_cust_number);
        END IF;
      
        --�������
        output(cux_fnd_xml_utl.get_tag_start('ar_group')); --������
      
        output(cux_fnd_xml_utl.get_tag('cust_name',
                                       l_cust_name)); --�ͻ�����
        output(cux_fnd_xml_utl.get_tag('cust_number',
                                       l_cust_number)); --�ͻ����
        output(cux_fnd_xml_utl.get_tag('cust_site_code',
                                       l_cust_site_code)); --�ͻ��ص�����
        output(cux_fnd_xml_utl.get_tag('transcation_num_ar',
                                       rec_ar_data.transcation_num)); --��������
      
        -----
        output(cux_fnd_xml_utl.get_tag('acc_class_ar',
                                       rec_ar_data.acc_class)); --��Ʒ���
        output(cux_fnd_xml_utl.get_tag('user_je_category_name_ar',
                                       rec_ar_data.user_je_category_name)); --���
      
        -----
        ---
        output(cux_fnd_xml_utl.get_tag('xal_header_id_ar',
                                       rec_ar_data.xal_header_id)); --xal_header_id
        output(cux_fnd_xml_utl.get_tag('xal_line_id_ar',
                                       rec_ar_data.xal_line_id)); --xal_line_id
        output(cux_fnd_xml_utl.get_tag('sla_flag_ar',
                                       rec_ar_data.sla_flag)); --sla_flag
        --
      
        output(cux_fnd_xml_utl.get_tag('gl_date_ar',
                                       to_char(rec_ar_data.gl_date,
                                               g_farmat))); --GL����
        output(cux_fnd_xml_utl.get_tag('account_ar',
                                       rec_ar_data.account)); --�˻�
        output(cux_fnd_xml_utl.get_tag('account_desc_ar',
                                       rec_ar_data.account_desc)); --�˻�˵��
        output(cux_fnd_xml_utl.get_tag('in_borrow_ar',
                                       rec_ar_data.in_borrow)); --���ʽ���
        output(cux_fnd_xml_utl.get_tag('in_credit_ar',
                                       rec_ar_data.in_credit)); --���ʴ���
        --
        output(cux_fnd_xml_utl.get_tag('in_net_amount_ar',
                                       rec_ar_data.in_net_amount)); --���ʾ���
        --
        output(cux_fnd_xml_utl.get_tag('in_currend_ar',
                                       rec_ar_data.in_currend)); --�������                          
      
        output(cux_fnd_xml_utl.get_tag('out_borrow_ar',
                                       rec_ar_data.out_borrow)); --�������
        output(cux_fnd_xml_utl.get_tag('out_credit_ar',
                                       rec_ar_data.out_credit)); --�������
        output(cux_fnd_xml_utl.get_tag('event_date_ar',
                                       to_char(rec_ar_data.event_date,
                                               g_farmat))); --�¼�����
        output(cux_fnd_xml_utl.get_tag('je_batch_name_ar',
                                       rec_ar_data.je_batch_name)); --�ռ�������
      
        output(cux_fnd_xml_utl.get_tag('je_name_ar',
                                       rec_ar_data.je_name)); --�ռ�����
      
        output(cux_fnd_xml_utl.get_tag('receipt_method_ar',
                                       l_receipt_method)); --�����
        output(cux_fnd_xml_utl.get_tag('receipt_comment_ar',
                                       l_receipt_comment)); --��ע      
        output(cux_fnd_xml_utl.get_tag('receipt_num_ar',
                                       l_receipt_num)); --�վݱ��
        output(cux_fnd_xml_utl.get_tag('receipt_date_ar',
                                       to_char(l_receipt_date,
                                               g_farmat))); --��������
      
        output(cux_fnd_xml_utl.get_tag_end);
      
      END LOOP;
    
    ELSIF p_report_type = 'COST' THEN
      --======================================================
      --MTL׷��Sheetҳ
      --======================================================
    
      FOR rec_mtl_data IN cur_mtl_data LOOP
        --��ʼ��
        l_transaction_flag_mtl   := NULL;
        l_transaction_cate_mtl   := NULL;
        l_transaction_date_mtl   := NULL;
        l_trans_source_type_mtl  := NULL;
        l_transaction_source_mtl := NULL;
        l_trans_reason_mtl       := NULL;
        l_trans_reference_mtl    := NULL;
        l_subinventory_code_mtl  := NULL;
        l_primary_quantity       := NULL;
        l_primary_uom_code_mtl   := NULL;
        l_locator_mtl            := NULL;
        l_department_mtl         := NULL;
        l_item_code_mtl          := NULL;
        l_item_desc_mtl          := NULL;
        l_gl_batch_mtl           := NULL;
        l_revision_mtl           := NULL;
        l_unit_cost_mtl          := NULL;
        --
        l_match_amount := NULL;
      
        --�жϵ�ǰsla���ǽ���Ǵ���
        IF rec_mtl_data.in_borrow IS NOT NULL
           AND rec_mtl_data.in_credit IS NULL THEN
          l_match_amount := rec_mtl_data.in_borrow;
        ELSIF rec_mtl_data.in_borrow IS NULL
              AND rec_mtl_data.in_credit IS NOT NULL THEN
          l_match_amount := -rec_mtl_data.in_credit;
        END IF;
      
        --��ȡ��������Ϣ
        --��֯��ֱ�ӽ���\��֯��ֱ�ӷ���\��֯�ڲ�ת������Ϊ��֯��ת��������
        IF rec_mtl_data.event_class_code IN
           ('DIR_INTERORG_RCPT',
            'DIR_INTERORG_SHIP',
            'INTRAORG_TXFR') THEN
          get_mtl_detail(1, --1����֯��ת�� 2������������
                         rec_mtl_data.trans_source_id,
                         l_transaction_flag_mtl, --�������ʶ,
                         l_transaction_cate_mtl, --����������,
                         l_transaction_date_mtl, --����������,
                         l_trans_source_type_mtl, --��������Դ����,
                         l_transaction_source_mtl, -- ��������Դ,
                         l_trans_reason_mtl, --������ԭ��,
                         l_trans_reference_mtl, --������ο�,
                         l_subinventory_code_mtl, --�ӿ��,
                         l_primary_quantity, --��Ҫ����
                         l_primary_uom_code_mtl, --��Ҫ��λ
                         l_locator_mtl, --��λ
                         l_department_mtl, --����
                         l_item_code_mtl, --����
                         l_item_desc_mtl);
        
        ELSE
          get_mtl_detail(2, --1����֯��ת�� 2������������
                         rec_mtl_data.trans_source_id,
                         l_transaction_flag_mtl, --�������ʶ,
                         l_transaction_cate_mtl, --����������,
                         l_transaction_date_mtl, --����������,
                         l_trans_source_type_mtl, --��������Դ����,
                         l_transaction_source_mtl, -- ��������Դ,
                         l_trans_reason_mtl, --������ԭ��,
                         l_trans_reference_mtl, --������ο�,
                         l_subinventory_code_mtl, --�ӿ��,
                         l_primary_quantity, --��Ҫ����
                         l_primary_uom_code_mtl, --��Ҫ��λ
                         l_locator_mtl, --��λ
                         l_department_mtl, --����
                         l_item_code_mtl, --����
                         l_item_desc_mtl);
        
        END IF;
      
        --��ȡmtl��������Ϣ
        get_mtl_dist_detail(rec_mtl_data.trans_source_id,
                            rec_mtl_data.code_combination_id,
                            l_match_amount,
                            l_gl_batch_mtl,
                            l_revision_mtl,
                            l_unit_cost_mtl);
      
        output(cux_fnd_xml_utl.get_tag_start('mtl_group')); --������
      
        output(cux_fnd_xml_utl.get_tag('account_mtl',
                                       rec_mtl_data.account)); --�˻�
        output(cux_fnd_xml_utl.get_tag('account_desc_mtl',
                                       rec_mtl_data.account_desc)); --�˻�˵��
        output(cux_fnd_xml_utl.get_tag('transcation_num_mtl',
                                       rec_mtl_data.transcation_num)); --��������
      
        -----
        output(cux_fnd_xml_utl.get_tag('acc_class_mtl',
                                       rec_mtl_data.acc_class)); --��Ʒ���
        output(cux_fnd_xml_utl.get_tag('user_je_category_name_mtl',
                                       rec_mtl_data.user_je_category_name)); --���
      
        -----
        --
        output(cux_fnd_xml_utl.get_tag('je_name_mtl',
                                       rec_mtl_data.je_name)); --�ռ�����
        output(cux_fnd_xml_utl.get_tag('je_batch_name_mtl',
                                       rec_mtl_data.je_batch_name)); --�ռ�������
        ---
        output(cux_fnd_xml_utl.get_tag('xal_header_id_mtl',
                                       rec_mtl_data.xal_header_id)); --xal_header_id
        output(cux_fnd_xml_utl.get_tag('xal_line_id_mtl',
                                       rec_mtl_data.xal_line_id)); --xal_line_id
        output(cux_fnd_xml_utl.get_tag('sla_flag_mtl',
                                       rec_mtl_data.sla_flag)); --sla_flag
        --
        output(cux_fnd_xml_utl.get_tag('transaction_date_mtl',
                                       to_char(l_transaction_date_mtl,
                                               g_farmat))); --����������
        output(cux_fnd_xml_utl.get_tag('transaction_flag_mtl',
                                       l_transaction_flag_mtl)); --�������ʶ
        output(cux_fnd_xml_utl.get_tag('transaction_cate_mtl',
                                       l_transaction_cate_mtl)); --����������
        output(cux_fnd_xml_utl.get_tag('in_borrow_mtl',
                                       rec_mtl_data.in_borrow)); --���ʽ���
        output(cux_fnd_xml_utl.get_tag('in_credit_mtl',
                                       rec_mtl_data.in_credit)); --���ʴ���
        --
        output(cux_fnd_xml_utl.get_tag('in_net_amount_mtl',
                                       rec_mtl_data.in_net_amount)); --���ʾ���
        --
        output(cux_fnd_xml_utl.get_tag('in_currend_mtl',
                                       rec_mtl_data.in_currend)); --�������
        output(cux_fnd_xml_utl.get_tag('out_borrow_mtl',
                                       rec_mtl_data.out_borrow)); --�������
        output(cux_fnd_xml_utl.get_tag('out_credit_mtl',
                                       rec_mtl_data.out_credit)); --�������
      
        output(cux_fnd_xml_utl.get_tag('currency_conversion_rate_mtl',
                                       rec_mtl_data.currency_conversion_rate)); --�����ۻ���
        output(cux_fnd_xml_utl.get_tag('primary_quantity_mtl',
                                       l_primary_quantity)); --��Ҫ����
        output(cux_fnd_xml_utl.get_tag('primary_uom_code_mtl',
                                       l_primary_uom_code_mtl)); --��Ҫ��λ
        output(cux_fnd_xml_utl.get_tag('trans_source_type_mtl',
                                       l_trans_source_type_mtl)); --��������Դ����
        output(cux_fnd_xml_utl.get_tag('transaction_source_mtl',
                                       l_transaction_source_mtl)); --��������Դ
        output(cux_fnd_xml_utl.get_tag('trans_reason_mtl',
                                       l_trans_reason_mtl)); --������ԭ��
        output(cux_fnd_xml_utl.get_tag('trans_reference_mtl',
                                       l_trans_reference_mtl)); --������ο�
        output(cux_fnd_xml_utl.get_tag('gl_batch_mtl',
                                       l_gl_batch_mtl)); --gl��
      
        output(cux_fnd_xml_utl.get_tag('subinventory_code_mtl',
                                       l_subinventory_code_mtl)); --�ӿ��
        output(cux_fnd_xml_utl.get_tag('locator_mtl',
                                       l_locator_mtl)); --��λ
        output(cux_fnd_xml_utl.get_tag('item_code_mtl',
                                       l_item_code_mtl)); --��Ŀ
        output(cux_fnd_xml_utl.get_tag('item_desc_mtl',
                                       l_item_desc_mtl)); --����˵��
        output(cux_fnd_xml_utl.get_tag('revision_mtl',
                                       l_revision_mtl)); --�汾
        output(cux_fnd_xml_utl.get_tag('dept_code_mtl',
                                       l_department_mtl)); --����
        output(cux_fnd_xml_utl.get_tag('unit_cost_mtl',
                                       l_unit_cost_mtl)); --��λ�ɱ�
        output(cux_fnd_xml_utl.get_tag('completed_date_mtl',
                                       rec_mtl_data.completed_date)); --��ƽ�������
      
        output(cux_fnd_xml_utl.get_tag_end);
      
      END LOOP;
    
      --======================================================
      --WIP׷��Sheetҳ
      --======================================================
      FOR rec_wip_data IN cur_wip_data LOOP
      
        --��ȡװ���
        l_primary_code := NULL;
        l_primary_desc := NULL;
        get_item_detail(rec_wip_data.primary_item_id,
                        rec_wip_data.organization_id,
                        l_primary_code,
                        l_primary_desc);
      
        --�������
        output(cux_fnd_xml_utl.get_tag_start('wip_group')); --������
      
        output(cux_fnd_xml_utl.get_tag('account_wip',
                                       rec_wip_data.account)); --�˻�
        output(cux_fnd_xml_utl.get_tag('account_desc_wip',
                                       rec_wip_data.account_desc)); --�˻�˵��
        output(cux_fnd_xml_utl.get_tag('transcation_num_wip',
                                       rec_wip_data.transcation_num)); --��������
      
        -----
        output(cux_fnd_xml_utl.get_tag('acc_class_wip',
                                       rec_wip_data.acc_class)); --��Ʒ���
        output(cux_fnd_xml_utl.get_tag('user_je_category_name_wip',
                                       rec_wip_data.user_je_category_name)); --���
      
        -----
        --
        output(cux_fnd_xml_utl.get_tag('je_name_wip',
                                       rec_wip_data.je_name)); --�ռ�����
        output(cux_fnd_xml_utl.get_tag('je_batch_name_wip',
                                       rec_wip_data.je_batch_name)); --�ռ�������
        ---
        output(cux_fnd_xml_utl.get_tag('xal_header_id_wip',
                                       rec_wip_data.xal_header_id)); --xal_header_id
        output(cux_fnd_xml_utl.get_tag('xal_line_id_wip',
                                       rec_wip_data.xal_line_id)); --xal_line_id
        output(cux_fnd_xml_utl.get_tag('sla_flag_wip',
                                       rec_wip_data.sla_flag)); --xal_line_id
        --
        output(cux_fnd_xml_utl.get_tag('transaction_date_wip',
                                       to_char(rec_wip_data.transaction_date,
                                               g_farmat))); --����������
        output(cux_fnd_xml_utl.get_tag('transaction_flag_wip',
                                       rec_wip_data.transaction_flag)); --�������ʶ
        output(cux_fnd_xml_utl.get_tag('transaction_cate_wip',
                                       rec_wip_data.transaction_cate)); --����������
        output(cux_fnd_xml_utl.get_tag('in_borrow_wip',
                                       rec_wip_data.in_borrow)); --���ʽ���
        output(cux_fnd_xml_utl.get_tag('in_credit_wip',
                                       rec_wip_data.in_credit)); --���ʴ���
        --
        output(cux_fnd_xml_utl.get_tag('in_net_amount_wip',
                                       rec_wip_data.in_net_amount)); --���ʾ���
        --
        output(cux_fnd_xml_utl.get_tag('in_currend_wip',
                                       rec_wip_data.in_currend)); --�������
        output(cux_fnd_xml_utl.get_tag('out_borrow_wip',
                                       rec_wip_data.out_borrow)); --�������
        output(cux_fnd_xml_utl.get_tag('out_credit_wip',
                                       rec_wip_data.out_credit)); --�������
      
        output(cux_fnd_xml_utl.get_tag('currency_conversion_rate_wip',
                                       rec_wip_data.currency_conversion_rate)); --�����ۻ���
        output(cux_fnd_xml_utl.get_tag('line_type_name_wip',
                                       rec_wip_data.line_type_name)); --������
        output(cux_fnd_xml_utl.get_tag('cost_element',
                                       NULL)); --�ɱ�Ҫ��
        output(cux_fnd_xml_utl.get_tag('operation_seq_num_wip',
                                       rec_wip_data.operation_seq_num)); --����
        output(cux_fnd_xml_utl.get_tag('primary_uom_wip',
                                       rec_wip_data.primary_uom)); --��λ
        output(cux_fnd_xml_utl.get_tag('primary_quantity_wip',
                                       rec_wip_data.primary_quantity)); --��Ҫ����
        output(cux_fnd_xml_utl.get_tag('unit_cost_wip',
                                       rec_wip_data.unit_cost)); --��λ�ɱ�
        output(cux_fnd_xml_utl.get_tag('transaction_source_wip',
                                       rec_wip_data.transaction_source)); --��������Դ
        output(cux_fnd_xml_utl.get_tag('trans_reason_wip',
                                       rec_wip_data.trans_reason)); --������ԭ��
        output(cux_fnd_xml_utl.get_tag('trans_reference_wip',
                                       rec_wip_data.trans_reference)); --������ο�
      
        output(cux_fnd_xml_utl.get_tag('gl_batch_wip',
                                       rec_wip_data.gl_batch)); --gl��
        output(cux_fnd_xml_utl.get_tag('completed_date_wip',
                                       rec_wip_data.completed_date)); --��ƽ�������
        output(cux_fnd_xml_utl.get_tag('ae_line_num_wip',
                                       rec_wip_data.ae_line_num)); --��
        output(cux_fnd_xml_utl.get_tag('primary_code_wip',
                                       l_primary_code)); --װ���
        output(cux_fnd_xml_utl.get_tag('primary_desc_wip',
                                       l_primary_desc)); --����˵��
        output(cux_fnd_xml_utl.get_tag('basis_wip',
                                       rec_wip_data.basis)); --��׼
      
        output(cux_fnd_xml_utl.get_tag('department_code_wip',
                                       rec_wip_data.department_code)); --����
        output(cux_fnd_xml_utl.get_tag('resource_seq_num_wip',
                                       rec_wip_data.resource_seq_num)); --��Դ���
        output(cux_fnd_xml_utl.get_tag('resource_code_wip',
                                       rec_wip_data.resource_code)); --��Դ
        output(cux_fnd_xml_utl.get_tag('wip_entity_name_wip',
                                       rec_wip_data.wip_entity_name)); --����
      
        output(cux_fnd_xml_utl.get_tag_end);
      
      END LOOP;
    
      --======================================================
      --RCV׷��Sheetҳ
      --======================================================
      FOR rec_rcv_data IN cur_rcv_data LOOP
      
        --�������
        output(cux_fnd_xml_utl.get_tag_start('rcv_group')); --������
      
        output(cux_fnd_xml_utl.get_tag('account_rcv',
                                       rec_rcv_data.account)); --�˻�
        output(cux_fnd_xml_utl.get_tag('account_desc_rcv',
                                       rec_rcv_data.account_desc)); --�˻�˵��
        output(cux_fnd_xml_utl.get_tag('transcation_num_rcv',
                                       rec_rcv_data.transcation_num)); --��������
      
        -----
        output(cux_fnd_xml_utl.get_tag('acc_class_rcv',
                                       rec_rcv_data.acc_class)); --��Ʒ���
        output(cux_fnd_xml_utl.get_tag('user_je_category_name_rcv',
                                       rec_rcv_data.user_je_category_name)); --���
      
        -----
        --
        output(cux_fnd_xml_utl.get_tag('je_name_rcv',
                                       rec_rcv_data.je_name)); --�ռ�����
        output(cux_fnd_xml_utl.get_tag('je_batch_name_rcv',
                                       rec_rcv_data.je_batch_name)); --�ռ�������
        ---
        output(cux_fnd_xml_utl.get_tag('xal_header_id_rcv',
                                       rec_rcv_data.xal_header_id)); --xal_header_id
        output(cux_fnd_xml_utl.get_tag('xal_line_id_rcv',
                                       rec_rcv_data.xal_line_id)); --xal_line_id
        output(cux_fnd_xml_utl.get_tag('sla_flag_rcv',
                                       rec_rcv_data.sla_flag)); --xal_line_id
        --
      
        output(cux_fnd_xml_utl.get_tag('in_borrow_rcv',
                                       rec_rcv_data.in_borrow)); --���ʽ���
        output(cux_fnd_xml_utl.get_tag('in_credit_rcv',
                                       rec_rcv_data.in_credit)); --���ʴ���
        --
        output(cux_fnd_xml_utl.get_tag('in_net_amount_rcv',
                                       rec_rcv_data.in_net_amount)); --���ʾ���
        --
        output(cux_fnd_xml_utl.get_tag('in_currend_rcv',
                                       rec_rcv_data.in_currend)); --�������
        output(cux_fnd_xml_utl.get_tag('out_borrow_rcv',
                                       rec_rcv_data.out_borrow)); --�������
        output(cux_fnd_xml_utl.get_tag('out_credit_rcv',
                                       rec_rcv_data.out_credit)); --�������
      
        --
        output(cux_fnd_xml_utl.get_tag('receipt_num_rcv',
                                       rec_rcv_data.receipt_num)); --���պ�
        output(cux_fnd_xml_utl.get_tag('transaction_type_rcv',
                                       rec_rcv_data.transaction_type)); --����������
        output(cux_fnd_xml_utl.get_tag('transaction_date_rcv',
                                       to_char(rec_rcv_data.transaction_date,
                                               g_farmat))); --����������
        output(cux_fnd_xml_utl.get_tag('transact_qty_rcv',
                                       rec_rcv_data.transact_qty)); --����
        output(cux_fnd_xml_utl.get_tag('item_code_rcv',
                                       rec_rcv_data.item_code)); --����
        output(cux_fnd_xml_utl.get_tag('item_desc_rcv',
                                       rec_rcv_data.item_description)); --����˵��
        output(cux_fnd_xml_utl.get_tag('vendor_num_rcv',
                                       rec_rcv_data.vendor_num)); --��Ӧ�̱��
        output(cux_fnd_xml_utl.get_tag('vendor_name_rcv',
                                       rec_rcv_data.vendor_name)); --��Ӧ������
        output(cux_fnd_xml_utl.get_tag('order_num_rcv',
                                       rec_rcv_data.order_num)); --������
        output(cux_fnd_xml_utl.get_tag('transact_uom_rcv',
                                       rec_rcv_data.transact_uom)); --��λ
      
        output(cux_fnd_xml_utl.get_tag_end);
      
      END LOOP;
    
    END IF;
  
    output(cux_fnd_xml_utl.get_tag_end); ---header
    output(cux_fnd_xml_utl.get_tag_end); ---sheet
    --
    output(cux_fnd_xml_utl.get_tag_end); ---report
    output(cux_fnd_xml_utl.get_file_end);
  
    cux_conc_utl.log_footer;
  
    /*x_return_status := cux_api.end_activity(p_pkg_name  => g_pkg_name,
    p_api_name  => l_api_name,
    p_commit    => p_commit,
    x_msg_count => x_msg_count,
    x_msg_data  => x_msg_data);*/
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := cux_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                   p_api_name  => l_api_name,
                                                   p_exc_name  => cux_api.g_exc_name_error,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := cux_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                   p_api_name  => l_api_name,
                                                   p_exc_name  => cux_api.g_exc_name_unexp,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := cux_api.handle_exceptions(p_pkg_name  => g_pkg_name,
                                                   p_api_name  => l_api_name,
                                                   p_exc_name  => cux_api.g_exc_name_others,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data);
  END process_request_xml;

  /* =============================================
  *   PROCEDURE
  *   NAME :
  *       main
  *   DESCRIPTION: 
  *       �������
  *   ARGUMENT:
  *       
  *   RETURN: 
  *       
  *   HISTORY: 
  *     1.00   2018-04-20   Xu.Wei Creation
  * =============================================*/

  PROCEDURE main(errbuf        OUT VARCHAR2,
                 retcode       OUT VARCHAR2,
                 p_org_id      IN NUMBER, --org_id
                 p_report_type IN VARCHAR2, -- ��������
                 p_period_f    IN VARCHAR2, --�ڼ��
                 p_period_t    IN VARCHAR2, --�ڼ���
                 p_gl_date_f   IN VARCHAR2, --GL���ڴ�
                 p_gl_date_t   IN VARCHAR2, --GL������
                 p_account_f   IN NUMBER, --VARCHAR2, --�˻���
                 p_account_t   IN NUMBER, --VARCHAR2, --�˻���
                 p_batch_num   IN VARCHAR2 --�ռ�������
                 ) IS
    l_return_status   VARCHAR2(30);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_gl_date_f       DATE;
    l_gl_date_t       DATE;
    l_set_of_books_id NUMBER;
  
  BEGIN
    retcode := '0';
    cux_conc_utl.log_header;
  
    --���ڲ�������
    l_gl_date_f := fnd_conc_date.string_to_date(p_gl_date_f);
    l_gl_date_t := fnd_conc_date.string_to_date(p_gl_date_t);
    --���ݵ�ǰ��֯ȡ��Ӧ������
    l_set_of_books_id := get_set_of_books_id(p_org_id);
    --=============================================================
    --log
    log('p_org_id: ' || p_org_id);
    log('p_report_type: ' || p_report_type);
    log('p_period_f: ' || p_period_f);
    log('p_period_t: ' || p_period_t);
    log('p_gl_date_f: ' || l_gl_date_f);
    log('p_gl_date_t: ' || l_gl_date_t);
    log('p_account_f: ' || p_account_f);
    log('p_account_t: ' || p_account_t);
    log('p_batch_num: ' || p_batch_num);
    log('l_set_of_books_id: ' || l_set_of_books_id);
    --=============================================================
    process_request_xml(p_init_msg_list => fnd_api.g_true,
                        p_commit        => fnd_api.g_false,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        --
                        p_set_of_books_id => l_set_of_books_id,
                        p_report_type     => p_report_type,
                        p_period_f        => p_period_f,
                        p_period_t        => p_period_t,
                        p_gl_date_f       => l_gl_date_f,
                        p_gl_date_t       => l_gl_date_t,
                        p_account_f       => p_account_f,
                        p_account_t       => p_account_t,
                        p_batch_num       => p_batch_num);
  
    -- conc end body
    -- concurrent footer log
    cux_conc_utl.log_footer;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      cux_conc_utl.log_message_list;
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
      cux_conc_utl.log_message_list;
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
                              p_procedure_name => 'MAIN',
                              p_error_text     => substrb(SQLERRM,
                                                          1,
                                                          240));
      cux_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END main;

END cux_retrospect_sheet_rpt;
/
