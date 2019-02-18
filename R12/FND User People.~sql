--FND User Person
/*    employee_id       person_party_id
HEA   81                NULL
SHE   1104              27047
*/

SELECT FU.USER_ID,
       PAP.PERSON_ID,
       PAP.PARTY_ID,
       FU.USER_NAME,
       FU.CREATION_DATE,
       FU.PERSON_PARTY_ID,
       FU.EMPLOYEE_ID,
       HP.PARTY_TYPE,
       HP.PARTY_NUMBER,
       HP.PARTY_NAME,
       HP.EMAIL_ADDRESS,
       FU.PERSON_PARTY_ID,
       PAP.FULL_NAME,
       PAP.SEX,
       FU.EMAIL_ADDRESS,
       PAP.EMAIL_ADDRESS,
       FU.*,
       PAP.*
  FROM APPS.FND_USER FU, APPS.PER_ALL_PEOPLE_F PAP, APPS.HZ_PARTIES HP
 WHERE 1 = 1
      --AND fu.person_party_id
      --AND nvl(nvl(hp.EMAIL_ADDRESS,FU.EMAIL_ADDRESS), PAP.EMAIL_ADDRESS) LIKE '%am.hd%'--'%AM.HD%'----'%rodchanon%'
   AND PAP.PARTY_ID = HP.PARTY_ID
   --AND HP.PARTY_NAME LIKE '%Soo Foo%'
      --AND pap.party_id = 9851
   --AND FU.USER_NAME IN ('71229010')
      --('70236270')
       --('70271660', '70308768', '70236270')
      --('22006270')
      
      --('HAND_LY', 'HAND_HKM')
      AND fu.user_id --= 1130--4129--2989--1959--4370--1567--1200--1194--1148--2989--1590--3374--4270--1147--1244--1794--1244--1147
 IN (1144,
1147,
1148,
1149,
1478,
1794,
3575,
4270
)
 
 --AND fu.encrypted_foundation_password = 'INVALID' 
  AND FU.EMPLOYEE_ID = PAP.PERSON_ID
   AND PAP.EFFECTIVE_END_DATE > SYSDATE;
   
   
SELECT *
  FROM APPS.FND_USER FU
 WHERE 1 = 1
   AND FU.USER_ID = 1130--4129--22006270
--AND length(fu.encrypted_foundation_password) < 10
--AND fu.encrypted_foundation_password = 'INVALID'
ORDER BY --last_update_date DESC
fu.creation_date DESC
;

SELECT PAP.PERSON_ID,
       PAP.PARTY_ID,
       PAP.LAST_NAME,
       PAP.FIRST_NAME,
       PAP.FULL_NAME,
       pap.email_address,
       PAP.*
  FROM PER_ALL_PEOPLE_F PAP
 WHERE 1 = 1
 AND pap.email_address LIKE UPPER('%am.hd%')
   --AND PAP.PERSON_ID = 9851 --81
   --AND PAP.EFFECTIVE_END_DATE > SYSDATE
--AND pap.party_id = 27299
;
SELECT * FROM FND_USER;

UPDATE FND_USER FU
   SET FU.EMPLOYEE_ID     = 1306, --HEA 81 SHE 1306
       FU.PERSON_PARTY_ID = 27249 --HEA NULL  SHE 27249
 WHERE 1 = 1
   AND FU.USER_NAME = 'HAND_HKM';
