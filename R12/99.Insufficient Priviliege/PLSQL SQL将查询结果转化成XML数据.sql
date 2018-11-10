SELECT dbms_xmlgen.getxml('SELECT msi.inventory_item_id,
       msi.organization_id,
       msi.segment1
  FROM mtl_system_items_b msi
 WHERE 1 = 1
   AND rownum < 5')
  FROM dual;
