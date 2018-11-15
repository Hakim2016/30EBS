SELECT u.user_name,
       app.application_short_name,
       fat.application_name,
       fr.responsibility_key,
       frt.responsibility_name,
       fff.function_name,
       fft.user_function_name,
       icx.function_type,
       icx.first_connect,
       icx.last_connect
  FROM icx_sessions          icx,
       fnd_user              u,
       fnd_application       app,
       fnd_application_tl    fat,
       fnd_responsibility    fr,
       fnd_responsibility_tl frt,
       fnd_form_functions    fff,
       fnd_form_functions_tl fft
 WHERE 1 = 1
   AND u.user_id = icx.user_id
   AND icx.responsibility_application_id = app.application_id
   AND fat.application_id = icx.responsibility_application_id
   AND fat.language = userenv('lang')
   AND fr.application_id = icx.responsibility_application_id
   AND fr.responsibility_id = icx.responsibility_id
   AND frt.language = userenv('lang')
   AND frt.application_id = icx.responsibility_application_id
   AND frt.responsibility_id = icx.responsibility_id
   AND fff.function_id = icx.function_id
   AND fft.function_id = icx.function_id
   AND fft.language = userenv('lang')
   AND icx.disabled_flag != 'Y'
   AND icx.pseudo_flag = 'N'
   AND (icx.last_connect + decode(fnd_profile.value('ICX_SESSION_TIMEOUT'),
                                  NULL,
                                  icx.limit_time,
                                  0,
                                  icx.limit_time,
                                  fnd_profile.value('ICX_SESSION_TIMEOUT') / 60) / 24) > SYSDATE
   AND icx.counter < icx.limit_connects;
