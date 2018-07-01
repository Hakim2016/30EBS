SELECT DISTINCT ppp.project_party_id project_party_id,
                ppp.object_id object_id,
                ppp.object_type object_type,
                ppp.project_id project_id,
                ppp.resource_id resource_id,
                ppp.resource_type_id resource_type_id,
                ppp.resource_source_id resource_source_id,
                pe.full_name resource_source_name,
                ppp.project_role_id project_role_id,
                pprt.project_role_type project_role_type,
                decode(pa_project_parties_utils.enable_edit_link(ppp.project_id,
                                                                 ppp.scheduled_flag,
                                                                 pa.assignment_id), 
                       'T',
                       'AttrWithEditLink',
                       'S',
                       'AttrWithTeamLink',
                       'AttrWithNoLink') project_role_meaning_link,
                decode(pa.assignment_id,
                       NULL,
                       pprt.meaning,
                       pa.assignment_name) project_role_meaning,
                ppp.start_date_active start_date_active,
                ppp.end_date_active end_date_active,
                pa_project_parties_utils.active_party(ppp.start_date_active,
                                                      ppp.end_date_active) active,
                ppp.scheduled_flag scheduled_flag,
                '' scheduled_img,
                decode(pa.assignment_id,
                       NULL,
                       'N',
                       pa_asgmt_wfstd.is_approval_pending(pa.assignment_id)) pending_approval,
                '' pending_approval_img,
                ppp.record_version_number record_version_number,
                ppa.start_date project_start_date,
                ppa.completion_date project_end_date,
                pa.assignment_id assignment_id,
                pa.record_version_number assign_record_version_number,
                prd.org_name organization_name,
                prd.org_id organization_id,
                hr_general.get_work_phone(pe.person_id) phone_number,
                pe.email_address email_address,
                prd.job_name job_title,
                'EMPLOYEE' party_type,
                decode(decode(pe.current_employee_flag,
                              'Y',
                              'Y',
                              decode(pe.current_npw_flag, 'Y', 'Y', 'N')),
                       'N',
                       'AttrNameWithNoLink',
                       'AttrNameWithLink') name_switcher,
                'OA.jsp?akRegionCode=PA_VIEW_SCHEDULE_LAYOUT-akRegionApplicationId=275-paCalledPage=WorkInfo-paResourceId=' ||
                nvl(ppp.resource_id, -1) || '-paPersonId=' ||
                ppp.resource_source_id || '-retainAM=N-addBreadCrumb=RP' name_link,
                decode(decode(pe.current_employee_flag,
                              'Y',
                              'Y',
                              decode(pe.current_npw_flag, 'Y', 'Y', 'N')),
                       'N',
                       0,
                       1) project_edit_privelege
  FROM pa_project_parties ppp,
       pa_projects_all ppa,
       pa_project_role_types pprt,
       per_all_people_f pe,
       pa_project_assignments pa,
       fnd_user u,
       (SELECT pj.name              job_name,
               haou.organization_id org_id,
               haou.name            org_name,
               paf.person_id,
               paf.assignment_type
          FROM per_all_assignments_f     paf,
               per_jobs                  pj,
               hr_all_organization_units haou
         WHERE trunc(SYSDATE) BETWEEN trunc(paf.effective_start_date) AND
               trunc(paf.effective_end_date)
           AND paf.primary_flag = 'Y'
           AND paf.organization_id = haou.organization_id
           AND nvl(paf.job_id, -99) = pj.job_id(+)) prd
 WHERE ppp.resource_type_id = 101
   AND ppp.project_id = ppa.project_id
   AND ppp.project_role_id = pprt.project_role_id
   AND ppp.resource_source_id = pe.person_id
   AND pe.effective_start_date =
       (SELECT MIN(papf.effective_start_date)
          FROM per_all_people_f papf
         WHERE papf.person_id = pe.person_id
           AND papf.effective_end_date >= trunc(SYSDATE))
   AND pe.effective_end_date >= trunc(SYSDATE)
   AND ppp.project_party_id = pa.project_party_id(+)
   AND nvl(prd.assignment_type, '-99') IN
       ('C',
        decode(decode(pe.current_employee_flag,
                      'Y',
                      'Y',
                      decode(pe.current_npw_flag, 'Y', 'Y', 'N')),
               'Y',
               'E',
               'B'),
        'E',
        '-99')
   AND ppp.resource_source_id = prd.person_id(+)
   AND u.employee_id(+) = ppp.resource_source_id
   AND ppp.object_type = 'PA_PROJECTS'
   AND ppp.object_id = ppa.project_id
AND ppa.project_id = 1194
   ;
