-- R11
/*
SELECT rl.responsibility_name,
       ur.start_date,
       ur.end_date,
       ur.user_id,
       ur.application_id,
       ur.responsibility_id
FROM   fnd_user_responsibility ur,
       fnd_responsibility_tl   rl
WHERE  rl.responsibility_id = ur.responsibility_id
AND    rl.LANGUAGE = 'ZHS'
AND    rl.responsibility_name = '160_ø‚¥Ê≥¨º∂”√ªß'
AND    ur.user_id = 1273;
*/

-- 11i
SELECT rl.responsibility_name,
       ur.start_date,
       ur.end_date,
       ur.user_id,
       ur.responsibility_application_id application_id,
       ur.responsibility_id
FROM   apps.fnd_user_resp_groups_all ur,
       applsys.fnd_responsibility_tl    rl
WHERE  rl.responsibility_id = ur.responsibility_id
AND    rl.LANGUAGE = 'US'
AND    ur.user_id = 1111;

SELECT * FROM
apps.fnd_user_resp_groups_all ur
WHERE  1 = 1
AND    UR.RESPONSIBILITY_ID = 20420
AND    ur.user_id = 1111;

UPDATE apps.fnd_user_resp_groups_all ur
SET  ur.end_date = SYSDATE + 1
WHERE  1 = 1
AND    UR.RESPONSIBILITY_ID = 20420
AND    ur.user_id = 1111;

--UPDATE wf_all_user_role_assignments ur SET ur.END_DATE = to_date('2006-10-20','YYYY-MM-DD') WHERE ur.user_name = 'HQXXB02' AND ur.END_DATE = to_date('2006-10-22','YYYY-MM-DD');


SELECT * FROM fnd_user u WHERE u.user_name = 'HQCGB27';

SELECT r.responsibility_name,
       u.user_id,
       r.responsibility_id,
       a.responsibility_application_id
FROM   fnd_user_resp_groups_all a,
       fnd_user                 u,
       fnd_responsibility_tl    r
WHERE  u.user_id = a.user_id
AND    r.responsibility_id = a.responsibility_id
AND    r.application_id = a.responsibility_application_id
AND    r.LANGUAGE = 'US'
AND 
AND    u.user_name = 'HAND_HKM'
;
