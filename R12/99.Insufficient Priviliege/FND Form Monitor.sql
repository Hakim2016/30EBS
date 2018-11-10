SELECT pap.full_name,
       fu.employee_id,
       fu.user_id,
       fsa.form_id,
       fsa.user_name,
       fsa.responsibility_name,
       fsa.user_form_name
  FROM fnd_signon_audit_view fsa,
       fnd_form              ff,
       fnd_user              fu,
       per_all_people_f      pap
 WHERE fsa.form_id = ff.form_id
   AND fsa.user_id = fu.user_id(+)
   AND fu.employee_id = pap.person_id(+)
   AND ff.form_name = 'XXWIPF001';

SELECT * FROM v$session t WHERE t.module LIKE '%XXWIPF001%';

SELECT hr_general.decode_position_latest_name(paa.position_id) position_name,
       pap.full_name,
       fu.employee_id,
       fu.user_id,
       fsa.form_id,
       fsa.user_name,
       fsa.responsibility_name,
       fsa.user_form_name
  FROM fnd_signon_audit_view fsa,
       fnd_form              ff,
       fnd_user              fu,
       per_all_people_f      pap,
       per_all_assignments_f paa
 WHERE fsa.form_id = ff.form_id
   AND fsa.user_id = fu.user_id(+)
   AND fu.employee_id = pap.person_id(+)
   AND trunc(SYSDATE) BETWEEN pap.effective_start_date(+) AND
       pap.effective_end_date(+)
   AND pap.person_id = paa.person_id(+)
   AND trunc(SYSDATE) BETWEEN paa.effective_start_date(+) AND
       paa.effective_end_date(+)
   AND ff.form_name = 'XXWIPF001';
