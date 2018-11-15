--To implement the solution, please execute the following steps: 

--1. Ensure that you have taken a backup of your system before applying the recommended solution. 

--2. Run the following scripts in a TEST environment first: 

-----1. Backup. 

create table SR_9287425981_AIAS_20140911
as 
SELECT *
  FROM ap_invoices_all
 WHERE invoice_id IN (291831);

--1 rows created 

create table SR_9287425981_aids_20140911
as 
SELECT *
  FROM ap_invoice_distributions_all
 WHERE invoice_id IN (291831);

--8 rows created 

create table SR_9287425981_apsa_20140911 
as 
SELECT *
  FROM ap_payment_schedules_all
 WHERE invoice_id IN (291831);

--1 rows created 

create table SR_9287425981_xes_20140911 
as 
SELECT *
  FROM xla.xla_events
 WHERE event_id IN (4353010, 4353236);

--2 rows created 

create table SR_9287425981_xahs_20140911 
as 
SELECT *
  FROM xla.xla_ae_headers
 WHERE event_id IN (4353010, 4353236);

--2 rows created 

create table SR_9287425981_xals_20140911 
as 
SELECT *
  FROM xla.xla_ae_lines
 WHERE ae_header_id IN (SELECT ae_header_id
                          FROM xla.xla_ae_headers
                         WHERE event_id IN (4353010, 4353236));

--7 rows created 

create table SR_9287425981_xdis_20140911 
as 
SELECT *
  FROM xla.xla_distribution_links
 WHERE event_id IN (4353010, 4353236)
   AND application_id = 200;

--14 rows created 

create table SR_9287425981_xtes_20140911 
as 
SELECT *
  FROM xla.xla_transaction_entities
 WHERE entity_id IN (4320545)
   AND application_id = 200;

--1 rows created. 

-- ===================== 

---2. DATA FIX. 

UPDATE ap_invoices_all
   SET payment_status_flag = 'Y'
 WHERE invoice_id IN (291831);

--1 rows updated 

UPDATE ap_invoice_distributions_all
   SET posted_flag = 'Y', accrual_posted_flag = 'Y', last_updated_by = '-169'
 WHERE invoice_id IN (291831);

--8 rows updated 

update AP_PAYMENT_SCHEDULES_ALL 
set payment_status_flag='Y' 
WHERE invoice_id in (291831); 

--1 row updated 

UPDATE xla.xla_events
   SET event_status_code = 'N', process_status_code = 'P'
 WHERE event_id IN (4353010, 4353236);

--2 rows updated. 

DELETE FROM xla.xla_transaction_entities
 WHERE entity_id IN (4320545)
   AND application_id = 200;

--1 row deleted 

DELETE FROM xla.xla_distribution_links
 WHERE event_id IN (4353010, 4353236)
 AND application_id = 200;

--14 rows deleted 

DELETE FROM xla.xla_ae_lines
 WHERE ae_header_id IN (SELECT ae_header_id
                          FROM xla.xla_ae_headers
                         WHERE event_id IN (4353010, 4353236));

--7 rows deleted 

DELETE FROM xla.xla_ae_headers
 WHERE event_id IN (4353010, 4353236);

--2 rows deleted. 

--3. Once the scripts complete, confirm that the data is corrected. 

--4. If you are satisfied with the results, issue a commit. 

--5. Confirm that the data is corrected when viewed in the Oracle Applications. 

--You can use the following steps: 
--a. Log in Payables responsibility 
--b. Try to create accounting for the credit memo. 


--6. If you are satisfied that the issue is resolved, migrate the solution as appropriate to other environments
