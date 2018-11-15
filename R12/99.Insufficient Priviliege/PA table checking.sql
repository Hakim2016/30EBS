SELECT *
  FROM pa_expenditure_items_all
 WHERE orig_transaction_reference = 20771589
   AND transaction_source = 'Work In Process';
SELECT *
  FROM cst_item_cost_details icd
 WHERE 1 = 1
   AND icd.creation_date >= to_date('20180723', 'yyyymmdd');
SELECT *
  FROM pa_transaction_interface_all pei
 WHERE 1 = 1
   AND pei.creation_date >= to_date('20180723', 'yyyymmdd');
   
SELECT *
  FROM pa_expenditure_items_all
 WHERE project_id = 949441--:p_project_id
 ;

SELECT *
  FROM pa_cost_distribution_lines_all
 WHERE project_id = 949441--:p_project_id
 ;

select * from PA_TASKS where PROJECT_ID =  	949441; 
