--param1-in using
--------2018-1-3
SELECT mfd.organization_id,
       mfd.transaction_id,
       mfd.inventory_item_id,
       mfd.concatenated_segments item_number,
       des.forecast_set forecast,
       mfd.forecast_designator forecast_designator,
       mfd.forecast_date,
       mfd.rate_end_date,
       mfd.current_forecast_quantity,
       mfd.bucket_type,
       decode(mfd.bucket_type, 1, 'Days', 2, 'Weeks', 3, 'Periods') buckets,
       mfd.comments comments
  FROM mrp_forecast_dates_v     mfd,
       mrp_forecast_designators des,
       fnd_user                 fu
 WHERE 1 = 1
   AND fu.user_id = mfd.created_by
   AND des.forecast_designator = mfd.forecast_designator
   AND mfd.organization_id =
       (SELECT ood.ORGANIZATION_ID
          FROM org_organization_definitions ood
         WHERE 1 = 1
           AND ood.organization_name = nvl(TRIM($param$.SHE_FAC_ORG), ood.organization_name))
   AND des.forecast_set = nvl(TRIM($param$.DOCP_FORECAST_SET), des.forecast_set)
   AND mfd.forecast_designator = nvl(TRIM($param$.DOCP_FORECAST), mfd.forecast_designator) --'SHE-FAC' --to modify
   AND mfd.concatenated_segments = nvl(TRIM($param$.DOCP_ITEM), mfd.concatenated_segments)
   AND mfd.creation_date >= to_date(nvl(TRIM($param$.DOCP_CREATE_DATE_FR), '20140613'), 'yyyymmdd')
   AND mfd.creation_date <=
       to_date(nvl(TRIM($param$.DOCP_CREATE_DATE_TO), to_char(SYSDATE, 'yyyymmdd')), 'yyyymmdd') + 0.99999
   AND mfd.last_update_date >= to_date(nvl(TRIM($param$.DOCP_LST_UPDT_FR), '20140613'), 'yyyymmdd')
   AND mfd.last_update_date <=
       to_date(nvl(TRIM($param$.DOCP_LST_UPDT_TO), to_char(SYSDATE, 'yyyymmdd')), 'yyyymmdd') + 0.99999
   AND fu.user_name = nvl(TRIM($param$.DOCP_CREATE_BY), fu.user_name)
