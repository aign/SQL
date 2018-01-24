--select task_manager.add_new_task_type_with_parameters('new_authorization_added'::text, 'david'::text, true, array['authorization_name' ,'text']) 
CREATE OR REPLACE FUNCTION cron.check_if_new_authorization_added()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
	task_name text;
	_res text[];
	_function_parameters text[];
	i int;
begin
	task_name='new_authorization_added';

	_res = task_bots.compare_uids(task_name, $$
									select authorization_name as unique_id from authorizations group by authorization_name							$$::text);
	perform utils.create_task_from_array(_res,task_name);
end 
$function$
