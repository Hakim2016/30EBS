--ap
SELECT XX.NAME "PaymentTerm in GSCM",
       APT.NAME,
       xx.START_DATE_ACTIVE,
       APT.LANGUAGE,
       APT.DESCRIPTION,
       XX.DESCRIPTION,
       --xx.attribute10 "PaymentTerm in HFA",
       XX.CREATED_BY,
       XX.*
  FROM AP_TERMS XX, AP_TERMS_TL APT
 WHERE 1 = 1
   AND XX.TERM_ID = APT.TERM_ID
   AND APT.LANGUAGE = USERENV('LANG')
--AND xx.name = '85TT'
--AND xx.created_by = 4411
--AND nvl(xx.end_date_active, SYSDATE) <= SYSDATE
--AND xx.attribute10 IS NOT NULL
 ORDER BY XX.CREATION_DATE DESC;

--ar
SELECT XX.CREATION_DATE,
       XX.NAME "PaymentTerm in GSCM",
       XX.DESCRIPTION,
       SUBSTRB(XX.ATTRIBUTE10, 1, 4) "PaymentTerm in HFA",
       XX.ATTRIBUTE10,
       XX.CREATED_BY /*,
       xx.*/
  FROM RA_TERMS XX
 WHERE 1 = 1
--AND nvl(xx.end_date_active, SYSDATE) <= SYSDATE
--AND xx.attribute10 IS NOT NULL
--AND xx.created_by = 4411
 ORDER BY XX.ATTRIBUTE10;

/*Scripts to change payment term*/
SELECT *
  FROM RA_TERMS_B XX
 WHERE 1 = 1
   AND XX.CREATED_BY = 4411
 ORDER BY XX.ATTRIBUTE10;

SELECT *
  FROM FND_USER XX
 WHERE 1 = 1
   AND XX.USER_ID = 4411;

----------------------------
--ar payment term
SELECT XX.CREATION_DATE,
       XX.NAME "PaymentTerm in GSCM",
       RTL.DUE_DAYS,
       XX.DESCRIPTION,
       SUBSTRB(XX.ATTRIBUTE10, 1, 4) "PaymentTerm in HFA",
       XX.ATTRIBUTE10,
       XX.CREATED_BY /*,
       xx.*/
  FROM RA_TERMS XX, RA_TERMS_LINES RTL
 WHERE 1 = 1
   AND XX.TERM_ID = RTL.TERM_ID
   AND NVL(XX.END_DATE_ACTIVE, SYSDATE) >= SYSDATE
   AND XX.ATTRIBUTE10 IS NOT NULL
   AND XX.NAME IN ('IMM', 'IMMS')
--AND xx.created_by = 4411
 ORDER BY XX.ATTRIBUTE10;
