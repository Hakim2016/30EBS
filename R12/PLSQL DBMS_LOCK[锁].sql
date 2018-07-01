DECLARE
  l_lock_handle VARCHAR2(128);
  l_status      INTEGER;
BEGIN
  --    0 - success
  --    1 - timeout
  --    2 - deadlock
  --    3 - parameter error
  --    4 - don't own lock specified by 'id' or 'lockhandle'
  --    5 - illegal lockhandle

  dbms_lock.allocate_unique(lockname => 'TEST_1', lockhandle => l_lock_handle);
  dbms_output.put_line('l_lock_handle :' || l_lock_handle);
  l_status := dbms_lock.request(lockhandle        => l_lock_handle,
                                lockmode          => dbms_lock.x_mode,
                                timeout           => dbms_lock.maxwait,
                                release_on_commit => TRUE);

  dbms_output.put_line('l_status :' || l_status);

  l_status := dbms_lock.request(lockhandle        => l_lock_handle,
                                lockmode          => dbms_lock.x_mode,
                                timeout           => dbms_lock.maxwait,
                                release_on_commit => TRUE);

  dbms_output.put_line('l_status :' || l_status);
  IF l_status <> 0 THEN
    dbms_lock.sleep(10);
  END IF;

  l_status := dbms_lock.release(lockhandle => l_lock_handle);

  dbms_output.put_line('l_status :' || l_status);
END;
