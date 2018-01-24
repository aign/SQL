--select task_manager.add_new_task_type_with_parameters('consider_adding_audit_trail_to_table'::text, 'david'::text, true, array['schema_name' ,'text','table_name' ,'text']) 
CREATE OR REPLACE FUNCTION cron.check_if_table_created_without_audit_triggers()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	_res json;
	_function_parameters text[];
	i int;
	_item json;
	_ids text[];
	_name text;
begin
	_name = 'consider_adding_audit_trail_to_table';
	_res = task_bots.compare_uids_new(_name, $$
										--SELECT json_build_array(table_schema::text,table_name::text) as unique_id 
										SELECT table_name as unique_id , table_schema::text||'.' ||table_name::text as table_name 
										FROM information_schema.tables t
										where table_name not in
												(SELECT event_object_table
													FROM  information_schema.triggers
													WHERE trigger_name = 'audit_trigger_row')
													and table_type ='BASE TABLE' 
													and table_schema <> 'pg_catalog'
													and table_schema <> 'information_schema'			
													and table_schema <> 'task_bots'
									$$::text);
	raise notice '%',_res;
	
	_item=_res ->'unique_id';
	--here we check if there is results for column unique_id
	--if there are no records then result will be '{"unique_id":null,"the_accountant":null}'
	--but null here is text 'null' so isnull() won't work
	if ((_item::text) != 'null' ) then
		--to access any desired array yo have to convert it from json to postgres array by 
		--calling this select array_agg(value) into _ids from json_array_elements(_res ->'unique_id'); 
		--where _res ->'unique_id' - is array of values returned for column unique_id  
		--select array_agg(value) into _ids from json_array_elements(_res ->'table_name');
		select array_agg(string_to_array(value::text,'.')) into _ids from json_array_elements(_res ->'table_name');
		raise notice '%',_ids;
--		select array_agg(value) into _values from json_array_elements(_res ->'the_accountant');

		perform utils.create_task_from_array(_ids,_name);
	end if;

end 
$function$

select string_to_array(value::text,'.')

select array_agg(string_to_array(value::text,'.'))--array_agg(value) 
from json_array_elements('{"unique_id":["cached_consider_adding_audit_trail_to_table"],"table_name":["task_bots.cached_consider_adding_audit_trail_to_table"]}'::json->'table_name')

drop table task_bots.cached_consider_adding_audit_trail_to_table


select * from task_bots.cached_consider_adding_audit_trail_to_table

select cron.check_if_table_created_without_audit_triggers()


select * from task_bots.cached_consider_adding_audit_trail_to_table
delete from task_bots.cached_consider_adding_audit_trail_to_table

select array_agg(unique_id), array_agg(table_schema) from task_bots.cached_consider_adding_audit_trail_to_table

select '{"unique_id":["cached_consider_adding_audit_trail_to_table"],"table_schema":["task_bots"]}'::json


WITH data(unique_id) AS (  SELECT
  						array_agg(newone.unique_id::text) 
						FROM
 						task_bots.cached_consider_adding_audit_trail_to_table as newone
						FULL OUTER JOIN task_bots.cached_consider_adding_audit_trail_to_table as oldone USING (unique_id)
						WHERE
 						oldone.unique_id IS null
 						) SELECT row_to_json(data) FROM data 						
 select t.value from 
 	json_array_elements('{"unique_id":["task_bots.cached_consider_adding_audit_trail_to_table"]}'::json ->'unique_id') t
 	;