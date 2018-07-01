     SELECT   conversion_rate
     --INTO     rate
     FROM   GL_DAILY_RATES
     WHERE  1=1
     --from_currency = --l_from_currency
     AND  to_currency = 'SGD'--l_to_currency
     AND  conversion_date = to_date('2018-04-30','yyyy-mm-dd')--trunc(x_conversion_date)
     AND  conversion_type = 'Corporate';--x_conversion_type;
     
     
                   gl_currency_api.convert_amount(poh.currency_code,
                                             'SGD',
                                             parameters.p_end_date - 1, --pda.creation_date, -- p_conversion_date,
                                             'Corporate',
                                             pol.unit_price *
                                             pda.quantity_ordered)) po_amount_sgd
