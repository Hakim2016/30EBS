Select period_name
From gl_period_statuses
WHERE application_id = 101
   AND ledger_id = 2021--fnd_profile.value('GL_SET_OF_BKS_ID')
   AND closing_status = 'O'
   --AND start_date <= trunc(sysdate)
ORDER BY start_date DESC;
