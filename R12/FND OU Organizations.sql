--Business Group
SELECT v.organization_id,
       v.business_group_id,
       v.name,
       v.location_code,
       v.type,
       v.organization_type,
       
       v.*
  FROM hr_organization_units_v v
 WHERE 1 = 1
   AND v.organization_id = v.business_group_id
   ORDER BY v.organization_id;

SELECT * FROM org_organization_definitions ood;

--HOU
SELECT *
  FROM hr_operating_units hou
 WHERE 1 = 1
 ORDER BY hou.business_group_id;

SELECT v.organization_id,
       v.business_group_id,
       v.name,
       v.type,
       v.organization_type,
       
       v.*
  FROM hr_organization_units_v v
 WHERE 1 = 1
 ORDER BY v.organization_id DESC;

SELECT *
  FROM hz_parties hp
 WHERE 1 = 1
      --AND hp.party_name LIKE '%HAKIM%'
   AND hp.last_updated_by = 1014703;

--Vision China
/*
organization_id 4555
*/

SELECT *
  FROM ra_customer_trx_all rct
 WHERE 1 = 1
   AND rct.org_id = 4555;
