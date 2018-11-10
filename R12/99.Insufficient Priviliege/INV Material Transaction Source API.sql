SELECT inv_object_genealogy.getsource(mmt.organization_id, mmt.transaction_source_type_id, mmt.transaction_source_id),
       mmt.transaction_source_type_id,
       mmt.*
  FROM mtl_material_transactions mmt
 WHERE 1 = 1
   --AND inv_object_genealogy.getsource(mmt.organization_id, mmt.transaction_source_type_id, mmt.transaction_source_id) IS NOT NULL
   AND mmt.transaction_id = 3186033--3186061--3202317
