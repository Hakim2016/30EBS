/*        HZ_CUST_ACCT_SITES_ALL存了account的所有site信息，
我理解这个表是存了这些site可以有哪些作用，然后通
过其字段PARTY_SITE_ID关联到hz_party_sites, 
HZ_CUST_SITE_USES_ALL这个表是比较实用的，
好像做OM时ship_to,bill_to，最终是用的这个表里面的信息，
包括account 科目信息,这个表里面同样没有address具体信息，
是通过CUST_ACCT_SITE_ID关联到HZ_CUST_ACCT_SITES_ALL，
进而再关联到hz_party_sites->hz_locations*/
SELECT *
  FROM hz_cust_site_uses_all  hcsu,
       hz_cust_acct_sites_all hcas,
       hz_party_sites         hps
 WHERE hcsu.status = 'A'
   AND hcsu.site_use_code = 'BILL_TO'
   AND hcsu.bill_to_site_use_id = ''
   AND hcsu.
      --AND hcsu.primary_flag = 'Y'
   AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id
   AND hps.party_site_id = hcas.party_site_id
   AND hps.party_site_number = 41630
   AND hcsu.org_id = 101; --添加上OU的限制

--ALTER SESSION SET CURRENT_SCHEMA = apps; 
SELECT acct.account_number 客户编码,
       party.party_name    客户名称,
       ship_su.location    收货地点,
       ship_loc.address1   收货地址,
       bill_su.location    收单地点,
       bill_loc.address1   收单地址
  FROM hz_cust_accounts       acct,
       hz_parties             party,
       hz_cust_acct_sites_all ship_to_cust_site,
       
       hz_cust_site_uses_all  ship_su, ----ship_to
       hz_party_sites         ship_ps,
       hz_locations           ship_loc,
       hz_cust_acct_sites_all ship_cas,
       
       hz_cust_site_uses_all  bill_su, --bill_to
       hz_party_sites         bill_ps,
       hz_locations           bill_loc,
       hz_cust_acct_sites_all bill_cas

 WHERE 1 = 1
      --AND acct.account_number = '525GJ009'--'US-000002'
   AND acct.status = 'A'
   AND party.country = 'US' --美国
   AND acct.party_id = party.party_id
   AND ship_to_cust_site.cust_account_id = acct.cust_account_id
   AND ship_to_cust_site.status = 'A'
      --ship_to
   AND ship_su.site_use_code(+) = 'SHIP_TO'
   AND ship_su.cust_acct_site_id(+) = ship_to_cust_site.cust_acct_site_id
   AND ship_su.status(+) = 'A'
   AND ship_su.cust_acct_site_id = ship_cas.cust_acct_site_id(+)
   AND ship_cas.party_site_id = ship_ps.party_site_id(+)
   AND ship_loc.location_id(+) = ship_ps.location_id
   AND ship_loc.country(+) = 'US' --美国
      --bill_to  
   AND bill_su.site_use_code(+) = 'BILL_TO'
   AND bill_su.cust_acct_site_id(+) = ship_to_cust_site.cust_acct_site_id
   AND bill_su.status(+) = 'A'
   AND bill_su.cust_acct_site_id = bill_cas.cust_acct_site_id(+)
   AND bill_cas.party_site_id = bill_ps.party_site_id(+)
   AND bill_loc.location_id(+) = bill_ps.location_id
   AND bill_loc.country(+) = 'US' --美国

AND acct.account_number = 'FB00000303'--'HL00000020'--'FB00000303'
;
