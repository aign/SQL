CREATE OR REPLACE VIEW gui.create_task_from_cell AS
 SELECT row_number() OVER () AS id,
    get_latest_selected_window() AS window_name,
    window_state.id AS id_selected,
    get_latest_selected_column() AS column_selected,
    '' AS task_details,
    column_task_description.task_description,
    column_task_description.ultradox,
    column_task_description.send_from,
    'n/a'::character varying AS worker_initials,
    ( SELECT choose_period.from_date
           FROM choose_period
          WHERE choose_period.id = get_selected_id_in_other_window('choose_period_view'::character varying)) AS from_date,
    ( SELECT choose_period.until_date
           FROM choose_period
          WHERE choose_period.id = get_selected_id_in_other_window('choose_period_view'::character varying)) AS until_date,
    0 AS email_customer,
    '' as new_task_type, 
    column_task_description.query_to_get_variables,
    column_task_description.query_to_get_parameters
   FROM ( SELECT get_latest_selected_ids.id
           FROM get_latest_selected_ids() get_latest_selected_ids(id)) window_state
     LEFT JOIN column_task_description ON column_task_description.column_name::text = get_latest_selected_column();