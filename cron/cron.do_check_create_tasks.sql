CREATE OR REPLACE FUNCTION cron.do_check_create_tasks(task_name text , query text, column_name text default 'unique_id', worker_column_name text default null)
 RETURNS boolean 
 LANGUAGE 'plpgsql' VOLATILE COST 100
 AS $BODY$
declare
    _res json;
	_item json;
	_ids text[];
	_workers text[];
    _function_parameters text[];
    i int;
begin   

-- Use cases
-- 1. Create task with one parameter (that is being returned by query as unique_id) assigned to the default freelancer :
-- For example we want to create a task called 'test_task', 
-- that have one parameter "customer_id"	
--		cron.do_check_create_tasks('test_task' , $$ select id as unique_id from public.customers where id = 2 $$ )
--
-- 2. Create task with one parameter (that is NOT being returned by query as unique_id) assigned to the default freelancer :
-- For example we want to create a task called 'test_task', 
-- that have one parameter "primary_phone"	
--		cron.do_check_create_tasks('test_task' , $$ select id as unique_id , primary_phone from public.customers where id = 2 $$ ,'primary_phone')
-- or   cron.do_check_create_tasks('test_task' , $$ select id as unique_id , primary_phone from public.customers where id = 2 $$ ,column_name:='primary_phone')
--
-- 3. Create task with one parameter (that is being returned by query as unique_id) assigned to the specific freelancer returned from query :
-- For example we want to create a task called 'test_task', 
-- that have one parameter "customer_id"	
--		cron.do_check_create_tasks('test_task' , $$ select id as unique_id , the_accountant from public.customers where id = 2 $$ ,worker_column_name:= 'the_accountant' )
--
-- 4. Create task with one parameter (that is NOT being returned by query as unique_id) assigned to the specific freelancer returned from query :
-- For example we want to create a task called 'test_task', 
-- that have one parameter "primary_phone"	
--		cron.do_check_create_tasks('test_task' , $$ select id as unique_id ,primary_phone, the_accountant from public.customers where id = 2 $$,'primary_phone', 'the_accountant' )
-- or   cron.do_check_create_tasks('test_task' , $$ select id as unique_id ,primary_phone, the_accountant from public.customers where id = 2 $$,column_name:='primary_phone', worker_column_name:= 'the_accountant' )
	
	
    _res = task_bots.compare_uids_new(task_name, query);
	raise notice 'results = %',_res;
	_item=_res ->> column_name;
	if ((_item::text) != 'null' ) then
		_workers = null;
		if (worker_column_name is not null) then
			SELECT ARRAY(SELECT trim(elem::text, '"') into _workers 
                     FROM   json_array_elements(_res->worker_column_name) elem) AS txt_arr;
			raise notice 'workers = %',_workers;
		end if;

		SELECT ARRAY(SELECT trim(elem::text, '"' ) into _ids 
                     FROM   json_array_elements(_res->column_name) elem) AS txt_arr; 
		raise notice '%',_ids;
		perform utils.create_task_from_array(_ids,task_name,_workers);

	end if;
	return true;
	exception when others then
		raise exception 'ERROR :%',SQLERRM;
		return false;
end 
$BODY$

select cron.do_check_create_tasks('TEST_TASK',$$
                            select id as unique_id, id as freelancer_id, 'new_freelancer_registered_consider_sending_email'::text as script_name from task_manager.freelancers where strpos(email, 'revisor1') = 0 and id > 1068
                            $$,worker_column_name:='script_name')
