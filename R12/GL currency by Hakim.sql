--GL currency

SELECT * --gdr.conversion_rate
  FROM apps.gl_daily_rates gdr
 WHERE gdr.from_currency = 'USD' --p_from_currency
   AND gdr.to_currency = 'CNY' --p_to_currency
   AND gdr.status_code != 'D'
      AND gdr.conversion_type = 'Corporate'--p_conversion_type
   AND gdr.conversion_date <= to_date('30-NOV-2018', 'DD-MM-YYYY') --trunc(p_conversion_date);
ORDER BY gdr.conversion_date desc

;
