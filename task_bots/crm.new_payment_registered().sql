
--select task_manager.add_new_task_type_with_parameters('fill_out_missing_information_from_onboarding_process'::text, 'david'::text, true, array['parameters' ,'text'])
select * from task_manager.column_task_description where column_name = 'fill_out_missing_information_from_onboarding_process'
select * from task_manager.task_parameters where task_type_id = 1023
insert into task_manager.task_parameters  (task_type_id, parameter_name, data_type) values (1023,'customer_id','int')

CREATE OR REPLACE FUNCTION crm.new_payment_registered()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
	new_invoice_number int;
	_customer_id int;
	_task_parameter text;
	_onboarder text;
	_task_name text;
begin
	_task_name = 'fill_out_missing_information_from_onboarding_process';
	select "crm"."set_invoice_number_for_new_payments"(NEW.id) into new_invoice_number;
	perform "crm"."send_receipt"(new_invoice_number, false);
	perform crm.choose_startup_email_to_send(NEW.id);
	select "crm"."get_customer_id_from_stripe_description"(new.description) into _customer_id;
	select crm.check_all_fields_filled_out_to_onboard_customer(_customer_id) into _task_parameter;
	select onboarder into _onboarder from public.customers where id = _customer_id;
	raise notice 'customer_id = %',_customer_id;
	if (_task_parameter is not null) and (_onboarder is not null) then		
		perform utils.create_task_from_array(array[[_task_parameter,cast(_customer_id as text) ]], _task_name, array[_onboarder]);
	end if;
	RETURN NEW;
	exception when others then
		perform utils.create_task_from_array(array[['crm.new_payment_registered',SQLERRM]], 'handle_system_error'::text, array['david']);	
  		RETURN NEW;
END;
$function$

select * from crm.stripe_charges order by id desc
select id,onboarder from public.customers where primary_email like 'ignat%'
200370

insert into crm.stripe_charges (description) values ('200370-00000')

select (array['a'::text,'1'::text])
select * from task_manager.tasks order by id desc
select array_agg(onboarder) from public.customers where id = 200370
select crm.check_all_fields_filled_out_to_onboard_customer(200181)
select array_agg('a'::text)
select "crm"."get_customer_id_from_stripe_description"('200181-10095') 

select id,crm.check_all_fields_filled_out_to_onboard_customer(id) from public.customers
select array_length('{"a"}'::text[],1)
crm.get_customer_id_from_stripe_description(description)) 
		from crm.stripe_charges