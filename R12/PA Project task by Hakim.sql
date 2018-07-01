SELECT ppa.closed_date,
       ppa.segment1,
       ppa.name,
       pt.*
  FROM pa_projects_all ppa,
       pa_tasks        pt
 WHERE 1 = 1
   AND ppa.project_id = pt.project_id
      --AND pt.task_number = 'TAE1072-TH.ER'
   AND ppa.segment1 = '12003759'--'10101506'
   AND pt.task_number LIKE '%.EQ'
   AND ppa.org_id = 82;