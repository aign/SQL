
CREATE OR REPLACE FUNCTION task_bots.check_if_non_paying_customer_exists()
 RETURNS void -- returning array because there can be more than one result
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
   	RAISE NOTICE '%', _res;
	if array_length(_res,1)>0 then
		FOR i IN 1 .. array_upper(_res, 1)
		LOOP
   			RAISE NOTICE '%', _res[i];
			_function_parameters =ARRAY[_res[i]];
			perform task_bots.create_task('check_why_non_paying_customer_is_sending_us_receipts'::text,_function_parameters );
		END LOOP;
	end if;

end 
$function$
