SELECT *
  FROM pa_segment_value_lookup_sets lkh,
       pa_segment_value_lookups     lkl
 WHERE 1 = 1
   AND lkh.segment_value_lookup_set_id = lkl.segment_value_lookup_set_id
   AND lkh.segment_value_lookup_set_name =
      --'HEA Expen Type Clearing Subacc'
       'HEA Expenditure Type';

SELECT *
  FROM pa_segment_value_lookup_sets lkh
 WHERE 1 = 1
   AND lkh.segment_value_lookup_set_name = 'HEA Expen Type Clearing Subacc';

SELECT *
  FROM pa_segment_value_lookups lkl
 WHERE 1 = 1
   AND lkl.segment_value_lookup_set_id = 8;

SELECT lkh.segment_value_lookup_set_name,
       lkl.segment_value_lookup,
       lkl.segment_value,
       lkh.*,
       lkl.*
  FROM pa_segment_value_lookup_sets lkh,
       pa_segment_value_lookups     lkl
 WHERE 1 = 1
   AND lkh.segment_value_lookup_set_id = lkl.segment_value_lookup_set_id
   AND lkh.segment_value_lookup_set_name = 'HEA Expen Type Clearing Subacc';

SELECT dr_acc.segment_value_lookup expen_type,
       dr_acc.segment_value dr_acc,
       dr_subacc.segment_value dr_subacc,
       cr_acc.segment_value cr_acc,
       cr_subacc.segment_value cr_subacc
  FROM (SELECT lkh.*,
               lkl.*
          FROM pa_segment_value_lookup_sets lkh,
               pa_segment_value_lookups     lkl
         WHERE 1 = 1
           AND lkh.segment_value_lookup_set_id = lkl.segment_value_lookup_set_id
           AND lkh.segment_value_lookup_set_name = 'HEA Expenditure Type') dr_acc,
       (SELECT lkh.*,
               lkl.*
          FROM pa_segment_value_lookup_sets lkh,
               pa_segment_value_lookups     lkl
         WHERE 1 = 1
           AND lkh.segment_value_lookup_set_id = lkl.segment_value_lookup_set_id
           AND lkh.segment_value_lookup_set_name = 'HEA Expenditure Type Subacc') dr_subacc,
       (SELECT lkh.*,
               lkl.*
          FROM pa_segment_value_lookup_sets lkh,
               pa_segment_value_lookups     lkl
         WHERE 1 = 1
           AND lkh.segment_value_lookup_set_id = lkl.segment_value_lookup_set_id
           AND lkh.segment_value_lookup_set_name = 'HEA Expenditure Type Clearing') cr_acc,
       (SELECT lkh.*,
               lkl.*
          FROM pa_segment_value_lookup_sets lkh,
               pa_segment_value_lookups     lkl
         WHERE 1 = 1
           AND lkh.segment_value_lookup_set_id = lkl.segment_value_lookup_set_id
           AND lkh.segment_value_lookup_set_name = 'HEA Expen Type Clearing Subacc') cr_subacc
 WHERE 1 = 1
   AND dr_acc.segment_value_lookup = dr_subacc.segment_value_lookup
   AND cr_acc.segment_value_lookup = cr_subacc.segment_value_lookup
   AND dr_acc.segment_value_lookup = cr_acc.segment_value_lookup
   AND dr_acc.segment_value_lookup LIKE '%Transfer%'--'%Material%'--'PPO Transfer'
   ;
