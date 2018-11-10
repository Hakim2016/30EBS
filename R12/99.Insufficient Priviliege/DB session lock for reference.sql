SELECT sn.username,
       m.sid,
       sn.serial#,
       m.TYPE,
       decode(m.lmode,
              0,
              'None',
              1,
              'Null',
              2,
              'Row Share',
              3,
              'Row Excl.',
              4,
              'Share',
              5,
              'S/Row Excl.',
              6,
              'Exclusive',
              lmode,
              ltrim(to_char(lmode, '990'))) lmode,
       decode(m.request,
              0,
              'None',
              1,
              'Null',
              2,
              'Row Share',
              3,
              'Row Excl.',
              4,
              'Share',
              5,
              'S/Row Excl.',
              6,
              'Exclusive',
              request,
              ltrim(to_char(m.request, '990'))) request,
       m.id1,
       m.id2
  FROM v$session sn,
       v$lock    m
 WHERE (sn.sid = m.sid AND m.request != 0) --存在锁请求，即被阻塞  
    OR (sn.sid = m.sid --不存在锁请求，但是锁定的对象被其他会话请求锁定  
       AND m.request = 0 AND lmode != 4 AND
       (id1, id2) IN (SELECT s.id1,
                              s.id2
                         FROM v$lock s
                        WHERE request != 0
                          AND s.id1 = m.id1
                          AND s.id2 = m.id2))
 ORDER BY id1,
          id2,
          m.request;

/*    
  alter system kill session '91';  
  alter system kill session '144,633';  
  alter system kill session '91,21';  
  alter system kill session '112,5772';  
*/
