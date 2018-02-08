CREATE OR REPLACE FUNCTION gui.get_latest_selected_column_value(column_name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare 
  _view_name text;
  _id int;
  _sqlstr text;
  _result text;
  _window_name text;
begin
	select window_name into _window_name from gui.window_state 
		where cells_selected->0->>1 = column_name and username = current_setting('session.username') 
	order by last_updated desc limit 1;
	raise notice 'un = %',current_setting('session.username');
	raise notice 'wn = %',_window_name;
	select TRIM (
 		trailing ';'
 		FROM ((regexp_split_to_array(substring( query, position('from ' in query)+5 ,20),' ') )[1])
 		) into _view_name
 	from gui.windows where name = (_window_name);
 	
	WITH main AS (select * from gui.window_state 
	where cells_selected->0->>1 = column_name and username = current_setting('session.username') 
	order by last_updated desc limit 1),
    	 elems AS (SELECT elem FROM main, json_array_elements(main.cells_selected::json) AS elem)
	SELECT (elem->>0)::int into _id FROM elems WHERE (SELECT COUNT(DISTINCT elem->>0) FROM elems) = 1 and elem->>1 = column_name LIMIT 1;
	raise notice 'cn = %',column_name;
	raise notice 'vn = %',_view_name;
	raise notice 'id = %',_id;
	_sqlstr = 'select '||column_name||' from '||_view_name||' where id = '||_id;
	raise notice '%',_sqlstr;
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
