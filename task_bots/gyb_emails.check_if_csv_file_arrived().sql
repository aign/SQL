create or replace function gyb_emails.check_if_csv_file_arrived()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
	_file_path text;
	_message_uid text;
	_customer_id int;
	_js text[];
	_f_csv boolean;
	_mail_exist boolean;
	_subject text;
	_email text;
begin	
	raise notice 'START check_if_csv_file_arrived';
	select new.attachment_path , new.message_uid into _file_path, _message_uid;
	_file_path = gyb_emails.get_s3_file_path(_file_path);
	raise notice 'file_path = %',_file_path;
	_f_csv = _file_path like '%.csv';
	raise notice 'file_path_csv = %',_f_csv;
	if  _f_csv = 't' then		
		select count(message_uid)>0 from gyb_emails.messages into _mail_exist where message_uid = _message_uid and lower(email_to) = 'bank@revisor1.dk';
		if _mail_exist = true then
			select customer_id,email_subject from gyb_emails.messages into _customer_id, _subject where message_uid = _message_uid;			
			raise notice 'customer_id = %',_customer_id;
			if _customer_id is null then
		  		_customer_id =0;
			end if;
			_js = array[cast(_customer_id as text),_file_path];
			perform task_bots.create_task ('import_csv_file', _js);
			new.attachment_printed = 'passed to import_csv_file task';
		end if;	
	end if;
	raise notice 'END check_if_csv_file_arrived';
	return new;
end;
$function$;


create trigger check_if_csv_file_arrived BEFORE INSERT OR UPDATE
        on gyb_emails.attachments
         for each row
         execute procedure check_if_csv_file_arrived();         
         
         

