-- ������֮��
SELECT temp.start_date,
       temp.end_date,
       LEVEL,
       temp.start_date + LEVEL,
       to_char(temp.start_date + LEVEL, 'Day'),
       to_char(temp.start_date + LEVEL, 'D')
  FROM (SELECT trunc(SYSDATE) - 20 start_date,
               trunc(SYSDATE) end_date
          FROM dual) temp
-- WHERE LEVEL < 30
CONNECT BY temp.start_date + LEVEL <= temp.end_date;

-- δ��30��
SELECT temp.start_date,
       LEVEL,
       temp.start_date + LEVEL,
       to_char(temp.start_date + LEVEL, 'Day'),
       to_char(temp.start_date + LEVEL, 'D')
  FROM (SELECT trunc(SYSDATE) start_date
          FROM dual) temp
CONNECT BY temp.start_date + LEVEL <= temp.start_date + 30;

-- ��ȥ30��
SELECT temp.start_date,
       LEVEL,
       temp.start_date - LEVEL,
       to_char(temp.start_date - LEVEL, 'Day'),
       to_char(temp.start_date - LEVEL, 'D')
  FROM (SELECT trunc(SYSDATE) start_date
          FROM dual) temp
CONNECT BY temp.start_date - 30 + LEVEL <= temp.start_date;
