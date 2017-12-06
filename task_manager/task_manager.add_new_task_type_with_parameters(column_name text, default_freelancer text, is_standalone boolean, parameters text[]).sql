create or replace function task_manager.add_new_task_type_with_parameters(column_name text, default_freelancer text, is_standalone boolean, parameters text[])
	returns boolean
 	LANGUAGE plpgsql
AS $function$
declare
	_new_task_type_id int;
	i int;
begin	
	insert into task_manager.column_task_description (column_name , default_freelancer, is_standalone) values (column_name , default_freelancer , is_standalone ) returning id into _new_task_type_id;
	if array_length(parameters, 1)>0 then
		if mod(array_length(parameters, 1),2) = 0 then -- parameters must be in pairs parameter_name, data_type like this one ['email_address' ,'text'] or ['email_address' ,'text' ,'customer_id', 'int']
			i=1;
			while i <= array_length(parameters, 1) 
			loop
				insert into task_manager.task_parameters(task_type_id , parameter_name, data_type)
											values(_new_task_type_id, parameters[i] , parameters[i+1]);
				i := i + 2 ; 
 			end loop ;

		else
			raise exception 'parameters count must be even';
			return false;
		end if;
	end if;
	return true;
exception when others then
	raise notice 'ERROR = %',SQLERRM;
	return false;
end 
$function$

-- sample execute
-- select task_manager.add_new_task_type_with_parameters('send_email_to_customer_after_they_emailed_us_their_first_receipt'::text, 'alexey'::text, true, array['email_address' ,'text'])