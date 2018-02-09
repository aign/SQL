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
declare
	_action_id int;
	_customer_id text;
begin
	if column_selected = 'yearly_holding_reminder_mail' then
		_customer_id = id_selected;
		raise notice '%',column_selected;
		perform task_bots.create_task('yearly_holding_reminder_mail'::text,array[_customer_id]);
		select id into _action_id from emails.actions where action_parameters->'customer_id' = _customer_id order by id desc limit 1; 
		insert into emails.cell_actions(action_id, cell_table, cell_column, cell_id) 
			values (_action_id, window_name, column_selected, _customer_id);
		insert into cell_colors (view_name, id_value, field_name, setting_value) 
			values (window_name, _customer_id, column_selected, '#00FF00') ON CONFLICT ON CONSTRAINT attempting_to_set_multiple_colors_on_a_cell_please_choose_just_ DO update SET setting_value = '#00FF00';
		insert into gui.cell_comments (cell_table, cell_column, cell_id, comment) 
				values (window_name, column_selected, cast(_customer_id as int), 
					utils.date_danish(now()::date)::varchar) ON CONFLICT ON CONSTRAINT attempting_to_set_multiple_comments_on_a_cell DO update SET comment = concat(now()::date::varchar, ' ', cell_comments.comment);
	else
		perform create_email_from_cell(task_description, window_name, id_selected, column_selected, query_to_get_variables, ultradox, send_from, from_date, until_date); 
	end if;
end 
$function$

