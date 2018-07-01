CREATE OR REPLACE PACKAGE xxpjm_task_scheduled_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      xxpjm_task_scheduled_pkg
  Description:
      This program provide concurrent main procedure to perform:
      
  History:
      1.00  20/04/2012 10:58:05 AM  ouzhiwei     Creation
      1.01  17/07/2013              Fandong.chen Update
            Add new parameter p_update_shipping_phase_only
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
  g_num_format        VARCHAR2(30) := 'FM9999999999999999999990.00';
  g_date_format       VARCHAR2(30) := 'YYYY-MM-DD HH24:MI:SS';

  g_request_id NUMBER := fnd_global.conc_request_id;
  g_session_id NUMBER := userenv('sessionid');
  g_appl_name  VARCHAR2(10) := 'XXPJM';
  --add by jiaming.zhou 2014-03-05 start
  g_call_flag VARCHAR2(1) := 'N';
  --add by jiaming.zhou 2014-03-05 end
  --program entrance
  PROCEDURE main(errbuf     OUT VARCHAR2,
                 retcode    OUT VARCHAR2,
                 p_group_id IN NUMBER);
  PROCEDURE submit_schedule_update(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                   p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   x_request_id    OUT VARCHAR2,
                                   p_group_id      IN NUMBER);
  FUNCTION get_working_ver_id(p_task_id NUMBER) RETURN NUMBER;
  PROCEDURE get_phase_part_schedule_date(p_task_id             IN NUMBER, --the part task
                                         p_delivery_date       IN DATE, --part task shipping schedule end date
                                         x_schedule_start_date OUT DATE,
                                         x_schedule_end_date   OUT DATE,
                                         x_return_status       OUT VARCHAR2,
                                         x_msg_data            OUT VARCHAR2);

  PROCEDURE get_lead_time(x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_task_id       IN NUMBER,
                          x_use_time      OUT NUMBER,
                          x_lead_time     OUT NUMBER);

  PROCEDURE main_proj_mfg(errbuf                  OUT VARCHAR2,
                          retcode                 OUT VARCHAR2,
                          p_project_id            IN NUMBER,
                          p_top_task_id           IN NUMBER,
                          p_partial_delivery_date IN VARCHAR2,
                          p_schedule_end_date     IN VARCHAR2,
                          --update by jiaming.zhou 2013-12-31 start
                          --p_update_shipping_phase_only IN VARCHAR2,--New parameter added by fandong.chen 20130717
                          p_plan_shipping_date IN VARCHAR2,
                          --update by jiaming.zhou 2013-12-31 end
                          p_base_on_spec           IN VARCHAR2,
                          p_spec_schedule_end_date IN VARCHAR2);

  PROCEDURE process_request_proj_mfg1(p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                      p_commit                IN VARCHAR2 DEFAULT fnd_api.g_false,
                                      x_return_status         OUT NOCOPY VARCHAR2,
                                      x_msg_count             OUT NOCOPY NUMBER,
                                      x_msg_data              OUT NOCOPY VARCHAR2,
                                      p_project_id            IN NUMBER,
                                      p_top_task_id           IN NUMBER,
                                      p_partial_delivery_date IN DATE,
                                      p_schedule_end_date     IN DATE
                                      --update by jiaming.zhou 2013-12-31 start
                                      --,p_update_shipping_phase_only IN VARCHAR2
                                      --update by jiaming.zhou 2013-12-31 end
                                      );

  PROCEDURE process_request_mfg(p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                p_commit                IN VARCHAR2 DEFAULT fnd_api.g_false,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2,
                                p_project_id            IN NUMBER,
                                p_top_task_id           IN NUMBER,
                                p_source                IN VARCHAR2,
                                p_market                IN VARCHAR2,
                                p_model                 IN VARCHAR2,
                                p_lt_model              IN VARCHAR2,
                                p_partial_delivery_date IN DATE,
                                p_final_delivery_date   IN DATE);
  PROCEDURE update_task_schedule(p_init_msg_list        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 p_commit               IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_msg_count            OUT NOCOPY NUMBER,
                                 x_msg_data             OUT NOCOPY VARCHAR2,
                                 p_task_id              IN NUMBER,
                                 p_scheduled_start_date IN DATE := pa_interface_utils_pub.g_pa_miss_date,
                                 p_scheduled_end_date   IN DATE := pa_interface_utils_pub.g_pa_miss_date);
  --add by jiaming.zhou 2014-03-05 start
  PROCEDURE update_speci_part_schedule(p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                       p_commit                IN VARCHAR2 DEFAULT fnd_api.g_false,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2,
                                       p_task_id               IN NUMBER,
                                       p_partial_delivery_date IN DATE,
                                       p_final_delivery_date   IN DATE);
  --add by jiaming.zhou 2014-03-05 end
