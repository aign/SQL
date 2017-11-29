-------------------------------------------------------------------------------------------------------------------------------------------
-- PREPARATIONS
-------------------------------------------------------------------------------------------------------------------------------------------

insert into task_manager.freelancers(worker_initials) values ('choose_startup_email_to_send_bot');
insert into task_bots.bots(name , type,path) values ('choose_startup_email_to_send_bot',1,'task_bots.choose_startup_email_to_send_bot');

insert into task_manager.column_task_description (column_name ,default_freelancer,category,is_standalone,problem_description )
												 values('choose_startup_email_to_send','choose_startup_email_to_send_bot', 'bank',true,'');

--insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1008, 'customer_id','int');
--insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1008, 'message_uid','text');

CREATE OR REPLACE FUNCTION task_bots.choose_startup_email_to_send_bot(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	sqlstr text;
	_worker_initials text;
	_task_id_to_complete int;
	_parameters json;
	begin
		_worker_initials = 'choose_startup_email_to_send_bot'; -- this is for logging
		-- select * from task_manager.tasks where id = task_id; -- to get something from current task 		
		-- select task_bots.create_task ('task_type_name', '{}'); -- to create task of certain task type 
		
		--updating the current task for choose_startup_email_to_send_bot as completed
		update task_manager.tasks set task_status='completed' where id = task_id;
		--logging
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Complete task '||cast(task_id as text),'success');		
		return true;
	exception when others then
		insert into task_bots.logs(botname,"action","result") values ('insert_bot','Complete task '||cast(_task_id_to_complete as text) ||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$;

-------------------------------------------------------------------------
-- Test create task of 'choose_startup_email_to_send' type
-- select task_bots.create_task ('choose_startup_email_to_send', '{}');