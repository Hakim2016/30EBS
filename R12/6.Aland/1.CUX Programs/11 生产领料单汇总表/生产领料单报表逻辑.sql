   SELECT 
   count(1)
   /*gbh.batch_no
            , --单据
             --mtt.transaction_type_name, --事物处理类型
             flv.meaning transaction_type_name
            ,trunc(mmt.transaction_date) transaction_date
            , --事物处理日期
             mmt.subinventory_code
            , --子库存
             sub.description sub_desc
            , --子库存,
             gbh.attribute4 || '车间' requisit_dept
            , --领用部门
             msi.organization_id
            ,msi.inventory_item_id
            ,msi.segment1
            , --物料编号
             msi.description
            , --物料名称
             msi.attribute4
            , --规格型号
             -- msi.primary_uom_code,
             msi.primary_unit_of_measure
            , --计量单位
             mtl.lot_number
            , --批次
             SUM(mtl.primary_quantity) primary_quantity
            , --数量
             SUM(amount.amount) amount
            , --金额
             mmt.transaction_id
            ,gle.primary_ledger_id
            */
            --,cux_wms_util_pkg.get_wms_user_num(p_transaction_id => mmt.transaction_id) user_num
            --,cux_wms_util_pkg.get_wms_user_name(p_transaction_id => mmt.transaction_id) user_name
      
      FROM   gme_batch_header gbh
            ,
             --  gme_material_details           gmd,
             mtl_material_transactions      mmt
            ,mtl_transaction_types          mtt
            ,fnd_lookup_values_vl           flv
            ,mtl_secondary_inventories      sub
            ,mtl_system_items_vl            msi
            ,org_organization_definitions   ood
            ,gmf_legal_entities             gle
            ,mtl_transaction_lot_numbers    mtl
            ,cux_inv_transaction_amount_all amount
      WHERE  EXISTS (SELECT 1
              FROM   gme_material_details gmd
              WHERE  gmd.batch_id = gbh.batch_id
              AND    mmt.transaction_source_id = gmd.batch_id
              AND    mmt.organization_id = gmd.organization_id
              AND    mmt.inventory_item_id = gmd.inventory_item_id)
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
      AND    (('Y'/*g_post_flag*/ = 'Y') AND EXISTS (SELECT 1
                                              FROM   xla.xla_transaction_entities xte
                                                    ,xla.xla_ae_headers           xah
                                              WHERE  xah.application_id = xte.application_id
                                              AND xte.application_id = 401--707
                                              AND    xah.entity_id = xte.entity_id
                                              AND    xte.source_id_int_1 = mmt.transaction_id
                                              AND    xte.ledger_id = gle.primary_ledger_id
                                              AND xah.period_name = '2018-11'
                                              --AND    (xah.accounting_date >= g_gl_start_date OR g_gl_start_date IS NULL)
                                              --AND    (xah.accounting_date <= g_gl_end_date OR g_gl_end_date IS NULL)
                                              ) 
                                              OR
             nvl('Y'/*g_post_flag*/
                                                ,'N') = 'N')
            --added by yachao.wu 20190412 end 
      AND    1 = 1
      AND    ood.operating_unit = 81--g_org_id
            -- AND    mmt.transaction_date BETWEEN g_transaction_start_date AND g_transaction_end_date
      --AND    (mmt.transaction_date >= g_transaction_start_date OR g_transaction_start_date IS NULL)
      --AND    (mmt.transaction_date <= g_transaction_end_date OR g_transaction_end_date IS NULL)
      /*AND    gbh.attribute4 = nvl(g_requisit_dept
                                 ,gbh.attribute4)*/
      GROUP  BY gbh.batch_no
               , --单据
                flv.meaning
               , --事物处理类型
                trunc(mmt.transaction_date)
               , --事物处理日期
                mmt.subinventory_code
               , --子库存
                sub.description
               , --子库存,
                gbh.attribute4 || '车间'
               , --领用部门
                msi.organization_id
               ,msi.inventory_item_id
               ,msi.segment1
               , --物料编号
                msi.description
               , --物料名称
                msi.attribute4
               , --规格型号
                -- msi.primary_uom_code,
                msi.primary_unit_of_measure
               , --计量单位
                mtl.lot_number
               , --批次
                mmt.transaction_id
               ,gle.primary_ledger_id
      ORDER  BY gbh.batch_no
               ,flv.meaning
               ,trunc(mmt.transaction_date)
               ,msi.segment1;
