
SELECT job.job_id,
       jgr.internal_name,
       job.business_group_id,
       job.job_definition_id,
       job.date_from,
       job.comments,
       job.date_to,
       jbt.name,
       job.attribute_category,
       job.attribute1,
       job.attribute2,
       job.attribute3,
       job.attribute4,
       job.attribute5,
       job.attribute6,
       job.attribute7,
       job.attribute8,
       job.attribute9,
       job.attribute10,
       job.attribute11,
       job.attribute12,
       job.attribute13,
       job.attribute14,
       job.attribute15,
       job.attribute16,
       job.attribute17,
       job.attribute18,
       job.attribute19,
       job.attribute20,
       job.last_update_date,
       job.last_updated_by,
       job.last_update_login,
       job.creation_date,
       job.created_by,
       job.job_information_category,
       job.job_information1,
       job.job_information2,
       job.job_information3,
       job.job_information4,
       job.job_information5,
       job.job_information6,
       job.job_information7,
       job.job_information8,
       job.job_information9,
       job.job_information10,
       job.job_information11,
       job.job_information12,
       job.job_information13,
       job.job_information14,
       job.job_information15,
       job.job_information16,
       job.job_information17,
       job.job_information18,
       job.job_information19,
       job.job_information20,
       job.object_version_number,
       job.request_id,
       job.program_application_id,
       job.program_id,
       job.program_update_date,
       job.benchmark_job_flag,
       job.benchmark_job_id,
       job.emp_rights_flag,
       job.job_group_id,
       job.approval_authority
  FROM per_jobs job, per_jobs_tl jbt, per_job_groups jgr
 WHERE job.job_group_id = jgr.job_group_id
   AND jbt.job_id = job.job_id
   AND jbt.language = userenv('LANG')
   AND jgr.internal_name = 'HR_' || job.business_group_id;

--Scripts below to solve problem:
--Failed to select the jobs just created in form (HR>>Work structures>>Position)
SELECT jgr.*
  FROM per_job_groups jgr
 WHERE 1 = 1
   AND jgr.business_group_id = 7903;

CREATE TABLE per_job_groups190126 AS
  SELECT jgr.*
    FROM per_job_groups jgr
   WHERE 1 = 1
     AND jgr.business_group_id = 7903;
SELECT * FROM per_job_groups190126 WHERE 1 = 1;

UPDATE per_job_groups jgr
SET jgr.INTERNAL_NAME = 'HR_7903_HKM',
jgr.DISPLAYED_NAME = 'HR_7903_HKM'
 WHERE 1 = 1
   AND jgr.business_group_id = 7903
   AND jgr.JOB_GROUP_ID = 8362;
   
UPDATE per_job_groups jgr
SET jgr.INTERNAL_NAME = 'HR_7903',
jgr.DISPLAYED_NAME = 'XXHR_JOB_GROUP'
 WHERE 1 = 1
   AND jgr.business_group_id = 7903
   AND jgr.JOB_GROUP_ID = 9362;
