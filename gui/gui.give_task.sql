CREATE OR REPLACE VIEW gui.give_task AS
 SELECT create_task_from_cell.id,
    create_task_from_cell.window_name,
    create_task_from_cell.id_selected,
    create_task_from_cell.column_selected,
    create_task_from_cell.task_details,
    create_task_from_cell.task_description,
    create_task_from_cell.ultradox,
    create_task_from_cell.worker_initials,
    create_task_from_cell.from_date,
    create_task_from_cell.until_date,
    create_task_from_cell.send_from,
    create_task_from_cell.email_customer,
    create_task_from_cell.query_to_get_variables,
    create_task_from_cell.query_to_get_parameters,
    create_task_from_cell.new_task_type
   FROM create_task_from_cell;