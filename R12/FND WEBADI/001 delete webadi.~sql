--delete webadi
SELECT biv.*
  FROM bne_integrators_b biv
 WHERE 1 = 1
   AND biv.integrator_code LIKE 'ITMFRCST%' FOR UPDATE;

SELECT *
  FROM bne_interfaces_b inf
 WHERE 1 = 1
 AND inf.interface_code LIKE 'ITMFRCST%';
 
DELETE FROM bne_interfaces_b inf --bne_interfaces_vl inf
 WHERE 1 = 1
 AND inf.interface_code LIKE 'ITMFRCST%';
 
SELECT *
  FROM bne_interfaces_tl inf --bne_interfaces_vl inf
 WHERE 1 = 1
 AND inf.interface_code LIKE 'ITMFRCST%';
 
 DELETE FROM bne_interfaces_tl inf --bne_interfaces_vl inf
 WHERE 1 = 1
 AND inf.interface_code LIKE 'ITMFRCST%';
   
   
CREATE TABLE bne_interfaces171208
AS
SELECT *
  FROM bne_interfaces_b inf --bne_interfaces_vl inf
 WHERE 1 = 1
 --AND inf.creation_date  > SYSDATE - 5;
   AND inf.integrator_code = 'ITMFRCST_XINTG';
   
SELECT * FROM bne_interfaces171208;

DELETE FROM bne_interfaces_b inf --bne_interfaces_vl inf
 WHERE 1 = 1
 AND inf.integrator_code = 'ITMFRCST_XINTG';

SELECT /*bic.required_flag,bic.read_only_flag,*/ bic.*
  FROM bne_interface_cols_b bic
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%' FOR UPDATE;
   
   
   
UPDATE bne_interface_cols_b bic
SET bic.required_flag = 'Y'
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%';
   
   
   -------Action Type

SELECT bic.required_flag,
       bic.display_flag,
       bic.default_type,
       bic.default_value,
       bic.*
  FROM bne_interface_cols_b bic
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%'
   AND bic.interface_col_name IN
      
       ('P_PROCESS_FLAG',
        'P_ERROR_MESSAGE',
        'P_TRANSACTION_ID',
        'P_INVENTORY_ITEM_ID',
        'P_BUCKET_TYPE',
        'P_ORGANIZATION_ID');
        
UPDATE bne_interface_cols_b bic
SET bic.required_flag = 'Y',
       bic.display_flag = 'Y',
       bic.default_type = '',
       bic.default_value = '',
       bic.read_only_flag = 'N'
        WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%'
   AND bic.interface_col_name IN
      
       ('P_TRANSACTION_ID');
       
 
--Update Action Type
UPDATE bne_interface_cols_b bic
SET bic.default_type = 'PARAMETER',
bic.default_value = 'DOCP_ACTION_TYPE'
 WHERE 1 = 1
 AND bic.interface_col_name = 'P_ACTION_TYPE'
   AND bic.interface_code LIKE 'ITMFRCST%'; 


   
   
DELETE FROM bne_interface_cols_b bic
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%';
   
SELECT *
  FROM bne_interface_cols_tl bic
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%';
   
DELETE  FROM bne_interface_cols_tl bic
 WHERE 1 = 1
   AND bic.interface_code LIKE 'ITMFRCST%';

SELECT *
  FROM bne_param_lists_b bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST%';
   
DELETE FROM bne_param_lists_b bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST%';
   
SELECT *
  FROM bne_param_lists_tl bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST%';
   
DELETE  FROM bne_param_lists_tl bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST%';
   
  
/*   
   attribute_app_id : 20006
   attribute_code   : GENERAL_281_P0_ATT
*/

SELECT *
  FROM bne_param_list_items bpli
 WHERE 1 = 1
   AND bpli.application_id = 20009
   AND bpli.param_list_code LIKE 'ITMFRCST%'
 ORDER BY bpli.param_list_code,
          bpli.sequence_num;
          
DELETE FROM bne_param_list_items bpli
 WHERE 1 = 1
   AND bpli.application_id = 20009
   AND bpli.param_list_code LIKE 'ITMFRCST%';

SELECT *
  FROM bne_attributes ba
 WHERE 1 = 1
   AND ba.application_id = 20009
   AND ba.attribute_code LIKE 'ITMFRCST%' /*'GENERAL_281_P0_ATT'*/
 ORDER BY ba.rowid;
 
DELETE  FROM bne_attributes ba
 WHERE 1 = 1
   AND ba.application_id = 20009
   AND ba.attribute_code LIKE 'ITMFRCST%';

SELECT *
  FROM bne_stored_sql a
 WHERE 1 = 1
   AND a.creation_date > SYSDATE - 20
   AND a.content_code LIKE '%ITMFRCST%'
   FOR UPDATE;


SELECT *
  FROM bne_stored_sql a
 WHERE 1 = 1
      --AND a.creation_date > SYSDATE -10
   AND a.content_code LIKE 'GENERAL_281%';

SELECT *
  FROM bne_param_defns_vl a, bne_param_list_items b
 WHERE a.param_defn_code = b.param_defn_code
   --AND b.param_list_code LIKE '%XXMRP%'
   AND a.application_id = b.application_id
   AND a.application_id = 20009;
   --and a.param_source='HR:Download';

