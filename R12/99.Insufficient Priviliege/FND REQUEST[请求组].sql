SELECT a.user_concurrent_program_name,
       c.request_group_name,
       a.concurrent_program_name,
       c.request_group_code,
       a.*
  FROM fnd_concurrent_programs_vl a,
       fnd_request_group_units    b,
       fnd_request_groups         c
 WHERE 1 = 1
   AND a.user_concurrent_program_name 
   --= 'PRC: Interface Supplier Costs' --'Projects Cost Collection Manager'--'PRC: Transaction Import'
      --LIKE '%Cost Collector%'
      IN (
      --'Cost Collection Manager'
      --'Projects Cost Collection Manager'
      --,
      --'PRC: Transaction Import',
      'PRC: Interface Supplier Costs'--,
      --'AUD: Supplier Costs Interface Audit',
      --'PRC: Update Project Summary Amounts'
      )
      --AND a.concurrent_program_name = 'CMCPCM'--'XXPJMR017'
   AND a.concurrent_program_id = b.request_unit_id(+)
   AND a.application_id = b.unit_application_id(+)
   AND b.request_group_id = c.request_group_id(+);
