-- Script create_sql_profile_from_plan.sql
-- Takes Four parameters sql_id plan_value category (DEFAULT) force_match (FALSE)
-- Set a profile for given hash plan value

declare
ar_profile_hints sys.sqlprof_attr;
cl_sql_text      clob;
begin
select
       extractvalue(value(d), '/hint') as outline_hints
        bulk collect
        into
             ar_profile_hints
         from
        xmltable('/*/outline_data/hint'
           passing (
             select                      xmltype(other_xml) as xmlval
             from
                     dba_hist_sql_plan
             where
                     sql_id = '&&1'
             and     plan_hash_value = &&2
             and     other_xml is not null
             )
             ) d;
 select           sql_text
                  into           cl_sql_text
       from           dba_hist_sqltext  where
       sql_id = '&&1';
 dbms_sqltune.import_sql_profile(
 sql_text    => cl_sql_text  ,
 profile     => ar_profile_hints  ,
 category    => '&&3'  ,
 name        => 'PROFILE_&&1',
 force_match => &&4 );
end;
/

