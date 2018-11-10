SELECT pei.expenditure_item_id,
       pei.expenditure_id,
       pei.task_id,
       pt.task_number,
       pei.expenditure_item_date,
       pei.transaction_source,
       pei.system_linkage_function,
       pei.expenditure_type,
       pei.quantity,
       pei.inventory_item_id,
       decode(pei.inventory_item_id,
              NULL,
              NULL,
              pa_utils4.get_inventory_item(pei.inventory_item_id)) inventory_item,
       pei.unit_of_measure,
       decode(pei.unit_of_measure,
              NULL,
              pa_utils4.get_unit_of_measure(pei.expenditure_type),
              pei.unit_of_measure) unit_of_measure,
       pa_utils4.get_unit_of_measure_m(pei.unit_of_measure,
                                       pei.expenditure_type) unit_of_measure_m,
       pea.expenditure_status_code,
       flv.meaning expenditure_status_name,
       pea.expenditure_ending_date,
       pea.expenditure_class_code,
       pea.incurred_by_person_id,
       pea.incurred_by_organization_id,
       pea.expenditure_group,
       pea.entered_by_person_id,
       pea.acct_currency_code,
       nvl(pei.override_to_organization_id, pea.incurred_by_organization_id)

  FROM pa_expenditure_items_all pei,
       pa_expenditures_all      pea,
       fnd_lookup_values_vl     flv,
       pa_tasks                 pt
 WHERE 1 = 1
   AND pei.project_id = 1194
   AND pei.expenditure_id = pea.expenditure_id
   AND pea.expenditure_status_code = flv.lookup_code
   AND flv.lookup_type = 'EXPENDITURE STATUS'
   AND pei.task_id = pt.task_id
--AND pei.expenditure_type = 'Material'
--ORDER BY pei.expenditure_item_id
;
SELECT *
  FROM pa_expenditure_items_all pei
 WHERE NOT EXISTS (SELECT 1
          FROM pa_expenditure_types t
         WHERE pei.expenditure_type = t.expenditure_type);
