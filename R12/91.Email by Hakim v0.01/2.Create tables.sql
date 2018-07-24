/*Objects creation
--create table from fnd_request
fnd_conc_req_summary_v

CREATE TABLE hkm_conc_req_summary AS
SELECT *
  FROM fnd_conc_req_summary_v
 WHERE 1 = 2;


create unique index hkm_conc_req_summary_U1 ON hkm_conc_req_summary (request_id);
*/

--add monitor boject
INSERT INTO hkm_conc_req_summary
  SELECT *
    FROM fnd_conc_req_summary_v v
   WHERE 1 = 1
     AND v.request_id = 15489358--15487352
     --IN (15481910)
  --15481905
  --15481897
  ;
COMMIT;

--check the monitor table
SELECT * FROM hkm_conc_req_summary;
--use column "PRINTER" to identify if monitor is needed
--"N" no need for monitor

SELECT v.phase_code, crs.printer,crs.*
  FROM hkm_conc_req_summary   crs,
       fnd_conc_req_summary_v v
 WHERE 1 = 1
   AND crs.request_id = v.request_id
      --AND crs.status_code IN ('R', 'P')
   AND v.phase_code IN ('C')
   --AND crs.printer <> 'N'
   ;

--send the email
DECLARE
x_1 VARCHAR2(200);
x_2 VARCHAR2(200);
BEGIN
  hkm_request_monitor.main(x_1, x_2);
END;

--declare errbuf varchar2(4000); retcode varchar2(4000); begin WF_BES_CLEANUP.CLEANUP_SUBSCRIBERS(errbuf, retcode); end;
--3.����һ��ִ�мƻ���ÿ��1440���ӣ���һ�������д洢����һ��
DECLARE
  i INTEGER;
BEGIN
  sys.dbms_job.submit(job       => i,
                      what      => 'DECLARE s1 VARCHAR2(200); s2 VARCHAR2(200); BEGIN hkm_request_monitor.main(s1, s2); END;',
                      next_date => SYSDATE,
                      INTERVAL  => 'sysdate+5/1440');
  dbms_output.put_line('job = ' || i);
  COMMIT;
END;
/

SELECT * FROM user_jobs;