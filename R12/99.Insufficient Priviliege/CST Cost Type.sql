--Cost Type
SELECT cct.cost_type,
       cct.description,
       cct.default_cost_type,
       cct.*
  FROM cst_cost_types_v cct
 WHERE 1 = 1
--AND cct.cost_type = 'GSCM_AVG'

;
