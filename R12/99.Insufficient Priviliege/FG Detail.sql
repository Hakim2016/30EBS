/*begin
  fnd_global.APPS_INITIALIZE(user_id => 4088,resp_id =>50848 ,resp_appl_id =>275 );  
  mo_global.set_policy_context(p_access_mode => 'S',p_org_id => 84);
end;
*/
SELECT xcfd.PROJECT_NUMBER,
       xcfd.TASK_NUMBER,
       xcfd.EXPENDITURE_ITEM_DATE,
       xcfd.EXPENDITURE_ENDING_DATE,
       xcfd.EXPENDITURE_TYPE,
       xcfd.EXPENDITURE_AMOUNT,
       xcfd.ORIG_EXPENDITURE_TYPE,
       xcfd.EXPENDITURE_REFERENCE,
       xcfd.PROJECT_TYPE,
       xcfd.COST_TYPE,
       xcfd.SUB_TYPE,
       xcfd.SOURCE_TABLE,
       xcfd.SOURCE_LINE_ID,
       xcfd.COST_DETAIL_ID,
       xcfd.COST_HEADER_ID,
       xcfd.ROW_ID,
       xcfd.TRANSFERED_PA_FLAG,
       xcfd.BATCH_NAME,
       xcfd.ORG_ID,
       xcfd.PERIOD_NAME,
       xcfd.EXPENDITURE_ORG_ID,
       xcfd.PROJECT_ID,
       xcfd.PROJECT_NAME,
       xcfd.PROJECT_LONG_NAME,
       xcfd.MFG_ID,
       xcfd.MFG_NUMBER,
       xcfd.TASK_ID,
       xcfd.EXPENDITURE_ID,
       xcfd.ORIG_EXPENDITURE_AMOUNT,
       xcfd.CREATION_DATE,
       xcfd.CREATED_BY,
       xcfd.LAST_UPDATED_BY,
       xcfd.LAST_UPDATE_DATE,
       xcfd.LAST_UPDATE_LOGIN,
       xcfd.REQUEST_ID,
       xcfd.ATTRIBUTE_CATEGORY,
       xcfd.ATTRIBUTE1,
       xcfd.ATTRIBUTE2,
       xcfd.ATTRIBUTE3,
       xcfd.ATTRIBUTE4,
       xcfd.ATTRIBUTE5,
       xcfd.ATTRIBUTE6,
       xcfd.ATTRIBUTE7,
       xcfd.ATTRIBUTE8,
       xcfd.ATTRIBUTE9,
       xcfd.ATTRIBUTE10,
       xcfd.ATTRIBUTE11,
       xcfd.ATTRIBUTE12,
       xcfd.ATTRIBUTE13,
       xcfd.ATTRIBUTE14,
       xcfd.ATTRIBUTE15
  FROM xxpa_cost_flow_dtls_v xcfd
 WHERE EXPENDITURE_AMOUNT <> 0
   AND - 1 = -1
   AND (EXPENDITURE_AMOUNT <> 0 AND - 1 = -1 AND EXISTS
        (SELECT 1
           FROM xxpa_cost_flow_sum_v xcfs
          WHERE xcfs.cost_header_id = xcfd.cost_header_id
            AND xcfs.org_id = 84
            AND xcfs.cost_type = 'FAC_FG'
            AND xcfs.PERIOD_NAME = 'MAR-17'
            AND xcfs.project_id = nvl('', xcfs.project_id)
            AND xcfs.MFG_ID = nvl('', xcfs.MFG_ID)
            AND xcfs.TRANSFERED_PA_FLAG = 'N'))
 ORDER BY project_number, task_number, expenditure_type
