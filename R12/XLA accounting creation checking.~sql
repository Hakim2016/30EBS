SELECT xte.entity_id,
       xe.event_status_code,
       xe.process_status_code,xte.entity_code,
       xte.transaction_number,
       xe.transaction_date,
       xte.source_id_int_1,
       --xte.*,
       xe.*
  FROM xla.xla_transaction_entities xte,
       xla.xla_events               xe
 WHERE 1 = 1
      --AND xe.event_id
   AND xe.entity_id = xte.entity_id
   AND xte.ledger_id = 2021--2041 --2041
      AND xte.source_id_int_1 --= 5235833--54897273 --54896869--54868663
      IN (5235833,5085765--4408821--4408820--rt.transaction_id
         ,64512074,69864747,70045973--48624778--mmt.transaction_id
       )
   /*AND xte.transaction_number --LIKE 'HKM18060401%'--54834283
      --IN ('SINI003038126', 'H358K057*4', '3194', '00157509', 'AHJ0376350', '35860*3')
       IN (48624778--mmt.transaction_id
       ,4408820--rt.transaction_id
       \*, 48629281*\)*/
      --IN('DP-18000143')
   AND xte.application_id = 707 --222--707--200 --707 --200--707
--AND xte.entity_id =27219514-->= 29967072
--AND xte.entity_code = 'RCV_ACCOUNTING_EVENTS'
 ORDER BY xte.transaction_number;

--rcv transaction
SELECT *
  FROM rcv_transactions rt
 WHERE 1 = 1
   AND rt.transaction_id = 5235833;

--2. 

SELECT *
  FROM xla_transaction_entities_upg
 WHERE ledger_id = 2021
   AND application_id = 707
   AND entity_id IN (SELECT entity_id
                       FROM xla_events
                      WHERE application_id = 707
                        AND event_date BETWEEN '01-MAR-2018' AND '31-MAR-2018'
                        AND event_status_code <> 'P'
                        AND process_status_code <> 'P');

--3. 
SELECT *
  FROM xla_events
 WHERE 1 = 1
   AND application_id = 707
      --AND event_date BETWEEN '01-MAR-2018' AND '31-MAR-2018'
   AND event_status_code <> 'P'
   AND process_status_code <> 'P';

--4. 
SELECT *
  FROM mtl_material_transactions
 WHERE transaction_id IN (SELECT source_id_int_1
                            FROM xla_transaction_entities_upg
                           WHERE ledger_id = 2021
                             AND application_id = 707
                             AND entity_id IN (SELECT entity_id
                                                 FROM xla_events
                                                WHERE application_id = 707
                                                  AND event_date BETWEEN '01-MAR-2018' AND '31-MAR-2018'
                                                  AND event_status_code <> 'P'
                                                  AND process_status_code <> 'P'));

--20181205
/*Create Accounting Report Shows Error 95318 The account code combination id 0 
specified for line 1 does not exist. Please use a valid account code combination id 
for the subledger journal entry line (Doc ID 1396419.1)*/
SELECT *
  FROM xla_accounting_errors
 WHERE application_id = 707 --555
   AND ledger_id = 2041
   AND message_number = 95318
   AND creation_date > (SYSDATE - 90)
   ;

SELECT geh.legal_entity_id,
       geh.ledger_id,
       geh.transaction_id,
       geh.transaction_date,
       geh.event_type_code,
       geh.event_class_code,
       gel.journal_line_type,
       gel.transaction_account_id,
       code_combination_id,
       fnd_flex_ext.get_segs('SQLGL', 'GL#', gcc.chart_of_accounts_id, gcc.code_combination_id) account,
       gl_flexfields_pkg.get_concat_description(gcc.chart_of_accounts_id, gcc.code_combination_id) acc_description,
       SUM(nvl(gel.accounted_amount, 0))
  FROM gl_code_combinations    gcc,
       gmf_xla_extract_headers geh,
       gmf_xla_extract_lines   gel
 WHERE gel.transaction_account_id = gcc.code_combination_id(+)
   AND geh.header_id = gel.header_id
   AND geh.event_id = gel.event_id
   AND geh.transaction_id IN (&t1, &t2)
 GROUP BY geh.legal_entity_id,
          geh.ledger_id,
          geh.transaction_id,
          geh.transaction_date,
          geh.event_type_code,
          geh.event_class_code,
          gel.journal_line_type,
          gel.transaction_account_id,
          code_combination_id,
          fnd_flex_ext.get_segs('SQLGL', 'GL#', gcc.chart_of_accounts_id, gcc.code_combination_id),
          gl_flexfields_pkg.get_concat_description(gcc.chart_of_accounts_id, gcc.code_combination_id)
