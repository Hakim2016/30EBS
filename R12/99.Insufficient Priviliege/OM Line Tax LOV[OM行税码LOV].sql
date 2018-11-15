SELECT DISTINCT lookup_code tax_code,
                description meaning,
                org_id
  FROM zx_output_classifications_v
 WHERE lookup_type = 'ZX_OUTPUT_CLASSIFICATIONS'
      --AND org_id IN (:1, -99)
   AND enabled_flag = 'Y'
   AND SYSDATE BETWEEN start_date_active AND nvl(end_date_active, SYSDATE)
