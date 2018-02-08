

CREATE or replace RULE create_email AS
    ON UPDATE TO create_task_from_cell
   WHERE (new.email_customer = 1 and new.new_task_type is null) DO INSTEAD
      	SELECT create_email_from_cell(new.task_description, (new.window_name)::character varying, 
   		(new.id_selected)::character varying, 
   		new.column_selected, 
   		new.query_to_get_variables, 
   		new.ultradox, 
   		new.send_from, 
   		new.from_date, 
   		new.until_date) 
   			AS create_email_from_cell;

CREATE or replace RULE create_email_with_bot AS
    ON UPDATE TO create_task_from_cell
   WHERE (new.email_customer = 1 and new.new_task_type is not null) DO INSTEAD
   		select task_bots.
      	SELECT create_email_from_cell(new.task_description, (new.window_name)::character varying, 
   		(new.id_selected)::character varying, 
   		new.column_selected, 
   		new.query_to_get_variables, 
   		new.ultradox, 
   		new.send_from, 
   		new.from_date, 
   		new.until_date) 
   			AS create_email_from_cell;


select * from task_bots.bots