SELECT ood.organization_code orga,
       ccga.organization_id orga_id,
       ccg.multi_org_flag multi_org,
       decode(ccg.cost_group_type,3,'Inventory',1,'Project',ccg.cost_group_type) typ,
       ccg.cost_group,
       ccga.material_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.material_account) material_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.material_account) material_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.material_account) material_account,
       ccga.material_overhead_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.material_overhead_account) material_overhead_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.material_overhead_account) material_overhead_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.material_overhead_account) material_overhead_account,
       ccga.resource_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.resource_account) resource_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.resource_account) resource_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.resource_account) resource_account,
       ccga.outside_processing_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.outside_processing_account) outside_processing_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.outside_processing_account) outside_processing_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.outside_processing_account) outside_processing_account,
       ccga.overhead_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.overhead_account) overhead_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.overhead_account) overhead_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.overhead_account) overhead_account,
       ccga.expense_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.expense_account) expense_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.expense_account) expense_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.expense_account) expense_account,
       ccga.average_cost_var_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.average_cost_var_account) average_cost_var_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.average_cost_var_account) average_cost_var_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.average_cost_var_account) average_cost_var_account,
       ccga.encumbrance_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.encumbrance_account) encumbrance_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.encumbrance_account) encumbrance_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.encumbrance_account) encumbrance_account,
       ccga.purchase_price_var_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.purchase_price_var_account) purchase_price_var_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.purchase_price_var_account) purchase_price_var_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.purchase_price_var_account) purchase_price_var_account,
       ccga.payback_mat_var_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.payback_mat_var_account) payback_mat_var_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.payback_mat_var_account) payback_mat_var_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.payback_mat_var_account) payback_mat_var_account,
       ccga.payback_moh_var_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.payback_moh_var_account) payback_moh_var_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.payback_moh_var_account) payback_moh_var_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.payback_moh_var_account) payback_moh_var_account,
       ccga.payback_res_var_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.payback_res_var_account) payback_res_var_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.payback_res_var_account) payback_res_var_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.payback_res_var_account) payback_res_var_account,
       ccga.payback_osp_var_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.payback_osp_var_account) payback_osp_var_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.payback_osp_var_account) payback_osp_var_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.payback_osp_var_account) payback_osp_var_account,
       ccga.payback_ovh_var_account,
       --xxhkm_common_utl.get_acc_cate(ood.chart_of_accounts_id, ccga.payback_ovh_var_account) payback_ovh_var_account,
       --xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, ccga.payback_ovh_var_account) payback_ovh_var_account,
       --xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, ccga.payback_ovh_var_account) payback_ovh_var_account,
       
       ccg.*,
       ccga.*
  FROM cst_cost_groups_v            ccg,
       cst_cost_group_accounts      ccga,
       org_organization_definitions ood
 WHERE 1 = 1
   AND ood.organization_id = ccga.organization_id
   AND ccg.cost_group_id = ccga.cost_group_id
      --AND ccg.cost_group IN ('10101528')--('CG-1001', '10101506')
   AND ccga.organization_id = 83

;

SELECT *
  FROM cst_cost_groups_v ccg
 WHERE 1 = 1
   AND ccg.organization_id = 83;
