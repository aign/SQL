create or replace function task_bots.send_sms(customer_id int, message_text text)
returns boolean
LANGUAGE plpgsql
AS $function$
declare
 _customer_phone text; 
begin
	select primary_phone into _customer_phone from public.customers where id = customer_id;
	insert into emails.actions 
	(templateurl,action_parameters) values 
	('https://rest.nexmo.com/sms/json',
	hstore('from_date',null)|| 
	hstore('api_key','7ae91a90')||
	hstore('sendFrom',null)|| 
	hstore('from','Revisor1')|| 
	hstore('to',_customer_phone)|| 
	hstore('text',message_text)|| 
	hstore('until_date','null')|| 
	hstore('api_secret','9761fce526ec805a')|| 
	hstore('mergedHtml.sendFrom',null));
	notify emailer;
	return true;
	exception when others then
		insert into task_bots.logs(botname,"action","result") values ('send_sms_function','SMS send text '||cast(_sms_text as text)||' for customer '||cast(_customer_id as text)||' task '||cast(task_id as text)||' ERROR:'||SQLERRM,'failed');
		return false;
end;
$function$

