-------------------------------------------------------------------------------------------------------------------------------------------
-- PREPARATIONS
-------------------------------------------------------------------------------------------------------------------------------------------

insert into task_manager.freelancers(worker_initials) values ('choose_startup_email_to_send_bot');
insert into task_bots.bots(name , type,path) values ('choose_startup_email_to_send_bot',1,'task_bots.choose_startup_email_to_send_bot');

insert into task_manager.column_task_description (column_name ,default_freelancer,category,is_standalone,problem_description )
												 values('choose_startup_email_to_send','choose_startup_email_to_send_bot', 'bank',true,'');

--insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1008, 'customer_id','int');
--insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1008, 'message_uid','text');

CREATE OR REPLACE FUNCTION task_bots.choose_startup_email_to_send_bot(task_id integer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	_sqlstr text;
	_task_type_id int;
	_worker_initials text;	
	_parameters json;
	_parameter text;
	_customer_id text;
	_name text;
	_function_parameters text[];
	_success boolean;
begin
		_worker_initials = 'choose_startup_email_to_send_bot';
		select task_type_id , parameters ,name into _task_type_id, _parameters , _name from task_manager.tasks where id = task_id;
		if _task_type_id is null then
			select  id into _task_type_id from task_manager.column_task_description where column_name = _name; 
		end if;

		select parameter_name into _parameter from task_manager.task_parameters where task_type_id=_task_type_id;
		_sqlstr = $$ select  '$$||_parameters||$$'::json ->> '$$|| _parameter||$$'$$;
		execute _sqlstr into _customer_id;

		_function_parameters =ARRAY[_customer_id];-- task_bots.create_task function expects text array as 2nd parameter
		-- also it takes this array as array of values. For example 
		-- if created task have 2 parameters "customer_id" and "text" 
		-- then to create task you need to pass only parameter values like ["2","test"] not key/value pairs like [{"customer_id":"2"} , {"text":"test"}] 
		perform task_bots.create_task ('deleteme_send_random_email_customer'::text, _function_parameters); -- to create task of certain task type 
		
		--updating the current task for choose_startup_email_to_send_bot as completed
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Complete task '||cast(task_id as text),'success');
		update task_manager.tasks set task_status='completed' where id = task_id;
		return true;
	exception when others then
		raise notice 'ERROR = %',SQLERRM;
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Complete task ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$
-------------------------------------------------------------------------
-- Test create task of 'choose_startup_email_to_send' type
-- select task_bots.create_task ('choose_startup_email_to_send', '{}');