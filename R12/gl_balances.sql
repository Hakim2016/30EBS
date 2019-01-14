﻿SELECT gcc.segment3 acct,
       ba.currency_code,
       ba.begin_balance_dr-ba.begin_balance_cr begin_ov,--记账金额
       ba.begin_balance_dr_beq - ba.begin_balance_cr_beq begin_lcv,--记账本位币金额
       ba.period_net_dr,
       ba.period_net_cr,
       ba.period_net_dr_beq prd_dr_loc,
       ba.period_net_cr_beq prd_cr_loc,
       ba.period_net_dr_beq - ba.period_net_cr_beq 本币期末合计,--本期合计
       NULL 原币期末余额,--原币期末余额
       NULL 本币期末余额, --本币期末余额
       /*
      ,
       nvl(ba.begin_balance_dr          , 0) - nvl(ba.begin_balance_cr                    , 0) begin_balance --期初余额 原币
            ,
       
       ba.period_net_dr --本期借方发生额 原币
            ,
       ba.period_net_dr_beq --本期借方发生额 本币      
            ,
       ba.period_net_cr --本期贷方发生额 原币
            ,
       ba.period_net_cr_beq --本期贷方发生额 本币
            ,
       nvl(ba.period_net_dr_beq          , 0) - nvl(ba.period_net_cr_beq                    , 0) --PTD
            ,
       (nvl(ba.begin_balance_dr            , 0) - nvl(ba.begin_balance_cr                      , 0) +
       nvl(ba.period_net_dr                                , 0) -
       nvl(ba.period_net_cr                                          , 0)) ytd_balance --期末余额 原币
            ,
       (nvl(ba.begin_balance_dr_beq            , 0) - nvl(ba.begin_balance_cr_beq                      , 0) +
       nvl(ba.period_net_dr_beq                                , 0) -
       nvl(ba.period_net_cr_beq                                          , 0)) ytd_balance_beq --期末余额 本币
       ,*/
       ba.*
  FROM gl_balances          ba,
       gl_code_combinations gcc
 WHERE 1 = 1
   AND ba.code_combination_id = gcc.code_combination_id
   AND gcc.segment1 = 'FB00'
   AND gcc.segment3 = '1145400000'--'5120010011'--'1145400000'--'5120010011'
   --AND gcc.segment4 = '0000'
   --AND gcc.segment5 = '0'
   AND ba.ledger_id = 2021
   AND ba.period_name = 'DEC-18'--'NOV-18'--'NOV-18'
   
   ;
   SELECT ba.period_name,SUM(ba.begin_balance_dr_beq - ba.begin_balance_cr_beq)  期初金额--begin_lcv--入账金额
  ,sum(ba.period_net_dr_beq - ba.period_net_cr_beq) 本期发生 ,
  SUM(ba.begin_balance_dr_beq - ba.begin_balance_cr_beq) +
  sum(ba.period_net_dr_beq - ba.period_net_cr_beq) 期末金额
FROM gl_balances          ba,
       gl_code_combinations gcc
 WHERE 1 = 1
   AND ba.code_combination_id = gcc.code_combination_id
   AND gcc.segment1 = 'FB00'
   AND gcc.segment3 = '1145400000'--'5120010011'--'1145400000'--'5120010011'
   --AND gcc.segment4 = '0000'
   --AND gcc.segment5 = '0'
   AND ba.ledger_id = 2021
   AND ba.period_name IN ('OCT-18','NOV-18','DEC-18')--'JUN-16'--'OCT-17'--'DEC-18'--'NOV-18'
   GROUP BY ba.period_name
   
   ;
