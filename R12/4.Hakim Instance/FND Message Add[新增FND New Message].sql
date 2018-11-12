DECLARE
  CURSOR c1 IS
    SELECT *
      FROM xx_fnd_new_messages_stg;
BEGIN
  FOR z IN c1
  LOOP
    fnd_new_messages_pkg.load_row(x_application_id   => z.application_id,
                                  x_message_name     => z.message_name,
                                  x_message_number   => z.message_number,
                                  x_message_text     => z.message_text,
                                  x_description      => z.description,
                                  x_type             => z.type,
                                  x_max_length       => z.max_length,
                                  x_category         => z.category,
                                  x_severity         => z.severity,
                                  x_fnd_log_severity => z.fnd_log_severity,
                                  x_owner            => &user_name,
                                  x_custom_mode      => 'FORCE',
                                  x_last_update_date => NULL);
  END LOOP;
  COMMIT;
END;
