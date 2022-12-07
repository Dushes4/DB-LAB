create index name_index on Person using hash(name);
create index rent_user_index on Rent using hash(user_id);
create index task_employee_index on Task using hash(employee_id);
create index jobs_delivered_index on Jobs_done using btree(scooters_delivered);
create index jobs_solved_index on Jobs_done using btree(requests_solved);
create index task_scooter_t_index on Task_scooter using hash(task_id);
create index rent_scooter_index on Rent using hash(scooter_id);
create index parkingh_scooter_index on Parking_history using hash(scooter_id);
