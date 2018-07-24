SELECT hca.last_update_date,
       hca.payment_term_id,
       hca.last_updated_by,
       hp.last_update_date,
       hp.last_updated_by,
       hca.cust_account_id,
       hca.account_number,
       hca.customer_type,
       hca.status,
       hca.object_version_number,
       hp.party_name,
       hp.party_id,
       hp.object_version_number party_object_version_number,
       hp.*,
       hca.*
  FROM hz_cust_accounts hca,
       hz_parties       hp
 WHERE hp.party_id = hca.party_id
      --AND hca.cust_account_id = 84040
   AND hca.account_number --= 'HL00000184'
       IN ('HL00000184', 'HL00000168', 'HL00000158', 'HL00000146', 'HL00000140', 'HL00000038');

SELECT hp_per.party_number,
       hp_per.party_name,
       hp_per.person_first_name,
       hp_per.person_last_name,
       rol.cust_account_id,
       rol.cust_acct_site_id
  FROM hz_cust_account_roles rol,
       hz_parties            hp_rel,
       hz_relationships      rel,
       hz_parties            hp_per
 WHERE rol.party_id = hp_rel.party_id
   AND hp_rel.party_id(+) = rel.party_id
      --AND rel.object_type = 'PERSON'
      --AND rel.relationship_code = 'CONTACT'
   AND rel.object_id = hp_per.party_id
--AND rol.cust_account_id = 1242557
--AND hp_rel.party_number = 'HL00000184';
--AND rol.cust_acct_site_id IS NOT NULL
;
