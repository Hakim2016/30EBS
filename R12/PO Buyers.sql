SELECT poagenteo.agent_id,
       poagenteo.location_id,
       poagenteo.category_id,
       poagenteo.start_date_active,
       poagenteo.end_date_active,
       poagenteo.attribute_category,
       poagenteo.attribute1,
       poagenteo.attribute2,
       poagenteo.attribute3,
       poagenteo.attribute4,
       poagenteo.attribute5,
       poagenteo.attribute6,
       poagenteo.attribute7,
       poagenteo.attribute8,
       poagenteo.attribute9,
       poagenteo.attribute10,
       poagenteo.attribute11,
       poagenteo.attribute12,
       poagenteo.attribute13,
       poagenteo.attribute14,
       poagenteo.attribute15,
       papf.full_name,
       psl.location_code,
       mkfv.concatenated_segments
  FROM po_agents            poagenteo,
       per_all_people_f     papf,
       po_ship_to_loc_org_v psl,
       mtl_categories_kfv   mkfv
 WHERE poagenteo.agent_id = papf.person_id
   AND poagenteo.category_id = mkfv.category_id(+)
   AND (papf.employee_number IS NOT NULL OR papf.npw_number IS NOT NULL)
   AND trunc(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
   AND decode(hr_general.get_xbg_profile, 'Y', papf.business_group_id, hr_general.get_business_group_id) =
       papf.business_group_id
   AND poagenteo.location_id = psl.location_id(+)
   AND papf.person_id = 119
