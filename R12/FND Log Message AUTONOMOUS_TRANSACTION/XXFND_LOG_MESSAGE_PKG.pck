CREATE OR REPLACE PACKAGE apps.xxfnd_log_message_pkg IS

  -- Author  : 70588596
  -- Created : 2015/5/12 14:24:27
  -- Purpose : 

  PROCEDURE proc_log(p_module       IN VARCHAR2,
                     p_message_text IN VARCHAR2);

END xxfnd_log_message_pkg;
/
CREATE OR REPLACE PACKAGE BODY apps.xxfnd_log_message_pkg IS

  PROCEDURE proc_log(p_module       IN VARCHAR2,
                     p_message_text IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_log_id NUMBER;
  BEGIN
  
    SELECT xxfnd.xxfnd_log_message_s.nextval
      INTO l_log_id
      FROM dual;
  
    INSERT INTO xxfnd.xxfnd_log_message
      (log_id,
       module, --
       message_text,
       session_id,
       user_id,
       request_id,
       prog_appl_id,
       program_id,
       resp_id,
       resp_appl_id,
       creation_date)
    VALUES
      (l_log_id,
       substrb(p_module, 1, 255),
       substrb(p_message_text, 1, 4000),
       fnd_global.session_id,
       fnd_global.user_id,
       fnd_global.conc_request_id,
       fnd_global.prog_appl_id,
       fnd_global.conc_program_id,
       fnd_global.resp_id,
       fnd_global.resp_appl_id,
       SYSDATE);
    COMMIT;
  END proc_log;
END xxfnd_log_message_pkg;
/
