SELECT atr3.tax,
       atr3.tax_regime_code,
       atr3.tax_status_code,
       atr3.percentage_rate,
       atr3.description,
       atr3.tax_rate_code,
       atr3.tax_rate_name,
       atr3.*
  FROM zx_rates_vl atr3
 WHERE 1 = 1 /*atr3.effective_to is null
                        and */
      --AND tax = 'TH_TAX'
   --AND tax = 'SGP_TAX'
      --AND atr3.tax_rate_id = 10308
   /*AND atr3.tax_rate_code --= 'O7'
       IN ('JA', 'JI')*/
       AND atr3.tax_regime_code LIKE '%REGIME%'
       AND atr3.tax = 'CN_TAX_HKM01'
       ;
