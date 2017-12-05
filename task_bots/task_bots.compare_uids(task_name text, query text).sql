CREATE OR REPLACE FUNCTION task_bots.compare_uids(task_name text, query text)
 RETURNS text[] -- returning array because there can be more than one result
 LANGUAGE plpgsql
AS $function$
declare
	_sqlstr text;
	_res text[];
	_tablename text;
	_tablename_short text;
	_new_tablename text;
begin
	raise notice 'starting  compare_uids';
	_tablename = 'task_bots.cached_'||task_name;
	_tablename_short= 'cached_'||task_name; -- because alter table does not get schema name in tbale name
	_new_tablename = 'task_bots.new_cached_'||task_name;
	-- storing data from query into new_ table
	_sqlstr = 'drop table if exists '|| _new_tablename||' ;create table '||_new_tablename||' as '||query;	
	execute _sqlstr;
	-- getting differences between query and stored results
	SELECT
  		array_agg(unique_id) into _res
	FROM
 		task_bots.new_cached_check_why_non_paying_customer_is_sending_us_receipts as newone
	FULL OUTER JOIN task_bots.cached_check_why_non_paying_customer_is_sending_us_receipts as oldone USING (unique_id)
		WHERE
 		oldone.unique_id IS null;
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