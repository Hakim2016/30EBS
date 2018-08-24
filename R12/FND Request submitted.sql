/*
v1.0  add responsibility
v1.01 add user info(user name & email)
*/
SELECT v.request_id rqst_id,
       v.argument_text,
       --v.request_date,
       --v.requested_start_date,
       v.actual_start_date act_strt_date,
       --v.requested_start_date start_date,
       v.actual_completion_date cplt_date,
       --(v.ACTUAL_COMPLETIOv.REQUESTED_START_DATEN_DATE - v.ACTUAL_START_DATE) / (60 * 60) "����ʱ��",
       DECODE(v.actual_completion_date, NULL,TRUNC((SYSDATE - v.actual_start_date)*24,3), NULL) during,
       trunc((v.actual_completion_date - v.actual_start_date) * 24) hr,
       round(((v.actual_completion_date - v.actual_start_date) * 24 -
             trunc((v.actual_completion_date - v.actual_start_date) * 24)) * 60,
             2) mins,
       decode(v.phase_code, 'R', 'Running', 'P', 'Pending', 'C', 'Completed', v.phase_code) phase,
       decode(v.status_code,
              'R',
              'Running',
              'Q',
              'Standby',
              'C',
              'Completed',
              'X',
              'Terminated',
              'E',
              'Error',
              'G',
              'Warning',
              'I',
              'Scheduled',
              v.status_code) status_code,
       --v.status_code,
       v.program_short_name short_name,
       v.user_concurrent_program_name,
       v.requestor,
       v.requested_by rqst_by,
       pap.email_address,
       pap.full_name,
       v.argument_text,
       v.responsibility_application_id app_id,
       (SELECT fa.application_short_name
          FROM fnd_application fa
         WHERE 1 = 1
           AND fa.application_id = v.responsibility_application_id) app_name,
       v.responsibility_id,
       fr.responsibility_key
  FROM fnd_conc_req_summary_v v,
       fnd_responsibility     fr,
       fnd_user               fu,
       per_all_people_f       pap
 WHERE 1 = 1
   AND fu.user_id = v.requested_by
   AND fu.employee_id = pap.person_id(+)
   AND pap.effective_end_date > SYSDATE
   AND fr.responsibility_id = v.responsibility_id
      --AND v.request_id = 16282868--16253168--16221488--13165995--16098690--15981725--15956670
      --IN (16275615, 16278535)
      --AND v.program_short_name = 'XXPAUPDATESTATUS'
      --AND v.program LIKE 'Create Accounting%'
      AND v.user_concurrent_program_name LIKE
      '%XXGL:Accounting Data Outbound HFG%'
      --'%IF68%'
      --'XXPA:Project Cost Data Outbound'
      --'XXWIP: Pull Item Quantity Checking'
      --'XXPA:Project Revenue and Cost of Sales Recognition Request'
      --'XXPA:EQ%s JIP Automatical Transfer Program'
      --'XXPA:Project EQ Cost of Sales Recognition Request(HEA/HBS)'
      --'PRC: Distribute Usage and Miscellaneous Costs'
      --'%XXGL:Exchange Rate Inbound to HFG%'
      --'XXPA:Project EQ Cost of Sales Recognition Request(SHE)'
      --'XXPA: Finish Goods Transfer'
      --'XXPA:Project Cost Analysis (SHE/HET) NEW'
      --'XXPA:Project Wip Cost Analysis Detail'
      --'XXPA: Project FG Completion Data Collection'
      --'Item categories report'
      --'%Supplier Costs Interface Audit'
      --'%Cost Collection Manager'
      --'%XXPJM:Labor Hours Budget Interface%'
      --'Create Accounting%'
      --'Create Accounting - Cost Management'
      --'XXOM:Tax Invoice Print'
      --'XXPA:Accrual Offset Auto Generate Program'
      --'Period Close Reconciliation Report'
      --'Receiving Value Report (XML)'
      --'%COGS Monthly Report%'
      --'XXPA:Project Revenue and Cost of Sales Recognition Request'
      --'%XXPJM:Labor Hours Budget Interface%'--IF47
      --'%Cost Incurred Report%'
      --'XXPA:Project Cost Data Outbound'
      --'XXPA:Generate Expenditure Batch For Cost Structure'
      --'XXAR:HEA/HBS Tax Invoice Print'
      --'XXAR: Billing Interface outbound to G4'
      --'PRC: Update Project Summary Amounts'
      --'AUD: Supplier Costs Interface Audit'
      --'Projects Cost Collection Manager'
      --'XXOM%SO Balance Report'
      --'XXOM:SO Balance Report(Sales)'
      --'Create Accounting%'
      --'Cost Manager'
      --'Actual Cost Worker'
      --'%Project Cost Analysis%'
      --'XXGL:Fixed Assets Outbound to HFG'
      --'Projects Cost Collection Manager'
      --'Cost Collection Manager'
      --######conplatibility of <XXPA:Project Status Update(BA)> start
      /*AND v.user_concurrent_program_name IN (
      'XXPA:Project Status Update(BA)',
      --'XXPA:Generate Expenditure Batch For Cost Structure',
      'XXPA:Project Revenue and Cost of Sales Recognition Request',
      --'XXPA:Project EQ Cost of Sales Recognition Request(HEA/HBS)',
      --
      'XXPA:Project Status Update(Installation)'
      )*/
      --######conplatibility of <XXPA:Project Status Update(BA)> end
      --'XXPA:Project Status Update(BA)'
      --'XXAR: Delivery Interface outbound GSCM to R3'
      --'XXPA%Project Revenue and Cost of Sales Recognition Request'
      --'Period Close Reconciliation Report'
      --'PRC: Transaction Import'
      --'XXPA:Project Cost Data Outbound'
      
      --AND v.request_date > TRUNC(SYSDATE)
   --AND v.request_date <> v.requested_start_date
--AND trunc(v.request_date) = to_date('2018-07-13','yyyy-mm-dd')
--AND v.argument_text LIKE '%OVERSEA%'--'%SHE_FAC_ORG%%'--'HEA_Oracle,%'
--AND v.requestor = 'HAND_HKM'--'HAND_LCR'--'70264934'--'HAND_HKM'
--AND v.status_code = 'E'
--AND v.phase_code IN ('R', 'P')
AND v.request_id >= 16727489
 ORDER BY v.request_id --DESC
 ;

--add user info v1.01
SELECT fu.user_id,
       fu.employee_id,
       pap.person_id,
       fu.*,
       pap.*
  FROM fnd_user         fu,
       per_all_people_f pap
 WHERE 1 = 1
      
   AND fu.user_id = 4270 --v.REQUESTED_BY
   AND fu.employee_id = pap.person_id;

SELECT *
  FROM per_all_people_f pap
 WHERE 1 = 1
   AND pap.person_id = 96;
