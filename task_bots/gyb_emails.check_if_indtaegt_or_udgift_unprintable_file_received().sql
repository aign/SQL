create or replace function gyb_emails.check_if_indtaegt_or_udgift_unprintable_file_received()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
	_file_path text;
	_message_uid text;
	_customer_id int;
	_js text[];
	_email_to text;
	_address_in_table int;
	
begin	
	raise notice 'START check_if_indtaegt_or_udgift_unprintable_file_received';	
	select new.attachment_path, new.message_uid into _file_path, _message_uid;
	select customer_id into _customer_id from gyb_emails.messages	where message_uid = _message_uid and email_to in (select address from gyb_emails.email_addresses_to_process); 
	if _customer_id is not null then
		raise notice 'file_path = %',_file_path;
		if reverse(substring(reverse(_file_path) from 1 for strpos(reverse(_file_path),'.'))) in (select extension from gyb_emails.unprintable_file_extensions) then	
			_file_path = gyb_emails.get_s3_file_path(_file_path);
			raise notice 'file_path = %',_file_path;
			_js = array[cast(_customer_id as text), _message_uid ,   _file_path];
			raise notice 'json = %',_js;				
			perform task_bots.create_task ('indtaegt_or_udgift_unprintable_file_received', _js);
			new.attachment_printed = 'UNPRINTABLE FILE';
		end if;
	end if;
	raise notice 'END check_if_indtaegt_or_udgift_unprintable_file_received';	
	return new;
end;
$function$;

create trigger check_if_indtaegt_or_udgift_unprintable_file_received BEFORE INSERT OR UPDATE
        on gyb_emails.attachments
         for each row
         execute procedure check_if_indtaegt_or_udgift_unprintable_file_received();
