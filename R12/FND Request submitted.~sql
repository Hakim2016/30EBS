/*
v1.0  add responsibility
v1.01 add user info(user name & email)
*/
SELECT v.request_id rqst_id,
       v.argument_text,
       /*(SELECT ppa.segment1
          FROM pa_projects_all ppa
         WHERE 1 = 1
           AND ppa.project_id = substr(v.argument_text, 1, instr(v.argument_text, ',') - 1)) prj_num,*/
       --SUBSTR(v.argument_text, 1, INSTR(v.argument_text, ',')-1) prj_id,
       --v.request_date,
       --v.requested_start_date,
       v.actual_start_date act_strt_date,
       --v.requested_start_date start_date,
       v.actual_completion_date cplt_date,
       --(v.ACTUAL_COMPLETIOv.REQUESTED_START_DATEN_DATE - v.ACTUAL_START_DATE) / (60 * 60) "运行时间",
       decode(v.actual_completion_date, NULL, trunc((SYSDATE - v.actual_start_date) * 24, 3), NULL) during,
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
          FROM apps.fnd_application fa
         WHERE 1 = 1
           AND fa.application_id = v.responsibility_application_id) app_name,
       v.responsibility_id,
       fr.responsibility_key,
       fcr.outfile_name,
       fcr.output_file_type,--change Output_file_type to 'PS'
       fnd_webfile.get_url(3, --log 输出类型 --3 log
                           v.request_id, --请求ID
                           'APPLSYSPUB/PUB',
                           'FCWW',
                           10),
       fnd_webfile.get_url(4, --output 输出类型  --4 output
                           v.request_id, --请求ID
                           'APPLSYSPUB/PUB',
                           'FCWW',
                           10)
  FROM apps.fnd_conc_req_summary_v v,
       apps.fnd_responsibility     fr,
       apps.fnd_user               fu,
       apps.per_all_people_f       pap,
       apps.fnd_concurrent_requests fcr
 WHERE 1 = 1
 AND v.REQUEST_ID = fcr.request_id
   AND fu.user_id = v.requested_by
   AND fu.employee_id = pap.person_id(+)
   AND pap.effective_end_date > SYSDATE
   AND fr.responsibility_id = v.responsibility_id
      --AND v.request_id = 18192510--18188486--18073759--16839045--16282868--16253168--16221488--13165995--16098690--15981725--15956670
      --=17659658--17493023--17524251--17523985
      --IN (17374943, 17374944, 17375642,17375545,17294974)
      --AND v.program_short_name LIKE 'XX%'--= 'XXPAB008'--'XXINVB014'--'XXPAUPDATESTATUS'
      --AND v.program LIKE --'Create Accounting%'
      --AND v.status_code IN ('E','G')
      --AND v.phase_code IN ('R', 'P')
   AND v.user_concurrent_program_name
   /*IN
   (
   --'XXPA: Cost Card Detail Report(HEA/HBS)','XXPA:Cost Card Report(HEA/HBS)'
   --'Open Account Balances Listing'
   )*/
    
   LIKE 
   '%ost%llect%'
   --'%Project Cost Data Outbound'
   --'XXINV:Stock Master Report'
   --'%Stock%Report%'
   --'Cost Manager'
   --'Actual Cost Worker'
   --'%%Auto%PO%Receive%to%Stock%After%'
   --'%XXINV:Subinventory Transfer%'
   --'Transfer Journal%'
   --'XXPO:Auto PO Receive to Stock After Inspection'
   --'XXPO:Auto PO Receive to Stock After Inspection'
   --'PRC%'
   --'XXAR:HEA/HBS Credit Note Application Print'
   --'XXPA:Project COGS Monthly Report%'
   --'XXFND:Interface Manager'
   --'%XXPA:Project Cost Data Outbound%'
   --'XXPA:Project EQ Cost of Sales Recognition Request%'
   --'XXPA%Movement%Monthly%Balance%Report'
   --'XXPA%FG Monthly Report'
   --'%Monthly Balance Report%'
   --'XXPA:Project Revenue and Cost of Sales Recognition Request'
   --'%XXINV: Inventory Item Information export%'
   --'%Project%COGS%Monthly%'
   --'XXPA:Project Cost Data Outbound'
   --'XXPA%Project Revenue and Cost of Sales Recognition Request'
   --'%Interface%Manager%'
   --'XXPA:Project Cost Detail Report (HEA/HBS)'
--'XXPA:Project Cost Data Outbound'
--'XXPA:Progressive JIP and Sales Summary Report'
--'XXOM:SO Balance Report'
--'XX%'
--'Trial Balance%'
--'XXPA:Cost Card Report(HEA/HBS)'
--'%Cost Card%'
--'XXOM:SO Balance Report%'
--'Cost Manager'
--'Actual Cost Worker'
--'XXAR:Account Receivable Card'(2207196,897153)
--'%XXGL:Accounting Data Outbound HFG%'
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
AND v.argument_text LIKE '%83,%'--'%2018%'--'%OVERSEA%'--'%SHE_FAC_ORG%%'--'HEA_Oracle,%'
--AND v.requestor = 'HAND_HKM'--'HAND_LCR'--'70264934'--'HAND_HKM'
--AND v.request_id = 17225733--17204202-->= 16727489
 ORDER BY --v.
           v.request_id DESC;

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
