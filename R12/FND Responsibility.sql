-- R12

SELECT RL.RESPONSIBILITY_NAME,
       UR.START_DATE,
       UR.END_DATE,
       --UR.USER_ID,
       UR.APPLICATION_ID,
       UR.RESPONSIBILITY_ID FND_RESP
  FROM FND_RESPONSIBILITY UR, FND_RESPONSIBILITY_TL RL
 WHERE RL.RESPONSIBILITY_ID = UR.RESPONSIBILITY_ID
   AND RL.LANGUAGE = 'US' --'ZHS'
   AND    rl.responsibility_name LIKE '%ALL%'--'%User%Manage%'--= '160_��泬���û�'
--AND    ur.user_id = 1273
;

SELECT FRL.RESPONSIBILITY_NAME, FR.*, FRL.*
  FROM FND_RESPONSIBILITY FR, FND_RESPONSIBILITY_TL FRL
 WHERE 1 = 1
   AND FRL.LANGUAGE = 'US'
   AND FR.RESPONSIBILITY_ID = FRL.RESPONSIBILITY_ID
   
   AND upper(FRL.RESPONSIBILITY_NAME) LIKE '%FULL%'--'%ALL%'    
   ;

-- 11i
SELECT RL.RESPONSIBILITY_NAME,
       UR.START_DATE,
       UR.END_DATE,
       UR.USER_ID,
       UR.RESPONSIBILITY_APPLICATION_ID APPLICATION_ID,
       UR.RESPONSIBILITY_ID
  FROM APPS.FND_USER_RESP_GROUPS_ALL UR, APPLSYS.FND_RESPONSIBILITY_TL RL
 WHERE RL.RESPONSIBILITY_ID = UR.RESPONSIBILITY_ID
   AND RL.LANGUAGE = 'US'
   AND UR.USER_ID = 1111;

SELECT *
  FROM APPS.FND_USER_RESP_GROUPS_ALL UR
 WHERE 1 = 1
   AND UR.RESPONSIBILITY_ID = 20420
--AND    ur.user_id = 1111
;

UPDATE APPS.FND_USER_RESP_GROUPS_ALL UR
   SET UR.END_DATE = SYSDATE + 1
 WHERE 1 = 1
   AND UR.RESPONSIBILITY_ID = 20420
   AND UR.USER_ID = 1111;

--UPDATE wf_all_user_role_assignments ur SET ur.END_DATE = to_date('2006-10-20','YYYY-MM-DD') WHERE ur.user_name = 'HQXXB02' AND ur.END_DATE = to_date('2006-10-22','YYYY-MM-DD');

SELECT * FROM FND_USER U WHERE U.USER_NAME = 'HQCGB27';

SELECT R.RESPONSIBILITY_NAME,
       U.USER_ID,
       R.RESPONSIBILITY_ID,
       A.RESPONSIBILITY_APPLICATION_ID
  FROM FND_USER_RESP_GROUPS_ALL A, FND_USER U, FND_RESPONSIBILITY_TL R
 WHERE U.USER_ID = A.USER_ID
   AND R.RESPONSIBILITY_ID = A.RESPONSIBILITY_ID
   AND R.APPLICATION_ID = A.RESPONSIBILITY_APPLICATION_ID
   AND R.LANGUAGE = 'US'
      --AND 
   AND U.USER_NAME = 'HAKIM' --'HAND_HKM'
;
