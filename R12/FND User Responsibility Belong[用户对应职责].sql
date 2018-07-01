SELECT fu.user_name,
       fr.responsibility_name,
       furg.start_date,
       furg.end_date,
       fu.end_date
  FROM fnd_user_resp_groups_direct furg,
       fnd_responsibility_vl       fr,
       fnd_user                    fu
 WHERE 1 = 1
   AND furg.user_id = fu.user_id
      -- AND (furg.user_id = 2722)
   AND furg.responsibility_application_id = fr.application_id
   AND furg.responsibility_id = fr.responsibility_id
   AND fr.responsibility_id = 50663
   AND upper(fr.responsibility_name) = upper('HEA PA Manager')
 ORDER BY fu.user_name
