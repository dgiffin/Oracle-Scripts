select
   s.sid, 
   s.username,
   s.sql_id,
   t.start_time,
   t.used_ublk  "Used Undo",
   (select 
 from
   gv$session s,
   gv$transaction t
 where
   t.addr = s.taddr
order by s.inst_id,s.sid;
