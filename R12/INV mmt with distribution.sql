SELECT *
  FROM cst_inv_distribution_v cid
 WHERE 1 = 1
   AND cid.transaction_id = 54896869;

SELECT *
  FROM gl_code_combinations gcc
 WHERE 1 = 1
   AND gcc.code_combination_id = 1246380--3043
   
   ;

SELECT cid.transaction_id,
       cid.transaction_type_id,
       cid.organization_id,
       cid.reference_account,
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
   AND gcc.code_combination_id(+) = cid.reference_account
   AND cid.line_type_name = 'Cost variance'
   AND cid.transaction_id -->= 54896869
       = 48624778
      --IN(38434933/*, 38434935*/)
      --AND cid.transaction_type_name = 'Project Receipt'
   AND cid.transaction_type_id = 36 --112
   AND cid.organization_id = 121
   AND rownum = 1
 ORDER BY cid.transaction_id;

SELECT xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, gcc.code_combination_id),
       gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' ||
       gcc.segment6,
       gcc.*
  FROM gl_code_combinations gcc
 WHERE 1 = 1
      /*AND xla_oa_functions_pkg.get_ccid_description(gcc.chart_of_accounts_id, gcc.code_combination_id) =
      'HL00.000.5120010011.5220200000.0.0.0'*/
   AND gcc.segment1 = 'HL00'
   AND gcc.segment3 = '5120010011';
