SELECT distinct a.RESPONSIBILITY_NAME
  FROM FND_RESPONSIBILITY_VL a,
       (SELECT LEVEL,
               lpad(' ', LEVEL * 2, ' ') || menu_id,
               lpad(' ', LEVEL * 2, ' ') || PROMPT,
               menu_id
          FROM fnd_menu_entries_vl v
         WHERE 1 = 1
           AND v.PROMPT IS NOT NULL
           --AND LEVEL = 2
         START WITH menu_id IN --86570
                    (SELECT fme.menu_id
                       FROM fnd_menu_entries fme
                      WHERE fme.function_id =
                            (SELECT f3.function_id
                               FROM fnd_form_functions f3
                              WHERE f3.function_name = 'XXDIS_XXINVIAR')) --XXDIS_XXINVIAR XXDIS_XXPAFGD
        CONNECT BY PRIOR menu_id = sub_menu_id) t
 WHERE a.MENU_ID = t.menu_id;
