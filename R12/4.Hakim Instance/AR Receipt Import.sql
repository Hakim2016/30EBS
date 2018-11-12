DECLARE
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_receipt_id    NUMBER;
  l_amount        NUMBER;
BEGIN
  fnd_global.apps_initialize(user_id      => 1393,
                             resp_id      => 50699,
                             resp_appl_id => 200);
  mo_global.set_policy_context('S', 82);
  
  ar_receipt_api_pub.create_cash(p_api_version      => 1.0,
                                 p_init_msg_list    => fnd_api.g_true,
                                 p_commit           => fnd_api.g_false,
                                 p_validation_level => fnd_api.g_valid_level_full,
                                 x_return_status    => l_return_status,
                                 x_msg_count        => l_msg_count,
                                 x_msg_data         => l_msg_data,
                                 
                                 p_currency_code        => 'SGD',
                                 p_exchange_rate_type   => '',
                                 p_exchange_rate        => NULL,
                                 p_exchange_rate_date   => NULL,
                                 p_amount               => 12121,
                                 p_receipt_number       => '2013050301',
                                 p_receipt_date         => SYSDATE - 60,
                                 p_gl_date              => SYSDATE - 60,
                                 p_customer_number      => 'FB00000224',
                                 p_customer_site_use_id => 14989,
                                 p_receipt_method_name  => 'HFA RECEIPT',
                                 p_comments             => '',
                                 p_cr_id                => l_receipt_id);

  dbms_output.put_line('  l_cash_receipt_id:' || l_receipt_id);
  dbms_output.put_line('  l_return_status:' || l_return_status);
  dbms_output.put_line('  l_msg_count:' || l_msg_count);

  IF l_msg_count > 0 THEN
    FOR i IN 1 .. l_msg_count LOOP
      dbms_output.put_line(fnd_msg_pub.get(p_msg_index => i,
                                           p_encoded   => 'F'));
    END LOOP;
  END IF;
END;
