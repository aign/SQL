--insert into task_manager.freelancers (worker_initials) values ('startup_sms_bot');
--select task_manager.add_new_task_type_with_parameters('startup_sms'::text, 'startup_sms_bot'::text, true, array['customer_id' ,'int' , 'sms_text','text'])
--select * from task_manager.column_task_description where column_name= 'startup_sms'
--insert into task_bots.bots ("name", "type","path",task_type_id) values('startup_sms_bot',1,'task_bots.startup_sms_bot',1029);

CREATE OR REPLACE FUNCTION task_bots.startup_sms_bot(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	botname text;
	task_type_name text;
	_view_name text;
	_query_to_get_variables text;
	_task_description text;
	_task_description_variables hstore;
	_ultradox text;
 	_customer_id int;
 	_sms_text text;
 	_customer_exists boolean;
 	_worker_initials text;
begin
		-- if parameter 'sms_text' of this task is null then this function will send sms to customer primery_phone with 
		-- text stored in 'task_description' column of task 'startup_sms'
		-- for example select task_bots.create_task('startup_sms'::text,array['200370',null]);
		-- if  'sms_text' of this task is NOT null then it will send sms with text from 'sms_text' parameter
		-- for example select task_bots.create_task('startup_sms'::text,array['200370','Some Text']);
		botname = 'startup_sms_bot';
		task_type_name = 'startup_sms';
		select parameters->>'customer_id',parameters->>'sms_text', worker_initials into _customer_id, _sms_text ,_worker_initials 
				from task_manager.tasks where id  = task_id;
		select  task_description, ultradox,query_to_get_variables,view_name 
			into _task_description, _ultradox, _query_to_get_variables, _view_name 
			from task_manager.column_task_description where column_name = task_type_name;
   		if _sms_text is not null then
   			_task_description=_sms_text;
   		end if;
		_query_to_get_variables = replace(_query_to_get_variables, 'VIEW_NAME', _view_name);
		if (_query_to_get_variables is not null) then
			execute _query_to_get_variables into _task_description_variables using _customer_id;
		end if;
		
		_task_description_variables =_task_description_variables||hstore('text',_task_description)||hstore('from_date',null)||hstore('sendFrom',null)||hstore('until_date',null)||hstore('mergedHtml.sendFrom',null);
		insert into emails.actions 
			(templateurl,action_parameters) values 
			(_ultradox,_task_description_variables);
		notify emailer;
			insert into task_bots.logs(botname,"action","result") values (_worker_initials,'SMS send text '||cast(_sms_text as text)||' for customer '||cast(_customer_id as text)||' task '||cast(task_id as text),'success');
			update task_manager.tasks set task_status='completed' where id = task_id;
			return true;
exception when others then
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'SMS send text '||cast(_sms_text as text)||' for customer '||cast(_customer_id as text)||' task '||cast(task_id as text)||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;	
end;
$function$;
