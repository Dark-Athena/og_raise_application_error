create or replace  procedure raise_application_error (int4,text) is 
l_stack_info text;
begin
	select string_agg(  'P0001: at "'||
	(select n.nspname  from pg_catalog.pg_namespace n where n.oid=p.pronamespace)
||'.'||pro_name||'", line '||line_num ,chr(10)) into l_stack_info
  from (
select (string_to_array(t,','))[1] pro_oid,
(string_to_array(t,','))[2] line_num,
array_to_string(array_remove(array_remove(string_to_array(t,','),(string_to_array(t,','))[1]),(string_to_array(t,','))[2]),',')  pro_name 
from 
unnest(string_to_array(dbms_utility.format_call_stack('s'),chr(10))) t 
where (string_to_array(t,','))[3] is not null) ,pg_proc p 
where pro_oid::oid=p.oid
and pro_name not like 'raise_application_error%';
	raise  'P%: % %',$1,$2,chr(10)||l_stack_info;
end;
