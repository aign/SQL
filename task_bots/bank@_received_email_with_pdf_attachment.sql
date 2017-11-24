insert into task_manager.column_task_description (column_name ,default_freelancer,category,is_standalone,problem_description )
values('bank@_received_email_with_pdf_attachment','david', 'bank',true,'Customer has sent pdf file to bank@revisor1.dk')

insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type)
values(1004, 'customer_id','int');
insert into  task_manager.task_parameters (task_type_id,parameter_name,data_type)
values(1004, 'email_id','text');
