/*
v1.0  add responsibility
v1.01 add user info(user name & address)
*/
SELECT v.request_id rqst_id,
       v.request_date,
       v.actual_completion_date cplt_date,
       (v.ACTUAL_COMPLETION_DATE - v.ACTUAL_START_DATE) / (60 * 60) "运行时间",
       decode(v.phase_code, 'R', 'Running', 'P', 'Pending', 'C', 'Completed', v.phase_code) phase,
       DECODE(v.status_code, 'R', 'Running', 'Q', 'Standby','C', 'Completed','X','Terminated','E','Error', v.status_code) status_code,
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
      --AND v.request_id = 16221488--13165995--16098690--15981725--15956670
      --AND v.program_short_name = 'XXPAUPDATESTATUS'
      --AND v.program LIKE 'Create Accounting%'
   AND v.user_concurrent_program_name LIKE
   '%XXPJM:Labor Hours Budget Interface%'--IF47
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
      --'%Project Cost Analysis%'
      --'XXGL:Fixed Assets Outbound to HFG'
      --'Projects Cost Collection Manager'
      --'Cost Collection Manager'
      --######conplatibility of <XXPA:Project Status Update(BA)> start
      /*AND v.user_concurrent_program_name IN (
      'XXPA:Project Status Update(BA)',
      'XXPA:Generate Expenditure Batch For Cost Structure',
      'XXPA:Project Revenue and Cost of Sales Recognition Request',
      'XXPA:Project EQ Cost of Sales Recognition Request(HEA/HBS)',
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
--AND trunc(v.request_date) >= to_date('2018-05-09','yyyy-mm-dd')
--AND v.argument_text LIKE '%SHE_FAC_ORG%%'--'HEA_Oracle,%'
--AND v.requestor = 'HAND_HKM'
--AND v.status_code = 'E'
--AND v.phase_code IN ('R', 'P')
 ORDER BY v.request_id DESC;

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
