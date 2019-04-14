select gl.name,
       xah.period_name,
       mmt.TRANSACTION_ID,
       msif.SEGMENT1,
       msif.DESCRIPTION,
       mtt.TRANSACTION_TYPE_NAME,
       mmt.PRIMARY_QUANTITY,
       mmt.TRANSACTION_DATE,
       xal.entered_dr,
       xal.entered_cr,
       xal.accounted_dr,
       xal.accounted_cr,
     /*  GL_FLEXFIELDS_PKG.GET_DESCRIPTION_SQL(gcck.code_combination_id,
                                                         3,
                                                         GCCk.SEGMENT3) coa_des,*/
       gcck.concatenated_segments,
       gcck.segment3,

       (SELECT FFVV.DESCRIPTION
          FROM APPS.FND_FLEX_VALUE_SETS FFVS, APPS.FND_FLEX_VALUES_VL FFVV
         WHERE FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID
           AND FFVS.FLEX_VALUE_SET_NAME = 'ALAND_COA_ACC'
           AND FFVV.FLEX_VALUE = GCCK.SEGMENT3) ACC_DES,
           xah.accounting_date/*,
           to_char(xah.accounting_date,'yyyy-mm')*/
  from apps.mtl_material_transactions     mmt,
       apps.mtl_transaction_types         mtt,
       xla.xla_transaction_entities  xte,
       gl.gl_ledgers                 gl,
       xla.xla_events                xe,
       xla.xla_ae_headers            xah,
       xla.xla_ae_lines              xal,
       apps.gl_code_combinations_kfv gcck,
       apps.mtl_system_items_fvl          msif
 where 1 = 1
   and xte.ledger_id = gl.ledger_id
   and xte.application_id = xe.application_id
   and xte.entity_id = xe.entity_id
   and xe.application_id = xah.application_id
   and xe.event_id = xah.event_id
   and xah.ae_header_id = xal.ae_header_id
   and xal.code_combination_id = gcck.code_combination_id(+)
   and xte.source_id_int_1 = mmt.TRANSACTION_ID
   and mmt.TRANSACTION_TYPE_ID = mtt.TRANSACTION_TYPE_ID
   and msif.INVENTORY_ITEM_ID = mmt.INVENTORY_ITEM_ID
   and msif.ORGANIZATION_ID = mmt.ORGANIZATION_ID
   --and mmt.TRANSACTION_DATE>=to_date('2018-11-01 00:00:00','YYYY-MM-DD HH24:MI:SS')
   --and mmt.TRANSACTION_DATE<=to_date('2018-11-30 23:59:59','YYYY-MM-DD HH24:MI:SS')
   and nvl(xal.entered_dr,99999999999999) <> 0
   --AND mmt.TRANSACTION_ID = 5504592
   AND xah.period_name = '2018-11'
   --AND to_char(xah.accounting_date,'yyyy-mm') <> to_char(mmt.TRANSACTION_DATE,'yyyy-mm')
   --AND ROWNUM = 1
      --²ÎÊý
  -- and mmt.TRANSACTION_SOURCE_TYPE_ID = 12
 --  and mmt.TRANSACTION_ID = 2009908
