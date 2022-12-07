CREATE OR REPLACE FUNCTION get_scooters_by_parking(target_parking_id INTEGER) 
returns table(
	scooter_id INTEGER,
	battery_charge INTEGER) AS
$$
begin
	if (SELECT COUNT(*) FROM Parking WHERE parking_id = target_parking_id) = 0 then
		RAISE NOTICE 'Parking with this id does not exist';
		return;
    elsif (SELECT COUNT(*) FROM Parking 
			JOIN Scooter ON Parking.latitude = Scooter.latitude 
			AND Parking.longitude = Scooter.longitude
			WHERE Parking.parking_id = target_parking_id) = 0 then
        RAISE NOTICE 'There are no scooters';
		return;
	else
		return query SELECT Scooter.scooter_id, Scooter.battery_charge FROM Parking
			JOIN Scooter ON Parking.latitude = Scooter.latitude AND Parking.longitude = Scooter.longitude
			WHERE Parking.parking_id = target_parking_id;		
    end if;
end;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION get_rents(request_user_id INTEGER) 
returns table(
	scooter_id INTEGER,
	start_latitude FLOAT,
	start_longitude FLOAT,
	start_time TIMESTAMP,
	finish_latitude FLOAT,
	finish_longitude FLOAT,
	finish_time TIMESTAMP) AS
$$
begin
	if (SELECT COUNT(*) FROM "User" WHERE User_id = request_user_id) = 0 then
		RAISE NOTICE 'User with this id does not exist';
		return;
    elsif (SELECT COUNT(*) FROM Rent WHERE User_id = request_user_id) = 0 then
        RAISE NOTICE 'This user has no rents';
		return;
	else
		return query SELECT Rent.scooter_id, Rent.start_latitude, Rent.start_longitude, Rent.start_time, 
											Rent.finish_latitude, Rent.finish_longitude, Rent.finish_time FROM Rent 
			WHERE User_id = request_user_id;	
    end if;
end;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION get_requests(request_user_id INTEGER) 
returns table(
	request_text TEXT,
	request_reply TEXT,
	datetime TIMESTAMP) AS
$$
begin
	if (SELECT COUNT (*) FROM "User" WHERE user_id = request_user_id) = 0 then
		RAISE NOTICE 'User with this id does not exist';
		return;
    elsif (SELECT COUNT(*) FROM Support_request WHERE user_id = request_user_id) = 0 then
        RAISE NOTICE 'There are no requests from this user';
		return;
	else
		return query SELECT Support_request.request_text, Support_request.request_text, Support_request.datetime
			FROM Support_request WHERE Support_request.user_id = request_user_id;
		
    end if;
end;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION get_available_tasks(request_employee_id INTEGER) 
returns table(
	task_id INTEGER,
	scooter_id INTEGER,
	parking_id INTEGER,
	latitude FLOAT,
	longitude FLOAT) AS
$$
begin
	if (SELECT COUNT (*) FROM Employee WHERE employee_id = request_employee_id) = 0 then
		RAISE NOTICE 'Employee with this id does not exist';
		return;
    elsif (SELECT COUNT(*) FROM Task WHERE employee_id = request_employee_id 
										AND DATE(datetime) = CURRENT_DATE
										AND is_done = 'False') = 0 then
        RAISE NOTICE 'There are no available tasks';
		return;
	else
		return query SELECT Task.task_id, Task_scooter.scooter_id, Task.parking_id, Parking.latitude, Parking.longitude FROM Task 
			JOIN Task_scooter ON Task.task_id = Task_scooter.task_id 
			JOIN Parking ON Task.parking_id = Parking.parking_id
			WHERE employee_id = request_employee_id 
				AND DATE(datetime) = CURRENT_DATE
				AND is_done = 'False';	
    end if;
end;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION get_available_requests(request_support_id INTEGER) 
returns table(
	request_text TEXT,
	datetime TIMESTAMP,
	name VARCHAR(50),
	surname VARCHAR(50)) AS
$$
begin
	if (SELECT COUNT (*) FROM Employee WHERE employee_id = request_support_id) = 0 then
		RAISE NOTICE 'Employee with this id does not exist';
		return;
    elsif (SELECT COUNT(*) FROM Support_request WHERE employee_id = request_support_id AND is_resolved = 'False') = 0 then
        RAISE NOTICE 'There are no available tasks';
		return;
	else
		return query SELECT Support_request.request_text, Support_request.is_resolved, Person.name, Person.surname
			FROM Support_request
			JOIN "User" ON Support_request.user_id = "User".user_id
			JOIN Person ON "User_id".person_id = Person.person_id
			WHERE Support_request.employee_id = request_support_id 
				  AND Support_request.is_resolved = 'False';
		
    end if;
end;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION get_scooter_coords(request_scooter_id INTEGER) 
returns table(
	battery_charge INTEGER,
	is_parked BOOL,
	latitude FLOAT,
	longitude FLOAT) AS
$$
begin
    if (SELECT COUNT(*) FROM Scooter WHERE scooter_id = request_scooter_id) = 0 then
        RAISE NOTICE 'Scooter with this id does not exist';
		return;
	else
		return query SELECT Scooter.battery_charge, Scooter.is_parked, Scooter.latitude, Scooter.longitude
							FROM Scooter WHERE scooter_id = request_scooter_id;	
    end if;
end;
$$ language plpgsql;
