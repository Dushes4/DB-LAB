create index name_index on Person using hash(name);
create index name_index on Person using hash(surname);
create index rent_user_index on Rent using btree(user_id);
create index task_scooter_t_index on Task_scooter using btree(task_id);
/*
create index task_employee_index on Task using btree(employee_id);
create index rent_scooter_index on Rent using btree(scooter_id);
create index parkingh_scooter_index on Parking_history using btree(scooter_id);
*/
