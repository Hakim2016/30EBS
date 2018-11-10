SELECT psp.security_profile_name,
       psp.business_group_name,
       psp.security_profile_id,
       psp.org_security_mode,
       pso.organization_name,
       pso.organization_id,
       pso.entry_type
  FROM per_security_profiles_v      psp,
       per_security_organizations_v pso
 WHERE psp.security_profile_id = pso.security_profile_id(+)
 ORDER BY psp.security_profile_name;