SELECT *
  FROM bne_param_defns_b d
 WHERE 1 = 1
   AND d.param_defn_code LIKE '%ITMFRCST%';

DELETE FROM  bne_param_defns_b  d 
WHERE 1=1
AND d.param_defn_code LIKE '%ITMFRCST%';

SELECT *
  FROM bne_param_defns_tl d
 WHERE 1 = 1
   AND d.param_defn_code LIKE '%ITMFRCST%';

DELETE FROM  bne_param_defns_tl  d 
WHERE 1=1
AND d.param_defn_code LIKE '%ITMFRCST%';
   
   
SELECT * FROM BNE.BNE_PARAM_LISTS_TL JJ WHERE JJ.APPLICATION_ID=20009
DELETE FROM BNE.BNE_PARAM_LISTS_TL JJ WHERE JJ.APPLICATION_ID=20009

--integrator
SELECT *
  FROM bne_integrators_tl bil
 WHERE 1 = 1
   AND bil.creation_date > SYSDATE - 50;

--content
SELECT * FROM bne_contents_tl bcl
WHERE 1=1
AND bcl.creation_date > SYSDATE - 50;

--layout
SELECT * FROM bne_layouts_tl bll
WHERE 1=1
AND bll.creation_date > SYSDATE - 50;

--interface_cols
SELECT * FROM bne_interface_cols_tl bicl
WHERE 1=1
AND bicl.creation_date > SYSDATE - 50;

--bne_param_lists_b
SELECT * FROM bne_param_lists_b bplb
WHERE 1=1
AND bplb.creation_date > SYSDATE - 50;

DELETE FROM bne_param_lists_b bplb
WHERE 1=1
AND bplb.creation_date > SYSDATE - 50;


--bne_param_lists_tl
SELECT * FROM bne_param_lists_tl bpb
WHERE 1=1
AND bpb.creation_date > SYSDATE - 50;

SELECT * FROM bne_mappings_b bml
WHERE 1=1
AND bml.creation_date > SYSDATE - 50;

--bne_mappings_tl
SELECT * FROM bne_mappings_tl bml
WHERE 1=1
AND bml.creation_date > SYSDATE - 50;

SELECT * FROM BNE_INTERFACE_COLS_B

DELETE FROM bne_param_lists_b bplb
WHERE 1=1
AND bplb.param_list_code LIKE 'ITMFRCST%';

DELETE FROM bne_interface_cols_tl bic
WHERE 1=1
AND bic.interface_code LIKE 'ITMFRCST%';

DELETE FROM bne_param_lists_tl bpl
WHERE 1=1
AND bpl.param_list_code LIKE 'ITMFRCST%';


--bne_components_b --组件表
SELECT t.application_id, --组件appid
       t.component_code, --组件code
       t.param_list_app_id, --参数列表appid
       t.param_list_code, --参数列表code
       t.user_name, --组件名称
       t.*
  FROM bne_components_vl t
 WHERE 1=1
 AND t.CREATION_DATE > SYSDATE - 50;

select * from bne_param_defns_b a where UPPER(a.param_name) LIKE '%DATE%'
AND application_id IN (800, 20009) FOR UPDATE;



---component-----
SELECT *
  FROM bne_param_list_items bpli
 WHERE 1 = 1
   AND bpli.application_id = 20009
   AND bpli.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%'
 ORDER BY bpli.param_list_code,
          bpli.sequence_num FOR UPDATE;
          
DELETE FROM bne_param_list_items bpli
 WHERE 1 = 1
   AND bpli.application_id = 20009
   AND bpli.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%';
   
SELECT *
  FROM bne_param_lists_tl bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%';
   
DELETE FROM bne_param_lists_tl bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%';
   
SELECT * FROM bne_components_b bml
WHERE 1=1
AND bml.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%';
--AND bml.creation_date > SYSDATE - 20;

DELETE FROM bne_components_b bml
WHERE 1=1
AND bml.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%';

SELECT *
  FROM bne_param_lists_b bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%';
   
DELETE FROM bne_param_lists_b bpl
 WHERE 1 = 1
   --AND bpl.application_id = 20006
   AND bpl.param_list_code LIKE 'ITMFRCST_XINTG_INTF1_C%';
   
   
--paramster list------
SELECT * FROM bne_param_defns_b bpl
WHERE 1=1
AND bpl.creation_date > SYSDATE - 50;

SELECT * FROM bne_param_defns_tl bpl
WHERE 1=1
--AND bpl.param_defn_code
--AND bpl.prompt_left LIKE '%YYYYMMDD%'
AND bpl.creation_date > SYSDATE - 50;
--AND bpl.param_list_code LIKE 'ITMFRCST%';

UPDATE  bne_param_defns_tl bpl
SET bpl.prompt_left = substr(bpl.prompt_left, 1, length(bpl.prompt_left) - 12) || '(YYYYMMDD)'
WHERE 1=1
--AND bpl.param_defn_code
AND bpl.prompt_left LIKE '%YYYY-MM-DD%'
AND bpl.creation_date > SYSDATE - 20;

SELECT * FROM bne_param_lists_b bpl
WHERE 1=1
AND bpl.creation_date > SYSDATE - 20;
AND bpl.param_list_code LIKE 'ITMFRCST%';
