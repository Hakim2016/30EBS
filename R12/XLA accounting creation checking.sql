--2. 

SELECT *
  FROM xla_transaction_entities_upg
 WHERE ledger_id = 2023
   AND application_id = 707
   AND entity_id IN (SELECT entity_id
                       FROM xla_events
                      WHERE application_id = 707
                        AND event_date BETWEEN '13-JUL-2018' AND '14-JUL-2018'
                        AND event_status_code <> 'P'
                        AND process_status_code <> 'P');

--3. 
SELECT *
  FROM xla_events
 WHERE 1=1
   AND application_id = 707
   --AND event_date BETWEEN '13-JUL-2018' AND '14-JUL-2018'
   AND event_status_code <> 'P'
   AND process_status_code <> 'P';

--4. 
SELECT *
  FROM mtl_material_transactions
 WHERE transaction_id IN (SELECT source_id_int_1
                            FROM xla_transaction_entities_upg
                           WHERE ledger_id = 2023
                             AND application_id = 707
                             AND entity_id IN (SELECT entity_id
                                                 FROM xla_events
                                                WHERE application_id = 707
                                                  AND event_date BETWEEN '13-JUL-2018' AND '14-JUL-2018'
                                                  AND event_status_code <> 'P'
                                                  AND process_status_code <> 'P'));
