PROCEDURE test_log(p_api_name VARCHAR2,
                   p_message  VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_log_id NUMBER;
BEGIN
  SELECT xxwip.xxwip_test_log_s.nextval
    INTO l_log_id
    FROM dual;

  INSERT INTO xxwip.xxwip_test_log
    (log_id, api_name, creation_date, message)
  VALUES
    (l_log_id, p_api_name, SYSDATE, p_message);
  COMMIT;
END test_log;
