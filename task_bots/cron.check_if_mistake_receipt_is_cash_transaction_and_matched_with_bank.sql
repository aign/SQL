--select task_manager.add_new_task_type_with_parameters('fix_mistake_receipt_is_cash_transaction_and_matched_with_bank'::text, 'david'::text, true, array['receipt_id' ,'int']) 
CREATE OR REPLACE FUNCTION cron.check_if_mistake_receipt_is_cash_transaction_and_matched_with_bank()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	_res text[];
	_function_parameters text[];
	i int;
	_name text;
begin
	_name = 'fix_mistake_receipt_is_cash_transaction_and_matched_with_bank';
	_res = task_bots.compare_uids(_name, $$
										select id  as unique_id from receipts where id in 
											(select receipt_id from reconciliations where bank_transaction_id = -1) and id in 
											(select receipt_id from reconciliations where bank_transaction_id <> -1)							
									$$::text);
	perform utils.create_task_from_array(_res,_name);
end 
$function$
