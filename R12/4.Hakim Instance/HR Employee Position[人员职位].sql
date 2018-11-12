SELECT fu.user_name,
       pap.full_name,
       -- pap.person_type_id,
       ppt.user_person_type,
       --pap.person_id,
       /*pap.effective_start_date,
       pap.effective_end_date,
       pa.effective_start_date,
       pa.effective_end_date,*/
       --pa.position_id,
       --pa.organization_id,
       hou.name organization_name,
       hr_general.decode_position_latest_name(pa.position_id) position_name,
       --pa.job_id,
       hr_general.decode_job(pa.job_id) job,
       --pa.assignment_status_type_id,
       --pa.business_group_id,
       hr_general.decode_ass_status_type(pa.assignment_status_type_id, pa.business_group_id)
  FROM fnd_user                     fu,
       per_all_people_f             pap,
       per_person_types_v           ppt,
       per_all_assignments_f        pa,
       hr_all_organization_units_vl hou
 WHERE fu.employee_id = pap.person_id
   AND pap.person_type_id = ppt.person_type_id(+)
   AND pap.person_id = pa.person_id
   AND pa.organization_id = hou.organization_id(+)
      AND fu.user_name = '70236338'--'70015928'
   AND trunc(SYSDATE) BETWEEN pap.effective_start_date AND pap.effective_end_date
   AND trunc(SYSDATE) BETWEEN pa.effective_start_date AND pa.effective_end_date
 ORDER BY pa.organization_id,
          fu.user_id,
          pap.person_id,
          pap.effective_start_date,
          pa.effective_start_date;

SELECT *
  FROM per_jobs_tl;
SELECT *
  FROM per_person_types_v;

ALTER session SET nls_language = 'Simplified Chinese';
ALTER session SET nls_language = 'American';
