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
 '�����ڳ�',
 
 decode(sign(SUM(nvl(a.begin_debit, 0)
                 - nvl(a.begin_credit, 0)
                 )
             ),
        1,
        SUM(nvl(a.begin_debit, 0)
            - nvl(a.begin_credit, 0)
            ),
        NULL) AS "�ڳ��跽���-������>0��",
        --aaa,--�ڳ��跽���-������>0��
 decode(sign(SUM(nvl(a.begin_debit, 0)
                 - nvl(a.begin_credit, 0)
                 )
             ),
        -1,
        -sum(nvl(a.begin_debit, 0)
             - nvl(a.begin_credit, 0)
             ),
        -NULL) AS "�ڳ��跽���-�������(<0)ȡ��",
        --bbb,--�ڳ��跽���-������<0��ȡ��
 SUM(nvl(a.begin_debit, 0)
     - nvl(a.begin_credit, 0)) AS "�ڳ��跽���-�������",
     --ccc,--�ڳ��跽���-�������
 decode(sign(SUM(nvl(a.begin_debit_func, 0)
                 - nvl(a.begin_credit_func, 0)
                 )
             ),
        1,
        SUM(nvl(a.begin_debit_func, 0)
            - nvl(a.begin_credit_func, 0)
            ),
        NULL) AS "�跽�ڳ��������-�������(>0)",
        --ddd,--�跽���ڱ�λ�����-������>0)
 decode(sign(SUM(nvl(a.begin_debit_func, 0)
                 - nvl(a.begin_credit_func, 0)
                 )
             ),
        -1,
        -sum(nvl(a.begin_debit_func, 0)
             - nvl(a.begin_credit_func, 0)
             ),
        NULL) AS "�ڳ��跽�������-����(<0)ȡ��",
        --eee,--�ڳ��跽��λ�����-������<0��ȡ��
 SUM(nvl(a.begin_debit_func, 0)
     - nvl(a.begin_credit_func, 0)) AS "�ڳ��跽�������-�������"
     --fff--�ڳ��跽��λ�����-�������
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
