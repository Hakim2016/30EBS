/*CURSOR cur_hfg IS*/
SELECT acct.attribute5,
       acct.account_number,
       hp.party_name,
       hp.duns_number_c legacy_customer_number,
       h_status.meaning cust_status,
       hou.name ou_name,
       ps.party_site_number site_number,
       s_status.meaning site_status,
       lc.country country_code,
       ft.territory_short_name country,
       lc.address1,
       lc.address2,
       lc.address3,
       lc.city,
       lc.county,
       lc.province,
       lc.state,
       lc.postal_code,
       lc.last_update_date,
       lc.location_id,
       uses.site_use_code business_purposes,
       uses.tax_code tax,
       xhs.company_code,
       decode(upper(gl.name), 'SHE LEDGER', 'R1', 'HET LEDGER', 'R1', NULL) wht_type,
       decode(upper(gl.name), 'SHE LEDGER', 'X', 'HET LEDGER', 'X', NULL) wht_agent,
       decode(upper(gl.name), 'SHE LEDGER', '20120101', 'HET LEDGER', '20120101', NULL) wht_from,
       decode(upper(gl.name), 'SHE LEDGER', '99991231', 'HET LEDGER', '99991231', NULL) wht_until,
       gcc.segment3,
       rt.segment1 || '.' || rt.segment2 sales_territory,
       (SELECT DISTINCT res.resource_name
          FROM jtf_rs_salesreps         jrs,
               jtf_rs_resource_extns_vl res
         WHERE jrs.resource_id = res.resource_id(+)
           AND jrs.salesrep_id = uses.primary_salesrep_id
           AND rownum = 1) sales_person,
       rtt.name payment_terms,
       ship_method.meaning ship_method,
       hp.party_id,
       sites.org_id,
       acct.cust_account_id,
       sites.cust_acct_site_id,
       ps.party_site_id,
       uses.site_use_id,
       /*greatest(hp.last_update_date,
                acct.last_update_date,
                sites.last_update_date,
                uses.last_update_date,
                ps.last_update_date,
                lc.last_update_date,
                nvl(get_site_cont_last_update(ps.party_site_id, 'PHONE', 'GEN'), hp.last_update_date),
                nvl(get_site_cont_last_update(ps.party_site_id, 'PHONE', 'FAX'), hp.last_update_date),
                nvl(get_site_cont_last_update(ps.party_site_id, 'PHONE', 'MOBILE'), hp.last_update_date),
                nvl(get_site_email_last_update(ps.party_site_id), hp.last_update_date)) cust_last_update_date,*/
       (SELECT MAX(unique_id)
          FROM xxar_cust_to_hfg_int xcth
         WHERE xcth.customer_number = acct.account_number
           AND xcth.site_use_id = uses.site_use_id) unique_id,
       ps.attribute3 tax_id,
       ps.attribute4 branch_number,
       ps.attribute5 branch_code

  FROM apps.hz_parties             hp,
       apps.hz_cust_accounts       acct,
       apps.hz_cust_acct_sites_all sites,
       apps.hz_cust_site_uses_all  uses,
       apps.hz_party_sites         ps,
       apps.hz_locations           lc,
       apps.hr_operating_units     hou,
       fnd_lookup_values           h_status,
       fnd_lookup_values           s_status,
       fnd_territories_vl          ft,
       gl_code_combinations        gcc,
       xxgl_hfs_system_options     xhs,
       gl_ledgers                  gl,
       ra_territories              rt,
       ra_terms_tl                 rtt,
       fnd_lookup_values           ship_method
 WHERE hp.party_id = acct.party_id
   AND acct.cust_account_id = sites.cust_account_id
   AND sites.cust_acct_site_id = uses.cust_acct_site_id(+)
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
   AND to_number(hou.set_of_books_id) = xhs.ledger_id
   AND xhs.ledger_id = gl.ledger_id
   AND nvl(xhs.inactive_date, SYSDATE + 1) >= SYSDATE
   AND uses.gl_id_rec = gcc.code_combination_id(+)
   AND uses.territory_id = rt.territory_id(+)
   AND uses.payment_term_id = rtt.term_id(+)
   AND rtt.language(+) = userenv('LANG')
   AND uses.ship_via = ship_method.lookup_code(+)
   AND ship_method.lookup_type(+) = 'SHIP_METHOD'
   AND ship_method.language(+) = userenv('LANG')
   AND uses.site_use_code = 'BILL_TO'
   AND uses.primary_flag = 'Y'
   AND gl.name = 'HBS Ledger'--2041--p_ledger
   AND acct.status = 'A'
   AND sites.status = 'A'
   AND acct.account_number LIKE 'HL%27'
  /* AND greatest(hp.last_update_date,
                acct.last_update_date,
                sites.last_update_date,
                uses.last_update_date,
                ps.last_update_date,
                lc.last_update_date,
                nvl(xxar_cust_to_hfg_pkg.get_site_cont_last_update(ps.party_site_id, 'PHONE', 'GEN'),
                    hp.last_update_date),
                nvl(xxar_cust_to_hfg_pkg.get_site_cont_last_update(ps.party_site_id, 'PHONE', 'FAX'),
                    hp.last_update_date),
                nvl(xxar_cust_to_hfg_pkg.get_site_cont_last_update(ps.party_site_id, 'PHONE', 'MOBILE'),
                    hp.last_update_date),
                nvl(xxar_cust_to_hfg_pkg.get_site_email_last_update(ps.party_site_id), hp.last_update_date)) BETWEEN
       p_date_from AND p_date_to
       */
       ;
       
CREATE TABLE hz_locations_20181207_1
AS
SELECT * FROM apps.hz_locations lc WHERE 1=1 AND lc.location_id = 38783;

SELECT * FROM hz_locations_20181207_1 WHERE 1=1 ;--AND 

