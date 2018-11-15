SELECT itf.*
  FROM apps.gl_ledgers gl,
       apps.fa_book_controls      fbc,
       cux.cux_fa_ws_asset_itf itf
 WHERE itf.book_type_code = fbc.book_type_code
   AND gl.ledger_id = fbc.set_of_books_Id
   --AND itf.creation_date > TRUNC(SYSDATE)+ 0.5
   AND itf.creation_date >
       to_date('2018-10-29 18:00:00', 'YYYY-MM-DD HH24:MI:SS')
   AND gl.name LIKE '%ZJ%'
