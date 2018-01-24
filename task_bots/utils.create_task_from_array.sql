CREATE OR REPLACE FUNCTION utils.create_task_from_array(values_array text[], task_name text, freelancers text[] DEFAULT NULL::text[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	i int;
	_function_parameters text[];
	
begin	
	raise notice 'fl =%', freelancers;
	raise notice 'va = %',values_array;
	if array_length(values_array,1)>0 then
		FOR i IN 1 .. array_upper(values_array, 1)
		LOOP
			_function_parameters = ARRAY(SELECT unnest(values_array[i:i]));
			
			raise notice 'fp = %',_function_parameters;
			
			if freelancers is null then
				perform task_bots.create_task(task_name,_function_parameters );
				raise notice '%, %', task_name, _function_parameters;
			else
				raise notice '%, %, %', task_name, _function_parameters,freelancers[i] ;
				perform task_bots.create_task(task_name,_function_parameters, freelancers[i]);				
				
			end if;
			
		END LOOP;
	end if;
end;
$function$


select replace('"alexey"' , '"', '')

select utils.create_task_from_array_test(array['a','b'], 'TEST_TASK'::text, array['"alexey"' ,'"alexey"' ]);
select utils.create_task_from_array_test(array[['a','b'],['c','d']], 'TEST_TASK'::text, array['"alexey"' ,'"alexey"' ]);

select (array[['a,b','c,d']])
select utils.create_task_from_array(ARRAY['1','2'], 'TEST_TASK', ARRAY['alexey','alexey'])

select ARRAY[['1','2'],['2','3']]

select * from task_manager.column_task_description where column_name = 'TEST_TASK'
select * from task_manager.task_parameters where task_type_id = 1021

select * from task_manager.task_parameters where task_type_id = 299
select * from task_manager.column_task_description where id = 299




