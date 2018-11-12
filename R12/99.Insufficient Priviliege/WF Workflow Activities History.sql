SELECT i.begin_date,
       a.begin_date,
       ias.rowid,
       'R',
       ias.item_type,
       it.display_name,
       it.description,
       ias.item_key,
       i.user_key,
       i.begin_date,
       i.end_date,
       ias.process_activity,
       pa.instance_label,
       a.name,
       a.display_name,
       a.description,
       a.type,
       l_at.meaning,
       ias.execution_time,
       ias.begin_date,
       ias.end_date,
       ias.activity_status,
       l_as.meaning,
       ias.activity_result_code,
       wf_core.activity_result(a.result_type, ias.activity_result_code),
       ias.assigned_user,
       wf_directory.getroledisplayname(ias.assigned_user),
       ias.notification_id,
       ias.outbound_queue_id,
       ias.error_name,
       ias.error_message,
       ias.error_stack,
       a.*
  FROM wf_lookups                l_at,
       wf_lookups                l_as,
       wf_activities_vl          a,
       wf_process_activities     pa,
       wf_item_types_vl          it,
       wf_items                  i,
       wf_item_activity_statuses ias
 WHERE ias.item_type = i.item_type
   AND ias.item_key = i.item_key
   AND i.begin_date BETWEEN a.begin_date AND nvl(a.end_date, i.begin_date)
   AND i.item_type = it.name
   AND ias.process_activity = pa.instance_id
   AND pa.activity_name = a.name
   AND pa.activity_item_type = a.item_type
   AND l_at.lookup_type = 'WFENG_ACTIVITY_TYPE'
   AND l_at.lookup_code = a.type
   AND l_as.lookup_type = 'WFENG_STATUS'
   AND l_as.lookup_code = ias.activity_status
   AND ias.item_type IN ('OEOL', 'OEOH')
   AND ias.item_key IN ('127470', '127471', '293282', '127516') --('3043','643140','3044')
 ORDER BY ias.item_key,
          ias.begin_date     DESC,
          ias.execution_time DESC;

SELECT ias.item_type,
       ias.item_key,
       ias.process_activity,
       pa.activity_name,
       ias.begin_date,
       ias.end_date,
       ias.execution_time,
       ias.*
  FROM wf_item_activity_statuses ias,
       wf_process_activities     pa
 WHERE 1 = 1
   AND ias.item_type IN ('OEOL' /*, 'OEOH'*/)
   AND ias.item_key IN ('127470', '127471', '293282', '127516')
   AND ias.process_activity = pa.instance_id
-- AND pa.activity_name IN ('XXINV_LINE_CLOSED_CHECK' /*, 'XXOM_BLOCK'*/)
 ORDER BY ias.item_key,
          ias.begin_date     DESC,
          ias.execution_time DESC;

