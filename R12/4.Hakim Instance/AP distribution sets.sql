SELECT * FROM AP_DISTRIBUTION_SETS_ALL;

SELECT *
  FROM AP_DISTRIBUTION_SETS_ALL AH, AP_DISTRIBUTION_SET_LINES_ALL AL
 WHERE 1 = 1
   AND AH.DISTRIBUTION_SET_ID = AL.DISTRIBUTION_SET_ID;