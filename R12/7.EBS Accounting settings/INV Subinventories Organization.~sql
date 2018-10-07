--INV>>Setup>>Organizations>>Subinventories

SELECT sec.organization_id,
       sec.secondary_inventory_name,
       sec.description,
       sec.status_code,
       sec.default_cost_group_name,
       sec.material_account,
       sec.outside_processing_account,
       sec.material_overhead_account,
       sec.overhead_account,
       sec.resource_account,
       sec.expense_account,
       sec.encumbrance_account,
       xla_oa_functions_pkg.get_ccid_description(ood.chart_of_accounts_id, sec.material_account) account_desc,
       xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, sec.material_account) account_segs

  FROM mtl_secondary_inventories_fk_v sec,
       org_organization_definitions   ood
 WHERE 1 = 1
   AND sec.organization_id = ood.organization_id
   AND sec.organization_id = 83 --121
   
--AND sec.secondary_inventory_name IN ('RM', '')

;

SELECT *
  FROM org_organization_definitions ood
 WHERE 1 = 1;
SELECT *
  FROM gl_code_combinations gcc
 WHERE 1 = 1
   AND gcc.code_combination_id = 1009;
