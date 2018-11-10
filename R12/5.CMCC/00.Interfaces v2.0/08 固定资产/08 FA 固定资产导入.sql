SELECT itf.source_pri_key             pri_key,
       itf.last_update_date,
       itf.claim_num                  报账单号,
       itf.book_type_code,
       itf.tag_number,
       itf.process_status_lookup_code 处理状态,
       itf.process_message,
       itf.date_place_in_service,
       itf.life_in_month,
       itf.deprn_flag,
       
       itf.*
  FROM apps.gl_ledgers         gl,
       apps.fa_book_controls   fbc,
       cux.cux_fa_ws_asset_itf itf
 WHERE itf.book_type_code = fbc.book_type_code
   AND gl.ledger_id = fbc.set_of_books_id
      --AND itf.creation_date > TRUNC(SYSDATE)+ 0.5
      /*AND itf.creation_date >
          to_date('2018-10-29 18:00:00', 'YYYY-MM-DD HH24:MI:SS')
      AND gl.name LIKE '%ZJ%'*/
   AND itf.source_pri_key IN
      
       (SELECT itf.source_pri_key
          FROM apps.gl_ledgers         gl,
               apps.fa_book_controls   fbc,
               cux.cux_fa_ws_asset_itf itf
         WHERE itf.book_type_code = fbc.book_type_code
           AND gl.ledger_id = fbc.set_of_books_id
           AND gl.name LIKE '%ZJ%'
           AND itf.process_status_lookup_code <> 'SUCCESS'
           AND NOT EXISTS
         (SELECT 1
                  FROM cux.cux_fa_ws_asset_itf itf2
                 WHERE 1 = 1
                   AND itf2.source_pri_key = itf.source_pri_key
                   AND itf2.process_status_lookup_code = 'SUCCESS'))
;
