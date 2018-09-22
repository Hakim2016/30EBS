
SELECT xe.event_status_code,
       xe.process_status_code,
       xe.transaction_date,
       xte.*
  FROM xla.xla_transaction_entities xte,
       xla.xla_events               xe
 WHERE 1 = 1
      --AND xe.event_id
   AND xe.entity_id = xte.entity_id
   AND xte.ledger_id = 2021
   AND xte.source_id_int_1 = 54897273 --54896869--54868663
      --AND xte.transaction_number LIKE 'HKM18060401%'--54834283
   AND xte.application_id = 707 --200--707
   AND xte.entity_id >= 29967072
--AND xte.entity_code = 'RCV_ACCOUNTING_EVENTS'
;

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
