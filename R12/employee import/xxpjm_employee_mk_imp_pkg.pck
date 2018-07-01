CREATE OR REPLACE PACKAGE xxpjm_employee_mk_imp_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPJM_EMPLOYEE_MK_IMP_PKG
  Description:
      This program provide concurrent main procedure to perform:
      Employee Interface (MK->G-SCM)
  History:
      1.00  2013-1-4 11:24:38  Lumen.Su  Creation
      1.0.1 2013-1-31          Fandong.Chen update
  ==================================================*/

  g_tab          VARCHAR2(1) := chr(9);
  g_change_line  VARCHAR2(2) := chr(10) || chr(13);
  g_line         VARCHAR2(150) := rpad('-', 150, '-');
  g_space        VARCHAR2(40) := '&nbsp';
  g_date_mask    VARCHAR(30) := 'YYYY-MM-DD HH24:MI:SS';
  g_default_date DATE := to_date('1950-1-1 00:00:00', g_date_mask);
  g_sysdate      DATE := to_date(to_char(SYSDATE, 'RRRR-MM-DD'),
                                 'RRRR-MM-DD');

  g_last_update_date  DATE := SYSDATE;
  g_last_updated_by   NUMBER := fnd_global.user_id;
  g_creation_date     DATE := SYSDATE;
  g_created_by        NUMBER := fnd_global.user_id;
  g_last_update_login NUMBER := fnd_global.login_id;

  g_request_id NUMBER := fnd_global.conc_request_id;
  g_session_id NUMBER := userenv('sessionid');

  g_success    VARCHAR2(1) := 'S';
  g_error      VARCHAR2(1) := 'E';
  g_unprocess  VARCHAR2(1) := 'P';
  g_processing VARCHAR2(1) := 'R';

  --g_org_id           NUMBER := fnd_profile.value('ORG_ID');
  g_org_id             NUMBER := fnd_profile.value('XXPJM_SHE_ORG_ID');
  --g_set_of_books_id  NUMBER := fnd_profile.value('GL_SET_OF_BKS_ID');
  g_set_of_books_id    NUMBER;
  
  g_mode_of_srp_num  VARCHAR2(40) := fnd_profile.value('JTF_RS_MODE_OF_SRP_NUM_CREATION');
  g_sale_credit_type VARCHAR2(30) := 'Quota Sales Credit';
  g_role_rs_type     VARCHAR2(20) := 'RS_INDIVIDUAL';
  g_role             VARCHAR2(40) := 'Sales Representative';

  g_business_group_id NUMBER;
  g_lookup_location   VARCHAR2(50) := 'XXHR_MK_LOCATION_MAPPING';
  g_lookup_division   VARCHAR2(50) := 'XXHR_MK_DIVISION_MAPPING';
  g_lookup_level      VARCHAR2(50) := 'XXHR_MK_LEVEL_MAPPING';
  g_vs_location       VARCHAR2(50) := 'XXHR_ORGANIZATION';
  g_vs_division       VARCHAR2(50) := 'XXHR_DEPARTMENT';
  g_vs_level          VARCHAR2(50) := 'XXHR_POSITION/JOB';
  g_lookup_title      VARCHAR2(50) := 'TITLE';

  g_t_person        VARCHAR2(30) := 'PER_PEOPLE_F';
  g_c_person_id     VARCHAR2(30) := 'PERSON_ID';
  g_t_assign        VARCHAR2(30) := 'PER_ALL_ASSIGNMENTS_F';
  g_c_assignment_id VARCHAR2(30) := 'ASSIGNMENT_ID';
  g_t_service       VARCHAR(30) := 'PER_PERIODS_OF_SERVICE';
  g_c_service_id    VARCHAR2(30) := 'PERIOD_OF_SERVICE_ID';

  g_sp_new            VARCHAR2(3) := 'NEW';
  g_sp_old            VARCHAR2(3) := 'OLD';
  g_sp_prefix         VARCHAR2(20) := 'GSE0';
  g_sp_city           VARCHAR2(50) := 'BANKOK';
  g_sp_contry_code    VARCHAR2(10) := 'TH';
  g_sp_address_1      VARCHAR2(240) := 'OFFICE';
  g_sp_address_name   VARCHAR2(50) := '0001';
  g_sp_site_code_fac  VARCHAR2(50) := '0001-SHE_FAC';
  g_sp_site_code_qh   VARCHAR2(50) := '0001-SHE_HQ';
  g_sp_location_fac   VARCHAR2(50) := 'SHE_FACTORY';
  g_sp_location_qh    VARCHAR2(50) := 'SHE_HEADQUARTER';
  g_sp_liability_acct VARCHAR2(240) := 'GS00.0.2151900000.0.0.0.0';

  g_working_hours      NUMBER := 40;
  g_frequency          VARCHAR2(1) := 'W';
  g_time_normal_start  VARCHAR2(5) := '09:00';
  g_time_normal_finish VARCHAR2(5) := '17:30';

  g_default_expense_account VARCHAR2(50) := 'GS00.GS00100200.1145500000.111103030.0.0.0';
  g_default_code_comb_id    NUMBER;

  g_local_debug_flag BOOLEAN := TRUE;

  --main
  PROCEDURE main(errbuf       OUT VARCHAR2,
                 retcode      OUT VARCHAR2,
                 p_group_id   IN NUMBER,
                 p_retry_flag IN VARCHAR2);

  FUNCTION get_object_version_number(p_table       IN VARCHAR2,
                                     p_object_name IN VARCHAR2,
                                     p_object_id   IN NUMBER,
                                     --new parameter added by fandong.chen 20130131
                                     p_effective_date IN DATE) RETURN NUMBER;