-- Standard Workflow history records
SELECT *
  FROM (SELECT wias.item_type AS item_type,
               wias.item_key AS item_key,
               wias.process_activity AS process_activity,
               wias.rowid AS row_id,
               'R' AS row_source,
               wias.notification_id AS notif_id,
               decode(wn.status, 'OPEN', nvl(wn.more_info_role, wias.assigned_user), wias.assigned_user) AS assigned_user,
               wias.activity_status AS activity_status,
               wias.activity_result_code AS activity_result_code,
               wias.execution_time AS execution_time,
               wias.begin_date AS begin_date,
               wias.end_date AS end_date,
               wias.due_date AS due_date,
               wl.meaning AS status_display,
               wa.name AS activity_name,
               wa.display_name AS activity_display,
               wi.user_key AS user_key,
               wa2.name AS parent_activity,
               decode(wa2.name, 'ROOT', '', wa2.display_name) AS parent_activity_display_name,
               wa.type AS activity_type,
               wf_fwkmon.getroleemailaddress(decode(wn.status,
                                                    'OPEN',
                                                    nvl(wn.more_info_role, wias.assigned_user),
                                                    wias.assigned_user)) AS role_email_address,
               wf_directory.getroledisplayname2(decode(wn.status,
                                                       'OPEN',
                                                       nvl(wn.more_info_role, wias.assigned_user),
                                                       wias.assigned_user)) AS role_display_name,
               decode(wias.activity_result_code, '#NULL', 'WfNoCloseDate', 'WfCloseDate') AS end_date_col_switch,
               decode(wias.activity_status, 'ERROR', 'WfStatusErrorText', 'WfStatusNoterrText') AS status_column_switch,
               decode(wias.activity_status,
                      'ERROR',
                      'WfStatusError',
                      'COMPLETE',
                      'WfStatusComplete',
                      'SUSPEND',
                      'WfStatusSuspended',
                      'WAITING',
                      'WfStatusWaiting',
                      'DEFERRED',
                      'WfStatusDeferred',
                      'NOTIFIED',
                      'WfStatusNotified',
                      'WfStatusActive') AS image_column_switch,
               wf_core.activity_result(wa.result_type,
                                       decode(wias.activity_result_code, '#NULL', NULL, wias.activity_result_code)) AS result_display,
               wpa.activity_item_type AS activity_item_type,
               decode(wa.type,
                      'NOTICE',
                      decode(wias.activity_status,
                             'NOTIFIED',
                             'WfReassignEnabled',
                             'ERROR',
                             'WfReassignEnabled',
                             'WfReassignDisabled'),
                      'WfReassignDisabled') AS reassign_switcher,
               decode(wias.activity_status,
                      'NOTIFIED',
                      'N',
                      'ACTIVE',
                      'N',
                      'ERROR',
                      'N',
                      'WAITING',
                      'N',
                      'DEFERRED',
                      'N',
                      'Y') AS select_disabled,
               decode(wa.type,
                      'PROCESS',
                      decode(wias.activity_status,
                             'SUSPEND',
                             'WfResumeEnabled',
                             'COMPLETE',
                             'WfSuspResDisabled',
                             'WfSuspendEnabled'),
                      'WfSuspResDisabled') AS suspend_switcher,
               wa.expand_role AS expand_role,
               decode(wn.status,
                      'OPEN',
                      nvl2(wn.more_info_role, wf_core.translate('WFNTF_MOREINFO_REQUESTED'), wnl.meaning),
                      wnl.meaning) AS notification_status
          FROM wf_item_activity_statuses wias
          LEFT JOIN wf_notifications wn
            ON wias.notification_id = wn.notification_id
          LEFT JOIN wf_lookups wnl
            ON wnl.lookup_code = wn.status
           AND wnl.lookup_type = 'WF_NOTIFICATION_STATUS', wf_lookups wl, wf_items wi, wf_activities_vl wa,
         wf_process_activities wpa, wf_activities_vl wa2
         WHERE wl.lookup_code = wias.activity_status
           AND wl.lookup_type = 'WFENG_STATUS'
           AND wias.item_type = wi.item_type
           AND wias.item_key = wi.item_key
           AND wias.process_activity = wpa.instance_id
           AND wpa.activity_name = wa.name
           AND wpa.activity_item_type = wa.item_type
           AND wi.begin_date BETWEEN wa.begin_date AND nvl(wa.end_date, wi.begin_date)
           AND wpa.process_name = wa2.name
           AND wpa.process_item_type = wa2.item_type
           AND wpa.process_version = wa2.version
           AND wias.item_type = 'OEOL' -- :1
           AND wias.item_key = '3043' --:2
        UNION ALL
        SELECT wiash.item_type AS item_type,
               wiash.item_key AS item_key,
               wiash.process_activity AS process_activity,
               wiash.rowid AS row_id,
               'H' AS row_source,
               wiash.notification_id AS notif_id,
               decode(wn.status, 'OPEN', nvl(wn.more_info_role, wiash.assigned_user), wiash.assigned_user) AS assigned_user,
               wiash.activity_status AS activity_status,
               wiash.activity_result_code AS activity_result_code,
               wiash.execution_time AS execution_time,
               wiash.begin_date AS begin_date,
               wiash.end_date AS end_date,
               wiash.due_date AS due_date,
               wl.meaning AS status_display,
               wa.name AS activity_name,
               wa.display_name AS activity_display,
               wi.user_key AS user_key,
               wa2.name AS parent_activity,
               decode(wa2.name, 'ROOT', '', wa2.display_name) AS parent_activity_display_name,
               wa.type AS activity_type,
               wf_fwkmon.getroleemailaddress(decode(wn.status,
                                                    'OPEN',
                                                    nvl(wn.more_info_role, wiash.assigned_user),
                                                    wiash.assigned_user)) AS role_email_address,
               wf_directory.getroledisplayname2(decode(wn.status,
                                                       'OPEN',
                                                       nvl(wn.more_info_role, wiash.assigned_user),
                                                       wiash.assigned_user)) AS role_display_name,
               decode(wiash.activity_result_code, '#NULL', 'WfNoCloseDate', 'WfCloseDate') AS end_date_col_switch,
               decode(wiash.activity_status, 'ERROR', 'WfStatusErrorText', 'WfStatusNoterrText') AS status_column_switch,
               decode(wiash.activity_status,
                      'ERROR',
                      'WfStatusError',
                      'COMPLETE',
                      'WfStatusComplete',
                      'SUSPEND',
                      'WfStatusSuspended',
                      'WAITING',
                      'WfStatusWaiting',
                      'DEFERRED',
                      'WfStatusDeferred',
                      'NOTIFIED',
                      'WfStatusNotified',
                      'WfStatusActive') AS image_column_switch,
               wf_core.activity_result(wa.result_type,
                                       decode(wiash.activity_result_code, '#NULL', NULL, wiash.activity_result_code)) AS result_display,
               wpa.activity_item_type AS activity_item_type,
               decode(wa.type,
                      'NOTICE',
                      decode(wiash.activity_status,
                             'NOTIFIED',
                             'WfReassignEnabled',
                             'ERROR',
                             'WfReassignEnabled',
                             'WfReassignDisabled'),
                      'WfReassignDisabled') AS reassign_switcher,
               decode(wiash.activity_status,
                      'NOTIFIED',
                      'N',
                      'ACTIVE',
                      'N',
                      'ERROR',
                      'N',
                      'WAITING',
                      'N',
                      'DEFERRED',
                      'N',
                      'Y') AS select_disabled,
               decode(wa.type,
                      'PROCESS',
                      decode(wiash.activity_status,
                             'SUSPEND',
                             'WfResumeEnabled',
                             'COMPLETE',
                             'WfSuspResDisabled',
                             'WfSuspendEnabled'),
                      'WfSuspResDisabled') AS suspend_switcher,
               wa.expand_role AS expand_role,
               decode(wn.status,
                      'OPEN',
                      nvl2(wn.more_info_role, wf_core.translate('WFNTF_MOREINFO_REQUESTED'), wnl.meaning),
                      wnl.meaning) AS notification_status
          FROM wf_item_activity_statuses_h wiash
          LEFT JOIN wf_notifications wn
            ON wiash.notification_id = wn.notification_id
          LEFT JOIN wf_lookups wnl
            ON wnl.lookup_code = wn.status
           AND wnl.lookup_type = 'WF_NOTIFICATION_STATUS', wf_lookups wl, wf_items wi, wf_activities_vl wa,
         wf_process_activities wpa, wf_activities_vl wa2
         WHERE wl.lookup_code = wiash.activity_status
           AND wl.lookup_type = 'WFENG_STATUS'
           AND wiash.item_type = wi.item_type
           AND wiash.item_key = wi.item_key
           AND wiash.process_activity = wpa.instance_id
           AND wpa.activity_name = wa.name
           AND wpa.activity_item_type = wa.item_type
           AND wi.begin_date BETWEEN wa.begin_date AND nvl(wa.end_date, wi.begin_date)
           AND wpa.process_name = wa2.name
           AND wpa.process_item_type = wa2.item_type
           AND wpa.process_version = wa2.version
           AND wiash.item_type = 'OEOL' --:3
           AND wiash.item_key = '3043' /*:4*/
        ) qrslt
 ORDER BY 11 DESC,
          10 DESC;
