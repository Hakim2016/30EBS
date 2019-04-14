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
      LIKE '6601%'
      AND LENGTH(gcc.segment3) = 10
      --AND gcc.segment4 = '0000'
      --AND gcc.segment5 = '0'
   AND ba.ledger_id = 2021
   AND ba.period_name IN ('2018-09' /*'JAN-19'*/) --'JUN-16'--'OCT-17'--'DEC-18'--'NOV-18'
   AND gcc.segment2 IN (
'10112100101',
'10112110101',
'10113130101',
'10113060101',
'10113060201',
'10113080101',
'10113090101',
'10113100101',
'10113110101',
'10113120101',
'10113060301',
'10113140101',
'10113150101',
'10113160101',
'10113170101',
'10113180101',
'10113190101'
   )
 GROUP BY /*gcc.segment1,*/gcc.segment2,
       gcc.segment3,
       ba.period_name
