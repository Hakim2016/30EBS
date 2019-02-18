SELECT t.user_profile_option_name "Profile Option",
       a.last_update_date,
       decode(a.level_id, 10001, 'Site', 10002, 'Application', 10003, 'Responsibility', 10004, 'User') "Level",
       decode(a.level_id,
              10001,
              'Site',
              10002,
              b.application_short_name,
              10003,
              c.responsibility_key,
              10004,
              d.user_name,
              'UnDef') "Level Value",
       a.profile_option_value "Profile Value"
  FROM fnd_profile_option_values a,
       fnd_application           b,
       fnd_responsibility        c,
       fnd_user                  d,
       fnd_profile_options       e,
       fnd_profile_options_tl    t
 WHERE a.profile_option_id = e.profile_option_id
   AND e.profile_option_name IN ('CSE_PA_EXP_TYPE')
   AND a.level_value = b.application_id(+)
   AND a.level_value = c.responsibility_id(+)
   AND a.level_value = d.user_id(+)
   AND t.profile_option_name = e.profile_option_name
   AND t.language = 'US'
 ORDER BY e.profile_option_name,
          a.level_id DESC;
