select * from apps.cux_fnd_operating_units_v hou;

select * from apps.org_organization_definitions ood;

--INV
SELECT oap.organization_id "Organization ID",
ood.organization_name,
       mp.organization_code "Organization Code",
       oap.period_name "Period Name",
       oap.period_start_date "Start Date",
       oap.period_close_date "Closed Date",
       decode(oap.open_flag,
              'P',
              'P - Period Close is processing',
              'N',
              'N - Period Close process is completed',
              'Y',
              'Y - Period is open if Closed Date is NULL',
              'Unknown') "Period Status",
              mp.*
  FROM apps.org_acct_periods oap,
       apps.mtl_parameters   mp,
       apps.org_organization_definitions ood
            --org_organization_definitions
 WHERE oap.organization_id = mp.organization_id
 and ood.organization_id = oap.organization_id
   --AND trunc(period_start_date) > SYSDATE - 40 --adjust date as needed
   --AND trunc(period_start_date) < SYSDATE + 1
   and ood.organization_name like '%ZJ%'
   AND oap.period_start_date =  to_date('2018-10-01','yyyy-mm-dd')
   and oap.period_close_date is null
 ORDER BY oap.organization_id,
          oap.period_start_date;
