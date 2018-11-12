-- Register Application ：XXENG
DECLARE
  lb_check   BOOLEAN;
  l_commit   BOOLEAN := FALSE;
  l_count    NUMBER;
  l_rowid    VARCHAR2(40);
  l_user_id  NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.login_id;
  l_cur_date DATE := SYSDATE;

  l_application_id         NUMBER;
  l_application_name       VARCHAR2(200) := 'Addon ENG';
  l_application_short_name VARCHAR2(100) := 'XXENG';
  l_basepath               VARCHAR2(100) := 'XXENG_TOP';
  l_description            VARCHAR2(240) := 'Addon ENG';

BEGIN

  DECLARE
    x_rowid VARCHAR2(30);
  BEGIN
    -- valudate application short name existed or not,not existed, register application
    SELECT a.application_id
      INTO l_application_id
      FROM fnd_application a
     WHERE a.application_short_name = l_application_short_name; -- 'XXPJM';
    dbms_output.put_line('SUCCESS==Application(' || l_application_short_name || ') has existed');
    l_commit := FALSE;
  EXCEPTION
    WHEN no_data_found THEN
      --register application
      -- valudate user application name existed or not
      SELECT COUNT(1)
        INTO l_count
        FROM fnd_application_tl t
       WHERE t.application_name = l_application_name; -- 'Addon PJM';
    
      IF l_count > 0 THEN
        -- dbms_output.put_line('用户应用名Addon PJM已经存在，请核对不同语言环境的用户应用名后，再执行！');
        dbms_output.put_line('application name (' || l_application_name ||
                             ') is existed,please checking ,then running！');
        raise_application_error(-20001, 'USER_APPLICATION_EXISTS');
      END IF;
      BEGIN
        SELECT fnd_application_s.nextval
          INTO l_application_id
          FROM dual;
        fnd_application_pkg.insert_row(x_rowid                  => x_rowid,
                                       x_application_id         => l_application_id,
                                       x_application_short_name => l_application_short_name, -- 'XXPJM',
                                       x_basepath               => l_basepath, -- 'XXPJM_TOP',
                                       x_application_name       => l_application_name, --'Addon PJM',
                                       x_description            => l_description, --'Addon PJM',
                                       x_creation_date          => l_cur_date,
                                       x_created_by             => l_user_id,
                                       x_last_update_date       => l_cur_date,
                                       x_last_updated_by        => l_user_id,
                                       x_last_update_login      => l_login_id,
                                       x_product_code           => l_application_short_name --'XXPJM'
                                       );
        l_commit := TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          dbms_output.put_line(to_char(SQLCODE) || '-' || SQLERRM);
          raise_application_error(-20001, 'register application(' || l_application_short_name || ') Failure');
      END;
      IF l_commit = TRUE THEN
        dbms_output.put_line('SUCCESS== Register application(' || l_application_short_name || ') Success!');
      END IF;
  END;
END;
