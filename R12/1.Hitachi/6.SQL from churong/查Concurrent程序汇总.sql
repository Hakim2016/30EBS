select * from apps.FND_CONC_REQ_SUMMARY_V
where 1=1
and program ='Interface program:IF62 (XXGL:Accounting Data Outbound HFG)'--Program Name
and request_date between to_date('2017/05/04','yyyy/mm/dd') and sysdate --to_date('2016/10/31','yyyy/mm/dd')


