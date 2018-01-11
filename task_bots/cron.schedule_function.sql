CREATE OR REPLACE FUNCTION cron.schedule_function( function_name text , sheduled_time timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	_already_scheduled boolean;
	_sqlstr text;
begin
	select 	count(*)>0 into _already_scheduled from task_bots.execute_python where (schedule_time <= sheduled_time and schedule_time >now() )and parameters like '%'||function_name||'%';
	raise notice '%',_already_scheduled;
	if not _already_scheduled then
	
		insert into task_bots.execute_python (python_script, parameters, schedule_time) 
				values ('execute_query.py', 'select '||function_name,  sheduled_time); 
	end if; 
end 
$function$