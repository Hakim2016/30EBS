--Purchasing>>Setup>>Organizations>>Receiving Options

SELECT xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, rp.receiving_account_id) receiving_account,
       xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, rp.receiving_account_id) receiving_account,
       xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, rp.clearing_account_id) clearing_account,
       xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, rp.clearing_account_id) clearing_account,
       
       rp.*
  FROM rcv_parameters               rp,
       org_organization_definitions ood
 WHERE 1 = 1
   AND rp.organization_id = ood.organization_id
   AND rp.organization_id = 83;
