--User & Person Approve
SELECT fu.user_id,
       fu.user_name,
       pap.person_id,
       pap.last_name,
       pap.full_name --*
  FROM fnd_user         fu,
       per_all_people_f pap
 WHERE 1 = 1
   AND fu.employee_id = pap.person_id
   AND fu.user_name = 'HAND_HKM';

SELECT fu.user_id,
       fu.user_name,
       pap.person_id,
       pap.last_name,
       pap.full_name --*
  FROM fnd_user         fu,
       per_all_people_f pap
 WHERE 1 = 1
   AND fu.employee_id = pap.person_id
   AND fu.user_name = 'HAND_HKM';
   
SELECT * FROM per_all_people_f f
WHERE 1=1
AND f.full_name LIKE '%HEAADMIN%';
