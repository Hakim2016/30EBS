
SELECT dfv.title,
       dfv.descriptive_flexfield_name,
       dfv.default_context_field_name,
       dfcv.descriptive_flex_context_code,
       dfcv.descriptive_flex_context_name,
       dfcu.end_user_column_name,
       dfcu.form_left_prompt,
       dfcu.application_column_name,
       dfcu.descriptive_flex_context_code,
       dfcu.flex_value_set_id
  FROM apps.fnd_descriptive_flexs_vl    dfv,
       apps.fnd_descr_flex_contexts_vl  dfcv,
       apps.fnd_descr_flex_col_usage_vl dfcu
 WHERE -1 = -1
   AND dfv.descriptive_flexfield_name = dfcv.descriptive_flexfield_name
   AND dfcv.descriptive_flexfield_name = dfcu.descriptive_flexfield_name
   AND dfcv.descriptive_flex_context_code = dfcu.descriptive_flex_context_code
      and dfv.TITLE like 'Transaction Information'
      --说明性弹性域标题
      --'HEA Tax Invoice Header Flexfield' --CUX form fail to find the description flexfield
      --'HEA Tax Invoice Header%'
      
   --AND dfcv.descriptive_flexfield_name like --'GL_IEA_TRANSACTION_LINES' --说明性弹性域代码
   --'XXAR_TAX_INVOICE_HEADERS%'
   --'RA_CUSTOMER_TRX'
--and dfcu.END_USER_COLUMN_NAME = '退回类型'
--and dfcv.DESCRIPTIVE_FLEX_CONTEXT_NAME like '%退回类型%'/*'%寿险%业务%'*/
--and dfcv.DESCRIPTIVE_FLEX_CONTEXT_CODE like '长期待摊费用.车辆租赁%'
;
