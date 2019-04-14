--���������е�ֵ����������һ�ű���
SELECT fif.application_id,
       fif.id_flex_code,
       fif.id_flex_name,
       fif.table_application_id,
       fif.application_table_name,
       fif.description,
       fif.set_defining_column_name,
       fif.concatenated_segs_view_name,
       --struct.application_id,
       --struct.id_flex_code,
       struct.id_flex_num,
       struct.id_flex_structure_code,
       struct.id_flex_structure_name,
       struct.description,
       segs.segment_num,
       segs.segment_name,
       segs.form_left_prompt,
       segs.application_column_name,
       --segs.flex_value_set_id,
       vset.flex_value_set_name,
       segs.enabled_flag,
       segs.display_flag
  FROM apps.fnd_id_flexs              fif,
       apps.fnd_id_flex_structures_vl struct,
       apps.fnd_id_flex_segments_vl   segs,
       apps.fnd_flex_value_sets       vset
 WHERE 1 = 1
   AND fif.application_id = struct.application_id
   AND fif.id_flex_code = struct.id_flex_code
      --
   AND struct.application_id = segs.application_id --401
   AND struct.id_flex_num = segs.id_flex_num --101
   AND struct.id_flex_code = segs.id_flex_code --'MTLL'
      --
   AND segs.flex_value_set_id = vset.flex_value_set_id(+)
   --AND struct.id_flex_structure_name LIKE
      --struct.id_flex_structure_name "Title" in the lines
       --'%%Qualifiers%'
       --'XXGSCM INV Sales Orders' --key flexfield
AND fif.id_flex_name like '%Segment%'--'%Segment%Qualifiers%'--'Sales Orders'--'%Segment%Qualifiers%'--'Sales Orders'--'Accounting Flexfield'--"Flexfield Title"
--AND fif.application_table_name IN ('MTL_ITEM_LOCATIONS', 'GL_CODE_COMBINATIONS')
 ORDER BY fif.application_id,
          fif.id_flex_code,
          struct.id_flex_num,
          --decode(segs.enabled_flag, 'Y', 1, 'N', 2),
          segs.segment_num;

SELECT xx.segment1,
       xx.segment2,
       xx.segment3,
       xx.*
  FROM mtl_sales_orders xx
 WHERE 1 = 1
   AND xx.segment1 = '22011912';

