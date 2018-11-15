SELECT * FROM zx_lines;


--分配行的税的取值
SELECT * FROM zx_rec_nrec_dist t where t.tax_line_id=10213126;
--
SELECT * FROM zx_lines_det_factors;
--分配行的税的取值
SELECT * FROM zx_rec_nrec_dist;


select * from zx_lines_summary_v;

select ail.summary_tax_line_id, ail.*
  from ap_invoices_all ai, ap_invoice_lines_all ail
 where ai.invoice_id = ail.invoice_id
   and ai.invoice_num = 'CESHI002';

select * from zx_lines_summary t where t.summary_tax_line_id=1428678 ;

SELECT * FROM zx_lines;

SELECT t.application_id,
       t.entity_code,
       t.event_class_code,
       t.trx_id,
       t.trx_level_type,
       t.trx_line_id,
       t.tax_regime_code,
       t.tax,
       t.tax_apportionment_line_number,
       t.tax_rate,
       t.tax_amt,
       t.tax_amt_tax_curr,
       t.tax_amt_funcl_curr,
       t.*
  FROM zx_lines t
 WHERE t.summary_tax_line_id = 1428678;

200 AP_INVOICES 

--所有的行类型的不是为‘TAX’的行。
SELECT * FROM zx_lines_det_factors;

--分配行的税的取值
SELECT * FROM zx_rec_nrec_dist;



SELECT *
  FROM zx_lines
 WHERE application_id = '200'
   AND entity_code = 'AP_INVOICES'
   AND event_class_code = 'STANDARD INVOICES'
   AND trx_id = '200000'
   AND trx_level_type = 'LINE'
   AND summary_tax_line_id = 1428678
   AND trx_line_number  =1
   AND t
 ORDER BY trx_number, trx_line_number, tax_line_number;

SELECT * FROM ap_invoices_all t WHERE t.invoice_num LIKE 'CESHI%';

CREATE OR REPLACE VIEW CUX_AP_ALL_COST_V AS 
SELECT /*ail.invoice_id, ail.line_number,zl.tax_apportionment_line_number*/
COUNT(1)
  FROM ap_invoice_lines_all ail, zx_lines zl
 WHERE ail.invoice_id = zl.trx_id(+) --关联条件
   AND ail.line_number = zl.trx_line_number(+) --关联条件
      /*  AND zl.summary_tax_line_id = ail.
            */
   AND zl.application_id(+) = '200'
   AND zl.entity_code(+) = 'AP_INVOICES'
   AND zl.event_class_code(+) = 'STANDARD INVOICES'
   AND zl.trx_level_type(+) = 'LINE'
   --AND ail.creation_date > trunc(SYSDATE - 30)
/*   AND ail.line_type_lookup_code ='ITEM'
*/   AND (zl.tax_apportionment_line_number=1 OR zl.tax_apportionment_line_number IS NULL)
 GROUP BY ail.invoice_id, ail.line_number;
SELECT COUNT(*)
  FROM ap_invoice_lines_all ail
 WHERE  /*ail.creation_date>trunc(SYSDATE-30)
 AND */ail.line_type_lookup_code ='ITEM'; 
 
SELECT t.application_id,
       t.entity_code,
       t.event_class_code,
       t.trx_id,
       t.trx_level_type,
       t.trx_line_id,
       t.tax_regime_code,
       t.tax,
       t.tax_apportionment_line_number,
       t.tax_rate,
       t.tax_amt,
       t.*
  FROM zx_lines t
 WHERE t.trx_id IN (61000,69000,200000,50000)
 ORDER BY t.trx_id,t.trx_line_number;
   





