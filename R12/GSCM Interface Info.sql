SELECT xic.interface_code,
       xic.enabled_flag,
       xic.frozen_flag,
       xic.description,
       --xic.type,
       flv_type.meaning type_name,
       --xic.remote_system_code,
       flv_remote_sys.meaning remote_system_name,
       xic.need_ledger,
       xic.report_flag,
       -- DB --- 
       xic.object_owner,
       xic.table_name,
       xic.group_seq_name,
       xic.row_seq_name,
       -- APP ---
       xic.application_name,
       xic.concurrent_program_name,
       xic.user_concurrent_program_name,
       ----------
       to_char(xic.data_fetch_sql)
  FROM xxfnd_interface_config_v xic,
       fnd_lookup_values_vl     flv_type,
       fnd_lookup_values_vl     flv_remote_sys
-- WHERE (interface_code = 'IF01')
 WHERE xic.type = flv_type.lookup_code
   AND flv_type.lookup_type = 'XXFND_INTERFACE_TYPE'
   AND xic.remote_system_code = flv_remote_sys.lookup_code
   AND flv_remote_sys.lookup_type = 'XXFND_SYSTEM_CODE'
 ORDER BY xic.interface_code ASC;
