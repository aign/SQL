insert into task_manager.column_task_description (column_name ,default_freelancer,category,is_standalone,problem_description )
values('bank@_received_email_without_attachments','david', 'bank',true,'Customer has sent message to bank@revisor1.dk without attachments')

select * from column_task_description where column_name ='bank@_received_email_without_attachments'
insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type)
values(1006, 'customer_id','int');
insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type)
values(1006, 'message_uid','text');