UNION 
;
SELECT DISTINCT ppp.project_party_id,
                ppp.object_id,
                ppp.object_type,
                ppp.project_id,
                ppp.resource_id,
                ppp.resource_type_id,
                ppp.resource_source_id,
                hzp.party_name,
                ppp.project_role_id,
                pprt.project_role_type,
                decode(pa_project_parties_utils.enable_edit_link(ppp.project_id,
                                                                 ppp.scheduled_flag,
                                                                 -999),
                       'T',
                       'AttrWithEditLink',
                       'S',
                       'AttrWithTeamLink',
                       'AttrWithNoLink'),
                pprt.meaning,
                ppp.start_date_active,
                ppp.end_date_active,
                pa_project_parties_utils.active_party(ppp.start_date_active,
                                                      ppp.end_date_active),
                ppp.scheduled_flag,
                '',
                'N',
                '',
                ppp.record_version_number,
                ppa.start_date,
                ppa.completion_date,
                -999,
                -999,
                hzo.party_name,
                hzo.party_id,
                hzcp.phone_area_code ||
                decode(hzcp.phone_number,
                       NULL,
                       NULL,
                       decode(hzcp.phone_area_code,
                              NULL,
                              hzcp.phone_number,
                              '-' || hzcp.phone_number)) ||
                decode(hzcp.phone_extension,
                       NULL,
                       NULL,
                       '+' || hzcp.phone_extension),
                hzp.email_address,
                NULL,
                'PERSON',
                'AttrNameWithLink',
                'OA.jsp?akRegionCode=PA_VIEW_SCHEDULE_LAYOUT-akRegionApplicationId=275-paCalledPage=WorkInfo-paResourceId=' ||
                nvl(ppp.resource_id, -1) || '-paPersonId=' ||
                ppp.resource_source_id || '-retainAM=N-addBreadCrumb=RP',
                1
  FROM pa_project_parties    ppp,
       pa_projects_all       ppa,
       pa_project_role_types pprt,
       hz_parties            hzp,
       hz_parties            hzo,
       hz_relationships      hzr,
       hz_contact_points     hzcp,
       fnd_user              u
 WHERE ppp.resource_type_id = 112
   AND ppp.project_id = ppa.project_id
   AND ppp.project_role_id = pprt.project_role_id
   AND ppp.resource_source_id = hzp.party_id
   AND hzp.party_type = 'PERSON'
   AND hzo.party_type = 'ORGANIZATION'
   AND hzr.relationship_code IN ('EMPLOYEE_OF', 'CONTACT_OF')
   AND hzr.status = 'A'
   AND hzr.subject_id = hzp.party_id
   AND hzr.object_id = hzo.party_id
   AND hzr.object_table_name = 'HZ_PARTIES'
   AND hzr.directional_flag = 'F'
   AND hzcp.owner_table_name(+) = 'HZ_PARTIES'
   AND hzcp.owner_table_id(+) = hzp.party_id
   AND hzcp.contact_point_type(+) = 'PHONE'
   AND hzcp.phone_line_type(+) = 'GEN'
   AND hzcp.primary_flag(+) = 'Y'
   AND u.person_party_id(+) = ppp.resource_source_id
   AND ppp.object_type = 'PA_PROJECTS'
   AND ppp.object_id = ppa.project_id
AND ppa.project_id = 1194
   ;
UNION ALL
;
SELECT DISTINCT ppp.project_party_id,
                ppp.object_id,
                ppp.object_type,
                ppp.project_id,
                ppp.resource_id,
                ppp.resource_type_id,
                ppp.resource_source_id,
                hzo.party_name,
                ppp.project_role_id,
                pprt.project_role_type,
                decode(pa_project_parties_utils.enable_edit_link(ppp.project_id,
                                                                 ppp.scheduled_flag,
                                                                 -999),
                       'T',
                       'AttrWithEditLink',
                       'S',
                       'AttrWithTeamLink',
                       'AttrWithNoLink'),
                pprt.meaning,
                ppp.start_date_active,
                ppp.end_date_active,
                pa_project_parties_utils.active_party(ppp.start_date_active,
                                                      ppp.end_date_active),
                ppp.scheduled_flag,
                '' scheduled_img,
                'N',
                '',
                ppp.record_version_number,
                ppa.start_date,
                ppa.completion_date,
                -999,
                -999,
                NULL,
                -999,
                hzcp.phone_area_code ||
                decode(hzcp.phone_number,
                       NULL,
                       NULL,
                       decode(hzcp.phone_area_code,
                              NULL,
                              hzcp.phone_number,
                              '-' || hzcp.phone_number)) ||
                decode(hzcp.phone_extension,
                       NULL,
                       NULL,
                       '+' || hzcp.phone_extension),
                hzo.email_address,
                NULL,
                'ORGANIZATION',
                decode(pa_security_pvt.check_user_privilege('PA_PRJ_SETUP_SUBTAB',
                                                            'PA_PROJECTS',
                                                            ppp.project_id),
                       'T',
                       'AttrNameWithLink',
                       'AttrNameWithNoLink'),
                'OA.jsp?akRegionCode=PA_ORGANIZATION_DETAILS_LAYOUT-akRegionApplicationId=275-paProjectPartyId=' ||
                ppp.project_party_id || '-retainAM=N-addBreadCrumb=RP',
                decode(pa_security_pvt.check_user_privilege('PA_PRJ_SETUP_SUBTAB',
                                                            'PA_PROJECTS',
                                                            ppp.project_id),
                       'T',
                       1,
                       0)
  FROM pa_project_parties       ppp,
       pa_projects_all          ppa,
       pa_project_role_types_vl pprt,
       hz_parties               hzo,
       hz_contact_points        hzcp
 WHERE ppp.resource_type_id = 112
   AND ppp.project_id = ppa.project_id
   AND ppp.project_role_id = pprt.project_role_id
   AND ppp.resource_source_id = hzo.party_id
   AND hzo.party_type = 'ORGANIZATION'
   AND hzcp.owner_table_name(+) = 'HZ_PARTIES'
   AND hzcp.owner_table_id(+) = hzo.party_id
   AND hzcp.contact_point_type(+) = 'PHONE'
   AND hzcp.phone_line_type(+) = 'GEN'
   AND hzcp.primary_flag(+) = 'Y'
   AND ppp.object_type = 'PA_PROJECTS'
   AND ppp.object_id = ppa.project_id
AND ppa.project_id = 1194
