-- 量日期之间
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

-- 未来30天
SELECT temp.start_date,
       LEVEL,
       temp.start_date + LEVEL,
       to_char(temp.start_date + LEVEL, 'Day'),
       to_char(temp.start_date + LEVEL, 'D')
  FROM (SELECT trunc(SYSDATE) start_date
          FROM dual) temp
CONNECT BY temp.start_date + LEVEL <= temp.start_date + 30;

-- 过去30天
SELECT temp.start_date,
       LEVEL,
       temp.start_date - LEVEL,
       to_char(temp.start_date - LEVEL, 'Day'),
       to_char(temp.start_date - LEVEL, 'D')
  FROM (SELECT trunc(SYSDATE) start_date
          FROM dual) temp
CONNECT BY temp.start_date - 30 + LEVEL <= temp.start_date;
