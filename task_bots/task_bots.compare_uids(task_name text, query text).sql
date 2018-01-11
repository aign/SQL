CREATE OR REPLACE FUNCTION task_bots.compare_uids(task_name text, query text)
 RETURNS text[]
 LANGUAGE plpgsql
AS $function$
declare
	_sqlstr text;
	_res text[];
	_tablename text;
	_tablename_short text;
	_new_tablename text;
	_table_exists text;
begin
	_tablename = 'task_bots.cached_'||task_name;
	_tablename_short= 'cached_'||task_name; -- because alter table does not get schema name in tbale name
	_new_tablename = 'task_bots.new_cached_'||task_name;
	--_sqlstr = $$ SELECT to_regclass($$||_tablename ||$$) is null $$;
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
	-- getting differences between query and stored results
	_sqlstr = $$
	SELECT
  		array_agg(unique_id) 
	FROM
 		$$ || _new_tablename || $$ as newone
	FULL OUTER JOIN $$|| _tablename ||$$ as oldone USING (unique_id)
		WHERE
 		oldone.unique_id IS null;$$;
	raise notice '%',_sqlstr;
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
