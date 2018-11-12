SELECT msi.segment1 parent_item,
       msi1.inventory_item_id
--INTO l_top_task_number
  FROM mtl_system_items_b       msi,
       bom_bill_of_materials    bom,
       bom_inventory_components bic,
       mtl_system_items_b       msi1
 WHERE 1 = 1
   AND msi.organization_id = 86
   AND msi.inventory_item_id = bom.assembly_item_id
   AND msi.organization_id = bom.organization_id
   AND bom.alternate_bom_designator IS NULL
   AND bom.bill_sequence_id = bic.bill_sequence_id
   AND bic.disable_date IS NULL
   AND bic.component_item_id = msi1.inventory_item_id
   AND msi1.organization_id = bom.organization_id
   AND msi1.segment1 = 'TAJ0292-TH-D-L#ADH0001_001'; --ÓÉ×Ó¼°¸¸

SELECT LEVEL, lpad(' ', LEVEL * 2, ' ') || 'xxx',bom.organization_id,
       bom.assembly_item_id,
       (
       SELECT msi.segment1 FROM mtl_system_items_b       msi
       WHERE 1=1
       AND msi.inventory_item_id = bom.assembly_item_id
       AND msi.organization_id = 86
       )
  FROM bom_bill_of_materials    bom,
       bom_inventory_components bic
 WHERE 1 = 1
   AND bom.bill_sequence_id = bic.bill_sequence_id
   AND bom.organization_id = 86
 START WITH bic.bill_sequence_id = (SELECT bic.bill_sequence_id
                                      FROM bom_bill_of_materials    bom,
                                           bom_inventory_components bic
                                     WHERE 1 = 1
                                       AND bom.bill_sequence_id = bic.bill_sequence_id
                                       AND bic.component_item_id = 4089046
                                       AND bom.organization_id = 86)
--CONNECT BY PRIOR bic.component_item_id = bom.assembly_item_id
CONNECT BY PRIOR bom.assembly_item_id = bic.component_item_id
;

SELECT * FROM mtl_system_items_b       msi
       WHERE 1=1
       --AND msi.inventory_item_id = bom.assembly_item_id
       AND msi.organization_id = 86
       AND msi.segment1 = 'TAJ0292-TH-D-LP221101_000'--'TAJ0292-TH-D-L#ADH0001_001'
;

SELECT lpad(' ', LEVEL * 2, ' ') || menu_id,
       prompt
  FROM fnd_menu_entries_vl
 START WITH menu_id = (SELECT fme.menu_id
                         FROM fnd_menu_entries fme
                        WHERE fme.function_id =
                              (SELECT f3.function_id
                                 FROM fnd_form_functions    f3,
                                      fnd_form_functions_tl f3l
                                WHERE 1 = 1
                                  AND f3.function_id = f3l.function_id
                                  AND f3l.language = userenv('LANG')
                                  AND f3l.user_function_name = 'XXINV: Pack Case Define Rules(SHE)'))
CONNECT BY PRIOR menu_id = sub_menu_id;
