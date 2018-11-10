--ALTER SESSION SET CURRENT_SCHEMA=apps
---AP\AR\GL\PA\PO Period status
SELECT t.application_code,
       t.period_name,
       t.province 省份,
       t.ledger 帐套,
       t.period_counter 期间总数,
       t.period_counter - t.unclosed 关闭期间数,
       t.unclosed 未关闭期间数,
       round((1 - t.unclosed / t.period_counter) * 100,
             2) || '%' 进度
  FROM (SELECT gps.application_code,
               gps.period_name,
               hou1.attribute7 province,
               decode(substr(gps.ledger_name,
                             5,
                             2),
                      'HJ',
                      '合建',
                      'TD',
                      'TD',
                      '上市') ledger,
               
               COUNT(1) period_counter,
               SUM(decode(gps.period_show_status,
                          'OPEN',
                          1,
                          0)) unclosed
          FROM apps.cux_gl_period_status_v    gps,
               apps.hr_all_organization_units hou1
         WHERE 1 = 1
           AND gps.org_id = hou1.organization_id(+)
           AND (gps.period_name = '2018-10')
         GROUP BY gps.application_code,
                  hou1.attribute7,
                  gps.ledger_id,
                  gps.ledger_name,
                  gps.application_code,
                  gps.period_name) t
WHERE t.province = 'ZJ'
UNION ALL
---PA Period status
SELECT 'PA' application_code,
       t.period_name,
       t.province_code 省份,
       t.short_name,
       t.period_count pa期间总数,
       t.close_count pa关闭期间数,
       (t.period_count - t.close_count) 未关闭期间数,
       round(t.close_count / t.period_count * 100) || '%' AS pa已关闭百分比
  FROM (SELECT hou.province_code,
               ppa.period_name,
               decode(substr(gso.short_name,
                             5,
                             2),
                      'HJ',
                      '合建',
                      'TD',
                      'TD',
                      '上市') short_name,
               COUNT(1) period_count,
               SUM(decode(ppa.status,
                          'C',
                          1,
                          0)) close_count
          FROM apps.cux_fnd_operating_units_v hou,
               apps.gl_sets_of_books          gso,
               apps.pa_periods_all            ppa
         WHERE ppa.org_id(+) = hou.org_id
           AND ppa.period_name = '2018-10'
           AND gso.set_of_books_id = hou.set_of_books_id
         GROUP BY hou.province_code,
                  ppa.period_name,
                  hou.set_of_books_id,
                  decode(substr(gso.short_name,
                                5,
                                2),
                         'HJ',
                         '合建',
                         'TD',
                         'TD',
                         '上市')) t
WHERE t.province_code = 'ZJ'
UNION ALL
---FA Period status
SELECT 'FA' application_code,
       t.period_name,
       t.province_code 省份,
       t.short_name,
       t.period_count 期间总数,
       (t.period_count - t.not_close_count) 关闭期间数,
       t.not_close_count fa未关闭期间数,
       round((t.period_count - t.not_close_count) / t.period_count * 100,
             0) || '%' AS fa已关闭百分比
  FROM (SELECT hou.attribute7 province_code,
               decode(substr(gsb.short_name,
                             5,
                             2),
                      'HJ',
                      '合建',
                      'TD',
                      'TD',
                      '上市') short_name,
               COUNT(1) AS period_count,
               SUM(CASE
                     WHEN fdp.period_close_date IS NULL THEN
                      1
                     ELSE
                      0
                   END) not_close_count,
               fdp.period_name
          FROM apps.hr_organization_units hou,
               apps.fa_book_controls      fbc,
               apps.gl_sets_of_books      gsb,
               apps.fa_deprn_periods      fdp
         WHERE fbc.org_id = hou.organization_id
           AND gsb.set_of_books_id = fbc.set_of_books_id
           AND fdp.book_type_code = fbc.book_type_code
           AND fdp.period_name = '2018-10'
         GROUP BY hou.attribute7,
                  decode(substr(gsb.short_name,
                                5,
                                2),
                         'HJ',
                         '合建',
                         'TD',
                         'TD',
                         '上市'),
                  fdp.period_name,
                  gsb.set_of_books_id) t
WHERE t.province_code = 'ZJ'
UNION ALL
---INV Period status
SELECT t.application_code,
       t.period_name,
       t.province_code,
       t.ledger,
       t.period_count,
       t.closed_count,
       (t.period_count - t.closed_count) unclosed_count,
       round(closed_count / period_count * 100,
             0) || '%' AS 已关闭百分比
  FROM (SELECT 'INV' application_code,
               oap.period_name,
               hou.attribute7 province_code,
               
               decode(substr(lg.name,
                             5,
                             2),
                      'HJ',
                      '合建',
                      'TD',
                      'TD',
                      '上市') ledger,
               COUNT(*) period_count,
               SUM(decode(oap.open_flag,
                          'N',
                          1,
                          0)) closed_count
          FROM apps.org_acct_periods             oap,
               apps.org_organization_definitions ood,
               apps.hr_organization_units        hou,
               apps.gl_ledgers                   lg
         WHERE oap.organization_id = ood.organization_id
           AND ood.operating_unit = hou.organization_id
           AND lg.ledger_id = ood.set_of_books_id
           AND oap.period_name = '2018-10'
         GROUP BY oap.period_name,
                  hou.attribute7,
                  decode(substr(lg.name,
                                5,
                                2),
                         'HJ',
                         '合建',
                         'TD',
                         'TD',
                         '上市')) t
WHERE t.province_code = 'ZJ'
UNION ALL
---GL Period status
SELECT t.application_code,
       t.period_name,
       t.province_code,
       t.ledger,
       t.period_count,
       t.closed_count,
       (t.period_count - t.closed_count) unclosed_count,
       round(t.closed_count / t.period_count * 100,
             0) || '%' AS closed_pct
  FROM (SELECT 'GL' application_code,
               gps.period_name,
               gl.name province_code,
               decode(substr(gl.name,
                             5,
                             2),
                      'HJ',
                      '合建',
                      'TD',
                      'TD',
                      '上市') ledger,
               COUNT(*) period_count,
               SUM(decode(gps.closing_status,
                          'C',
                          1,
                          'P',
                          1,
                          0)) closed_count
          FROM apps.gl_period_statuses gps,
               apps.gl_ledgers         gl
         WHERE gps.ledger_id = gl.ledger_id
           AND application_id = 101
           AND period_name = '2018-10'
         GROUP BY gps.period_name,
                  gl.name,
                  decode(substr(gl.name,
                                5,
                                2),
                         'HJ',
                         '合建',
                         'TD',
                         'TD',
                         '上市')) t
WHERE t.province_code = 'ZJ'
;

