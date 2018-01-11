CREATE OR REPLACE FUNCTION utils.create_task_from_array(values_array text[], task_name text, freelancers text[] DEFAULT NULL::text[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	i int;
	_function_parameters text[];
begin	
	raise notice '%', freelancers;

	if array_length(values_array,1)>0 then
		FOR i IN 1 .. array_upper(values_array, 1)
		LOOP
			_function_parameters = ARRAY[values_array[i]];
			if freelancers is null then
				perform task_bots.create_task(task_name,_function_parameters );
				raise notice '%, %', task_name, _function_parameters;
			else
				perform task_bots.create_task(task_name,_function_parameters,freelancers[i] );
				raise notice '%, %, %', task_name, _function_parameters,freelancers[i];
			end if;
			
		END LOOP;
	end if;
end;
$function$

select utils.create_task_from_array(ARRAY['1','2'], 'TEST_TASK', ARRAY['alexey','alexey'])



select * from task_manager.column_task_description where column_name = 'TEST_TASK'
select * from task_manager.task_parameters where task_type_id = 1021

select * from task_manager.task_parameters where task_type_id = 299
select * from task_manager.column_task_description where id = 299




