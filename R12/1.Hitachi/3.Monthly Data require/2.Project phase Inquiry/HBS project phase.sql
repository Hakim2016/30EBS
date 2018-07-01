SELECT ELEMENT_VERSION_ID,
       PARENT_STRUCTURE_VERSION_ID,
       ORG_ID,
       PROJECT_ID,
       TASK_ID,
       CUSTOMER_ID,
       PROJECT_END_DATE,
       PROJECT_START_DATE,
       ORG_NAME,
       PROJECT_NUM,
       PROJECT_NAME,
       CUSTOMER_NAME,
       PROJECT_STATUS_CODE,
       PROJECT_STATUS_NAME,
       PROJECT_LONG_NAME,
       PROJECT_TYPE_CODE,
       CUSTOMER_NUMBER,
       TASK_STATUS,
       MFG_NUM,
       RELATED_MFG_NUM,
       MFG_TASK_NAME,
       MFG_SPEC,
       MFG_STATUS,
       SCHEDULED_START_DATE,
       SCHEDULED_FINISH_DATE,
       ESTIMATED_START_DATE,
       ESTIMATED_FINISH_DATE,
       ACTUAL_START_DATE,
       ACTUAL_FINISH_DATE,
       PROJECT_TYPE
  FROM xxpjm_mfg_status_v
 WHERE (ORG_ID = 101)--HBS
