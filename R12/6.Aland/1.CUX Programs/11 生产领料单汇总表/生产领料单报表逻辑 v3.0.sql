
SELECT
mmt.transaction_id, 
mtt.transaction_type_name/*
      ,SUM(xal.entered_dr)
      ,SUM(xal.entered_cr)
      ,SUM(xal.accounted_dr)
      ,SUM(xal.accounted_cr)
      ,SUM(amount.amount)*/
      
      ,xal.accounted_dr
      ,xal.accounted_cr
      ,amount.amount
FROM   gme_batch_header               gbh
      ,mtl_material_transactions      mmt
      ,mtl_transaction_types          mtt
      ,fnd_lookup_values_vl           flv
      ,mtl_secondary_inventories      sub
      ,mtl_system_items_vl            msi
      ,org_organization_definitions   ood
      ,gmf_legal_entities             gle
      ,mtl_transaction_lot_numbers    mtl
      ,cux_inv_transaction_amount_all amount
       --added by yachao.wu start 
      ,xla.xla_transaction_entities xte
      ,xla.xla_ae_headers           xah
      ,xla.xla_ae_lines             xal
--added by yachao.wu end  
WHERE  EXISTS (SELECT 1
        FROM   gme_material_details gmd
        WHERE  gmd.batch_id = gbh.batch_id
        AND    mmt.transaction_source_id = gmd.batch_id
        AND    mmt.organization_id = gmd.organization_id
        AND    mmt.inventory_item_id = gmd.inventory_item_id)
        AND xte.application_id = 555
AND    sub.secondary_inventory_name = mmt.subinventory_code
AND    sub.organization_id = mmt.organization_id
AND    mtt.transaction_type_id = mmt.transaction_type_id
AND    flv.lookup_type = 'CUX_INV_TRANSACTION_TYPE'
AND    flv.lookup_code = upper(mtt.transaction_type_name)
AND    msi.inventory_item_id = mmt.inventory_item_id
AND    msi.organization_id = mmt.organization_id
AND    ood.organization_id = msi.organization_id
AND    NOT EXISTS (SELECT DISTINCT mp.master_organization_id
        FROM   mtl_parameters mp
        WHERE  mp.master_organization_id = ood.organization_id) --非主组织
AND    gle.legal_entity_id = ood.legal_entity
AND    mtl.transaction_id(+) = mmt.transaction_id
AND    amount.transaction_id(+) = mmt.transaction_id
AND    mtt.transaction_type_name IN ('WIP Issue'
                                    ,'WIP Return')
      
      --added by yachao.wu 20190422 start 关联到XLA
AND    xal.ae_header_id = xah.ae_header_id
AND    xal.application_id = xah.application_id
      
AND    xte.source_id_int_1 = mmt.transaction_id
AND    xte.entity_code = 'PRODUCTION'
AND    xah.application_id = xte.application_id
AND    xah.entity_id = xte.entity_id
AND    to_char(xah.accounting_date
              ,'YYYY-MM') = '2018-11'
      --added by yachao.wu 20190412 end 
AND    ood.operating_unit = 81
--GROUP  BY mmt.transaction_id,mtt.transaction_type_name
