create or replace function gyb_emails.check_if_received_email_with_pdf_attachment()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
_file_path text;
	_message_uid text;
	_customer_id int;
	_js text[];
	_f_pdf boolean;
	_mail_exist boolean;
begin	
	raise notice 'START check_if_received_email_with_pdf_attachment';
	select new.attachment_path , new.message_uid into _file_path, _message_uid;
	_file_path = gyb_emails.get_s3_file_path(_file_path);
	raise notice 'file_path = %',_file_path;
	_f_pdf = _file_path like '%.pdf';
	raise notice 'file_path_pdf = %',_f_pdf;
	if  _f_pdf = true then
		raise notice 'file_path_pdf ';
		select count(customer_id)>0 from gyb_emails.messages into _mail_exist where message_uid = _message_uid and lower(email_to) = 'bank@revisor1.dk';
		if _mail_exist = true then
			select customer_id from gyb_emails.messages into _customer_id where message_uid = _message_uid and lower(email_to) = 'bank@revisor1.dk';
			if _customer_id is null then
		  		_customer_id =0;
			end if;
			raise notice 'customer_id = %',_customer_id;
			_js = array[cast(_customer_id as text),_file_path];
			raise notice 'json = %',_js;
			perform task_bots.create_task ('bank@_received_email_with_pdf_attachment', _js);
			new.attachment_printed = 'passed to bank@_received_email_with_pdf_attachment task';
		end if;	
	end if;
	raise notice 'END check_if_received_email_with_pdf_attachment';
	return new;
	end;
$function$;

create trigger check_if_received_email_with_pdf_attachment BEFORE INSERT OR UPDATE
        on gyb_emails.attachments
         for each row
         execute procedure check_if_received_email_with_pdf_attachment();
         