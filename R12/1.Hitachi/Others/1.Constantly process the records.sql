DECLARE
  a            NUMBER:=0;
  b            NUMBER:=0;
  l_request_id NUMBER;
  l_project_id NUMBER;
  l_task_id    NUMBER;
  l_fst_date   VARCHAR2(80);
  l_snd_date   VARCHAR2(80);
  l_trd_date   VARCHAR2(80);
  l_fth_date   VARCHAR2(80);
  CURSOR cur_date IS
    SELECT t.ROWID row_id,
           ppa.project_id,
           pt.task_id,
           to_char(to_date(fst_date, 'DD-MON-YY'), 'YYYY/MM/DD HH24:MI:SS') fst_date,
           to_char(to_date(snd_date, 'DD-MON-YY'), 'YYYY/MM/DD HH24:MI:SS') snd_date,
           to_char(to_date(trd_date, 'DD-MON-YY'), 'YYYY/MM/DD HH24:MI:SS') trd_date,
           to_char(to_date(fth_date, 'DD-MON-YY'), 'YYYY/MM/DD HH24:MI:SS') fth_date
      FROM xxpjm_date_update_20180504_hbs t,
           pa_projects_all                ppa,
           pa_tasks                       pt
     WHERE 1 = 1
       AND ppa.project_id = pt.project_id
       AND t.mfg_num = pt.task_number
       AND t.project_num = ppa.segment1
       AND t.process_status IS NULL
       AND rownum <= 5;
BEGIN
  fnd_global.apps_initialize(user_id      => 4411,
                             resp_id      => 51249, --hbs51249 hea50676
                             resp_appl_id => 660);
  mo_global.init('M');
  LOOP
    SELECT COUNT(*) INTO b FROM xxpjm_date_update_20180504_hbs;
    SELECT COUNT(*)
      INTO a
      FROM fnd_concurrent_requests t
     WHERE t.phase_code = 'R';
    IF a <= 35 THEN
      FOR rec_data IN cur_date LOOP
        l_request_id := fnd_request.submit_request(application => 'XXPJM',
                                                   program     => 'XXPJMUSCM',
                                                   sub_request => FALSE,
                                                   argument1   => rec_data.project_id,
                                                   argument2   => rec_data.task_id,
                                                   argument3   => rec_data.fst_date,
                                                   argument4   => rec_data.snd_date,
                                                   argument5   => rec_data.trd_date,
                                                   argument6   => rec_data.fth_date,
                                                   argument7   => NULL,
                                                   argument8   => 'N',
                                                   argument9   => NULL);
        --dbms_output.put_line(l_request_id);
      
        UPDATE xxpjm_date_update_20180504_hbs t
           SET t.process_status = 'S',
               t.process_date   = SYSDATE,
               t.request_id     = l_request_id
         WHERE t.rowid = rec_data.row_id;
         COMMIT;
      END LOOP;
    ELSE
      NULL;
    END IF;
    DBMS_LOCK.SLEEP(100); --»√≥Ã–Ú‘› ±100√Î÷”
    EXIT WHEN b = 0;
  END LOOP;
END;
