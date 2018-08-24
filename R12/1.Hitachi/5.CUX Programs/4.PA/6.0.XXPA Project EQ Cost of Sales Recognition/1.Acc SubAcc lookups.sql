SELECT flv.meaning,
       flv.description acc,
       flv.tag         sbacc,
       flv.lookup_type
--INTO l_account, l_subaccount
  FROM fnd_lookup_values_vl flv
 WHERE flv.lookup_type = 'XXPA_SHE' || '&' || 'HET_COGS_ACCT' || '&' || 'SUBACCT'
   AND flv.enabled_flag = 'Y'
   AND nvl(flv.end_date_active, SYSDATE) >= SYSDATE
--AND flv.meaning = p_project_type
;
