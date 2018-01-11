CREATE OR REPLACE FUNCTION task_bots.compare_uids_new(task_name text, query text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
declare
	_sqlstr text;
	--_res text[];
	_res json;
	_tablename text;
	_tablename_short text;
	_new_tablename text;
	_table_exists text;
	_parameters text[];
	_column_names text[];	
	_p_str text;
	_w_str text;
begin
	
   	select array_agg(parameter_name) into _parameters from task_manager.task_parameters where task_type_id =    	
		(select id from task_manager.column_task_description where column_name=task_name);
	_sqlstr = ' with tbl as( SELECT row_to_json(t) x FROM  ('||query||' limit 1'||') as t ) select array_agg(key) from tbl, json_each(x);';
	execute _sqlstr into _column_names;

	_tablename = 'task_bots.cached_'||task_name;
	_tablename_short= 'cached_'||task_name; -- because alter table does not get schema name in tbale name
	_new_tablename = 'task_bots.new_cached_'||task_name;
	_table_exists = to_regclass(_tablename);
	raise notice '%',_table_exists;
	if _table_exists  is null then
		_sqlstr = 'drop table if exists '|| _tablename||' ;create table '||_tablename||' as '||query;
		raise notice '%',_sqlstr;
		execute _sqlstr;
		return '{}';
	end if;
	-- storing data from query into new_ table
	_sqlstr = 'drop table if exists '|| _new_tablename||' ;create table '||_new_tablename||' as '||query;	
	
	execute _sqlstr;
		
	_p_str = 'array_agg(newone.'||array_to_string(_column_names, '), array_agg(newone.')||')';
	_w_str = ' WITH data('|| array_to_string(_column_names, ',')||') AS ( ';
	raise notice '%' , _p_str;

	-- getting differences between query and stored results
	_sqlstr = _w_str|| $$ SELECT
  						$$|| _p_str ||$$ 
						FROM
 						$$ || _new_tablename || $$ as newone
						FULL OUTER JOIN $$|| _tablename ||$$ as oldone USING (unique_id)
						WHERE
 						oldone.unique_id IS null
 						) SELECT row_to_json(data) FROM data
			  $$;

 	execute _sqlstr into _res;

	-- deleting the old table and renaming new_ table 
	_sqlstr = 'drop table '|| _tablename||'; alter table '||_new_tablename||' rename to '||_tablename_short;
	execute _sqlstr;
	--returning the results
	return _res;

	exception when others then
		raise notice 'ERROR = %',SQLERRM;
		return '{}';
end 
$function$
