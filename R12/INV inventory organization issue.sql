SELECT organization_id,
       row_id,
       business_group_id,
       NAME,
       organization_type,
       date_from,
       date_to,
       location_code,
       internal_external_meaning,
       internal_address_line,
       cost_allocation_keyflex_id,
       location_id,
       soft_coding_keyflex_id,
       TYPE,
       internal_external_flag,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       attribute21,
       attribute22,
       attribute23,
       attribute24,
       attribute25,
       attribute26,
       attribute27,
       attribute28,
       attribute29,
       attribute30,
       comments,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by,
       style,
       country,
       address_line_1,
       address_line_2,
       address_line_3,
       region_1,
       region_2,
       region_3,
       telephone_number_1,
       telephone_number_2,
       telephone_number_3,
       postal_code,
       town_or_city,
       loc_information13,
       loc_information14,
       loc_information15,
       loc_information16,
       loc_information17,
       loc_information18,
       loc_information19,
       loc_information20,
       object_version_number
  FROM hr_organization_units_v
 WHERE 1=1
 /*AND (--1
 
 \*('' IS NULL AND ((hr_organization_units_v.business_group_id + 0 = 7903) OR
       (hr_organization_units_v.business_group_id + 0 =
       hr_organization_units_v.organization_id))) --or1
       *\
       --OR
       
       \*('' IS NOT NULL AND
       ((EXISTS (SELECT 1
                     FROM pay_restriction_values      prv1,
                          hr_organization_information hoi
                    WHERE prv1.restriction_code = 'ORG_CLASS'
                      AND prv1.customized_restriction_id = ''
                      AND hoi.org_information_context = 'CLASS'
                      AND prv1.value = hoi.org_information1
                      AND ((prv1.value = 'HR_BG' AND
                          hr_organization_units_v.business_group_id + 0 =
                          hr_organization_units_v.organization_id) OR
                          (prv1.value != 'HR_BG' AND
                          hr_organization_units_v.business_group_id + 0 = 7903))
                      AND hoi.organization_id =
                          hr_organization_units_v.organization_id)) OR
       (NOT EXISTS
        (SELECT 1
              FROM pay_restriction_values prv2
             WHERE prv2.restriction_code = 'ORG_CLASS'
               AND prv2.customized_restriction_id = ''))))--or2
               *\
               
               )--1
               */
   AND (NAME LIKE 'HAKIM%')
 ORDER BY NAME
