CREATE OR REPLACE PACKAGE xxpjm_project_public IS

  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  * =================================================================
  *   PROGRAM NAME:
  *                xxpjm_project_public
  *   DESCRIPTION:
  *                PA:Project,Top Task,Task,Customer,Contact,Agreements API
  *   HISTORY:
  *     1.00  2012-03-08   ouzhiwei       Created
  *     v2.0  2014-09-04   jiaming.zhou   Updated
  * ===============================================================*/
  g_tab         VARCHAR2(1) := chr(9);
  g_change_line VARCHAR2(2) := chr(10);
  g_line        VARCHAR2(150) := rpad('=', 150, '=');

  g_last_update_date  DATE := SYSDATE;
  g_last_updated_by   NUMBER := fnd_global.user_id;
  g_creation_date     DATE := SYSDATE;
  g_created_by        NUMBER := fnd_global.user_id;
  g_last_update_login NUMBER := fnd_global.login_id;

  g_request_id       NUMBER := fnd_global.conc_request_id;
  g_session_id       NUMBER := userenv('sessionid');
  g_program_id       NUMBER := fnd_global.conc_program_id;
  g_program_appl_id  NUMBER := fnd_global.prog_appl_id;
  g_program_upd_date DATE := SYSDATE;
  g_appl_name        VARCHAR2(10) := 'XXPJM';

  g_ckd_design        VARCHAR2(30) := fnd_profile.value('XXPJM_CKD_DESIGN_PHASE');
  g_ckd_ba_di_process VARCHAR2(30) := fnd_profile.value('XXPJM_CKD_BA_DI_PROCESS_PHASE');
  g_ckd_purchasing    VARCHAR2(30) := fnd_profile.value('XXPJM_CKD_PURCHASING_PHASE');
  g_design_planning   VARCHAR2(30) := fnd_profile.value('XXPJM_DESIGN_PLANNING_PHASE');
  g_ba_di_process     VARCHAR2(30) := fnd_profile.value('XXPJM_BA_DI_PROCESS_PHASE');
  --add by jiaming.zhou v2.0 start
  g_ba_order_received VARCHAR2(30) := fnd_profile.value('XXPJM_BA_ORDER_RECEIVED_PHASE');
  --add by jiaming.zhou v2.0 end
  ---------------   
  g_packing                    VARCHAR2(30) := fnd_profile.value('XXPJM_PACKING_PHASE');
  g_inspection                 VARCHAR2(30) := fnd_profile.value('XXPJM_INSPECTION_PHASE');
  g_spec_finalization          VARCHAR2(30) := fnd_profile.value('XXPJM_SPEC_FINALIZATION_PHASE');
  g_purchasing                 VARCHAR2(30) := fnd_profile.value('XXPJM_PURCHASING_PHASE');
  g_billing                    VARCHAR2(30) := fnd_profile.value('XXPJM_BILLING_PHASE');
  g_shipping                   VARCHAR2(30) := fnd_profile.value('XXPJM_SHIPPING_PHASE');
  g_production                 VARCHAR2(30) := fnd_profile.value('XXPJM_PRODUCTION_PHASE');
  g_warranty                   VARCHAR2(30) := fnd_profile.value('XXPJM_WARRANTY_PHASE');
  g_installation               VARCHAR2(30) := fnd_profile.value('XXPJM_INSTALLATION_PHASE');
  g_design                     VARCHAR2(30) := fnd_profile.value('XXPJM_DESIGN_PHASE');
  g_er_expense_budget_type     VARCHAR2(30) := 'EXPENSE';
  g_er_labor_budget_type       VARCHAR2(30) := 'LABOR';
  g_er_material_budget_type    VARCHAR2(30) := 'MATERIAL';
  g_er_subcontract_budget_type VARCHAR2(30) := 'SUBCONTRACTING';
  g_eq_cost_type               VARCHAR2(30) := 'EQ COST';
  
  
  -- Operating Units
  g_hea_org_id        NUMBER := fnd_profile.value('XXPJM_HEA_ORG_ID');
  
  FUNCTION get_project_id(p_project_number IN VARCHAR2) RETURN NUMBER;
  FUNCTION get_task_id(p_project_id IN NUMBER, p_task_number IN VARCHAR2)
    RETURN NUMBER;
  /*==================================================
  Program Name:
      project_process
  Description:
      project generation
  History:
      1.00  2012/2/27 17:17:57  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE project_process(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_temp_type     IN xxpjm_proj_generation_int%ROWTYPE);
                            
  PROCEDURE project_process2(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_temp_type     IN xxpjm_proj_generation_int%ROWTYPE);
                            
  FUNCTION check_mfg_isnot_exists(p_project_id IN NUMBER,
                                  p_mfg_nubmer IN VARCHAR2) RETURN NUMBER;
  PROCEDURE get_projcet_customer_info(p_project_id            IN NUMBER,
                                      p_customer_id           IN NUMBER,
                                      x_bill_to_address_id    OUT NUMBER,
                                      x_ship_to_address_id    OUT NUMBER,
                                      x_contribution          OUT NUMBER,
                                      x_relationship          OUT VARCHAR2,
                                      x_inv_currency_code     OUT VARCHAR2,
                                      x_inv_rate_type         OUT VARCHAR2,
                                      x_record_version_number OUT VARCHAR2,
                                      x_return_status         OUT VARCHAR2,
                                      x_msg_count             OUT NUMBER,
                                      x_msg_data              OUT VARCHAR2);
  FUNCTION get_cust_addr_id(p_site_use_id   IN NUMBER,
                            p_site_use_code IN VARCHAR2) RETURN NUMBER;
  /*==================================================
  Program Name:
      update_project_customer_process
  Description:
      when so 
  History:
      1.00  2012/2/27 17:17:57  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE update_proj_customer_process(p_project_id         IN NUMBER,
                                         p_old_customer_id    IN NUMBER,
                                         p_new_customer_id    IN NUMBER,
                                         p_bill_to_address_id IN NUMBER,
                                         p_ship_to_address_id IN NUMBER,
                                         p_inv_currency_code  IN VARCHAR2,
                                         p_org_id             IN NUMBER,
                                         p_add_flag           IN VARCHAR2,
                                         x_return_status      OUT NOCOPY VARCHAR2,
                                         x_msg_count          OUT NOCOPY NUMBER,
                                         x_msg_data           OUT NOCOPY VARCHAR2);
  FUNCTION get_latest_wp_version(p_task_id IN NUMBER) RETURN NUMBER;
  PROCEDURE GET_LAST_TOP_TASK_INFO(P_PROJECT_ID           IN NUMBER,
                                   P_TEMP_TOP_TASK_NUMBER IN VARCHAR2,
                                   X_TOP_TASK_ID          OUT PA_TASKS.TOP_TASK_ID%TYPE,
                                   X_TASK_VERSION_ID      OUT NOCOPY PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE,
                                   X_STRUCTURE_VERSION_ID OUT NOCOPY PA_PROJ_ELEMENT_VERSIONS.PARENT_STRUCTURE_VERSION_ID%TYPE,
                                   X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
                                   X_MSG_DATA             OUT NOCOPY VARCHAR2);
  FUNCTION get_current_working_ver_id(p_task_id IN NUMBER) RETURN NUMBER;

  /*==================================================
  Program Name:
      update_schedule
  Description:
      update schedule
  History:
      1.00  2012/5/30 10:15:57  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE update_schedule(P_PROJECT_ID            IN NUMBER,
                            P_TOP_TASK_ID           IN NUMBER,
                            P_SOURCE                IN VARCHAR2,
                            P_MARKET                IN VARCHAR2,
                            P_MODEL                 IN VARCHAR2,
                            p_lt_model              IN VARCHAR2 := NULL,
                            P_PARTIAL_DELIVERY_DATE IN DATE,
                            P_FINAL_DELIVERY_DATE   IN DATE,
                            X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT             OUT NOCOPY NUMBER,
                            X_MSG_DATA              OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      get_new_task_number
  Description:
      get new task number
  History:
      1.00  2012/2/29 13:45:30  ouzhiwei  Creation
  ==================================================*/
  FUNCTION get_new_task_number(p_parent_task_id NUMBER) RETURN VARCHAR2;
  
  
  /*==================================================
  Program Name:
      cleanup
  Description:
      cleanup
  History:
      1.00  2012/12/11 04:16:30  jundong.wu  Creation
  ==================================================*/
  PROCEDURE cleanup(p_project_id     IN   NUMBER,
                    x_return_status  OUT  VARCHAR2,
                    x_msg_count      OUT  NUMBER,
                    x_msg_data       OUT  VARCHAR2);
  
    
