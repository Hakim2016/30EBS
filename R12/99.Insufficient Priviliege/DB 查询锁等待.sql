select a.username, a.sid, a.serial#, b.id1
   from v$session a, v$lock b
   where b.id1 in
      (select distinct e.id1
       from v$session d, v$lock e
       where d.lockwait = e.kaddr)
    and a.sid = b.sid
    and b.request = 0
