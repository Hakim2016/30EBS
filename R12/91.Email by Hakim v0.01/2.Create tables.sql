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
     AND v.request_id = 17374986--17373644--17373432--15540813--15540804--15515034--15514566--15514565--15512836--15512251--15512211--15511782--15508909--15508903--15508884--15508877--15508426--15508460--15508355--15508223--15508187--15508138--15508084--15508070--15507969--15507928--15489358--15487352
     --IN (15481910)
  --15481905
  --15481897
  ;
COMMIT;

--check the monitor table
SELECT v.printer,v.* FROM hkm_conc_req_summary v
ORDER BY request_id DESC;
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
--3.创建一个执行计划：每天1440分钟，即一分钟运行存储过程一次
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
