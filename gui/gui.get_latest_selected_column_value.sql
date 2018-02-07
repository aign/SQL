CREATE OR REPLACE FUNCTION gui.get_latest_selected_column_value(column_name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare 
  _view_name text;
  _id int;
  _sqlstr text;
  _result text;
begin
	select TRIM (
 		trailing ';'
 		FROM ((regexp_split_to_array(substring( query, position('from ' in query)+5 ,20),' ') )[1])
 		) into _view_name
 	from gui.windows where name = (SELECT window_name FROM gui.window_state WHERE username = current_setting('session.username') ORDER BY last_updated DESC LIMIT 1);
 	
	WITH main AS (SELECT * FROM gui.window_state WHERE username = current_setting('session.username') ORDER BY last_updated DESC LIMIT 1),
    	 elems AS (SELECT elem FROM main, json_array_elements(main.cells_selected::json) AS elem)
	SELECT (elem->>0)::int into _id FROM elems WHERE (SELECT COUNT(DISTINCT elem->>0) FROM elems) = 1 and elem->>1 = column_name LIMIT 1;
	_sqlstr = 'select '||column_name||' from '||_view_name||' where id = '||_id;
	execute _sqlstr into _result;
	return _result;
exception when others then
	return null;
	
end;
$function$


--set session.username = 'ignatyuk.a@gmail.com';
--select gui.get_latest_selected_column_value('primary_phone')
--select gui.get_latest_selected_column_value('vat_code')
--select gui.get_latest_selected_column_value('primary_email')

