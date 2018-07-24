--add_period_opening
SELECT

 /*p_session_id,
 
 p_acc_no1_p,
 p_acc_no2_p,
 
 p_year,
 p_period,*/
 
 1,
 0,
 
 a.acc_no1,
 a.acc_no2,
 currency,
 period,
 '本期期初',
 
 decode(sign(SUM(nvl(a.begin_debit, 0)
                 - nvl(a.begin_credit, 0)
                 )
             ),
        1,
        SUM(nvl(a.begin_debit, 0)
            - nvl(a.begin_credit, 0)
            ),
        NULL) AS "期初借方余额-贷方余额（>0）",
        --aaa,--期初借方余额-贷方余额（>0）
 decode(sign(SUM(nvl(a.begin_debit, 0)
                 - nvl(a.begin_credit, 0)
                 )
             ),
        -1,
        -sum(nvl(a.begin_debit, 0)
             - nvl(a.begin_credit, 0)
             ),
        -NULL) AS "期初借方余额-贷方余额(<0)取负",
        --bbb,--期初借方余额-贷方余额（<0）取负
 SUM(nvl(a.begin_debit, 0)
     - nvl(a.begin_credit, 0)) AS "期初借方余额-贷方余额",
     --ccc,--期初借方余额-贷方余额
 decode(sign(SUM(nvl(a.begin_debit_func, 0)
                 - nvl(a.begin_credit_func, 0)
                 )
             ),
        1,
        SUM(nvl(a.begin_debit_func, 0)
            - nvl(a.begin_credit_func, 0)
            ),
        NULL) AS "借方期初本币余额-贷方余额(>0)",
        --ddd,--借方初期本位币余额-贷方余额（>0)
 decode(sign(SUM(nvl(a.begin_debit_func, 0)
                 - nvl(a.begin_credit_func, 0)
                 )
             ),
        -1,
        -sum(nvl(a.begin_debit_func, 0)
             - nvl(a.begin_credit_func, 0)
             ),
        NULL) AS "期初借方本币余额-贷方(<0)取负",
        --eee,--期初借方本位币余额-贷方余额（<0）取负
 SUM(nvl(a.begin_debit_func, 0)
     - nvl(a.begin_credit_func, 0)) AS "期初借方本币余额-贷方余额"
     --fff--期初借方本位币余额-贷方余额
  FROM app_mate.gl_balance a
 WHERE YEAR = /*p_year*/'2017'
   /*AND period = decode(data_from_flag, 'YEAR', 1, p_period)*/
   AND company = /*p_company*/'10'
   AND a.acc_no1 = /*p_acc_no1_p*/'112199'
   AND nvl(a.acc_no2, '?') = nvl(/*p_acc_no2_p*/'T', '?')
  /* AND nvl(cost_center, '?') = nvl(p_cost_center, '?')*/
     
      --                AND EXISTS (
     
      --                    SELECT NULL FROM rep_cost_center_temp
     
      --                     WHERE session_id=p_session_id
     
      --                       AND NVL(cost_center,'?')=NVL(a.cost_center,'?')
     
      --                    )
     
   AND a.actual_flag = 'A'
   AND currency = 'FUC'

 GROUP BY a.acc_no1, a.acc_no2, currency,period;
