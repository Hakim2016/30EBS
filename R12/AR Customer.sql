
/*BEGIN
  fnd_global.apps_initialize(user_id => 2722, resp_id => 50676, resp_appl_id => 660);
    mo_global.init('PO');

END;*/


SELECT terr.territory_short_name region,
       cust.account_number,
       party.party_name customer_name,
       cust.attribute5 customer_code,
       gcck.segment3 acct_code,
       cust.creation_date,
       cust.attribute6 payment_method,
       cust.attribute1 payment_terms,
       (SELECT SUM(xxar_utils.convert_amount(xxh.currency_code,
                                             xxpa_utils.get_currency_code,
                                             xxh.invoice_date,
                                             ooh.conversion_type_code,
                                             xxar_hea_tax_invoice_pvt.get_header_invoiced_amount(xxh.header_id)))
          FROM xxar_tax_invoice_headers_all xxh,
               oe_order_headers_all         ooh
         WHERE xxh.customer_id = cust.cust_account_id
           AND xxh.oe_header_id = ooh.header_id
           AND xxh.invoice_date BETWEEN to_date('2015/04/01','YYYY/MM/DD') AND to_date('2016/03/31','YYYY/MM/DD')) sale_amount

  FROM hz_cust_accounts         cust,
       hz_parties               party,
       hz_cust_acct_sites_all   acct_site,
       hz_party_sites           party_site,
       hz_locations             lc,
       fnd_territories_vl       terr,
       hz_cust_site_uses_all    site_uses,
       gl_code_combinations_kfv gcck
 WHERE cust.cust_account_id = acct_site.cust_account_id
 --AND acct_site.org_id = 82
   AND cust.party_id = party.party_id
   AND acct_site.party_site_id = party_site.party_site_id
   AND party_site.location_id = lc.location_id
   AND terr.territory_code = lc.country
   AND cust.account_number = 'HL00000020'--'FB00000222'
   AND acct_site.cust_acct_site_id = site_uses.cust_acct_site_id(+)
   AND site_uses.gl_id_rec = gcck.code_combination_id(+)
   AND 'A' = site_uses.status(+)
   AND acct_site.status = 'A'
   AND cust.status = 'A';

SELECT hca.account_number,
       hca.last_update_date,
       hca.payment_term_id,
       hca.last_updated_by,
       hp.duns_number_c,
       --LENGTH(hp.duns_number_c),
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
      --AND hp.party_name LIKE '%INDIABULLS REAL ESTATE%'
   --AND hca.account_number
   --IN ('FB00000586')
      --LIKE 'FB%'
       --IN ('FB00000575', 'FB00000580', 'FB00000581','FB00000573')
--IN('FB00011339','FB00011611','FB00011784','FB00011171','FB00218573','FB00220047','FB00222032','FB00222530','FB00241561','FB00241958','FB00241965','FB00241967','FB00241978','FB00218509','FB00218511','FB00218512','FB00218514','FB00218547','FB00218552','FBC0000001','FB00266571','FB00271476','FB00271832','FB00277217','FB00277225','FB00277339','FB00283597','FB00287206','FB00302440','FB00341790','FB00342779','FB00353309','FBC0000002','FB00000243','FB00000244','FB00000245','FB00000002','FB00000022','FB00000030','FB00000031','FB00000068','FB00000077','FB00000078','FB00000095','FB00000098','FB00000102','FB00000106','FB00000108','FB00000115','FB00000121','FB00000128','FB00000133','FB00000136','FB00000147','FB00000151','FB00000167','FB00000172','FB00000175','FB00000183','FB00000193','FB00000200','FB00000205','FB00000223','FB00000224','FB00000239','FB00094163','FB00102506','FB00102761','FB00011788','FB00085210','FB00087924','FB00089429','FB00092102','FB00261570','FB00261578','FB00241983','FB00242005','FB00242056','FB00242304','FB00247468','FB00253895','FB00256062','FB00256106','FB00256377','FB00258037','FB00258315','FB00259296','FB00259312','FB00259315','FB00260683','FB00260690','FB00260711','FB00260715','FB00260757','FB00260803','FB00261554','FBC0000006','FB00000268','FB00000275','FB00000279','FB00000281','FB00000282','FB00000287','FB00000289','FB00000291','FB00000294','FB00000295','FB00000297','FB00000298','FB00000299','FB00000301','FB00000246','FB00000251','FB00209977','FB00210050','FB00210058','FB00210077','FB00210103','FB00210946','FB00211015','FB00211878','FB00211974','FB00212187','FB00201097','FB00201405','FB00201498','FB00202368','FB00204486','FB00209960','FB00209973','FB00262659','FB00263006','FB00263252','FB00261599','FB00261694','FB00261699','FB00262181','FB00262218','FB00262224','FB00262229','FB00262237','FB00262240','FB00262413','FB00000407','FB00000413','FB00000416','FB00000434','FB00000441','FB00000453','FB00000462','FB00000485','FB00000504','FB00000509','FB00000510','FB00000514','FB00000525','FB00000533','FB00000538','FB00000539','FB00000543','FB00000560','FB00000562','FB00000566','FB00000572','FB00000573','FB00010712','FB00011060','FB00000302','FB00000303','FB00000313','FB00000315','FB00000323','FB00000325','FB00000348','FB00000366','FB00000399','FB00000403','FB00000404','FB00214022','FB00217476','FB00218495','FB00218496','FB00218501','FB00218255','FB00212442','FB00213106','FB00266514','FB00266522','FB00263372','FB00263673','FB00263683','FB00263691','FB00263700','FB00263705','FB00263732','FB00263757','FB00263759','FB00263765','FB00263773','FB00263775','FB00263781','FB00263787','FB00263789','FB00263847','FB00263848','FB00263849','FB00263855','FB00263865','FB00263878','FB00263881','FB00263943')
--= 'FB00342779'--'HL00000192'--'HL00000184'
--IN ('HL00000184', 'HL00000168', 'HL00000158', 'HL00000146', 'HL00000140', 'HL00000038')
--AND hp.duns_number_c IS NOT NULL
--AND LENGTH(hp.duns_number_c) < 10
--AND hp.party_name = 'HITACHI BUILDING SYSTEMS CO. LTD'
--AND ROWNUM < 100
ORDER BY hca.CUST_ACCOUNT_ID DESC
;

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
