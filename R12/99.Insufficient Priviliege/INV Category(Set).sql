SELECT --COUNT(*),
--mic.inventory_item_id,
 (SELECT msi.segment1
    FROM mtl_system_items_b msi
   WHERE 1 = 1
     AND msi.inventory_item_id = mic.inventory_item_id
     AND msi.organization_id = mp.organization_id) item,
 mdcs.functional_area_id,
 mic.category_set_id,
 mic.category_set_name,
 mic.category_concat_segs,
 --category account
 mp.*,
 mic.*
  FROM mtl_categories            mc,
       mtl_item_categories_v     mic,
       mtl_default_category_sets mdcs,
       mtl_parameters            mp /*,
       mtl_system_items_b msi*/
 WHERE 1 = 1
      /*AND msi.inventory_item_id = mic.inventory_item_id
      AND msi.organization_id = mp.organization_id*/
   AND mc.category_id = mic.category_id
      --AND mdcs.functional_area_id = 8
   AND mic.category_set_id = mdcs.category_set_id
   AND mic.organization_id = mp.organization_id
   AND mp.organization_id = 86 --2760
   AND mic.inventory_item_id = 1621957
--AND mic.category_set_id = 1100000041
--GROUP BY mic.inventory_item_id = 1621957
--HAVING COUNT(*) > 1
;

SELECT *
  FROM mtl_categories mc;

SELECT *
  FROM mtl_default_category_sets mdcs
 WHERE 1 = 1
--AND mdcs.category_set_id = 1100000041
 ORDER BY mdcs.category_set_id;

SELECT mic.inventory_item_id,
       mic.category_id,
       mic.category_set_id,
       mic.category_set_name,
       mic.category_concat_segs,
       mic.category_set_id,
       mdcs.category_set_id,
       mdcs.functional_area_id
  FROM mtl_item_categories_v     mic,
       mtl_default_category_sets mdcs
 WHERE 1 = 1
   AND mdcs.category_set_id(+) = mic.category_set_id
   AND mic.inventory_item_id = --1621957
       (SELECT msi.inventory_item_id
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           --AND msi.inventory_item_id = mic.inventory_item_id
           AND msi.organization_id = 86--mic.organization_id
           AND msi.segment1 = '32722974-A-0000')
   AND mic.organization_id = 86
   --AND mdcs.functional_area_id = 8
 ORDER BY mic.category_set_id;
 
 SELECT msi.inventory_item_id,msi.segment1
          FROM mtl_system_items_b msi
         WHERE 1 = 1
           --AND msi.inventory_item_id = mic.inventory_item_id
           AND msi.organization_id = 86--mic.organization_id
           AND msi.segment1 LIKE '32722974%A%000';

SELECT --row_id,
 category_set_name,
 control_level,
 control_level_disp,
 organization_id,
 category_set_id,
 category_id,
 last_update_date,
 inventory_item_id,
 last_updated_by,
 creation_date,
 created_by,
 last_update_login,
 request_id,
 program_application_id,
 program_id,
 program_update_date,
 structure_id,
 validate_flag,
 mult_item_cat_assign_flag,
 category_concat_segs,
 hierarchy_enabled
  FROM mtl_item_categories_v
 WHERE inventory_item_id = 1621957
   AND organization_id = 86
   AND (organization_id = 86)
   AND (inventory_item_id = 1621957)
 ORDER BY category_set_id,
          control_level,
          category_set_name,
          category_concat_segs;
