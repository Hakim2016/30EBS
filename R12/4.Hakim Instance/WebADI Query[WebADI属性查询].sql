/* bne:page=BneCreateDoc&
   bne:language=US&
   bne:viewer=BNE:EXCEL2003%25&
   bne:reporting=N&
   bne:integrator=GENERAL_281_INTG&
   bne:layout=XXBOM_ITM_ATTRI_EXP_LY&
   bne:content=GENERAL_281_CNT&
   bne:noreview=Y
*/
SELECT biv.integrator_code,
       biv.user_name,
       biv.upload_param_list_app_id,
       biv.upload_param_list_code,
       biv.*
  FROM bne_integrators_vl biv
 WHERE 1 = 1
   AND biv.integrator_code = 'GENERAL_281_INTG';
/*
   upload_param_list_app_id      : 800
   upload_param_list_code        : HR_UPLOAD
   upload_serv_param_list_app_id : 231
   upload_serv_param_list_code   : UPL_SERV_JNLS
   
*/
SELECT *
  FROM bne_interfaces_vl inf
 WHERE 1 = 1
   AND inf.integrator_code = 'GENERAL_281_INTG';
-- application_id           : 20006  
-- interface_code           : GENERAL_281_INTF
-- upload_param_list_app_id : 20006  
-- upload_param_list_code   : GENERAL_281

SELECT *
  FROM bne_interface_cols_vl bic
 WHERE 1 = 1
   AND bic.interface_code = 'GENERAL_281_INTF';

SELECT *
  FROM bne_param_lists_vl bpl
 WHERE 1 = 1
   AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'GENERAL_281%';
/*   
   attribute_app_id : 20006
   attribute_code   : GENERAL_281_P0_ATT
*/

SELECT *
  FROM bne_param_list_items bpli
 WHERE 1 = 1
   AND bpli.application_id = 20006
   AND bpli.param_list_code LIKE 'GENERAL_281%'
 ORDER BY bpli.param_list_code,
          bpli.sequence_num;

SELECT *
  FROM bne_attributes ba
 WHERE 1 = 1
   AND ba.application_id = 20006
   AND ba.attribute_code LIKE 'GENERAL_281%' /*'GENERAL_281_P0_ATT'*/
 ORDER BY ba.rowid;
 
 SELECT * FROM bne_stored_sql a WHERE a.content_code LIKE '%281%';
SELECT *
  FROM bne_param_defns_vl a, bne_param_list_items b
 WHERE a.param_defn_code = b.param_defn_code
   AND b.param_list_code LIKE '%281%'
   AND a.application_id = b.application_id
   and a.param_source='HR:Download';
