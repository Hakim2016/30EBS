/*CURSOR cur_goe IS*/
SELECT acct.attribute12,
       acct.account_number,
       hp.party_name,
       hp.duns_number_c legacy_customer_number,
       h_status.meaning cust_status,
       (SELECT haou.attribute3
          FROM apps.hr_all_organization_units haou
         WHERE hou.organization_id = haou.organization_id) ou_name,
       ps.party_site_number site_number,
       s_status.meaning site_status,
       ft.territory_short_name country,
       lc.address1,
       lc.address2,
       lc.address3,
       lc.city,
       lc.county,
       lc.province,
       lc.state,
       lc.postal_code,
       ps.attribute1 credit_currency,
       ps.attribute2 credit_limit,
       acct.attribute1 payment_terms_at1,
       acct.attribute6 payment_method_at6,
       acct.creation_date h_creation_date,
       ps.party_site_name,
       ps.identifying_address_flag,
       sites.creation_date s_creation_date,
       hp.party_id,
       acct.cust_account_id,
       sites.cust_acct_site_id,
       ps.party_site_id
  FROM apps.hz_parties             hp,
       apps.hz_cust_accounts       acct,
       apps.hz_cust_acct_sites_all sites,
       apps.hz_party_sites         ps,
       apps.hz_locations           lc,
       apps.hr_operating_units     hou,
       fnd_lookup_values           h_status,
       fnd_lookup_values           s_status,
       fnd_territories_vl          ft
 WHERE hp.party_id = acct.party_id
   AND acct.cust_account_id = sites.cust_account_id
   AND sites.party_site_id = ps.party_site_id(+)
   AND ps.location_id = lc.location_id(+)
   AND sites.org_id = hou.organization_id(+)
   AND acct.status = h_status.lookup_code
   AND h_status.lookup_type = 'HZ_CPUI_REGISTRY_STATUS'
   AND h_status.language = userenv('LANG')
   AND sites.status = s_status.lookup_code
   AND s_status.lookup_type = 'HZ_CPUI_REGISTRY_STATUS'
   AND s_status.language = userenv('LANG')
   AND lc.country = ft.territory_code
   AND (hp.last_update_date >= p_interface_date OR acct.last_update_date >= p_interface_date OR
       sites.last_update_date >= p_interface_date OR
       (EXISTS (SELECT 1
                   FROM apps.hz_cust_site_uses_all uses
                  WHERE uses.cust_acct_site_id = sites.cust_acct_site_id
                    AND uses.last_update_date >= p_interface_date)) OR ps.last_update_date >= p_interface_date OR
       lc.last_update_date >= p_interface_date OR
       (EXISTS (SELECT 1
                   FROM apps.hz_customer_profiles hcp,
                        apps.hz_cust_profile_amts hcpa
                  WHERE hcp.cust_account_id = acct.cust_account_id
                    AND hcp.site_use_id IS NULL
                    AND hcp.cust_account_profile_id = hcpa.cust_account_profile_id
                    AND (hcp.last_update_date >= p_interface_date OR hcpa.last_update_date >= p_interface_date))));
