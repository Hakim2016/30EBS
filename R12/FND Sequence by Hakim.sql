SELECT dsc.application_id app_id,
       dsc.code,
       dsc.name,
       dsc.table_name,
       dsc.description,
       dsc.*
  FROM fnd_doc_sequence_categories dsc
 WHERE 1 = 1
   AND 1 = 1
 ORDER BY dsc.last_update_date DESC;

SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id = 660;

SELECT dsa.category_code, dsa.set_of_books_id, dsa.*
  FROM fnd_doc_sequence_assignments dsa
 WHERE 1 = 1
   AND 1 = 1
 ORDER BY dsa.set_of_books_id DESC;

SELECT *
  FROM gl_sets_of_books sob
 WHERE 1 = 1
 ORDER BY sob.set_of_books_id DESC;
