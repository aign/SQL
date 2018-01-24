CREATE OR REPLACE FUNCTION task_bots.create_task(task_type text, text[], freelancer text DEFAULT NULL::text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
 _name text;
 _freelancer text;
 _parameters json;
 _param_names text[];
 _param_values ALIAS FOR $2;
 _str text;
 _p_v jsonb;
 i int;
 type_id int;
begin		
	select id into type_id from task_manager.column_task_description where column_name = task_type;
	if type_id is not null then
		_str = '';
		select column_name,default_freelancer into _name, _freelancer from task_manager.column_task_description where id = type_id;
		if freelancer is not null then
			_freelancer = replace(freelancer,'"','');
		end if;
		select array_agg(parameter_name::text order by id) into _param_names  from task_manager.task_parameters where task_type_id =type_id ;
		raise notice '_param_names: %',_param_names; 
		if array_length(_param_names,1) <> array_length(_param_values,1) then
		    raise exception 'parameter count mismatch must be %, instead this function got % parameters',array_length(_param_names,1), array_length(_param_values,1);
		end if;
	    select json_object(_param_names , _param_values) into _p_v;
		raise notice 'freelancer = %',_freelancer;
		insert into tasks (name,worker_initials,parameters,task_type_id ) values (_name, _freelancer, _p_v, type_id);
		return true;
	else
		raise notice 'Task type % not found',task_type;
		
		insert into task_bots.logs(botname,"action","result") values ('task_bots.create_task' , 'Task type '||task_type||' not found', 'failed');
		return false;
	end if;
end;
$function$
