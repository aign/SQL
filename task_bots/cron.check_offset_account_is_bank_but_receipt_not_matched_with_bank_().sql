CREATE OR REPLACE FUNCTION cron.check_offset_account_is_bank_but_receipt_not_matched_with_bank_()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	_res json;
	_function_parameters text[];
	i int;
	_name text;
	_item json;
	_ids text[];
	_values text[];
begin
	_name = 'offset_account_is_bank_but_receipt_not_matched_with_bank_transaction';
	_res = task_bots.compare_uids_new(_name, $$
							select receipts.id as unique_id, the_accountant from receipts left join reconciliations on (receipt_id = receipts.id) left join customers on (customer_id = customers.id) where offset_account = 5820 and (bank_transaction_id is null or bank_transaction_id = -1) and deleted = false 
							$$::text);
	--results are returned as json arrays
	--for example  {"unique_id":[1003547,1003548],"the_accountant":["jens","someone"]}
	--"unique_id" and "the_accountant" in the example above are columns that provided in query passed to task_bots.compare_uids_new function
	--you can set any columns in query for exaple "select id, name, customer_id, email from ..."
	--and the result will be {"id":[1,2],"name":["name_1","name_2"], "customer_id":[100,101], "email:["a@a.com","b@b.com"]"}
	_item=_res ->'unique_id';
	--here we check if there is results for column unique_id
	--if there are no records then result will be '{"unique_id":null,"the_accountant":null}'
	--but null here is text 'null' so isnull() won't work
	if ((_item::text) != 'null' ) then
		--to access any desired array yo have to convert it from json to postgres array by 
		--calling this select array_agg(value) into _ids from json_array_elements(_res ->'unique_id'); 
		--where _res ->'unique_id' - is array of values returned for column unique_id  
		select array_agg(value) into _ids from json_array_elements(_res ->'unique_id');
		select array_agg(value) into _values from json_array_elements(_res ->'the_accountant');
		perform utils.create_task_from_array(_ids,_name,_values);
	end if;
end 
$function$
