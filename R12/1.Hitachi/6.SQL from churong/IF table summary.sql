SELECT xic.interface_code,
       xic.user_concurrent_program_name,
       decode(xic.type, 'I', 'Inbound', 'O', 'Outbound') type,
       xic.object_owner,
       xic.remote_system_code,
       XIC.*
  FROM apps.xxfnd_interface_config_v xic
 WHERE 1 = 1
 ORDER BY 1
