DECLARE
  l_currency_code VARCHAR2(10);
  l_precision     NUMBER;
  l_ext_precision NUMBER;
  l_min_acct_unit NUMBER;

  -- conversion rate
  FUNCTION get_conversion_rate(p_from_currency   IN VARCHAR2,
                               p_to_currency     IN VARCHAR2,
                               p_conversion_type IN VARCHAR2,
                               p_conversion_date IN DATE) RETURN NUMBER IS
    CURSOR cur IS
      SELECT gdr.conversion_rate
        FROM gl_daily_rates gdr
       WHERE gdr.from_currency = p_from_currency
         AND gdr.to_currency = p_to_currency
         AND gdr.status_code != 'D'
         AND gdr.conversion_type = p_conversion_type
         AND gdr.conversion_date = trunc(p_conversion_date);
    l_conversion_rate NUMBER;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_conversion_rate;
    IF cur%NOTFOUND THEN
      l_conversion_rate := NULL;
    END IF;
    CLOSE cur;
    RETURN l_conversion_rate;
  END get_conversion_rate;

BEGIN

  l_currency_code := 'USD';
  -- Call the procedure
  -- currency precision
  fnd_currency.get_info(currency_code => l_currency_code,
                        PRECISION     => l_precision,
                        ext_precision => l_ext_precision,
                        min_acct_unit => l_min_acct_unit);

  dbms_output.put_line(' l_currency_code : ' || l_currency_code);
  dbms_output.put_line(' l_precision     : ' || l_precision);
  dbms_output.put_line(' l_ext_precision : ' || l_ext_precision);
  dbms_output.put_line(' l_min_acct_unit : ' || l_min_acct_unit);

END;
