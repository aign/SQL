CREATE OR REPLACE FUNCTION cron.check_offset_account_is_bank_but_receipt_not_matched_with_bank_()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	--_res text[];
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
	_item=_res ->'unique_id';
	if ((_item::text) != 'null' ) then
		select array_agg(value) into _ids from json_array_elements(_res ->'unique_id');
		select array_agg(value) into _values from json_array_elements(_res ->'the_accountant');
		perform utils.create_task_from_array(_ids,_name,_values);
	end if;
end 
$function$

select cron.check_offset_account_is_bank_but_receipt_not_matched_with_bank_()

select ('{"unique_id":null,"the_accountant":null}'::json->'unique_id')::text = 'null'
