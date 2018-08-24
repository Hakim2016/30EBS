--XXGL_EXCHANGE_RATE_INBOUND_PKG;--.hfg_main
/*
XXGLB006
IF68
XXGL:Exchange Rate Inbound to HFG
XXGL_EXCH_RATE_INBOUND_INT
*/

SELECT /*intf.creation_date,
       intf.valid_from_date,
       intf.process_status,
       --intf.process_message,
       intf.from_currency,
       intf.to_currency,*/
 intf.*
  FROM xxgl_exch_rate_inbound_int intf
 WHERE 1 = 1
      --AND intf.creation_date >= trunc(SYSDATE)-1
   AND intf.valid_from = '20180731'
   AND intf.exch_rate_type = 'M' --'Z'--'M'
--AND intf.process_status <> 'E'
 ORDER BY intf.group_id DESC,
          intf.unique_id;

SELECT intf.group_id,
       intf.valid_from,
       to_char(to_date(intf.valid_from, 'yyyymmdd'), 'day') week,
       intf.exch_rate_type,
       COUNT(*)
--intf.*
  FROM xxgl_exch_rate_inbound_int intf
 WHERE 1 = 1
   --AND intf.creation_date >= trunc(SYSDATE) - 60
--AND intf.valid_from = '20180731'
AND intf.exch_rate_type = 'Z'--'Z'--'M'
--AND intf.process_status <> 'E'
 GROUP BY intf.group_id,
          intf.valid_from,
          intf.exch_rate_type
 ORDER BY intf.valid_from DESC,
          intf.exch_rate_type;

SELECT *
  FROM apps.gl_daily_rates

 WHERE conversion_date = --to_date('2018-08-01','YYYY-MM-DD')
       to_date('2018-07-25', 'YYYY-MM-DD');

SELECT gdr.conversion_date,
       --decode(gdr.conversion_type, '1021', 'Z Rate', '1001', 'SHEAP', '1002', 'SHEAR', gdr.conversion_type) TYPE,
       gdr.creation_date,
       to_char(gdr.conversion_date, 'day') weekday,
       COUNT(*)
  FROM gl_daily_rates gdr
 WHERE 1 = 1
   AND gdr.conversion_date >= to_date('2018-07-01', 'YYYY-MM-DD')
 GROUP BY gdr.conversion_date
          --,gdr.conversion_type
         ,
          gdr.creation_date
 ORDER BY gdr.conversion_date DESC;
