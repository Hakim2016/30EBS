CREATE OR REPLACE PACKAGE xxpa_labor_hours_import_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPA_LABOR_HOURS_IMPORT_PKG
  Description:
      This program provide concurrent main procedure to perform:
      
  History:
      1.00  2012-4-17 19:48:43  senlin.gu  Creation
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

  TYPE labor_hours_int_rec IS RECORD(
    unique_id              NUMBER,
    group_id               NUMBER,
    org_name               VARCHAR2(30),
    mfg_no                 VARCHAR2(30),
    hours                  NUMBER,
    work_code              VARCHAR2(30),
    vo_defect              VARCHAR2(30),
    employee_name          VARCHAR2(240),
    department             VARCHAR2(50),
    section                VARCHAR2(30),
    resource_code          VARCHAR2(30),
    transaction_date       DATE,
    transfer_date          DATE,
    source_group_indentify VARCHAR2(30),
    source_type            VARCHAR2(30),
    source_system          VARCHAR2(30),
    source_line_identify   VARCHAR2(30),
    remark                 VARCHAR2(2000),
    source_doc_number      VARCHAR2(30),
    source_doc_line_num    VARCHAR2(10),
    process_status         VARCHAR2(1),
    process_date           DATE,
    process_message        VARCHAR2(2000),
    object_version_number  NUMBER,
    creation_date          DATE,
    created_by             NUMBER,
    last_updated_by        NUMBER,
    last_update_date       DATE,
    last_update_login      NUMBER,
    program_application_id NUMBER,
    program_id             NUMBER,
    program_update_date    DATE,
    request_id             NUMBER,
    attribute_category     VARCHAR2(30),
    attribute1             VARCHAR2(240),
    attribute2             VARCHAR2(240),
    attribute3             VARCHAR2(240),
    attribute4             VARCHAR2(240),
    attribute5             VARCHAR2(240),
    attribute6             VARCHAR2(240),
    attribute7             VARCHAR2(240),
    attribute8             VARCHAR2(240),
    attribute9             VARCHAR2(240),
    attribute10            VARCHAR2(240),
    attribute11            VARCHAR2(240),
    attribute12            VARCHAR2(240),
    attribute13            VARCHAR2(240),
    attribute14            VARCHAR2(240),
    attribute15            VARCHAR2(240));

  TYPE labor_hours_all_rec IS RECORD(
    process_type             VARCHAR2(50),
    hours_id                 NUMBER,
    group_id                 NUMBER,
    org_id                   NUMBER,
    mfg_no                   VARCHAR2(30),
    hours                    NUMBER,
    work_code                VARCHAR2(30),
    vo_defect                VARCHAR2(30),
    employee_name            VARCHAR2(240),
    employee_id              NUMBER,
    department               VARCHAR2(50),
    section                  VARCHAR2(30),
    group_dsp                VARCHAR2(30),
    department_id            NUMBER,
    resource_id              NUMBER,
    transaction_date         DATE,
    transfer_date            DATE,
    source_group_indentify   VARCHAR2(30),
    expenditure_type_id      VARCHAR2(30),
    project_id               NUMBER,
    task_id                  NUMBER,
    source_type              VARCHAR2(30),
    source_system            VARCHAR2(30),
    source_line_id           NUMBER,
    remark                   VARCHAR2(200),
    source_id_int_1          NUMBER,
    security_id_char_1       VARCHAR2(30),
    source_id_int_2          NUMBER,
    security_id_char_2       VARCHAR2(30),
    source_id_int_3          NUMBER,
    security_id_char_3       VARCHAR2(30),
    source_application_id    NUMBER,
    wbs_progress_flag        VARCHAR2(1),
    costed_flag              VARCHAR2(1),
    object_version_number    NUMBER := 1,
    creation_date            DATE := SYSDATE,
    created_by               NUMBER := -1,
    last_updated_by          NUMBER := -1,
    last_update_date         DATE := SYSDATE,
    last_update_login        NUMBER,
    program_application_id   NUMBER,
    program_id               NUMBER,
    program_update_date      DATE,
    request_id               NUMBER,
    attribute_category       VARCHAR2(30),
    attribute1               VARCHAR2(240),
    attribute2               VARCHAR2(240),
    attribute3               VARCHAR2(240),
    attribute4               VARCHAR2(240),
    attribute5               VARCHAR2(240),
    attribute6               VARCHAR2(240),
    attribute7               VARCHAR2(240),
    attribute8               VARCHAR2(240),
    attribute9               VARCHAR2(240),
    attribute10              VARCHAR2(240),
    attribute11              VARCHAR2(240),
    attribute12              VARCHAR2(240),
    attribute13              VARCHAR2(240),
    attribute14              VARCHAR2(240),
    attribute15              VARCHAR2(240),
    labor_rate               NUMBER,
    --labor_amount             NUMBER,
    related_expenditure_type VARCHAR2(30),
    related_labor_rate       NUMBER);

  PROCEDURE process_labor_hours(x_labor_hours_all_rec IN OUT labor_hours_all_rec,
                                x_return_status       OUT VARCHAR2,
                                x_error_message       OUT VARCHAR2);

  --main
  PROCEDURE installation_main(errbuf       OUT VARCHAR2,
                              retcode      OUT VARCHAR2,
                              p_group_id   IN NUMBER,
                              p_error_flag IN VARCHAR2
                              --p_source_system IN VARCHAR2 DEFAULT NULL
                              );

  PROCEDURE design_main(errbuf       OUT VARCHAR2,
                        retcode      OUT VARCHAR2,
                        p_group_id   IN NUMBER,
                        p_error_flag IN VARCHAR2
                        --p_source_system IN VARCHAR2 DEFAULT NULL
                        );

  PROCEDURE get_process_type(p_source_line_id IN NUMBER,
                             p_source_system  IN VARCHAR2,
                             x_process_type   OUT VARCHAR2,
                             x_return_status  OUT VARCHAR2,
                             x_error_message  OUT VARCHAR2);

  FUNCTION get_project_id(p_mfg_number    IN VARCHAR2,
                          x_error_message OUT VARCHAR2) RETURN NUMBER;

  FUNCTION get_task_id(p_mfg_number    IN VARCHAR2,
                       p_project_id    IN NUMBER,
                       p_source_system IN VARCHAR2,
                       x_error_message OUT VARCHAR2) RETURN NUMBER;

  PROCEDURE process_request(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_group_id      IN NUMBER,
                            p_error_flag    IN VARCHAR2,
                            p_source_system IN VARCHAR2 DEFAULT NULL);

  PROCEDURE create_labor_hours(p_labor_hours_int_rec IN labor_hours_int_rec,
                               p_commit              IN VARCHAR2 := fnd_api.g_false,
                               x_return_status       OUT NOCOPY VARCHAR2);

