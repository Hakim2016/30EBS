select a.user_name user_id ,b.full_name user_full_name,
      c.d_supervisor_id supervisor_user_id ,
      d.authorization_limit User_auth_limit ,
      e.authorization_limit Supervisor_auth_limit
from fnd_user a,
      per_all_people_f b,
      PER_ASSIGNMENTS_V7 c,
      gl_authorization_limits_v d,
      gl_authorization_limits_v e
where a.employee_id=b.person_id
and b.person_id=c.person_id(+)
and a.employee_id=d.employee_id(+)
and c.supervisor_id=e.employee_id(+)
and a.user_name='HAKIM'--'&preparer_id'

;
