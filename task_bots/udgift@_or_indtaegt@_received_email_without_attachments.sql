insert into task_manager.column_task_description (column_name ,default_freelancer,category,is_standalone,problem_description )
values('udgift@_or_indtaegt@_received_email_without_attachment','david', 'bank',true,'Customer has sent pdf file to udgift@_or_indtaegt@_')

SELECT * FROM task_manager.column_task_description WHERE id =1007
udgift@_or_indtaegt@_received_email_without_attachment 

insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type)
values(1007, 'customer_id','int');
insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type)
values(1007, 'message_uid','text');
