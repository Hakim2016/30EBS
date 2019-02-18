SELECT fm.menu_name,
       fm.user_menu_name,
       fme.entry_sequence seq,
       fme.prompt,
       fme.sub_menu_id,
       fme.function_id,
       decode(fme.function_id,
              NULL,
              (SELECT fm2.menu_name || '.' || fm2.user_menu_name
                 FROM fnd_menus_vl fm2
                WHERE 1 = 1 --submenu
                  AND fm2.menu_id = fme.sub_menu_id --1037425--
               ),
              (SELECT fff.function_name || '.' || fff.user_function_name
                 FROM fnd_form_functions_vl fff
                WHERE 1 = 1
                  AND fff.function_id = fme.function_id
               )) menu_func,
       fm.*,
       fme.*
  FROM fnd_menus_vl fm, fnd_menu_entries_vl fme
 WHERE 1 = 1
   AND fm.menu_id = fme.menu_id
   --AND fm.menu_name LIKE '%HKM%002'
   AND EXISTS
   (
   SELECT 1 from fnd_form_functions_vl fff2 where 1=1 
   AND fff2.function_id = fme.FUNCTION_ID
   AND fff2.FUNCTION_NAME LIKE 'HDSP%' 
   --anf fff2.USER_FUNCTION_NAME LIKE
   )
   ;
