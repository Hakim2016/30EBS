SELECT led.name,
       dsa.doc_sequence_id,
       dsa.doc_sequence_assignment_id,
       dsa.end_date,
       app.language,
       app.application_name,
       jct.user_je_category_name,
       dsa.category_code,
       dsa.doc_sequence_id,
       ds.db_sequence_name,
       dsa.method_code,
       dsa.start_date                 assgn_st_date,
       dsa.end_date                   assgn_end_date,
       ds.start_date                  seq_st_date,
       ds.end_date                    seq_end_date,
       ds.type
  FROM fnd_doc_sequence_assignments dsa,
       fnd_document_sequences       ds,
       gl_je_categories_tl          jct,
       gl_ledgers                   led,
       fnd_application_tl           app
 WHERE dsa.doc_sequence_id = ds.doc_sequence_id
   AND jct.je_category_name = dsa.category_code
   AND app.application_id = ds.application_id
   AND led.ledger_id = dsa.set_of_books_id
      --AND dsa.end_date < (sysdate - 30) -- Shows seq assignments which ended less than 30 days before the current date
   AND led.ledger_id = 1020 --&LedgerId

;
