SELECT * FROM wip_transactions_v wt
WHERE 1=1
AND wt.creation_date >= to_date('20180720','yyyymmdd')
;

SELECT * FROM wip_transactions wt
WHERE 1=1
AND wt.creation_date >= to_date('20180720','yyyymmdd')
;
