--��ȡ�ڳ������� 
SELECT gcc.segment3,ba.period_name,
       SUM(ba.begin_balance_dr_beq) �ڳ��跽,
       SUM(ba.begin_balance_cr_beq) �ڳ�����,
       SUM(ba.begin_balance_dr_beq) - SUM(ba.begin_balance_cr_beq) �ڳ����,
       
       SUM(ba.begin_balance_dr_beq - ba.begin_balance_cr_beq) �ڳ���� --begin_lcv--���˽��
      ,
       SUM(ba.period_net_dr_beq - ba.period_net_cr_beq) ���ڷ���,
       SUM(ba.begin_balance_dr_beq - ba.begin_balance_cr_beq) +
       SUM(ba.period_net_dr_beq - ba.period_net_cr_beq) ��ĩ���,
       to_char(to_date(ba.period_name, 'yyyy-mm') - 1/12, 'yyyy-mm') ��ĩ��Ϣ
       FROM gl_balances ba, gl_code_combinations gcc
 WHERE ba.code_combination_id = gcc.code_combination_id
   AND ba.ledger_id = 2021 --g_ledger_id
   AND gcc.segment3 = '1605020101' --g_account
   AND ba.period_name in ('2018-05','2018-06', '2018-07' ,'2018-08', '2018-09', '2018-10') --g_period_name
   AND ba.currency_code = 'CNY' --g_base_currency
      --AND gcc.CHART_OF_ACCOUNTS_ID = g_coa_id
   AND gcc.detail_posting_allowed_flag = 'Y'
 GROUP BY gcc.segment3,ba.period_name
 ORDER BY to_date(ba.period_name, 'yyyy-mm') DESC;