END xxpjm_project_public;
/
CREATE OR REPLACE PACKAGE BODY xxpjm_project_public IS
  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  * =================================================================
  *   PROGRAM NAME:
  *                xxpjm_project_public
  *   DESCRIPTION:
  *                PA:Project,Top Task,Task,Customer,Contact,Agreements API
  *   HISTORY:
  *     1.00  2012-03-08   ouzhiwei       Created
  *       2014-09-04   jiaming.zhou   Updated
  * ===============================================================*/


  -- Debug Enabled
  l_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
  PROCEDURE raise_exception(p_return_status VARCHAR2) IS
  BEGIN
    IF (p_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (p_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END raise_exception;

  --log
  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, REPLACE(p_content, chr(0), ' '));
  END log;

  PROCEDURE log_time(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log,
                      REPLACE(p_content || ' time:' ||
                              to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'),
                              chr(0),
                              ' '));
  END log_time;
  FUNCTION get_message(p_appl_name    IN VARCHAR2,
                       p_message_name IN VARCHAR2,
                       p_token1       IN VARCHAR2 DEFAULT NULL,
                       p_token1_value IN VARCHAR2 DEFAULT NULL,
                       p_token2       IN VARCHAR2 DEFAULT NULL,
                       p_token2_value IN VARCHAR2 DEFAULT NULL,
                       p_token3       IN VARCHAR2 DEFAULT NULL,
                       p_token3_value IN VARCHAR2 DEFAULT NULL,
                       p_token4       IN VARCHAR2 DEFAULT NULL,
                       p_token4_value IN VARCHAR2 DEFAULT NULL,
                       p_token5       IN VARCHAR2 DEFAULT NULL,
                       p_token5_value IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS
  BEGIN
    fnd_message.clear;
    fnd_message.set_name(p_appl_name, p_message_name);
  
    IF p_token1 IS NOT NULL THEN
      fnd_message.set_token(p_token1, p_token1_value);
    END IF;
    IF p_token2 IS NOT NULL THEN
      fnd_message.set_token(p_token2, p_token2_value);
    END IF;
    IF p_token3 IS NOT NULL THEN
      fnd_message.set_token(p_token3, p_token3_value);
    END IF;
    IF p_token4 IS NOT NULL THEN
      fnd_message.set_token(p_token4, p_token4_value);
    END IF;
    IF p_token5 IS NOT NULL THEN
      fnd_message.set_token(p_token5, p_token5_value);
    END IF;
  
    RETURN fnd_message.get;
  END get_message;

  FUNCTION check_proj_customer_exists(p_project_id  IN NUMBER,
                                      p_customer_id IN NUMBER)
    RETURN VARCHAR2 AS
    l_valid_flag VARCHAR2(1);
  BEGIN
    SELECT 'Y'
      INTO l_valid_flag
      FROM pa.pa_project_customers ppc
     WHERE ppc.project_id = p_project_id
       AND ppc.customer_id = p_customer_id;
    RETURN l_valid_flag;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;
  FUNCTION get_cust_addr_id(p_site_use_id   IN NUMBER,
                            p_site_use_code IN VARCHAR2) RETURN NUMBER IS
    l_cust_acct_site_id hz_cust_site_uses_all.cust_acct_site_id%TYPE;
    CURSOR cur_acct IS
      SELECT hcs.cust_acct_site_id
        FROM hz_cust_site_uses_all hcs
       WHERE hcs.site_use_id = p_site_use_id
         AND hcs.status = 'A'
         AND hcs.site_use_code = p_site_use_code;
  BEGIN
    OPEN cur_acct;
    FETCH cur_acct
      INTO l_cust_acct_site_id;
    CLOSE cur_acct;
    RETURN l_cust_acct_site_id;
  END;

  FUNCTION ger_project_manager_id(p_project_id IN NUMBER) RETURN NUMBER IS
    CURSOR cur_person IS
      SELECT ppp.person_id
        FROM pa_project_players ppp
       WHERE ppp.project_role_type = 'PROJECT MANAGER'
         AND trunc(SYSDATE) BETWEEN trunc(ppp.start_date_active) AND
             nvl(trunc(end_date_active), trunc(SYSDATE))
         AND project_id = p_project_id;
    l_person_id pa_project_players.person_id%TYPE;
  BEGIN
    OPEN cur_person;
    FETCH cur_person
      INTO l_person_id;
    CLOSE cur_person;
    RETURN l_person_id;
  END;

  PROCEDURE get_projcet_customer_info(p_project_id            IN NUMBER,
                                      p_customer_id           IN NUMBER,
                                      x_bill_to_address_id    OUT NUMBER,
                                      x_ship_to_address_id    OUT NUMBER,
                                      x_contribution          OUT NUMBER,
                                      x_relationship          OUT VARCHAR2,
                                      x_inv_currency_code     OUT VARCHAR2,
                                      x_inv_rate_type         OUT VARCHAR2,
                                      x_record_version_number OUT VARCHAR2,
                                      x_return_status         OUT VARCHAR2,
                                      x_msg_count             OUT NUMBER,
                                      x_msg_data              OUT VARCHAR2) IS
    CURSOR cur_pa_customer IS
      SELECT ppc.bill_to_address_id,
             ppc.ship_to_address_id,
             ppc.customer_bill_split,
             ppc.project_relationship_code,
             
             ppc.inv_currency_code,
             ppc.inv_rate_type,
             ppc.record_version_number
        FROM pa.pa_project_customers ppc
       WHERE ppc.project_id = p_project_id
         AND ppc.customer_id = p_customer_id;
  BEGIN
    OPEN cur_pa_customer;
    FETCH cur_pa_customer
      INTO x_bill_to_address_id,
           x_ship_to_address_id,
           x_contribution,
           x_relationship,
           x_inv_currency_code,
           x_inv_rate_type,
           x_record_version_number;
    CLOSE cur_pa_customer;
  END get_projcet_customer_info;

  PROCEDURE get_project_template_info(p_sales_type_id        IN NUMBER,
                                      p_sales_line_type_id   IN NUMBER,
                                      x_project_id           OUT NOCOPY NUMBER,
                                      x_top_task_id          OUT NOCOPY NUMBER,
                                      x_top_task_number      OUT NOCOPY VARCHAR2,
                                      x_task_version_id      OUT NOCOPY NUMBER,
                                      x_structure_version_id OUT NOCOPY NUMBER,
                                      x_return_status        OUT NOCOPY VARCHAR2,
                                      x_msg_data             OUT NOCOPY VARCHAR2) IS
    CURSOR cur_project(p_project_id pa_projects_all.project_id%TYPE) IS
      SELECT pa.segment1
        FROM pa_projects_all pa
       WHERE pa.project_id = p_project_id;
    CURSOR cur_so_order_type IS
      SELECT ott.attribute4
        FROM oe_transaction_types_all ott
       WHERE ott.transaction_type_id = p_sales_type_id;
    CURSOR cur_task(p_project_id NUMBER) IS
      SELECT pt.top_task_id,
             pev.element_version_id,
             pev.parent_structure_version_id,
             pt.task_number
        FROM pa_tasks pt, pa_proj_element_versions pev
       WHERE pt.project_id = p_project_id
         AND pt.project_id = pev.project_id
         AND pt.task_id = pev.proj_element_id
         AND pt.task_id = pt.top_task_id
         AND pev.object_type = 'PA_TASKS'
         AND pt.attribute7 = p_sales_line_type_id --SALES LINE TYPE
         AND pev.parent_structure_version_id =
             nvl(pa_project_structure_utils.get_latest_wp_version(pev.project_id),
                 pa_project_structure_utils.get_current_working_ver_id(pev.project_id));
    l_project_number pa_projects_all.segment1%TYPE;
  BEGIN
    x_return_status := xxpjm_proj_generation_pkg.g_success;
    --get project template
    OPEN cur_so_order_type;
    FETCH cur_so_order_type
      INTO x_project_id;
    IF cur_so_order_type%NOTFOUND THEN
      CLOSE cur_so_order_type;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := get_message(g_appl_name, 'XXPJM_004E_018');
      RETURN;
    END IF;
    CLOSE cur_so_order_type;
    /* BEGIN
      SELECT t.meaning
        INTO l_project_no
        FROM xxpjm_lookups t
       WHERE t.lookup_type = 'XXPJM_TEMPLATE_PROJECT'
         AND t.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN
             nvl(t.start_date_active, trunc(SYSDATE)) AND
             nvl(t.end_date_active, trunc(SYSDATE))
         AND t.lookup_code = p_ou_name;
    EXCEPTION
      WHEN too_many_rows THEN
        --message
        --  fnd_api.g_exc_error;
        x_return_status := xxpjm_proj_generation_pkg.g_error;
      WHEN no_data_found THEN
        --message
        x_return_status := xxpjm_proj_generation_pkg.g_error;
      WHEN OTHERS THEN
        --message    
        x_return_status := xxpjm_proj_generation_pkg.g_error;
    END;*/
    log('template_proj_id:' || x_project_id);
    --get task info
    OPEN cur_task(x_project_id);
    FETCH cur_task
      INTO x_top_task_id,
           x_task_version_id,
           x_structure_version_id,
           x_top_task_number;
    IF cur_task%NOTFOUND THEN
      CLOSE cur_task;
      x_return_status := fnd_api.g_ret_sts_error;
      OPEN cur_project(x_project_id);
      FETCH cur_project
        INTO l_project_number;
      CLOSE cur_project;
      x_msg_data := get_message(g_appl_name,
                                'XXPJM_004E_028',
                                'PROJECT_NUMBER',
                                l_project_number);
      RETURN;
    END IF;
    CLOSE cur_task;
  END get_project_template_info;

  FUNCTION get_current_working_ver_id(p_task_id IN NUMBER) RETURN NUMBER AS
    CURSOR cur_task_ver IS
      SELECT pev.element_version_id
        FROM pa_proj_element_versions pev
       WHERE pev.proj_element_id = p_task_id
         AND pev.object_type = 'PA_TASKS'
         AND pev.parent_structure_version_id =
             pa_project_structure_utils.get_current_working_ver_id(pev.project_id);
    l_tast_version_id NUMBER;
  BEGIN
    OPEN cur_task_ver;
    FETCH cur_task_ver
      INTO l_tast_version_id;
    CLOSE cur_task_ver;
    RETURN l_tast_version_id;
  END;

  FUNCTION get_latest_wp_version(p_task_id IN NUMBER) RETURN NUMBER AS
    CURSOR cur_task_ver IS
      SELECT pev.element_version_id
        FROM pa_proj_element_versions pev
       WHERE pev.proj_element_id = p_task_id
         AND pev.object_type = 'PA_TASKS'
         AND pev.parent_structure_version_id =
             pa_project_structure_utils.get_latest_wp_version(pev.project_id);
    l_tast_version_id NUMBER;
  BEGIN
    OPEN cur_task_ver;
    FETCH cur_task_ver
      INTO l_tast_version_id;
    CLOSE cur_task_ver;
    RETURN l_tast_version_id;
  END;

  PROCEDURE get_last_top_task_info(p_project_id           IN NUMBER,
                                   p_temp_top_task_number IN VARCHAR2,
                                   x_top_task_id          OUT pa_tasks.top_task_id%TYPE,
                                   x_task_version_id      OUT NOCOPY pa_proj_element_versions.element_version_id%TYPE,
                                   x_structure_version_id OUT NOCOPY pa_proj_element_versions.parent_structure_version_id%TYPE,
                                   x_return_status        OUT NOCOPY VARCHAR2,
                                   x_msg_data             OUT NOCOPY VARCHAR2) IS
    CURSOR cur_task IS
      SELECT pt.top_task_id,
             pev.element_version_id,
             pev.parent_structure_version_id
        FROM pa_tasks pt, pa_proj_element_versions pev
       WHERE pt.project_id = p_project_id
         AND pt.project_id = pev.project_id
         AND pt.task_id = pev.proj_element_id
         AND pt.task_id = pt.top_task_id
         AND pev.object_type = 'PA_TASKS'
         AND pev.parent_structure_version_id =
             pa_project_structure_utils.get_current_working_ver_id(pev.project_id)
         AND pt.task_number = nvl(p_temp_top_task_number, pt.task_number)
       ORDER BY pt.top_task_id DESC;
    l_template_id pa_projects_all.project_id%TYPE;
    l_project_no  pa_projects_all.segment1%TYPE;
  BEGIN
    x_return_status := xxpjm_proj_generation_pkg.g_success;
    --get task info
    OPEN cur_task;
    FETCH cur_task
      INTO x_top_task_id, x_task_version_id, x_structure_version_id;
    CLOSE cur_task;
  END get_last_top_task_info;

  FUNCTION get_project_id(p_project_number IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_project IS
      SELECT pa.project_id
        FROM pa_projects_all pa
       WHERE pa.segment1 = p_project_number;
    l_project_id pa_projects.project_id%TYPE;
  BEGIN
    OPEN cur_project;
    FETCH cur_project
      INTO l_project_id;
    CLOSE cur_project;
    RETURN l_project_id;
  END get_project_id;
  
  FUNCTION check_install3(p_task_id  NUMBER)
    RETURN VARCHAR2
  IS
    CURSOR cur_task
    IS
      SELECT 'Y'
        FROM pa_tasks pt,
             pa_tasks ptt
       WHERE pt.task_id        = p_task_id
         AND pt.parent_task_id = ptt.task_id
         AND ptt.attribute3    = 'Installation'
         AND pt.wbs_level      = 3;
         
    l_wbs_level  VARCHAR2(100);
  BEGIN
    OPEN  cur_task;
    FETCH cur_task
    INTO  l_wbs_level;
    CLOSE cur_task;
    
    IF l_wbs_level IS NOT NULL THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;

  FUNCTION check_mfg_isnot_exists(p_project_id IN NUMBER,
                                  p_mfg_nubmer IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_task IS
      SELECT pt.task_id
        FROM pa_tasks pt
       WHERE pt.task_number = p_mfg_nubmer
         AND pt.project_id = p_project_id
         AND pt.top_task_id = pt.task_id;
    l_task_id pa_tasks.task_id%TYPE;
  BEGIN
    OPEN cur_task;
    FETCH cur_task
      INTO l_task_id;
    CLOSE cur_task;
    RETURN l_task_id;
  END check_mfg_isnot_exists;

  FUNCTION get_task_id(p_project_id IN NUMBER, p_task_number IN VARCHAR2)
    RETURN NUMBER IS
    CURSOR cur_task IS
      SELECT pt.task_id
        FROM pa_tasks pt
       WHERE pt.project_id = p_project_id
         AND pt.task_number = p_task_number;
    l_task_id pa_tasks.task_id%TYPE;
  BEGIN
    OPEN cur_task;
    FETCH cur_task
      INTO l_task_id;
    CLOSE cur_task;
    RETURN l_task_id;
  END get_task_id;

  /*==================================================
  Program Name:
      get_new_task_number
  Description:
      get new task number
  History:
      1.00  2012/2/29 13:45:30  ouzhiwei  Creation
  ==================================================*/
  FUNCTION get_new_task_number(p_parent_task_id NUMBER) RETURN VARCHAR2 IS
    l_parent_task_no pa_proj_elements.element_number%TYPE;
    l_child_exists   NUMBER;
    /*CURSOR cur_parent_task IS
    SELECT MAX(t.task_number) task_number
      FROM pa_tasks t
     WHERE task_id = p_parent_task_id;*/
  
    /*CURSOR cur_task IS
    SELECT MAX( to_number(substr(t.task_number,
                          instr(t.task_number, '.', -1) + 1) ) )
      FROM pa_tasks t
     WHERE parent_task_id = p_parent_task_id;  */
    CURSOR cur_project IS
      SELECT project_id
        FROM pa_proj_elements t
       WHERE t.proj_element_id = p_parent_task_id;
    CURSOR cur_task(p_project_id NUMBER, p_parent_task_no VARCHAR2) IS
      SELECT MAX(to_number(substr(t.element_number,
                                  instr(t.element_number, '.', -1) + 1)))
        FROM pa_proj_elements t
       WHERE element_number LIKE p_parent_task_no || '.%'
         AND project_id = p_project_id;
  
    l_task_number pa_proj_elements.element_number%TYPE;
    l_str_front   VARCHAR2(240);
    l_num_behind  NUMBER;
    l_location    NUMBER;
    l_project_id  NUMBER;
  BEGIN
  
    log('/****************BEGIN get_new_task_number****************/');
    log('p_parent_task_id: ' || p_parent_task_id);
  
    --get project_id 
    OPEN cur_project;
    FETCH cur_project
      INTO l_project_id;
    CLOSE cur_project;
    --get parent task  number
    l_parent_task_no := pa_task_utils.get_task_number(p_parent_task_id);
    --check child exists
    --l_child_exists := pa_task_utils.check_child_exists(p_parent_task_id);
    --if  exist
    /* IF l_child_exists = 1 THEN*/
    /* --get parent task number 
    OPEN cur_parent_task;
    FETCH cur_parent_task
      INTO l_parent_task_no;
    close cur_parent_task; */
    --get max child task task number 
    log('l_project_id:     ' || l_project_id);
    log('l_parent_task_no: ' || l_parent_task_no);
   
    
    BEGIN
      OPEN cur_task(l_project_id, l_parent_task_no);
      FETCH cur_task
        INTO l_num_behind;
      l_num_behind := NVL(l_num_behind, 0);
      CLOSE cur_task;
      log('l_num_behind:' || l_num_behind);
      l_num_behind := l_num_behind + 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_num_behind := 1;
        IF cur_task%ISOPEN THEN
          CLOSE cur_task;
        END IF;
    END;
    l_task_number := l_parent_task_no || '.' || l_num_behind;
    --cut out  last '.' and get number after last '.'
    /*  BEGIN*/
    /*l_location := instr(l_max_task_no, '.', -1);
    IF l_location = 0 THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    l_str_front   := substr(l_max_task_no, 1, l_location - 1);
    l_num_behind  := substr(l_max_task_no, l_location + 1);
    l_num_behind  := l_num_behind + 1;
    l_task_number := l_str_front || '.' || l_num_behind;*/
  
    /*   EXCEPTION
    WHEN OTHERS THEN
      l_task_number := l_parent_task_no || '.1';*/
    /* END;*/
    /*ELSE
      l_task_number := l_parent_task_no || '.1';
    END IF;*/
  
    log('l_task_number:' || l_task_number);
    
    log('/****************END get_new_task_number****************/');
    
    RETURN(l_task_number);
  END get_new_task_number;

  /*==================================================
  Program Name:
      get_resource_list_member_id
  Description:
      get resource list member id
  History:
      1.00  2012/2/29 16:26:19  ouzhiwei  Creation
  ==================================================*/
  FUNCTION get_resource_list_member_id(p_loading_plan_id NUMBER)
    RETURN NUMBER IS
    l_resource_list_member_id NUMBER;
  BEGIN
    SELECT rlm.resource_list_member_id
      INTO l_resource_list_member_id
      FROM pa_resource_list_members rlm,
           bom_department_resources bdr,
           bom_departments          bd,
           xxpjm_loading_plan_all   plp
     WHERE bdr.department_id = bd.department_id
       AND rlm.bom_resource_id = bdr.resource_id
       AND bdr.department_id = plp.phase
       AND bdr.resource_id = plp.loadplan_task
       AND plp.loading_plan_id = p_loading_plan_id;
    RETURN l_resource_list_member_id;
  EXCEPTION
    WHEN no_data_found THEN
      --MESSAGE
      RETURN NULL;
    WHEN too_many_rows THEN
      --message
      RETURN NULL;
    WHEN OTHERS THEN
      --message
      RETURN NULL;
    
  END get_resource_list_member_id;
  

  /*==================================================
  Program Name:
      update_schedule
  Description:
      update schedule
  History:
      1.00  2012/5/30 10:15:57  ouzhiwei  Creation
  ==================================================*/

  PROCEDURE update_schedule(p_project_id            IN NUMBER,
                            p_top_task_id           IN NUMBER,
                            p_source                IN VARCHAR2,
                            p_market                IN VARCHAR2,
                            p_model                 IN VARCHAR2,
                            p_lt_model              IN VARCHAR2 := NULL,
                            p_partial_delivery_date IN DATE,
                            p_final_delivery_date   IN DATE,
                            x_return_status         OUT NOCOPY VARCHAR2,
                            x_msg_count             OUT NOCOPY NUMBER,
                            x_msg_data              OUT NOCOPY VARCHAR2) AS
    CURSOR cur_parts_task IS
      SELECT xtd.element_number task_number,
             xtd.name           task_name,
             xtd.task_id        part_task_id,
             xtd.part_task,
             pt.task_id,
             pt.top_task_id,
             pt.project_id
        FROM xxpjm_task_dtls_v xtd, pa_tasks pt
       WHERE parent_structure_version_id =
             pa_project_structure_utils.get_current_working_ver_id(xtd.project_id)
         AND pt.task_id = xtd.parent_task_id
         AND pt.attribute3 = fnd_profile.value('XXPJM_SHIPPING_PHASE')
         AND pt.project_id = xtd.project_id
         AND pt.top_task_id = p_top_task_id
         AND xtd.part_task IS NOT NULL;
    x_schedule_start_date DATE;
    x_schedule_end_date   DATE;
    x_row_id              VARCHAR2(30);
    x_unique_id           NUMBER;
    /*L_MAKE                 VARCHAR2(30) := 'MAKE';
    L_MIX_ORGINAL          VARCHAR2(30) := 'MIXED-ORINAL';*/
    l_lookup_schedule_make VARCHAR2(30) := 'XXPJM_PARTS_SCHEDULE_MAKE';
    l_lookup_schedule_mix  VARCHAR2(30) := 'XXPJM_PARTS_SCHEDULE_MIX';
    l_lookup_type          fnd_lookup_values_vl.lookup_type%TYPE;
    l_delivery_date        DATE;
    FUNCTION check_lookup_code_valid(p_lookup_type VARCHAR2,
                                     
                                     p_lookup_code VARCHAR2) RETURN VARCHAR2 AS
      CURSOR cur_lookup IS
        SELECT 'Y'
          FROM fnd_lookup_values_vl flv
         WHERE flv.lookup_type = p_lookup_type
           AND flv.lookup_code = p_lookup_code
           AND flv.enabled_flag = 'Y'
           AND trunc(SYSDATE) BETWEEN
               nvl(flv.start_date_active, trunc(SYSDATE)) AND
               nvl(flv.end_date_active, trunc(SYSDATE));
      l_valid_flag VARCHAR2(1);
    BEGIN
      OPEN cur_lookup;
      FETCH cur_lookup
        INTO l_valid_flag;
      CLOSE cur_lookup;
      RETURN l_valid_flag;
    END;
  BEGIN
  
    /*IF P_SOURCE = xxinv_item_imp_pub.g_source_make THEN
       L_LOOKUP_TYPE := L_LOOKUP_SCHEDULE_MAKE;
     ELSIF UPPER(P_SOURCE) = UPPER(xxinv_item_imp_pub.g_source_mixed) THEN
       L_LOOKUP_TYPE := L_LOOKUP_SCHEDULE_MIX;
     ELSE
       RETURN;
     END IF;
     IF P_PARTIAL_DELIVERY_DATE IS NULL AND P_FINAL_DELIVERY_DATE IS NULL THEN
       X_MSG_DATA := 'procedure update_schedule  P_Partial_Delivery_Date and P_Final_Delivery_Date is null.';
       LOG(X_MSG_DATA);
       --X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;
    
    FOR REC_PARTS_TASK IN CUR_PARTS_TASK LOOP
     
       IF CHECK_LOOKUP_CODE_VALID(L_LOOKUP_TYPE, REC_PARTS_TASK.PART_TASK) = 'Y' THEN
         L_DELIVERY_DATE := P_PARTIAL_DELIVERY_DATE;
       ELSE
         L_DELIVERY_DATE := P_FINAL_DELIVERY_DATE;
       END IF;
       IF L_DELIVERY_DATE IS NULL THEN
         log('L_DELIVERY_DATE is null,please check!');
         GOTO PROGRAM_END;
       END IF;
       --init xxpjm_task_scheduled_pkg global variable for goe so/vo interface 
       XXPJM_TASK_SCHEDULED_PKG.INIT(P_MARKET        => P_MARKET,
                                     P_MODEL         => P_MODEL,
                                     P_DELIVERY_DATE => L_DELIVERY_DATE);
       log('L_DELIVERY_DATE:' || L_DELIVERY_DATE);
       log('REC_PARTS_TASK.PART_TASK_ID:' || REC_PARTS_TASK.PART_TASK_ID);
       LOG('begin calling procedure xxpjm_task_scheduled_pkg.get_phase_part_schedule_date');
       XXPJM_TASK_SCHEDULED_PKG.GET_PHASE_PART_SCHEDULE_DATE(P_TASK_ID             => REC_PARTS_TASK.PART_TASK_ID,
                                                             P_DELIVERY_DATE       => L_DELIVERY_DATE,
                                                             X_SCHEDULE_START_DATE => X_SCHEDULE_START_DATE,
                                                             X_SCHEDULE_END_DATE   => X_SCHEDULE_END_DATE,
                                                             X_RETURN_STATUS       => X_RETURN_STATUS,
                                                             X_MSG_DATA            => X_MSG_DATA);
       LOG('end calling procedure xxpjm_task_scheduled_pkg.get_phase_part_schedule_date');
       IF NVL(X_RETURN_STATUS, FND_API.G_RET_STS_SUCCESS) <>
          FND_API.G_RET_STS_SUCCESS THEN
         EXIT;
       END IF;
       IF X_SCHEDULE_START_DATE IS NULL THEN
         --x_return_status := fnd_api.g_ret_sts_error;
         GOTO PROGRAM_END;
         LOG('procedure update_schedule  get schedule start date return null.');
         -- EXIT;
       END IF;
       X_ROW_ID    := NULL;
       X_UNIQUE_ID := NULL;
       LOG('begin calling procedure xxpjm_schedule_update_temp_pkg.insert_row');
       XXPJM_SCHEDULE_UPDATE_TEMP_PKG.INSERT_ROW(X_ROW_ID                => X_ROW_ID,
                                                 P_GROUP_ID              => G_SESSION_ID,
                                                 X_UNIQUE_ID             => X_UNIQUE_ID,
                                                 P_PROJECT_ID            => REC_PARTS_TASK.PROJECT_ID,
                                                 P_TOP_TASK_ID           => REC_PARTS_TASK.TOP_TASK_ID,
                                                 P_TASK_ID               => REC_PARTS_TASK.TASK_ID,
                                                 P_PART_TASK_ID          => REC_PARTS_TASK.PART_TASK_ID,
                                                 P_SCHEDULE_START_DATE   => X_SCHEDULE_START_DATE,
                                                 P_SCHEDULE_END_DATE     => L_DELIVERY_DATE,
                                                 P_OBJECT_VERSION_NUMBER => 1,
                                                 P_CREATION_DATE         => SYSDATE,
                                                 P_CREATED_BY            => G_CREATED_BY,
                                                 P_LAST_UPDATED_BY       => G_LAST_UPDATED_BY,
                                                 P_LAST_UPDATE_DATE      => SYSDATE,
                                                 P_LAST_UPDATE_LOGIN     => G_LAST_UPDATE_LOGIN);
       LOG('end calling procedure xxpjm_schedule_update_temp_pkg.insert_row');
       LOG('begin calling procedure xxpjm_task_scheduled_pkg.process_request');
       XXPJM_TASK_SCHEDULED_PKG.PROCESS_REQUEST(X_RETURN_STATUS => X_RETURN_STATUS,
                                                X_MSG_COUNT     => X_MSG_COUNT,
                                                X_MSG_DATA      => X_MSG_DATA,
                                                P_GROUP_ID      => G_SESSION_ID);
       LOG('end calling procedure xxpjm_task_scheduled_pkg.process_request');
       IF NVL(X_RETURN_STATUS, FND_API.G_RET_STS_SUCCESS) <>
          FND_API.G_RET_STS_SUCCESS THEN
         EXIT;
       END IF;
       <<PROGRAM_END>>
       NULL;
     END LOOP;*/
  
    xxpjm_task_scheduled_pkg.process_request_mfg(x_return_status         => x_return_status,
                                                 x_msg_count             => x_msg_count,
                                                 x_msg_data              => x_msg_data,
                                                 p_project_id            => p_project_id,
                                                 p_top_task_id           => p_top_task_id,
                                                 p_source                => p_source,
                                                 p_market                => p_market,
                                                 p_model                 => p_model,
                                                 p_lt_model              => p_lt_model,
                                                 p_partial_delivery_date => p_partial_delivery_date,
                                                 p_final_delivery_date   => p_final_delivery_date);
  
  END;
  /*==================================================
  Program Name:
      update_structure_name
  Description:
      update Structure name with pev structure id 
      for publish too many times cause structure name length more then it's length
  History:
      1.00  2012/7/24 15:08:00  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE update_structure_name(p_project_id    IN NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2) AS
    CURSOR cur_stru IS
      SELECT pev_structure_id, record_version_number
        FROM pa_proj_elem_ver_structure
       WHERE element_version_id =
             pa_project_structure_utils.get_current_working_ver_id(p_project_id);
    l_pev_structure_id       NUMBER;
    l_record_version_number  NUMBER;
    l_structure_version_name pa_proj_elem_ver_structure.name%TYPE;
  BEGIN
    OPEN cur_stru;
    FETCH cur_stru
      INTO l_pev_structure_id, l_record_version_number;
    CLOSE cur_stru;
    IF l_pev_structure_id IS NULL THEN
      x_msg_data := 'Can not get pev_structure_id,please check parameter when calling procedure Update_Structure_Version_Attr.';
      RETURN;
    END IF;
  
    l_structure_version_name := to_char(SYSDATE, 'YYYYMMDDHH24MISS');
    xxpa_proj_public_pvt.update_structure_version_attr(p_pev_structure_id       => l_pev_structure_id,
                                                       p_structure_version_name => l_structure_version_name,
                                                       p_record_version_number  => l_record_version_number,
                                                       x_return_status          => x_return_status,
                                                       x_msg_count              => x_msg_count,
                                                       x_msg_data               => x_msg_data);
  END;

  /*==================================================
  Program Name:
      project_process
  Description:
      project generation
  History:
      1.00  2012/2/27 17:17:57  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE project_process(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_temp_type     IN xxpjm_proj_generation_int%ROWTYPE) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'project_process';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    l_errbuf                    VARCHAR2(4000);
    l_retcode                   VARCHAR2(4000);
    l_proj_template_id          NUMBER;
    x_project_id                pa_projects_all.project_id%TYPE;
    x_new_project_number        pa_projects_all.segment1%TYPE;
    x_top_task_id               pa_tasks.top_task_id%TYPE;
    x_src_task_version_id       NUMBER;
    x_src_structure_version_id  NUMBER;
    x_dest_task_version_id      NUMBER;
    x_dest_structure_version_id NUMBER;
    l_employee_id               NUMBER;
    
    l_msg_data                  VARCHAR2(240);
  
    CURSOR cur_task(p_project_id NUMBER, p_top_task_id NUMBER) IS
    --delete phase      
      SELECT pt.task_id
        FROM pa_tasks pt
       WHERE pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND EXISTS
       (SELECT 1
                FROM xxpjm_stype_wbs_relationshp_v swr
               WHERE NVL(upper(swr.supply_scope_name),
                         xxfnd_const.null_char) =
                     NVL(upper(p_temp_type.source),
                         xxfnd_const.null_char)
                 AND swr.sales_type_id = p_temp_type.sales_line_type_id
                 AND NVL(swr.sales_scope_name,
                         xxfnd_const.null_char) = NVL(p_temp_type.market, xxfnd_const.null_char)
                 AND swr.org_id = p_temp_type.org_id
                 AND ((pt.attribute3 = g_packing AND
                      nvl(swr.phase_packing, 'N') = 'N') OR
                      (pt.attribute3 = g_inspection AND
                      nvl(swr.phase_inspection, 'N') = 'N') OR
                      (pt.attribute3 = g_spec_finalization AND
                      nvl(swr.phase_spec_finalization, 'N') = 'N') OR
                      (pt.attribute3 = g_purchasing AND
                      nvl(swr.phase_purchasing, 'N') = 'N') OR
                      (pt.attribute3 = g_billing AND
                      nvl(swr.phase_billing, 'N') = 'N') OR
                      (pt.attribute3 = g_shipping AND
                      nvl(swr.phase_shipping, 'N') = 'N') OR
                      (pt.attribute3 = g_production AND
                      nvl(swr.phase_producton, 'N') = 'N') OR
                      (pt.attribute3 = g_warranty AND
                      nvl(swr.phase_free_maintenance, 'N') = 'N') OR
                      (pt.attribute3 = g_installation AND
                      nvl(swr.phase_installation, 'N') = 'N') OR
                      (pt.attribute3 = g_design AND
                      nvl(swr.phase_design, 'N') = 'N')
                      -----------------
                      OR (pt.attribute3 = g_ckd_design AND
                      nvl(swr.phase_ckd_design, 'N') = 'N') OR
                      (pt.attribute3 = g_ckd_ba_di_process AND
                      nvl(swr.phase_di_process, 'N') = 'N') OR
                      (pt.attribute3 = g_ckd_purchasing AND
                      nvl(swr.phase_ckd_purchasing, 'N') = 'N') OR
                      (pt.attribute3 = g_design_planning AND
                      nvl(swr.phase_design_planning, 'N') = 'N') OR
                      --add by jiaming.zhou  start
                      (pt.attribute3 = g_ba_order_received  AND
                      nvl(swr.phase_ba_order_received, 'N') = 'N' AND swr.org_id = 84) OR
                      --add by jiaming.zhou  end
                      (pt.attribute3 = g_ba_di_process AND
                      nvl(swr.phase_ba_di_process, 'N') = 'N')))
      --delete parts      
      UNION ALL
      SELECT pt.task_id
        FROM xxpjm_stype_wbs_relationshp_v swr,
             pa_tasks                      pt,
             xxpjm_item_category_v         xic
       WHERE NVL(upper(swr.supply_scope_name), xxfnd_const.null_char) = NVL(upper(p_temp_type.source),
                                                                            xxfnd_const.null_char)
         AND swr.sales_type_id = p_temp_type.sales_line_type_id
         AND NVL(swr.sales_scope_name, xxfnd_const.null_char) = NVL(p_temp_type.market,
                                                                    xxfnd_const.null_char)
         AND swr.org_id = p_temp_type.org_id
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 = xic.flex_value --part_task
         AND nvl(swr.phase_parts_level, 'N') <> 'Y'
         --add by jiaming.zhou  start
         AND (swr.org_id = 84 OR swr.org_id = 82 AND nvl(swr.phase_ba_di_process, 'N') = 'N')
         --add by jiaming.zhou  end
      --delete claim task
      UNION ALL
      SELECT pt.task_id
        FROM pa_tasks pt
       WHERE pt.attribute5 IS NOT NULL --ER Claim Item
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND NOT EXISTS
       (SELECT 1
                FROM xxpjm_claim_weightage xcw
               WHERE upper(xcw.model) = upper(p_temp_type.model)
                 AND xcw.claim_type = 'ER'
                 AND xcw.claim_item = pt.attribute5);
  
    CURSOR cur_loadplan(p_project_id NUMBER, p_top_task_id NUMBER) IS
    /*SELECT plp.loading_plan_id
                                                                ,plp.standard_time
                                                                ,plp.phase_value
                                                                ,plp.loadplan_task_value
                                                                ,pt.task_id
                                                            FROM xxpjm_production_lead_time_v plt
                                                                ,xxpjm_phase_loading_plan_v   plp
                                                                ,pa_tasks                     pt
                                                           WHERE plt.lead_time_id = plp.lead_time_id
                                                             AND plt.org_id = p_temp_type.org_id
                                                             AND plt.model_value = p_temp_type.model
                                                             AND plt.market = p_temp_type.market
                                                             AND pt.project_id = p_project_id
                                                             AND pt.top_task_id = l_top_task_id
                                                             AND upper(pt.attribute7) = upper(plp.department)
                                                           ORDER BY pt.task_id, plp.phase_value, plp.loadplan_task_value;*/
      SELECT plp.loading_plan_id,
             plp.standard_time,
             plp.phase_value,
             plp.loadplan_task,
             plp.loadplan_task_value
             /*,pt.task_id*/,
             ppe.proj_element_id task_id,
             ppe.type_id --add by ouzhiwei at 2012-07-18
        FROM xxpjm_loading_plan_v plp, pa_tasks pt, pa_proj_elements ppe
       WHERE plp.org_id = p_temp_type.org_id
         AND plp.elevate_model = p_temp_type.model
         AND plp.market = p_temp_type.market
            --   AND pt.project_id = ppe.project_id
            --  AND pt.top_task_id = p_top_task_id
            --  AND upper(pt.attribute3) = upper(plp.department)
            
         AND ppe.project_id = p_project_id
         AND pt.task_number = ppe.element_number
         AND pt.top_task_id = p_top_task_id
         AND upper(pt.attribute3) = upper(plp.department)
            -- For HEA Installation need to check stops
         AND (p_temp_type.org_id != g_hea_org_id OR
             pt.attribute3 != g_installation OR
             plp.stop = p_temp_type.stops)
       ORDER BY pt.task_id, plp.phase_value, plp.loadplan_task_value;
  
    CURSOR cur_elements(p_project_id       NUMBER,
                        p_temp_top_task_id NUMBER,
                        p_last_top_task_id NUMBER) IS
      SELECT ppe.proj_element_id,
             ppe.element_number,
             ppe.name,
             pt.task_id template_task_id,
             ppe.record_version_number,
             pt.attribute_category,
             pt.attribute1,
             pt.attribute2,
             pt.attribute3,
             pt.attribute4,
             pt.attribute5,
             pt.attribute6,
             pt.attribute7,
             pt.attribute8,
             pt.attribute9,
             pt.attribute10,
             pt.chargeable_flag
        FROM pa_proj_elements ppe, pa_tasks pt, pa_tasks pt_new
       WHERE ppe.project_id = p_project_id
         AND pt.task_number(+) = ppe.element_number
         AND pt.top_task_id(+) = p_temp_top_task_id
         AND pt_new.top_task_id = p_last_top_task_id
         AND pt_new.task_id = ppe.proj_element_id
      /*AND pt.project_id = p_project_id*/
      ;
  
    CURSOR cur_resource_assignments(p_project_id  NUMBER,
                                    p_top_task_id IN NUMBER) IS
      SELECT pra.resource_assignment_id,
             pet.attribute1             er_budget_type,
             pet.attribute2             eq_budget_type
        FROM pa_proj_elements            ppe,
             pa_tasks                    pt,
             pa_task_types               ptt,
             pa_resource_assignments     pra,
             pa.pa_resource_list_members prlm,
             pa_expenditure_types        pet
       WHERE ppe.project_id = p_project_id
         AND ptt.task_type_id = ppe.type_id
         AND ppe.proj_element_id = pt.task_id
         AND pt.top_task_id = p_top_task_id
         AND ptt.task_type IN ('EQ COST', 'ER COST')
         AND pra.project_id = ppe.project_id
         AND pra.task_id = ppe.proj_element_id
         AND wbs_element_version_id =
             xxpjm_project_public.get_current_working_ver_id(ppe.proj_element_id)
         AND prlm.resource_class_code = 'FINANCIAL_ELEMENTS'
         AND prlm.fc_res_type_code = 'EXPENDITURE_TYPE'
         AND prlm.resource_list_member_id = pra.resource_list_member_id
         AND pet.expenditure_type = prlm.expenditure_type;
  
    CURSOR cur_so_customer_info(p_so_header_id IN NUMBER) IS
      SELECT sold_to_org_id, ship_to_org_id, invoice_to_org_id
        FROM oe_order_headers_all
       WHERE header_id = p_so_header_id;
  
    l_data                    VARCHAR2(2000);
    l_idx                     NUMBER;
    x_error_message           VARCHAR2(1000);
    x_task_id                 NUMBER;
    l_new_task_number         pa_tasks.task_number%TYPE;
    l_resource_list_member_id NUMBER;
    l_project_id              pa_projects_all.project_id%TYPE;
    l_prefix                  VARCHAR2(100);
    l_top_task_number         pa_tasks.task_number%TYPE;
    l_temp_top_task_number    pa_tasks.task_number%TYPE;
    l_top_task_id             pa_tasks.top_task_id%TYPE;
    l_temp_top_task_id        pa_tasks.top_task_id%TYPE;
    l_last_top_task_id        pa_tasks.top_task_id%TYPE;
    l_task_id                 pa_tasks.task_id%TYPE;
    l_bill_to_address_id      hz_cust_site_uses_all.cust_acct_site_id%TYPE;
    l_ship_to_address_id      hz_cust_site_uses_all.cust_acct_site_id%TYPE;
    l_element_number          pa_proj_elements.element_number%TYPE;
    l_element_name            pa_proj_elements.name%TYPE;
    l_test_top_task_id        NUMBER;
    l_person_id               pa_project_players.person_id%TYPE;
    l_proj_long_name          pa_projects_all.long_name%TYPE;
    x_published_struct_ver_id NUMBER;
    l_planned_quantity        NUMBER;
    l_customer_id             NUMBER;
    l_ship_to_org_id          NUMBER;
    l_bill_to_org_id          NUMBER;
    l_attribute3              VARCHAR2(100);
    l_task_name               VARCHAR2(100);
  BEGIN
    /*  x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => fnd_api.g_false);
    
    raise_exception(x_return_status);*/
    /* fnd_global.apps_initialize(1450, 50877, 275);
    mo_global.init('PA');
    mo_global.set_policy_context('S', p_temp_type.org_id);*/
    x_return_status := fnd_api.g_ret_sts_success;
    --get template info 
    log('get template info');
    get_project_template_info(p_temp_type.sales_type_id,
                              p_temp_type.sales_line_type_id,
                              l_proj_template_id,
                              l_temp_top_task_id,
                              l_temp_top_task_number,
                              x_src_task_version_id,
                              x_src_structure_version_id,
                              x_return_status,
                              x_msg_data);
    raise_exception(x_return_status);
    x_project_id := get_project_id(p_temp_type.so_number);
    IF x_project_id IS NULL THEN
      --process 10 generation project
      IF l_debug = 'Y' THEN
        log('l_proj_template_id:' || l_proj_template_id);
      END IF;
      IF p_temp_type.project_name IS NOT NULL THEN
        l_proj_long_name := p_temp_type.so_number || '_' ||
                            p_temp_type.project_name;
      ELSE
        l_proj_long_name := p_temp_type.so_number;
      END IF;
      log_time('xxpa_proj_public_pvt.add_project');
      xxpa_proj_public_pvt.add_project(p_orig_project_id    => l_proj_template_id,
                                       p_proj_num           => p_temp_type.so_number,
                                       p_long_name          => l_proj_long_name,
                                       p_description        => NULL,
                                       p_effective_date     => SYSDATE,
                                       p_copy_task_flag     => 'N',
                                       x_project_id         => x_project_id,
                                       p_debug_flag         => 'Y',
                                       x_new_project_number => x_new_project_number,
                                       x_return_status      => x_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data);
      log_time('xxpa_proj_public_pvt.add_project');
      raise_exception(x_return_status);
      IF l_debug = 'Y' THEN
        log('add_project out_project_id:' || x_project_id);
      END IF;
      IF x_project_id IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        raise_exception(x_return_status);
      END IF;
      SELECT pa_project_structure_utils.get_current_working_ver_id(x_project_id)
        INTO x_dest_structure_version_id
        FROM dual;
      --copy task from template 
      l_prefix := '';
      log('copy task from template  call procedure  xxpa_proj_public_pvt.copy_tasks_in_bulk');
      log_time('xxpa_proj_public_pvt.copy_tasks_in_bulk');
      xxpa_proj_public_pvt.copy_tasks_in_bulk(p_debug_mode                => 'Y',
                                              p_src_project_id            => l_proj_template_id,
                                              p_src_task_version_id       => x_src_task_version_id,
                                              p_src_structure_version_id  => x_src_structure_version_id,
                                              p_dest_structure_version_id => x_dest_structure_version_id,
                                              p_dest_task_version_id      => x_dest_structure_version_id,
                                              p_dest_project_id           => x_project_id,
                                              p_peer_or_sub               => 'SUB',
                                              p_prefix                    => l_prefix,
                                              x_return_status             => x_return_status,
                                              x_msg_count                 => x_msg_count,
                                              x_msg_data                  => x_msg_data);
      log_time('xxpa_proj_public_pvt.copy_tasks_in_bulk');
      IF l_debug = 'Y' THEN
        log('x_return_status:' || x_return_status);
        log('x_msg_count:' || x_msg_count);
        log('x_msg_data:' || x_msg_data);
      END IF;
      raise_exception(x_return_status);
    
      /*--get project manager
      log('get project manager');
      SELECT he.employee_id
        INTO l_employee_id
        FROM hr_employees he
       WHERE he.full_name = 'Ou ZhiWei,';*/
      --process 20 create project manager
      --get project manager from template project key member PROJECT MANAGER
      l_person_id := ger_project_manager_id(l_proj_template_id);
      IF l_person_id IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := get_message(g_appl_name, 'XXPJM_004E_016');
        raise_exception(x_return_status);
      END IF;
      log('process 20 create project manager call procedure xxpa_proj_public_pvt.create_proj_manager');
      xxpa_proj_public_pvt.create_proj_manager(p_project_id     => x_project_id,
                                               p_employee_id    => l_person_id,
                                               p_effective_date => SYSDATE,
                                               p_debug_mode     => 'Y',
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data);
      raise_exception(x_return_status);
      --process 30 generation project parameter
      log('begin  generation project parameter call procedure  xxpjm_project_para_gen_pkg.main');
      xxpjm_project_para_gen_pkg.main(errbuf        => l_errbuf,
                                      retcode       => l_retcode,
                                      p_project_id  => x_project_id,
                                      p_template_id => NULL);
      IF l_retcode <> '0' THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := l_errbuf;
        raise_exception(x_return_status);
      END IF;
      log('end  generation project parameter');
      --add project customer
      --get so customer_id 
      OPEN cur_so_customer_info(p_temp_type.so_header_id);
      FETCH cur_so_customer_info
        INTO l_customer_id, l_ship_to_org_id, l_bill_to_org_id;
      CLOSE cur_so_customer_info;
      --get bill_to_address_id
      log('get bill_to_address_id');
      l_bill_to_address_id := get_cust_addr_id(l_bill_to_org_id, 'BILL_TO');
      --get ship_to_address_id
      log('get ship_to_address_id');
      l_ship_to_address_id := get_cust_addr_id(l_ship_to_org_id, 'SHIP_TO');
      log(' begin create project customer call procedure xxpa_proj_public_pvt.add_proj_customer');
      xxpa_proj_public_pvt.add_proj_customer(p_project_id          => x_project_id,
                                             p_customer_id         => l_customer_id,
                                             p_bill_to_address_id  => l_bill_to_address_id,
                                             p_ship_to_address_id  => l_ship_to_address_id,
                                             p_org_id              => p_temp_type.org_id,
                                             p_inv_currency_code   => p_temp_type.currency,
                                             p_customer_bill_split => 100,
                                             x_return_status       => x_return_status,
                                             x_msg_count           => x_msg_count,
                                             x_msg_data            => x_msg_data);
      log('x_msg_data:' || x_msg_data);
      raise_exception(x_return_status);
      log(' end create project customer');
    ELSE
      --check mfg number isnot exits in this project
      log('check mfg number isnot exits in this project if exists then return else copy task from template top task');
      l_task_id := check_mfg_isnot_exists(p_project_id => x_project_id,
                                          p_mfg_nubmer => p_temp_type.manufacturing_number);
      IF l_task_id IS NOT NULL THEN
        /*IF p_temp_type.sales_line_type =
           xxpjm_proj_generation_pkg.g_goe_line_type_eq THEN
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := get_message(g_appl_name, 'XXPJM_004E_005');
          raise_exception(x_return_status);
        ELSE
          RETURN;
        END IF;*/
        RETURN;
      END IF;
      log('get project last top task info');
      --get project last top task info 
      get_last_top_task_info(x_project_id,
                             NULL,
                             l_last_top_task_id,
                             x_dest_task_version_id,
                             x_dest_structure_version_id,
                             x_return_status,
                             x_msg_data);
      IF l_debug = 'Y' THEN
        log('l_last_top_task_id:' || l_last_top_task_id);
        log('x_dest_task_version_id:' || x_dest_task_version_id);
        log('x_dest_structure_version_id:' || x_dest_structure_version_id);
        log('x_return_status:' || x_return_status);
        log('x_msg_data:' || x_msg_data);
      END IF;
      raise_exception(x_return_status);
      --copy task from template 
      l_prefix := '';
      IF l_debug = 'Y' THEN
        log('l_proj_template_id:' || l_proj_template_id);
        log('x_src_task_version_id:' || x_src_task_version_id);
        log('x_src_structure_version_id:' || x_src_structure_version_id);
        log('x_dest_structure_version_id:' || x_dest_structure_version_id);
        log('x_dest_task_version_id:' || x_dest_task_version_id);
        log('x_project_id:' || x_project_id);
      END IF;
      log('copy task from template  call procedure  xxpa_proj_public_pvt.copy_tasks_in_bulk');
      log_time('xxpa_proj_public_pvt.copy_tasks_in_bulk');
      xxpa_proj_public_pvt.copy_tasks_in_bulk(p_debug_mode                => 'Y',
                                              p_src_project_id            => l_proj_template_id,
                                              p_src_task_version_id       => x_src_task_version_id,
                                              p_src_structure_version_id  => x_src_structure_version_id,
                                              p_dest_structure_version_id => x_dest_structure_version_id,
                                              p_dest_task_version_id      => x_dest_task_version_id,
                                              p_dest_project_id           => x_project_id,
                                              p_peer_or_sub               => 'PEER',
                                              p_prefix                    => l_prefix,
                                              x_return_status             => x_return_status,
                                              x_msg_count                 => x_msg_count,
                                              x_msg_data                  => x_msg_data);
      /* SELECT pa_project_structure_utils.get_current_working_ver_id(x_project_id)
        INTO x_dest_structure_version_id
        FROM dual;
      xxpa_proj_public_pvt.copy_tasks_in_bulk(p_debug_mode                => 'Y',
                                              p_src_project_id            => l_proj_template_id,
                                              p_src_task_version_id       => x_src_task_version_id,
                                              p_src_structure_version_id  => x_src_structure_version_id,
                                              p_dest_structure_version_id => x_dest_structure_version_id,
                                              p_dest_task_version_id      => x_dest_structure_version_id,
                                              p_dest_project_id           => x_project_id,
                                              p_peer_or_sub               => 'SUB',
                                              p_prefix                    => l_prefix,
                                              x_return_status             => x_return_status,
                                              x_msg_count                 => x_msg_count,
                                              x_msg_data                  => x_msg_data);*/
      log_time('xxpa_proj_public_pvt.copy_tasks_in_bulk');
      IF l_debug = 'Y' THEN
        log('x_return_status:' || x_return_status);
        log('x_msg_count:' || x_msg_count);
        log('x_msg_data:' || x_msg_data);
      END IF;
      raise_exception(x_return_status);
    END IF;
  
    --get project last top task info 
    get_last_top_task_info(x_project_id,
                           l_temp_top_task_number,
                           l_last_top_task_id,
                           x_dest_task_version_id,
                           x_dest_structure_version_id,
                           x_return_status,
                           x_msg_data);
  
    --process 60 workloading
    IF l_debug = 'Y' THEN
      log('l_last_top_task_id:' || l_last_top_task_id);
      log('x_project_id:' || x_project_id);
    END IF;
    log('process 60 workloading');
    log('/****************BEGIN rec_loadplan****************/');
    log('x_project_id:                   ' || x_project_id);
    log('l_temp_top_task_id:             ' || l_temp_top_task_id);
    FOR rec_loadplan IN cur_loadplan(x_project_id, l_temp_top_task_id) LOOP
      --get task number
      l_new_task_number := get_new_task_number(rec_loadplan.task_id);
      IF l_debug = 'Y' THEN
        log('go in loop :rec_loadplan');
        log('do on task==>' || rec_loadplan.phase_value);
        log('start create loadplan task==>' ||
            rec_loadplan.loadplan_task_value);
        log_time('xxpa_proj_public_pvt.add_proj_task');
        log('x_project_id:' || x_project_id);
        log('x_dest_structure_version_id:' ||
            pa_project_structure_utils.get_current_working_ver_id(x_project_id));
        log('rec_loadplan.loadplan_task_value:' ||
            rec_loadplan.loadplan_task_value);
        log('l_new_task_number:' || l_new_task_number);
        log(' rec_loadplan.task_id:' || rec_loadplan.task_id);
      END IF;
      log('add project task call procedure xxpa_proj_public_pvt.add_proj_task');
      xxpa_proj_public_pvt.add_proj_task(p_project_id           => x_project_id,
                                         p_structure_version_id => pa_project_structure_utils.get_current_working_ver_id(x_project_id), -- x_dest_structure_version_id,
                                         p_task_name            => rec_loadplan.loadplan_task_value,
                                         p_task_number          => l_new_task_number,
                                         p_parent_task_id       => rec_loadplan.task_id,
                                         p_task_type            => rec_loadplan.type_id,
                                         x_task_id              => x_task_id,
                                         x_return_status        => x_return_status,
                                         x_msg_count            => x_msg_count,
                                         x_msg_data             => x_msg_data);
      IF l_debug = 'Y' THEN
        log('x_task_id:' || x_task_id);
        log_time('xxpa_proj_public_pvt.add_proj_task');
        log('x_return_status:' || x_return_status);
        log('x_msg_count:' || x_msg_count);
        log('x_msg_data:' || x_msg_data);
      END IF;
      /*log('test raise 60');
      RAISE fnd_api.g_exc_error; */
      raise_exception(x_return_status);
      --get resource_member_id
      --if L_DEBUG = 'Y' THEN
      log('get resource_member_id');
      log('rec_loadplan.loading_plan_id:' || rec_loadplan.loading_plan_id);
      l_resource_list_member_id := get_resource_list_member_id(rec_loadplan.loading_plan_id);
      log('l_resource_list_member_id:' || l_resource_list_member_id);
      --assign task resources
      log('assign task resources');
      --end if;
      IF l_resource_list_member_id IS NOT NULL THEN
        IF l_debug = 'Y' THEN
          log_time('xxpa_proj_public_pvt.add_task_resource_assignment');
          log('x_task_id:' || x_task_id);
          log('get_current_working_ver_id(x_task_id):' ||
              get_current_working_ver_id(x_task_id));
        END IF;
        xxpa_proj_public_pvt.add_task_resource_assignment(p_project_id => x_project_id,
                                                          /*  p_pa_structure_version_id  => x_dest_structure_version_id,*/
                                                          p_task_id                  => x_task_id,
                                                          pa_task_element_version_id => get_current_working_ver_id(x_task_id),
                                                          p_resource_list_member_id  => l_resource_list_member_id,
                                                          p_planned_quantity         => rec_loadplan.standard_time,
                                                          p_pm_product_code          => 'pjm',
                                                          p_pm_task_asgmt_reference  => x_task_id,
                                                          x_return_status            => x_return_status,
                                                          x_msg_count                => x_msg_count,
                                                          x_msg_data                 => x_msg_data);
        IF l_debug = 'Y' THEN
          log_time('xxpa_proj_public_pvt.add_task_resource_assignment');
          log('x_return_status:' || x_return_status);
          log('x_msg_count:' || x_msg_count);
          log('x_msg_data:' || x_msg_data);
        END IF;
        /* log('test raise 70');
        RAISE fnd_api.g_exc_error; */
        raise_exception(x_return_status);
      END IF;
    END LOOP;
    log('/****************END rec_loadplan****************/');
  
    --structure published
    log('structure published');
    xxpa_proj_public_pvt.structure_published(p_project_id              => x_project_id,
                                             x_published_struct_ver_id => x_published_struct_ver_id,
                                             x_msg_count               => x_msg_count,
                                             x_msg_data                => x_msg_data,
                                             x_return_status           => x_return_status);
    raise_exception(x_return_status);
    log('get the generate top task id');
    --get the generate top task id
    --get project last top task info 
    get_last_top_task_info(x_project_id,
                           l_temp_top_task_number,
                           l_last_top_task_id,
                           x_dest_task_version_id,
                           x_dest_structure_version_id,
                           x_return_status,
                           x_msg_data);
    IF l_debug = 'Y' THEN
      log('x_return_status:' || x_return_status);
      log('x_msg_data:' || x_msg_data);
    END IF;
    raise_exception(x_return_status);
    IF l_debug = 'Y' THEN
      log('l_top_task_id:' || l_top_task_id);
      log('x_project_id:' || x_project_id);
      --process 40 update task_nubmer
      log('process 40 update task_nubmer');
      log('x_project_id:' || x_project_id);
      log('l_temp_top_task_id:' || l_temp_top_task_id);
    END IF;
    log_time('loop rec_elements');
    FOR rec_elements IN cur_elements(x_project_id,
                                     l_temp_top_task_id,
                                     l_last_top_task_id) LOOP
      IF l_debug = 'Y' THEN
        log('begin  loop :cur_elements');
      END IF;
      log('project_process.rec_elements  element_number ' || rec_elements.element_number);
      log('project_process.rec_elements  element_number ' || rec_elements.proj_element_id);
      l_element_number := REPLACE(rec_elements.element_number,
                                  l_temp_top_task_number,
                                  p_temp_type.manufacturing_number);
      log('project_process.rec_elements  l_element_number ' || l_element_number);
      log('project_process.rec_elements  rec_elements.name ' || rec_elements.name);
      /*log('***************1');
      log('l_element_number:' || l_element_number);
      log('l_element_name:' || l_element_name);*/
      IF rec_elements.element_number = l_temp_top_task_number THEN
        
        l_element_name := p_temp_type.manufacturing_number || '_' ||
                          p_temp_type.lift_no;
        IF l_debug = 'Y' THEN
          log('l_temp_top_task_number:' || l_temp_top_task_number);
          log('x_project_id:' || x_project_id);
        END IF;
      ELSE
        --update by gusenlin 2013-12-24 start  for install 3 level no need to add lift no
        IF check_install3(rec_elements.template_task_id) ='Y' THEN
          l_element_name := rec_elements.name;
        ELSE
          l_element_name := rec_elements.name || '_' || p_temp_type.lift_no;
        END IF;
        --update by gusenlin 2013-12-24 end
      END IF;
      IF l_debug = 'Y' THEN
        IF rec_elements.attribute8 = 'EQ' THEN
          log('................exists EQ!!!!');
        END IF;
      END IF;
      /*log('***************2');
      log_time(' xxpa_proj_public_pvt.update_proj_element');
      
      log('rec_elements.proj_element_id:' || rec_elements.proj_element_id);
      log('rec_elements.attribute_category:' ||
          rec_elements.attribute_category);
      log('rec_elements.attribute1:' || rec_elements.attribute1);
      log('rec_elements.attribute2:' || rec_elements.attribute2);
      log('rec_elements.attribute3:' || rec_elements.attribute3);
      log('rec_elements.attribute4:' || rec_elements.attribute4);
      log('rec_elements.attribute5:' || rec_elements.attribute5);
      log('rec_elements.attribute6:' || rec_elements.attribute6);
      log('rec_elements.attribute7:' || rec_elements.attribute7);
      log('rec_elements.attribute8:' || rec_elements.attribute8);
      log('rec_elements.attribute9:' || rec_elements.attribute9);
      log('rec_elements.attribute10:' || rec_elements.attribute10);
      log('rec_elements.record_version_number:' ||
          rec_elements.record_version_number);
      log('rec_elements.record_version_number:' ||
          rec_elements.record_version_number);
      log('l_element_number:' || l_element_number);
      log('l_element_name:' || l_element_name);*/
      BEGIN
        SELECT pt.attribute3, pt.task_name
          INTO l_attribute3, l_task_name
          FROM pa_tasks pt
         WHERE pt.task_id = rec_elements.proj_element_id;
      EXCEPTION
        WHEN OTHERS THEN
          log('*****************ERROR:' || SQLERRM);
      END;
      xxpa_proj_public_pvt.update_proj_element(p_proj_element_id       => rec_elements.proj_element_id,
                                               p_chargeable_flag       => rec_elements.chargeable_flag,
                                               p_element_number        => l_element_number,
                                               p_element_name          => l_element_name,
                                               p_record_version_number => rec_elements.record_version_number,
                                               p_tk_attribute_category => rec_elements.attribute_category,
                                               p_tk_attribute1         => rec_elements.attribute1,
                                               p_tk_attribute2         => rec_elements.attribute2,
                                               p_tk_attribute3         => rec_elements.attribute3,
                                               p_tk_attribute4         => rec_elements.attribute4,
                                               p_tk_attribute5         => rec_elements.attribute5,
                                               p_tk_attribute6         => rec_elements.attribute6,
                                               p_tk_attribute7         => rec_elements.attribute7,
                                               p_tk_attribute8         => rec_elements.attribute8,
                                               p_tk_attribute9         => rec_elements.attribute9,
                                               p_tk_attribute10        => rec_elements.attribute10,
                                               x_return_status         => x_return_status,
                                               x_msg_count             => x_msg_count,
                                               x_msg_data              => x_msg_data);
      IF l_debug = 'Y' THEN
        log_time(' xxpa_proj_public_pvt.update_proj_element');
        log('x_return_status:' || x_return_status);
        log('x_msg_count:'     || x_msg_count);
        log('x_msg_data:'      || x_msg_data);
      END IF;
      /* log('test raise 40');
      RAISE fnd_api.g_exc_error; */
      raise_exception(x_return_status);
    END LOOP;
    -- RAISE fnd_api.g_exc_error;
    log_time('loop rec_elements');
    log('end loop :cur_elements');
    --process 50 update wbs as mapping sales buiness type
    log('process 50 update wbs as mapping sales buiness type');
    log('/****************BEGIN rec_task in cur_task****************/');
    log('x_project_id:                   ' || x_project_id);
    log('l_last_top_task_id:             ' || l_last_top_task_id);
    log('p_temp_type.source:             ' || p_temp_type.source);
    log('p_temp_type.sales_line_type_id: ' || p_temp_type.sales_line_type_id);
    log('p_temp_type.market:             ' || p_temp_type.market);
    FOR rec_task IN cur_task(x_project_id, l_last_top_task_id) LOOP
      --IF l_debug = 'Y' THEN
      log('go in loop :rec_task');
      log('start delete task==>');
      log('delete task_id==>' || rec_task.task_id);
      log('delete project task call procedure xxpa_proj_public_pvt.delete_proj_task');
      log_time('xxpa_proj_public_pvt.delete_proj_task');
      --END IF;
      xxpa_proj_public_pvt.delete_proj_task(p_project_id    => x_project_id,
                                            p_task_id       => rec_task.task_id,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data);
      --IF l_debug = 'Y' THEN
      log_time('xxpa_proj_public_pvt.delete_proj_task');
      log('delete delete_proj_task return status==>' || x_return_status);
      log('x_return_status:' || x_return_status);
      log('x_msg_count:' || x_msg_count);
      log('x_msg_data:' || x_msg_data);
      --END IF;
      raise_exception(x_return_status);
      FOR i IN 1 .. nvl(x_msg_count, 0) LOOP
        pa_interface_utils_pub.get_messages(p_encoded       => 'F',
                                            p_msg_index     => i,
                                            p_msg_count     => x_msg_count,
                                            p_msg_data      => x_msg_data,
                                            p_data          => l_data,
                                            p_msg_index_out => l_idx);
        x_error_message := substrb(x_error_message || l_data, 1, 2000);
        IF l_debug = 'Y' THEN
          log('delete delete_proj_task x_error_message==>' ||
              x_error_message);
        END IF;
      END LOOP;
    END LOOP;
    log('/****************END rec_task in cur_task****************/');
    log('begin loop cur_resource_assignments');
    --update budget 
    FOR rec_resource_assignments IN cur_resource_assignments(x_project_id,
                                                             l_last_top_task_id) LOOP
      l_planned_quantity := NULL;
      --er 
      --EXPENSE  
      IF nvl(p_temp_type.er_budget_expense, 0) > 0 AND
         rec_resource_assignments.er_budget_type = g_er_expense_budget_type THEN
        l_planned_quantity := p_temp_type.er_budget_expense;
        --LABOR
      ELSIF nvl(p_temp_type.er_budget_labor, 0) > 0 AND
            rec_resource_assignments.er_budget_type =
            g_er_labor_budget_type THEN
        l_planned_quantity := p_temp_type.er_budget_labor;
        --MATERIAL
      ELSIF nvl(p_temp_type.er_budget_material, 0) > 0 AND
            rec_resource_assignments.er_budget_type =
            g_er_material_budget_type THEN
        l_planned_quantity := p_temp_type.er_budget_material;
        --SUBCONTRACTING
      ELSIF nvl(p_temp_type.er_budget_subcontracting, 0) > 0 AND
            rec_resource_assignments.er_budget_type =
            g_er_subcontract_budget_type THEN
        l_planned_quantity := p_temp_type.er_budget_subcontracting;
        --EQ COST
      ELSIF nvl(p_temp_type.eq_unit_cost, 0) > 0 AND
            rec_resource_assignments.eq_budget_type = g_eq_cost_type THEN
        l_planned_quantity := p_temp_type.eq_unit_cost;
      END IF;
      IF l_planned_quantity > 0 THEN
        IF l_debug = 'Y' THEN
          log('begin procedure xxpa_proj_public_pvt.update_task_assignments');
        END IF;
        xxpa_proj_public_pvt.update_task_assignments(p_project_id         => x_project_id,
                                                     p_planned_quantity   => l_planned_quantity,
                                                     p_task_assignment_id => rec_resource_assignments.resource_assignment_id,
                                                     x_msg_count          => x_msg_count,
                                                     x_msg_data           => x_msg_data,
                                                     x_return_status      => x_return_status);
        IF l_debug = 'Y' THEN
          log('end procedure xxpa_proj_public_pvt.update_task_assignments');
          log('x_return_status:' || x_return_status);
        END IF;
        raise_exception(x_return_status);
      END IF;
    END LOOP;
    log('end loop cur_resource_assignments');
    /*    --update wbs schedule  
    LOG('update wbs schedule');
    UPDATE_SCHEDULE(P_PROJECT_ID            => X_PROJECT_ID,
                    P_TOP_TASK_ID           => L_LAST_TOP_TASK_ID,
                    P_SOURCE                => P_TEMP_TYPE.SOURCE,
                    P_MARKET                => P_TEMP_TYPE.MARKET,
                    P_MODEL                 => P_TEMP_TYPE.MODEL,
                    P_PARTIAL_DELIVERY_DATE => P_TEMP_TYPE.PARTIAL_DELIVERY_DATE,
                    P_FINAL_DELIVERY_DATE   => P_TEMP_TYPE.FINAL_DELIVERY_DATE,
                    X_MSG_COUNT             => X_MSG_COUNT,
                    X_MSG_DATA              => X_MSG_DATA,
                    X_RETURN_STATUS         => X_RETURN_STATUS);
    RAISE_EXCEPTION(X_RETURN_STATUS);*/
    --structure published

    
    log('structure published');
    log_time('structure published');
    xxpa_proj_public_pvt.structure_published(p_project_id              => x_project_id,
                                             x_published_struct_ver_id => x_published_struct_ver_id,
                                             x_msg_count               => x_msg_count,
                                             x_msg_data                => x_msg_data,
                                             x_return_status           => x_return_status);
    raise_exception(x_return_status);
    log_time('structure published');
    --      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    --structure published
    log('update structure name');
    log_time('update structure name');
    update_structure_name(p_project_id    => x_project_id,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          x_return_status => x_return_status);
    raise_exception(x_return_status);
    log_time('update structure name');
  
    --update wbs schedule  
    log('update wbs schedule');
    update_schedule(p_project_id            => x_project_id,
                    p_top_task_id           => l_last_top_task_id,
                    p_source                => p_temp_type.source,
                    p_market                => p_temp_type.market,
                    p_model                 => p_temp_type.model,
                    p_lt_model              => p_temp_type.lt_model,
                    p_partial_delivery_date => p_temp_type.partial_delivery_date,
                    p_final_delivery_date   => p_temp_type.final_delivery_date,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data,
                    x_return_status         => x_return_status);
    raise_exception(x_return_status);
    
    --update by gusenlin 2013-12-19 start
    log('xxpjm_install_phase_pub.is_ProjectB : l_proj_template_id ' || l_proj_template_id);
    IF xxpjm_install_phase_pub.is_ProjectB(l_proj_template_id) ='Y' THEN
      
      xxpjm_install_phase_pub.copy_task_dependencies(p_project_id           =>  x_project_id,
                                                     p_top_task_id          =>  l_last_top_task_id,
                                                     p_source_project_id    =>  l_proj_template_id,
                                                     p_source_top_task_id   =>  l_temp_top_task_id,
                                                     p_manufacturing_number =>  p_temp_type.manufacturing_number,
                                                     p_source_mfg_number    =>  l_temp_top_task_number,
                                                     x_msg_data             =>  l_msg_data,
                                                     x_return_status        =>  x_return_status); 
      
      IF x_return_status = fnd_api.g_ret_sts_success THEN
        xxpjm_install_phase_pub.instal_process(p_project_id         => x_project_id,
                                               p_top_task_id        => l_last_top_task_id,
                                               p_source_top_task_id => l_temp_top_task_id,
                                               p_model              => p_temp_type.model,
                                               p_lift_no            => p_temp_type.stops,
                                               p_org_id             => p_temp_type.org_id,
                                               x_return_status      => x_return_status,
                                               x_error_message      => l_msg_data);
      
        log('xxpjm_install_phase_pub.instal_process x_return_status : ' || x_return_status);
        log('xxpjm_install_phase_pub.instal_process l_msg_data      : ' || l_msg_data);
      END IF;
    END IF;
    --update by gusenlin 2013-12-19 end
    
    xxpa_proj_public_pvt.structure_published(p_project_id              => x_project_id,
                                             x_published_struct_ver_id => x_published_struct_ver_id,
                                             x_msg_count               => x_msg_count,
                                             x_msg_data                => x_msg_data,
                                             x_return_status           => x_return_status);
    log('xxpa_proj_public_pvt.structure_published x_msg_count     : ' || x_msg_count);
    log('xxpa_proj_public_pvt.structure_published x_msg_data      : ' || x_msg_data);
    log('xxpa_proj_public_pvt.structure_published x_return_status : ' || x_return_status);
    if nvl(x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
       raise_exception(x_return_status);
    end if;
    
    x_msg_data := nvl(l_msg_data,x_msg_data);
    
  EXCEPTION
    WHEN OTHERS THEN
      log('Error Message as following:');
      log(dbms_utility.format_error_backtrace ||
                           dbms_utility.format_error_stack);
      x_return_status := fnd_api.g_ret_sts_error;
      IF x_msg_data IS NULL THEN
        x_msg_data := 'calling xxpjm_project_public.project_process raise error:' ||
                      SQLERRM;
      END IF;
  END project_process;


  PROCEDURE project_process2(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_temp_type     IN xxpjm_proj_generation_int%ROWTYPE)
  IS
    CURSOR project_c(p_project_num  VARCHAR2)
    IS
      SELECT project_id
        FROM pa_projects  pa
       WHERE pa.segment1 = p_project_num;
       
    l_project_id          NUMBER;
    l_retcode             VARCHAR2(1);
    l_errbuf              VARCHAR2(2000);
  BEGIN

    project_process(p_init_msg_list,
                    p_commit,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_temp_type);
                    
    IF x_return_status = fnd_api.g_ret_sts_success THEN
      
      log('/****************BEGIN Delete Publish Version****************/');
      OPEN  project_c(p_temp_type.so_number);
      FETCH project_c
       INTO l_project_id;
      CLOSE project_c;
      
      log('l_project_id: ' || l_project_id);
      IF l_project_id IS NOT NULL THEN
        
        xxpjm_delete_publish_ver_pkg.main(l_errbuf,
                                          l_retcode,
                                          l_project_id);
      
      END IF;
      log('/****************END Delete Publish Version****************/');
    
    END IF;

  END;
                             


  /*==================================================
  Program Name:
      update_project_customer_process
  Description:
      when so 
  History:
      1.00  2012/2/27 17:17:57  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE update_proj_customer_process(p_project_id         IN NUMBER,
                                         p_old_customer_id    IN NUMBER,
                                         p_new_customer_id    IN NUMBER,
                                         p_bill_to_address_id IN NUMBER,
                                         p_ship_to_address_id IN NUMBER,
                                         p_inv_currency_code  IN VARCHAR2,
                                         p_org_id             IN NUMBER,
                                         p_add_flag           IN VARCHAR2,
                                         x_return_status      OUT NOCOPY VARCHAR2,
                                         x_msg_count          OUT NOCOPY NUMBER,
                                         x_msg_data           OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_proj_customer_process';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    x_bill_to_address_id    NUMBER;
    x_ship_to_address_id    NUMBER;
    x_contribution          NUMBER;
    x_relationship          pa_project_customers.project_relationship_code%TYPE;
    x_inv_currency_code     pa_project_customers.inv_currency_code%TYPE;
    x_inv_rate_type         pa_project_customers.inv_rate_type%TYPE;
    x_record_version_number NUMBER;
    x_old_contribution      NUMBER;
  BEGIN
    log('staring procedure update_proj_customer_process');
    x_return_status := fnd_api.g_ret_sts_success;
    --get old projcet_customer_info
    log('get old projcet_customer_info');
    get_projcet_customer_info(p_project_id            => p_project_id,
                              p_customer_id           => p_old_customer_id,
                              x_bill_to_address_id    => x_bill_to_address_id,
                              x_ship_to_address_id    => x_ship_to_address_id,
                              x_contribution          => x_old_contribution,
                              x_relationship          => x_relationship,
                              x_inv_currency_code     => x_inv_currency_code,
                              x_inv_rate_type         => x_inv_rate_type,
                              x_record_version_number => x_record_version_number,
                              x_return_status         => x_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data);
    raise_exception(x_return_status);
  
    IF p_add_flag <> 'Y' THEN
      --update old project customer  ship to/bill to
      log('update old project customer  ship to/bill to');
      xxpa_proj_public_pvt.update_project_customer(p_project_id                => p_project_id,
                                                   p_customer_id               => p_old_customer_id,
                                                   p_record_version_number     => x_record_version_number,
                                                   p_bill_to_address_id        => p_bill_to_address_id,
                                                   p_ship_to_address_id        => p_ship_to_address_id,
                                                   p_project_relationship_code => x_relationship,
                                                   p_customer_bill_split       => x_old_contribution,
                                                   p_inv_currency_code         => x_inv_currency_code,
                                                   p_inv_rate_type             => x_inv_rate_type,
                                                   x_return_status             => x_return_status,
                                                   x_msg_count                 => x_msg_count,
                                                   x_msg_data                  => x_msg_data);
      raise_exception(x_return_status);
      RETURN;
    ELSE
      --update old project customer  set customer_bill_split=0
      log('update old project customer  set customer_bill_split=0');
      IF l_debug = 'Y' THEN
        log('p_old_customer_id:' || p_old_customer_id);
        log('x_bill_to_address_id:' || x_bill_to_address_id);
        log('x_ship_to_address_id:' || x_ship_to_address_id);
      END IF;
      xxpa_proj_public_pvt.update_project_customer(p_project_id                => p_project_id,
                                                   p_customer_id               => p_old_customer_id,
                                                   p_record_version_number     => x_record_version_number,
                                                   p_bill_to_address_id        => x_bill_to_address_id,
                                                   p_ship_to_address_id        => x_ship_to_address_id,
                                                   p_project_relationship_code => x_relationship,
                                                   p_customer_bill_split       => 0,
                                                   p_inv_currency_code         => x_inv_currency_code,
                                                   p_inv_rate_type             => x_inv_rate_type,
                                                   x_return_status             => x_return_status,
                                                   x_msg_count                 => x_msg_count,
                                                   x_msg_data                  => x_msg_data);
      raise_exception(x_return_status);
    END IF;
    --check if project customer exists
    log('check if project customer exists');
    IF check_proj_customer_exists(p_project_id  => p_project_id,
                                  p_customer_id => p_new_customer_id) = 'Y' THEN
      --get new projcet_customer_info
      log('get new projcet_customer_info');
      get_projcet_customer_info(p_project_id            => p_project_id,
                                p_customer_id           => p_old_customer_id,
                                x_bill_to_address_id    => x_bill_to_address_id,
                                x_ship_to_address_id    => x_ship_to_address_id,
                                x_contribution          => x_contribution,
                                x_relationship          => x_relationship,
                                x_inv_currency_code     => x_inv_currency_code,
                                x_inv_rate_type         => x_inv_rate_type,
                                x_record_version_number => x_record_version_number,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data);
      --if new project customer  exists then update   customer_bill_split=old_customer_bill_split   
      log('if new project customer  exists then update   customer_bill_split=old_customer_bill_split  ');
      xxpa_proj_public_pvt.update_project_customer(p_project_id                => p_project_id,
                                                   p_customer_id               => p_new_customer_id,
                                                   p_record_version_number     => x_record_version_number,
                                                   p_bill_to_address_id        => p_bill_to_address_id,
                                                   p_ship_to_address_id        => p_ship_to_address_id,
                                                   p_project_relationship_code => x_relationship,
                                                   p_customer_bill_split       => x_old_contribution,
                                                   p_inv_currency_code         => x_inv_currency_code,
                                                   p_inv_rate_type             => x_inv_rate_type,
                                                   x_return_status             => x_return_status,
                                                   x_msg_count                 => x_msg_count,
                                                   x_msg_data                  => x_msg_data);
      raise_exception(x_return_status);
      RETURN;
      /* x_msg_data      := get_message(g_appl_name, 'XXPJM_004E_011');
      x_return_status := fnd_api.G_RET_STS_ERROR;
      raise_exception(x_return_status);*/
    END IF;
    --add new project customer 
    log('add new project customer');
    xxpa_proj_public_pvt.add_proj_customer(p_project_id          => p_project_id,
                                           p_customer_id         => p_new_customer_id,
                                           p_bill_to_address_id  => p_bill_to_address_id,
                                           p_ship_to_address_id  => p_ship_to_address_id,
                                           p_inv_currency_code   => x_inv_currency_code,
                                           p_org_id              => p_org_id,
                                           p_customer_bill_split => x_old_contribution,
                                           x_return_status       => x_return_status,
                                           x_msg_count           => x_msg_count,
                                           x_msg_data            => x_msg_data);
    raise_exception(x_return_status);
    log('end procedure update_proj_customer_process');
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END update_proj_customer_process;
  
  
  PROCEDURE cleanup(p_project_id     IN   NUMBER,
                    x_return_status  OUT  VARCHAR2,
                    x_msg_count      OUT  NUMBER,
                    x_msg_data       OUT  VARCHAR2)
  IS
    l_errbuf        VARCHAR2(2000);
    l_retcode       VARCHAR2(1);
  BEGIN

    log('/****************BEGIN cleanup****************/');

    x_return_status := fnd_api.g_ret_sts_success;
    xxpjm_delete_publish_ver_pkg.main(l_errbuf,
                                      l_retcode,
                                      p_project_id);
                                      
    update_structure_name(p_project_id,
                          x_return_status,
                          x_msg_count,
                          x_msg_data);
                          
    log('/****************END cleanup****************/');

  END;


END xxpjm_project_public;
/
