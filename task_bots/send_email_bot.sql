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
CREATE OR REPLACE FUNCTION task_bots.send_email_bot(task_id int)
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
	_param_value text;
	_sqlstr text;
	_query text;
	_view_name text;
	_email_address text;
	_ultradox text;
begin
		raise notice '-----------------------------------------------STARTING send_email_bot-----------------------------------------------------------------------------------';
		_worker_initials = 'send_email_bot'; -- this is for logging
		select task_type_id , parameters  into _task_type_id, _parameters from task_manager.tasks where id = task_id;
		select parameter_name into _parameter from task_manager.task_parameters where task_type_id=_task_type_id;
		select query_to_get_variables , view_name, ultradox into _query,_view_name, _ultradox from task_manager.column_task_description where id=_task_type_id;
		
		raise notice 'task_type_id = %',_task_type_id;
		raise notice 'parameters = %',_parameters;
		raise notice 'query = %',_query;
		_sqlstr = $$ select  '$$||_parameters||$$'::json ->> '$$|| _parameter||$$'$$;
		raise notice 'SQL = %',_sqlstr;
		execute _sqlstr into _param_value;
		raise notice 'parameter = %',_param_value;
		_query = replace(_query, '$1', _view_name);
		_query= replace(_query, '$2', _param_value);
		raise notice 'query = %',_query;
		execute _query into _email_address;
		--select * from task_manager.task_parameters where task_type_id =
		if  _email_address is null then 
			raise exception 'Can not find email for %  = %', _parameter ,_param_value;
		end if;
		raise notice 'email = %',_email_address;
		insert into actions (templateurl, action_parameters) values (_ultradox, 
        hstore('query_that_failed', ' ') || hstore('primary_email', _email_address) || hstore('description', ' '));
		notify emailer;
		--updating the current task for send_email_bot as completed
		raise notice 'task_id = %',task_id;
		update task_manager.tasks set task_status='completed' where id = task_id;
		raise notice '-';
		--logging
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Complete task '||cast(task_id as text),'success');
		raise notice '-----------------------------------------------send_email_bot END-----------------------------------------------------------------------------------';
		return true;
	exception when others then
		raise notice 'ERROR %',SQLERRM;
		insert into task_bots.logs(botname,"action","result") values ('insert_bot','Complete task '||cast(_task_id_to_complete as text) ||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$;
-----------------------
-- Test create task of 'choose_startup_email_to_send' type
-- select task_bots.create_task ('deleteme_send_random_email_freelancer', '{29}');
-- select task_bots.create_task ('deleteme_send_random_email_customer', '{200370}');
