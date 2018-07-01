/*
ALTER SESSION SET nls_language = american;
*/
DECLARE
  l_result                 NUMBER;
  l_po_api_errors_rec_type po_api_errors_rec_type;
BEGIN
  fnd_global.apps_initialize(user_id      => 1133,
                             resp_id      => 50716,
                             resp_appl_id => 201);
  mo_global.init(p_appl_short_name => fnd_global.application_short_name);
  
  l_result := po_change_api1_s.update_po(x_po_number           => 10013991,
                                         x_release_number      => NULL,
                                         x_revision_number     => 0,
                                         x_line_number         => 1,
                                         x_shipment_number     => NULL,
                                         new_quantity          => NULL,
                                         new_price             => 12122222222,
                                         new_promised_date     => NULL,
                                         new_need_by_date      => NULL,
                                         launch_approvals_flag => NULL,
                                         update_source         => NULL,
                                         version               => 1,
                                         x_override_date       => NULL,
                                         x_api_errors          => l_po_api_errors_rec_type,
                                         p_buyer_name          => NULL,
                                         p_secondary_quantity  => NULL,
                                         p_preferred_grade     => NULL,
                                         p_org_id              => 82);

  IF l_result <> 1 THEN
    BEGIN
      FOR i IN 1 .. l_po_api_errors_rec_type.message_text.count LOOP
        dbms_output.put_line(l_po_api_errors_rec_type.message_text(i));
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;
END;
