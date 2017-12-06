CREATE OR REPLACE FUNCTION cron.check_if_customer_sent_first_receipt()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	_res text[];
	_function_parameters text[];
	i int;
begin
	_res = task_bots.compare_uids('send_email_to_customer_after_they_emailed_us_their_first_receipt'::text, $$
							select email_from as unique_id, email_from from messages inner join email_addresses_to_process on (email_to = address) group by email_from;
							$$::text);
	perform utils.create_task_from_array(_res,'send_email_to_customer_after_they_emailed_us_their_first_receipt');
end 
$function$


--select cron.check_if_customer_sent_first_receipt()
