CREATE OR REPLACE FUNCTION task_bots.send_email_bot(task_id integer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	sqlstr text;
	_name text;
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
	_fileId text;
	task_description_variables hstore;
	_query_prefix text;
	_query_suffix text;
begin
		_worker_initials = 'send_email_bot'; -- this is for logging
		----- getting all needed info
		select task_type_id , parameters ,name into _task_type_id, _parameters , _name from task_manager.tasks where id = task_id;
		if _task_type_id is null then
			select id into _task_type_id from task_manager.column_task_description where column_name = _name;
		end if;

		select parameter_name into _parameter from task_manager.task_parameters where task_type_id=_task_type_id;
		select query_to_get_variables , ultradox, template_url into _query, _ultradox, _fileId from task_manager.column_task_description where id=_task_type_id;
		raise notice 'query = %',_sqlstr;
		--getting id from parameter 
		_sqlstr = $$ select  '$$||_parameters||$$'::json ->> '$$|| _parameter||$$'$$;
		raise notice 'query = %',_sqlstr;
		execute _sqlstr into _param_value;
		--preparing the query
		_query_prefix = $$with results as ( $$;		
		_query_suffix = $$ ) select hstore(results.*) || hstore('fileId', $2) from results $$;
		_query =_query_prefix || _query ||_query_suffix;
		--getting the variables
		raise notice '%', _query;
		execute _query into task_description_variables using _param_value, _fileId;
		
		insert into actions (templateurl, action_parameters) values (_ultradox, task_description_variables);
		--updating the current task for send_email_bot as completed
		update task_manager.tasks set task_status='completed' where id = task_id;
		--logging
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Complete task '||cast(task_id as text),'success');
		return true;
	exception when others then
		raise notice 'ERROR %',SQLERRM;
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$
