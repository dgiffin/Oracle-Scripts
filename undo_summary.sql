set serverout on
set echo off verify off feedback off
DECLARE
v_instance v$instance.instance_name%TYPE;
v_undotbs v$parameter.value%TYPE;
v_tot_undo number;
v_expired_undo number;
v_unexpired_undo number;
v_active_undo number;
v_free_undo number;
v_offline_undo number;
v_expired_percent number;
v_unexpired_percent number;
v_active_percent number;
v_free_percent number;
v_offline_percent number;

BEGIN

select instance_name into v_instance from v$instance;
select upper(value) into v_undotbs from v$parameter where name = 'undo_tablespace';

select nvl(trunc(sum(bytes/1024/1024)),0) into v_tot_undo from dba_data_files where tablespace_name = 
(select upper(value) from v$parameter where name = 'undo_tablespace');

select nvl(trunc(sum(bytes/1024/1024)),0) into v_expired_undo  from dba_undo_extents where tablespace_name = 
(select upper(value) from v$parameter where name = 'undo_tablespace') 
and status = 'EXPIRED'
and segment_name not in
(select segment_name from dba_rollback_segs where status = 'OFFLINE');

select nvl(trunc(sum(bytes/1024/1024)),0) into v_unexpired_undo  from dba_undo_extents where tablespace_name = 
(select upper(value) from v$parameter where name = 'undo_tablespace')
and status = 'UNEXPIRED'
and segment_name not in
(select segment_name from dba_rollback_segs where status = 'OFFLINE');

select nvl(trunc(sum(bytes/1024/1024)),0) into v_active_undo  from dba_undo_extents where tablespace_name = 
(select upper(value) from v$parameter where name = 'undo_tablespace') 
and status = 'ACTIVE'
and segment_name not in
(select segment_name from dba_rollback_segs where status = 'OFFLINE');

select nvl(trunc(sum(bytes/1024/1024)),0) into v_offline_undo from dba_segments a, dba_rollback_segs b
where a.segment_name = b.segment_name;

v_free_undo := v_tot_undo - v_expired_undo - v_unexpired_undo - v_active_undo;

v_expired_percent := round(v_expired_undo / v_tot_undo * 100,0);
v_unexpired_percent := round(v_unexpired_undo / v_tot_undo * 100,0);
v_active_percent := round(v_active_undo / v_tot_undo * 100,0);
v_free_percent := round(v_free_undo / v_tot_undo * 100,0);
v_offline_percent := round(v_offline_undo / v_tot_undo * 100,0);


dbms_output.put_line (v_instance||' '||v_undotbs||' Allocated '||v_tot_undo||' Mb,'||' Active '||v_active_undo||' Mb ('||v_active_percent||'%),'||' Expired '||v_expired_undo||' Mb ('||v_expired_percent||'%),'||' Unexpired '||v_unexpired_undo||' Mb ('||v_unexpired_percent||'%)'||', Undefined '||v_free_undo||' Mb ('||v_free_percent||'%)');

END;
/
