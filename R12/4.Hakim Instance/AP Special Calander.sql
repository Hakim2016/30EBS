--Header
SELECT * FROM AP_OTHER_PERIOD_TYPES;

--Header Line
SELECT *
  FROM AP_OTHER_PERIOD_TYPES AOPT, AP_OTHER_PERIODS AOP
 WHERE 1 = 1
   AND AOPT.PERIOD_TYPE = AOP.PERIOD_TYPE
   AND aopt.period_type = 'XXHKM_Monthly'--'Monthly 01 - 12'
   ;
