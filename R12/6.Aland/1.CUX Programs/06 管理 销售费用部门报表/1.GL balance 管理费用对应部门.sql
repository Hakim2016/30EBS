SELECT gcc.segment2,
       gcc.segment3,
       ba.period_name,
       SUM(ba.begin_balance_dr_beq - ba.begin_balance_cr_beq) 期初金额 --begin_lcv--入账金额
      ,
       SUM(ba.period_net_dr_beq - ba.period_net_cr_beq) 本期发生,
       SUM(ba.begin_balance_dr_beq - ba.begin_balance_cr_beq) +
       SUM(ba.period_net_dr_beq - ba.period_net_cr_beq) 期末金额
  FROM gl_balances ba, gl_code_combinations gcc
 WHERE 1 = 1
   AND ba.code_combination_id = gcc.code_combination_id
      --AND gcc.segment1 = 'FB00'
   AND gcc.segment3 --= '1605020101' --'1145400000'--'5120010011'--'1145400000'--'5120010011'
      LIKE '6602%'
      AND LENGTH(gcc.segment3) = 10
      --AND gcc.segment4 = '0000'
      --AND gcc.segment5 = '0'
   AND ba.ledger_id = 2021
   AND ba.period_name IN ('2018-09' /*'JAN-19'*/) --'JUN-16'--'OCT-17'--'DEC-18'--'NOV-18'
   AND gcc.segment2 IN (
'10111010101',
'10111020101',
'10111030101',
'10111040101',
'10111050101',
'10111060101',
'10111070101',
'10112010101',
'10112020101',
'10112030101',
'10112040101',
'10112050101',
'10112060101',
'10112060201',
'10112060301',
'10112070101',
'10112080101',
'10112080201',
'10112080301',
'10112090101',
'10112100101',
'10112120101',
'10112130101',
'10112140101',
'10112140201',
'10112140301',
'10112140501',
'10112140601',
'10112140701',
'10112150101',
'10113010101',
'10113020101',
'10113030101',
'10113040101',
'10113050101',
'10113070101',
'10111080101',
'10111090101',
'10112070201',
'10111040201',
'10112060401'
   )
 GROUP BY /*gcc.segment1,*/gcc.segment2,
       gcc.segment3,
       ba.period_name
