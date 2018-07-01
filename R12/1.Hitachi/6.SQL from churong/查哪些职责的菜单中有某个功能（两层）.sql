select distinct r.RESPONSIBILITY_NAME, m.MENU_NAME
  from FND_RESPONSIBILITY_VL r,
       FND_MENUS_VL m,
       FND_MENU_ENTRIES_VL me,
       (select m.MENU_NAME m_name, m.MENU_ID m_id
          from FND_MENUS_VL m, FND_MENU_ENTRIES_VL me
         where 1 = 1
           and me.FUNCTION_ID = 47312 --Tax Invoice(HEA)
           and me.MENU_ID = m.MENU_ID) t
 where 1 = 1
   and (me.FUNCTION_ID = 47312 --Tax Invoice(HEA)
       or me.SUB_MENU_ID = t.m_id)
   and me.MENU_ID = m.MENU_ID
   and m.MENU_ID = r.MENU_ID
   
   