END xxpjm_task_scheduled_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxpjm_task_scheduled_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPJM_EMPLOYEE_MK_IMP_PKG
  Description:
      Update the schedule date
  History:
      v1.0  2014-07-17         Jiaming.Zhou 
         Add the function to use in SHE
      v2.0  2014-10-08         Jiaming.Zhou 
         Update the installation phase update to use in SHE
  ==================================================*/
  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'xxpjm_task_scheduled_pkg';
  g_phase_wbs_level NUMBER := 2;
  g_part_wbs_level  NUMBER := 3;

  g_global_flag  VARCHAR2(1) := 'N';
  g_market       VARCHAR2(30);
  g_model        VARCHAR2(30);
  g_source       VARCHAR2(240);
  g_lt_model     VARCHAR2(30);
  g_installation VARCHAR2(30) := 'Installation';
  --add by jiaming.zhou 2014-03-04 start
  g_specification VARCHAR2(30) := 'Spec Finalization';
  g_miss_char CONSTANT VARCHAR2(1) := chr(0);
  g_miss_date CONSTANT DATE := to_date('1', 'j');
  --add by jiaming.zhou 2014-03-04 end

  g_delivery_date DATE;
  TYPE task_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_task_tab     task_tab;
  l_task_tab_int task_tab;
  l_index        NUMBER := 0;

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

  --output
  PROCEDURE output(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_content);
  END output;

  --log
  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, REPLACE(p_content, chr(0), ' '));
  END log;

  --outputtd
  PROCEDURE outputtd(p_content IN VARCHAR2) IS
  BEGIN
    output('<td>' || p_content || '</td>');
  END outputtd;

  --format number
  FUNCTION format(p_content IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(p_content, g_num_format);
  END format;

  --format string
  FUNCTION format(p_content IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '="' || p_content || '"';
  END format;

  --format date
  FUNCTION format(p_content IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(p_content, g_date_format);
  END format;

  FUNCTION get_message(p_appl_name     IN VARCHAR2,
                       p_message_name  IN VARCHAR2,
                       p_token1        IN VARCHAR2 DEFAULT NULL,
                       p_token1_value  IN VARCHAR2 DEFAULT NULL,
                       p_token2        IN VARCHAR2 DEFAULT NULL,
                       p_token2_value  IN VARCHAR2 DEFAULT NULL,
                       p_token3        IN VARCHAR2 DEFAULT NULL,
                       p_token3_value  IN VARCHAR2 DEFAULT NULL,
                       p_token4        IN VARCHAR2 DEFAULT NULL,
                       p_token4_value  IN VARCHAR2 DEFAULT NULL,
                       p_token5        IN VARCHAR2 DEFAULT NULL,
                       p_token5_value  IN VARCHAR2 DEFAULT NULL,
                       p_token6        IN VARCHAR2 DEFAULT NULL,
                       p_token6_value  IN VARCHAR2 DEFAULT NULL,
                       p_token7        IN VARCHAR2 DEFAULT NULL,
                       p_token7_value  IN VARCHAR2 DEFAULT NULL,
                       p_token8        IN VARCHAR2 DEFAULT NULL,
                       p_token8_value  IN VARCHAR2 DEFAULT NULL,
                       p_token9        IN VARCHAR2 DEFAULT NULL,
                       p_token9_value  IN VARCHAR2 DEFAULT NULL,
                       p_token10       IN VARCHAR2 DEFAULT NULL,
                       p_token10_value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
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
  
    IF p_token6 IS NOT NULL THEN
      fnd_message.set_token(p_token6, p_token6_value);
    END IF;
    IF p_token7 IS NOT NULL THEN
      fnd_message.set_token(p_token7, p_token7_value);
    END IF;
    IF p_token8 IS NOT NULL THEN
      fnd_message.set_token(p_token8, p_token8_value);
    END IF;
    IF p_token9 IS NOT NULL THEN
      fnd_message.set_token(p_token9, p_token9_value);
    END IF;
    IF p_token10 IS NOT NULL THEN
      fnd_message.set_token(p_token10, p_token10_value);
    END IF;
  
    RETURN fnd_message.get;
  END get_message;

  --add by jiaming.zhou 2014-03-05 start
  PROCEDURE get_phase(p_task_id      IN NUMBER,
                      p_project_type OUT VARCHAR2,
                      p_phase        OUT VARCHAR2) IS
    CURSOR phase_c(p_task_id NUMBER) IS
      SELECT phase.attribute3,
             pa.project_type
        FROM pa_tasks        part,
             pa_tasks        phase,
             pa_projects_all pa
       WHERE phase.task_id = p_task_id
         AND pa.project_id = phase.project_id;
  BEGIN
  
    OPEN phase_c(p_task_id);
    FETCH phase_c
      INTO p_phase,
           p_project_type;
    IF phase_c%NOTFOUND THEN
      p_phase        := NULL;
      p_project_type := NULL;
    END IF;
    CLOSE phase_c;
  END;
  --add by jiaming.zhou 2014-03-05 end

  FUNCTION get_phase(p_task_id NUMBER) RETURN VARCHAR2 IS
    CURSOR phase_c(p_task_id NUMBER) IS
      SELECT pt.attribute3
        FROM pa_tasks pt
       WHERE pt.task_id = p_task_id;
  
    l_phase pa_tasks.attribute3%TYPE;
  BEGIN
  
    OPEN phase_c(p_task_id);
    FETCH phase_c
      INTO l_phase;
    IF phase_c%NOTFOUND THEN
      l_phase := NULL;
    END IF;
    CLOSE phase_c;
  
    RETURN l_phase;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  --only for goe so/vo interface
  FUNCTION get_make_mix_lookup(p_source IN VARCHAR2) RETURN VARCHAR2 AS
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
  
  BEGIN
    IF p_source = xxinv_item_imp_pub.g_source_make THEN
      l_lookup_type := l_lookup_schedule_make;
    ELSIF upper(p_source) = upper(xxinv_item_imp_pub.g_source_mixed) THEN
      l_lookup_type := l_lookup_schedule_mix;
    END IF;
    RETURN l_lookup_type;
  END;

  PROCEDURE insert_temp(p_task_id IN NUMBER) AS
  BEGIN
    INSERT INTO xxpjm_task_schedule_temp
      (task_id)
    VALUES
      (p_task_id);
  END;
  FUNCTION check_lookup_code_valid(p_lookup_type VARCHAR2,
                                   p_lookup_code VARCHAR2) RETURN VARCHAR2 AS
    CURSOR cur_lookup IS
      SELECT 'Y'
        FROM fnd_lookup_values_vl flv
       WHERE flv.lookup_type = p_lookup_type
         AND flv.lookup_code = p_lookup_code
         AND flv.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN nvl(flv.start_date_active, trunc(SYSDATE)) AND
             nvl(flv.end_date_active, trunc(SYSDATE));
    l_valid_flag VARCHAR2(1);
  BEGIN
    OPEN cur_lookup;
    FETCH cur_lookup
      INTO l_valid_flag;
    CLOSE cur_lookup;
    RETURN l_valid_flag;
  END;

  FUNCTION get_delivery_date(p_lookup_type           VARCHAR2,
                             p_part_task             IN VARCHAR2,
                             p_partial_delivery_date DATE,
                             p_final_delivery_date   DATE) RETURN DATE AS
    x_delivery_date DATE;
  BEGIN
    IF check_lookup_code_valid(p_lookup_type, p_part_task) = 'Y' THEN
      x_delivery_date := p_partial_delivery_date;
    ELSE
      x_delivery_date := p_final_delivery_date;
    END IF;
    IF x_delivery_date IS NULL THEN
      log('L_DELIVERY_DATE is null,please check!');
    END IF;
    RETURN x_delivery_date;
  END;

  FUNCTION check_is_part_task(p_task_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_task_part IS
      SELECT 'Y'
        FROM pa_tasks part
       WHERE part.task_id = p_task_id
         AND part.wbs_level = g_part_wbs_level
         AND part.attribute1 IS NOT NULL;
    l_valid_flag VARCHAR2(1) := 'N';
  BEGIN
    OPEN cur_task_part;
    FETCH cur_task_part
      INTO l_valid_flag;
    CLOSE cur_task_part;
    RETURN l_valid_flag;
  END;

  FUNCTION check_is_phase_task(p_task_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_task_phase IS
      SELECT 'Y'
        FROM pa_tasks phase
       WHERE phase.task_id = p_task_id
         AND phase.wbs_level = g_phase_wbs_level
         AND phase.attribute3 IS NOT NULL;
    l_valid_flag VARCHAR2(1) := 'N';
  BEGIN
    OPEN cur_task_phase;
    FETCH cur_task_phase
      INTO l_valid_flag;
    CLOSE cur_task_phase;
    RETURN l_valid_flag;
  END;

  FUNCTION check_phase_part_task(p_task_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_task IS
      SELECT 'Y'
        FROM pa_tasks phase,
             pa_tasks part
       WHERE phase.task_id = p_task_id
         AND phase.attribute3 IS NOT NULL
         AND part.parent_task_id = phase.task_id
         AND part.attribute1 IS NOT NULL;
    l_valid_flag VARCHAR2(1) := 'N';
  BEGIN
    OPEN cur_task;
    FETCH cur_task
      INTO l_valid_flag;
    CLOSE cur_task;
    RETURN l_valid_flag;
  END;

  FUNCTION get_working_ver_id(p_task_id NUMBER) RETURN NUMBER AS
    CURSOR cur_element_version_id IS
      SELECT pev.element_version_id
        FROM pa_proj_element_versions pev,
             pa_tasks                 pt
       WHERE pev.proj_element_id = pt.task_id
         AND pev.parent_structure_version_id = pa_project_structure_utils.get_current_working_ver_id(pev.project_id) --newest current woking 
         AND pt.task_id = p_task_id;
    l_cur_element_version_id NUMBER;
  BEGIN
    OPEN cur_element_version_id;
    FETCH cur_element_version_id
      INTO l_cur_element_version_id;
    CLOSE cur_element_version_id;
    RETURN l_cur_element_version_id;
  END;

  PROCEDURE get_max_min_schedule(p_phase_task_id        IN NUMBER,
                                 x_scheduled_start_date OUT DATE,
                                 x_scheduled_end_date   OUT DATE) AS
    CURSOR cur_part_task IS
      SELECT MIN(pev.scheduled_start_date),
             MAX(pev.scheduled_finish_date)
        FROM pa_tasks                     pt,
             pa_tasks                     phase,
             pa.pa_proj_elem_ver_schedule pev
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.attribute1 IS NOT NULL
         AND phase.task_id = p_phase_task_id
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 IS NOT NULL
         AND pev.element_version_id = get_working_ver_id(pt.task_id);
  BEGIN
    OPEN cur_part_task;
    FETCH cur_part_task
      INTO x_scheduled_start_date,
           x_scheduled_end_date;
    CLOSE cur_part_task;
  END;
  --get changed subtask min schedule start date  and max schedule end date under mfg to update billing and cost task
  PROCEDURE get_max_min_schedule_subtask(p_top_task_id          IN NUMBER,
                                         x_scheduled_start_date OUT DATE,
                                         x_scheduled_end_date   OUT DATE) AS
    CURSOR cur_part_task IS
      SELECT MIN(pev.scheduled_start_date),
             MAX(pev.scheduled_finish_date)
        FROM pa_tasks                     pt,
             pa.pa_proj_elem_ver_schedule pev,
             xxpjm_task_schedule_temp     tep
       WHERE pt.wbs_level > g_phase_wbs_level
         AND pt.attribute1 IS NOT NULL
         AND pt.top_task_id = p_top_task_id
         AND pev.element_version_id = get_working_ver_id(pt.task_id)
         AND tep.task_id = pt.task_id;
  BEGIN
    OPEN cur_part_task;
    FETCH cur_part_task
      INTO x_scheduled_start_date,
           x_scheduled_end_date;
    CLOSE cur_part_task;
  END;

  PROCEDURE get_task_schedule_date(p_element_version_id  IN NUMBER,
                                   x_schedule_start_date OUT DATE,
                                   x_schedule_end_date   OUT DATE) AS
    CURSOR cur_elem_ver_schedule IS
      SELECT scheduled_start_date,
             scheduled_finish_date
        FROM pa.pa_proj_elem_ver_schedule t
       WHERE t.element_version_id = p_element_version_id;
  BEGIN
    OPEN cur_elem_ver_schedule;
    FETCH cur_elem_ver_schedule
      INTO x_schedule_start_date,
           x_schedule_end_date;
    CLOSE cur_elem_ver_schedule;
  END;

  --only for private
  PROCEDURE get_lead_time(x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_task_id       IN NUMBER,
                          /*P_TASK_LEVEL_TYPE       IN VARCHAR2 DEFAULT 'PART', -- PART OR PHASE*/
                          x_use_time  OUT NUMBER,
                          x_lead_time OUT NUMBER) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'get_lead_time';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    CURSOR cur_task_part IS
      SELECT top_task.task_name top_task_name,
             part.top_task_id,
             part.attribute1    part,
             phase.attribute3   phase,
             pa.org_id
        FROM pa_tasks        part,
             pa_tasks        phase,
             pa_tasks        top_task,
             pa_projects_all pa
       WHERE part.task_id = p_task_id
         AND phase.task_id = part.parent_task_id
         AND top_task.task_id = part.top_task_id
         AND pa.project_id = phase.project_id
         AND part.attribute1 IS NOT NULL
         AND phase.attribute3 IS NOT NULL;
  
    CURSOR cur_task_phase IS
      SELECT top_task.task_name top_task_name,
             phase.top_task_id,
             phase.attribute3   phase,
             pa.org_id
        FROM pa_tasks        phase,
             pa_tasks        top_task,
             pa_projects_all pa
       WHERE phase.task_id = p_task_id
         AND top_task.task_id = phase.top_task_id
         AND pa.project_id = phase.project_id
         AND phase.attribute3 IS NOT NULL;
  
    CURSOR cur_org(p_org_id IN NUMBER) IS
      SELECT hou.name
        FROM hr_operating_units hou
       WHERE hou.organization_id = p_org_id;
    l_delivery_date         DATE;
    l_element_version_id    NUMBER;
    l_pev_schedule_id       NUMBER;
    l_record_version_number NUMBER;
    l_market                xxpjm_so_addtn_headers.market%TYPE;
    l_model                 xxpjm_so_addtn_lines.model%TYPE;
    l_source                xxpjm_so_addtn_lines.source%TYPE;
    l_lt_model              xxpjm_so_addtn_lines.lt_model%TYPE;
    l_org_id                NUMBER;
    l_top_task_id           NUMBER;
    l_part                  pa_tasks.attribute1%TYPE;
    l_phase                 pa_tasks.attribute3%TYPE;
    l_top_task_name         pa_tasks.task_name %TYPE;
    l_operating_unit        hr_operating_units.name%TYPE;
  BEGIN
    -- API body
    /*if P_TASK_LEVEL_TYPE='PART' then */
    IF check_is_part_task(p_task_id) = 'Y' THEN
      log('Task is  part task');
      OPEN cur_task_part;
      FETCH cur_task_part
        INTO l_top_task_name,
             l_top_task_id,
             l_part,
             l_phase,
             l_org_id;
      CLOSE cur_task_part;
      /*elsif P_TASK_LEVEL_TYPE='PHASE' then */
      --If task is not part 
    ELSIF check_is_phase_task(p_task_id) = 'Y' THEN
      log('Task is not part task');
      OPEN cur_task_phase;
      FETCH cur_task_phase
        INTO l_top_task_name,
             l_top_task_id,
             l_phase,
             l_org_id;
      CLOSE cur_task_phase;
    ELSE
      log('Task is not phase task or task is not valid,please check!');
      RETURN;
    END IF;
    /*else 
       LOG('PARAMETER P_TASK_LEVEL_TYPE IS NOT VALID');
    return ;
    END IF;*/
    --IF L_DEBUG = 'Y' THEN
    log('l_top_task_id:' || l_top_task_id);
    --END IF;
    --get market model info
    log('g_global_flag: ' || g_global_flag);
    IF g_global_flag = 'N' THEN
      log('-------------1');
      BEGIN
        --update by jiaming.zhou 2014-07-17 v1.0 start
        /*SELECT sah.market,
              sal.model,
              sal.source,
              sal.lt_model
         INTO l_market,
              l_model,
              l_source,
              l_lt_model
         FROM xxpjm_so_addtn_headers_all sah,
              xxpjm_so_addtn_lines_all   sal,
              pa_tasks                   pt,
              pa_projects_all            pp,
              oe_order_headers_all       ooh,
              oe_order_lines_all         ool
        WHERE pp.project_id = pt.project_id
             pp.segment1 = ooh.order_number
          AND ooh.org_id = pp.org_id
          AND ooh.header_id = sah.so_header_id
          AND sah.header_id = sal.header_id
          AND sal.so_line_id = ool.line_id
          AND ool.task_id = pt.task_id
          AND pt.top_task_id = l_top_task_id
          AND rownum = 1;*/
        SELECT market,
               model,
               SOURCE,
               lt_model
          INTO l_market,
               l_model,
               l_source,
               l_lt_model
          FROM (SELECT sah.market,
                       sal.model,
                       sal.source,
                       sal.lt_model
                  FROM xxpjm_so_addtn_headers_all sah,
                       xxpjm_so_addtn_lines_all   sal,
                       pa_tasks                   pt,
                       pa_projects_all            pp,
                       oe_order_headers_all       ooh,
                       oe_order_lines_all         ool
                 WHERE pp.project_id = pt.project_id
                   AND pp.segment1 = ooh.order_number
                   AND (pp.project_type NOT IN ('SHE FAC_Spare Parts', 'SHE FAC_Elevator', 'SHE FAC_Assy Parts') OR
                       ooh.org_id = 82)
                   AND ooh.org_id = pp.org_id
                   AND ooh.header_id = sah.so_header_id
                   AND sah.header_id = sal.header_id
                   AND sal.so_line_id = ool.line_id
                   AND ool.task_id = pt.task_id
                   AND pt.top_task_id = l_top_task_id
                   AND rownum = 1
                UNION ALL
                SELECT xool.market,
                       xool.model,
                       xool.source,
                       NULL lt_model
                  FROM xxom_oversea_order_lines_all xool,
                       pa_tasks                     pt,
                       pa_projects_all              pp,
                       oe_order_lines_all           ool
                 WHERE pp.project_id = pt.project_id
                   AND pp.project_id = ool.project_id
                   AND pp.project_type IN ('SHE FAC_Spare Parts', 'SHE FAC_Elevator', 'SHE FAC_Assy Parts')
                   AND ool.org_id = 84
                   AND xool.project_id = pp.project_id
                   AND ool.line_number = xool.line_number
                   AND ool.shipment_number = xool.shipment_number
                   AND ool.task_id = pt.task_id
                   AND pt.top_task_id = l_top_task_id
                   AND rownum = 1);
        --update by jiaming.zhou 2014-07-17 v1.0 end
        log('-------------2');
      
      EXCEPTION
        WHEN too_many_rows THEN
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := get_message(g_appl_name, 'XXPJM_007E_005', 'MFG_NO', l_top_task_name);
        WHEN no_data_found THEN
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := get_message(g_appl_name, 'XXPJM_007E_004', 'MFG_NO', l_top_task_name);
        WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          x_msg_data      := 'Calling procedure:get_lead_time do get market model info Occurred Error ' || SQLERRM;
      END;
      log('-------------3');
      log('-------------X_RETURN_STATUS:' || x_return_status);
      raise_exception(x_return_status);
      log('-------------4');
    ELSE
      l_market   := g_market;
      l_model    := g_model;
      l_source   := g_source;
      l_lt_model := g_lt_model;
    END IF;
  
    --IF l_debug = 'Y' THEN
    log('l_market:   ' || l_market);
    log('l_model:    ' || l_model);
    log('l_source:   ' || l_source);
    log('l_lt_model: ' || l_lt_model);
    log('l_org_id:   ' || l_org_id);
    log('l_phase:    ' || l_phase);
    log('l_part:     ' || l_part);
    --END IF;
  
    --get operating unit name
    OPEN cur_org(l_org_id);
    FETCH cur_org
      INTO l_operating_unit;
    CLOSE cur_org;
    --get lead tiem and use time
  
    BEGIN
      SELECT lt.use_time,
             lt.lead_time
        INTO x_use_time,
             x_lead_time
        FROM xxpjm_lead_time_all lt
       WHERE lt.org_id = l_org_id
         AND lt.market = l_market
         AND lt.source = l_source
         AND nvl(lt.lt_model, 'xxx') = nvl(l_lt_model, 'xxx')
         AND lt.model = l_model
         AND lt.phase = l_phase
         AND nvl(lt.part, 'xxx') = nvl(l_part, 'xxx');
    EXCEPTION
      WHEN no_data_found THEN
        --X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;   --updated by ouzhiwei 2012-06-18 if leat time is not maintain it shoutnot raise error 
        x_msg_data := get_message(g_appl_name,
                                  'XXPJM_007E_006',
                                  'OPERATING_UNIT',
                                  l_operating_unit,
                                  'MARKET',
                                  l_market,
                                  'MODEL',
                                  l_model,
                                  'SOURCE',
                                  l_source,
                                  'LT_MODEL',
                                  l_lt_model,
                                  'PHASE',
                                  l_phase,
                                  'PART',
                                  l_part);
      WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        x_msg_data      := 'Calling procedure:get_lead_time do get lead tiem and use time Occurred Error ' || SQLERRM;
    END;
    raise_exception(x_return_status);
    IF l_debug = 'Y' THEN
      log('x_use_time:  ' || x_use_time);
      log('x_lead_time: ' || x_lead_time);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END;
  --for publish use
  PROCEDURE get_phase_part_schedule_date(p_task_id             IN NUMBER, --the part task
                                         p_delivery_date       IN DATE, --part task shipping schedule end date
                                         x_schedule_start_date OUT DATE,
                                         x_schedule_end_date   OUT DATE,
                                         x_return_status       OUT VARCHAR2,
                                         x_msg_data            OUT VARCHAR2) AS
    CURSOR cur_org IS
      SELECT pa.org_id
        FROM pa_projects_all pa,
             pa_tasks        pt
       WHERE pa.project_id = pt.project_id
         AND pt.task_id = p_task_id;
  
    l_calendar_code             bom_calendars.calendar_code%TYPE;
    l_end_date                  DATE;
    l_work_days                 NUMBER;
    l_org_id                    NUMBER;
    l_calendar_exception_set_id NUMBER := -1;
    l_use_time                  NUMBER;
    l_lead_time                 NUMBER;
    l_before_after_flag         VARCHAR2(1);
    l_phase                     pa_tasks.attribute3%TYPE;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    --get lead time and use time
    --IF L_DEBUG = 'Y' THEN
    log('get lead time and use time');
    log('P_TASK_ID:' || p_task_id);
    --END IF;
    get_lead_time(x_return_status => x_return_status,
                  x_msg_data      => x_msg_data,
                  p_task_id       => p_task_id,
                  x_use_time      => l_use_time,
                  x_lead_time     => l_lead_time);
    raise_exception(x_return_status);
  
    l_phase := get_phase(p_task_id);
    log('l_phase: ' || l_phase);
  
    --added by ouzhiwei at 2012-06-18 
    --if leat time is not maintain it shoutnot raise error
    IF l_use_time IS NULL AND l_lead_time IS NULL THEN
      IF l_phase = xxpjm_project_public.g_shipping THEN
        x_schedule_end_date := p_delivery_date;
      END IF;
      RETURN;
    END IF;
    --get project org_id
    --IF L_DEBUG = 'Y' THEN
    log('get project org_id');
    --END IF;
    OPEN cur_org;
    FETCH cur_org
      INTO l_org_id;
    CLOSE cur_org;
    --get calendar code by attribute2
    --IF L_DEBUG = 'Y' THEN
    log('get calendar code by attribute2');
    --END IF;
    BEGIN
      SELECT bc.calendar_code
        INTO l_calendar_code
        FROM bom_calendars bc
       WHERE trunc(SYSDATE) BETWEEN bc.calendar_start_date AND bc.calendar_end_date
         AND bc.attribute2 = l_org_id;
    EXCEPTION
      WHEN no_data_found THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := get_message(g_appl_name, 'XXPJM_007E_002');
      WHEN too_many_rows THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := get_message(g_appl_name, 'XXPJM_007E_003');
      WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        x_msg_data      := 'Calling get_phase_part_schedule_date Occurred Error ' || SQLERRM;
    END;
    raise_exception(x_return_status);
    --begin get schedule start date and end date 
    --get schedule_end_date
    --IF L_DEBUG = 'Y' THEN
    log('get schedule_end_date');
    --END IF;
    l_work_days := nvl(l_lead_time, 0);
    IF l_work_days >= 0 THEN
      l_before_after_flag := xxbom_common_utl.g_before_flag;
    ELSE
      l_before_after_flag := xxbom_common_utl.g_after_flag;
    END IF;
    xxbom_common_utl.get_calendar_work_date(p_calendar_code             => l_calendar_code,
                                            p_calendar_exception_set_id => l_calendar_exception_set_id,
                                            p_before_after_flag         => l_before_after_flag,
                                            p_start_date                => p_delivery_date,
                                            p_work_days                 => abs(l_work_days),
                                            x_end_date                  => x_schedule_end_date,
                                            x_return_status             => x_return_status,
                                            x_msg_data                  => x_msg_data);
    log(x_msg_data);
    --IF L_DEBUG = 'Y' THEN
    log('P_DELIVERY_DATE:' || p_delivery_date);
    log('L_WORK_DAYS:' || l_work_days);
    log('X_SCHEDULE_END_DATE:' || x_schedule_end_date);
    --END IF;
    raise_exception(x_return_status);
    -- x_schedule_end_date   := p_delivery_date - nvl(p_lead_time, 0);                                        
    --get  schedule_start_date
    --IF L_DEBUG = 'Y' THEN
    log('get  schedule_start_date');
    --END IF;
  
    l_work_days := l_work_days + nvl(l_use_time, 0);
    IF l_work_days >= 0 THEN
      l_before_after_flag := xxbom_common_utl.g_before_flag;
    ELSE
      l_before_after_flag := xxbom_common_utl.g_after_flag;
    END IF;
    xxbom_common_utl.get_calendar_work_date(p_calendar_code             => l_calendar_code,
                                            p_calendar_exception_set_id => l_calendar_exception_set_id,
                                            p_before_after_flag         => l_before_after_flag,
                                            p_start_date                => p_delivery_date,
                                            p_work_days                 => abs(l_work_days),
                                            x_end_date                  => x_schedule_start_date,
                                            x_return_status             => x_return_status,
                                            x_msg_data                  => x_msg_data);
    log(x_msg_data);
    --IF L_DEBUG = 'Y' THEN
    log('P_DELIVERY_DATE:' || p_delivery_date);
    log('L_WORK_DAYS:' || l_work_days);
    log('X_SCHEDULE_START_DATE:' || x_schedule_start_date);
    --END IF;
    raise_exception(x_return_status);
    --end
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END;

  FUNCTION get_delivery_date(p_top_task_id NUMBER) RETURN DATE AS
  
    l_task_id             NUMBER;
    l_element_version_id  NUMBER;
    l_schedule_start_date DATE;
    l_schedule_end_date   DATE;
  BEGIN
    BEGIN
      --get shipping task id
      SELECT task_id
        INTO l_task_id
        FROM pa_tasks pt
       WHERE pt.top_task_id = p_top_task_id
         AND pt.wbs_level = g_phase_wbs_level
         AND attribute3 = xxpjm_project_public.g_shipping;
      --get working element_version_id
      l_element_version_id := get_working_ver_id(l_task_id);
      --task schedule date
      get_task_schedule_date(p_element_version_id  => l_element_version_id,
                             x_schedule_start_date => l_schedule_start_date,
                             x_schedule_end_date   => l_schedule_end_date);
    EXCEPTION
      WHEN no_data_found THEN
        --message
        NULL;
      WHEN too_many_rows THEN
        --message
        NULL;
      WHEN OTHERS THEN
        --message
        NULL;
    END;
    RETURN l_schedule_end_date;
  END;

  PROCEDURE update_task_schedule(p_init_msg_list        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 p_commit               IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_msg_count            OUT NOCOPY NUMBER,
                                 x_msg_data             OUT NOCOPY VARCHAR2,
                                 p_task_id              IN NUMBER,
                                 p_scheduled_start_date IN DATE := pa_interface_utils_pub.g_pa_miss_date,
                                 p_scheduled_end_date   IN DATE := pa_interface_utils_pub.g_pa_miss_date) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_task_schedule';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    l_delivery_date DATE;
    CURSOR cur_elem_ver_schedule(p_element_version_id NUMBER) IS
      SELECT pev_schedule_id,
             record_version_number
        FROM pa.pa_proj_elem_ver_schedule t
       WHERE t.element_version_id = p_element_version_id
         FOR UPDATE NOWAIT;
    l_element_version_id    NUMBER;
    l_pev_schedule_id       NUMBER;
    l_record_version_number NUMBER;
    l_log_meg               VARCHAR2(200);
  BEGIN
    -- logging parameters
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
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
    -- API body
    --get element_version_id
    IF l_debug = 'Y' THEN
      l_log_meg := 'get_working_ver_id';
      log(l_log_meg);
    END IF;
    l_element_version_id := get_working_ver_id(p_task_id);
    --get pev_schedule_id 
    IF l_debug = 'Y' THEN
      l_log_meg := 'get pev_schedule_id';
      log(l_log_meg);
    END IF;
    OPEN cur_elem_ver_schedule(l_element_version_id);
    FETCH cur_elem_ver_schedule
      INTO l_pev_schedule_id,
           l_record_version_number;
    CLOSE cur_elem_ver_schedule;
    --update SCHEDULE date 
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure xxpa_proj_public_pvt.update_schedule_version';
      log(l_log_meg);
      l_log_meg := '*******************P_TASK_ID:' || p_task_id;
      log(l_log_meg);
    END IF;
    xxpa_proj_public_pvt.update_schedule_version(p_pev_schedule_id       => l_pev_schedule_id,
                                                 p_record_version_number => l_record_version_number,
                                                 p_scheduled_start_date  => p_scheduled_start_date,
                                                 p_scheduled_end_date    => p_scheduled_end_date,
                                                 x_return_status         => x_return_status,
                                                 x_msg_count             => x_msg_count,
                                                 x_msg_data              => x_msg_data);
    IF l_debug = 'Y' THEN
      l_log_meg := 'end procedure xxpa_proj_public_pvt.update_schedule_version';
      log(l_log_meg);
      l_log_meg := 'x_return_status:' || x_return_status;
      log(l_log_meg);
      l_log_meg := 'x_msg_count:' || x_msg_count;
      log(l_log_meg);
      l_log_meg := 'x_msg_data:' || x_msg_data;
      log(l_log_meg);
    END IF;
    raise_exception(x_return_status);
    l_index := l_index + 1;
    l_task_tab(l_index) := p_task_id;
    --insert temp table
    insert_temp(p_task_id);
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
    IF l_debug = 'Y' THEN
      l_log_meg := 'end procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
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
  END update_task_schedule;

  PROCEDURE update_task_schedule(p_init_msg_list     IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 p_commit            IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 x_msg_data          OUT NOCOPY VARCHAR2,
                                 p_target_task_id    IN NUMBER,
                                 p_reference_task_id IN NUMBER) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_task_schedule';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    l_delivery_date DATE;
    CURSOR cur_elem_ver_schedule(p_element_version_id NUMBER) IS
      SELECT pev_schedule_id,
             record_version_number
        FROM pa.pa_proj_elem_ver_schedule t
       WHERE t.element_version_id = p_element_version_id
         FOR UPDATE NOWAIT;
    l_element_version_id    NUMBER;
    l_pev_schedule_id       NUMBER;
    l_record_version_number NUMBER;
    l_schedule_start_date   DATE;
    l_schedule_end_date     DATE;
    l_log_meg               VARCHAR2(200);
  BEGIN
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
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
    -- API body
    --get working element_version_id
    IF l_debug = 'Y' THEN
      l_log_meg := 'get working element_version_id';
      log(l_log_meg);
    END IF;
    l_element_version_id := get_working_ver_id(p_reference_task_id);
    --get task scheduled date
    IF l_debug = 'Y' THEN
      l_log_meg := 'get task scheduled date';
      log(l_log_meg);
    END IF;
    get_task_schedule_date(p_element_version_id  => l_element_version_id,
                           x_schedule_start_date => l_schedule_start_date,
                           x_schedule_end_date   => l_schedule_end_date);
    -- update_task_schedule
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure update_task_schedule';
      log(l_log_meg);
    END IF;
    log('L_SCHEDULE_END_DATE:' || l_schedule_end_date);
    update_task_schedule(p_init_msg_list        => p_init_msg_list,
                         p_commit               => p_commit,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         p_task_id              => p_target_task_id,
                         p_scheduled_start_date => l_schedule_start_date,
                         p_scheduled_end_date   => l_schedule_end_date);
    IF l_debug = 'Y' THEN
      l_log_meg := 'end procedure update_task_schedule';
      log(l_log_meg);
      l_log_meg := 'x_return_status:' || x_return_status;
      log(l_log_meg);
      l_log_meg := 'x_msg_count:' || x_msg_count;
      log(l_log_meg);
      l_log_meg := 'x_msg_data:' || x_msg_data;
      log(l_log_meg);
    END IF;
    raise_exception(x_return_status);
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
    IF l_debug = 'Y' THEN
      l_log_meg := 'end procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
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
  END update_task_schedule;

  --add by jiaming.zhou 2014-03-05 start
  PROCEDURE update_speci_part_schedule(p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                       p_commit                IN VARCHAR2 DEFAULT fnd_api.g_false,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2,
                                       p_task_id               IN NUMBER,
                                       p_partial_delivery_date IN DATE,
                                       p_final_delivery_date   IN DATE) IS
    CURSOR cur_org IS
      SELECT pa.org_id
        FROM pa_projects_all pa,
             pa_tasks        pt
       WHERE pa.project_id = pt.project_id
         AND pt.task_id = p_task_id;
    l_api_name CONSTANT VARCHAR2(60) := 'update_specification_part_schedule';
    l_use_time                  NUMBER;
    l_lead_time                 NUMBER;
    l_log_meg                   VARCHAR2(200);
    l_schedule_start_date       DATE;
    l_schedule_end_date         DATE;
    l_work_days                 NUMBER;
    l_org_id                    NUMBER;
    l_before_after_flag         xxbom_common_utl.g_before_flag%TYPE;
    l_calendar_code             bom_calendars.calendar_code%TYPE;
    l_calendar_exception_set_id NUMBER := -1;
  BEGIN
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
    get_lead_time(x_return_status => x_return_status,
                  x_msg_data      => x_msg_data,
                  p_task_id       => p_task_id,
                  x_use_time      => l_use_time,
                  x_lead_time     => l_lead_time);
    IF l_debug = 'Y' THEN
      l_log_meg := 'get  schedule start date and end date use lead time';
      log('use_time:' || l_use_time);
      log('lead_time:' || l_lead_time);
      log(l_log_meg);
    END IF;
  
    OPEN cur_org;
    FETCH cur_org
      INTO l_org_id;
    CLOSE cur_org;
  
    log('get calendar code by attribute2');
    BEGIN
      SELECT bc.calendar_code
        INTO l_calendar_code
        FROM bom_calendars bc
       WHERE trunc(SYSDATE) BETWEEN bc.calendar_start_date AND bc.calendar_end_date
         AND bc.attribute2 = l_org_id;
    EXCEPTION
      WHEN no_data_found THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := get_message(g_appl_name, 'XXPJM_007E_002');
      WHEN too_many_rows THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := get_message(g_appl_name, 'XXPJM_007E_003');
      WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        x_msg_data      := 'Calling get_phase_part_schedule_date Occurred Error ' || SQLERRM;
    END;
    raise_exception(x_return_status);
  
    log('get schedule_end_date');
    l_work_days := nvl(l_lead_time, 0);
    IF l_work_days >= 0 THEN
      l_before_after_flag := xxbom_common_utl.g_before_flag;
    ELSE
      l_before_after_flag := xxbom_common_utl.g_after_flag;
    END IF;
    xxbom_common_utl.get_calendar_work_date(p_calendar_code             => l_calendar_code,
                                            p_calendar_exception_set_id => l_calendar_exception_set_id,
                                            p_before_after_flag         => l_before_after_flag,
                                            p_start_date                => p_final_delivery_date,
                                            p_work_days                 => abs(l_work_days),
                                            x_end_date                  => l_schedule_end_date,
                                            x_return_status             => x_return_status,
                                            x_msg_data                  => x_msg_data);
    --update by jiaming.zhou 20140604 start
    --IF abs(l_schedule_end_date - p_partial_delivery_date) <= 3 * 30 THEN
    IF abs(l_schedule_end_date - p_partial_delivery_date) <= 3 * 30 AND (l_lead_time <> 0 OR nvl(l_use_time, 0) <> 0) THEN
      --update by jiaming.zhou 20140604 end
      xxbom_common_utl.get_calendar_work_date(p_calendar_code             => l_calendar_code,
                                              p_calendar_exception_set_id => l_calendar_exception_set_id,
                                              p_before_after_flag         => l_before_after_flag,
                                              p_start_date                => p_partial_delivery_date,
                                              p_work_days                 => 90,
                                              x_end_date                  => l_schedule_end_date,
                                              x_return_status             => x_return_status,
                                              x_msg_data                  => x_msg_data);
    END IF;
    log(x_msg_data);
    IF l_debug = 'Y' THEN
      log('L_WORK_DAYS:' || l_work_days);
      log('X_SCHEDULE_END_DATE:' || l_schedule_end_date);
    END IF;
    raise_exception(x_return_status);
  
    l_work_days := l_work_days + nvl(l_use_time, 0);
    IF l_work_days >= 0 THEN
      l_before_after_flag := xxbom_common_utl.g_before_flag;
    ELSE
      l_before_after_flag := xxbom_common_utl.g_after_flag;
    END IF;
    xxbom_common_utl.get_calendar_work_date(p_calendar_code             => l_calendar_code,
                                            p_calendar_exception_set_id => l_calendar_exception_set_id,
                                            p_before_after_flag         => l_before_after_flag,
                                            p_start_date                => p_partial_delivery_date,
                                            p_work_days                 => abs(l_work_days),
                                            x_end_date                  => l_schedule_start_date,
                                            x_return_status             => x_return_status,
                                            x_msg_data                  => x_msg_data);
    log(x_msg_data);
    IF l_debug = 'Y' THEN
      log('L_WORK_DAYS:' || l_work_days);
      log('X_SCHEDULE_START_DATE:' || l_schedule_start_date);
    END IF;
    raise_exception(x_return_status);
  
    dbms_output.put_line(l_schedule_start_date);
    dbms_output.put_line(l_schedule_end_date);
    dbms_output.put_line(p_task_id);
    update_task_schedule(p_init_msg_list        => p_init_msg_list,
                         p_commit               => p_commit,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         p_task_id              => p_task_id,
                         p_scheduled_start_date => l_schedule_start_date,
                         p_scheduled_end_date   => l_schedule_end_date);
    IF l_debug = 'Y' THEN
      l_log_meg := 'end procedure update_task_schedule';
      log(l_log_meg);
      l_log_meg := 'x_return_status:' || x_return_status;
      log(l_log_meg);
      l_log_meg := 'x_msg_count:' || x_msg_count;
      log(l_log_meg);
      l_log_meg := 'x_msg_data:' || x_msg_data;
      log(l_log_meg);
    END IF;
    dbms_output.put_line(x_msg_data);
    raise_exception(x_return_status);
    x_return_status := fnd_api.g_ret_sts_success;
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END;
  --add by jiaming.zhou 2014-03-05 end

  PROCEDURE update_phase_part_schedule(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                       p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_msg_count     OUT NOCOPY NUMBER,
                                       x_msg_data      OUT NOCOPY VARCHAR2,
                                       p_task_id       IN NUMBER,
                                       p_delivery_date IN DATE) IS
    CURSOR cur_task_phase_part IS
      SELECT phase.project_id,
             phase.attribute3 phase,
             part.attribute1  part
        FROM pa_tasks phase,
             pa_tasks part
       WHERE phase.task_id = part.parent_task_id
         AND part.task_id = p_task_id
         AND part.wbs_level = g_part_wbs_level;
    l_api_name       CONSTANT VARCHAR2(30) := 'update_phase_part_schedule';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    l_schedule_start_date DATE;
    l_schedule_end_date   DATE;
    l_use_time            NUMBER;
    l_lead_time           NUMBER;
    l_project_id          NUMBER;
    l_log_meg             VARCHAR2(200);
    l_phase               pa_tasks.attribute3%TYPE;
    l_part                pa_tasks.attribute1%TYPE;
  BEGIN
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
    -- start activity to create savepoint, check compatibility
    -- and initialize message list, include debug message hint to enter api
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
  
    /*  --get phase and part type
    OPEN CUR_TASK_PHASE_PART;
    FETCH CUR_TASK_PHASE_PART
      INTO L_PROJECT_ID, L_PHASE, L_PART;
    CLOSE CUR_TASK_PHASE_PART;*/
    --get  schedule start date and end date use lead time 
    IF l_debug = 'Y' THEN
      l_log_meg := 'get  schedule start date and end date use lead time';
      log(l_log_meg);
    END IF;
    get_phase_part_schedule_date(p_task_id             => p_task_id,
                                 p_delivery_date       => p_delivery_date,
                                 x_schedule_start_date => l_schedule_start_date,
                                 x_schedule_end_date   => l_schedule_end_date,
                                 x_return_status       => x_return_status,
                                 x_msg_data            => x_msg_data);
    raise_exception(x_return_status);
  
    l_phase := get_phase(p_task_id);
    -- For shipping, need to change date
    IF l_schedule_start_date IS NULL AND l_phase = xxpjm_project_public.g_shipping THEN
      update_task_schedule(p_init_msg_list        => p_init_msg_list,
                           p_commit               => p_commit,
                           x_return_status        => x_return_status,
                           x_msg_count            => x_msg_count,
                           x_msg_data             => x_msg_data,
                           p_task_id              => p_task_id,
                           p_scheduled_start_date => l_schedule_end_date,
                           p_scheduled_end_date   => l_schedule_end_date);
      RETURN;
    END IF;
  
    --added by ouzhiwei at 2012-06-18 
    --if leat time is not maintain it shoutnot raise error
    IF l_schedule_start_date IS NULL THEN
      RETURN;
    END IF;
    --update task schedule
    IF l_debug = 'Y' THEN
      l_log_meg := 'l_schedule_start_date:' || l_schedule_start_date;
      log(l_log_meg);
      l_log_meg := 'l_schedule_end_date:' || l_schedule_end_date;
      log(l_log_meg);
      l_log_meg := 'begin procedure update_task_schedule';
    END IF;
  
    update_task_schedule(p_init_msg_list        => p_init_msg_list,
                         p_commit               => p_commit,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         p_task_id              => p_task_id,
                         p_scheduled_start_date => l_schedule_start_date,
                         p_scheduled_end_date   => l_schedule_end_date);
    IF l_debug = 'Y' THEN
      l_log_meg := 'end procedure update_task_schedule';
      log(l_log_meg);
      l_log_meg := 'x_return_status:' || x_return_status;
      log(l_log_meg);
      l_log_meg := 'x_msg_count:' || x_msg_count;
      log(l_log_meg);
      l_log_meg := 'x_msg_data:' || x_msg_data;
      log(l_log_meg);
    END IF;
    raise_exception(x_return_status);
    x_return_status := fnd_api.g_ret_sts_success;
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END;

  PROCEDURE update_other_subtask(p_project_id  IN NUMBER,
                                 p_top_task_id IN NUMBER,
                                 --update by jiaming.zhou 2013-12-31 start
                                 --p_update_shipping_phase_only IN VARCHAR2 DEFAULT NULL,
                                 --update by jiaming.zhou 2013-12-31 end
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2) AS
    CURSOR cur_phase_task IS
      SELECT pt.task_id,
             pt.attribute3 phase
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute3 IS NOT NULL
         AND EXISTS (SELECT 1
                FROM xxpjm_task_schedule_temp tep,
                     pa_tasks                 part
               WHERE part.task_id = tep.task_id
                 AND part.parent_task_id = pt.task_id
                 AND part.attribute1 IS NOT NULL);
  
    CURSOR cur_other_subtask(p_phase_task_id IN NUMBER) IS
      SELECT pt.task_id
        FROM pa_tasks pt
       WHERE pt.attribute1 IS NULL
         AND pt.parent_task_id = p_phase_task_id;
    x_schedule_start_date DATE;
    x_schedule_end_date   DATE;
  BEGIN
  
    FOR rec_phase_tasks IN cur_phase_task
    LOOP
    
      --update by jiaming.zhou 2013-12-31 start
      /*      IF nvl(p_update_shipping_phase_only, 'N') = 'Y' AND
         rec_phase_tasks.phase <> xxpjm_project_public.g_shipping THEN
        GOTO next_loop;
      END IF;*/
      --update by jiaming.zhou 2013-12-31 end
    
      --get schedule date
      get_max_min_schedule(p_phase_task_id        => rec_phase_tasks.task_id,
                           x_scheduled_start_date => x_schedule_start_date,
                           x_scheduled_end_date   => x_schedule_end_date);
      IF x_schedule_start_date IS NULL AND x_schedule_end_date IS NULL THEN
        log('PHASE:' || rec_phase_tasks.phase || ' TASK_ID:' || rec_phase_tasks.task_id ||
            ' X_SCHEDULE_START_DATE AND X_SCHEDULE_END_DATE IS NULL');
        GOTO next_loop;
      END IF;
      FOR rec_other_subtasks IN cur_other_subtask(rec_phase_tasks.task_id)
      LOOP
        --update others subtask schedule date 
        update_task_schedule(x_return_status        => x_return_status,
                             x_msg_count            => x_msg_count,
                             x_msg_data             => x_msg_data,
                             p_task_id              => rec_other_subtasks.task_id,
                             p_scheduled_start_date => x_schedule_start_date,
                             p_scheduled_end_date   => x_schedule_end_date);
      END LOOP;
      <<next_loop>>
      NULL;
    END LOOP;
  END;

  PROCEDURE handle_proj_mfg(p_project_id  IN NUMBER,
                            p_top_task_id IN NUMBER,
                            --update by jiaming.zhou 2014-03-10 start
                            --p_schedule_end_date IN DATE,
                            p_partial_delivery_date IN DATE,
                            p_final_delivery_date   IN DATE,
                            --update by jiaming.zhou 2014-03-10 end
                            --update by jiaming.zhou 2013-12-31 start
                            --p_update_shipping_phase_only IN VARCHAR2 DEFAULT NULL, --Added by fandong.chen 20130717
                            --update by jiaming.zhou 2013-12-31 end
                            p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2) AS
  
    CURSOR cur_task(x_project_id  NUMBER,
                    x_top_task_id IN NUMBER) IS
      SELECT pt.top_task_id,
             pt.task_number,
             pt.task_id,
             pt.attribute3 phase,
             decode(ptt.task_type, 'EQ COST', 'Y', 'ER COST', 'Y', 'FM COST', 'Y', NULL) cost_task,
             pt_top.task_number mfg_number,
             pp.segment1 project_number
        FROM pa_tasks         pt,
             pa_tasks         pt_top,
             pa_projects      pp,
             pa_task_types    ptt,
             pa_proj_elements ppe
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = x_project_id
         AND pt.top_task_id = x_top_task_id
         AND pp.project_id = pt.project_id
         AND ptt.task_type_id = ppe.type_id
         AND ppe.proj_element_id = pt.task_id
         AND pt_top.task_id = pt.top_task_id
            --update by jiaming.zhou v2.0 start
            --AND (pt.attribute3 <> g_installation OR pt.attribute3 IS NULL) --add by gusenlin 2013-12-31 start
         AND (pt.attribute3 <> g_installation OR pp.org_id = 84 AND pt.attribute3 = g_installation OR
             pt.attribute3 IS NULL) --add by gusenlin 2013-12-31 start
      --update by jiaming.zhou v2.0 end
       ORDER BY pt.project_id,
                pt.top_task_id,
                pt.task_id;
  
    CURSOR cur_part_task(p_project_id  NUMBER,
                         p_top_task_id NUMBER,
                         p_part_type   VARCHAR2) IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt,
             pa_tasks phase
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 = p_part_type
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 <> xxpjm_project_public.g_shipping;
  
    CURSOR cur_subtask(p_task_id NUMBER) IS
      SELECT task_id,
             task_number,
             wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt
       WHERE pt.wbs_level > g_phase_wbs_level
       START WITH task_id = p_task_id
      CONNECT BY PRIOR task_id = pt.parent_task_id
       ORDER BY pt.wbs_level DESC;
  
    CURSOR cur_shipping_part_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1 part,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt,
             pa_tasks phase
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 IS NOT NULL
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_scheduled_start_date(p_task_id NUMBER) IS
      SELECT scheduled_start_date
        FROM pa.pa_proj_elem_ver_schedule t
       WHERE t.element_version_id = get_working_ver_id(p_task_id);
  
    CURSOR cur_shipping_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_no_shipping_tasks IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute3 != xxpjm_project_public.g_shipping
         AND 1 != nvl(pa_task_utils.check_child_exists(pt.task_id), 0);
  
    CURSOR cur_phase_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = nvl(p_top_task_id, pt.top_task_id);
  
    CURSOR cur_tep_task(p_task_id IN NUMBER) IS
      SELECT 'Y'
        FROM xxpjm_task_schedule_temp tep
       WHERE tep.task_id = p_task_id;
    l_element_version_id      NUMBER;
    l_log_meg                 VARCHAR2(200);
    l_proj_mfg                VARCHAR2(200);
    l_valid_flag              VARCHAR2(1);
    x_published_struct_ver_id NUMBER;
    x_schedule_end_date       DATE;
    x_schedule_start_date     DATE;
    l_schedule_start_date     DATE;
    l_schedule_end_date       DATE;
    l_lookup_type             fnd_lookup_types.lookup_type%TYPE;
    --add by jiaming.zhou 2014-03-04 start
    l_phase        pa_tasks.attribute3%TYPE;
    l_project_type pa_projects_all.project_type%TYPE;
    --add by jiaming.zhou 2014-03-04 end
  BEGIN
    log('process 10-50:begin loop REC_SHIPPING_TASK');
  
    /*FOR one_task IN cur_no_shipping_tasks LOOP
    
      update_phase_part_schedule(p_init_msg_list,
                                 p_commit,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 one_task.task_id,
                                 p_schedule_end_date);
                                       
    END LOOP;*/
  
    FOR rec_tasks IN cur_task(p_project_id, p_top_task_id)
    LOOP
      l_proj_mfg := 'project_number:' || rec_tasks.project_number || ' mfg_number:' || rec_tasks.mfg_number ||
                    ' task_number:' || rec_tasks.task_number;
      /*IF L_DELIVERY_DATE IS NULL THEN
        L_DELIVERY_DATE := GET_DELIVERY_DATE(REC_TASKS.TOP_TASK_ID);
        IF L_DELIVERY_DATE IS NULL THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;*/
      IF l_debug = 'Y' THEN
        l_log_meg := 'begin loop rec_subtasks';
        log(l_log_meg);
      END IF;
      log('process 10-50-40-10:begin loop REC_SUBTASKS');
      /*FOR REC_SUBTASKS IN CUR_SUBTASK(REC_TASKS.TASK_ID) LOOP
        L_PROJ_MFG := 'project_number:' || REC_TASKS.PROJECT_NUMBER ||
                      ' mfg_number:' || REC_TASKS.MFG_NUMBER ||
                      ' subtask:' || REC_SUBTASKS.TASK_NUMBER;
        --update parts scheduled date 
        IF REC_SUBTASKS.WBS_LEVEL = 3 AND REC_SUBTASKS.PART IS NOT NULL THEN
          NULL;
          \*update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                     p_commit        => p_commit,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_task_id       => rec_subtasks.task_id,
                                     p_delivery_date => l_delivery_date,
                                     p_phase         => rec_tasks.phase,
                                     p_part          => rec_subtasks.part);
          IF l_debug = 'Y' THEN
            log(l_log_meg);
            l_log_meg := 'x_return_status:' || x_return_status;
            log(l_log_meg);
            l_log_meg := 'x_msg_count:' || x_msg_count;
            log(l_log_meg);
            l_log_meg := 'x_msg_data:' || x_msg_data;
            log(l_log_meg);
          END IF;
          raise_exception(x_return_status);*\
          --update other subtask scheduled date use phase task scheduled date
        ELSE
          UPDATE_TASK_SCHEDULE(P_INIT_MSG_LIST     => P_INIT_MSG_LIST,
                               P_COMMIT            => P_COMMIT,
                               X_RETURN_STATUS     => X_RETURN_STATUS,
                               X_MSG_COUNT         => X_MSG_COUNT,
                               X_MSG_DATA          => X_MSG_DATA,
                               P_TARGET_TASK_ID    => REC_SUBTASKS.TASK_ID,
                               P_REFERENCE_TASK_ID => REC_TASKS.TASK_ID);
          IF L_DEBUG = 'Y' THEN
            LOG(L_LOG_MEG);
            L_LOG_MEG := 'x_return_status:' || X_RETURN_STATUS;
            LOG(L_LOG_MEG);
            L_LOG_MEG := 'x_msg_count:' || X_MSG_COUNT;
            LOG(L_LOG_MEG);
            L_LOG_MEG := 'x_msg_data:' || X_MSG_DATA;
            LOG(L_LOG_MEG);
          END IF;
          RAISE_EXCEPTION(X_RETURN_STATUS);
          L_INDEX := L_INDEX + 1;
          L_TASK_TAB(L_INDEX) := REC_SUBTASKS.TASK_ID;
        END IF;
      END LOOP;*/
      log('process 10-50-40-20:end loop REC_SUBTASKS');
      IF l_debug = 'Y' THEN
        l_log_meg := 'end loop rec_subtasks';
        log(l_log_meg);
      END IF;
    
      --update by jiaming.zhou 2013-12-31 start
      /*      
      \**********************
      --update shipping only     
      \***********************\
      IF nvl(p_update_shipping_phase_only, 'N') = 'Y' AND
         nvl(rec_tasks.phase, '@#$%') <> xxpjm_project_public.g_shipping THEN
        GOTO next_loop;
      END IF;*/
      --update by jiaming.zhou 2013-12-31 end
    
      -- task dont have subtask
      IF nvl(pa_task_utils.check_child_exists(rec_tasks.task_id), 0) <> 1 THEN
        log('process 10-50-40-30:task dont have subtask');
        --update phase 
        IF /*REC_TASKS.PHASE in                                                                                                                                                   XXPJM_PROJECT_PUBLIC.G_BILLING)*/
         rec_tasks.phase IS NOT NULL OR rec_tasks.cost_task IS NOT NULL THEN
          log('update others phase:' || rec_tasks.phase);
          log('REC_TASKS.TASK_ID:' || rec_tasks.task_id);
          --add by jiaming.zhou 2014-03-05 start
          /*log('P_SCHEDULE_END_DATE:' || p_schedule_end_date);
          update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
          p_commit        => p_commit,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_task_id       => rec_tasks.task_id,
          p_delivery_date => p_schedule_end_date);*/
          log('P_PARTIAL_DELIVERY_DATE:' || p_partial_delivery_date);
          log('P_FINAL_DELIVERY_DATE:' || p_final_delivery_date);
          get_phase(rec_tasks.task_id, l_project_type, l_phase);
        
          IF nvl(l_phase, g_miss_char) = g_specification AND
             nvl(p_final_delivery_date, g_miss_date) <> p_partial_delivery_date AND
             (l_project_type IN ('B', 'E') AND xxpjm_proj_generation_pkg.g_call_flag = 'Y' OR
              l_project_type IN ('C', 'D') AND xxpjm_so_generate_project_pkg.g_call_flag = 'Y' OR
              l_project_type IN ('B', 'C', 'D', 'E', 'M', 'F') AND xxpjm_tasks_scheduled_upt_pkg.g_call_flag = 'Y' OR
              l_project_type IN ('B', 'C', 'D', 'E', 'M', 'F') AND g_call_flag = 'Y') THEN
            update_speci_part_schedule(p_init_msg_list         => p_init_msg_list,
                                       p_commit                => p_commit,
                                       x_return_status         => x_return_status,
                                       x_msg_count             => x_msg_count,
                                       x_msg_data              => x_msg_data,
                                       p_task_id               => rec_tasks.task_id,
                                       p_partial_delivery_date => p_partial_delivery_date,
                                       p_final_delivery_date   => p_final_delivery_date);
          ELSE
            update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                       p_commit        => p_commit,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_task_id       => rec_tasks.task_id,
                                       p_delivery_date => p_partial_delivery_date);
          END IF;
          --add by jiaming.zhou 2014-03-05 end  
          IF l_debug = 'Y' THEN
            log(l_log_meg);
            l_log_meg := 'x_return_status:' || x_return_status;
            log(l_log_meg);
            l_log_meg := 'x_msg_count:' || x_msg_count;
            log(l_log_meg);
            l_log_meg := 'x_msg_data:' || x_msg_data;
            log(l_log_meg);
          END IF;
          IF nvl(x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
            RETURN;
          END IF;
          /*L_INDEX := L_INDEX + 1;
          L_TASK_TAB(L_INDEX) := REC_TASKS.TASK_ID;*/
        END IF;
      
        --update phase or cost task scheduled date use top task  scheduled date
        --get changed subtask min schedule start date  and max schedule end date under mfg to update billing and cost task
        /*IF REC_TASKS.PHASE IN
           (XXPJM_PROJECT_PUBLIC.G_BILLING \*, XXPJM_PROJECT_PUBLIC.G_WARRANTY*\) OR
           REC_TASKS.COST_TASK IS NOT NULL THEN
          log('REC_TASKS.COST_TASK:' || REC_TASKS.COST_TASK);
          --
          get_max_min_schedule_subtask(p_TOP_task_id          => REC_TASKS.TOP_TASK_ID,
                                       x_scheduled_start_date => X_SCHEDULE_START_DATE,
                                       x_scheduled_end_date   => X_SCHEDULE_END_DATE);
          \*UPDATE_TASK_SCHEDULE(P_INIT_MSG_LIST     => P_INIT_MSG_LIST,
          P_COMMIT            => P_COMMIT,
          X_RETURN_STATUS     => X_RETURN_STATUS,
          X_MSG_COUNT         => X_MSG_COUNT,
          X_MSG_DATA          => X_MSG_DATA,
          P_TARGET_TASK_ID    => REC_TASKS.TASK_ID,
          P_REFERENCE_TASK_ID => REC_TASKS.TOP_TASK_ID);*\
          UPDATE_TASK_SCHEDULE(P_INIT_MSG_LIST        => P_INIT_MSG_LIST,
                               P_COMMIT               => P_COMMIT,
                               X_RETURN_STATUS        => X_RETURN_STATUS,
                               X_MSG_COUNT            => X_MSG_COUNT,
                               X_MSG_DATA             => X_MSG_DATA,
                               P_TASK_ID              => REC_TASKS.TASK_ID,
                               P_SCHEDULED_START_DATE => X_SCHEDULE_START_DATE,
                               P_SCHEDULED_END_DATE   => X_SCHEDULE_END_DATE);
            
          IF L_DEBUG = 'Y' THEN
            LOG(L_LOG_MEG);
            L_LOG_MEG := 'x_return_status:' || X_RETURN_STATUS;
            LOG(L_LOG_MEG);
            L_LOG_MEG := 'x_msg_count:' || X_MSG_COUNT;
            LOG(L_LOG_MEG);
            L_LOG_MEG := 'x_msg_data:' || X_MSG_DATA;
            LOG(L_LOG_MEG);
          END IF;
          RAISE_EXCEPTION(X_RETURN_STATUS);
          \*L_INDEX := L_INDEX + 1;
          L_TASK_TAB(L_INDEX) := REC_TASKS.TASK_ID;*\
        END IF;*/
      ELSE
        IF check_phase_part_task(rec_tasks.task_id) = 'N' THEN
          IF rec_tasks.phase IS NOT NULL OR rec_tasks.cost_task IS NOT NULL THEN
            log('update others phase:' || rec_tasks.phase);
            log('REC_TASKS.TASK_ID:' || rec_tasks.task_id);
            log('P_FINAL_DELIVERY_DATE:' || p_final_delivery_date);
          
            update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                       p_commit        => p_commit,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_task_id       => rec_tasks.task_id,
                                       --update by jiaming.zhou 2014-03-10 start
                                       --p_delivery_date => p_schedule_end_date
                                       p_delivery_date => p_partial_delivery_date
                                       --update by jiaming.zhou 2014-03-10 end
                                       );
          
            IF l_debug = 'Y' THEN
              log(l_log_meg);
              l_log_meg := 'x_return_status:' || x_return_status;
              log(l_log_meg);
              l_log_meg := 'x_msg_count:' || x_msg_count;
              log(l_log_meg);
              l_log_meg := 'x_msg_data:' || x_msg_data;
              log(l_log_meg);
            END IF;
            IF nvl(x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
              RETURN;
            END IF;
          END IF;
          --If phase task had update schedule then do this
          OPEN cur_tep_task(rec_tasks.task_id);
          FETCH cur_tep_task
            INTO l_valid_flag;
          CLOSE cur_tep_task;
          IF l_valid_flag = 'Y' THEN
            FOR rec_subtasks IN cur_subtask(rec_tasks.task_id)
            LOOP
            
              update_task_schedule(p_init_msg_list     => p_init_msg_list,
                                   p_commit            => p_commit,
                                   x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data,
                                   p_target_task_id    => rec_subtasks.task_id,
                                   p_reference_task_id => rec_tasks.task_id);
              IF l_debug = 'Y' THEN
                log(l_log_meg);
                l_log_meg := 'x_return_status:' || x_return_status;
                log(l_log_meg);
                l_log_meg := 'x_msg_count:' || x_msg_count;
                log(l_log_meg);
                l_log_meg := 'x_msg_data:' || x_msg_data;
                log(l_log_meg);
              END IF;
              IF nvl(x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
                RETURN;
              END IF;
            END LOOP;
          END IF;
        
        ELSIF rec_tasks.phase = xxpjm_project_public.g_shipping THEN
          log('update others phase: ' || rec_tasks.phase);
          log('REC_TASKS.TASK_ID:   ' || rec_tasks.task_id);
          log('P_PARTIAL_DELIVERY_DATE: ' || p_partial_delivery_date);
        
          update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                     p_commit        => p_commit,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_task_id       => rec_tasks.task_id,
                                     --update by jiaming.zhou 2014-03-10 start
                                     --p_delivery_date => p_schedule_end_date
                                     p_delivery_date => p_partial_delivery_date
                                     --update by jiaming.zhou 2014-03-10 end
                                     );
        END IF;
      END IF;
    
      --update by jiaming.zhou 2013-12-31 start
      --<<next_loop>>
      --update by jiaming.zhou 2013-12-31 end
      NULL;
    
    END LOOP;
    log('process 10-50-50:end loop REC_TASKS');
  
    log('process 10-60:end loop REC_SHIPPING_TASK');
    IF l_debug = 'Y' THEN
      l_log_meg := 'end loop rec_tasks';
      log(l_log_meg);
    END IF;
  
    --rollup task
    FOR i IN 1 .. l_index
    LOOP
      l_element_version_id := get_working_ver_id(l_task_tab(i));
      xxpa_proj_public_pvt.tasks_rollup(p_element_version_id => l_element_version_id,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data);
      IF nvl(x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
        RETURN;
      END IF;
    END LOOP;
  
  END;

  FUNCTION get_source(p_order_number VARCHAR2,
                      p_mfg_num      VARCHAR2) RETURN VARCHAR2 IS
    CURSOR source_c(p_order_number VARCHAR2,
                    p_mfg_num      VARCHAR2) IS
      SELECT xsol.source
        FROM xxpjm_so_addtn_lines_all   xsol,
             xxpjm_so_addtn_headers_all xsoh,
             oe_order_headers_all       ooh
       WHERE xsol.header_id = xsoh.header_id
         AND xsoh.so_header_id = ooh.header_id
         AND ooh.order_number = p_order_number
         AND xsol.mfg_no = p_mfg_num;
  
    l_source xxpjm_so_addtn_lines_all.source%TYPE;
  BEGIN
  
    OPEN source_c(p_order_number, p_mfg_num);
    FETCH source_c
      INTO l_source;
    IF source_c%NOTFOUND THEN
      l_source := NULL;
    END IF;
    CLOSE source_c;
  
    RETURN l_source;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --add by jiaming.zhou 2013-12-31 start
  PROCEDURE update_plan_shipping_date(p_top_task_id        IN NUMBER,
                                      p_project_id         IN NUMBER,
                                      p_plan_shipping_date IN VARCHAR2) IS
    l_plan_shipping_date DATE;
    CURSOR cur_update_task IS
      SELECT psd.top_task_id,
             psd.project_id
        FROM xxpjm_planning_shipping_date psd
       WHERE psd.top_task_id = nvl(p_top_task_id, psd.top_task_id)
         AND psd.project_id = p_project_id;
    CURSOR cur_insert_task IS
      SELECT task_id top_task_id
        FROM pa_tasks pt
       WHERE project_id = p_project_id
         AND task_id = nvl(p_top_task_id, task_id)
         AND wbs_level = 1
         AND NOT EXISTS (SELECT 1
                FROM xxpjm_planning_shipping_date psd
               WHERE psd.top_task_id = pt.task_id
                 AND psd.project_id = pt.project_id);
  BEGIN
    l_plan_shipping_date := fnd_conc_date.string_to_date(p_plan_shipping_date);
    IF p_plan_shipping_date IS NOT NULL AND l_plan_shipping_date IS NULL THEN
      --IF13
      NULL;
    ELSE
      FOR rec_insert IN cur_insert_task
      LOOP
        INSERT INTO xxpjm_planning_shipping_date
          (shipping_date_id, top_task_id, project_id, plan_shipping_date, request_id)
        VALUES
          (xxpjm_planning_shipping_date_s.nextval,
           rec_insert.top_task_id,
           p_project_id,
           l_plan_shipping_date,
           g_request_id);
      END LOOP;
      FOR rec_update IN cur_update_task
      LOOP
        UPDATE xxpjm_planning_shipping_date
           SET plan_shipping_date = l_plan_shipping_date
         WHERE top_task_id = rec_update.top_task_id
           AND project_id = p_project_id;
      END LOOP;
    END IF;
  END;
  --add by jiaming.zhou 2013-12-31 end

  PROCEDURE process_request(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_group_id      IN NUMBER) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_delivery_date DATE;
    CURSOR cur_task IS
      SELECT pt.top_task_id,
             pt.task_number,
             pt.task_id,
             pt.attribute3 phase,
             decode(ptt.task_type, 'EQ COST', 'Y', 'ER COST', 'Y', 'FM COST', 'Y', NULL) cost_task,
             pt_top.task_number mfg_number,
             pp.segment1 project_number
        FROM pa_tasks         pt,
             pa_tasks         pt_top,
             pa_projects      pp,
             pa_task_types    ptt,
             pa_proj_elements ppe
       WHERE pt.wbs_level = g_phase_wbs_level
         AND EXISTS (SELECT 1
                FROM xxpjm_schedule_update_temp sut
               WHERE sut.group_id = p_group_id
                 AND pt.project_id = sut.project_id
                 AND pt.top_task_id = sut.top_task_id)
         AND pp.project_id = pt.project_id
         AND ptt.task_type_id = ppe.type_id
         AND ppe.proj_element_id = pt.task_id
         AND pt_top.task_id = pt.top_task_id
       ORDER BY pt.project_id,
                pt.top_task_id,
                pt.task_id;
    CURSOR cur_part_task(p_project_id  NUMBER,
                         p_top_task_id NUMBER,
                         p_part_type   VARCHAR2) IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt,
             pa_tasks phase
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 = p_part_type
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 <> xxpjm_project_public.g_shipping;
    CURSOR cur_subtask(p_task_id NUMBER) IS
      SELECT task_id,
             task_number,
             wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt
       WHERE pt.wbs_level > g_phase_wbs_level
       START WITH task_id = p_task_id
      CONNECT BY PRIOR task_id = pt.parent_task_id
       ORDER BY pt.wbs_level DESC;
    CURSOR cur_temp(p_group_id NUMBER) IS
      SELECT sut.*,
             pt.attribute1 part
        FROM xxpjm_schedule_update_temp sut,
             pa_tasks                   pt
       WHERE group_id = p_group_id
         AND pt.task_id = sut.part_task_id
       ORDER BY sut.project_id,
                sut.top_task_id,
                sut.task_id;
  
    CURSOR cur_temp_project IS
      SELECT sut.project_id
        FROM xxpjm_schedule_update_temp sut
       WHERE group_id = p_group_id
       GROUP BY sut.project_id;
    CURSOR cur_temp_top_task IS
      SELECT sut.project_id,
             top_task_id
        FROM xxpjm_schedule_update_temp sut
       WHERE group_id = p_group_id
       GROUP BY sut.project_id,
                top_task_id;
    l_element_version_id      NUMBER;
    l_log_meg                 VARCHAR2(200);
    l_proj_mfg                VARCHAR2(200);
    x_published_struct_ver_id NUMBER;
    x_schedule_start_date     DATE;
    x_schedule_end_date       DATE;
  BEGIN
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
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
    -- API body
  
    -- logging parameters
    IF l_debug = 'Y' THEN
      xxfnd_debug.log('p_group_id : ' || p_group_id);
    END IF;
    l_index    := 0;
    l_task_tab := l_task_tab_int;
    -- todo
    --update parts schedule date
    IF l_debug = 'Y' THEN
      l_log_meg := 'update parts schedule date';
      log(l_log_meg);
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
    FOR rec_shipping_parts IN cur_temp(p_group_id)
    LOOP
      --update shipping parts schedule date  
      IF l_debug = 'Y' THEN
        l_log_meg := 'update shipping parts schedule date';
        log(l_log_meg);
      END IF;
      l_log_meg := 'schedule_start_date:' || rec_shipping_parts.schedule_start_date;
      log(l_log_meg);
      update_task_schedule(p_init_msg_list        => p_init_msg_list,
                           p_commit               => p_commit,
                           x_return_status        => x_return_status,
                           x_msg_count            => x_msg_count,
                           x_msg_data             => x_msg_data,
                           p_task_id              => rec_shipping_parts.part_task_id,
                           p_scheduled_start_date => rec_shipping_parts.schedule_start_date,
                           p_scheduled_end_date   => rec_shipping_parts.schedule_end_date);
      --update other phase parts schedule date
      IF l_debug = 'Y' THEN
        l_log_meg := 'update other phase parts schedule date';
        log(l_log_meg);
        l_log_meg := 'begin loop rec_other_parts';
        log(l_log_meg);
      END IF;
      raise_exception(x_return_status);
      /*L_INDEX := L_INDEX + 1;
      L_TASK_TAB(L_INDEX) := REC_SHIPPING_PARTS.PART_TASK_ID;*/
      FOR rec_other_parts IN cur_part_task(rec_shipping_parts.project_id,
                                           rec_shipping_parts.top_task_id,
                                           rec_shipping_parts.part)
      LOOP
      
        l_log_meg := 'rec_other_parts.task_name:' || rec_other_parts.task_name;
        log(l_log_meg);
        update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                   p_commit        => p_commit,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_task_id       => rec_other_parts.task_id,
                                   p_delivery_date => rec_shipping_parts.schedule_end_date);
        raise_exception(x_return_status);
        /*IF X_RETURN_STATUS = fnd_api.g_ret_sts_success THEN
          L_INDEX := L_INDEX + 1;
          L_TASK_TAB(L_INDEX) := REC_OTHER_PARTS.TASK_ID;
        END IF;*/
      END LOOP;
      IF l_debug = 'Y' THEN
        l_log_meg := 'end loop rec_other_parts';
        log(l_log_meg);
      END IF;
    END LOOP;
    --update task scheduled date
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
  
    log('process 10-35:update other subtask under phase which have part task which has update schedule');
    FOR rec_top_tasks IN cur_temp_top_task
    LOOP
      --update other subtask under phase which have part task which has update schedule
      update_other_subtask(p_project_id    => rec_top_tasks.project_id,
                           p_top_task_id   => rec_top_tasks.top_task_id,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);
      raise_exception(x_return_status);
    END LOOP;
    --rollup task
    FOR i IN 1 .. l_index
    LOOP
      l_element_version_id := get_working_ver_id(l_task_tab(i));
      xxpa_proj_public_pvt.tasks_rollup(p_element_version_id => l_element_version_id,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data);
      raise_exception(x_return_status);
    END LOOP;
  
    --structure published
    log('structure published');
  
    FOR rec_proj IN cur_temp_project
    LOOP
      xxpa_proj_public_pvt.structure_published(p_project_id              => rec_proj.project_id,
                                               x_published_struct_ver_id => x_published_struct_ver_id,
                                               x_msg_count               => x_msg_count,
                                               x_msg_data                => x_msg_data,
                                               x_return_status           => x_return_status);
      raise_exception(x_return_status);
    
      xxpjm_project_public.cleanup(rec_proj.project_id, x_return_status, x_msg_count, x_msg_data);
    
      raise_exception(x_return_status);
    
    END LOOP;
  
    --delete temp
    DELETE xxpjm_schedule_update_temp
     WHERE group_id = p_group_id;
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      log(l_proj_mfg);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      log(l_proj_mfg);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN OTHERS THEN
      log(l_proj_mfg);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
  END process_request;

  -- add by gusenlin 20130730  for Quotation Maintance Form to call
  PROCEDURE process_request_proj_mfg1(p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                      p_commit                IN VARCHAR2 DEFAULT fnd_api.g_false,
                                      x_return_status         OUT NOCOPY VARCHAR2,
                                      x_msg_count             OUT NOCOPY NUMBER,
                                      x_msg_data              OUT NOCOPY VARCHAR2,
                                      p_project_id            IN NUMBER,
                                      p_top_task_id           IN NUMBER,
                                      p_partial_delivery_date IN DATE,
                                      p_schedule_end_date     IN DATE
                                      --update by jiaming.zhou 2013-12-31 start
                                      --,p_update_shipping_phase_only IN VARCHAR2
                                      --update by jiaming.zhou 2013-12-31 end
                                      ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_delivery_date DATE;
    /*CURSOR CUR_TASK(x_project_id number, x_top_task_id in number) IS
    SELECT PT.TOP_TASK_ID,
           PT.TASK_NUMBER,
           PT.TASK_ID,
           PT.ATTRIBUTE3 PHASE,
           DECODE(PTT.TASK_TYPE,
                  'EQ COST',
                  'Y',
                  'ER COST',
                  'Y',
                  'FM COST',
                  'Y',
                  NULL) COST_TASK,
           PT_TOP.TASK_NUMBER MFG_NUMBER,
           PP.SEGMENT1 PROJECT_NUMBER
      FROM PA_TASKS         PT,
           PA_TASKS         PT_TOP,
           PA_PROJECTS      PP,
           PA_TASK_TYPES    PTT,
           PA_PROJ_ELEMENTS PPE
     WHERE PT.WBS_LEVEL = G_PHASE_WBS_LEVEL
       AND PT.PROJECT_ID = x_PROJECT_ID
       AND PT.TOP_TASK_ID = x_top_task_id
       AND PP.PROJECT_ID = PT.PROJECT_ID
       AND PTT.TASK_TYPE_ID = PPE.TYPE_ID
       AND PPE.PROJ_ELEMENT_ID = PT.TASK_ID
       AND PT_TOP.TASK_ID = PT.TOP_TASK_ID
     ORDER BY PT.PROJECT_ID, PT.TOP_TASK_ID, PT.TASK_ID;*/
    CURSOR cur_part_task(p_project_id  NUMBER,
                         p_top_task_id NUMBER,
                         p_part_type   VARCHAR2) IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt,
             pa_tasks phase
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 = p_part_type
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 <> xxpjm_project_public.g_shipping;
  
    CURSOR cur_subtask(p_task_id NUMBER) IS
      SELECT task_id,
             task_number,
             wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt
       WHERE pt.wbs_level > g_phase_wbs_level
       START WITH task_id = p_task_id
      CONNECT BY PRIOR task_id = pt.parent_task_id
       ORDER BY pt.wbs_level DESC;
  
    CURSOR cur_shipping_part_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1   part,
             pt.project_id,
             pt.top_task_id,
             top.task_number top_task_number,
             pa.segment1     project_number
      
        FROM pa_tasks        pt,
             pa_tasks        phase,
             pa_tasks        top,
             pa_projects_all pa
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = top.task_id
         AND pt.project_id = pa.project_id
         AND pt.top_task_id = nvl(p_top_task_id, pt.top_task_id)
         AND pt.attribute1 IS NOT NULL
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_scheduled_start_date(p_task_id NUMBER) IS
      SELECT scheduled_start_date
        FROM pa.pa_proj_elem_ver_schedule t
       WHERE t.element_version_id = get_working_ver_id(p_task_id);
  
    CURSOR cur_shipping_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = nvl(p_top_task_id, pt.top_task_id)
         AND pt.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_tep_task(p_task_id IN NUMBER) IS
      SELECT 'Y'
        FROM xxpjm_task_schedule_temp tep
       WHERE tep.task_id = p_task_id;
  
    CURSOR cur_top_task IS
      SELECT top_task_id
        FROM pa_tasks
       WHERE project_id = p_project_id
         AND task_id = top_task_id
         AND top_task_id = nvl(p_top_task_id, top_task_id);
    l_element_version_id      NUMBER;
    l_log_meg                 VARCHAR2(200);
    l_proj_mfg                VARCHAR2(200);
    l_valid_flag              VARCHAR2(1);
    x_published_struct_ver_id NUMBER;
    x_schedule_end_date       DATE;
    x_schedule_start_date     DATE;
    l_schedule_start_date     DATE;
    l_lookup_type             fnd_lookup_types.lookup_type%TYPE;
    l_source                  xxpjm_so_addtn_lines_all.source%TYPE;
    l_schedule_end_date       DATE;
  BEGIN
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
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
    -- API body
  
    -- logging parameters
    IF l_debug = 'Y' THEN
      xxfnd_debug.log('P_PROJECT_ID :           ' || p_project_id);
      xxfnd_debug.log('P_TOP_TASK_ID :          ' || p_top_task_id);
      xxfnd_debug.log('p_partial_delivery_date: ' || p_partial_delivery_date);
      xxfnd_debug.log('p_SCHEDULE_END_DATE :    ' || p_schedule_end_date);
    END IF;
    l_index    := 0;
    l_task_tab := l_task_tab_int;
    -- todo
    --update parts schedule date
    IF l_debug = 'Y' THEN
      l_log_meg := 'update parts schedule date';
      log(l_log_meg);
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
  
    FOR rec_shipping_parts IN cur_shipping_part_task
    LOOP
      --update shipping parts schedule date  
      IF l_debug = 'Y' THEN
        l_log_meg := 'update shipping parts schedule date';
        log(l_log_meg);
      END IF;
    
      l_source := get_source(rec_shipping_parts.project_number, rec_shipping_parts.top_task_number);
      log('l_source: ' || l_source);
      l_lookup_type := get_make_mix_lookup(l_source);
      log('l_lookup_type: ' || l_lookup_type);
    
      l_schedule_end_date := get_delivery_date(p_lookup_type           => l_lookup_type,
                                               p_part_task             => rec_shipping_parts.part,
                                               p_partial_delivery_date => p_partial_delivery_date,
                                               p_final_delivery_date   => p_schedule_end_date);
      log('l_schedule_end_date: ' || l_schedule_end_date);
    
      get_phase_part_schedule_date(p_task_id             => rec_shipping_parts.task_id,
                                   p_delivery_date       => l_schedule_end_date,
                                   x_schedule_start_date => x_schedule_start_date,
                                   x_schedule_end_date   => x_schedule_end_date,
                                   x_return_status       => x_return_status,
                                   x_msg_data            => x_msg_data);
      raise_exception(x_return_status);
      IF x_schedule_start_date IS NULL THEN
        GOTO loop_end;
      END IF;
      update_task_schedule(p_init_msg_list        => p_init_msg_list,
                           p_commit               => p_commit,
                           x_return_status        => x_return_status,
                           x_msg_count            => x_msg_count,
                           x_msg_data             => x_msg_data,
                           p_task_id              => rec_shipping_parts.task_id,
                           p_scheduled_start_date => x_schedule_start_date,
                           p_scheduled_end_date   => x_schedule_end_date);
      --update other phase parts schedule date
      IF l_debug = 'Y' THEN
        l_log_meg := 'update other phase parts schedule date';
        log(l_log_meg);
        l_log_meg := 'begin loop rec_other_parts';
        log(l_log_meg);
      END IF;
      raise_exception(x_return_status);
      /*L_INDEX := L_INDEX + 1;
      L_TASK_TAB(L_INDEX) := REC_SHIPPING_PARTS.PART_TASK_ID;*/
    
      --update by jiaming.zhou 2013-12-31 start
      --New IF condition 'p_update_shipping_phase_only' added by fandong.chen 20130717
      --IF nvl(p_update_shipping_phase_only, 'N') = 'N' THEN
      --update by jiaming.zhou 2013-12-31 end
    
      FOR rec_other_parts IN cur_part_task(rec_shipping_parts.project_id,
                                           rec_shipping_parts.top_task_id,
                                           rec_shipping_parts.part)
      LOOP
      
        l_log_meg := 'rec_other_parts.task_name:' || rec_other_parts.task_name;
        log(l_log_meg);
        update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                   p_commit        => p_commit,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_task_id       => rec_other_parts.task_id,
                                   p_delivery_date => l_schedule_end_date);
        raise_exception(x_return_status);
        /*IF X_RETURN_STATUS = fnd_api.g_ret_sts_success THEN
          L_INDEX := L_INDEX + 1;
          L_TASK_TAB(L_INDEX) := REC_OTHER_PARTS.TASK_ID;
        END IF;*/
      END LOOP;
      IF l_debug = 'Y' THEN
        l_log_meg := 'end loop rec_other_parts';
        log(l_log_meg);
      END IF;
      --update by jiaming.zhou 2013-12-31 start
      --END IF; --  p_update_shipping_phase_only = 'N'
      --update by jiaming.zhou 2013-12-31 end
    
      <<loop_end>>
      NULL;
    END LOOP;
  
    --update task scheduled date
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
  
    FOR rec_top_task IN cur_top_task
    LOOP
      log('process 10-35:update other subtask under phase which have part task which has update schedule');
      --update other subtask under phase which have part task which has update schedule
      update_other_subtask(p_project_id  => p_project_id,
                           p_top_task_id => rec_top_task.top_task_id,
                           --update by jiaming.zhou 2013-12-31 start
                           --p_update_shipping_phase_only => p_update_shipping_phase_only,
                           --update by jiaming.zhou 2013-12-31 end
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);
      raise_exception(x_return_status);
    
      IF p_partial_delivery_date IS NOT NULL THEN
        handle_proj_mfg(x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_project_id    => p_project_id,
                        p_top_task_id   => rec_top_task.top_task_id,
                        --update by jiaming.zhou 2013-12-31 start
                        --p_update_shipping_phase_only => p_update_shipping_phase_only,
                        --update by jiaming.zhou 2013-12-31 end
                        --update by jiaming.zhou 2014-03-10 start
                        --p_schedule_end_date => p_partial_delivery_date
                        p_partial_delivery_date => p_partial_delivery_date,
                        p_final_delivery_date   => p_schedule_end_date
                        --update by jiaming.zhou 2014-03-10 end
                        );
        raise_exception(x_return_status);
      END IF;
    END LOOP;
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      log(l_proj_mfg);
      log(x_msg_data);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      log(l_proj_mfg);
      log(x_msg_data);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN OTHERS THEN
      log(l_proj_mfg);
      log(x_msg_data);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
  END process_request_proj_mfg1;

  PROCEDURE process_request_proj_mfg(p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                     p_commit                IN VARCHAR2 DEFAULT fnd_api.g_false,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2,
                                     p_project_id            IN NUMBER,
                                     p_top_task_id           IN NUMBER,
                                     p_partial_delivery_date IN DATE,
                                     p_schedule_end_date     IN DATE,
                                     --update by jiaming.zhou 2013-12-31 start
                                     --p_update_shipping_phase_only IN VARCHAR2
                                     p_plan_shipping_date IN VARCHAR2
                                     --update by jiaming.zhou 2013-12-31 end
                                     ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_delivery_date DATE;
    /*CURSOR CUR_TASK(x_project_id number, x_top_task_id in number) IS
    SELECT PT.TOP_TASK_ID,
           PT.TASK_NUMBER,
           PT.TASK_ID,
           PT.ATTRIBUTE3 PHASE,
           DECODE(PTT.TASK_TYPE,
                  'EQ COST',
                  'Y',
                  'ER COST',
                  'Y',
                  'FM COST',
                  'Y',
                  NULL) COST_TASK,
           PT_TOP.TASK_NUMBER MFG_NUMBER,
           PP.SEGMENT1 PROJECT_NUMBER
      FROM PA_TASKS         PT,
           PA_TASKS         PT_TOP,
           PA_PROJECTS      PP,
           PA_TASK_TYPES    PTT,
           PA_PROJ_ELEMENTS PPE
     WHERE PT.WBS_LEVEL = G_PHASE_WBS_LEVEL
       AND PT.PROJECT_ID = x_PROJECT_ID
       AND PT.TOP_TASK_ID = x_top_task_id
       AND PP.PROJECT_ID = PT.PROJECT_ID
       AND PTT.TASK_TYPE_ID = PPE.TYPE_ID
       AND PPE.PROJ_ELEMENT_ID = PT.TASK_ID
       AND PT_TOP.TASK_ID = PT.TOP_TASK_ID
     ORDER BY PT.PROJECT_ID, PT.TOP_TASK_ID, PT.TASK_ID;*/
    CURSOR cur_part_task(p_project_id  NUMBER,
                         p_top_task_id NUMBER,
                         p_part_type   VARCHAR2) IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt,
             pa_tasks phase
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 = p_part_type
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 <> xxpjm_project_public.g_shipping;
  
    CURSOR cur_subtask(p_task_id NUMBER) IS
      SELECT task_id,
             task_number,
             wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt
       WHERE pt.wbs_level > g_phase_wbs_level
       START WITH task_id = p_task_id
      CONNECT BY PRIOR task_id = pt.parent_task_id
       ORDER BY pt.wbs_level DESC;
  
    CURSOR cur_shipping_part_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1   part,
             pt.project_id,
             pt.top_task_id,
             top.task_number top_task_number,
             pa.segment1     project_number
      
        FROM pa_tasks        pt,
             pa_tasks        phase,
             pa_tasks        top,
             pa_projects_all pa
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = top.task_id
         AND pt.project_id = pa.project_id
         AND pt.top_task_id = nvl(p_top_task_id, pt.top_task_id)
         AND pt.attribute1 IS NOT NULL
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_scheduled_start_date(p_task_id NUMBER) IS
      SELECT scheduled_start_date
        FROM pa.pa_proj_elem_ver_schedule t
       WHERE t.element_version_id = get_working_ver_id(p_task_id);
  
    CURSOR cur_shipping_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = nvl(p_top_task_id, pt.top_task_id)
         AND pt.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_tep_task(p_task_id IN NUMBER) IS
      SELECT 'Y'
        FROM xxpjm_task_schedule_temp tep
       WHERE tep.task_id = p_task_id;
  
    CURSOR cur_top_task IS
      SELECT top_task_id
        FROM pa_tasks
       WHERE project_id = p_project_id
         AND task_id = top_task_id
         AND top_task_id = nvl(p_top_task_id, top_task_id);
  
    --add by jiaming.zhou 2014-04-08 start 
    CURSOR cur_old_delivery_date(p_project_id  NUMBER,
                                 p_top_task_id NUMBER) IS
      SELECT DISTINCT xxmrp_total_proj_report_pkg.get_ship_start_date(mfg.task_number, sol.source) partial_delivery_date,
                      xxmrp_total_proj_report_pkg.get_ship_end_date(mfg.task_number, sol.source) final_delivery_date,
                      ooh.order_number,
                      soh.project_country,
                      sol.model,
                      sol.mfg_no,
                      pa.long_name,
                      mfg.task_id
        FROM pa_tasks                   mfg,
             pa_projects_all            pa,
             oe_order_headers_all       ooh,
             xxpjm_so_addtn_headers_all soh,
             xxpjm_so_addtn_lines_all   sol
       WHERE mfg.project_id = pa.project_id
         AND pa.segment1 = ooh.order_number
         AND ooh.header_id = soh.so_header_id
         AND soh.header_id = sol.header_id
         AND sol.mfg_no = mfg.task_number
         AND mfg.task_id = nvl(p_top_task_id, mfg.task_id)
         AND pa.project_id = nvl(p_project_id, pa.project_id)
         AND pa.org_id = 82;
  
    CURSOR cur_delivery_date_temp(p_project_id  NUMBER,
                                  p_top_task_id NUMBER) IS
      SELECT COUNT(1)
        FROM xxpjm.xxpjm_delivery_date_temp
       WHERE project_id = p_project_id
         AND task_id = p_top_task_id;
  
    l_delivery_date_temp_count NUMBER;
    rec_delivery_date_temp     xxpjm_delivery_date_temp%ROWTYPE;
    TYPE delivery_date_table_type IS TABLE OF xxpjm_delivery_date_temp%ROWTYPE INDEX BY BINARY_INTEGER;
    l_delivery_date_table delivery_date_table_type;
    l_count               NUMBER := 0;
    --add by jiaming.zhou 2014-04-08 end
    l_element_version_id      NUMBER;
    l_log_meg                 VARCHAR2(200);
    l_proj_mfg                VARCHAR2(200);
    l_valid_flag              VARCHAR2(1);
    x_published_struct_ver_id NUMBER;
    x_schedule_end_date       DATE;
    x_schedule_start_date     DATE;
    l_schedule_start_date     DATE;
    l_lookup_type             fnd_lookup_types.lookup_type%TYPE;
    l_source                  xxpjm_so_addtn_lines_all.source%TYPE;
    l_schedule_end_date       DATE;
  BEGIN
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
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
    -- API body
  
    -- logging parameters
    IF l_debug = 'Y' THEN
      xxfnd_debug.log('P_PROJECT_ID :           ' || p_project_id);
      xxfnd_debug.log('P_TOP_TASK_ID :          ' || p_top_task_id);
      xxfnd_debug.log('p_partial_delivery_date: ' || p_partial_delivery_date);
      xxfnd_debug.log('p_SCHEDULE_END_DATE :    ' || p_schedule_end_date);
    END IF;
    l_index    := 0;
    l_task_tab := l_task_tab_int;
    -- todo
    --update parts schedule date
    IF l_debug = 'Y' THEN
      l_log_meg := 'update parts schedule date';
      log(l_log_meg);
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
  
    --add by jiaming.zhou 2014-04-09 start
    xxmrp_total_proj_report_pkg.set_org_id(p_project_id);
    FOR rec_old_delivery_date IN cur_old_delivery_date(p_project_id, p_top_task_id)
    LOOP
      l_count := l_count + 1;
      rec_delivery_date_temp.model := rec_old_delivery_date.model;
      rec_delivery_date_temp.task_id := rec_old_delivery_date.task_id;
      rec_delivery_date_temp.project_id := p_project_id;
      rec_delivery_date_temp.request_id := fnd_global.conc_request_id;
      rec_delivery_date_temp.so_number := rec_old_delivery_date.order_number;
      rec_delivery_date_temp.project_country := rec_old_delivery_date.project_country;
      rec_delivery_date_temp.old_partial_delivery_date := rec_old_delivery_date.partial_delivery_date;
      rec_delivery_date_temp.old_final_delivery_date := rec_old_delivery_date.final_delivery_date;
      rec_delivery_date_temp.new_partial_delivery_date := p_partial_delivery_date;
      rec_delivery_date_temp.new_final_delivery_date := p_schedule_end_date;
      rec_delivery_date_temp.source_org := 'SG1';
      rec_delivery_date_temp.project_long_name := rec_old_delivery_date.long_name;
      rec_delivery_date_temp.mfg_number := rec_old_delivery_date.mfg_no;
      rec_delivery_date_temp.type := 'Sales Order';
      rec_delivery_date_temp.process_status := 'P';
      rec_delivery_date_temp.last_updated_by := fnd_global.user_id;
      rec_delivery_date_temp.last_update_date := SYSDATE;
      rec_delivery_date_temp.last_update_login := fnd_global.login_id;
      l_delivery_date_table(l_count) := rec_delivery_date_temp;
    END LOOP;
    --add by jiaming.zhou 2014-04-09 end
  
    FOR rec_shipping_parts IN cur_shipping_part_task
    LOOP
      --update shipping parts schedule date  
      IF l_debug = 'Y' THEN
        l_log_meg := 'update shipping parts schedule date';
        log(l_log_meg);
      END IF;
    
      l_source := get_source(rec_shipping_parts.project_number, rec_shipping_parts.top_task_number);
      log('l_source: ' || l_source);
      l_lookup_type := get_make_mix_lookup(l_source);
      log('l_lookup_type: ' || l_lookup_type);
    
      l_schedule_end_date := get_delivery_date(p_lookup_type           => l_lookup_type,
                                               p_part_task             => rec_shipping_parts.part,
                                               p_partial_delivery_date => p_partial_delivery_date,
                                               p_final_delivery_date   => p_schedule_end_date);
      log('l_schedule_end_date: ' || l_schedule_end_date);
    
      get_phase_part_schedule_date(p_task_id             => rec_shipping_parts.task_id,
                                   p_delivery_date       => l_schedule_end_date,
                                   x_schedule_start_date => x_schedule_start_date,
                                   x_schedule_end_date   => x_schedule_end_date,
                                   x_return_status       => x_return_status,
                                   x_msg_data            => x_msg_data);
      raise_exception(x_return_status);
      IF x_schedule_start_date IS NULL THEN
        GOTO loop_end;
      END IF;
      update_task_schedule(p_init_msg_list        => p_init_msg_list,
                           p_commit               => p_commit,
                           x_return_status        => x_return_status,
                           x_msg_count            => x_msg_count,
                           x_msg_data             => x_msg_data,
                           p_task_id              => rec_shipping_parts.task_id,
                           p_scheduled_start_date => x_schedule_start_date,
                           p_scheduled_end_date   => x_schedule_end_date);
      --update other phase parts schedule date
      IF l_debug = 'Y' THEN
        l_log_meg := 'update other phase parts schedule date';
        log(l_log_meg);
        l_log_meg := 'begin loop rec_other_parts';
        log(l_log_meg);
      END IF;
      raise_exception(x_return_status);
      /*L_INDEX := L_INDEX + 1;
      L_TASK_TAB(L_INDEX) := REC_SHIPPING_PARTS.PART_TASK_ID;*/
    
      --update by jiaming.zhou 2013-12-31 start
      --New IF condition 'p_update_shipping_phase_only' added by fandong.chen 20130717
      --IF nvl(p_update_shipping_phase_only, 'N') = 'N' THEN
      --update by jiaming.zhou 2013-12-31 end
    
      FOR rec_other_parts IN cur_part_task(rec_shipping_parts.project_id,
                                           rec_shipping_parts.top_task_id,
                                           rec_shipping_parts.part)
      LOOP
      
        l_log_meg := 'rec_other_parts.task_name:' || rec_other_parts.task_name;
        log(l_log_meg);
        update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                   p_commit        => p_commit,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_task_id       => rec_other_parts.task_id,
                                   p_delivery_date => l_schedule_end_date);
        raise_exception(x_return_status);
        /*IF X_RETURN_STATUS = fnd_api.g_ret_sts_success THEN
          L_INDEX := L_INDEX + 1;
          L_TASK_TAB(L_INDEX) := REC_OTHER_PARTS.TASK_ID;
        END IF;*/
      END LOOP;
      IF l_debug = 'Y' THEN
        l_log_meg := 'end loop rec_other_parts';
        log(l_log_meg);
      END IF;
    
      --update by jiaming.zhou 2013-12-31 start  
      --END IF; --  p_update_shipping_phase_only = 'N'
      --update by jiaming.zhou 2013-12-31 end
    
      <<loop_end>>
      NULL;
    END LOOP;
  
    --update task scheduled date
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
  
    FOR rec_top_task IN cur_top_task
    LOOP
      log('process 10-35:update other subtask under phase which have part task which has update schedule');
      --update other subtask under phase which have part task which has update schedule
      update_other_subtask(p_project_id  => p_project_id,
                           p_top_task_id => rec_top_task.top_task_id,
                           --update by jiaming.zhou 2013-12-31 start
                           --p_update_shipping_phase_only => p_update_shipping_phase_only,
                           --update by jiaming.zhou 2013-12-31 end
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);
      raise_exception(x_return_status);
    
      IF p_partial_delivery_date IS NOT NULL THEN
        handle_proj_mfg(x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_project_id    => p_project_id,
                        p_top_task_id   => rec_top_task.top_task_id,
                        --update by jiaming.zhou 2013-12-31 start
                        --p_update_shipping_phase_only => p_update_shipping_phase_only,
                        --update by jiaming.zhou 2013-12-31 end
                        --update by jiaming.zhou 2014-03-10 start
                        --p_schedule_end_date => p_partial_delivery_date
                        p_partial_delivery_date => p_partial_delivery_date,
                        p_final_delivery_date   => p_schedule_end_date
                        --update by jiaming.zhou 2014-03-10 end
                        );
        raise_exception(x_return_status);
      END IF;
    END LOOP;
  
    xxpa_proj_public_pvt.structure_published(p_project_id              => p_project_id,
                                             x_published_struct_ver_id => x_published_struct_ver_id,
                                             x_msg_count               => x_msg_count,
                                             x_msg_data                => x_msg_data,
                                             x_return_status           => x_return_status);
    IF nvl(x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;
  
    --add by jiaming.zhou 2014-04-09 start
    IF nvl(x_return_status, fnd_api.g_ret_sts_success) = fnd_api.g_ret_sts_success AND g_call_flag = 'Y' AND
       l_count <> 0 THEN
      FOR i IN 1 .. l_count
      LOOP
        OPEN cur_delivery_date_temp(l_delivery_date_table(i).project_id, l_delivery_date_table(i).task_id);
        FETCH cur_delivery_date_temp
          INTO l_delivery_date_temp_count;
        CLOSE cur_delivery_date_temp;
        IF l_delivery_date_temp_count = 0 THEN
          l_delivery_date_table(i).temp_id := xxpjm_delivery_date_temp_s.nextval;
          l_delivery_date_table(i).creation_date := SYSDATE;
          l_delivery_date_table(i).created_by := fnd_global.user_id;
          INSERT INTO xxpjm_delivery_date_temp
          VALUES l_delivery_date_table
            (i);
        ELSIF l_delivery_date_temp_count = 1 THEN
          UPDATE xxpjm_delivery_date_temp
             SET old_partial_delivery_date = l_delivery_date_table(i).old_partial_delivery_date,
                 old_final_delivery_date   = l_delivery_date_table(i).old_final_delivery_date,
                 new_final_delivery_date   = l_delivery_date_table(i).new_final_delivery_date,
                 new_partial_delivery_date = l_delivery_date_table(i).new_partial_delivery_date,
                 mfg_number                = l_delivery_date_table(i).mfg_number,
                 source_org                = l_delivery_date_table(i).source_org,
                 project_long_name         = l_delivery_date_table(i).project_long_name,
                 process_status            = l_delivery_date_table(i).process_status,
                 request_id                = l_delivery_date_table(i).request_id,
                 last_updated_by           = l_delivery_date_table(i).last_updated_by,
                 last_update_date          = l_delivery_date_table(i).last_update_date,
                 last_update_login         = l_delivery_date_table(i).last_update_login
           WHERE project_id = p_project_id
             AND task_id = l_delivery_date_table(i).task_id;
        END IF;
      END LOOP;
    END IF;
    --add by jiaming.zhou 2014-04-09 end
  
    xxpjm_project_public.cleanup(p_project_id, x_return_status, x_msg_count, x_msg_data);
    raise_exception(x_return_status);
  
    --add by jiaming.zhou 2013-12-31 start
    --new parameter p_planning_shipping_date
    IF nvl(x_return_status, fnd_api.g_ret_sts_success) = fnd_api.g_ret_sts_success THEN
      update_plan_shipping_date(p_top_task_id, p_project_id, p_plan_shipping_date);
    END IF;
    --add by jiaming.zhou 2013-12-31 end
  
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      log(l_proj_mfg);
      log(x_msg_data);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      log(l_proj_mfg);
      log(x_msg_data);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN OTHERS THEN
      log(l_proj_mfg);
      log(x_msg_data);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
  END process_request_proj_mfg;
  --For goe so interface
  PROCEDURE process_request_mfg(p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                p_commit                IN VARCHAR2 DEFAULT fnd_api.g_false,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2,
                                p_project_id            IN NUMBER,
                                p_top_task_id           IN NUMBER,
                                p_source                IN VARCHAR2,
                                p_market                IN VARCHAR2,
                                p_model                 IN VARCHAR2,
                                p_lt_model              IN VARCHAR2,
                                p_partial_delivery_date IN DATE,
                                p_final_delivery_date   IN DATE) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_delivery_date DATE;
    CURSOR cur_task(x_project_id  NUMBER,
                    x_top_task_id IN NUMBER) IS
      SELECT pt.top_task_id,
             pt.task_number,
             pt.task_id,
             pt.attribute3 phase,
             decode(ptt.task_type, 'EQ COST', 'Y', 'ER COST', 'Y', 'FM COST', 'Y', NULL) cost_task,
             pt_top.task_number mfg_number,
             pp.segment1 project_number
        FROM pa_tasks         pt,
             pa_tasks         pt_top,
             pa_projects      pp,
             pa_task_types    ptt,
             pa_proj_elements ppe
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = x_project_id
         AND pt.top_task_id = x_top_task_id
         AND pp.project_id = pt.project_id
         AND ptt.task_type_id = ppe.type_id
         AND ppe.proj_element_id = pt.task_id
         AND pt_top.task_id = pt.top_task_id
       ORDER BY pt.project_id,
                pt.top_task_id,
                pt.task_id;
    CURSOR cur_part_task(p_project_id  NUMBER,
                         p_top_task_id NUMBER,
                         p_part_type   VARCHAR2) IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt,
             pa_tasks phase
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 = p_part_type
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 <> xxpjm_project_public.g_shipping;
  
    CURSOR cur_subtask(p_task_id NUMBER) IS
      SELECT task_id,
             task_number,
             wbs_level,
             pt.attribute1 part
        FROM pa_tasks pt
       WHERE pt.wbs_level > g_phase_wbs_level
       START WITH task_id = p_task_id
      CONNECT BY PRIOR task_id = pt.parent_task_id
       ORDER BY pt.wbs_level DESC;
  
    CURSOR cur_shipping_part_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.attribute1 part,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt,
             pa_tasks phase
       WHERE pt.wbs_level = g_part_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute1 IS NOT NULL
         AND phase.task_id = pt.parent_task_id
         AND phase.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_scheduled_start_date(p_task_id NUMBER) IS
      SELECT scheduled_start_date
        FROM pa.pa_proj_elem_ver_schedule t
       WHERE t.element_version_id = get_working_ver_id(p_task_id);
  
    CURSOR cur_shipping_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = p_top_task_id
         AND pt.attribute3 = xxpjm_project_public.g_shipping;
  
    CURSOR cur_phase_task IS
      SELECT pt.task_id,
             pt.task_number,
             pt.task_name,
             pt.wbs_level,
             pt.project_id,
             pt.top_task_id
        FROM pa_tasks pt
       WHERE pt.wbs_level = g_phase_wbs_level
         AND pt.project_id = p_project_id
         AND pt.top_task_id = nvl(p_top_task_id, pt.top_task_id);
  
    CURSOR cur_tep_task(p_task_id IN NUMBER) IS
      SELECT 'Y'
        FROM xxpjm_task_schedule_temp tep
       WHERE tep.task_id = p_task_id;
    l_element_version_id      NUMBER;
    l_log_meg                 VARCHAR2(200);
    l_proj_mfg                VARCHAR2(200);
    l_valid_flag              VARCHAR2(1);
    x_published_struct_ver_id NUMBER;
    x_schedule_end_date       DATE;
    x_schedule_start_date     DATE;
    l_schedule_start_date     DATE;
    l_schedule_end_date       DATE;
    l_lookup_type             fnd_lookup_types.lookup_type%TYPE;
  BEGIN
  
    log('/****************BEGIN process_request_mfg****************/');
  
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin procedure ' || l_api_name;
      log(l_log_meg);
    END IF;
    log('P_PARTIAL_DELIVERY_DATE:' || p_partial_delivery_date);
    log('P_FINAL_DELIVERY_DATE:  ' || p_final_delivery_date);
    log('P_PROJECT_ID:           ' || p_project_id);
    log('P_TOP_TASK_ID:          ' || p_top_task_id);
    log('P_SOURCE:               ' || p_source);
    log('P_MARKET:               ' || p_market);
    log('P_MODEL:                ' || p_model);
    log('P_LT_MODEL:             ' || p_lt_model);
  
    IF p_partial_delivery_date IS NULL AND p_final_delivery_date IS NULL THEN
      x_msg_data := 'procedure PROCESS_REQUEST_PROJ_MFG  P_Partial_Delivery_Date and P_Final_Delivery_Date is null.';
      log(x_msg_data);
      RETURN;
    END IF;
  
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
    IF p_project_id IS NULL OR p_top_task_id IS NULL /*or P_SOURCE is null or
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   P_MARKET is null or P_MODEL is null*/
     THEN
      x_msg_data := 'P_PROJECT_ID is null or P_TOP_TASK_ID is null.';
      log(x_msg_data);
      RETURN;
    END IF;
  
    -- API body
    g_global_flag := 'Y';
    g_market      := p_market;
    g_model       := p_model;
    g_source      := p_source;
    g_lt_model    := p_lt_model;
  
    -- logging parameters
    IF l_debug = 'Y' THEN
      xxfnd_debug.log('P_PROJECT_ID : ' || p_project_id);
      xxfnd_debug.log('P_TOP_TASK_ID : ' || p_top_task_id);
    END IF;
    IF p_source IS NULL THEN
      GOTO shipping_task_loop;
    END IF;
    l_index    := 0;
    l_task_tab := l_task_tab_int;
    -- todo
    --update parts schedule date
    IF l_debug = 'Y' THEN
      l_log_meg := 'update parts schedule date';
      log(l_log_meg);
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
    log('process 10-10:get lookup type for make_mix');
    l_lookup_type := get_make_mix_lookup(p_source => p_source);
  
    IF l_lookup_type IS NULL THEN
      x_msg_data := 'Make or Mix Lookup For PARTS SCHEDULE is not exists.';
      log(x_msg_data);
    END IF;
  
    log('process 10-20:begin loop shipping parts');
  
    FOR rec_shipping_parts IN cur_shipping_part_task
    LOOP
      --update shipping parts schedule date  
      IF l_debug = 'Y' THEN
        l_log_meg := 'update shipping parts schedule date';
        log(l_log_meg);
      END IF;
      log('process 10-20-10:get_DELIVERY_DATE');
      l_schedule_end_date := get_delivery_date(p_lookup_type           => l_lookup_type,
                                               p_part_task             => rec_shipping_parts.part,
                                               p_partial_delivery_date => p_partial_delivery_date,
                                               p_final_delivery_date   => p_final_delivery_date);
    
      log('l_lookup_type:           ' || l_lookup_type);
      log('rec_shipping_parts.part: ' || rec_shipping_parts.part);
      log('p_partial_delivery_date: ' || p_partial_delivery_date);
      log('p_final_delivery_date:   ' || p_final_delivery_date);
      log('l_schedule_end_date:     ' || l_schedule_end_date);
    
      IF l_schedule_end_date IS NULL THEN
        GOTO rec_shipping_parts_end;
      END IF;
      log('process 10-20-20:GET_PHASE_PART_SCHEDULE_DATE');
      get_phase_part_schedule_date(p_task_id             => rec_shipping_parts.task_id,
                                   p_delivery_date       => l_schedule_end_date,
                                   x_schedule_start_date => x_schedule_start_date,
                                   x_schedule_end_date   => x_schedule_end_date,
                                   x_return_status       => x_return_status,
                                   x_msg_data            => x_msg_data);
    
      log('rec_shipping_parts.task_id: ' || rec_shipping_parts.task_id);
      log('x_schedule_start_date:      ' || x_schedule_start_date);
      log('x_schedule_end_date:        ' || x_schedule_end_date);
      log('x_return_status:            ' || x_return_status);
      log('x_msg_data:                 ' || x_msg_data);
    
      raise_exception(x_return_status);
      IF x_schedule_start_date IS NULL THEN
        GOTO rec_shipping_parts_end;
      END IF;
      log('process 10-20-30:UPDATE_TASK_SCHEDULE');
      update_task_schedule(p_init_msg_list        => p_init_msg_list,
                           p_commit               => p_commit,
                           x_return_status        => x_return_status,
                           x_msg_count            => x_msg_count,
                           x_msg_data             => x_msg_data,
                           p_task_id              => rec_shipping_parts.task_id,
                           p_scheduled_start_date => x_schedule_start_date,
                           p_scheduled_end_date   => x_schedule_end_date);
      --update other phase parts schedule date
      IF l_debug = 'Y' THEN
        l_log_meg := 'update other phase parts schedule date';
        log(l_log_meg);
        l_log_meg := 'begin loop rec_other_parts';
        log(l_log_meg);
      END IF;
      raise_exception(x_return_status);
      /*L_INDEX := L_INDEX + 1;
      L_TASK_TAB(L_INDEX) := REC_SHIPPING_PARTS.PART_TASK_ID;*/
      log('process 10-20-40:begin loop CUR_PART_TASK');
      FOR rec_other_parts IN cur_part_task(rec_shipping_parts.project_id,
                                           rec_shipping_parts.top_task_id,
                                           rec_shipping_parts.part)
      LOOP
      
        l_log_meg := 'rec_other_parts.task_name:' || rec_other_parts.task_name;
        log(l_log_meg);
        log('process 10-20-40-10:UPDATE_PHASE_PART_SCHEDULE');
        update_phase_part_schedule(p_init_msg_list => p_init_msg_list,
                                   p_commit        => p_commit,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_task_id       => rec_other_parts.task_id,
                                   p_delivery_date => l_schedule_end_date);
        raise_exception(x_return_status);
        /*IF X_RETURN_STATUS = fnd_api.g_ret_sts_success THEN
          L_INDEX := L_INDEX + 1;
          L_TASK_TAB(L_INDEX) := REC_OTHER_PARTS.TASK_ID;
        END IF;*/
      END LOOP;
      log('process 10-20-50:end loop CUR_PART_TASK');
      IF l_debug = 'Y' THEN
        l_log_meg := 'end loop rec_other_parts';
        log(l_log_meg);
      END IF;
      <<rec_shipping_parts_end>>
      NULL;
    END LOOP;
  
    log('process 10-30:end loop REC_SHIPPING_PARTS');
    --update task scheduled date
    IF l_debug = 'Y' THEN
      l_log_meg := 'begin loop rec_tasks';
      log(l_log_meg);
    END IF;
  
    log('process 10-35:update other subtask under phase which have part task which has update schedule');
    --update other subtask under phase which have part task which has update schedule
    update_other_subtask(p_project_id    => p_project_id,
                         p_top_task_id   => p_top_task_id,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);
    raise_exception(x_return_status);
  
    log('process 10-40:rollup task');
    /* --rollup task
    FOR I IN 1 .. L_INDEX LOOP
      L_ELEMENT_VERSION_ID := GET_WORKING_VER_ID(L_TASK_TAB(I));
      XXPA_PROJ_PUBLIC_PVT.TASKS_ROLLUP(P_ELEMENT_VERSION_ID => L_ELEMENT_VERSION_ID,
                                        X_RETURN_STATUS      => X_RETURN_STATUS,
                                        X_MSG_COUNT          => X_MSG_COUNT,
                                        X_MSG_DATA           => X_MSG_DATA);
      RAISE_EXCEPTION(X_RETURN_STATUS);
    END LOOP;*/
    <<shipping_task_loop>>
    NULL;
  
    IF p_partial_delivery_date IS NOT NULL THEN
      handle_proj_mfg(x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_project_id    => p_project_id,
                      p_top_task_id   => p_top_task_id,
                      --add by jiaming.zhou 2014-03-10 start
                      --update by jiaming.zhou 2014-03-10 start
                      --p_schedule_end_date => p_partial_delivery_date
                      p_partial_delivery_date => p_partial_delivery_date,
                      p_final_delivery_date   => p_final_delivery_date
                      --update by jiaming.zhou 2014-03-10 end
                      );
      raise_exception(x_return_status);
    END IF;
  
    /*xxpa_proj_public_pvt.structure_published(p_project_id              => p_project_id,
                                             x_published_struct_ver_id => x_published_struct_ver_id,
                                             x_msg_count               => x_msg_count,
                                             x_msg_data                => x_msg_data,
                                             x_return_status           => x_return_status);
    IF nvl(x_return_status, fnd_api.g_ret_sts_success) <>
       fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;*/
    -- API end body
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
    log('/****************END process_request_mfg****************/');
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      log(l_proj_mfg);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      log(l_proj_mfg);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
    WHEN OTHERS THEN
      log(l_proj_mfg);
      IF x_msg_data IS NULL THEN
        x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                       p_api_name       => l_api_name,
                                                       p_savepoint_name => l_savepoint_name,
                                                       p_exc_name       => xxfnd_api.g_exc_name_others,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);
      END IF;
  END process_request_mfg;

  PROCEDURE submit_schedule_update(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                   p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   x_request_id    OUT VARCHAR2,
                                   p_group_id      IN NUMBER) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'submit_schedule_update';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
  BEGIN
    x_return_status := xxfnd_api.start_activity(p_pkg_name       => g_pkg_name,
                                                p_api_name       => l_api_name,
                                                p_savepoint_name => l_savepoint_name,
                                                p_init_msg_list  => p_init_msg_list);
    raise_exception(x_return_status);
  
    x_request_id := fnd_request.submit_request('XXPJM',
                                               'XXPJMUSCH',
                                               '',
                                               to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'),
                                               FALSE,
                                               p_group_id,
                                               chr(0));
  
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           p_commit    => p_commit,
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
  END submit_schedule_update;

  PROCEDURE main_proj_mfg(errbuf                  OUT VARCHAR2,
                          retcode                 OUT VARCHAR2,
                          p_project_id            IN NUMBER,
                          p_top_task_id           IN NUMBER,
                          p_partial_delivery_date IN VARCHAR2,
                          p_schedule_end_date     IN VARCHAR2,
                          --update by jiaming.zhou 2013-12-31 start
                          --p_update_shipping_phase_only IN   VARCHAR2,
                          p_plan_shipping_date IN VARCHAR2,
                          --update by jiaming.zhou 2013-12-31 end
                          p_base_on_spec           IN VARCHAR2,
                          p_spec_schedule_end_date IN VARCHAR2) IS
    l_return_status         VARCHAR2(30);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_partial_delivery_date DATE;
    l_schedule_end_date     DATE;
  
    l_spec_schedule_end_date DATE;
  
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body
  
    -- convert parameter data type, such as varchar2 to date
    l_partial_delivery_date := fnd_conc_date.string_to_date(p_partial_delivery_date);
    l_schedule_end_date     := fnd_conc_date.string_to_date(p_schedule_end_date);
  
    -- call process request api
    l_spec_schedule_end_date := fnd_conc_date.string_to_date(p_spec_schedule_end_date);
  
    --update by jiaming.zhou 2013-12-31 start
    /*    IF p_base_on_spec = 'Y' AND p_update_shipping_phase_only = 'Y' THEN
      fnd_message.set_name('XXPJM','XXPJM_007E_007');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF*/
    IF
    --update by jiaming.zhou 2013-12-31 end
     p_base_on_spec = 'Y' AND p_spec_schedule_end_date IS NULL THEN
      fnd_message.set_name('XXPJM', 'XXPJM_007E_008');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    
    ELSIF p_base_on_spec = 'Y' THEN
      xxpjm_task_sch_based_spec_pkg.process_task(x_return_status          => l_return_status,
                                                 x_msg_count              => l_msg_count,
                                                 x_msg_data               => l_msg_data,
                                                 p_project_id             => p_project_id,
                                                 p_top_task_id            => p_top_task_id,
                                                 p_spec_schedule_end_date => l_spec_schedule_end_date);
    ELSE
      g_call_flag := 'Y';
      process_request_proj_mfg(x_return_status         => l_return_status,
                               x_msg_count             => l_msg_count,
                               x_msg_data              => l_msg_data,
                               p_project_id            => p_project_id,
                               p_top_task_id           => p_top_task_id,
                               p_partial_delivery_date => l_partial_delivery_date,
                               p_schedule_end_date     => l_schedule_end_date,
                               --update by jiaming.zhou 2013-12-31 start
                               --p_update_shipping_phase_only => p_update_shipping_phase_only
                               p_plan_shipping_date => p_plan_shipping_date
                               --update by jiaming.zhou 2013-12-31 end
                               );
    END IF;
  
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  
    -- conc end body
    -- concurrent footer log
    xxfnd_conc_utl.log_footer;
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '1';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                              p_procedure_name => 'MAIN_PROJ_MFG',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END main_proj_mfg;

  PROCEDURE main(errbuf     OUT VARCHAR2,
                 retcode    OUT VARCHAR2,
                 p_group_id IN NUMBER) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body
  
    -- convert parameter data type, such as varchar2 to date
    -- l_date := fnd_conc_date.string_to_date(p_project_id);
  
    -- call process request api
    process_request(x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_group_id      => p_group_id);
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  
    -- conc end body
    -- concurrent footer log
    xxfnd_conc_utl.log_footer;
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '1';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                              p_procedure_name => 'MAIN',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END main;

END xxpjm_task_scheduled_pkg;
/
