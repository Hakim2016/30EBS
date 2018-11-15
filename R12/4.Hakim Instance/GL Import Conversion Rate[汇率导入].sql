DECLARE
  x_msg_data             VARCHAR2(2000);
  x_msg_count            NUMBER;
  l_batch_number         NUMBER;
  l_user_conversion_type VARCHAR2(100);

  l_rate_record gl_daily_rates_interface%ROWTYPE;

BEGIN

  l_rate_record.from_currency        := 'CNY';
  l_rate_record.to_currency          := 'SGD';
  l_rate_record.from_conversion_date := trunc(SYSDATE);
  l_rate_record.to_conversion_date   := trunc(SYSDATE);
  l_rate_record.user_conversion_type := l_user_conversion_type;
  l_rate_record.conversion_rate      := 1.6;
  l_rate_record.mode_flag            := 'I';
  l_rate_record.batch_number         := l_batch_number;

  INSERT INTO gl_daily_rates_interface VALUE l_rate_record;
  /*  INSERT INTO gl_daily_rates_interface
    (from_currency,
     to_currency,
     from_conversion_date,
     to_conversion_date,
     user_conversion_type,
     conversion_rate,
     mode_flag,
     batch_number)
  VALUES
    (csr_exhange_rate.from_currency,
     csr_exhange_rate.to_currency,
     csr_exhange_rate.valid_from_date,
     csr_exhange_rate.valid_from_date,
     csr_exhange_rate.exchange_rate_type,
     csr_exhange_rate.exchange_rate,
     'I',
     l_batch_number);*/

  gl_crm_utilities_pkg.daily_rates_import(errbuf         => x_msg_data,
                                          retcode        => x_msg_count,
                                          p_batch_number => l_batch_number);

  dbms_output.put_line(' x_msg_data  : ' || x_msg_data);
  dbms_output.put_line(' x_msg_count : ' || x_msg_count);

END;
