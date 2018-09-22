--Purchasing>>Setup>>Organizations>>Purchasing Options
SELECT xxhkm_common_utl.get_ccid_segments(ood.chart_of_accounts_id, psp.accrued_code_combination_id) accrued_acc,
       xxhkm_common_utl.get_ccid_description(ood.chart_of_accounts_id, psp.accrued_code_combination_id) accrued_acc,
       
       psp.*
  FROM po_system_parameters_all psp,
       (SELECT ood1.operating_unit,
               ood1.chart_of_accounts_id
          FROM org_organization_definitions ood1
         WHERE 1 = 1
           AND nvl(ood1.operating_unit, -1) <> -1
         GROUP BY ood1.operating_unit,
                  ood1.chart_of_accounts_id) ood
 WHERE 1 = 1
   AND psp.org_id = ood.operating_unit
   AND psp.org_id = 82;

SELECT ood.operating_unit,
       ood.chart_of_accounts_id
  FROM org_organization_definitions ood
 WHERE 1 = 1
   AND nvl(ood.operating_unit, -1) <> -1
 GROUP BY ood.operating_unit,
          ood.chart_of_accounts_id; -- AND
