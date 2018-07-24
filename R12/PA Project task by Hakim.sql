SELECT ppa.closed_date,
       ppa.segment1,
       ppa.project_type,
       ppa.name,
       pt.*
  FROM pa_projects_all ppa,
       pa_tasks        pt
 WHERE 1 = 1
   AND ppa.project_id = pt.project_id
      --AND pt.task_number = 'TAE1072-TH.ER'
      AND ppa.project_type = 'SHE HO_SHE Project'
   --AND ppa.segment1 = 
   --''
   --'202474'--'23000461'--'202474'--'12003759'--'10101506'
   --AND pt.task_number LIKE '%.ER'
   AND ppa.last_update_date > to_date('20180101','yyyymmdd')
   AND ppa.closed_date IS NULL
   AND ppa.org_id = 84;
   
   SELECT 
   ool.ordered_item,
   ool.project_id,
   ool.task_id,
   ooh.*
   ,ool.*
    FROM oe_order_headers_all ooh
   , oe_order_lines_all ool
   WHERE 1=1
   AND ooh.header_id = ool.header_id
   AND ooh.order_number = '23000461'--'23000414'
   ;
