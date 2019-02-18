SELECT 

job_id, NAME, date_from job_start_date, date_to job_end_date
  FROM per_jobs_v v
 WHERE 1=1
 AND NAME LIKE 'H%'
-- AND (NAME LIKE :1)
--AND (business_group_id = :2 AND nvl(:3, date_from) BETWEEN date_from AND nvl(date_to, :4))
 ORDER BY NAME;
 
 SELECT * from per_jobs_v where 1=1 AND NAME LIKE 'H%';
