SELECT * FROM ar_memo_lines_all_b v WHERE 1 = 1;

SELECT memo_line_id      memo_line_id,
       org_id            org_id,
       NAME              NAME,
       description       description,
       LANGUAGE          LANGUAGE,
       source_lang       source_lang,
       last_update_date  last_update_date,
       creation_date     creation_date,
       created_by        created_by,
       last_updated_by   last_updated_by,
       last_update_login last_update_login,
       zd_edition_name   zd_edition_name,
       zd_sync           zd_sync
  FROM "AR"."AR_MEMO_LINES_ALL_TL" t
 WHERE 1 = 1
   AND t.language = userenv('LANG') --LANGUAGE('ZHS')
 ORDER BY t.org_id DESC, t.memo_line_id;

SELECT * FROM ra_rules WHERE 1 = 1;

--AutoAccounting
SELECT h.org_id, h.type, l.segment, l.table_name, l.constant, h.*, l.*
  FROM ra_account_defaults_all h, ra_account_default_segments l
 WHERE 1 = 1
   AND h.gl_default_id = l.gl_default_id
   --AND h.org_id = 7905
   ;
