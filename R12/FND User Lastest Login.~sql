SELECT fu.end_date,
       fu.user_name,
       ppf.full_name,
       ppf.effective_start_date,
       ppf.effective_end_date,
       fl.*
  FROM fnd_logins       fl,
       per_all_people_f ppf,
       fnd_user         fu
 WHERE 1 = 1
   AND fl.user_id = fu.user_id
   AND fu.user_name LIKE 'HAND%'
   AND fu.employee_id = ppf.person_id(+)
   AND nvl(fu.end_date, SYSDATE) BETWEEN nvl(ppf.effective_start_date, SYSDATE) AND
       nvl(ppf.effective_end_date, SYSDATE)
      --AND fu.user_name NOT IN ('HAND_ADMIN')
      --AND fu.user_name IN ('HAND_HDH')
   AND fl.login_id = (SELECT MAX(fl_sub.login_id)
                        FROM fnd_logins fl_sub
                       WHERE fl.user_id = fl_sub.user_id)
 ORDER BY fl.login_id DESC
