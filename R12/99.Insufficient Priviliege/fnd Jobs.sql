--1.����һ�����Ա�
create table xxhkm_test_t(dtime date);
Select * From xxhkm_test_t;

--2.����һ���洢����
create or replace procedure p_test as
begin
 insert into xxhkm_test_t values(sysdate);
end;

--3.����һ��ִ�мƻ���ÿ��1440���ӣ���һ�������д洢����һ��
Declare
  i Integer;
Begin
   dbms_job.submit(i,'p_test;',Sysdate,'sysdate+1/1440');
end;

--4.�鿴�Ѿ�����������ִ�мƻ�
Select * From user_jobs uj
WHERE 1=1
--AND uj.WHAT LIKE '%p_test%'
ORDER BY uj.job;

--5.����ִ�мƻ�
Declare
  job_num Integer;
Begin
 -- ���Ҽƻ���
 SELECT t.job INTO job_num FROM user_jobs t WHERE 1=1 AND t.job = 280;
 -- �����ƶ���ִ�мƻ�
 dbms_job.run(job_num);
end;

--6.�鿴�ƻ������н��
  select
    t.dtime
    --to_char(t.dtime,'yyyy-mm-dd hh24:mi:ss')
  from xxhkm_test_t t
  Order By t.dtime;

-- ������Ա�����
   Delete xxhkm_test_t t;

--7.�޸�ִ�мƻ����޸�ִ�еļ��ʱ�䣩
/*
sysdate+1              ��ʾÿ��ִ��һ��
sysdate+1/24           ��ʾÿСʱִ��һ��
sysdate+1/(24*60)      ��ʾÿ����ִ��һ��
sysdate+1/(24*60*60)   ��ʾÿ��ִ��һ��
*/
Declare
  job_num Integer;
Begin
  -- ���Ҽƻ���
  Select t.JOB Into job_num From User_Jobs t ;
  -- �޸�Ϊ��ÿ��ִ��һ��
  dbms_job.interval(job_num, 'sysdate+1/(24*60)');
end;

--8.ֹͣһ��ִ�мƻ�
/*
 Sysdate+(5) ������,
 Sysdate+(5/24) ����ʱ,
 Sysdate+(5/24/60) �����,
 Sysdate+(5/24/60/60) ������
*/

Declare 
  job_num Integer; 
Begin 
  -- ���Ҽƻ��� 
  Select t.JOB Into job_num From User_Jobs t WHERE t.job=280; 
  -- �޸�Ϊ��ÿ��ִ��һ�� 
  dbms_job.interval(job_num, 'sysdate+10/(24*60*60)'); 
end; 

--8.ֹͣһ��ִ�мƻ� 
/* 
Sysdate+(5) ������, 
Sysdate+(5/24) ����ʱ, 
Sysdate+(5/24/60) �����, 
Sysdate+(5/24/60/60) ������ 
*/ 
Declare 
  job_num Integer; 
Begin 
  -- ���Ҽƻ��� 
  Select t.JOB Into job_num From User_Jobs t ; 
  -- ֹͣ�ƻ�������ִ�� 
  --dbms_job.broken(job_num,True); 
  -- ֹͣ�ƻ������������Ӻ����ִ�� 
  dbms_job.broken(job_num,True,Sysdate+(2/24/60)); 
end; 

--9.ɾ��ִ�мƻ�Declare 
DECLARE
  job_num INTEGER;
BEGIN
  -- ���Ҽƻ��� 
  SELECT t.job
    INTO job_num
    FROM user_jobs t
    WHERE 1=1
    AND t.job=301;
  dbms_job.remove(job_num);
END;

--���ӣ� 
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
-- ���Ҽƻ��� 
Select t.JOB Into job_num From User_Jobs t ; 
-- �����ƶ���ִ�мƻ� 
dbms_job.run(job_num); 
end; 