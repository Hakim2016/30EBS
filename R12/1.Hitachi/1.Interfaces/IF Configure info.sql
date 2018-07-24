SELECT xic.interface_code,
       xic.user_concurrent_program_name,
       decode(xic.type, 'I', 'Inbound', 'O', 'Outbound') TYPE,
       xic.object_owner,
       xic.remote_system_code,
       fef.execution_file_name,
       xic.*
  FROM apps.xxfnd_interface_config_v xic,
       fnd_executables_form_v        fef
 WHERE 1 = 1
   AND fef.executable_name = xic.concurrent_program_name(+)
      --AND xic.remote_system_code = 'R3'
   AND xic.interface_code = 'IF81'
--AND xic.remote_system_code = 'HFG'
/*  AND xic.interface_code IN 

(
'IF61','IF62','IF63','IF64', 'IF67','IF68'
,
'IF77','IF78','IF79'
)*/
--AND xic.type = 'I'--'O'
--AND xic.USER_CONCURRENT_PROGRAM_NAME LIKE '%ixed%sset%'
--AND xic.enabled_flag = 'N'
 ORDER BY 1;
xxbom_eco_report_pkg;--.main

/*
IF11

XXPJM:Project generation (G-O/E->G-SCM)
XXPJM_PROJ_GENERATION_INT
*/

/*
IF12
VO: Version Order
from GOE
XXPJM:VO Interface Import(GOE->GSCM)


*/

/*
IF47
XXPJMB009
XXPJM
XXPJM_LABOUR_BUDGET_INT
XXPJM:Labor Hours Budget Interface

*/
