--select task_manager.add_new_task_type_with_parameters('investigate_customer_not_found'::text, 'david'::text, true, array['email_address' ,'text'])

CREATE OR REPLACE FUNCTION cron.check_if_received_email_from_unknown_email_address()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	_res text[];
	_function_parameters text[];
	i int;
	_name text;
begin
	_name = 'received_email_from_unknown_email_address';
	_res = task_bots.compare_uids(_name, $$
							select distinct(email_from) as unique_id, email_from from gyb_emails.messages  where email_to in (select address from gyb_emails.email_addresses_to_process)
							and email_from not in (select primary_email from public.customers where primary_email is not null) 
							$$::text);
	perform utils.create_task_from_array(_res,_name);
	insert into task_bots.logs(botname,action) values ('received_email_from_unknown_email_address','end');
end 
$function$


select cron.runs_every_minute()
select * from task_bots.logs order by id desc
-- select cron.check_if_received_email_from_unknown_email_address()
