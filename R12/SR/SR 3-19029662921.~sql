--SR 3-19029662921 : Differenct happenen between Trial Balance and Period Close Reconciliation Report(Cost Group Total)

--1. Please execute the following scripts and upload results to SR including column headers: 
--1) 
SELECT v.*
  FROM gl_code_combinations_kfv v
 WHERE segment3 /*#*/
       = '5300990999' --'5300990098'--'1145400000'
   AND chart_of_accounts_id = 50351 --&chart_of_accounts_id

; -- Please segment# with correct segment num 

--SELECT * FROM gl_sets_of_books sob WHERE 1=1 AND 
SELECT DISTINCT gps.period_name
  FROM gl_period_statuses gps
 WHERE 1 = 1
   AND gps.set_of_books_id = 2021;
--2) 
SELECT to_date(b.period_name, 'MON-YY'),
       a.je_source,
       a.je_category,
       a.period_name,
       a.status,
       a.currency_code,
       a.name,
       b.*
  FROM gl_je_headers a,
       gl_je_lines   b
 WHERE b.ledger_id = 2021 --&ledger_id
      --AND b.period_name = 'OCT-17'--LIKE 'ADJ%'
      --AND to_date(b.period_name, 'MON-YY') <= to_date('2016-07-31', 'yyyy-mm-dd')
   AND b.code_combination_id IN --(1010)
       (SELECT DISTINCT code_combination_id
          FROM gl_code_combinations_kfv
         WHERE segment3 = '5300990999' --'1145400000'
           AND segment5 = '0'
           AND chart_of_accounts_id = 50351 --&chart_of_accounts_id
        )
   AND a.je_header_id = b.je_header_id
 ORDER BY a.je_header_id DESC;
--3) 
SELECT /*'JAN'||SUBSTR(gb.period_name, -3),
to_date('JAN'||SUBSTR(gb.period_name, -3), 'MON-YY'),*/
/*DISTINCT */
 gb.period_name,
 gb.*
  FROM gl_balances gb
 WHERE ledger_id = 2021 --&ledger_id
      --AND gb.period_name LIKE 'OCT-17'
      --AND to_date(gb.period_name, 'MON-YY') <= to_date('2016-07-31','yyyy-mm-dd')
   AND (to_date('JAN' || substr(gb.period_name, -3), 'MON-YY') <= to_date('2015-12-31', 'yyyy-mm-dd') --2015年之前所有的数据
       OR gb.period_name IN ('JAN-16', 'FEB-16', 'MAR-16', 'APR-16', 'MAY-16', 'JUN-16', 'JUL-16'))
   AND code_combination_id IN (SELECT DISTINCT code_combination_id
                                 FROM gl_code_combinations_kfv
                                WHERE segment3 = '1145400000'
                                  AND chart_of_accounts_id = 50351 --&chart_of_accounts_id
                               );

--2. Please help to run the XLA GL Diagnostics test (see NOTE 878891.1 ), and upload outputs to SR: 
/*
This diagnostic can be obtained by applying the following patches. 
for 12.1.x versions: Patch 8765953:R12.XLA.B 

Navigation to run the test: 
Log into the "Application Diagnostics" responsibility (in older versions: "Oracle Diagnostics Tool" responsibility) 
In the "Diagnose" tab click "Select Application" and select Subledger Accounting 
In the GL_DIAGNOSTICS group, select the test "XLA GL Diagnostics" 

The XLA GL Diagnostics test has to be run for all the ledgers associated to a primary ledger. The below query can be run for the primary ledger and will help to identify the ledgers for which the diagnostic should be run: 
*/
SELECT gled.ledger_id AS ledger_id
  FROM gl_ledger_relationships glr,
       gl_ledgers              gled
 WHERE glr.primary_ledger_id = 2021 --&p_ledger_id -- Put primary ledger id here 
   AND glr.application_id = 101
   AND ((glr.target_ledger_category_code IN ('SECONDARY', 'ALC') AND glr.relationship_type_code = 'SUBLEDGER') OR
       (glr.target_ledger_category_code IN ('PRIMARY') AND glr.relationship_type_code = 'NONE'))
   AND glr.target_ledger_id = gled.ledger_id
   AND nvl(gled.complete_flag, 'Y') = 'Y'
 GROUP BY gled.ledger_id;
/*
The diagnostic will prompt for following parameters: 
Ledger name (One ledger at a time) 
Responsibility name (subledger responsibility) 
Start Date and End Date 
Source (Journal Entry Source Name) 
Application_Id （707: Cost Managements; 201: Purchasing; Need to execute the test twice) 
*/

SELECT organization_id,
       accounting_line_type,
       reference_account,
       SUM(nvl(base_transaction_value, 0))
  FROM mtl_transaction_accounts
 WHERE accounting_line_type IN (1, 5, 14)
   AND to_char(transaction_date, 'yyyymm') = '201606'
 GROUP BY organization_id,
          accounting_line_type,
          reference_account;

SELECT code_combination_id,
       SUM(nvl(accounted_dr, 0)),
       SUM(nvl(accounted_cr, 0))
  FROM rcv_receiving_sub_ledger
 WHERE accounting_line_type = 'Receiving Inspection'
   AND to_char(transaction_date, 'yyyymm') = '201606'
 GROUP BY code_combination_id;
