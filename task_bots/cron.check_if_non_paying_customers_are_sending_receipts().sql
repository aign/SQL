CREATE OR REPLACE FUNCTION cron.check_if_non_paying_customers_are_sending_receipts()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	_res text[];
	_function_parameters text[];
	i int;
begin
	_res = task_bots.compare_uids('check_why_non_paying_customer_is_sending_us_receipts'::text, $$
							select customer_id as unique_id, 
							customer_id, count(*)  
							from public.receipts inner join (
							select id from public.customers where has_customer_ever_paid_us_anything(id) is false and test_account is false) 
							as paying_customers on (customer_id = paying_customers.id) 
							--where customer_id not in (200121,200445)  
							group by customer_id
							$$::text);
	perform utils.create_task_from_array(_res,'check_why_non_paying_customer_is_sending_us_receipts');
end 
$function$
