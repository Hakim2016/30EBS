DECLARE
  l_result     BOOLEAN;
  l_request_id NUMBER;
  l_exit       BOOLEAN;
BEGIN
  l_result := fnd_request.add_layout('XXWIP', 'XXWIPR002', 'en', 'US', 'PDF');

  l_request_id := fnd_request.submit_request('XXWIP',
                                             'XXWIPR002',
                                             '',
                                             '',
                                             FALSE,
                                             :parameter.org_id,
                                             'SOS',
                                             '',
                                             userenv('sessionid'),
                                             chr(0));

  IF l_request_id > 0 THEN
    l_exit := app_form.quietcommit();
    fnd_message.clear;
    fnd_message.set_name('FND', 'CONC-REQUEST SUBMITTED');
    fnd_message.set_token('REQUEST', l_request_id);
    fnd_message.set_token('JOB', 'Stock Out Slip Print');
    fnd_message.show;
  ELSE
    fnd_message.set_string('Concurrent Request Submit Failure !');
    fnd_message.error;
    RAISE form_trigger_failure;
  END IF;
END;
