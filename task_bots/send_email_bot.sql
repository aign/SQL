-------------------------------------------------------------------------------------------------------------------------------------------
-- PREPARATIONS
-------------------------------------------------------------------------------------------------------------------------------------------
insert into task_manager.freelancers(worker_initials) values ('send_email_bot');
insert into task_bots.bots(name , type,path) values ('send_email_bot',1,'task_bots.send_email_bot');
-------------------------------------------------------------------------------------------------------------------------------------------
-- Task type for freelancer
-------------------------------------------------------------------------------------------------------------------------------------------

insert into task_manager.column_task_description (column_name ,default_freelancer,category,is_standalone,problem_description,ultradox )
												 values('deleteme_send_random_email_freelancer','send_email_bot', 'bank',true,'','https://www.ultradox.com/run/8sn1oYorh7jXjgQ12gfKlBYlCL2wuq');
insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1009, 'freelancer_id','int');



-------------------------------------------------------------------------------------------------------------------------------------------
-- Task type for customer
-------------------------------------------------------------------------------------------------------------------------------------------
insert into task_manager.column_task_description (column_name ,default_freelancer,category,is_standalone,problem_description, ultradox )
												 values('deleteme_send_random_email_customer','send_email_bot', 'bank',true,'','https://www.ultradox.com/run/8sn1oYorh7jXjgQ12gfKlBYlCL2wuq');												 
insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1010, 'customer_id','int');



--------------------------------------------------
CREATE OR REPLACE FUNCTION task_bots.send_email_bot(task_id integer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	sqlstr text;
	_worker_initials text;
	_task_id_to_complete int;
	_task_type_id int;
	_parameters json;
	_parameter text;
	_param_value int;
	_sqlstr text;
	_query text;
	_email_address text;
	_ultradox text;
	task_description_variables hstore;
begin
		_worker_initials = 'send_email_bot'; -- this is for logging
		----- getting all needed info
		select task_type_id , parameters  into _task_type_id, _parameters from task_manager.tasks where id = task_id;
		select parameter_name into _parameter from task_manager.task_parameters where task_type_id=_task_type_id;
		select query_to_get_variables , ultradox into _query, _ultradox from task_manager.column_task_description where id=_task_type_id;
		
		--getting id from parameter 
		_sqlstr = $$ select  '$$||_parameters||$$'::json ->> '$$|| _parameter||$$'$$;
		execute _sqlstr into _param_value;
		
		execute _query into task_description_variables using _param_value;
		
		insert into actions (templateurl, action_parameters) 
			values (_ultradox, task_description_variables);
		notify emailer;
		--updating the current task for send_email_bot as completed
		update task_manager.tasks set task_status='completed' where id = task_id;
		--logging
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Complete task '||cast(task_id as text),'success');
		return true;
	exception when others then
		raise notice 'ERROR %',SQLERRM;
		insert into task_bots.logs(botname,"action","result") values ('insert_bot','Complete task '||cast(_task_id_to_complete as text) ||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$
-----------------------
-- Test create task of 'choose_startup_email_to_send' type
-- select task_bots.create_task ('deleteme_send_random_email_freelancer', '{29}');
-- select task_bots.create_task ('deleteme_send_random_email_customer', '{200370}');
