DECLARE
  l_n     NUMBER;
  l_count NUMBER;
BEGIN

  l_n := dbms_utility.get_time;
  SELECT COUNT(1)
    INTO l_count
    FROM wf_item_activity_statuses_h t;
  -- l_n := dbms_utility.get_time;
  l_n := (dbms_utility.get_time - l_n) / 100;

  dbms_output.put_line(' l_n     : ' || l_n);
  dbms_output.put_line(' l_count : ' || l_count);
END;