END xxpjm_employee_mk_imp_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxpjm_employee_mk_imp_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPJM_EMPLOYEE_MK_IMP_PKG
  Description:
      This program provide concurrent main procedure to perform:
      Employee Interface (MK->G-SCM)
  History:
      1.00  2013-1-4 11:24:38  Lumen.Su  Creation
  ==================================================*/

  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'XXPJM_EMPLOYEE_MK_IMP_PKG';
  -- Debug Enabled
  l_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');

  --output
  PROCEDURE output(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_content);
  END output;

  --log
  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log,
                      to_char(SYSDATE, 'YYYY/MM/DD HH24:MI:SS') || ' - ' ||
                      p_content);
  END log;

  --debug
  PROCEDURE debug(p_content IN VARCHAR2) IS
  BEGIN
    IF g_local_debug_flag THEN
      fnd_file.put_line(fnd_file.log,
                        '[D]' || to_char(SYSDATE, 'YYYY/MM/DD HH24:MI:SS') ||
                        ' - ' || p_content);
    END IF;
  END debug;
 --new function get_hr_lookup_code added by fandong.chen 20130201
 FUNCTION get_hr_lookup_code(p_lookup_type IN VARCHAR2,
                             p_meaning     IN VARCHAR2) RETURN VARCHAR2 IS
   CURSOR cur IS
     SELECT hl.lookup_code
       FROM hr_lookups hl
      WHERE hl.lookup_type = p_lookup_type
        AND hl.meaning = p_meaning;
   l_lookup_code fnd_lookup_values.lookup_code%TYPE;
 BEGIN
   l_lookup_code := NULL;
   OPEN cur;
   FETCH cur
     INTO l_lookup_code;
   CLOSE cur;
   RETURN l_lookup_code;
 END get_hr_lookup_code;
  
  FUNCTION get_set_of_books_id(p_org_id IN NUMBER) RETURN NUMBER IS
    l_set_of_books_id NUMBER;
  BEGIN
    SELECT set_of_books_id
      INTO l_set_of_books_id
      FROM hr_operating_units
     WHERE organization_id = p_org_id;
    RETURN l_set_of_books_id;
  EXCEPTION
    WHEN OTHERS THEN
      log('get_set_of_books_id error: ' || SQLERRM ||
          dbms_utility.format_error_backtrace);
      RETURN NULL;
  END get_set_of_books_id;
  
 FUNCTION get_code_comb_id(p_account        IN VARCHAR2,
                           p_set_of_book_id IN NUMBER) RETURN NUMBER IS
   l_code_comb_id NUMBER;
 BEGIN
   SELECT gcc.code_combination_id
     INTO l_code_comb_id
     FROM gl_code_combinations_kfv gcc, gl_sets_of_books sob
    WHERE gcc.concatenated_segments = p_account
      AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
      AND sob.set_of_books_id = p_set_of_book_id;
   RETURN l_code_comb_id;
 EXCEPTION
   WHEN OTHERS THEN
     log('get_set_of_books_id error: ' || SQLERRM ||
         dbms_utility.format_error_backtrace);
     RETURN NULL;
 END get_code_comb_id;
  --
  --
  FUNCTION get_employee_id(p_employee_number IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_id IS
      SELECT pf.person_id
        FROM per_all_people_f pf
       WHERE pf.employee_number = p_employee_number;
    l_employee_id NUMBER;
  BEGIN
    l_employee_id := -1;
    OPEN cur_id;
    FETCH cur_id
      INTO l_employee_id;
    CLOSE cur_id;
    RETURN l_employee_id;
  END get_employee_id;

  --
  --
  FUNCTION get_business_group_id(p_person_id IN NUMBER) RETURN NUMBER IS
    CURSOR cur_bg IS
      SELECT business_group_id
        FROM per_all_people_f pf
       WHERE pf.person_id = p_person_id;
    l_bg_id NUMBER;
  BEGIN
    l_bg_id := -1;
    OPEN cur_bg;
    FETCH cur_bg
      INTO l_bg_id;
    CLOSE cur_bg;
    RETURN l_bg_id;
  END get_business_group_id;

  --
  --
  FUNCTION get_assignment_id(p_person_id         IN NUMBER,
                             p_business_group_id IN NUMBER) RETURN NUMBER IS
    CURSOR cur_asg IS
      SELECT assignment_id
        FROM per_all_assignments_f
       WHERE person_id = p_person_id
         AND business_group_id = p_business_group_id;
    p_assign_id NUMBER;
  BEGIN
    p_assign_id := -1;
    OPEN cur_asg;
    FETCH cur_asg
      INTO p_assign_id;
    CLOSE cur_asg;
    RETURN p_assign_id;
  END get_assignment_id;
  --
  --
  FUNCTION get_employee_type_id(p_employee_type IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_id IS
      SELECT ppttl.person_type_id
        FROM per_person_types_tl ppttl
       WHERE ppttl.language = userenv('LANG')
         AND ppttl.user_person_type = p_employee_type;
    l_employee_type_id NUMBER;
  BEGIN
    l_employee_type_id := -1;
    OPEN cur_id;
    FETCH cur_id
      INTO l_employee_type_id;
    CLOSE cur_id;
    RETURN l_employee_type_id;
  END get_employee_type_id;

  --
  --
  FUNCTION get_resign_code(p_ori_resign_reason IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_code IS
      SELECT lookup_code
        FROM hr_leg_lookups
       WHERE lookup_type = 'LEAV_REAS'
         AND enabled_flag = 'Y'
         AND SYSDATE BETWEEN nvl(start_date_active, SYSDATE) AND
             nvl(end_date_active, SYSDATE)
         AND lookup_code = p_ori_resign_reason;
    l_code VARCHAR2(30);
  BEGIN
    l_code := NULL;
    OPEN cur_code;
    FETCH cur_code
      INTO l_code;
    CLOSE cur_code;
    RETURN l_code;
  END get_resign_code;

  --
  --
  FUNCTION get_lookup_desc(p_lookup_code IN VARCHAR2,
                           p_lookup_type IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_lookup IS
      SELECT flv.description
        FROM fnd_lookup_values flv
       WHERE flv.lookup_type = p_lookup_type
         AND flv.lookup_code = p_lookup_code
         AND flv.language = userenv('LANG');
    l_desc VARCHAR2(300);
  BEGIN
    debug(p_lookup_code || ' - ' || p_lookup_type);
    l_desc := NULL;
    OPEN cur_lookup;
    FETCH cur_lookup
      INTO l_desc;
    CLOSE cur_lookup;
    RETURN l_desc;
  END get_lookup_desc;

  --
  --
  FUNCTION get_lookup_meaning(p_lookup_code IN VARCHAR2,
                              p_lookup_type IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_lookup IS
      SELECT flv.meaning
        FROM fnd_lookup_values flv
       WHERE flv.lookup_type = p_lookup_type
         AND flv.lookup_code = p_lookup_code
         AND flv.language = userenv('LANG');
    l_meaning VARCHAR2(300);
  BEGIN
    l_meaning := NULL;
    OPEN cur_lookup;
    FETCH cur_lookup
      INTO l_meaning;
    CLOSE cur_lookup;
    RETURN l_meaning;
  END get_lookup_meaning;

  --
  --
  FUNCTION is_valueset_value(p_value              IN VARCHAR2,
                             p_dependent_vs_value IN VARCHAR2,
                             p_value_set          IN VARCHAR2) RETURN BOOLEAN IS
    CURSOR cur_vs IS
      SELECT COUNT(*)
        FROM fnd_flex_value_sets fvs, fnd_flex_values_vl fv
       WHERE fvs.flex_value_set_name = p_value_set
         AND fvs.flex_value_set_id = fv.flex_value_set_id
         AND nvl(fv.parent_flex_value_low, '**') =
             nvl(p_dependent_vs_value, '**')
         AND fv.flex_value = p_value;
    l_cnt NUMBER;
  BEGIN
    l_cnt := 0;
    OPEN cur_vs;
    FETCH cur_vs
      INTO l_cnt;
    CLOSE cur_vs;
    IF l_cnt > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;

  --
  --
  FUNCTION get_job_id(p_job_name IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_id IS
      SELECT t.job_id
        FROM per_jobs_tl t
       WHERE t.name = p_job_name
         AND t.language = userenv('LANG');
    l_job_id NUMBER;
  BEGIN
    l_job_id := -1;
    OPEN cur_id;
    FETCH cur_id
      INTO l_job_id;
    CLOSE cur_id;
    RETURN l_job_id;
  END get_job_id;
  
  --
  --
  FUNCTION get_datatrack_ud_mode(p_base_table_name IN VARCHAR2,
                                 p_base_key_column IN VARCHAR2,
                                 p_base_key_value  IN VARCHAR2,
                                 p_effective_date  IN DATE) RETURN VARCHAR2 IS
    lb_correction           BOOLEAN;
    lb_update               BOOLEAN;
    lb_update_override      BOOLEAN;
    lb_update_change_insert BOOLEAN;
    lc_dt_ud_mode           VARCHAR2(100) := NULL;
  BEGIN
  
    dt_api.find_dt_upd_modes(p_effective_date       => p_effective_date,
                             p_base_table_name      => p_base_table_name,
                             p_base_key_column      => p_base_key_column,
                             p_base_key_value       => p_base_key_value,
                             p_correction           => lb_correction,
                             p_update               => lb_update,
                             p_update_override      => lb_update_override,
                             p_update_change_insert => lb_update_change_insert);
    -- UPDATE_OVERRIDE
    IF (lb_update_override = TRUE OR lb_update_change_insert = TRUE) THEN
      lc_dt_ud_mode := hr_api.g_update_override;
    END IF;
    -- CORRECTION
    IF (lb_correction = TRUE) THEN
      lc_dt_ud_mode := hr_api.g_correction;
    END IF;
    -- UPDATE
    IF (lb_update = TRUE) THEN
      lc_dt_ud_mode := hr_api.g_update;
    END IF;
  
    RETURN lc_dt_ud_mode;
  
  EXCEPTION
    WHEN OTHERS THEN
      log('get_data_track_ud_mode error: ' || SQLERRM ||'  '||
          dbms_utility.format_error_backtrace);
      RETURN NULL;
  END;

  --
  --
  FUNCTION get_position_id(p_position_name IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_position IS
      SELECT b.position_id
        FROM hr_all_positions_f b
       WHERE b.name = p_position_name;
    l_position_id NUMBER;
  BEGIN
    l_position_id := -1;
    OPEN cur_position;
    FETCH cur_position
      INTO l_position_id;
    CLOSE cur_position;
    RETURN l_position_id;
  END get_position_id;

  --
  --
  FUNCTION get_people_group_id(p_location IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_group_id IS
      SELECT ppg.people_group_id
        FROM fnd_lookup_values flv, pay_people_groups_kfv ppg
       WHERE flv.lookup_type = 'XXHR_MK_GROUP_MAPPING'
         AND flv.language = userenv('LANG')
         AND flv.meaning = ppg.concatenated_segments
         AND flv.lookup_code = p_location;
    l_people_group_id NUMBER;
  BEGIN
    l_people_group_id := -1;
    OPEN cur_group_id;
    FETCH cur_group_id
      INTO l_people_group_id;
    CLOSE cur_group_id;
    RETURN l_people_group_id;
  END get_people_group_id;

  --
  --
  FUNCTION get_assign_location_id(p_location IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_location IS
      SELECT tl.location_id
        FROM hr_locations_all_tl tl, fnd_lookup_values flv
       WHERE tl.language = userenv('LANG')
         AND flv.lookup_type = 'XXHR_MK_LOCATION_MAPPING'
         AND flv.language = userenv('LANG')
         AND tl.location_code = flv.description
         AND flv.lookup_code = p_location;
    l_location_id NUMBER;
  BEGIN
    l_location_id := -1;
    OPEN cur_location;
    FETCH cur_location
      INTO l_location_id;
    CLOSE cur_location;
    RETURN l_location_id;
  END get_assign_location_id;

  --
  --
  FUNCTION get_status(p_status IN VARCHAR2, p_business_group_id IN NUMBER)
    RETURN NUMBER IS
    CURSOR cur_amd IS
      SELECT amd.assignment_status_type_id
        FROM per_ass_status_type_amends    amd
            ,per_ass_status_type_amends_tl amdtl
       WHERE 1 = 1
         AND amd.ass_status_type_amend_id =
             amdtl.ass_status_type_amend_id(+)
         AND amd.business_group_id(+) + 0 = p_business_group_id + 0
         AND amdtl.language(+) = userenv('LANG')
         AND amdtl.user_status = p_status;
    CURSOR cur_st IS
      SELECT sttl.assignment_status_type_id
        FROM per_assignment_status_types_tl sttl
       WHERE 1 = 1
         AND sttl.language = userenv('LANG')
         AND sttl.user_status = p_status;
    l_status_id NUMBER;
  BEGIN
    l_status_id := -1;
    OPEN cur_amd;
    FETCH cur_amd
      INTO l_status_id;
    CLOSE cur_amd;
  
    IF l_status_id IS NULL OR l_status_id = -1 THEN
      OPEN cur_st;
      FETCH cur_st
        INTO l_status_id;
      CLOSE cur_st;
    END IF;
  
    RETURN l_status_id;
  END get_status;

  --
  --
  FUNCTION is_emp_terminated(l_person_id         IN NUMBER,
                             l_business_group_id IN NUMBER) RETURN BOOLEAN IS
    CURSOR cur_service IS
      SELECT actual_termination_date
        FROM per_periods_of_service
       WHERE person_id = l_person_id
         AND l_business_group_id + 0 = 0
       ORDER BY object_version_number;
    l_date DATE;
  BEGIN
    l_date := NULL;
    OPEN cur_service;
    FETCH cur_service
      INTO l_date;
    CLOSE cur_service;
    IF l_date IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END is_emp_terminated;

  --
  --
  FUNCTION get_sale_dept_id(p_group_name IN VARCHAR2) RETURN NUMBER IS
    CURSOR cur_dept IS
      SELECT t.group_id
        FROM jtf_rs_groups_tl t
       WHERE t.group_name = p_group_name
         AND t.language = userenv('LANG');
    p_group_id NUMBER;
  BEGIN
    p_group_id := -1;
    OPEN cur_dept;
    FETCH cur_dept
      INTO p_group_id;
    CLOSE cur_dept;
    RETURN p_group_id;
  END get_sale_dept_id;

  --
  --
  FUNCTION is_duplicate(p_group_id        IN NUMBER,
                        p_employee_number IN VARCHAR2) RETURN BOOLEAN IS
    CURSOR cur_data IS
      SELECT COUNT(*)
        FROM xxpjm.xxpjm_employee_int xei
       WHERE xei.group_id = p_group_id
         AND xei.employee_number = p_employee_number
         AND xei.process_status = g_unprocess;
    l_cnt NUMBER;
  BEGIN
    l_cnt := 0;
    OPEN cur_data;
    FETCH cur_data
      INTO l_cnt;
    CLOSE cur_data;
    IF l_cnt > 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_duplicate;

  --
  --
  FUNCTION check_vendor_exist(p_employee_number IN VARCHAR2,
                              p_name_english    IN VARCHAR2) RETURN NUMBER IS
  
    CURSOR cur_vendor_name IS
      SELECT pv.vendor_id
        FROM po_vendors pv
       WHERE pv.vendor_name = p_name_english;
  
    CURSOR cur_vendor_number IS
      SELECT pv.vendor_id
        FROM po_vendors pv
       WHERE pv.segment1 = g_sp_prefix || p_employee_number;
  
    l_vendor_id_name   NUMBER;
    l_vendor_id_number NUMBER;
  BEGIN
  
    l_vendor_id_name := -1;
    OPEN cur_vendor_name;
    FETCH cur_vendor_name
      INTO l_vendor_id_name;
    CLOSE cur_vendor_name;
    l_vendor_id_number := -1;
    OPEN cur_vendor_number;
    FETCH cur_vendor_number
      INTO l_vendor_id_number;
    CLOSE cur_vendor_number;
  
    IF l_vendor_id_name = -1 AND l_vendor_id_number = -1 THEN
      RETURN 0;
    ELSIF l_vendor_id_name <> -1 AND l_vendor_id_number = -1 THEN
      RETURN 1;
    ELSIF l_vendor_id_name = -1 AND l_vendor_id_number <> -1 THEN
      RETURN 2;
    ELSIF l_vendor_id_name <> -1 AND l_vendor_id_number <> -1 THEN
      IF l_vendor_id_name = l_vendor_id_number THEN
        RETURN l_vendor_id_name;
      ELSE
        RETURN 3;
      END IF;
    END IF;
  
  END check_vendor_exist;

  --
  --
  FUNCTION check_vendor_exist(p_employee_number IN VARCHAR2) RETURN NUMBER IS
  
    CURSOR cur_vendor_number IS
      SELECT pv.vendor_id
        FROM po_vendors pv
       WHERE pv.segment1 = g_sp_prefix || p_employee_number;
  
    l_vendor_id NUMBER;
  BEGIN
    l_vendor_id := -1;
    OPEN cur_vendor_number;
    FETCH cur_vendor_number
      INTO l_vendor_id;
    CLOSE cur_vendor_number;
    RETURN l_vendor_id;
  END check_vendor_exist;

  --
  --
  FUNCTION get_object_version_number(p_table       IN VARCHAR2,
                                     p_object_name IN VARCHAR2,
                                     p_object_id   IN NUMBER,
                                     --added by fandong.chen 20130131
                                     p_effective_date IN DATE)
    RETURN NUMBER IS
    TYPE l_cursor_type IS REF CURSOR;
    cur_object              l_cursor_type;
    l_sql                   VARCHAR2(2000);
    l_object_version_number NUMBER;
    l_effective_date        VARCHAR2(100);
  BEGIN
    l_object_version_number := -1;
    IF p_table = g_t_service THEN 
      l_sql := 'SELECT object_version_number FROM ' || p_table || ' WHERE ' ||
             p_object_name || ' = ' || to_char(p_object_id);
    ELSE
    l_effective_date        := to_char(p_effective_date,'DD-MM-YYYY');
    /* l_sql                   := 'SELECT MAX(object_version_number) FROM ' ||
    p_table || ' WHERE ' || p_object_name ||
    ' = ' || to_char(p_object_id);*/
    l_sql := 'SELECT object_version_number FROM ' || p_table || ' WHERE ' ||
             p_object_name || ' = ' || to_char(p_object_id) ||
             ' AND fnd_conc_date.string_to_date('||chr(39) || l_effective_date ||chr(39)||
             ') between effective_start_date and effective_end_date';
    END IF;
    debug('get_ovn: ' || l_sql);
    OPEN cur_object FOR l_sql;
    FETCH cur_object
      INTO l_object_version_number;
    CLOSE cur_object;
    RETURN l_object_version_number;
  END get_object_version_number;

  --
  --
  FUNCTION get_effective_date(p_object_id IN NUMBER, p_table IN VARCHAR2)
    RETURN DATE IS
    CURSOR cur_emp IS
      SELECT pf.effective_start_date
        FROM per_people_f pf
       WHERE pf.person_id = p_object_id
       ORDER BY pf.object_version_number DESC;
  
    CURSOR cur_asg IS
      SELECT paaf.effective_start_date
        FROM per_all_assignments_f paaf
       WHERE paaf.assignment_id = p_object_id
       ORDER BY paaf.object_version_number DESC;
    l_date DATE;
  
  BEGIN
    l_date := NULL;
    IF p_table = g_t_person THEN
      OPEN cur_emp;
      FETCH cur_emp
        INTO l_date;
      CLOSE cur_emp;
    ELSIF p_table = g_t_assign THEN
      OPEN cur_asg;
      FETCH cur_asg
        INTO l_date;
      CLOSE cur_asg;
    END IF;
    RETURN l_date;
  END get_effective_date;

  --
  --
  FUNCTION get_period_of_service_id(p_person_id IN NUMBER) RETURN NUMBER IS
    CURSOR cur_pid IS
      SELECT pps.period_of_service_id
        FROM per_periods_of_service pps
       WHERE pps.person_id = p_person_id;
    l_service_id NUMBER;
  BEGIN
    l_service_id := -1;
    OPEN cur_pid;
    FETCH cur_pid
      INTO l_service_id;
    CLOSE cur_pid;
    RETURN l_service_id;
  END get_period_of_service_id;

  --
  --
  FUNCTION get_emp_full_name(p_person_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_emp IS
      SELECT pf.full_name
        FROM per_people_f pf
       WHERE pf.person_id = p_person_id
       ORDER BY object_version_number DESC;
    l_full_name VARCHAR2(240);
  BEGIN
    l_full_name := NULL;
    OPEN cur_emp;
    FETCH cur_emp
      INTO l_full_name;
    CLOSE cur_emp;
    RETURN l_full_name;
  END get_emp_full_name;

  --
  --
  FUNCTION get_default_sct_id RETURN NUMBER IS
    CURSOR cur_num IS
      SELECT ot.sales_credit_type_id
        FROM oe_sales_credit_types ot
       WHERE ot.quota_flag = 'Y'
         AND ot.enabled_flag = 'Y'
         AND ot.name = g_sale_credit_type;
    l_id NUMBER;
  BEGIN
    l_id := -1;
    OPEN cur_num;
    FETCH cur_num
      INTO l_id;
    CLOSE cur_num;
    RETURN l_id;
  END get_default_sct_id;

  --
  --
  FUNCTION get_default_role_id RETURN NUMBER IS
    CURSOR cur_role IS
      SELECT a.role_id
        FROM jtf_rs_roles_vl a
       WHERE a.active_flag = 'Y'
         AND a.role_name = g_role;
    l_id NUMBER;
  BEGIN
    l_id := -1;
    OPEN cur_role;
    FETCH cur_role
      INTO l_id;
    CLOSE cur_role;
    RETURN l_id;
  END get_default_role_id;

  --
  --
  FUNCTION get_default_role_code RETURN VARCHAR2 IS
    CURSOR cur_role IS
      SELECT a.role_code
        FROM jtf_rs_roles_vl a
       WHERE 1 = 1
         AND a.active_flag = 'Y'
         AND a.role_name = g_role;
    l_code VARCHAR2(30);
  BEGIN
    l_code := NULL;
    OPEN cur_role;
    FETCH cur_role
      INTO l_code;
    CLOSE cur_role;
    RETURN l_code;
  END get_default_role_code;

  --
  --
  PROCEDURE set_resource_ref_rec(p_person_id            IN NUMBER,
                                 x_resource_rec         OUT jtf_rs_resource_extns%ROWTYPE,
                                 x_rs_salerep_rec       OUT jtf_rs_salesreps%ROWTYPE,
                                 x_rs_group_relalte_rec OUT jtf_rs_group_members%ROWTYPE,
                                 x_rs_role_relate_rec   OUT jtf_rs_role_relations%ROWTYPE) IS
    CURSOR cur_rec_rs IS
      SELECT *
        FROM jtf_rs_resource_extns
       WHERE category = 'EMPLOYEE'
         AND source_id = p_person_id
       ORDER BY object_version_number DESC;
  
    CURSOR cur_rec_sale IS
      SELECT jrs.*
        FROM jtf_rs_salesreps jrs, jtf_rs_resource_extns jrre
       WHERE jrs.resource_id = jrre.resource_id
         AND jrre.source_id = p_person_id
         AND jrre.category = 'EMPLOYEE'
       ORDER BY jrs.object_version_number DESC;
  
    CURSOR cur_rec_group IS
      SELECT jrg.*
        FROM jtf_rs_group_members jrg, jtf_rs_resource_extns jrre
       WHERE jrg.resource_id = jrre.resource_id
         AND jrg.delete_flag = 'N'
         AND jrre.source_id = p_person_id
         AND jrre.category = 'EMPLOYEE'
       ORDER BY jrg.object_version_number DESC;
  
    CURSOR cur_rec_role IS
      SELECT jrr.*
        FROM jtf_rs_role_relations jrr, jtf_rs_resource_extns jrre
       WHERE jrr.role_resource_id = jrre.resource_id
         AND jrre.source_id = p_person_id
         AND jrre.category = 'EMPLOYEE'
       ORDER BY jrr.object_version_number DESC;
  
  BEGIN
    x_resource_rec         := NULL;
    x_rs_salerep_rec       := NULL;
    x_rs_group_relalte_rec := NULL;
    x_rs_role_relate_rec   := NULL;
  
    OPEN cur_rec_rs;
    FETCH cur_rec_rs
      INTO x_resource_rec;
    CLOSE cur_rec_rs;
  
    OPEN cur_rec_sale;
    FETCH cur_rec_sale
      INTO x_rs_salerep_rec;
    CLOSE cur_rec_sale;
  
    OPEN cur_rec_group;
    FETCH cur_rec_group
      INTO x_rs_group_relalte_rec;
    CLOSE cur_rec_group;
  
    OPEN cur_rec_role;
    FETCH cur_rec_role
      INTO x_rs_role_relate_rec;
    CLOSE cur_rec_role;
  
  END set_resource_ref_rec;

  --
  --
  FUNCTION get_old_hire_date(p_person_id IN NUMBER) RETURN DATE IS
    CURSOR cur_date IS
      SELECT start_date
        FROM per_all_people_f
       WHERE person_id = p_person_id
       ORDER BY object_version_number DESC;
    l_date DATE;
  BEGIN
    l_date := NULL;
    OPEN cur_date;
    FETCH cur_date
      INTO l_date;
    CLOSE cur_date;
    RETURN l_date;
  END get_old_hire_date;

  --
  --
  PROCEDURE update_rows(p_data_rec xxpjm.xxpjm_employee_int%ROWTYPE) IS
  BEGIN
    UPDATE xxpjm.xxpjm_employee_int xei
       SET ROW = p_data_rec
     WHERE xei.unique_id = p_data_rec.unique_id;
    COMMIT;
  END update_rows;

  --
  --
  PROCEDURE create_emp_job(p_data_rec   IN OUT xxpjm.xxpjm_employee_int%ROWTYPE,
                           x_error_flag OUT NOCOPY BOOLEAN,
                           x_error_msg  OUT NOCOPY VARCHAR2) IS
    CURSOR cur_group_id IS
      SELECT job_group_id
        FROM per_job_groups
       WHERE business_group_id = p_data_rec.business_group_id;
    x_job_id                NUMBER;
    x_object_version_number NUMBER;
    x_job_definition_id     NUMBER;
    x_name                  VARCHAR2(240);
    l_job_group_id          NUMBER;
  BEGIN
    x_error_flag := FALSE;
    x_error_msg  := NULL;
  
    OPEN cur_group_id;
    FETCH cur_group_id
      INTO l_job_group_id;
    CLOSE cur_group_id;
  
    IF l_job_group_id IS NOT NULL THEN
      hr_job_api.create_job(p_validate              => FALSE,
                            p_business_group_id     => p_data_rec.business_group_id,
                            p_date_from             => g_default_date,
                            p_job_group_id          => l_job_group_id,
                            p_segment1              => p_data_rec.job_location_code,
                            p_segment2              => p_data_rec.job_devision_code,
                            p_segment3              => p_data_rec.job_level_code,
                            p_language_code         => hr_api.userenv_lang,
                            p_job_id                => x_job_id,
                            p_object_version_number => x_object_version_number,
                            p_job_definition_id     => x_job_definition_id,
                            p_name                  => x_name);
      p_data_rec.job_id := x_job_id;
      debug('Create job: ' || x_name);
    ELSE
      x_error_flag := TRUE;
      x_error_msg  := 'Invalide job group for business group';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END create_emp_job;

  --
  --
  PROCEDURE create_emp_position(p_data_rec   IN OUT xxpjm.xxpjm_employee_int%ROWTYPE,
                                x_error_flag OUT NOCOPY BOOLEAN,
                                x_error_msg  OUT NOCOPY VARCHAR2) IS
    x_position_id            NUMBER;
    x_object_version_number  NUMBER;
    x_position_definition_id NUMBER;
    x_name                   VARCHAR2(240);
  BEGIN
    x_error_flag := FALSE;
    x_error_msg  := NULL;
  
    hr_position_api.create_position(p_validate               => FALSE,
                                    p_job_id                 => p_data_rec.job_id,
                                    p_organization_id        => g_org_id,
                                    p_date_effective         => g_default_date,
                                    p_working_hours          => g_working_hours,
                                    p_frequency              => g_frequency,
                                    p_time_normal_start      => g_time_normal_start,
                                    p_time_normal_finish     => g_time_normal_finish,
                                    p_location_id            => p_data_rec.assign_location_id,
                                    p_segment1               => p_data_rec.job_location_code,
                                    p_segment2               => p_data_rec.job_devision_code,
                                    p_segment3               => p_data_rec.job_level_code,
                                    p_position_id            => x_position_id,
                                    p_object_version_number  => x_object_version_number,
                                    p_position_definition_id => x_position_definition_id,
                                    p_name                   => x_name);
    p_data_rec.position_id := x_position_id;
    debug('Create position: ' || x_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END create_emp_position;

  --
  --
  PROCEDURE create_employee(p_data_rec      IN xxpjm.xxpjm_employee_int%ROWTYPE,
                            x_person_id     OUT NUMBER,
                            x_assignment_id OUT NUMBER,
                            x_error_flag    OUT NOCOPY BOOLEAN,
                            x_error_msg     OUT NOCOPY VARCHAR2) IS
    l_employee_number           VARCHAR2(240);
    x_per_object_version_number NUMBER := NULL;
    x_asg_object_version_number NUMBER := NULL;
    x_per_effective_start_date  DATE := NULL;
    x_per_effective_end_date    DATE := NULL;
    x_full_name                 VARCHAR2(240) := NULL;
    x_per_comment_id            NUMBER := NULL;
    x_assignment_sequence       NUMBER := NULL;
    x_assignment_number         VARCHAR2(30) := NULL;
    x_name_combination_warning  BOOLEAN := NULL;
    x_assign_payroll_warning    BOOLEAN := NULL;
    x_orig_hire_warning         BOOLEAN := NULL;
  BEGIN
    x_person_id       := NULL;
    x_assignment_id   := NULL;
    x_error_flag      := FALSE;
    x_error_msg       := NULL;
    l_employee_number := p_data_rec.employee_number;
  
    hr_employee_api.create_employee(p_validate                  => FALSE,
                                    p_business_group_id         => p_data_rec.business_group_id,
                                    p_hire_date                 => p_data_rec.start_working_date,
                                    p_last_name                 => p_data_rec.name_english,
                                    p_sex                       => p_data_rec.sex,
                                    p_person_type_id            => p_data_rec.employee_type_id,
                                    p_date_of_birth             => p_data_rec.date_of_birth,
                                    p_employee_number           => l_employee_number,
                                    p_attribute1                => p_data_rec.name_thai,
                                    p_attribute2                => p_data_rec.ldap_id,
                                    p_person_id                 => x_person_id,
                                    p_assignment_id             => x_assignment_id,
                                    p_per_object_version_number => x_per_object_version_number,
                                    p_asg_object_version_number => x_asg_object_version_number,
                                    p_per_effective_start_date  => x_per_effective_start_date,
                                    p_per_effective_end_date    => x_per_effective_end_date,
                                    p_full_name                 => x_full_name,
                                    p_per_comment_id            => x_per_comment_id,
                                    p_assignment_sequence       => x_assignment_sequence,
                                    p_assignment_number         => x_assignment_number,
                                    p_name_combination_warning  => x_name_combination_warning,
                                    p_assign_payroll_warning    => x_assign_payroll_warning,
                                    p_orig_hire_warning         => x_orig_hire_warning,
                                    --new field added by fandong.chen 20130201 begin
                                    p_title                     => p_data_rec.title_code
                                    --new field added by fandong.chen 20130201 end
                                    );
    debug('create_employee down. person_id:' || to_char(x_person_id));
  EXCEPTION
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END create_employee;

  --
  --
  PROCEDURE update_employee(p_data_rec   IN xxpjm.xxpjm_employee_int%ROWTYPE,
                            x_error_flag OUT NOCOPY BOOLEAN,
                            x_error_msg  OUT NOCOPY VARCHAR2) IS
    l_per_object_version_number NUMBER;
    l_employee_number           VARCHAR2(240);
    l_datetrack_update_mode     VARCHAR2(40) := hr_api.g_correction;
    --
    x_effective_start_date     DATE;
    x_effective_end_date       DATE;
    x_full_name                VARCHAR2(240);
    x_comment_id               NUMBER;
    x_name_combination_warning BOOLEAN;
    x_assign_payroll_warning   BOOLEAN;
    x_orig_hire_warning        BOOLEAN;
    x_warn_ee                  VARCHAR2(240);
    l_old_hire_date            DATE;
    l_phase                    VARCHAR2(240);
  BEGIN
    x_error_flag      := FALSE;
    x_error_msg       := NULL;
    l_employee_number := p_data_rec.employee_number;
  
    --Update hire date
    l_phase := 'Update hire date';
    debug(l_phase);
    l_old_hire_date := get_old_hire_date(p_data_rec.person_id);
    IF l_old_hire_date IS NOT NULL THEN
      hr_change_start_date_api.update_start_date(p_validate         => FALSE,
                                                 p_person_id        => p_data_rec.person_id,
                                                 p_old_start_date   => l_old_hire_date,
                                                 p_new_start_date   => p_data_rec.start_working_date,
                                                 p_update_type      => 'E',
                                                 p_applicant_number => NULL,
                                                 p_warn_ee          => x_warn_ee);
      debug(l_phase || ' ok.');
    END IF;
  
    --Update person
    l_phase := 'Update person';
    debug(l_phase);
    --modified by fandong.chen 20130131 begin
   /* l_per_object_version_number := get_object_version_number(g_t_person,
                                                             g_c_person_id,
                                                             p_data_rec.person_id);*/
     l_per_object_version_number := get_object_version_number(g_t_person,
                                                             g_c_person_id,
                                                             p_data_rec.person_id,
                                                             g_sysdate);
    --modified by fandong.chen 20130131 end                                                             
    hr_person_api.update_person(p_validate                 => FALSE,
                                p_datetrack_update_mode    => l_datetrack_update_mode,
                                p_person_id                => p_data_rec.person_id,
                                p_object_version_number    => l_per_object_version_number,
                                p_effective_date           => g_sysdate,
                                p_person_type_id           => p_data_rec.employee_type_id,
                                p_last_name                => p_data_rec.name_english,
                                p_date_of_birth            => p_data_rec.date_of_birth,
                                p_employee_number          => l_employee_number,
                                p_sex                      => p_data_rec.sex,
                                p_attribute_category       => NULL,
                                p_attribute1               => p_data_rec.name_thai,
                                p_attribute2               => p_data_rec.ldap_id,
                                p_effective_start_date     => x_effective_start_date,
                                p_effective_end_date       => x_effective_end_date,
                                p_full_name                => x_full_name,
                                p_comment_id               => x_comment_id,
                                p_name_combination_warning => x_name_combination_warning,
                                p_assign_payroll_warning   => x_assign_payroll_warning,
                                p_orig_hire_warning        => x_orig_hire_warning,
                                --new field added by fandong.chen 20130201 begin
                                p_title                     => p_data_rec.title_code
                                --new field added by fandong.chen 20130201 end
                                );
    debug(l_phase || ' ok.');
  EXCEPTION
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := 'Error when ' || l_phase || '. MSG:' ||
                      dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END update_employee;

  --
  --
  PROCEDURE update_emp_assignment(p_data_rec   IN xxpjm.xxpjm_employee_int%ROWTYPE,
                                  x_error_flag OUT NOCOPY BOOLEAN,
                                  x_error_msg  OUT NOCOPY VARCHAR2) IS
    p_asg_object_version_number NUMBER;
    p_asg_effective_start_date  DATE;
    l_datetrack_update_mode     VARCHAR2(30) := hr_api.g_correction;
    --
    x_cagr_grade_def_id          NUMBER := NULL;
    x_cagr_concatenated_segments VARCHAR2(240) := NULL;
    x_concatenated_segments      VARCHAR2(240) := NULL;
    x_soft_coding_keyflex_id     NUMBER := NULL;
    x_comment_id                 NUMBER := NULL;
    x_effective_start_date       DATE := NULL;
    x_effective_end_date         DATE := NULL;
    x_no_managers_warning        BOOLEAN := NULL;
    x_other_manager_warning      BOOLEAN := NULL;
    x_hourly_salaried_warning    BOOLEAN := NULL;
    x_gsp_post_process_warning   VARCHAR2(240) := NULL;
    --
    x_special_ceiling_step_id      NUMBER := NULL;
    x_people_group_id              NUMBER := NULL;
    x_group_name                   VARCHAR2(240) := NULL;
    x_org_now_no_manager_warning   BOOLEAN := NULL;
    x_spp_delete_warning           BOOLEAN := NULL;
    x_entries_changed_warning      VARCHAR2(240) := NULL;
    x_tax_district_changed_warning BOOLEAN := NULL;
    l_phase                        VARCHAR2(240);
  BEGIN
    x_people_group_id := p_data_rec.assign_people_group_id;
    x_error_flag      := FALSE;
    x_error_msg       := NULL;
 
    --Modified by fandong.chen 20130130 begin  
    --change the effective start date to sysdate, so we can use the update mode
    /*p_asg_object_version_number := get_object_version_number(g_t_assign,
                                                             g_c_assignment_id,
                                                             p_data_rec.assignment_id);
    p_asg_effective_start_date  := get_effective_date(p_data_rec.assignment_id,
                                                      g_t_assign); */
    p_asg_effective_start_date := trunc(SYSDATE);      
    p_asg_object_version_number := get_object_version_number(g_t_assign,
                                                             g_c_assignment_id,
                                                             p_data_rec.assignment_id,
                                                             p_asg_effective_start_date);                                         
    l_datetrack_update_mode := get_datatrack_ud_mode(p_base_table_name => 'PER_ALL_ASSIGNMENTS_F',
                                                     p_base_key_column => 'ASSIGNMENT_ID',
                                                     p_base_key_value  => p_data_rec.assignment_id,
                                                     p_effective_date  => p_asg_effective_start_date);
    log('datatrack_update_mode(update_emp_asg): '||p_data_rec.assignment_id||'  '||l_datetrack_update_mode);                                                                                           
    --Modified by fandong.chen 20130130 end     
    --Update Assignment
    l_phase := 'Update assignment main info. ';
    debug(l_phase);
    hr_assignment_api.update_emp_asg(p_validate                   => FALSE,
                                     p_datetrack_update_mode      => l_datetrack_update_mode,
                                     p_assignment_id              => p_data_rec.assignment_id,
                                     p_object_version_number      => p_asg_object_version_number,
                                     p_effective_date             => p_asg_effective_start_date,
                                     p_supervisor_id              => p_data_rec.assign_manager_id,
                                     p_assignment_status_type_id  => p_data_rec.assign_status_type_id,
                                     p_ass_attribute1             => p_data_rec.salesman, --SALE MAN FLAG
                                     p_ass_attribute2             => p_data_rec.assign_department, --DEPARTMENT
                                     p_ass_attribute3             => p_data_rec.assign_section, --SECTION
                                     p_ass_attribute4             => p_data_rec.assign_position, --POSITION    
                                     p_set_of_books_id            => g_set_of_books_id, --Added by fandong.chen 2013-03-29
                                     p_default_code_comb_id       => g_default_code_comb_id, --Added by fandong.chen 2013-03-29       
                                     p_cagr_grade_def_id          => x_cagr_grade_def_id,
                                     p_cagr_concatenated_segments => x_cagr_concatenated_segments,
                                     p_concatenated_segments      => x_concatenated_segments,
                                     p_soft_coding_keyflex_id     => x_soft_coding_keyflex_id,
                                     p_comment_id                 => x_comment_id,
                                     p_effective_start_date       => x_effective_start_date,
                                     p_effective_end_date         => x_effective_end_date,
                                     p_no_managers_warning        => x_no_managers_warning,
                                     p_other_manager_warning      => x_other_manager_warning,
                                     p_hourly_salaried_warning    => x_hourly_salaried_warning,
                                     p_gsp_post_process_warning   => x_gsp_post_process_warning);
    debug(l_phase || ' ok.');
  
    --Update Assignment Criteria
    l_phase := 'Update assignment criteria info. ';
    debug(l_phase);
    --Added by fandong.chen 20130131 begin
    --if the update mode is 'UPDATE',the object_version_number may changed
     p_asg_object_version_number := get_object_version_number(g_t_assign,
                                                             g_c_assignment_id,
                                                             p_data_rec.assignment_id,
                                                             p_asg_effective_start_date); 
     l_datetrack_update_mode := get_datatrack_ud_mode(p_base_table_name => 'PER_ALL_ASSIGNMENTS_F',
                                                     p_base_key_column => 'ASSIGNMENT_ID',
                                                     p_base_key_value  => p_data_rec.assignment_id,
                                                     p_effective_date  => p_asg_effective_start_date); 
    --Added by fandong.chen 20130131 end                                                             
    log('datatrack_update_mode(update_emp_asg_criteria): '||p_data_rec.assignment_id||'  '||l_datetrack_update_mode);  
    hr_assignment_api.update_emp_asg_criteria(p_validate                     => FALSE,
                                              p_called_from_mass_update      => FALSE,
                                              p_datetrack_update_mode        => l_datetrack_update_mode,
                                              p_assignment_id                => p_data_rec.assignment_id,
                                              p_object_version_number        => p_asg_object_version_number,
                                              p_effective_date               => p_asg_effective_start_date,
                                              p_position_id                  => p_data_rec.position_id,
                                              p_job_id                       => p_data_rec.job_id,
                                              p_organization_id              => nvl(g_org_id,
                                                                                    g_business_group_id),
                                              p_location_id                  => p_data_rec.assign_location_id,
                                              p_special_ceiling_step_id      => x_special_ceiling_step_id,
                                              p_people_group_id              => x_people_group_id, --
                                              p_soft_coding_keyflex_id       => x_soft_coding_keyflex_id,
                                              p_group_name                   => x_group_name,
                                              p_effective_start_date         => x_effective_start_date,
                                              p_effective_end_date           => x_effective_end_date,
                                              p_org_now_no_manager_warning   => x_org_now_no_manager_warning,
                                              p_other_manager_warning        => x_other_manager_warning,
                                              p_spp_delete_warning           => x_spp_delete_warning,
                                              p_entries_changed_warning      => x_entries_changed_warning,
                                              p_tax_district_changed_warning => x_tax_district_changed_warning,
                                              p_concatenated_segments        => x_concatenated_segments,
                                              p_gsp_post_process_warning     => x_gsp_post_process_warning);
    debug(l_phase || ' ok.');
  EXCEPTION
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := 'Error when ' || l_phase ||
                      dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END update_emp_assignment;

  --
  --
  PROCEDURE update_ex_info(p_data_rec   IN xxpjm.xxpjm_employee_int%ROWTYPE,
                           x_error_flag OUT NOCOPY BOOLEAN,
                           x_error_msg  OUT NOCOPY VARCHAR2) IS
    l_object_version_number      NUMBER;
    l_last_standard_process_date DATE;
    l_period_of_service_id       NUMBER;
    --
    x_supervisor_warning         BOOLEAN;
    x_event_warning              BOOLEAN;
    x_interview_warning          BOOLEAN;
    x_review_warning             BOOLEAN;
    x_recruiter_warning          BOOLEAN;
    x_asg_future_changes_warning BOOLEAN;
    x_entries_changed_warning    VARCHAR2(240);
    x_pay_proposal_warning       BOOLEAN;
    x_dod_warning                BOOLEAN;
    x_alu_change_warning         VARCHAR2(240);
  
  BEGIN
    x_error_flag := FALSE;
    x_error_msg  := NULL;
  
    IF p_data_rec.period_of_service_id IS NULL OR
       p_data_rec.period_of_service_id = -1 THEN
      l_period_of_service_id := get_period_of_service_id(p_data_rec.person_id);
    ELSE
      l_period_of_service_id := p_data_rec.period_of_service_id;
    END IF;
    --modified by fandong.chen 20130131 begin
   /* l_object_version_number      := get_object_version_number(g_t_service,
                                                              g_c_service_id,
                                                              l_period_of_service_id);*/
   l_object_version_number      := get_object_version_number(g_t_service,
                                                             g_c_service_id,
                                                             l_period_of_service_id,
                                                             g_sysdate);    
    --modified by fandong.chen 20130131 end                                                                                                                                                                                     
    l_last_standard_process_date := p_data_rec.resign_date;
  
    hr_ex_employee_api.actual_termination_emp(p_validate                   => FALSE,
                                              p_effective_date             => g_sysdate,
                                              p_period_of_service_id       => l_period_of_service_id,
                                              p_object_version_number      => l_object_version_number,
                                              p_actual_termination_date    => p_data_rec.resign_date,
                                              p_last_standard_process_date => l_last_standard_process_date,
                                              p_leaving_reason             => p_data_rec.resign_reason_code,
                                              p_supervisor_warning         => x_supervisor_warning,
                                              p_event_warning              => x_event_warning,
                                              p_interview_warning          => x_interview_warning,
                                              p_review_warning             => x_review_warning,
                                              p_recruiter_warning          => x_recruiter_warning,
                                              p_asg_future_changes_warning => x_asg_future_changes_warning,
                                              p_entries_changed_warning    => x_entries_changed_warning,
                                              p_pay_proposal_warning       => x_pay_proposal_warning,
                                              p_dod_warning                => x_dod_warning,
                                              p_alu_change_warning         => x_alu_change_warning);
    debug('update_ex_info ok');
  EXCEPTION
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END update_ex_info;

  --
  --
  PROCEDURE create_emp_resouce(p_data_rec   IN OUT xxpjm.xxpjm_employee_int%ROWTYPE,
                               x_error_flag OUT NOCOPY BOOLEAN,
                               x_error_msg  OUT NOCOPY VARCHAR2) IS
    l_salesperson_number VARCHAR2(240);
    l_emp_full_name      VARCHAR2(240);
    x_return_status      VARCHAR2(1);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(2000);
    x_resource_id        jtf_rs_resource_extns.resource_id%TYPE;
    x_resource_number    jtf_rs_resource_extns.resource_number%TYPE;
    l_msg_index_out      NUMBER;
    x_salesrep_id        jtf_rs_salesreps.salesrep_id%TYPE;
    x_role_relate_id     jtf_rs_role_relations.role_relate_id%TYPE;
    e_create_rs_exception EXCEPTION;
    l_phase VARCHAR2(240);
  BEGIN
    x_error_flag    := FALSE;
    x_error_msg     := NULL;
    l_emp_full_name := get_emp_full_name(p_data_rec.person_id);
  
    --create resource  
    l_phase := 'create resource ';
    jtf_rs_resource_pub.create_resource(p_api_version       => 1.0,
                                        p_init_msg_list     => fnd_api.g_false,
                                        p_commit            => fnd_api.g_false,
                                        p_category          => 'EMPLOYEE',
                                        p_source_id         => p_data_rec.person_id,
                                        p_source_name       => l_emp_full_name,
                                        p_resource_name     => l_emp_full_name,
                                        p_start_date_active => p_data_rec.start_working_date,
                                        p_end_date_active   => NULL,
                                        x_return_status     => x_return_status,
                                        x_msg_count         => x_msg_count,
                                        x_msg_data          => x_msg_data,
                                        x_resource_id       => x_resource_id,
                                        x_resource_number   => x_resource_number);
    IF x_return_status = 'E' OR x_resource_id IS NULL THEN
      log('Error when create resource.');
      RAISE e_create_rs_exception;
    ELSE
      p_data_rec.resource_number := x_resource_number;
      debug('Create resource successfully. ' || to_char(x_resource_id) ||
            ' - ' || x_resource_number);
    END IF;
  
    --create salesrep
    l_phase := 'create salesrep ';
    
    --Modified by fandong.chen 20130130 begin
    --the salesperson_number value come from MK system
   /* IF g_mode_of_srp_num = 'SEQUENCE_GENERATED' THEN
      BEGIN
        SELECT jtf_rs_salesrep_number_s.nextval
          INTO l_salesperson_number
          FROM dual;
      EXCEPTION
        WHEN OTHERS THEN
          l_salesperson_number := p_data_rec.employee_number;
      END;
    ELSE
      l_salesperson_number := p_data_rec.employee_number;
    END IF;*/
    l_salesperson_number := p_data_rec.salesman_number;
    --Modified by fandong.chen 20130130 end    
    jtf_rs_salesreps_pub.create_salesrep(p_api_version          => 1.0,
                                         p_init_msg_list        => fnd_api.g_true,
                                         p_commit               => fnd_api.g_false,
                                         p_resource_id          => x_resource_id,
                                         p_salesrep_number      => l_salesperson_number,
                                         p_sales_credit_type_id => get_default_sct_id,
                                         p_status               => 'A',
                                         p_start_date_active    => SYSDATE - 1,
                                         p_end_date_active      => NULL,
                                         p_set_of_books_id      => g_set_of_books_id,
                                         x_return_status        => x_return_status,
                                         x_msg_count            => x_msg_count,
                                         x_msg_data             => x_msg_data,
                                         x_salesrep_id          => x_salesrep_id);
    IF x_return_status = 'E' THEN
      log('Error when create salesrep.');
      RAISE e_create_rs_exception;
    ELSE
      debug('Create salesrep successfully. ' || to_char(x_salesrep_id));
    END IF;
  
    --create resource and groups(members) association
    l_phase := 'create resource and groups(members) association ';
    jtf_rs_grp_membership_pub.create_group_membership(p_api_version   => 1.0,
                                                      p_init_msg_list => fnd_api.g_true,
                                                      p_commit        => fnd_api.g_false,
                                                      p_resource_id   => x_resource_id,
                                                      p_group_id      => p_data_rec.sale_department_id,
                                                      p_role_id       => NULL,
                                                      p_start_date    => NULL,
                                                      p_end_date      => NULL,
                                                      x_return_status => x_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data);
    IF x_return_status = 'E' THEN
      log('Error when create group membership.');
      RAISE e_create_rs_exception;
    ELSE
      debug('Create resource and groups(members) association successfully.');
    END IF;
  
    --create resource and role association
    l_phase := 'create resource and role association ';
    jtf_rs_role_relate_pub.create_resource_role_relate(p_api_version        => 1.0,
                                                       p_init_msg_list      => fnd_api.g_true,
                                                       p_commit             => fnd_api.g_false,
                                                       p_role_resource_type => g_role_rs_type,
                                                       p_role_resource_id   => x_resource_id,
                                                       p_role_id            => get_default_role_id,
                                                       p_role_code          => get_default_role_code,
                                                       p_start_date_active  => g_sysdate,
                                                       p_end_date_active    => NULL,
                                                       x_return_status      => x_return_status,
                                                       x_msg_count          => x_msg_count,
                                                       x_msg_data           => x_msg_data,
                                                       x_role_relate_id     => x_role_relate_id);
    IF x_return_status = 'E' THEN
      log('Error when create role relatep.');
      RAISE e_create_rs_exception;
    ELSE
      debug('Create resource and role association successfully.');
    END IF;
  
  EXCEPTION
    WHEN e_create_rs_exception THEN
      x_error_flag := TRUE;
      FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
        fnd_msg_pub.get(p_msg_index     => i,
                        p_data          => x_msg_data,
                        p_encoded       => 'T',
                        p_msg_index_out => l_msg_index_out);
        fnd_message.set_encoded(x_msg_data);
        x_error_msg := fnd_message.get;
      END LOOP;
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END create_emp_resouce;

  --
  --
  PROCEDURE update_emp_resouce(p_data_rec   IN OUT xxpjm.xxpjm_employee_int%ROWTYPE,
                               x_error_flag OUT NOCOPY BOOLEAN,
                               x_error_msg  OUT NOCOPY VARCHAR2) IS
    l_phase                VARCHAR2(240);
    l_resource_rec         jtf_rs_resource_extns%ROWTYPE;
    l_rs_salerep_rec       jtf_rs_salesreps%ROWTYPE;
    l_rs_group_relalte_rec jtf_rs_group_members%ROWTYPE;
    l_rs_role_relate_rec   jtf_rs_role_relations%ROWTYPE;
    x_return_status        VARCHAR2(1);
    x_msg_count            NUMBER;
    x_msg_data             VARCHAR2(2000);
    l_msg_index_out        NUMBER;
    e_update_rs_exception EXCEPTION;
    l_emp_full_name VARCHAR2(240);
  BEGIN
  
    x_error_flag := FALSE;
    x_error_msg  := NULL;
    set_resource_ref_rec(p_person_id            => p_data_rec.person_id,
                         x_resource_rec         => l_resource_rec,
                         x_rs_salerep_rec       => l_rs_salerep_rec,
                         x_rs_group_relalte_rec => l_rs_group_relalte_rec,
                         x_rs_role_relate_rec   => l_rs_role_relate_rec);
  
    IF p_data_rec.salesman = 'Y' AND p_data_rec.resign_date IS NULL THEN
      IF l_resource_rec.resource_id IS NULL THEN
        --when no employee reource created, then create
        l_phase := 'Create resource';
        debug(l_phase);
        create_emp_resouce(p_data_rec   => p_data_rec,
                           x_error_flag => x_error_flag,
                           x_error_msg  => x_error_msg);
      
      ELSE
        --when employee have created employee reource, then update
        l_phase := 'Update resource';
        debug(l_phase);
        l_emp_full_name := get_emp_full_name(p_data_rec.person_id);
        jtf_rs_resource_pub.update_resource(p_api_version        => 1.0,
                                            p_init_msg_list      => fnd_api.g_false,
                                            p_commit             => fnd_api.g_false,
                                            p_resource_id        => l_resource_rec.resource_id,
                                            p_resource_number    => l_resource_rec.resource_number,
                                            p_resource_name      => l_emp_full_name,
                                            p_source_name        => l_emp_full_name,
                                            p_start_date_active  => l_resource_rec.start_date_active,
                                            p_end_date_active    => NULL,
                                            p_object_version_num => l_resource_rec.object_version_number,
                                            p_user_name          => l_resource_rec.user_name,
                                            x_return_status      => x_return_status,
                                            x_msg_count          => x_msg_count,
                                            x_msg_data           => x_msg_data);
        IF x_return_status = 'E' THEN
          RAISE e_update_rs_exception;
        ELSE
          p_data_rec.resource_number := l_resource_rec.resource_number;
          debug(l_phase || ' Successfully.');
        END IF;
      
        l_phase := 'Update resource salesrep';
        debug(l_phase);
        IF l_rs_salerep_rec.salesrep_id IS NOT NULL THEN
          jtf_rs_salesreps_pub.update_salesrep(p_api_version           => 1.0,
                                               p_init_msg_list         => fnd_api.g_false,
                                               p_commit                => fnd_api.g_false,
                                               p_salesrep_id           => l_rs_salerep_rec.salesrep_id,
                                               p_sales_credit_type_id  => l_rs_salerep_rec.sales_credit_type_id,
                                               p_start_date_active     => l_rs_salerep_rec.start_date_active,
                                               p_end_date_active       => NULL,
                                               p_status                => 'A',
                                               --Modified by Fandong.Chen Begin
                                               --Update salesrep_number as Employ Number
                                               --p_salesrep_number       => l_rs_salerep_rec.salesrep_number,
                                               p_salesrep_number       => p_data_rec.salesman_number,
                                               --Modified by Fandong.Chen End
                                               p_org_id                => l_rs_salerep_rec.org_id,
                                               p_object_version_number => l_rs_salerep_rec.object_version_number,
                                               x_return_status         => x_return_status,
                                               x_msg_count             => x_msg_count,
                                               x_msg_data              => x_msg_data);
          IF x_return_status = 'E' THEN
            RAISE e_update_rs_exception;
          ELSE
            debug('Update Resource Salesrep Successfully.');
          END IF;
        END IF;
      
        l_phase := 'Update resource role relate';
        debug(l_phase);
        IF l_rs_role_relate_rec.role_relate_id IS NOT NULL THEN
          jtf_rs_role_relate_pub.update_resource_role_relate(p_api_version        => 1.0,
                                                             p_init_msg_list      => fnd_api.g_true,
                                                             p_commit             => fnd_api.g_false,
                                                             p_role_relate_id     => l_rs_role_relate_rec.role_relate_id,
                                                             p_start_date_active  => l_rs_role_relate_rec.start_date_active,
                                                             p_end_date_active    => NULL,
                                                             p_object_version_num => l_rs_role_relate_rec.object_version_number,
                                                             x_return_status      => x_return_status,
                                                             x_msg_count          => x_msg_count,
                                                             x_msg_data           => x_msg_data);
          IF x_return_status = 'E' THEN
            log('Error when create group membership.');
            RAISE e_update_rs_exception;
          ELSE
            debug('Create resource and groups(members) association successfully.');
          END IF;
        END IF;
      
        l_phase := 'Delete and create resource group membership';
        debug(l_phase);
        IF l_rs_group_relalte_rec.group_member_id IS NOT NULL THEN
          jtf_rs_grp_membership_pub.delete_group_membership(p_api_version        => 1.0,
                                                            p_init_msg_list      => fnd_api.g_false,
                                                            p_commit             => fnd_api.g_false,
                                                            p_group_id           => l_rs_group_relalte_rec.group_id,
                                                            p_resource_id        => l_rs_group_relalte_rec.resource_id,
                                                            p_group_member_id    => l_rs_group_relalte_rec.group_member_id,
                                                            p_role_relate_id     => NULL,
                                                            p_object_version_num => l_rs_group_relalte_rec.object_version_number,
                                                            x_return_status      => x_return_status,
                                                            x_msg_count          => x_msg_count,
                                                            x_msg_data           => x_msg_data);
          IF x_return_status = 'E' THEN
            log('Error when delete group membership.');
            RAISE e_update_rs_exception;
          ELSE
            debug(l_phase || '-delete Successfully.');
          END IF;
        END IF;
        jtf_rs_grp_membership_pub.create_group_membership(p_api_version   => 1.0,
                                                          p_init_msg_list => fnd_api.g_true,
                                                          p_commit        => fnd_api.g_false,
                                                          p_resource_id   => l_resource_rec.resource_id,
                                                          p_group_id      => p_data_rec.sale_department_id,
                                                          p_role_id       => NULL,
                                                          p_start_date    => NULL,
                                                          p_end_date      => NULL,
                                                          x_return_status => x_return_status,
                                                          x_msg_count     => x_msg_count,
                                                          x_msg_data      => x_msg_data);
        IF x_return_status = 'E' THEN
          log('Error when re-create group membership.');
          RAISE e_update_rs_exception;
        ELSE
          debug(l_phase || '-recreate Successfully.');
        END IF;
      
      END IF;
    
    ELSIF l_resource_rec.resource_id IS NOT NULL THEN
    
      l_phase := 'Update resource salesrep';
      debug(l_phase);
      IF l_rs_salerep_rec.salesrep_id IS NOT NULL AND
         l_rs_salerep_rec.end_date_active IS NULL THEN
        jtf_rs_salesreps_pub.update_salesrep(p_api_version           => 1.0,
                                             p_init_msg_list         => fnd_api.g_false,
                                             p_commit                => fnd_api.g_false,
                                             p_salesrep_id           => l_rs_salerep_rec.salesrep_id,
                                             p_sales_credit_type_id  => l_rs_salerep_rec.sales_credit_type_id,
                                             p_start_date_active     => l_rs_salerep_rec.start_date_active,
                                             p_end_date_active       => g_sysdate,
                                             p_status                => NULL,
                                             p_salesrep_number       => l_rs_salerep_rec.salesrep_number,
                                             p_org_id                => l_rs_salerep_rec.org_id,
                                             p_object_version_number => l_rs_salerep_rec.object_version_number,
                                             x_return_status         => x_return_status,
                                             x_msg_count             => x_msg_count,
                                             x_msg_data              => x_msg_data);
        IF x_return_status = 'E' THEN
          RAISE e_update_rs_exception;
        ELSE
          debug(l_phase || ' Successfully.');
        END IF;
      END IF;
    
      l_phase := 'Update resource role relate';
      debug(l_phase);
      IF l_rs_role_relate_rec.role_relate_id IS NOT NULL AND
         l_rs_role_relate_rec.end_date_active IS NULL THEN
        jtf_rs_role_relate_pub.update_resource_role_relate(p_api_version        => 1.0,
                                                           p_init_msg_list      => fnd_api.g_true,
                                                           p_commit             => fnd_api.g_false,
                                                           p_role_relate_id     => l_rs_role_relate_rec.role_relate_id,
                                                           p_start_date_active  => l_rs_role_relate_rec.start_date_active,
                                                           p_end_date_active    => g_sysdate,
                                                           p_object_version_num => l_rs_role_relate_rec.object_version_number,
                                                           x_return_status      => x_return_status,
                                                           x_msg_count          => x_msg_count,
                                                           x_msg_data           => x_msg_data);
        IF x_return_status = 'E' THEN
          log('Error when create group membership.');
          RAISE e_update_rs_exception;
        ELSE
          debug(l_phase || ' Successfully.');
        END IF;
      END IF;
    
      l_phase := 'Delete resource group membership';
      debug(l_phase);
      IF l_rs_group_relalte_rec.group_member_id IS NOT NULL THEN
        jtf_rs_grp_membership_pub.delete_group_membership(p_api_version        => 1.0,
                                                          p_init_msg_list      => fnd_api.g_false,
                                                          p_commit             => fnd_api.g_false,
                                                          p_group_id           => l_rs_group_relalte_rec.group_id,
                                                          p_resource_id        => l_rs_group_relalte_rec.resource_id,
                                                          p_group_member_id    => l_rs_group_relalte_rec.group_member_id,
                                                          p_role_relate_id     => NULL,
                                                          p_object_version_num => l_rs_group_relalte_rec.object_version_number,
                                                          x_return_status      => x_return_status,
                                                          x_msg_count          => x_msg_count,
                                                          x_msg_data           => x_msg_data);
        IF x_return_status = 'E' THEN
          log('Error when delete group membership.');
          RAISE e_update_rs_exception;
        ELSE
          debug(l_phase || '-delete Successfully.');
        END IF;
      END IF;
    
      l_phase := 'Update resource';
      debug(l_phase);
      IF l_resource_rec.end_date_active IS NULL THEN
        jtf_rs_resource_pub.update_resource(p_api_version        => 1.0,
                                            p_init_msg_list      => fnd_api.g_false,
                                            p_commit             => fnd_api.g_false,
                                            p_resource_id        => l_resource_rec.resource_id,
                                            p_resource_number    => l_resource_rec.resource_number,
                                            p_start_date_active  => l_resource_rec.start_date_active,
                                            p_end_date_active    => g_sysdate,
                                            p_source_name        => l_resource_rec.source_name,
                                            p_object_version_num => l_resource_rec.object_version_number,
                                            p_user_name          => l_resource_rec.user_name,
                                            x_return_status      => x_return_status,
                                            x_msg_count          => x_msg_count,
                                            x_msg_data           => x_msg_data);
        IF x_return_status = 'E' THEN
          RAISE e_update_rs_exception;
        ELSE
          p_data_rec.resource_number := l_resource_rec.resource_number;
          debug(l_phase || ' Successfully.');
        END IF;
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN e_update_rs_exception THEN
      x_error_flag := TRUE;
      FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
        fnd_msg_pub.get(p_msg_index     => i,
                        p_data          => x_msg_data,
                        p_encoded       => 'T',
                        p_msg_index_out => l_msg_index_out);
        fnd_message.set_encoded(x_msg_data);
        log('Error when ' || l_phase || '. Message: ' || fnd_message.get);
        x_error_msg := x_error_msg || fnd_message.get;
      END LOOP;
  END update_emp_resouce;

  --
  --
  PROCEDURE create_emp_supplier(p_data_rec   IN xxpjm.xxpjm_employee_int%ROWTYPE,
                                x_error_flag OUT NOCOPY BOOLEAN,
                                x_error_msg  OUT NOCOPY VARCHAR2) IS
    x_return_status   VARCHAR2(10);
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(1000);
    l_msg_index_out   NUMBER;
    l_vendor_rec      ap_vendor_pub_pkg.r_vendor_rec_type;
    x_vendor_id       NUMBER;
    x_party_id        NUMBER;
    l_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
    l_vendor_site_id  NUMBER;
    l_party_site_id   NUMBER;
    l_location_id     NUMBER;
    e_create_sp_exception EXCEPTION;
    l_phase VARCHAR2(240);
  BEGIN
    x_error_flag := FALSE;
    x_error_msg  := NULL;
  
    --Create vendor
    l_phase                        := 'Create vendor';
    l_vendor_rec.segment1          := g_sp_prefix ||
                                      p_data_rec.employee_number;
    l_vendor_rec.vendor_name       := p_data_rec.name_english;
    l_vendor_rec.start_date_active := g_sysdate;
    l_vendor_rec.attribute6        := TRIM(substr(substr(p_data_rec.name_english,
                                                         1,
                                                         instr(p_data_rec.name_english,
                                                               chr(32))),
                                                  1,
                                                  10));
    l_vendor_rec.allow_awt_flag    := 'Y';
  
    pos_vendor_pub_pkg.create_vendor(p_vendor_rec    => l_vendor_rec,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     x_vendor_id     => x_vendor_id,
                                     x_party_id      => x_party_id);
    IF x_return_status = 'E' OR x_vendor_id IS NULL THEN
      RAISE e_create_sp_exception;
    ELSE
      debug('Create vendor successfully. ' || to_char(x_vendor_id));
    END IF;
  
    --Create vendor_site
    l_phase := 'Create vendor_site';
    --Fac
    l_vendor_site_rec.party_site_name       := g_sp_address_name; --address name
    l_vendor_site_rec.vendor_id             := x_vendor_id;
    l_vendor_site_rec.org_id                := g_org_id;
    l_vendor_site_rec.vendor_site_code      := g_sp_site_code_fac;
    l_vendor_site_rec.ship_to_location_code := g_sp_location_fac;
    l_vendor_site_rec.bill_to_location_code := g_sp_location_fac;
    l_vendor_site_rec.pay_site_flag         := 'Y';
    l_vendor_site_rec.purchasing_site_flag  := 'Y';
    l_vendor_site_rec.country               := g_sp_contry_code;
    l_vendor_site_rec.address_line1         := g_sp_address_1;
    l_vendor_site_rec.city                  := g_sp_city;
    l_vendor_site_rec.allow_awt_flag        := 'Y';
  
    pos_vendor_pub_pkg.create_vendor_site(p_vendor_site_rec => l_vendor_site_rec,
                                          x_return_status   => x_return_status,
                                          x_msg_count       => x_msg_count,
                                          x_msg_data        => x_msg_data,
                                          x_vendor_site_id  => l_vendor_site_id,
                                          x_party_site_id   => l_party_site_id,
                                          x_location_id     => l_location_id);
    IF x_return_status = 'E' OR x_vendor_id IS NULL THEN
      RAISE e_create_sp_exception;
    ELSE
      debug('Create vendor site successfully. ' ||
            to_char(l_vendor_site_id));
    END IF;
  
    --HQ
    l_vendor_site_rec.party_site_name       := g_sp_address_name; --address name
    l_vendor_site_rec.vendor_id             := x_vendor_id;
    l_vendor_site_rec.org_id                := g_org_id;
    l_vendor_site_rec.vendor_site_code      := g_sp_site_code_qh;
    l_vendor_site_rec.ship_to_location_code := g_sp_location_qh;
    l_vendor_site_rec.bill_to_location_code := g_sp_location_qh;
    l_vendor_site_rec.pay_site_flag         := 'Y';
    l_vendor_site_rec.purchasing_site_flag  := 'Y';
    l_vendor_site_rec.country               := g_sp_contry_code;
    l_vendor_site_rec.address_line1         := g_sp_address_1;
    l_vendor_site_rec.city                  := g_sp_city;
    l_vendor_site_rec.allow_awt_flag        := 'Y';
  
    pos_vendor_pub_pkg.create_vendor_site(p_vendor_site_rec => l_vendor_site_rec,
                                          x_return_status   => x_return_status,
                                          x_msg_count       => x_msg_count,
                                          x_msg_data        => x_msg_data,
                                          x_vendor_site_id  => l_vendor_site_id,
                                          x_party_site_id   => l_party_site_id,
                                          x_location_id     => l_location_id);
    IF x_return_status = 'E' OR x_vendor_id IS NULL THEN
      RAISE e_create_sp_exception;
    ELSE
      debug('Create vendor site successfully. ' ||
            to_char(l_vendor_site_id));
    END IF;
    --
  EXCEPTION
    WHEN e_create_sp_exception THEN
      x_error_flag := TRUE;
      FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
        fnd_msg_pub.get(p_msg_index     => i,
                        p_data          => x_msg_data,
                        p_encoded       => 'T',
                        p_msg_index_out => l_msg_index_out);
        fnd_message.set_encoded(x_msg_data);
        x_error_msg := fnd_message.get;
      END LOOP;
    WHEN OTHERS THEN
      x_error_flag := TRUE;
      x_error_msg  := dbms_utility.format_error_stack ||
                      dbms_utility.format_error_backtrace;
  END create_emp_supplier;

  --
  --
  PROCEDURE update_emp_supplier(p_data_rec   IN xxpjm.xxpjm_employee_int%ROWTYPE,
                                x_error_flag OUT NOCOPY BOOLEAN,
                                x_error_msg  OUT NOCOPY VARCHAR2) IS
    CURSOR cur_vendor IS
      SELECT pav.vendor_id, pav.party_id, hp.object_version_number
        FROM ap_suppliers pav, hz_parties hp
       WHERE pav.party_id = hp.party_id
         AND pav.segment1 = g_sp_prefix || p_data_rec.employee_number;
    CURSOR cur_vd_site(p_vendor_id IN NUMBER) IS
      SELECT pvs.vendor_site_id
        FROM po_vendor_sites_all pvs
       WHERE pvs.vendor_id = p_vendor_id
         AND pvs.org_id = g_org_id;
    l_vendor_id                   NUMBER;
    l_party_id                    NUMBER;
    l_vendor_site_id              NUMBER;
    l_party_object_version_number NUMBER;
    l_vendor_rec                  ap_vendor_pub_pkg.r_vendor_rec_type;
    l_vendor_site_rec             ap_vendor_pub_pkg.r_vendor_site_rec_type;
    l_organization_rec            hz_party_v2pub.organization_rec_type;
    x_profile_id                  NUMBER;
    x_return_status               VARCHAR2(10);
    x_msg_count                   NUMBER;
    x_msg_data                    VARCHAR2(1000);
    l_msg_index_out               NUMBER;
    e_update_sp_exception EXCEPTION;
    l_pahse VARCHAR2(240);
  BEGIN
    x_error_flag     := FALSE;
    x_error_msg      := NULL;
    l_vendor_id      := -1;
    l_vendor_site_id := -1;
    OPEN cur_vendor;
    FETCH cur_vendor
      INTO l_vendor_id, l_party_id, l_party_object_version_number;
    CLOSE cur_vendor;
    debug('Fetch vendor id:' || to_char(l_vendor_id));
    debug('Supplier status:' || p_data_rec.supplier_status);
    debug('Resign date:' || to_char(p_data_rec.resign_date, g_date_mask));
  
    IF l_vendor_id IS NOT NULL OR l_vendor_id <> -1 THEN
      IF p_data_rec.supplier_status = g_sp_new THEN
        --new supplier
        --for employee that have not created supplier, then create
        l_pahse := 'Vondor not exits. Create vendor';
        debug(l_pahse);
        create_emp_supplier(p_data_rec   => p_data_rec,
                            x_error_flag => x_error_flag,
                            x_error_msg  => x_error_msg);
      ELSIF p_data_rec.supplier_status = g_sp_old THEN
        --old supplier
        --for employee that have created supplier, 
        --only when resign employee could process and inactive supplier
        l_pahse := 'Vondor exits. Update vendor';
        debug(l_pahse);
      
        --Vendor Site 
        IF p_data_rec.resign_date IS NOT NULL THEN
        
          l_pahse := 'Update vendor site(Inactive)';
          debug(l_pahse);
          FOR rec IN cur_vd_site(l_vendor_id) LOOP
            l_vendor_site_id := rec.vendor_site_id;
            l_pahse          := 'Update vendor site, id:' ||
                                to_char(l_vendor_site_id);
            debug(l_pahse);
          
            l_vendor_site_rec.vendor_id      := l_vendor_id;
            l_vendor_site_rec.vendor_site_id := l_vendor_site_id;
            l_vendor_site_rec.inactive_date  := g_sysdate;
            pos_vendor_pub_pkg.update_vendor_site(p_vendor_site_rec => l_vendor_site_rec,
                                                  x_return_status   => x_return_status,
                                                  x_msg_count       => x_msg_count,
                                                  x_msg_data        => x_msg_data);
            IF x_return_status = 'E' THEN
              log('Error when ' || l_pahse);
              RAISE e_update_sp_exception;
            ELSE
              debug('Update vendor site[' || to_char(l_vendor_site_id) ||
                    '] successfully.');
            END IF;
          
          END LOOP;
        
        END IF;
      
        --Vendor 
        IF p_data_rec.resign_date IS NOT NULL THEN
          l_pahse := 'Update vendor(Inactive), id:' || to_char(l_vendor_id);
          debug(l_pahse);
          l_vendor_rec.end_date_active := g_sysdate;
        ELSE
          l_pahse := 'Update vendor id:' || to_char(l_vendor_id);
          debug(l_pahse);
        END IF;
        l_vendor_rec.vendor_id := l_vendor_id;
        /* l_vendor_rec.vendor_name := p_data_rec.name_english;
        l_vendor_rec.attribute6  := TRIM(substr(substr(p_data_rec.name_english,
                                                       1,
                                                       instr(p_data_rec.name_english,
                                                             chr(32))),
                                                1,
                                                10));*/
        pos_vendor_pub_pkg.update_vendor(p_vendor_rec    => l_vendor_rec,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data);
        IF x_return_status = 'E' THEN
          RAISE e_update_sp_exception;
        ELSE
          debug('Update vendor successfully.');
          l_pahse := 'Update vendor name, id:' || to_char(l_vendor_id);
          debug(l_pahse);
          l_organization_rec.party_rec.party_id := l_party_id;
          l_organization_rec.organization_name  := p_data_rec.name_english;
          hz_party_v2pub.update_organization(p_init_msg_list               => fnd_api.g_true,
                                             p_organization_rec            => l_organization_rec,
                                             p_party_object_version_number => l_party_object_version_number,
                                             x_profile_id                  => x_profile_id,
                                             x_return_status               => x_return_status,
                                             x_msg_count                   => x_msg_count,
                                             x_msg_data                    => x_msg_data);
          IF x_return_status = 'E' THEN
            log('Error when update vendor name.');
            RAISE e_update_sp_exception;
          ELSE
            debug('Update vendor name successfully.[' ||
                  to_char(l_party_object_version_number) || ']');
          END IF;
        
        END IF;
      
        --
      END IF;
    END IF;
  EXCEPTION
    WHEN e_update_sp_exception THEN
      x_error_flag := TRUE;
      FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
        fnd_msg_pub.get(p_msg_index     => i,
                        p_data          => x_msg_data,
                        p_encoded       => 'T',
                        p_msg_index_out => l_msg_index_out);
        fnd_message.set_encoded(x_msg_data);
        x_error_msg := x_error_msg || ' ' || fnd_message.get;
      END LOOP;
  END update_emp_supplier;

  --
  --
  PROCEDURE create_records(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                           p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                           p_data_rec      IN OUT xxpjm.xxpjm_employee_int%ROWTYPE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           x_error_msg     OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'create_records';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'create_records';
    l_phase      VARCHAR2(240);
    l_error_flag BOOLEAN;
    l_error_msg  VARCHAR2(1000);
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
  
    --API body
  
    --3.1 Create Job and Position when not exists
    l_phase := '3.1 Create Job and Position when not exists';
    debug(l_phase);
    IF p_data_rec.job_id IS NULL OR p_data_rec.job_id = -1 THEN
      create_emp_job(p_data_rec   => p_data_rec,
                     x_error_flag => l_error_flag,
                     x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when create Job! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    IF p_data_rec.position_id IS NULL OR p_data_rec.position_id = -1 THEN
      create_emp_position(p_data_rec   => p_data_rec,
                          x_error_flag => l_error_flag,
                          x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when create Position! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  
    --3.2 Create Employee
    l_phase := '3.2 Create Employee';
    debug(l_phase);
    create_employee(p_data_rec      => p_data_rec,
                    x_person_id     => p_data_rec.person_id,
                    x_assignment_id => p_data_rec.assignment_id,
                    x_error_flag    => l_error_flag,
                    x_error_msg     => l_error_msg);
  
    IF l_error_flag OR p_data_rec.person_id IS NULL OR
       p_data_rec.assignment_id IS NULL THEN
      x_error_msg := 'Error when create employee! ' || l_error_msg;
      log(x_error_msg);
      RAISE fnd_api.g_exc_error;
    END IF;
  
    --3.3 Update Assignment Info
    l_phase := '3.3 Update Assignment Info';
    debug(l_phase);
    update_emp_assignment(p_data_rec   => p_data_rec,
                          x_error_flag => l_error_flag,
                          x_error_msg  => l_error_msg);
    IF l_error_flag THEN
      x_error_msg := 'Error when update assignment! ' || l_error_msg;
      log(x_error_msg);
      RAISE fnd_api.g_exc_error;
    END IF;
  
    --3.4 Update Resign Info
    l_phase := '3.4 Update Resign Info';
    debug(l_phase);
    IF p_data_rec.resign_date IS NOT NULL THEN
      update_ex_info(p_data_rec   => p_data_rec,
                     x_error_flag => l_error_flag,
                     x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when update ex info! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  
    --3.5 Create Resource Info
    l_phase := '3.5 Create Resource Info';
    debug(l_phase);
    IF p_data_rec.salesman = 'Y' THEN
      create_emp_resouce(p_data_rec   => p_data_rec,
                         x_error_flag => l_error_flag,
                         x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when create resouce info! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  
    --3.6 Create Supplier Info
    l_phase := '3.6 Create Supplier Info';
    debug(l_phase);
    IF p_data_rec.supplier_status = g_sp_new THEN
      create_emp_supplier(p_data_rec   => p_data_rec,
                          x_error_flag => l_error_flag,
                          x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when create vendor! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  
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
  END create_records;

  --
  --
  PROCEDURE update_records(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                           p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                           p_data_rec      IN OUT xxpjm.xxpjm_employee_int%ROWTYPE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           x_error_msg     OUT NOCOPY VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_records';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'update_records';
    l_phase      VARCHAR2(240);
    l_error_flag BOOLEAN;
    l_error_msg  VARCHAR2(1000);
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
  
    --API body
  
    --3.1 Create Job and Position when not exists
    l_phase := '3.1 Create Job and Position when not exists';
    debug(l_phase);
    IF p_data_rec.job_id IS NULL OR p_data_rec.job_id = -1 THEN
      create_emp_job(p_data_rec   => p_data_rec,
                     x_error_flag => l_error_flag,
                     x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when create Job! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    IF p_data_rec.position_id IS NULL OR p_data_rec.position_id = -1 THEN
      create_emp_position(p_data_rec   => p_data_rec,
                          x_error_flag => l_error_flag,
                          x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when create Position! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  
    --3.2 Update Employee
    l_phase := '3.2 Update Employee';
    debug(l_phase);
    update_employee(p_data_rec   => p_data_rec,
                    x_error_flag => l_error_flag,
                    x_error_msg  => l_error_msg);
    IF l_error_flag THEN
      x_error_msg := 'Error when update emp! ' || l_error_msg;
      log(x_error_msg);
      RAISE fnd_api.g_exc_error;
    END IF;
  
    --3.3 Update Assignment Info
    l_phase := '3.3 Update Assignment Info';
    debug(l_phase);
    update_emp_assignment(p_data_rec   => p_data_rec,
                          x_error_flag => l_error_flag,
                          x_error_msg  => l_error_msg);
    IF l_error_flag THEN
      x_error_msg := 'Error when update assign info! ' || l_error_msg;
      log(x_error_msg);
      RAISE fnd_api.g_exc_error;
    END IF;
  
    --3.4 Update Resign Info
    l_phase := '3.4 Update Resign Info';
    debug(l_phase);
    IF p_data_rec.resign_date IS NOT NULL THEN
      update_ex_info(p_data_rec   => p_data_rec,
                     x_error_flag => l_error_flag,
                     x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when update ex info! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  
    --3.5 Update Resource Info
    l_phase := '3.5 Update Resource Info';
    debug(l_phase);
    IF p_data_rec.resign_date IS NOT NULL OR
       p_data_rec.salesman IS NOT NULL THEN
      update_emp_resouce(p_data_rec   => p_data_rec,
                         x_error_flag => l_error_flag,
                         x_error_msg  => l_error_msg);
      IF l_error_flag THEN
        x_error_msg := 'Error when update Resource Info! ' || l_error_msg;
        log(x_error_msg);
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  
    --3.6 Update Supplier Info
    l_phase := '3.6 Update Supplier Info';
    debug(l_phase);
    update_emp_supplier(p_data_rec   => p_data_rec,
                        x_error_flag => l_error_flag,
                        x_error_msg  => l_error_msg);
    IF l_error_flag THEN
      x_error_msg := 'Error when update vendor! ' || l_error_msg;
      log(x_error_msg);
      RAISE fnd_api.g_exc_error;
    END IF;
  
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
  END update_records;

  --
  --
  PROCEDURE validate_record(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_group_id      IN NUMBER,
                            p_record_status IN VARCHAR2,
                            x_row_count     OUT NUMBER,
                            x_err_count     OUT NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    CURSOR cur_data IS
      SELECT xei.*
        FROM xxpjm.xxpjm_employee_int xei
       WHERE xei.group_id = p_group_id
         AND xei.process_status = p_record_status;
    l_data_rec cur_data%ROWTYPE;
    l_api_name       CONSTANT VARCHAR2(30) := 'validate_record';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'validate_record';
    l_phase           VARCHAR2(1000);
    l_nullable        BOOLEAN;
    l_nullable_msg    VARCHAR2(32767);
    l_employee_id     NUMBER;
    l_job_name        VARCHAR2(240);
    l_position_name   VARCHAR2(240);
    l_supplier_status NUMBER;
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
  
    -- Validate API body begin
  
    x_row_count := 0;
    x_err_count := 0;
  
    FOR rec IN cur_data LOOP
    
      l_data_rec        := NULL;
      l_data_rec        := rec;
      l_nullable        := FALSE;
      l_nullable_msg    := NULL;
      l_supplier_status := NULL;
    
      l_data_rec.process_status  := g_processing;
      l_data_rec.process_date    := SYSDATE;
      l_data_rec.process_message := NULL;
    
      --2.1 Validate Nullable
      l_phase := '2.1 Validate Nullable';
      debug(l_phase);
      IF l_data_rec.action IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[ACTION] ';
      END IF;
      IF l_data_rec.employee_number IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[EMPLOYEE_NUMBER] ';
      END IF;
      IF l_data_rec.name_english IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[NAME_ENGLISH] ';
      END IF;
      --Disabled by fandong.chen 20130130
     /* IF l_data_rec.ldap_id IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[LDAP_ID] ';
      END IF;*/
      IF l_data_rec.sex IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[SEX] ';
      END IF;
      IF l_data_rec.start_working_date IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[START_WORKING_DATE] ';
      END IF;
      IF l_data_rec.job_location IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[JOB_LOCATION] ';
      END IF;
      IF l_data_rec.job_devision IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[JOB_DEVISION] ';
      END IF;
      IF l_data_rec.job_level IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[JOB_LEVEL_CODE] ';
      END IF;
      IF l_data_rec.employee_type IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[EMPLOYEE_TYPE] ';
      END IF;
      IF l_data_rec.assign_status IS NULL THEN
        l_nullable     := TRUE;
        l_nullable_msg := l_nullable_msg || '[ASSIGN_STATUS] ';
      END IF;
      IF l_nullable THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      l_nullable_msg || 'cannot be null.';
      END IF;
    
      --2.2 Validate Action
      l_phase := '2.2 Validate Action';
      debug(l_phase);
      IF upper(l_data_rec.action) <> 'CREATE' AND
         upper(l_data_rec.action) <> 'UPDATE' THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide ACTION[' ||
                                      l_data_rec.action || '].';
      END IF;
    
      --2.3 Validate Emloyee Number
      l_phase := '2.3 Validate Emloyee Number';
      debug(l_phase);
      l_data_rec.person_id := get_employee_id(l_data_rec.employee_number);
      IF l_data_rec.person_id IS NULL OR l_data_rec.person_id = -1 THEN
        IF upper(l_data_rec.action) = 'UPDATE' THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide EMPLOYEE_NUMBER[' ||
                                        l_data_rec.employee_number ||
                                        '], employee number not exists when update.';
        ELSE
          l_data_rec.business_group_id := g_business_group_id;
        END IF;
      ELSE
        IF upper(l_data_rec.action) = 'CREATE' THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide EMPLOYEE_NUMBER[' ||
                                        l_data_rec.employee_number ||
                                        '], employee number exists when create.';
        ELSE
          l_data_rec.business_group_id := get_business_group_id(l_data_rec.person_id);
          l_data_rec.assignment_id     := get_assignment_id(l_data_rec.person_id,
                                                            l_data_rec.business_group_id);
        END IF;
      END IF;
    
      --2.4 Validate Sex
      l_phase := '2.4 Validate Sex';
      debug(l_phase);
      IF l_data_rec.sex <> 'F' AND l_data_rec.sex <> 'M' THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide SEX[' || l_data_rec.sex || '].';
      END IF;
    
      --2.5 Validate Employee Type
      l_phase := '2.5 Validate Employee Type';
      debug(l_phase);
      l_data_rec.employee_type_id := get_employee_type_id(l_data_rec.employee_type);
      IF l_data_rec.employee_type_id IS NULL OR
         l_data_rec.employee_type_id = -1 THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide EMPLOYEE_TYPE[' ||
                                      l_data_rec.employee_type || '].';
      END IF;
    
      --2.6 Validate Resign Reason
      l_phase := '2.6 Validate Resign Reason';
      debug(l_phase);
      IF l_data_rec.resign_date IS NOT NULL THEN
        l_data_rec.period_of_service_id := get_period_of_service_id(l_data_rec.person_id);
        l_data_rec.resign_reason_code   := get_resign_code(l_data_rec.resign_reason);
        IF l_data_rec.resign_reason_code IS NULL THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide RESIGN_REASON[' ||
                                        l_data_rec.resign_reason ||
                                        '], please check reason or mapping lookup type.';
        END IF;
        IF upper(l_data_rec.action) = 'CREATE' THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := 'Cannot resign employee when create.';
        END IF;
      END IF;
    
      --2.7 Validate Assignment Location, Division, Level Code and Job Name
      --Location
      l_phase := '2.7.1 Validate Assignment Job Location';
      debug(l_phase);
      l_data_rec.job_location_code := get_lookup_meaning(l_data_rec.job_location,
                                                         g_lookup_location);
      IF l_data_rec.job_location_code IS NULL THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_LOCATION[' ||
                                      l_data_rec.job_location || '].';
      ELSIF NOT is_valueset_value(l_data_rec.job_location_code,
                                  NULL,
                                  g_vs_location) THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_LOCATION[' ||
                                      l_data_rec.job_location ||
                                      '], please lookup type mapping.';
      END IF;
    
      --Division
      l_phase := '2.7.2 Validate Assignment Job Division';
      debug(l_phase);
      l_data_rec.job_devision_code := get_lookup_desc(l_data_rec.job_devision,
                                                      g_lookup_division);
      IF l_data_rec.job_devision_code IS NULL THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_DEVISION[' ||
                                      l_data_rec.job_devision || '].';
      ELSIF NOT is_valueset_value(l_data_rec.job_devision_code,
                                  l_data_rec.job_location_code,
                                  g_vs_division) THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_DEVISION[' ||
                                      l_data_rec.job_devision ||
                                      '], please lookup type mapping.';
      END IF;
    
      --Level
      l_phase := '2.7.3 Validate Assignment Job Level';
      debug(l_phase);
      l_data_rec.job_level_code := get_lookup_desc(l_data_rec.job_level,
                                                   g_lookup_level);
      IF l_data_rec.job_level_code IS NULL THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_LEVEL[' ||
                                      l_data_rec.job_level || '].';
      ELSIF NOT is_valueset_value(l_data_rec.job_level_code,
                                  l_data_rec.job_location_code,
                                  g_vs_level) THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_LEVEL[' ||
                                      l_data_rec.job_level ||
                                      '], please lookup type mapping.';
      END IF;
    
      --Job Name
      l_phase := '2.7.4 Validate Assignment Job Name';
      debug(l_phase);
      l_job_name        := l_data_rec.job_location_code || '.' ||
                           l_data_rec.job_devision_code || '.' ||
                           l_data_rec.job_level_code;
      l_data_rec.job_id := get_job_id(l_job_name);
    
      --Position Name
      l_phase := '2.7.5 Validate Assignment Position Name';
      debug(l_phase);
      l_position_name        := l_data_rec.job_location_code || '.' ||
                                l_data_rec.job_devision_code || '.' ||
                                l_data_rec.job_level_code;
      l_data_rec.position_id := get_position_id(l_position_name);
    
      --2.7.6 Validate Assignment Group
      l_phase := '2.7.6 Validate Assignment Group';
      debug(l_phase);
      l_data_rec.assign_people_group_id := get_people_group_id(l_data_rec.job_location);
      IF l_data_rec.assign_people_group_id = -1 OR
         l_data_rec.assign_people_group_id IS NULL THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_LOCATION[' ||
                                      l_data_rec.job_location ||
                                      '] for assignment group.';
      END IF;
    
      --2.7.7 Validate Assignment Location
      l_phase := '2.7.7 Validate Assignment Location';
      debug(l_phase);
      l_data_rec.assign_location_id := get_assign_location_id(l_data_rec.job_location);
      IF l_data_rec.assign_location_id = -1 OR
         l_data_rec.assign_location_id IS NULL THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide JOB_LOCATION[' ||
                                      l_data_rec.job_location ||
                                      '] for assignment location.';
      END IF;
    
      --2.8 Validate Assignment Status
      l_phase := '2.8 Validate Assignment Status';
      debug(l_phase);
      l_data_rec.assign_status_type_id := get_status(l_data_rec.assign_status,
                                                     l_data_rec.business_group_id);
      IF l_data_rec.assign_status_type_id IS NULL OR
         l_data_rec.assign_status_type_id = -1 THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide ASSIGN_STATUS[' ||
                                      l_data_rec.assign_status || '].';
      END IF;
    
      --2.9 Validate Assign Manager
      l_phase := '2.9 Validate Assign Manager';
      debug(l_phase);
      --modified by fandong.chen 20130131
      --supervisor is not required
      IF l_data_rec.assign_manager IS NOT NULL THEN
        l_data_rec.assign_manager_id := get_employee_id(l_data_rec.assign_manager);
        IF l_data_rec.assign_manager_id IS NULL OR
           l_data_rec.assign_manager_id = -1 THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide ASSIGN_MANAGER[' ||
                                        l_data_rec.assign_manager || '].';
        END IF;
      END IF;
    
      --2.10 Validate Salesman Flag and Sale Department
      l_phase := '2.10 Validate Salesman Flag and Sale Department';
      debug(l_phase);
      IF is_emp_terminated(l_data_rec.person_id,
                           l_data_rec.business_group_id) THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide person[' ||
                                      l_data_rec.employee_number ||
                                      '], cannot update salesman when employee is terminated.';
      END IF;
      IF l_data_rec.salesman IS NOT NULL AND l_data_rec.salesman <> 'Y' AND
         l_data_rec.salesman <> 'N' THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide Job SALESMAN[' ||
                                      l_data_rec.salesman || '].';
      ELSIF l_data_rec.salesman = 'Y' THEN
        IF l_data_rec.sale_department IS NULL THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide Job SALE_DEPARTMENT[' ||
                                        l_data_rec.sale_department ||
                                        '], field cannot be null when SALESMAN is Y.';
        END IF;
        --new field validate added by fandong.chen 20130130 begin
        IF l_data_rec.salesman_number IS NULL THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide Job SALESMAN_NUMBER[' ||
                                        l_data_rec.sale_department ||
                                        '], field cannot be null when SALESMAN is Y.';
        END IF;
        --new field validate added by fandong.chen 20130130 end        
        /*IF l_data_rec.resign_reason_code IS NOT NULL THEN
          l_data_rec.sale_department := '000';
        END IF;*/
        l_data_rec.sale_department_id := get_sale_dept_id(l_data_rec.sale_department);
        IF l_data_rec.sale_department_id IS NULL OR
           l_data_rec.sale_department_id = -1 THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide Job SALE_DEPARTMENT[' ||
                                        l_data_rec.sale_department || '].';
        END IF;
      ELSIF l_data_rec.salesman = 'N' THEN
        l_data_rec.salesman        := 'N';
        l_data_rec.sale_department := NULL;
      ELSE
        l_data_rec.salesman        := NULL;
        l_data_rec.sale_department := NULL;
      END IF;
    
      --2.11 Validate start_working_date and birth_date
      l_phase := '2.11 Validate start_working_date and birth_date';
      debug(l_phase);
      IF l_data_rec.date_of_birth IS NOT NULL AND
         l_data_rec.date_of_birth > l_data_rec.start_working_date THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Invalide Job DATE_OF_BIRTH[' ||
                                      to_char(l_data_rec.date_of_birth,
                                              g_date_mask) || '].';
      END IF;
    
      --2.12 Check duplicate
      l_phase := '2.12 Check duplicate';
      debug(l_phase);
      IF is_duplicate(p_group_id, l_data_rec.employee_number) THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Duplicate records in this group.[' ||
                                      l_data_rec.employee_number || '].';
      END IF;
    
      --2.13 Validate Supplier
      l_phase := '2.13 Validate Supplier';
      debug(l_phase);
      l_supplier_status := check_vendor_exist(l_data_rec.employee_number,
                                              l_data_rec.name_english);
      IF l_supplier_status = 0 THEN
        l_data_rec.supplier_status := g_sp_new;
      ELSIF l_supplier_status = 1 THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Vedor Name[' ||
                                      l_data_rec.name_english ||
                                      '] exists but vendor number is not [' ||
                                      g_sp_prefix ||
                                      l_data_rec.employee_number || '].';
      ELSIF l_supplier_status = 2 THEN
        l_data_rec.supplier_status := g_sp_old;
        /*l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Vedor Number[' || g_sp_prefix ||
                                      l_data_rec.employee_number ||
                                      '] exists but vendor name is not [' ||
                                      l_data_rec.name_english || '].';*/
      ELSIF l_supplier_status = 3 THEN
        l_data_rec.process_status  := g_error;
        l_data_rec.process_message := l_data_rec.process_message ||
                                      'Vedor Number[' || g_sp_prefix ||
                                      l_data_rec.employee_number ||
                                      '] exists and vendor name[' ||
                                      l_data_rec.name_english ||
                                      '] exists, but not the same vendor.';
      ELSE
        l_data_rec.supplier_status := g_sp_old;
      END IF;
      
      --new field validate added by fandong.chen 20130201 begin
      --2.14 Validate title
      l_phase := '2.14 Validate title';
      debug(l_phase);
      IF l_data_rec.title_english IS NOT NULL THEN
        l_data_rec.title_code := get_hr_lookup_code(g_lookup_title,l_data_rec.title_english);
        IF l_data_rec.title_code IS NULL THEN
          l_data_rec.process_status  := g_error;
          l_data_rec.process_message := l_data_rec.process_message ||
                                        'Invalide Job TITLE_ENGLISH[' ||
                                         l_data_rec.title_english || '].';
        END IF;
      END IF;
      --new field validate added by fandong.chen 20130201 end
      
      --
      l_data_rec.last_updated_by       := g_last_updated_by;
      l_data_rec.last_update_login     := g_last_update_login;
      l_data_rec.last_update_date      := g_last_update_date;
      l_data_rec.object_version_number := l_data_rec.object_version_number + 1;
      l_data_rec.request_id            := g_request_id;
      --
      UPDATE xxpjm.xxpjm_employee_int INT
         SET ROW = l_data_rec
       WHERE int.unique_id = l_data_rec.unique_id;
    
      x_row_count := x_row_count + 1;
      IF l_data_rec.process_status = g_error THEN
        x_err_count := x_err_count + 1;
      END IF;
      debug('------------------------------');
    
    END LOOP;
  
    -- Validate API body end 
  
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
    COMMIT;
  
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
  END validate_record;

  --
  --
  PROCEDURE process_record(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                           p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           p_group_id      IN NUMBER,
                           x_error_flag    OUT VARCHAR2) IS
    CURSOR cur_date IS
      SELECT xei.*
        FROM xxpjm.xxpjm_employee_int xei
       WHERE xei.group_id = p_group_id
         AND xei.process_status = g_processing;
    l_api_name       CONSTANT VARCHAR2(30) := 'process_record';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'process_record';
    l_phase    VARCHAR2(240);
    l_data_rec cur_date%ROWTYPE;
    --
    l_return_status VARCHAR2(5);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_error_msg     VARCHAR2(32767);
    --
    l_error_cnt NUMBER;
    e_process_rec_exception EXCEPTION;
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
    -- Process Records API body begin
  
    x_error_flag := 'N';
    l_error_cnt  := 0;
  
    FOR rec IN cur_date LOOP
      l_data_rec      := NULL;
      l_data_rec      := rec;
      l_return_status := NULL;
      l_msg_count     := NULL;
      l_msg_data      := NULL;
      l_error_msg     := NULL;
    
      IF upper(l_data_rec.action) = 'CREATE' THEN
        debug('CREATE');
        create_records(p_init_msg_list => fnd_api.g_false,
                       p_commit        => fnd_api.g_false,
                       p_data_rec      => l_data_rec,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data,
                       x_error_msg     => l_error_msg);
      
      ELSIF upper(l_data_rec.action) = 'UPDATE' THEN
        debug('UPDATE');
        update_records(p_init_msg_list => fnd_api.g_false,
                       p_commit        => fnd_api.g_false,
                       p_data_rec      => l_data_rec,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data,
                       x_error_msg     => l_error_msg);
      END IF;
    
      IF l_return_status = 'E' THEN
        l_error_cnt                := l_error_cnt + 1;
        l_data_rec.process_status  := 'E';
        l_data_rec.process_message := substr(l_error_msg, 1, 2400);
      ELSE
        l_data_rec.process_status := 'S';
      END IF;
      update_rows(l_data_rec);
      debug('------------------------------');
    
    END LOOP;
  
    IF l_error_cnt > 0 THEN
      x_error_flag := 'Y';
    END IF;
    log('Process Error Count: ' || to_char(l_error_cnt));
  
    -- Process Records API body end
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      log('Error1:' || SQLERRM);
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      log('Error2:' || SQLERRM);
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      log('Error3:' || SQLERRM);
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
  END process_record;

  --
  --
  PROCEDURE print_import_report(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2,
                                p_group_id      IN NUMBER) IS
    CURSOR cur_data IS
      SELECT xei.action
            ,xei.employee_number
            ,xei.name_thai
            ,xei.name_english
            ,xei.sex
            ,xei.date_of_birth
            ,xei.start_working_date
            ,xei.employee_type
            ,xei.resign_date
            ,xei.resign_reason
            ,xei.job_location_code
            ,xei.job_devision_code
            ,xei.job_level_code
            ,xei.assign_manager
            ,xei.assign_status
            ,xei.salesman
            ,xei.sale_department
            ,xei.resource_number
            ,xei.process_status
            ,xei.process_message
            ,xei.ldap_id
            ,xei.salesman_number
            ,xei.title_english
        FROM xxpjm.xxpjm_employee_int xei
       WHERE xei.group_id = p_group_id;
    l_api_name       CONSTANT VARCHAR2(30) := 'print_import_report';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'print_import_report';
    l_phase    VARCHAR2(240);
    l_data_rec cur_data%ROWTYPE;
    l_print_by VARCHAR2(50) := fnd_global.user_name;
    l_status   VARCHAR2(50);
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
    -- API body
  
    l_phase := 'output header';
    output('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
    output('<html xmlns="http://www.w3.org/1999/xhtml">');
    output('<head>');
    output('<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />');
    output('<title>Employee Import Interface Report</title>');
    output('</head>');
    output('<body>');
    output('<div align=center>');
    output('<table width="850" height="80"align="center">');
    output('<tr>');
    output('<td colspan="3" align="center"><h2>Employee Import Interface Report</h2></td>');
    output('</tr>');
    output('</table>');
    output('<table width="850" style="text-align:left">');
    output('<tr><td>Print Date : ' || to_char(SYSDATE, g_date_mask) ||
           '</td></tr>');
    output('<tr><td>Print By : ' || l_print_by || '</td></tr>');
    output('</table>');
  
    l_phase := 'output line_title';
    output('<table width="850" cellpadding=1 cellspacing=0 border=1 bordercolorlight="#000000" bordercolordark="#FFFFFF">');
    output('<tr bgcolor="#999999" style="text-align:center">');
    output('<td>Action</td>');
    output('<td>Employee</td>');
    output('<td>Name Thai</td>');
    output('<td>Name English</td>');
    output('<td>Title English</td>');
    --Added New Column LDAP ID by Fandong.Chen
    output('<td>LDAP ID</td>');
    output('<td>Sex</td>');
    output('<td>Birth</td>');
    output('<td>Hire date</td>');
    output('<td>EMP Type</td>');
    output('<td>Resign Date</td>');
    output('<td>Resign Reason</td>');
    output('<td>Job</td>');
    output('<td>Assign Manager</td>');
    output('<td>Assign Status</td>');
    output('<td>Sale</td>');
    output('<td>Salesman Number</td>');
    output('<td>Sale Dept</td>');
    output('<td>Resource Number</td>');
    output('<td>Supplier Number</td>');
    output('<td>Status</td>');
    output('<td>Message</td>');
    output('</tr>');
  
    l_phase := 'output line content';
    FOR rec IN cur_data LOOP
      CASE rec.process_status
        WHEN 'S' THEN
          l_status := 'Success';
        WHEN 'E' THEN
          l_status := 'Error';
        WHEN 'P' THEN
          l_status := 'Pending';
        WHEN 'R' THEN
          l_status := 'Processing';
        ELSE
          l_status := 'Unknown';
      END CASE;
      output('<tr>');
      output('<td>' || rec.action || '</td>');
      output('<td>' || rec.employee_number || '</td>');
      output('<td>' || rec.name_thai || '</td>');
      output('<td>' || rec.name_english || '</td>');
      output('<td>' || rec.title_english || '</td>');
      --Added new column by Fandong.chen 20130128
      output('<td>' || rec.ldap_id || '</td>');
      output('<td>' || rec.sex || '</td>');
      output('<td>' || to_char(rec.date_of_birth, 'DD-MON-YYYY') ||
             '</td>');
      output('<td>' || to_char(rec.start_working_date, 'DD-MON-YYYY') ||
             '</td>');
      output('<td>' || rec.employee_type || '</td>');
      output('<td>' || to_char(rec.resign_date, 'DD-MON-YYYY') || '</td>');
      output('<td>' || rec.resign_reason || '</td>');
      output('<td>' || rec.job_location_code || '.' ||
             rec.job_devision_code || '.' || rec.job_level_code || '</td>');
      output('<td>' || rec.assign_manager || '</td>');
      output('<td>' || rec.assign_status || '</td>');
      output('<td>' || rec.salesman || '</td>');
      output('<td>' || rec.salesman_number || '</td>');
      output('<td>' || rec.sale_department || '</td>');
      output('<td>' || rec.resource_number || '</td>');
      output('<td>' || g_sp_prefix || rec.employee_number || '</td>');
      output('<td>' || l_status || '</td>');
      output('<td>' || rec.process_message || '</td>');
      output('</tr>');
    END LOOP;
    output('</table>');
  
    l_phase := 'output footer';
    output('<h4 align=center>*** End of Report - &lt;Employee Import Interface Report&gt; ***</h4>');
    output('</div>');
    output('</body>');
    output('</body>');
  
    -- Print Report API body end
    -- end activity, include debug message hint to exit api
    xxfnd_api.end_activity(p_pkg_name  => g_pkg_name,
                           p_api_name  => l_api_name,
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
  
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      log('Error when ' || l_phase || '. MSG:' || SQLERRM);
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_error,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      log('Error when ' || l_phase || '. MSG:' || SQLERRM);
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_unexp,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      log('Error when ' || l_phase || '. MSG:' || SQLERRM);
      x_return_status := xxfnd_api.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                     p_api_name       => l_api_name,
                                                     p_savepoint_name => l_savepoint_name,
                                                     p_exc_name       => xxfnd_api.g_exc_name_others,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);
    
  END print_import_report;

  PROCEDURE process_request(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_group_id      IN NUMBER,
                            p_retry_flag    IN VARCHAR2,
                            x_error_flag    OUT VARCHAR2) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_phase         VARCHAR2(240);
    l_record_status VARCHAR2(1);
    l_row_count     NUMBER;
    l_err_count     NUMBER;
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_error_flag    VARCHAR2(1);
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
    -- API body
  
    -- logging parameters
    IF l_debug = 'Y' THEN
      xxfnd_debug.log('p_group_id : ' || p_group_id);
      xxfnd_debug.log('p_retry_flag : ' || p_retry_flag);
    END IF;
  
    -- todo
    log('Process Begin.');
  
    --1.0 Prepare
    l_phase := '1.0 Prepare';
    log(l_phase);
    IF p_retry_flag = 'Y' THEN
      l_record_status := g_error;
    ELSE
      l_record_status := g_unprocess;
    END IF;
    g_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID'); --default 
    
    --Added by fandong.chen 20130131 begin
    --get set_of_books_id
    --set the context org_id to SHE_OU's org_id
    g_set_of_books_id      := get_set_of_books_id(g_org_id);
    g_default_code_comb_id := get_code_comb_id(g_default_expense_account,g_set_of_books_id);
    mo_global.set_policy_context('S',g_org_id);
    log('org_id: '||g_org_id);
    log('set_of_books_id: '||g_set_of_books_id);
    --Added by fandong.chen 20130131 end  
    --2.0 Validate Records
    l_phase := '2.0 Validate Records';
    log(l_phase);
    validate_record(p_init_msg_list => fnd_api.g_true,
                    p_commit        => fnd_api.g_true,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_group_id      => p_group_id,
                    p_record_status => l_record_status,
                    x_row_count     => l_row_count,
                    x_err_count     => l_err_count);
    IF l_err_count > 0 THEN
      x_error_flag := 'Y';
    END IF;
    log('Row processed: ' || to_char(l_row_count));
    log('Row error: ' || to_char(l_err_count));
    log(l_phase || ' end.');
  
    --3.0 Process Records
    l_phase := '3.0 Process Records';
    log(l_phase);
    process_record(p_init_msg_list => fnd_api.g_true,
                   p_commit        => fnd_api.g_true,
                   x_return_status => l_return_status,
                   x_msg_count     => l_msg_count,
                   x_msg_data      => l_msg_data,
                   p_group_id      => p_group_id,
                   x_error_flag    => l_error_flag);
    IF l_error_flag = 'Y' THEN
      x_error_flag := l_error_flag;
    END IF;
    log(l_phase || ' end.');
  
    --4.0 Print Report
    l_phase := '4.0 Print Report';
    log(l_phase);
    print_import_report(p_init_msg_list => fnd_api.g_true,
                        p_commit        => fnd_api.g_true,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_group_id      => p_group_id);
  
    log('Process End.');
  
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

  PROCEDURE main(errbuf       OUT VARCHAR2,
                 retcode      OUT VARCHAR2,
                 p_group_id   IN NUMBER,
                 p_retry_flag IN VARCHAR2) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_error_flag    VARCHAR2(1);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body
  
    -- convert parameter data type, such as varchar2 to date
    -- l_date := fnd_conc_date.string_to_date(p_parameter1);
    
    -- call process request api
    process_request(p_init_msg_list => fnd_api.g_true,
                    p_commit        => fnd_api.g_true,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_group_id      => p_group_id,
                    p_retry_flag    => p_retry_flag,
                    x_error_flag    => l_error_flag);
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  
    IF l_error_flag = 'Y' THEN
      retcode := '1';
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
                              p_procedure_name => 'MAIN',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END main;

END xxpjm_employee_mk_imp_pkg;
/
