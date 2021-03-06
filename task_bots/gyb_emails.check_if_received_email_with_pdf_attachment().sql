select * from task_manager.column_task_description where column_name = 'bank@_received_email_with_pdf_attachment'

select * from task_manager.task_parameters where task_type_id = 1004 
insert into task_manager.task_parameters (task_type_id, parameter_name,data_type) values (1004,'file_path','text')

CREATE OR REPLACE FUNCTION gyb_emails.check_if_received_email_with_pdf_attachment()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
_file_path text;
	_message_uid text;
	_customer_id int;
	_js text[];
	_f_pdf boolean;
	_mail_exist boolean;
	_subject text;
	_email text;
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
		if _mail_exist = true THEN		
			select customer_id,email_subject from gyb_emails.messages into _customer_id,_subject where message_uid = _message_uid and lower(email_to) = 'bank@revisor1.dk';
			if _customer_id is null then
		  		_customer_id =0;
			end if;

			raise notice 'customer_id = %',_customer_id;
			_js = array[cast(_customer_id as text),_message_uid,_file_path];
			raise notice 'json = %',_js;
			perform task_bots.create_task ('bank@_received_email_with_pdf_attachment', _js);
			new.attachment_printed = 'passed to bank@_received_email_with_pdf_attachment task';
		end if;	
	end if;
	raise notice 'END check_if_received_email_with_pdf_attachment';
	return new;
	end;
$function$
