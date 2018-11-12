--Oracle VPD
SELECT dp.package || '.' || dp.function,
       dp.*
  FROM dba_policies dp
 WHERE 1 = 1
      /*AND dp.OBJECT_NAME IN (UPPER\*('XXOM_DO_INVOICE_HEADERS')*\('xxpa_proj_milestone_manage'),
      'XXOM_DO_INVOICE_HEADERS',
      'XXAR_HEA_TAXINV_RULES_ALL',
      'XLA_TRANSACTION_ENTITIES')*/
   AND dp.policy_group LIKE 'XX%'
   AND dp.package LIKE 'XX%';
   
   
xxar_utils; --.TRX_TYPE_SEC2;
xla_security_policy_pkg; --.XLA_STANDARD_POLICY
xxpa_vpd_pkg; --.GETPOLICY


CREATE OR REPLACE FUNCTION hide_org_lead(v_schema IN VARCHAR2, v_object IN VARCHAR2)
  RETURN VARCHAR2 AS con VARCHAR2(100);
BEGIN
  con := 'org_id = 81';
  RETURN con;
END;

------
/*
BEGIN
dbms_rls.add_policy(object_schema   => 'XXPJM', --[1]
                    object_name     => 'XXPJM_PHASE_LOADING_PLAN', --[2]
                    policy_name     => 'hide_org_policy', --[3]
                    function_schema => 'APPS', --[4]
                    policy_function => 'hide_org_lead', --[5]
                    statement_types => 'SELECT,UPDATE',
                    enbale          => TRUE); --[6]
                      
dbms_rls.add_policy(object_schema   => 'APPS', --[1]
                    object_name     => 'XXOM_DO_INVOICE_HEADERS', --[2]
                    policy_name     => 'XXOM_DO_INVOICE_HEADERS', --[3]
                    function_schema => 'APPS', --[4]
                    policy_function => 'MO_GLOBAL.ORG_SECURITY', --[5]
                    statement_types => 'Select',
                    update_check    => FALSE,
                    ENABLE          => TRUE); --[6]
END;
*/

