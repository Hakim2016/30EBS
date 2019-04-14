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
   AND PAP.PARTY_ID = HP.PARTY_ID(+)
      --AND pap.party_id = 9851
   AND FU.USER_NAME IN 
      ('120811')
      --AND fu.encrypted_foundation_password = 'INVALID' 
 --AND hp.party_name LIKE '%Ñî¾²%'
  AND FU.EMPLOYEE_ID = PAP.PERSON_ID(+)
   --AND nvl(PAP.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
  /* AND SYSDATE BETWEEN nvl(PAP.EFFECTIVE_END_DATE, SYSDATE)
   AND */
   ;
   
   
SELECT *
  FROM APPS.FND_USER FU
 WHERE 1 = 1
   --AND FU.USER_ID = 22006270
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
