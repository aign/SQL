CREATE OR REPLACE FUNCTION gui.get_selected_column_value_in_other_window(column_name text)
 RETURNS text
 LANGUAGE sql
 STABLE STRICT
AS $function$
	select cells_selected->0->>0 from gui.window_state 
	where cells_selected->0->>1 = column_name and username = current_setting('session.username') 
	order by last_updated desc limit 1	
$function$

--set session.username = 'ignatyuk.a@gmail.com'
--select gui.get_selected_column_value_in_other_window('id'::text)