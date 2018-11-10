
SELECT aia.org_id,
       aia.invoice_id,
       aia.invoice_num,
       xah.entity_id,
       xdl.event_id,
       xdl.source_distribution_type,
       xdl.source_distribution_id_num_1,
       aid.distribution_line_number,
       aid.invoice_line_number,
       ail.line_number
  FROM xla.xla_distribution_links   xdl,
       xla.xla_ae_headers           xah,
       xla.xla_transaction_entities xte,
       ap_invoice_distributions_all aid,
       ap_invoice_lines_all         ail,
       ap_invoices_all              aia
 WHERE 1 = 1
   AND xdl.ae_header_id = xah.ae_header_id
   AND xah.application_id = xte.application_id
   AND xah.entity_id = xte.entity_id
   AND xdl.application_id = 200
   AND xdl.source_distribution_type = 'AP_INV_DIST'
   AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id
   AND aid.invoice_id = ail.invoice_id
   AND aid.invoice_line_number = ail.line_number
   AND ail.invoice_id = aia.invoice_id
   AND aia.invoice_num = 'CN15040001*1';
/*
 org_id     : 82
 invoice_id : 396688
 entity_id  : 7466227
 event_id   : 7498829 7498960 
*/
-- Delete AP XLA
-----1. Backup. 
CREATE TABLE XXAP.SR_9287425981_AIAS AS 
SELECT *
  FROM ap_invoices_all
 WHERE invoice_id IN ('396688');

-- 2 rows created 

create table XXAP.SR_9287425981_aids AS 
SELECT *
  FROM ap_invoice_distributions_all
 WHERE invoice_id IN ('396688');

-- 18 rows created 

create table XXAP.SR_9287425981_apsa as 
SELECT *
  FROM ap_payment_schedules_all
 WHERE invoice_id IN ('396688');

-- 2 rows created 

create table XXAP.SR_9287425981_xes AS 
SELECT *
  FROM xla.xla_events
 WHERE event_id IN ('7498829', '7498960');

-- 4 rows created 

create table XXAP.SR_9287425981_xahs AS 
SELECT *
  FROM xla.xla_ae_headers
 WHERE event_id IN ('7498829', '7498960');

-- 4 rows created 

create table XXAP.SR_9287425981_xals AS 
SELECT *
  FROM xla.xla_ae_lines
 WHERE ae_header_id IN (SELECT ae_header_id
                          FROM xla.xla_ae_headers
                         WHERE event_id IN ('7498829', '7498960'));

-- 14 rows created 

create table XXAP.SR_9287425981_xdis AS 
SELECT *
  FROM xla.xla_distribution_links
 WHERE event_id IN (7498829, 7498960)
   AND application_id = 200;

--32 rows created 

create table XXAP.SR_9287425981_xtes AS 
SELECT *
  FROM xla.xla_transaction_entities
 WHERE entity_id IN ('7466227')
   AND application_id = 200;

-- 2 rows created. 

-- ===================== 

---2. DATA FIX. 

UPDATE ap_invoices_all
   SET payment_status_flag = 'Y'
 WHERE invoice_id IN ('396688');

-- 2 rows updated 

UPDATE ap_invoice_distributions_all
   SET posted_flag = 'Y', accrual_posted_flag = 'Y', last_updated_by = '2722'
 WHERE invoice_id IN ('396688');

--18 rows updated 

UPDATE ap_payment_schedules_all
   SET payment_status_flag = 'Y'
 WHERE invoice_id IN ('396688');

--2 row updated 

UPDATE xla.xla_events
   SET event_status_code = 'N', process_status_code = 'P'
 WHERE event_id IN ('7498829', '7498960');

--4 rows updated. 

DELETE FROM xla.xla_transaction_entities
 WHERE entity_id IN ('7466227')
   AND application_id = 200;

--2 row deleted 

DELETE FROM xla.xla_distribution_links
 WHERE event_id IN ('7498829', '7498960')
   AND application_id = 200;

--32 rows deleted 

DELETE FROM xla.xla_ae_lines
 WHERE ae_header_id IN (SELECT ae_header_id
                          FROM xla.xla_ae_headers
                         WHERE event_id IN ('7498829', '7498960'));

--14 rows deleted 

DELETE FROM xla.xla_ae_headers
 WHERE event_id IN ('7498829', '7498960');

--4 rows deleted. 

--3. Once the scripts complete, confirm that the data is corrected. 

--4. If you are satisfied with the results, issue a commit. 

--5. Confirm that the data is corrected when viewed in the Oracle Applications. 

--You can use the following steps: 
--a. Log in Payables responsibility 
--b. Try to create accounting for the credit memo. 


--6. If you are satisfied that the issue is resolved, migrate the solution as appropriate to other environments. 
