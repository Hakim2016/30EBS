/*CREATE OR REPLACE VIEW XXOM_LC_MAINTENANCE_V AS*/
SELECT m.line_id                      AS  line_id,
       m.rowid                        AS  row_id,
       m.org_id                       AS  org_id,
       hou.name                       AS  org_name,
       m.customer_id                  AS  customer_id,
       m.so_header_id                 AS  so_header_id,
       m.lc_number                    AS  lc_number,
       m.issue_bank                   AS  issue_bank,
       hp.party_name                  AS  customer_name,
       hca.account_number             AS  customer_number,
       ooh.order_number               AS  order_number,
       m.amount                       AS  amount,
       m.currency_code                AS  currency_code,
       m.issue_date                   AS  issue_date,
       m.expire_date                  AS  expire_date,
       m.lastest_shipment_date        AS  lastest_shipment_date,
       m.final_shipment_date          AS  final_shipment_date,
       u.user_name                    AS  creator,
       rs.name                        AS  sales_person,
       m.remark                       AS  remark,
       m.salesrep_id                  AS  salesrep_id,
       m.program_application_id       AS  program_application_id,
       m.program_id                   AS  program_id,
       m.program_update_date          AS  program_update_date,
       m.request_id                   AS  request_id,
       m.attribute_category           AS  attribute_category,
       m.enabled_flag                 AS  enabled_flag,
       m.creation_date                AS  creation_date,
       m.created_by                   AS  created_by,
       m.last_update_date             AS  last_update_date,
       m.last_updated_by              AS  last_updated_by,
       m.last_update_login            AS  last_update_login,
       m.attribute1                   AS  attribute1,
       m.attribute2                   AS  attribute2,
       m.attribute3                   AS  attribute3,
       m.attribute4                   AS  attribute4,
       m.attribute5                   AS  attribute5,
       m.attribute6                   AS  attribute6,
       m.attribute7                   AS  attribute7,
       m.attribute8                   AS  attribute8,
       m.attribute9                   AS  attribute9,
       m.attribute10                  AS  attribute10,
       m.attribute11                  AS  attribute11,
       m.attribute12                  AS  attribute12,
       m.attribute13                  AS  attribute13,
       m.attribute14                  AS  attribute14,
       m.attribute15                  AS  attribute15

  FROM xxom_lc_maintenance        m,
       hr_all_organization_units  hou,
       hz_cust_accounts           hca,
       hz_parties                 hp,
       oe_order_headers_all       ooh,
       fnd_user                   u,
       ra_salesreps               rs

 WHERE m.org_id       =  hou.organization_id
   AND m.customer_id  =  hca.cust_account_id
   AND hca.party_id   =  hp.party_id
   AND m.so_header_id =  ooh.header_id
   AND m.created_by   =  u.user_id
   AND m.org_id       =  rs.org_id(+)
   AND m.salesrep_id  =  rs.salesrep_id(+);
