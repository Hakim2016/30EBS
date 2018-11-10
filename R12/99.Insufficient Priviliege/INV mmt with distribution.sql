SELECT *
  FROM cst_inv_distribution_v cid
 WHERE 1 = 1
   AND cid.transaction_id = 54896869;

SELECT *
  FROM gl_code_combinations gcc
 WHERE 1 = 1
   AND gcc.code_combination_id = 3043;

SELECT 
cid.transaction_id,
xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, gcc.code_combination_id) account_desc, --账户说明, --账户说明
       --gcc.segment1,
       --gcc.segment2,
       gcc.segment3,
       gcc.segment4,
       gcc.segment5,
       --gcc.segment6,
       cid.line_type_name,
       cid.transaction_type_name,
       cid.primary_quantity,
       cid.base_transaction_value,
       cid.basis_type_name,
       
       cid.*
  FROM cst_inv_distribution_v cid,
       gl_code_combinations   gcc
 WHERE 1 = 1
   AND gcc.code_combination_id = cid.reference_account
   AND cid.transaction_id -->= 54896869
IN(38434933/*, 38434935*/)
   --AND cid.transaction_type_name = 'Project Receipt'
   --AND cid.transaction_type_id = 112
   ORDER BY cid.transaction_id
   ;
