SELECT * FROM zx_regimes_b zrb WHERE 1 = 1;

SELECT * FROM zx.zx_taxes_b# zt WHERE 1 = 1;
SELECT *
  FROM zx_taxes_b zt
 WHERE 1 = 1
   AND zt.effective_to IS NULL;

SELECT * FROM zx_status_b zs WHERE 1 = 1;

SELECT *
  FROM --ZX_JURISDICTIONS_VL
       zx_jurisdictions_b zj
 WHERE 1 = 1;

SELECT *
  FROM --zx.ZX_RECOVERY_TYPES_B# 
       --ZX_RECOVERY_TYPES_VL
        zx.zx_recovery_types_tl zr
 WHERE 1 = 1;

SELECT *
  FROM zx_determining_factors_b zdf
 WHERE 1 = 1
   AND zdf.determining_factor_code;

SELECT
--zrb.
 zrb.*
  FROM zx_rules_b zrb
 WHERE 1 = 1
   AND zrb.tax_rule_code = 'XXHKM_AR_DM_RULE';

SELECT * from ZX_CONDITIONS zc
 where 1=1 
 --AND zc.DETERMINING_FACTOR_CODE LIKE '%DF'
 zc.c
 ;
