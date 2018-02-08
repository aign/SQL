CREATE OR REPLACE FUNCTION emails.create_email_from_cell_new(
		task_description character varying, 
		window_name character varying, 
   		id_selected character varying, 
   		column_selected text, 
   		query_to_get_variables character varying, 
   		ultradox character varying, 
   		send_from character varying, 
   		from_date date, 
   		until_date date)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
	if column_selected = 'yearly_holding_reminder_mail' then
		raise notice '%',column_selected;
		perform task_bots.create_task('yearly_holding_reminder_mail'::text,array[id_selected]);
	else
	perform create_email_from_cell(task_description, window_name, id_selected, column_selected, query_to_get_variables, ultradox, send_from, from_date, until_date); 
	end if;
end 
$function$