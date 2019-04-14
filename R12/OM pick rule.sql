SELECT 
--t.start_date_active,
*
--t.*
  FROM wsh_pick_grouping_rules t
 WHERE 1 = 1
 AND t.PICK_GROUPING_RULE_ID = 1394
 /*ORDER BY t.pick_grouping_rule_id DESC */FOR UPDATE;
