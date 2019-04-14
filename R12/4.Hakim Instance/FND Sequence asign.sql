SELECT seq.doc_sequence_id,
       seq.type,
       seq.name,
       seq.audit_table_name,
       seq.db_sequence_name,
       seq.table_name,
       sa.doc_sequence_assignment_id,
       seq.message_flag,
       sa.start_date,
       sa.end_date
  FROM fnd_document_sequences seq, fnd_doc_sequence_assignments sa
 WHERE seq.doc_sequence_id = sa.doc_sequence_id
   AND sa.application_id = :b5
   AND sa.category_code = :b4
   AND (sa.set_of_books_id = :b3 OR sa.set_of_books_id IS NULL)
   AND (sa.method_code = :b2 OR sa.method_code IS NULL OR :b2 IS NULL)
   AND :b1 BETWEEN sa.start_date AND nvl(sa.end_date + .9999, :b1 + .9999)
