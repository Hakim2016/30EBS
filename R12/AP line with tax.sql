
--ap haeder/ line with tax info
SELECT aph.invoice_id,
       apl.creation_date,
       apl.tax_regime_code,
       apl.tax,
       apl.tax_jurisdiction_code,
       apl.tax_status_code,
       apl.tax_rate_code,
       apl.tax_rate,
       apl.line_number,
       /*apl.last_update_date,
       apl.last_updated_by,*/
       apl.description,
       apl.amount line_amt,
       aph.invoice_num,
       apl.line_type_lookup_code,
       aph.attribute_category,
       aph.attribute8,
       aph.*,
       apl.*
  FROM ap_invoices_all      aph,
       ap_invoice_lines_all apl
--,ZX_LINES_V zxl
 WHERE 1 = 1
      --AND apl.tax = zxl.
   AND aph.invoice_id = apl.invoice_id
   AND aph.org_id = 84 --101 --82
      --AND aph.invoice_num = '18090012'--'SPE-17000168'
      --IN 
      
      --AND apl.amount <> 0
      --AND apl.line_number = 19
      --AND aph.creation_date >= SYSDATE - 160
      --AND aph.project_id IS NOT NULL
      --AND aph.po_header_id IS NULL
   AND EXISTS (SELECT 1
        
          FROM ap_invoice_lines_all apl2,
               ap_invoices_all      aph2
         WHERE 1 = 1
           AND aph2.invoice_id = aph.invoice_id
           AND aph2.invoice_id = apl2.invoice_id
           AND apl2.line_type_lookup_code = 'TAX'
        --AND apl2.amount <> 0
        --AND apl2.tax_rate <> 7
        )
 ORDER BY aph.invoice_id DESC,
          aph.invoice_num,
          apl.line_number,
          apl.amount;
