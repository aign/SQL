CREATE OR REPLACE FUNCTION task_bots.give_task_to_customer_onboarder_bot(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	sqlstr text;
	_worker_initials text;
	_customer_id int;
	_parameters json;
	_onboarder text;
begin
		select parameters->>'customer_id' into _customer_id from task_manager.tasks where id = task_id;
		select onboarder into _onboarder from public.customers where id = _customer_id;
		update task_manager.tasks set task_status='completed' where id = task_id;
		perform task_bots.create_task('potential_customer_has_sent_receipt'::text,array[_customer_id::text],_onboarder);
		insert into task_bots.logs(botname,"action","result") values ('give_task_to_customer_onboarder_bot','Complete task '||cast(task_id as text),'success');
		return true;
	exception when others then
		raise notice '%',SQLERRM;
		insert into task_bots.logs(botname,"action","result") values ('give_task_to_customer_onboarder_bot','Complete task '||cast(task_id as text) ||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$;