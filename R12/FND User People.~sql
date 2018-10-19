--FND User Person
/*    employee_id       person_party_id
HEA   81                NULL
SHE   1104              27047
*/

SELECT pap.person_id,
       pap.party_id,
       fu.user_name,
       fu.person_party_id,
       fu.employee_id,
       hp.party_type,
       hp.party_number,
       hp.party_name,
       hp.email_address,
       fu.person_party_id,
       pap.full_name,
       pap.sex,
       fu.email_address,
       pap.email_address,
       fu.*,
       pap.*
  FROM fnd_user         fu,
       per_all_people_f pap,
       hz_parties       hp
 WHERE 1 = 1
      --AND fu.person_party_id
      --AND hp.
   AND pap.party_id = hp.party_id
   AND fu.user_name IN --('70264934')--('10171749')--('71229010', '21097003')--
       ('HAND_LY', 'HAND_HKM')
      --AND fu.user_id = 1959--4370--1567--1200--1194--1148--2989--1590--3374--4270--1147--1244--1794--1244--1147
   AND fu.employee_id = pap.person_id
--AND pap.effective_end_date > SYSDATE
;

SELECT pap.person_id,
       pap.party_id,
       pap.last_name,
       pap.first_name,
       pap.full_name,
       pap.*
  FROM per_all_people_f pap
 WHERE 1 = 1
   AND pap.person_id = 81
   AND pap.effective_end_date > SYSDATE
--AND pap.party_id = 27299
;

UPDATE fnd_user fu
   SET fu.employee_id     = 1306, --HEA 81 SHE 1306
       fu.person_party_id = 27249 --HEA NULL  SHE 27249
 WHERE 1 = 1
   AND fu.user_name = 'HAND_HKM';
