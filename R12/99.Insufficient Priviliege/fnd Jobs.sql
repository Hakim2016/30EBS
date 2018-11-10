--1.创建一个测试表
create table xxhkm_test_t(dtime date);
Select * From xxhkm_test_t;

--2.创建一个存储过程
create or replace procedure p_test as
begin
 insert into xxhkm_test_t values(sysdate);
end;

--3.创建一个执行计划：每天1440分钟，即一分钟运行存储过程一次
Declare
  i Integer;
Begin
   dbms_job.submit(i,'p_test;',Sysdate,'sysdate+1/1440');
end;

--4.查看已经创建的所有执行计划
Select * From user_jobs uj
WHERE 1=1
--AND uj.WHAT LIKE '%p_test%'
ORDER BY uj.job;

--5.运行执行计划
Declare
  job_num Integer;
Begin
 -- 查找计划号
 SELECT t.job INTO job_num FROM user_jobs t WHERE 1=1 AND t.job = 280;
 -- 运行制定的执行计划
 dbms_job.run(job_num);
end;

--6.查看计划的运行结果
  select
    t.dtime
    --to_char(t.dtime,'yyyy-mm-dd hh24:mi:ss')
  from xxhkm_test_t t
  Order By t.dtime;

-- 查出测试表内容
   Delete xxhkm_test_t t;

--7.修改执行计划（修改执行的间隔时间）
/*
sysdate+1              表示每天执行一次
sysdate+1/24           表示每小时执行一次
sysdate+1/(24*60)      表示每分钟执行一次
sysdate+1/(24*60*60)   表示每秒执行一次
*/
Declare
  job_num Integer;
Begin
  -- 查找计划号
  Select t.JOB Into job_num From User_Jobs t ;
  -- 修改为：每天执行一次
  dbms_job.interval(job_num, 'sysdate+1/(24*60)');
end;

--8.停止一个执行计划
/*
 Sysdate+(5) 加五天,
 Sysdate+(5/24) 加五时,
 Sysdate+(5/24/60) 加五分,
 Sysdate+(5/24/60/60) 加五秒
*/

Declare 
  job_num Integer; 
Begin 
  -- 查找计划号 
  Select t.JOB Into job_num From User_Jobs t WHERE t.job=280; 
  -- 修改为：每天执行一次 
  dbms_job.interval(job_num, 'sysdate+10/(24*60*60)'); 
end; 

--8.停止一个执行计划 
/* 
Sysdate+(5) 加五天, 
Sysdate+(5/24) 加五时, 
Sysdate+(5/24/60) 加五分, 
Sysdate+(5/24/60/60) 加五秒 
*/ 
Declare 
  job_num Integer; 
Begin 
  -- 查找计划号 
  Select t.JOB Into job_num From User_Jobs t ; 
  -- 停止计划，不在执行 
  --dbms_job.broken(job_num,True); 
  -- 停止计划，并在两分钟后继续执行 
  dbms_job.broken(job_num,True,Sysdate+(2/24/60)); 
end; 

--9.删除执行计划Declare 
DECLARE
  job_num INTEGER;
BEGIN
  -- 查找计划号 
  SELECT t.job
    INTO job_num
    FROM user_jobs t
    WHERE 1=1
    AND t.job=301;
  dbms_job.remove(job_num);
END;

--例子： 
CREATE OR REPLACE PROCEDURE jobquery AS
BEGIN
  FOR cr IN (SELECT *
               FROM jccb.e_mp_cur_curve)
  LOOP
    dbms_output.put_line(cr.id);
  END LOOP;
END;

DECLARE
  job_excute INTEGER;
BEGIN
  dbms_job.submit(job_excute, 'jccb.jobquery;', SYSDATE, 'sysdate+1/144');
END;

SELECT *
  FROM user_jobs;

Declare 
  job_num Integer; 
Begin 
-- 查找计划号 
Select t.JOB Into job_num From User_Jobs t ; 
-- 运行制定的执行计划 
dbms_job.run(job_num); 
end; 
