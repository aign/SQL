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
 _customer_id int;
 _sms_text text;
 _customer_exists boolean;
 _worker_initials text;
begin
		botname = 'startup_sms_bot';
		select parameters->>'customer_id',parameters->>'sms_text', worker_initials into _customer_id, _sms_text ,_worker_initials from task_manager.tasks where id  = task_id;			
		select count(id)>0 into _customer_exists from public.customers where id= _customer_id;
		if _customer_exists then
			perform task_bots.send_sms(_customer_id , _sms_text);
			insert into task_bots.logs(botname,"action","result") values (_worker_initials,'SMS sent text '||cast(_sms_text as text)||' for customer '||cast(_customer_id as text)||' task '||cast(task_id as text),'success');
			update task_manager.tasks set task_status='completed' where id = task_id;
			return true;
		else raise exception 'Customer does not exists !';
		end if;
exception when others then
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'SMS sent text '||cast(_sms_text as text)||' for customer '||cast(_customer_id as text)||' task '||cast(task_id as text)||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;	
end;
$function$;

--select task_bots.create_task('startup_sms'::text,array['200370','test']);