END xxpa_labor_hours_import_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxpa_labor_hours_import_pkg AS
  /*==================================================
  Copyright (C) Hand Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
      XXPA_LABOR_HOURS_IMPORT_PKG
  Description:
      This program provide concurrent main procedure to perform:

  History:
      1.00  2012-4-17 19:48:43  senlin.gu  Creation
      1.02  2012-9-25           senlin.gu  Update
            * add the field vo defect
      1.03  2012-10-19          senlin.gu  Update
            * modify the logic of catch sub task
      1.04  2012-11-09          senlin.gu  Update
            * add the logic of line id
      1.05  2013-01-15              senlin.gu  Update
            * add labor_rate,labor_amount,related_expenditure_type,
              related_labor_amount  logic feild
      2.00  2017-07-04              kangrong.xu    update
            * add exclude cancelled project in get project id
  ==================================================*/
  -- Global variable
  g_pkg_name CONSTANT VARCHAR2(30) := 'XXPA_LABOR_HOURS_IMPORT_PKG';
  -- Debug Enabled
  l_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');

  g_appl_name VARCHAR2(20) := 'XXPA';

  g_create_type VARCHAR2(20) := 'CREATE';
  g_update_type VARCHAR2(20) := 'UPDATE';

  --g_source_system            VARCHAR2(30);

  g_installation_system VARCHAR2(30) := 'EWH';
  g_design_system       VARCHAR2(30) := 'DHR';
  --g_installation_task_extend VARCHAR2(20) := 'ER';
  --g_design_task_extend       VARCHAR2(20) := 'EQ';
  g_eq_task_type     VARCHAR2(30) := 'EQ COST';
  g_er_task_type     VARCHAR2(30) := 'ER COST';
  g_cost_task_type   VARCHAR2(30) := 'COST';
  g_charge_task_type VARCHAR2(30) := 'Upgraded Task Type';

  g_process_error_status   VARCHAR2(1) := 'E';
  g_process_pending_status VARCHAR2(1) := 'P';

  g_conc_request_id NUMBER := fnd_global.conc_request_id;

  g_current_labor VARCHAR2(30);

  g_date_mask VARCHAR2(30) := 'DD-MON-YYYY HH24:MI:SS';

  g_loadplan_group VARCHAR2(30) := 'XXPM_LOADPLAN_GROUP';

  /*TYPE labor_hours_all_rec IS RECORD(
  HOURS_ID               Number,
  GROUP_ID               Number,
  ORG_ID                 Number,
  MFG_NO                 Varchar2(30),
  HOURS                  Number,
  DEPARTMENT_ID          Number,
  RESOURCE_ID            Number,
  TRANSACTION_DATE       Date,
  EXPENDITURE_TYPE_ID    Varchar2(30),
  PROJECT_ID             Number,
  TASK_ID                Number,
  SOURCE_TYPE            Varchar2(30),
  SOURCE_SYSTEM          Varchar2(30),
  SOURCE_ID_INT_1        Number,
  SECURITY_ID_CHAR_1     Varchar2(30),
  SOURCE_ID_INT_2        Number,
  SECURITY_ID_CHAR_2     Varchar2(30),
  SOURCE_ID_INT_3        Number,
  SECURITY_ID_CHAR_3     Varchar2(30),
  SOURCE_APPLICATION_ID  Number,
  WBS_PROGRESS_FLAG      Varchar2(1),
  COSTED_FLAG            Varchar2(1),
  OBJECT_VERSION_NUMBER  Number,
  CREATION_DATE          DATE := sysdate,
  CREATED_BY             NUMBER := -1,
  LAST_UPDATED_BY        NUMBER := -1,
  LAST_UPDATE_DATE       DATE := sysdate,
  LAST_UPDATE_LOGIN      NUMBER,
  PROGRAM_APPLICATION_ID NUMBER,
  PROGRAM_ID             NUMBER,
  PROGRAM_UPDATE_DATE    DATE,
  REQUEST_ID             NUMBER,
  ATTRIBUTE_CATEGORY     VARCHAR2(30),
  ATTRIBUTE1             VARCHAR2(240),
  ATTRIBUTE2             VARCHAR2(240),
  ATTRIBUTE3             VARCHAR2(240),
  ATTRIBUTE4             VARCHAR2(240),
  ATTRIBUTE5             VARCHAR2(240),
  ATTRIBUTE6             VARCHAR2(240),
  ATTRIBUTE7             VARCHAR2(240),
  ATTRIBUTE8             VARCHAR2(240),
  ATTRIBUTE9             VARCHAR2(240),
  ATTRIBUTE10            VARCHAR2(240),
  ATTRIBUTE11            VARCHAR2(240),
  ATTRIBUTE12            VARCHAR2(240),
  ATTRIBUTE13            VARCHAR2(240),
  ATTRIBUTE14            VARCHAR2(240),
  ATTRIBUTE15            VARCHAR2(240));*/

  --output
  PROCEDURE output(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_content);
  END output;

  --log
  PROCEDURE log(p_content IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_content);
    --DBMS_OUTPUT.put_line(p_content);
  END log;

  PROCEDURE print_design_output(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2) IS
    CURSOR cur_output IS
      SELECT int.*
        FROM (SELECT xdhi.* FROM xxpa_design_labor_int xdhi) INT
       WHERE int.request_id = g_conc_request_id
       ORDER BY int.unique_id;
    l_user_name VARCHAR2(40);
    l_status    VARCHAR2(10);
    l_api_name       CONSTANT VARCHAR2(30) := 'print_output';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    --l_phase         VARCHAR2(30);
    l_record_count NUMBER(4) := 0;
    --l_error_message VARCHAR2(2000);
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
    SELECT user_name
      INTO l_user_name
      FROM fnd_user
     WHERE user_id = g_created_by;
    output('<html>');
    output('<head>');
    output('<title>Interface Data Report</title>');
    output('</head>');
    output('<body>');
    output('<div>');
    output('<h2 align=center> ' || g_current_labor ||
           ' Labor Hours Import Report </h3>');
    output('<table border=0 >');
    output('<tr>');
    output('<td width=100 align=left>' || 'Print Date:' || '</td>' ||
           '<td>' || to_char(SYSDATE, g_date_mask) || '</td>');
    output('</tr>');
    output('<td width=100 align=left>' || 'Print By:' || '</td>' || '<td>' ||
           l_user_name || '</td>');
    output('</table>');

    output('<table cellpadding=1 cellspacing=0 border=1 bordercolorlight="#000000" bordercolordark="#FFFFFF">');
    output('<tr bgcolor="#999999">');
    output('<td width=100 align=left> Organization </td>');
    output('<td width=100 align=left> MFG number </td>');
    output('<td width=100 align=left> Hours </td>');
    output('<td width=150 align=left> Employee </td>');
    output('<td width=150 align=left> Department</td>');
    output('<td width=150 align=left> Section </td>');
    output('<td width=100 align=left> Group </td>');
    output('<td width=100 align=left> Transaction Date </td>');
    output('<td width=100 align=left> Vo Defect </td>');
    output('<td width=100 align=left> Transfer Date </td>');
    output('<td width=100 align=left> Group Indentify </td>');
    output('<td width=100 align=left> Source System </td>');
    output('<td width=100 align=left> Line Identify</td>');
    output('<td width=60  align=left> Status </td>');
    output('<td width=200 align=left> Message </td>');
    output('</tr>');
    FOR rec_output IN cur_output LOOP
      IF rec_output.process_status = 'E' THEN
        l_status := 'Error';
      ELSIF rec_output.process_status = 'S' THEN
        l_status := 'Success';
      ELSIF rec_output.process_status = 'P' THEN
        l_status := 'Pending';
      ELSIF rec_output.process_status = 'R' THEN
        l_status := 'Processing';
      END IF;

      output('<tr>');
      output('<td width=60 align=left>' || rec_output.org_name || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.mfg_no || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.hours || '&nbsp;' ||
             '</td>');
      output('<td width=150 align=left>' || '&nbsp;' ||
             rec_output.employee_name || '</td>');
      output('<td width=150 align=left>' || rec_output.department ||
             '&nbsp;' || '</td>');
      output('<td width=150 align=left>' || rec_output.section || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.resource_code ||
             '&nbsp;' || '</td>');
      output('<td width=100 align=left>' ||
             to_char(rec_output.transaction_date, g_date_mask) || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.vo_defect ||
             '&nbsp;' || '</td>');
      output('<td width=100 align=left>' ||
             to_char(rec_output.transfer_date, g_date_mask) || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' ||
             rec_output.source_group_indentify || '&nbsp;' || '</td>');
      /*output('<td width=100 align=left>' ||
      to_char(rec_output.effective_date,'DD-MON-YYYY HH24:MI:SS') ||
      '&nbsp;' || '</td>');*/
      output('<td width=100 align=left>' || rec_output.source_system ||
             '</td>');
      output('<td width=100 align=left>' ||
             rec_output.source_line_identify || '&nbsp;' || '</td>');
      output('<td width=60 align=left>' || l_status || '&nbsp;' || '</td>');
      output('<td width=200 align=left>' || rec_output.process_message ||
             '&nbsp;' || '</td>');
      output('</tr>');
      l_record_count := l_record_count + 1;
    END LOOP;
    IF l_record_count = 0 THEN
      output('<tr>');
      output('<td align=center colspan=14> **NO ERROR RECORD** </td>');
      output('</tr>');
    END IF;
    output('</table>');
    output('</div>');
    output('</body>');
    output('</html>');
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
  END print_design_output;

  PROCEDURE print_installation_output(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER,
                                      x_msg_data      OUT NOCOPY VARCHAR2) IS
    CURSOR cur_output IS
      SELECT int.*
        FROM (SELECT xihi.* FROM xxpa_install_labor_int xihi) INT
       WHERE int.request_id = g_conc_request_id
       ORDER BY int.unique_id;
    l_user_name VARCHAR2(40);
    l_status    VARCHAR2(10);
    l_api_name       CONSTANT VARCHAR2(30) := 'print_output';
    l_savepoint_name CONSTANT VARCHAR2(30) := '';
    --l_phase         VARCHAR2(30);
    l_record_count  NUMBER(4) := 0;
    l_error_message VARCHAR2(2000);
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
    SELECT user_name
      INTO l_user_name
      FROM fnd_user
     WHERE user_id = g_created_by;
    output('<html>');
    output('<head>');
    output('<title>Interface Data Report</title>');
    output('</head>');
    output('<body>');
    output('<div>');
    output('<h2 align=center> ' || g_current_labor ||
           ' Labor Hours Import Report </h3>');
    output('<table border=0 >');
    output('<tr>');
    output('<td width=100 align=left>' || 'Print Date:' || '</td>' ||
           '<td>' || to_char(SYSDATE, g_date_mask) || '</td>');
    output('</tr>');
    output('<td width=100 align=left>' || 'Print By:' || '</td>' || '<td>' ||
           l_user_name || '</td>');
    output('</table>');

    output('<table cellpadding=1 cellspacing=0 border=1 bordercolorlight="#000000" bordercolordark="#FFFFFF">');
    output('<tr bgcolor="#999999">');
    output('<td width=100 align=left> Organization </td>');
    output('<td width=100 align=left> MFG number </td>');
    output('<td width=100 align=left> Hours </td>');
    output('<td width=150 align=left> Employee </td>');
    output('<td width=100 align=left> Department</td>');
    output('<td width=100 align=left> Section </td>');
    output('<td width=100 align=left> Group </td>');
    output('<td width=100 align=left> Transaction Date </td>');
    output('<td width=100 align=left> Work Code </td>');
    output('<td width=100 align=left> Vo Defect </td>');
    output('<td width=100 align=left> Transfer Date </td>');
    output('<td width=100 align=left> Group Indentify </td>');
    output('<td width=100 align=left> Source System </td>');
    output('<td width=100 align=left> Line Identify</td>');
    output('<td width=100 align=left> Remark</td>');
    output('<td width=60  align=left> Status </td>');
    output('<td width=200 align=left> Message </td>');
    output('</tr>');
    FOR rec_output IN cur_output LOOP
      IF rec_output.process_status = 'E' THEN
        l_status := 'Error';
      ELSIF rec_output.process_status = 'S' THEN
        l_status := 'Success';
      ELSIF rec_output.process_status = 'P' THEN
        l_status := 'Pending';
      ELSIF rec_output.process_status = 'R' THEN
        l_status := 'Processing';
      END IF;

      output('<tr>');
      output('<td width=60 align=left>' || rec_output.org_name || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.mfg_no || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.hours || '&nbsp;' ||
             '</td>');
      output('<td width=150 align=left>' || '&nbsp;' ||
             rec_output.employee_name || '</td>');
      output('<td width=100 align=left>' || rec_output.department ||
             '&nbsp;' || '</td>');
      output('<td width=100 align=left>' || rec_output.section || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.resource_code ||
             '&nbsp;' || '</td>');
      output('<td width=100 align=left>' ||
             to_char(rec_output.transaction_date, g_date_mask) || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' || rec_output.work_code ||
             '&nbsp;' || '</td>');
      output('<td width=100 align=left>' || rec_output.vo_defect ||
             '&nbsp;' || '</td>');
      output('<td width=100 align=left>' ||
             to_char(rec_output.transfer_date, g_date_mask) || '&nbsp;' ||
             '</td>');
      output('<td width=100 align=left>' ||
             rec_output.source_group_indentify || '&nbsp;' || '</td>');
      /*output('<td width=100 align=left>' ||
      to_char(rec_output.effective_date,'DD-MON-YYYY HH24:MI:SS') ||
      '&nbsp;' || '</td>');*/
      output('<td width=100 align=left>' || rec_output.source_system ||
             '</td>');
      output('<td width=100 align=left>' ||
             rec_output.source_line_identify || '&nbsp;' || '</td>');
      output('<td width=100 align=left>' || rec_output.remark || '</td>');
      output('<td width=60 align=left>' || l_status || '&nbsp;' || '</td>');
      output('<td width=200 align=left>' || rec_output.process_message ||
             '&nbsp;' || '</td>');
      output('</tr>');
      l_record_count := l_record_count + 1;
    END LOOP;
    IF l_record_count = 0 THEN
      output('<tr>');
      output('<td align=center colspan=14> **NO ERROR RECORD** </td>');
      output('</tr>');
    END IF;
    output('</table>');
    output('</div>');
    output('</body>');
    output('</html>');
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
  END print_installation_output;

  FUNCTION number_formate(p_value NUMBER) RETURN NUMBER IS
    l_number_formate NUMBER;
  BEGIN

    IF p_value IS NULL THEN
      l_number_formate := NULL;
    ELSE
      l_number_formate := p_value;
    END IF;

    RETURN l_number_formate;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

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

  PROCEDURE init_labor_hours_int(p_labor_hours_int_rec IN OUT labor_hours_int_rec) IS
  BEGIN
    p_labor_hours_int_rec.unique_id           := NULL;
    p_labor_hours_int_rec.org_name            := NULL;
    p_labor_hours_int_rec.mfg_no              := NULL;
    p_labor_hours_int_rec.department          := NULL;
    p_labor_hours_int_rec.section             := NULL;
    p_labor_hours_int_rec.resource_code       := NULL;
    p_labor_hours_int_rec.transaction_date    := NULL;
    p_labor_hours_int_rec.source_type         := NULL;
    p_labor_hours_int_rec.source_system       := NULL;
    p_labor_hours_int_rec.source_doc_line_num := NULL;
  END;

  PROCEDURE write_process_result(p_labor_hours_int_rec IN labor_hours_int_rec,
                                 p_process_type        IN VARCHAR2 DEFAULT NULL,
                                 p_return_status       IN VARCHAR2,
                                 p_error_message       IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    IF g_current_labor = g_design_system THEN
      UPDATE xxpa_design_labor_int

         SET process_status  = p_return_status
            ,process_date    = SYSDATE
            ,process_message = nvl(p_error_message, p_process_type)
            ,request_id      = g_conc_request_id

       WHERE unique_id = p_labor_hours_int_rec.unique_id;

    ELSIF g_current_labor = g_installation_system THEN

      UPDATE xxpa_install_labor_int

         SET process_status  = p_return_status
            ,process_date    = SYSDATE
            ,process_message = nvl(p_error_message, p_process_type)
            ,request_id      = g_conc_request_id

       WHERE unique_id = p_labor_hours_int_rec.unique_id;

    END IF;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      log('procedure ' || g_pkg_name || '.write_process_result ' ||
          'WHEN OTHERS THEN ' || SQLERRM);

  END;

  /*============================================================

      Function Name:
          get_process_type
      Description:
          This function is to decidce the program create or update

      History:
          1.00  2012-11-09 19:48:43  senlin.gu  Creation
  =============================================================*/
  PROCEDURE get_process_type(p_source_line_id IN NUMBER,
                             p_source_system  IN VARCHAR2,
                             x_process_type   OUT VARCHAR2,
                             x_return_status  OUT VARCHAR2,
                             x_error_message  OUT VARCHAR2) IS
    l_statement_num VARCHAR2(30);
    CURSOR cur_duplicate_lb(p_line_id NUMBER) IS
      SELECT COUNT(1)
        FROM xxpa.xxpa_labor_hours_all
       WHERE source_line_id = p_line_id
         AND source_system = p_source_system
         AND org_id = fnd_profile.value('XXPJM_HEA_ORG_ID');
    l_duplicate NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_statement_num := '10';
    IF p_source_line_id IS NULL THEN
      x_process_type := g_create_type;
      RETURN;
    END IF;
    l_statement_num := '20';

    OPEN cur_duplicate_lb(p_source_line_id);
    FETCH cur_duplicate_lb
      INTO l_duplicate;
    CLOSE cur_duplicate_lb;

    IF l_duplicate > 1 THEN
      x_error_message := 'There is more than one record line id(' ||
                         p_source_line_id || ') in system(' ||
                         p_source_system || ').';
      x_return_status := fnd_api.g_ret_sts_error;
    ELSIF l_duplicate = 1 THEN
      x_process_type := g_update_type;
    ELSE
      x_process_type := g_create_type;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      log('   procedure ' || g_pkg_name || '.get_process_type ' ||
          'WHEN OTHERS THEN ' || SQLERRM || l_statement_num);
      x_process_type := g_create_type;
  END;

  FUNCTION get_project_id(p_mfg_number    IN VARCHAR2,
                          x_error_message OUT VARCHAR2) RETURN NUMBER IS
    l_statement_num VARCHAR2(30);
    l_project_id    NUMBER := -1;
    l_project_count NUMBER := -1;
  BEGIN
    l_statement_num := '10';

    SELECT COUNT(1)
      INTO l_project_count
      FROM pa_tasks pt, pa_projects_all pa
     WHERE pt.top_task_id = pt.task_id
       AND pt.project_id = pa.project_id
       AND pa.org_id = fnd_profile.value('XXPJM_HEA_ORG_ID')
       --v2.00 add by kangrong.xu at 2017-07-04 begin
       AND pa.project_status_code <> '1010'
       --v2.00 add by kangrong.xu at 2017-07-04 end
       AND pt.task_number = p_mfg_number;

    IF l_project_count > 1 THEN
      x_error_message := get_message(g_appl_name,
                                     'XXPA_003E_001',
                                     'MFG_NUMBER',
                                     p_mfg_number);
      RETURN l_project_id;
    END IF;

    l_statement_num := '20';
    SELECT pa.project_id
      INTO l_project_id
      FROM pa_tasks pt, pa_projects_all pa
     WHERE pt.top_task_id = pt.task_id
       AND pt.project_id = pa.project_id
       AND pa.org_id = fnd_profile.value('XXPJM_HEA_ORG_ID')
       --v2.00 add by kangrong.xu at 2017-07-04 begin
       AND pa.project_status_code <> '1010'
       --v2.00 add by kangrong.xu at 2017-07-04 end
       AND pt.task_number = p_mfg_number;

    RETURN l_project_id;

  EXCEPTION
    WHEN no_data_found THEN
      --x_error_message := 'This mfg number has no project.';
      x_error_message := get_message(g_appl_name,
                                     'XXPA_003E_002',
                                     'MFG_NUMBER',
                                     p_mfg_number);
      RETURN l_project_id;
    WHEN OTHERS THEN
      log('   procedure ' || g_pkg_name || '.get_project_id ' ||
          'WHEN OTHERS THEN ' || SQLERRM || l_statement_num);
      RETURN l_project_id;
  END;

  ---------------------------------------------------------------------------------------
  --
  --
  --
  --Description: 2. When this interface is from intsallation system,
  --                then the task number is the MFG ER cost task;or eles it's EQ cost task;
  --             3. then the task is MFG.ER task or MFG.EQ task;
  ------------------------------------------------------------------------------------------
  FUNCTION get_task_id(p_mfg_number    IN VARCHAR2,
                       p_project_id    IN NUMBER,
                       p_source_system IN VARCHAR2,
                       x_error_message OUT VARCHAR2) RETURN NUMBER IS

    l_statement_num VARCHAR2(30);
    l_task_id       NUMBER := -1;
    l_cost_task     VARCHAR2(30);
    l_task_type     VARCHAR2(30);
  BEGIN
    --10.get cost task by mfg number and project
    l_statement_num := '10';
    IF p_source_system = g_installation_system THEN
      --l_cost_task := p_mfg_number || '%' || g_installation_task_extend;
      l_task_type := g_er_task_type;
    ELSIF p_source_system = g_design_system THEN
      --l_cost_task := p_mfg_number || '%' || g_design_task_extend;
      l_task_type := g_eq_task_type;
    END IF;
    log('   l_task_type=>' || l_task_type);

    --20.get task_id by cost task and project
    l_statement_num := '20';
    /*SELECT task_id
     INTO l_task_id
     FROM pa_tasks
    WHERE project_id = p_project_id
      AND task_number LIKE l_cost_task;*/
    SELECT pa.task_id
      INTO l_task_id
      FROM pa_tasks         pa
          ,pa_proj_elements ppe
          ,pa_task_types    t
          ,pa_tasks         top_task
     WHERE pa.task_id = ppe.proj_element_id
       AND ppe.type_id = t.task_type_id
       AND top_task.task_id = pa.top_task_id
       AND ppe.object_type = 'PA_TASKS'
       AND t.task_type = l_task_type
       AND ppe.project_id = p_project_id
       AND top_task.task_number = p_mfg_number;

    RETURN l_task_id;

  EXCEPTION
    WHEN too_many_rows THEN
      x_error_message := 'The combination mfg number and project has one more task.';
      RETURN l_task_id;
    WHEN no_data_found THEN
      BEGIN
        log('EQ ER Task Number Not Find ,Find Cost Task.');
        SELECT pa.task_id
          INTO l_task_id
          FROM pa_tasks         pa
              ,pa_proj_elements ppe
              ,pa_task_types    t
              ,pa_tasks         top_task
         WHERE pa.task_id = ppe.proj_element_id
           AND ppe.type_id = t.task_type_id
           AND top_task.task_id = pa.top_task_id
           AND ppe.object_type = 'PA_TASKS'
           AND t.task_type IN
               (g_cost_task_type, g_eq_task_type, g_charge_task_type)
           AND ppe.project_id = p_project_id
           AND top_task.task_number = p_mfg_number
         ORDER BY t.task_type ASC;
        RETURN l_task_id;
      EXCEPTION
        WHEN too_many_rows THEN
          x_error_message := 'The combination mfg number and project has one more task.';
          RETURN l_task_id;
        WHEN no_data_found THEN
          x_error_message := 'The combination mfg number and project has no task.';
          x_error_message := get_message(g_appl_name,
                                         'XXPA_003E_003',
                                         'MFG_NUMBER',
                                         p_mfg_number,
                                         'PROJECT',
                                         p_project_id);
          RETURN l_task_id;
        WHEN OTHERS THEN
          log('   procedure ' || g_pkg_name || '.get_task_id ' ||
              'WHEN OTHERS THEN ' || SQLERRM || l_statement_num);
          RETURN l_task_id;
      END;
    WHEN OTHERS THEN
      log('   procedure ' || g_pkg_name || '.get_task_id ' ||
          'WHEN OTHERS THEN ' || SQLERRM || l_statement_num);
      RETURN l_task_id;
  END;

  PROCEDURE get_porject_and_task(p_labor_hours_int_rec IN labor_hours_int_rec,
                                 x_labor_hours_all_rec IN OUT labor_hours_all_rec,
                                 x_return_status       OUT VARCHAR2,
                                 x_error_message       OUT VARCHAR2) IS
    l_statement_num VARCHAR2(30);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    l_statement_num                  := '10';
    x_labor_hours_all_rec.project_id := get_project_id(p_labor_hours_int_rec.mfg_no,
                                                       x_error_message);
    log('   ' || l_statement_num || '.get project.  project_id=' ||
        x_labor_hours_all_rec.project_id);

    IF x_labor_hours_all_rec.project_id = -1 THEN
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    l_statement_num               := '20';
    x_labor_hours_all_rec.task_id := get_task_id(p_labor_hours_int_rec.mfg_no,
                                                 x_labor_hours_all_rec.project_id,
                                                 p_labor_hours_int_rec.source_system,
                                                 x_error_message);

    log('   ' || l_statement_num || '.get task.  task_id=' ||
        x_labor_hours_all_rec.task_id);

    IF x_labor_hours_all_rec.task_id = -1 THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      log('   procedure ' || g_pkg_name || '.get_porject_and_task ' ||
          'WHEN OTHERS THEN ' || SQLERRM || ' statement: ' ||
          l_statement_num);
  END;

  PROCEDURE validate_transfer_fin(p_source_line_id IN NUMBER,
                                  p_source_system  IN VARCHAR2,
                                  x_return_status  OUT VARCHAR2,
                                  x_error_message  OUT VARCHAR2) IS
    CURSOR cur_cost_flag IS
      SELECT costed_flag
        FROM xxpa.xxpa_labor_hours_all
       WHERE source_line_id = p_source_line_id
         AND source_system = p_source_system
         AND org_id = fnd_profile.value('XXPJM_HEA_ORG_ID');
    l_cost_flag VARCHAR2(30);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    OPEN cur_cost_flag;
    FETCH cur_cost_flag
      INTO l_cost_flag;
    CLOSE cur_cost_flag;
    IF l_cost_flag = 'S' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := 'The labor hour record (line id)(' ||
                         p_source_line_id || ')(source system)(' ||
                         p_source_system || ') has transfered into FIN.';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_error_message := SQLERRM;
      x_return_status := fnd_api.g_ret_sts_error;
  END;

  PROCEDURE validate_line_indentify(p_source_line_indentify IN VARCHAR2,
                                    x_source_line_id        OUT NUMBER,
                                    x_return_status         OUT VARCHAR2,
                                    x_error_message         OUT VARCHAR2) IS

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    x_source_line_id := to_number(p_source_line_indentify);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_message := 'Field Line Indentify must be a number.';
      x_return_status := fnd_api.g_ret_sts_error;
  END;

  PROCEDURE validate_org_name(p_org_name      IN VARCHAR2,
                              x_org_id        OUT NUMBER,
                              x_return_status OUT VARCHAR2,
                              x_error_message OUT VARCHAR2) IS

    CURSOR org_cur(p_org_name_c IN VARCHAR2) IS
      SELECT organization_id org_id
        FROM hr_operating_units
       WHERE upper(NAME) = upper(p_org_name_c);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_org_name IS NULL THEN
      --x_error_message := 'Field org name must not be null.';
      x_error_message := get_message(g_appl_name, 'XXPA_003E_004');

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    OPEN org_cur(p_org_name);
    FETCH org_cur
      INTO x_org_id;
    CLOSE org_cur;

    IF x_org_id IS NULL THEN
      --x_error_message := 'The org name is not in system.';
      x_error_message := get_message(g_appl_name,
                                     'XXPA_003E_005',
                                     'ORG_NAME',
                                     p_org_name);
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  END;

  PROCEDURE validate_mfg_number(p_mfg_no        IN VARCHAR2,
                                x_mfg_no        OUT VARCHAR2,
                                x_return_status OUT VARCHAR2,
                                x_error_message OUT VARCHAR2) IS

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_mfg_no IS NULL THEN
      x_error_message := get_message(g_appl_name, 'XXPA_003E_006');
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    /*SELECT mfg_number
     INTO x_mfg_no
     FROM xxpjm_mfg_numbers_v
    WHERE mfg_number = p_mfg_no;*/
    x_mfg_no := p_mfg_no;

  EXCEPTION
    WHEN OTHERS THEN
      x_error_message := 'There is no mfg number in system.';
      x_return_status := fnd_api.g_ret_sts_error;

  END;

  PROCEDURE validate_source_system(p_source_system IN VARCHAR2,
                                   x_source_system OUT VARCHAR2,
                                   x_return_status OUT VARCHAR2,
                                   x_error_message OUT VARCHAR2) IS

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_source_system IS NULL THEN
      --x_error_message := 'The field source system must not be null.';
      x_error_message := get_message(g_appl_name, 'XXPA_003E_007');
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    x_source_system := p_source_system;

  END;

  PROCEDURE validate_transfer_date(p_transfer_date IN VARCHAR2,
                                   x_return_status OUT VARCHAR2,
                                   x_error_message OUT VARCHAR2) IS
    l_transfer_date DATE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    l_transfer_date := to_date(p_transfer_date, 'DD-MM-YYYY');

  EXCEPTION
    WHEN OTHERS THEN

      x_error_message := 'The formate transfer date is invalid,must be as DD-MM-YYYY.';
      --x_error_message := get_message(g_appl_name, 'XXPA_003E_008');
      x_return_status := fnd_api.g_ret_sts_error;

  END;

  PROCEDURE validate_hours(p_hours         IN VARCHAR2,
                           x_hours         OUT VARCHAR2,
                           x_return_status OUT VARCHAR2,
                           x_error_message OUT VARCHAR2) IS

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_hours IS NULL THEN
      --x_error_message := 'The field  hours must not be null.';
      x_error_message := get_message(g_appl_name, 'XXPA_003E_008');
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;
    x_hours :=  /*number_formate(*/
     p_hours /*)*/
      ;
  END;

  PROCEDURE validate_department(p_department    IN VARCHAR2,
                                p_section       IN VARCHAR2,
                                p_org_id        IN NUMBER,
                                x_department_id OUT NUMBER,
                                x_return_status OUT VARCHAR2,
                                x_error_message OUT VARCHAR2) IS

    CURSOR department_cur(p_department_c IN VARCHAR2,
                          p_section_c    IN VARCHAR2,
                          p_org_id_c     IN NUMBER) IS

      SELECT department_id
        FROM bom_departments bd
       WHERE bd.attribute1 = p_department_c
         AND bd.department_code = p_section_c
         AND bd.organization_id = p_org_id_c;
    /*AND bd.organization_id IN
    (SELECT organization_id, operating_unit
       FROM org_organization_definitions
      WHERE operating_unit = p_org_id)*/

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_department IS NULL THEN
      --x_error_message := 'The department must not be null.';
      x_error_message := get_message(g_appl_name, 'XXPA_003E_009');
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_section IS NULL THEN
      --x_error_message := 'The section must not be null.';
      x_error_message := get_message(g_appl_name, 'XXPA_003E_010');
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    OPEN department_cur(p_department, p_section, p_org_id);
    FETCH department_cur
      INTO x_department_id;
    CLOSE department_cur;

    IF x_department_id IS NULL THEN
      --x_error_message := 'The combination of section and department is not in system.';
      x_error_message := get_message(g_appl_name,
                                     'XXPA_003E_011',
                                     'SECTION',
                                     p_section,
                                     'DEPARTMENT',
                                     p_department);
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  END;

  PROCEDURE validate_resource_code(p_resource_code            IN VARCHAR2,
                                   p_org_id                   IN NUMBER,
                                   p_hours                    IN NUMBER,
                                   x_resource_id              OUT NUMBER,
                                   x_group_dsp                OUT VARCHAR2,
                                   x_expenditure_type_id      OUT VARCHAR2,
                                   x_labor_rate               OUT NUMBER,
                                   x_related_expenditure_type OUT VARCHAR2,
                                   x_related_labor_rate       OUT NUMBER,
                                   x_return_status            OUT VARCHAR2,
                                   x_error_message            OUT VARCHAR2) IS
    l_statement_num VARCHAR2(30);

    l_resource_ddf VARCHAR2(30);

    CURSOR cur_resource_ddf(p_resource_code IN VARCHAR2) IS
      SELECT fvv.flex_value sales_type_name
        FROM fnd_flex_values_vl fvv
       WHERE fvv.flex_value_set_id =
             (SELECT fvs.flex_value_set_id
                FROM fnd_flex_value_sets fvs
               WHERE fvs.flex_value_set_name = g_loadplan_group)
         AND fvv.enabled_flag = 'Y'
         AND trunc(SYSDATE) >= nvl(fvv.start_date_active, trunc(SYSDATE))
         AND trunc(SYSDATE) <= nvl(fvv.end_date_active, trunc(SYSDATE))
         AND fvv.flex_value = p_resource_code;

    CURSOR resource_cur(p_resource_code_c IN VARCHAR2,
                        p_org_id_c        IN NUMBER) IS
      SELECT br.resource_id, pet.expenditure_type
        FROM bom_resources br, pa_expenditure_types pet
       WHERE br.attribute1 = p_resource_code_c
         AND br.attribute2 = pet.expenditure_type_id
         AND br.organization_id IN
             (SELECT organization_id
                FROM org_organization_definitions
               WHERE operating_unit = p_org_id);

    CURSOR cur_labor_rate(p_expenditure_type IN VARCHAR2,
                          p_hours            IN NUMBER) IS
      SELECT cost_rate
        FROM (SELECT pet.expenditure_type_id
                    ,pet.expenditure_type
                    ,decode(pet.attribute11,
                            NULL,
                            pet.attribute12,
                            pet.attribute13) cost_rate
                FROM pa_expenditure_types pet)
       WHERE expenditure_type = p_expenditure_type;

    CURSOR cur_other_expenditure(p_expenditure_type IN VARCHAR2) IS
      SELECT oth_pecr.expenditure_type related_expenditure_type
            ,oth_pecr.attribute12      related_labor_rate
        FROM pa_expenditure_types oth_pecr
       WHERE oth_pecr.attribute11 = p_expenditure_type;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    l_statement_num := '10';
    IF p_resource_code IS NULL THEN
      --x_error_message := 'The field resource code must not be null.';
      x_error_message := get_message(g_appl_name, 'XXPA_003E_012');
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    l_statement_num := '15';
    OPEN cur_resource_ddf(p_resource_code);
    FETCH cur_resource_ddf
      INTO l_resource_ddf;
    CLOSE cur_resource_ddf;

    IF l_resource_ddf IS NULL THEN
      x_error_message := 'There is no loadplan goup in value set.';
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    l_statement_num := '20';
    OPEN resource_cur(p_resource_code, p_org_id);
    FETCH resource_cur
      INTO x_resource_id, x_expenditure_type_id;
    CLOSE resource_cur;

    IF x_resource_id IS NULL THEN
      --x_error_message := 'The combination of department and resource_code does not exist in system.';
      x_error_message := get_message(g_appl_name,
                                     'XXPA_003E_013',
                                     'RESOURDCE_CODE',
                                     p_resource_code);
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    OPEN cur_labor_rate(x_expenditure_type_id, p_hours);
    FETCH cur_labor_rate
      INTO x_labor_rate;
    CLOSE cur_labor_rate;

    OPEN cur_other_expenditure(x_expenditure_type_id);
    FETCH cur_other_expenditure
      INTO x_related_expenditure_type, x_related_labor_rate;
    CLOSE cur_other_expenditure;

    x_group_dsp := p_resource_code;

  END;

  PROCEDURE validate_labor_hours(p_labor_hours_int_rec IN labor_hours_int_rec,
                                 x_labor_hours_all_rec IN OUT labor_hours_all_rec,
                                 x_return_status       OUT VARCHAR2,
                                 x_error_message       OUT VARCHAR2) IS

    l_statement_num VARCHAR2(30);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    l_statement_num := '10';
    log(l_statement_num || '.validate org name.');
    validate_org_name(p_org_name      => p_labor_hours_int_rec.org_name,
                      x_org_id        => x_labor_hours_all_rec.org_id,
                      x_return_status => x_return_status,
                      x_error_message => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '20';
    log(l_statement_num || '.validate mfg number.');
    validate_mfg_number(p_mfg_no        => p_labor_hours_int_rec.mfg_no,
                        x_mfg_no        => x_labor_hours_all_rec.mfg_no,
                        x_return_status => x_return_status,
                        x_error_message => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '30';
    log(l_statement_num || '.validate source system.');
    validate_source_system(p_source_system => p_labor_hours_int_rec.source_system,
                           x_source_system => x_labor_hours_all_rec.source_system,
                           x_return_status => x_return_status,
                           x_error_message => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '35';
    log(l_statement_num || '.validate line identify.');
    validate_line_indentify(p_source_line_indentify => p_labor_hours_int_rec.source_line_identify,
                            x_source_line_id        => x_labor_hours_all_rec.source_line_id,
                            x_return_status         => x_return_status,
                            x_error_message         => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '40';
    log(l_statement_num || '.validate hours.');
    validate_hours(p_hours         => p_labor_hours_int_rec.hours,
                   x_hours         => x_labor_hours_all_rec.hours,
                   x_return_status => x_return_status,
                   x_error_message => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '45';
    log(l_statement_num || '.validate transfer date.');
    validate_transfer_date(p_transfer_date => p_labor_hours_int_rec.attribute2,
                           x_return_status => x_return_status,
                           x_error_message => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    /*l_statement_num := '50';
    log(l_statement_num || '.validate department.');
    validate_department(p_department    => p_labor_hours_int_rec.department,
                        p_section       => p_labor_hours_int_rec.section,
                        p_org_id        => x_labor_hours_all_rec.org_id,
                        x_department_id => x_labor_hours_all_rec.department_id,
                        x_return_status => x_return_status,
                        x_error_message => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;*/

    l_statement_num := '60';
    log(l_statement_num || '.validate resource code.');
    validate_resource_code(p_resource_code            => p_labor_hours_int_rec.resource_code,
                           p_org_id                   => x_labor_hours_all_rec.org_id,
                           p_hours                    => x_labor_hours_all_rec.hours,
                           x_resource_id              => x_labor_hours_all_rec.resource_id,
                           x_group_dsp                => x_labor_hours_all_rec.group_dsp,
                           x_expenditure_type_id      => x_labor_hours_all_rec.expenditure_type_id,
                           x_labor_rate               => x_labor_hours_all_rec.labor_rate,
                           x_related_expenditure_type => x_labor_hours_all_rec.related_expenditure_type,
                           x_related_labor_rate       => x_labor_hours_all_rec.related_labor_rate,
                           x_return_status            => x_return_status,
                           x_error_message            => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '65';
    log(l_statement_num || '.get process type.');
    get_process_type(p_source_line_id => x_labor_hours_all_rec.source_line_id,
                     p_source_system  => p_labor_hours_int_rec.source_system,
                     x_process_type   => x_labor_hours_all_rec.process_type,
                     x_return_status  => x_return_status,
                     x_error_message  => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '70';
    log(l_statement_num || '.validate the record has transfered into FIN.');
    validate_transfer_fin(p_source_line_id => x_labor_hours_all_rec.source_line_id,
                          p_source_system  => p_labor_hours_int_rec.source_system,
                          x_return_status  => x_return_status,
                          x_error_message  => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '75';
    log(l_statement_num || '.Get project and task.');
    get_porject_and_task(p_labor_hours_int_rec => p_labor_hours_int_rec,
                         x_labor_hours_all_rec => x_labor_hours_all_rec,
                         x_return_status       => x_return_status,
                         x_error_message       => x_error_message);
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_statement_num := '80';
    log(l_statement_num || '.init data.');
    x_labor_hours_all_rec.transaction_date       := p_labor_hours_int_rec.transaction_date;
    x_labor_hours_all_rec.group_id               := p_labor_hours_int_rec.group_id;
    x_labor_hours_all_rec.department             := p_labor_hours_int_rec.department;
    x_labor_hours_all_rec.work_code              := p_labor_hours_int_rec.work_code;
    x_labor_hours_all_rec.vo_defect              := p_labor_hours_int_rec.vo_defect;
    x_labor_hours_all_rec.section                := p_labor_hours_int_rec.section;
    x_labor_hours_all_rec.employee_name          := p_labor_hours_int_rec.employee_name;
    x_labor_hours_all_rec.transfer_date          := p_labor_hours_int_rec.transfer_date;
    x_labor_hours_all_rec.source_group_indentify := p_labor_hours_int_rec.source_group_indentify;
    x_labor_hours_all_rec.remark                 := p_labor_hours_int_rec.remark;
    x_labor_hours_all_rec.request_id             := g_conc_request_id;

  EXCEPTION
    WHEN OTHERS THEN
      log('procedure ' || g_pkg_name || '.validate_labor_hours ' ||
          'WHEN OTHERS THEN ' || SQLERRM || l_statement_num);

  END;

  PROCEDURE backup_labor_hours_his(p_hours_id IN NUMBER) IS
    l_his_id NUMBER;
  BEGIN
    SELECT xxpa_labor_hours_his_s.nextval INTO l_his_id FROM dual;
    log('[Procedure][backup_labor_hours_his][history id]: ' || l_his_id);
    INSERT INTO xxpa_labor_hours_his_all
      (history_id
      ,hours_id
      ,group_id
      ,org_id
      ,mfg_no
      ,hours
      ,employee_name
      ,employee_id
      ,department
      ,section
      ,group_dsp
      ,department_id
      ,resource_id
      ,transaction_date
      ,work_code
      ,vo_defect
      ,transfer_date
      ,source_group_indentify
      ,expenditure_type
      ,project_id
      ,task_id
      ,source_type
      ,source_system
      ,source_line_id
      ,remark
      ,source_id_int_1
      ,security_id_char_1
      ,source_id_int_2
      ,security_id_char_2
      ,source_id_int_3
      ,security_id_char_3
      ,source_application_id
      ,wbs_progress_flag
      ,costed_flag
      ,costed_error_message
      ,object_version_number
      ,creation_date
      ,created_by
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,request_id
      ,labor_rate
      ,related_expenditure_type
      ,related_labor_rate)
      (SELECT l_his_id
             ,xlha.hours_id
             ,xlha.group_id
             ,xlha.org_id
             ,xlha.mfg_no
             ,xlha.hours
             ,xlha.employee_name
             ,xlha.employee_id
             ,xlha.department
             ,xlha.section
             ,xlha.group_dsp
             ,xlha.department_id
             ,xlha.resource_id
             ,xlha.transaction_date
             ,xlha.work_code
             ,xlha.vo_defect
             ,xlha.transfer_date
             ,xlha.source_group_indentify
             ,xlha.expenditure_type
             ,xlha.project_id
             ,xlha.task_id
             ,xlha.source_type
             ,xlha.source_system
             ,xlha.source_line_id
             ,xlha.remark
             ,xlha.source_id_int_1
             ,xlha.security_id_char_1
             ,xlha.source_id_int_2
             ,xlha.security_id_char_2
             ,xlha.source_id_int_3
             ,xlha.security_id_char_3
             ,xlha.source_application_id
             ,xlha.wbs_progress_flag
             ,xlha.costed_flag
             ,xlha.costed_error_message
             ,xlha.object_version_number
             ,xlha.creation_date
             ,xlha.created_by
             ,xlha.last_updated_by
             ,xlha.last_update_date
             ,xlha.last_update_login
             ,xlha.request_id
             ,xlha.labor_rate
             ,xlha.related_expenditure_type
             ,xlha.related_labor_rate
         FROM xxpa_labor_hours_all xlha
        WHERE xlha.hours_id = p_hours_id);
  END;

  -------------------------------------------------------------------------------
  --
  --
  --Description : process_labor_hours labor hours date into table xxpa_labor_hours_all
  -------------------------------------------------------------------------------
  PROCEDURE process_labor_hours(x_labor_hours_all_rec IN OUT labor_hours_all_rec,
                                x_return_status       OUT VARCHAR2,
                                x_error_message       OUT VARCHAR2) IS
    l_statement_num VARCHAR2(30);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF x_labor_hours_all_rec.process_type = g_create_type THEN
      log(' Create Mode....');
      l_statement_num := '10';
      SELECT xxpa_labor_hours_s.nextval
        INTO x_labor_hours_all_rec.hours_id
        FROM dual;

      x_labor_hours_all_rec.creation_date    := SYSDATE;
      x_labor_hours_all_rec.created_by       := fnd_global.user_id;
      x_labor_hours_all_rec.last_updated_by  := fnd_global.user_id;
      x_labor_hours_all_rec.last_update_date := SYSDATE;

      l_statement_num := '20';
      INSERT INTO xxpa_labor_hours_all
        (hours_id
        ,group_id
        ,org_id
        ,mfg_no
        ,hours
        ,employee_name
        ,employee_id
        ,department
        ,section
        ,group_dsp
        ,department_id
        ,resource_id
        ,transaction_date
        ,work_code
        ,vo_defect
        ,transfer_date
        ,source_group_indentify
        ,expenditure_type
        ,project_id
        ,task_id
        ,source_type
        ,source_system
        ,source_line_id
        ,remark
        ,source_id_int_1
        ,security_id_char_1
        ,source_id_int_2
        ,security_id_char_2
        ,source_id_int_3
        ,security_id_char_3
        ,source_application_id
        ,wbs_progress_flag
        ,costed_flag
        ,costed_error_message
        ,object_version_number
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,program_application_id
        ,program_id
        ,program_update_date
        ,request_id
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,labor_rate
        ,related_expenditure_type
        ,related_labor_rate)
      VALUES
        (x_labor_hours_all_rec.hours_id
        ,x_labor_hours_all_rec.group_id
        ,x_labor_hours_all_rec.org_id
        ,x_labor_hours_all_rec.mfg_no
        ,x_labor_hours_all_rec.hours
        ,x_labor_hours_all_rec.employee_name
        ,x_labor_hours_all_rec.employee_id
        ,x_labor_hours_all_rec.department
        ,x_labor_hours_all_rec.section
        ,x_labor_hours_all_rec.group_dsp
        ,x_labor_hours_all_rec.department_id
        ,x_labor_hours_all_rec.resource_id
        ,x_labor_hours_all_rec.transaction_date
        ,x_labor_hours_all_rec.work_code
        ,x_labor_hours_all_rec.vo_defect
        ,x_labor_hours_all_rec.transfer_date
        ,x_labor_hours_all_rec.source_group_indentify
        ,x_labor_hours_all_rec.expenditure_type_id
        ,x_labor_hours_all_rec.project_id
        ,x_labor_hours_all_rec.task_id
        ,x_labor_hours_all_rec.source_type
        ,x_labor_hours_all_rec.source_system
        ,x_labor_hours_all_rec.source_line_id
        ,x_labor_hours_all_rec.remark
        ,x_labor_hours_all_rec.source_id_int_1
        ,x_labor_hours_all_rec.security_id_char_1
        ,x_labor_hours_all_rec.source_id_int_2
        ,x_labor_hours_all_rec.security_id_char_2
        ,x_labor_hours_all_rec.source_id_int_3
        ,x_labor_hours_all_rec.security_id_char_3
        ,x_labor_hours_all_rec.source_application_id
        ,x_labor_hours_all_rec.wbs_progress_flag
        ,x_labor_hours_all_rec.costed_flag
        ,NULL
        ,x_labor_hours_all_rec.object_version_number
        ,x_labor_hours_all_rec.creation_date
        ,x_labor_hours_all_rec.created_by
        ,x_labor_hours_all_rec.last_updated_by
        ,x_labor_hours_all_rec.last_update_date
        ,x_labor_hours_all_rec.last_update_login
        ,x_labor_hours_all_rec.program_application_id
        ,x_labor_hours_all_rec.program_id
        ,x_labor_hours_all_rec.program_update_date
        ,x_labor_hours_all_rec.request_id
        ,x_labor_hours_all_rec.attribute_category
        ,x_labor_hours_all_rec.attribute1
        ,x_labor_hours_all_rec.attribute2
        ,x_labor_hours_all_rec.attribute3
        ,x_labor_hours_all_rec.attribute4
        ,x_labor_hours_all_rec.attribute5
        ,x_labor_hours_all_rec.attribute6
        ,x_labor_hours_all_rec.attribute7
        ,x_labor_hours_all_rec.attribute8
        ,x_labor_hours_all_rec.attribute9
        ,x_labor_hours_all_rec.attribute10
        ,x_labor_hours_all_rec.attribute11
        ,x_labor_hours_all_rec.attribute12
        ,x_labor_hours_all_rec.attribute13
        ,x_labor_hours_all_rec.attribute14
        ,x_labor_hours_all_rec.attribute15
        ,x_labor_hours_all_rec.labor_rate
        ,x_labor_hours_all_rec.related_expenditure_type
        ,x_labor_hours_all_rec.related_labor_rate);

    ELSIF x_labor_hours_all_rec.process_type = g_update_type THEN
      log(' Update Mode....');
      x_labor_hours_all_rec.last_updated_by  := fnd_global.user_id;
      x_labor_hours_all_rec.last_update_date := SYSDATE;
      l_statement_num                        := '10';
      FOR rec IN (SELECT hours_id
                    FROM xxpa.xxpa_labor_hours_all
                   WHERE source_line_id =
                         x_labor_hours_all_rec.source_line_id
                     AND source_system = x_labor_hours_all_rec.source_system
                     AND org_id = fnd_profile.value('XXPJM_HEA_ORG_ID')) LOOP
        backup_labor_hours_his(rec.hours_id);
        l_statement_num := '20';
        UPDATE xxpa_labor_hours_all xlha
           SET group_id                 = x_labor_hours_all_rec.group_id
              ,org_id                   = x_labor_hours_all_rec.org_id
              ,mfg_no                   = x_labor_hours_all_rec.mfg_no
              ,hours                    = x_labor_hours_all_rec.hours
              ,employee_name            = x_labor_hours_all_rec.employee_name
              ,employee_id              = x_labor_hours_all_rec.employee_id
              ,department               = x_labor_hours_all_rec.department
              ,section                  = x_labor_hours_all_rec.section
              ,group_dsp                = x_labor_hours_all_rec.group_dsp
              ,department_id            = x_labor_hours_all_rec.department_id
              ,resource_id              = x_labor_hours_all_rec.resource_id
              ,transaction_date         = x_labor_hours_all_rec.transaction_date
              ,work_code                = x_labor_hours_all_rec.work_code
              ,vo_defect                = x_labor_hours_all_rec.vo_defect
              ,transfer_date            = x_labor_hours_all_rec.transfer_date
              ,source_group_indentify   = x_labor_hours_all_rec.source_group_indentify
              ,expenditure_type         = x_labor_hours_all_rec.expenditure_type_id
              ,project_id               = x_labor_hours_all_rec.project_id
              ,object_version_number    = xlha.object_version_number + 1
              ,task_id                  = x_labor_hours_all_rec.task_id
              ,source_type              = x_labor_hours_all_rec.source_type
              ,source_system            = x_labor_hours_all_rec.source_system
              ,source_line_id           = x_labor_hours_all_rec.source_line_id
              ,remark                   = x_labor_hours_all_rec.remark
              ,last_updated_by          = x_labor_hours_all_rec.last_updated_by
              ,last_update_date         = x_labor_hours_all_rec.last_update_date
              ,request_id               = x_labor_hours_all_rec.request_id
              ,labor_rate               = x_labor_hours_all_rec.labor_rate
              ,related_expenditure_type = x_labor_hours_all_rec.related_expenditure_type
              ,related_labor_rate       = x_labor_hours_all_rec.related_labor_rate
         WHERE xlha.hours_id = rec.hours_id;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      log('procedure ' || g_pkg_name || '.process_labor_hours ' ||
          'WHEN OTHERS THEN ' || SQLERRM || l_statement_num);
      x_error_message := g_pkg_name || '.process_labor_hours Exception:' ||
                         SQLERRM;
  END;

  PROCEDURE create_labor_hours(p_labor_hours_int_rec IN labor_hours_int_rec,
                               p_commit              IN VARCHAR2 := fnd_api.g_false,
                               x_return_status       OUT NOCOPY VARCHAR2) IS

    l_statement_num       VARCHAR2(30);
    l_labor_hours_all_rec labor_hours_all_rec;
    l_error_message       VARCHAR(240);

  BEGIN
    SAVEPOINT create_labor_hours;
    x_return_status := fnd_api.g_ret_sts_success;

    l_statement_num := '10';
    log(l_statement_num || '.validate labor hours.');
    validate_labor_hours(p_labor_hours_int_rec => p_labor_hours_int_rec,
                         x_labor_hours_all_rec => l_labor_hours_all_rec,
                         x_return_status       => x_return_status,
                         x_error_message       => l_error_message);

    IF x_return_status != fnd_api.g_ret_sts_success THEN
      write_process_result(p_labor_hours_int_rec => p_labor_hours_int_rec,
                           p_return_status       => x_return_status,
                           p_error_message       => l_error_message);
      RETURN;
    END IF;

    l_statement_num := '20';
    log(l_statement_num || '.insert labor hours.');
    process_labor_hours(x_labor_hours_all_rec => l_labor_hours_all_rec,
                        x_return_status       => x_return_status,
                        x_error_message       => l_error_message);

    l_statement_num := '30';
    write_process_result(p_labor_hours_int_rec => p_labor_hours_int_rec,
                         p_process_type        => l_labor_hours_all_rec.process_type,
                         p_return_status       => x_return_status,
                         p_error_message       => l_error_message);

    IF x_return_status != fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_labor_hours;
      RETURN;
    END IF;

    IF p_commit = fnd_api.g_true THEN
      COMMIT;
    END IF;

  END;

  PROCEDURE process_request(p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                            p_commit        IN VARCHAR2 DEFAULT fnd_api.g_false,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_group_id      IN NUMBER,
                            p_error_flag    IN VARCHAR2,
                            p_source_system IN VARCHAR2 DEFAULT NULL) IS

    l_api_name       CONSTANT VARCHAR2(30) := 'process_request';
    l_savepoint_name CONSTANT VARCHAR2(30) := 'sp_process_request01';
    l_process_status      VARCHAR2(1);
    l_labor_hours_int_rec labor_hours_int_rec;

    l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_output_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

    CURSOR design_labor_rec(p_process_status IN VARCHAR2) IS
      SELECT xlhi.*
        FROM xxpa_design_labor_int xlhi
       WHERE xlhi.group_id = p_group_id
         AND xlhi.process_status = p_process_status;

    CURSOR installation_labor_rec(p_process_status IN VARCHAR2) IS
      SELECT xlhi.*
        FROM xxpa_install_labor_int xlhi
       WHERE xlhi.group_id = p_group_id
         AND xlhi.process_status = p_process_status;

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
      xxfnd_debug.log('p_group_id   : ' || p_group_id);
      xxfnd_debug.log('p_error_flag : ' || p_error_flag);
    END IF;

    IF p_error_flag = 'Y' THEN
      l_process_status := g_process_error_status;
    ELSE
      l_process_status := g_process_pending_status;
    END IF;

    IF p_source_system = g_design_system THEN
      xxpa_labor_hours_import_pkg.log('Come to ' || g_design_system);
      FOR rec IN design_labor_rec(l_process_status) LOOP
        log('-----------------------------------------------------------');
        log('Process mfg number : ' || rec.mfg_no || '.');
        init_labor_hours_int(l_labor_hours_int_rec);
        l_labor_hours_int_rec.unique_id              := rec.unique_id;
        l_labor_hours_int_rec.group_id               := rec.group_id;
        l_labor_hours_int_rec.org_name               := rec.org_name;
        l_labor_hours_int_rec.mfg_no                 := rec.mfg_no;
        l_labor_hours_int_rec.hours                  := rec.hours;
        l_labor_hours_int_rec.department             := rec.department;
        l_labor_hours_int_rec.section                := rec.section;
        l_labor_hours_int_rec.resource_code          := rec.resource_code;
        l_labor_hours_int_rec.transaction_date       := rec.transaction_date;
        l_labor_hours_int_rec.vo_defect              := rec.vo_defect;
        l_labor_hours_int_rec.source_type            := rec.source_type;
        l_labor_hours_int_rec.source_system          := rec.source_system;
        l_labor_hours_int_rec.source_doc_line_num    := rec.source_doc_line_num;
        l_labor_hours_int_rec.employee_name          := rec.employee_name;
        l_labor_hours_int_rec.transfer_date          := rec.transfer_date;
        l_labor_hours_int_rec.source_group_indentify := rec.source_group_indentify;
        l_labor_hours_int_rec.source_line_identify   := rec.source_line_identify;
        --l_labor_hours_int_rec.source_group_indentify := rec.source_group_indentify;
        create_labor_hours(p_labor_hours_int_rec => l_labor_hours_int_rec,
                           p_commit              => fnd_api.g_true,
                           x_return_status       => l_return_status);

        IF l_return_status != fnd_api.g_ret_sts_success THEN
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      END LOOP;
    ELSIF p_source_system = g_installation_system THEN
      log('Come to ' || g_installation_system);
      FOR rec IN installation_labor_rec(l_process_status) LOOP
        log('-----------------------------------------------------------');
        log('Process mfg number : ' || rec.mfg_no || '.');
        init_labor_hours_int(l_labor_hours_int_rec);
        l_labor_hours_int_rec.unique_id              := rec.unique_id;
        l_labor_hours_int_rec.group_id               := rec.group_id;
        l_labor_hours_int_rec.org_name               := rec.org_name;
        l_labor_hours_int_rec.mfg_no                 := rec.mfg_no;
        l_labor_hours_int_rec.hours                  := rec.hours;
        l_labor_hours_int_rec.department             := rec.department;
        l_labor_hours_int_rec.section                := rec.section;
        l_labor_hours_int_rec.resource_code          := rec.resource_code;
        l_labor_hours_int_rec.work_code              := rec.work_code;
        l_labor_hours_int_rec.vo_defect              := rec.vo_defect;
        l_labor_hours_int_rec.transaction_date       := rec.transaction_date;
        l_labor_hours_int_rec.source_type            := rec.source_type;
        l_labor_hours_int_rec.source_system          := rec.source_system;
        l_labor_hours_int_rec.source_doc_line_num    := rec.source_doc_line_num;
        l_labor_hours_int_rec.employee_name          := rec.employee_name;
        l_labor_hours_int_rec.transfer_date          := rec.transfer_date;
        l_labor_hours_int_rec.source_group_indentify := rec.source_group_indentify;
        l_labor_hours_int_rec.source_line_identify   := rec.source_line_identify;
        l_labor_hours_int_rec.remark                 := rec.remark;
        create_labor_hours(p_labor_hours_int_rec => l_labor_hours_int_rec,
                           p_commit              => fnd_api.g_true,
                           x_return_status       => l_return_status);

        IF l_return_status != fnd_api.g_ret_sts_success THEN
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      END LOOP;
    END IF;

    IF x_return_status != fnd_api.g_ret_sts_success THEN
      log('Procedure main : rollback.');
      ROLLBACK;
    ELSE
      --null;
      log('Procedure main : commit.');
      --commit;
    END IF;

    IF p_source_system = g_design_system THEN
      print_design_output(p_init_msg_list => fnd_api.g_false,
                          x_return_status => l_output_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data);
    ELSIF p_source_system = g_installation_system THEN
      print_installation_output(p_init_msg_list => fnd_api.g_false,
                                x_return_status => l_output_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
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
  END process_request;

  PROCEDURE installation_main(errbuf       OUT VARCHAR2,
                              retcode      OUT VARCHAR2,
                              p_group_id   IN NUMBER,
                              p_error_flag IN VARCHAR2
                              --p_source_system IN VARCHAR2 DEFAULT NULL
                              ) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body

    -- convert parameter data type, such as varchar2 to date
    -- l_date := fnd_conc_date.string_to_date(p_parameter1);

    g_current_labor := g_installation_system;

    -- call process request api
    process_request(p_init_msg_list => fnd_api.g_true,
                    p_commit        => fnd_api.g_true,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_group_id      => p_group_id,
                    p_error_flag    => p_error_flag,
                    p_source_system => g_installation_system);

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
  END installation_main;

  PROCEDURE design_main(errbuf       OUT VARCHAR2,
                        retcode      OUT VARCHAR2,
                        p_group_id   IN NUMBER,
                        p_error_flag IN VARCHAR2
                        --p_source_system IN VARCHAR2 DEFAULT NULL
                        ) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
  BEGIN
    retcode := '0';
    -- concurrent header log
    xxfnd_conc_utl.log_header;
    -- conc body

    -- convert parameter data type, such as varchar2 to date
    -- l_date := fnd_conc_date.string_to_date(p_parameter1);

    g_current_labor := g_design_system;

    -- call process request api
    process_request(p_init_msg_list => fnd_api.g_true,
                    p_commit        => fnd_api.g_true,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_group_id      => p_group_id,
                    p_error_flag    => p_error_flag,
                    p_source_system => g_design_system);

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
  END design_main;

END xxpa_labor_hours_import_pkg;
/
