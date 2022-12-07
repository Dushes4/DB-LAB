CREATE OR REPLACE FUNCTION complete_task()
returns TRIGGER
as $$
declare
  task_r record;
  temprow record;
  s integer;
begin
  SELECT * INTO task_r FROM Task WHERE task_id = new.task_id;
  if task_r.is_done = 'True' then
    s := 0;
    for temprow IN SELECT * FROM Task_scooter WHERE task_id = task_r.task_id
    loop
    s := s + 1;
    end loop;
    if EXISTS (SELECT FROM Jobs_done WHERE employee_id = task_r.employee_id AND "date" = DATE(task_r.datetime)) then
      UPDATE Jobs_done SET scooters_delivered = scooters_delivered + s WHERE employee_id = task_r.employee_id AND "date" = DATE(task_r.datetime);
    else 
      INSERT INTO Jobs_done("date", requests_solved, scooters_delivered, employee_id) VALUES (DATE(task_r.datetime), '0', s, task_r.employee_id);
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

CREATE TRIGGER task_complete
    after INSERT OR UPDATE ON Task_scooter
    for each row
    execute procedure complete_task();



CREATE OR REPLACE FUNCTION solve_request()
returns TRIGGER
as $$
begin
  if new.is_resolved = 'True' then
    if EXISTS (SELECT FROM Jobs_done WHERE employee_id = new.employee_id AND "date" = DATE(new.datetime)) then
      UPDATE Jobs_done SET requests_solved = requests_solved + 1 WHERE employee_id = new.employee_id AND "date" = DATE(new.datetime);
    else 
      INSERT INTO Jobs_done("date", requests_solved, scooters_delivered, employee_id) VALUES (DATE(new.datetime), '1', '0', new.employee_id);
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

CREATE TRIGGER request_solved
    after INSERT OR UPDATE ON Support_request
    for each row
    execute procedure solve_request();



CREATE OR REPLACE FUNCTION change_job()
returns TRIGGER
as $$
begin
  if new.job_type = 'support' then
    insert into Appointment(job_id, employee_id, "date") VALUES ('1', new.employee_id, current_date);
  end if;
  if new.job_type = 'scout' then
    insert into Appointment(job_id, employee_id, "date") VALUES ('2', new.employee_id, current_date);
  end if;
  if new.job_type = 'driver' then
    insert into Appointment(job_id, employee_id, "date") VALUES ('3', new.employee_id, current_date);
  end if;
  return new;
end;
$$ language plpgsql;

CREATE TRIGGER job_change
    after INSERT OR UPDATE ON Employee
    for each row
    execute procedure change_job();



CREATE OR REPLACE FUNCTION park_user()
returns TRIGGER
as $$
declare 
  p_id integer;
begin
  if EXISTS (SELECT FROM Parking WHERE new.finish_longitude = longitude AND new.finish_latitude = latitude) then
    SELECT parking_id INTO p_id FROM Parking 
      WHERE new.finish_longitude = longitude 
      AND new.finish_latitude = latitude;
    
    INSERT into Parking_history(datetime, parking_id, scooter_id) VALUES (new.finish_time, p_id, new.scooter_id);
  end if;
  
  return new;
end;
$$ language plpgsql;

CREATE TRIGGER user_park
    after INSERT ON Rent
    for each row
    execute procedure park_user();



CREATE OR REPLACE FUNCTION park_employee()
returns TRIGGER
as $$
declare 
  task_r record;
  temprow record;
begin
  SELECT * INTO task_r FROM Task WHERE task_id = new.task_id;
  if task_r.is_done = 'True' then
    for temprow IN SELECT * FROM Task_scooter WHERE task_id = task_r.task_id
    loop
    INSERT into Parking_history(datetime, parking_id, scooter_id) VALUES (task_r.datetime, task_r.parking_id, temprow.scooter_id);
    end loop;
  end if;
  
  return new;
end;
$$ language plpgsql;

CREATE TRIGGER employee_park
    after INSERT ON Task_scooter
    for each row
    execute procedure park_employee();
------------------------------------------------------------------------------
