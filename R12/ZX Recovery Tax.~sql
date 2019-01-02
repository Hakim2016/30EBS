
SELECT t.responsibility_id, tl.responsibility_name, tl.language, t.*
  FROM fnd_responsibility t, fnd_responsibility_tl tl
 WHERE 1 = 1
   AND t.responsibility_id = tl.responsibility_id
   AND tl.language = 'US'
      --AND t.responsibility_key LIKE --'%HBS%SCM_SUPER_USER%'
      --'COST%MANAGEMENT%'
   AND tl.responsibility_name LIKE 'ALL' --'Cost Management%SLA'
;
--HEA SCM SUPER USER

SELECT * FROM fnd_user fu WHERE fu.user_name = 'HAND_MT';
--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86
/*
BEGIN
  fnd_global.apps_initialize(user_id      => 9221,
                             resp_id      => 50947,
                             resp_appl_id => 235);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);

END;*/

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_short_name = 'ZX';

SELECT DISTINCT ratetleo.tax_rate_code,
                ratetleo.tax,
                ratetleo.tax_regime_code,
                ratetleo.recovery_type_code,
                fnd.meaning AS recoverytype,
                ratetleo.content_owner_name AS contentowner,
                ratetleo.content_owner_id,
                decode(ratetleo.update_access,
                       'Y',
                       'UpdateEnabled',
                       'UpdateDisabled') AS update_switch,
                regimes_hzgeotypes.geography_type,
                regimes_hzgeographies.geography_name,
                fnd_territories_vl.territory_short_name AS countrycode
  FROM zx_mco_eo_rates_v     ratetleo,
       fnd_lookups           fnd,
       fnd_territories_vl,
       hz_geographies        regimes_hzgeographies,
       hz_geography_types_vl regimes_hzgeotypes,
       zx_regimes_vl         regimetleo
 WHERE regimetleo.tax_regime_code = ratetleo.tax_regime_code
 AND regimes_hzgeographies.geography_name = 'China'
      --AND upper(ratetleo.tax_regime_code) LIKE 'CN-Tax'--:1
      --AND upper(ratetleo.tax_rate_code) LIKE :2
      --AND upper(ratetleo.tax) LIKE :3
   AND ratetleo.recovery_type_code = fnd.lookup_code
   AND fnd.lookup_type = 'ZX_RECOVERY_TYPES'
   AND SYSDATE BETWEEN fnd.start_date_active AND
       nvl(fnd.end_date_active, SYSDATE)
   AND nvl(fnd.enabled_flag, 'N') = 'Y'
   AND ratetleo.rate_type_code = 'RECOVERY'
   AND fnd_territories_vl.territory_code(+) = regimetleo.country_code
   AND ratetleo.active_flag = 'Y' /*
   AND upper(ratetleo.content_owner_name) LIKE :4
   AND regimetleo.geography_type = regimes_hzgeotypes.geography_type(+)
   AND regimes_hzgeotypes.geography_type(+) = :5
   AND regimetleo.geography_id = regimes_hzgeographies.geography_id(+)
   AND regimes_hzgeographies.geography_name(+) = :6
   AND ((:7 IS NOT NULL AND regimetleo.country_code = :8) OR
       (:9 IS NULL AND regimes_hzgeotypes.geography_type =
       regimes_hzgeographies.geography_type))*/
