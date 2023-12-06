DROP DATABASE IF EXISTS airport;
CREATE DATABASE airport;
USE airport;
 
CREATE TABLE IF NOT EXISTS airlines(
airlines_id VARCHAR(127) NOT NULL,
airlines_name VARCHAR(255) NOT NULL,
CONSTRAINT `PK_airlines` PRIMARY KEY  (`airlines_id`));
 
CREATE TABLE  IF NOT EXISTS employees(
employee_id varchar(127) not null,
ssn varchar(127) not null,
employee_fname varchar(127) not null,
employee_lname varchar(127) not null,
airlines_id varchar(127) not null,
CONSTRAINT `PK_employees` PRIMARY KEY  (`employee_id`),
CONSTRAINT `FK_employees_airlines` foreign key(`airlines_id`) references  airlines(`airlines_id`) on update cascade on delete cascade);
 
 
CREATE TABLE  IF NOT EXISTS ground_staff(
employee_id varchar(127) not null,
employee_email varchar(127) unique not null,
employee_password  varchar(127) not null,
CONSTRAINT `PK_ground_staff` PRIMARY KEY  (`employee_id`, `employee_email`),
CONSTRAINT `FK_employees_ground_staff` foreign key(`employee_id`) references  employees(`employee_id`) on update cascade on delete cascade);
 
CREATE TABLE IF NOT EXISTS pilots(
employee_id varchar(127) not null,
ranking varchar(127) not null,
start_date date not null,
CONSTRAINT `PK_ground_staff` PRIMARY KEY  (`employee_id`,`ranking`),
CONSTRAINT `FK_employees_pilots` foreign key(`employee_id`) references  employees(`employee_id`) on update cascade on delete cascade);
 
CREATE TABLE IF NOT EXISTS model(
model_id varchar(127) not null,
model_name varchar(127) not null,
CONSTRAINT `PK_model` PRIMARY KEY  (`model_id`));
 
 
CREATE TABLE IF NOT EXISTS aircraft(
model_id varchar(127) not null,
airlines_id varchar(127) not null,
aircraft_id varchar(127) not null,
aircraft_name varchar(127) not null,
capacity int not null,
start_date date not null,
CONSTRAINT `PK_aircraft` PRIMARY KEY  (`aircraft_id`),
CONSTRAINT `FK_aircraft_airlines` foreign key(`airlines_id`) references  airlines(`airlines_id`) on update cascade on delete cascade,
CONSTRAINT `FK_aircraft_model` foreign key(`model_id`) references  model(`model_id`) on update cascade on delete cascade);
 
CREATE TABLE IF NOT EXISTS aircraft_pilot(
aircraft_id varchar(127) not null,
pilot_id varchar(127) not null,
CONSTRAINT `PK_aircraft_pilot` PRIMARY KEY  (`aircraft_id`,`pilot_id`),
CONSTRAINT `FK_pilot_aircraft` foreign key(`pilot_id`) references  pilots(`employee_id`) on update cascade on delete cascade,
CONSTRAINT `FK_aircraft_pilots_aircraft` foreign key(`aircraft_id`) references  aircraft(`aircraft_id`) on update cascade on delete cascade);
 
CREATE TABLE IF NOT EXISTS country(
country_id varchar(127) not null,
country_name varchar(127) not null,
CONSTRAINT `PK_country` PRIMARY KEY  (`country_id`));
 
CREATE TABLE IF NOT EXISTS city(
country_id varchar(127) not null,
city_id varchar(127) not null,
city_name varchar(127) not null,
CONSTRAINT `PK_city` PRIMARY KEY  (`city_id`),
CONSTRAINT `FK_city_country` foreign key(`country_id`) references  country(`country_id`) on update cascade on delete cascade);
 
CREATE TABLE IF NOT EXISTS routes(
route_id varchar(127) not null,
origin varchar(127) not null,
destination varchar(127) not null,
 
CONSTRAINT `PK_routes` PRIMARY KEY  (`route_id`),
CONSTRAINT `FK_routes_city1` foreign key(`origin`) references  city(`city_id`) on update cascade on delete cascade,
CONSTRAINT `FK_routes_city2` foreign key(`destination`) references  city(`city_id`) on update cascade on delete cascade);
-- CONSTRAINT `FK_routes_aircraft` foreign key(`aircraft_id`) references  aircraft(`aircraft_id`) on update cascade on delete cascade);
 
 
CREATE TABLE IF NOT EXISTS schedules(
schedule_id INT(10) not null AUTO_INCREMENT,
dept_time datetime not null,
arr_time datetime not null,
tickets_left int not null,
route_id varchar(127) not null,
aircraft_id varchar(127) not null,
fare int not null,
CONSTRAINT `PK_schedules` PRIMARY KEY  (`schedule_id`),
CONSTRAINT `FK_schedules_routes` foreign key(`route_id`) references  routes(`route_id`) on update cascade on delete cascade,
CONSTRAINT `FK_schedules_aircraft` foreign key(`aircraft_id`) references  aircraft(`aircraft_id`) on update cascade on delete cascade);
 
 
CREATE TABLE IF NOT EXISTS passengers(
passenger_id int(10) not null auto_increment,
passenger_name varchar(127) not null,
email varchar(127) unique not null,
passoword varchar(20) not null,
date_of_birth date not null,
city varchar(127) not null,
CONSTRAINT `PK_passengers` PRIMARY KEY  (`passenger_id`));
 
 
CREATE TABLE IF NOT EXISTS booking(
booking_id INT(10) not null AUTO_INCREMENT,
schedule_id int(10) not null,
passenger_id int(10) not null,
CONSTRAINT `PK_booking` PRIMARY KEY  (`booking_id`),
CONSTRAINT `FK_booking_schedules` foreign key(`schedule_id`) references  schedules(`schedule_id`) on update cascade on delete cascade,
CONSTRAINT `FK_booking_passengers` foreign key(`passenger_id`) references  passengers(`passenger_id`) on update cascade on delete cascade);
 
CREATE TABLE IF NOT EXISTS airlineAdmin(
admin_id INT AUTO_INCREMENT PRIMARY KEY,
user_name VARCHAR(50) UNIQUE NOT NULL,
password VARCHAR(50) NOT NULL
);
 
/*Procedures*/
 
DROP PROCEDURE IF EXISTS createNewUser;
DELIMITER //
 
CREATE PROCEDURE createNewUser(
  IN p_name VARCHAR(127),
  IN p_email VARCHAR(127),
  IN p_password VARCHAR(20),
  IN p_date_of_birth DATE,
  IN p_city VARCHAR(127)
)
BEGIN
 
  INSERT INTO passengers ( passenger_name, email, passoword, date_of_birth, city)
  VALUES ( p_name, p_email, p_password, p_date_of_birth, p_city);
END //
 
DELIMITER ;
 
 
DROP PROCEDURE IF EXISTS searchPassenger;
DELIMITER //
CREATE PROCEDURE searchPassenger(IN passenger_email VARCHAR(255))
BEGIN
    SELECT  p.*,b.booking_id,b.schedule_id
    FROM passengers p
    JOIN booking b ON p.passenger_id = b.passenger_id
    WHERE p.email = passenger_email;
END //
DELIMITER ;
 
DROP PROCEDURE IF EXISTS findAllUserBookings;
DELIMITER //
CREATE PROCEDURE findAllUserBookings(IN passenger_email VARCHAR(255))
BEGIN
    SELECT p.passenger_id, p.passenger_name, p.email, b.booking_id, s.schedule_id, s.dept_time, s.arr_time, r.origin,r.destination,s.fare
    FROM passengers p
    LEFT JOIN booking b ON p.passenger_id = b.passenger_id
    LEFT JOIN schedules s ON b.schedule_id = s.schedule_id
    LEFT JOIN routes r ON s.route_id = r.route_id
    WHERE p.email = passenger_email;
END//
DELIMITER ;
DROP PROCEDURE IF EXISTS findAllPassengers;
DELIMITER //
CREATE PROCEDURE findAllPassengers(IN schedule_id VARCHAR(127))
BEGIN
SELECT p.email,p.passenger_name,b.booking_id,b.schedule_id
    FROM passengers p
    INNER JOIN booking b ON p.passenger_id = b.passenger_id
    WHERE b.schedule_id = schedule_id;
END//
DELIMITER ;
DROP PROCEDURE IF EXISTS staffEntry;
DELIMITER //
 
CREATE PROCEDURE staffEntry(
    IN model_id VARCHAR(127),
    IN model_name VARCHAR(127),
    IN airlines_id VARCHAR(127),
    IN airlines_name VARCHAR(127),
    IN aircraft_id VARCHAR(127),
    IN aircraft_name VARCHAR(127),
    IN capacity INTEGER,
    IN start_date DATE,
    IN admin_id INTEGER
)
BEGIN
    -- Check if admin_id exists in the admin table
    IF NOT EXISTS (SELECT 1 FROM airlineAdmin WHERE admin_id = admin_id)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: admin_id does not exist in the admin table';
    END IF;
 
    -- Continue with the procedure if admin_id exists
    -- Insert into the model table
    INSERT INTO model (model_id, model_name)
    VALUES (model_id, model_name);
 
    -- Insert into the airlines table
    INSERT INTO airlines (airlines_id, airlines_name)
    VALUES (airlines_id, airlines_name);
 
    -- Insert into the aircraft table
    INSERT INTO aircraft (aircraft_id, airlines_id, model_id, aircraft_name, start_date, capacity)
    VALUES (aircraft_id, airlines_id, model_id, aircraft_name, start_date, capacity);
END//
 
DELIMITER ;
 
DROP PROCEDURE IF EXISTS deleteBookings;
DELIMITER //
CREATE PROCEDURE deleteBookings (IN sch_id VARCHAR(127))
BEGIN
    DELETE FROM schedules WHERE schedule_id = sch_id;

END//
DELIMITER ;
 
drop procedure if exists getAllSchedules;
DELIMITER //
create procedure getAllSchedules()
begin
select schedule_id from schedules;
END //
DELIMITER ;
 
drop procedure if exists getAllOriginCities;
DELIMITER //
create procedure getAllOriginCities()
begin
select distinct origin from routes;
END //
DELIMITER ;
call getAllOriginCities;
 
drop procedure if exists getAllFlightSchedulesForADate;
DELIMITER //
create procedure getAllFlightSchedulesForADate(IN input_date date)
begin
select s.schedule_id,s.route_id,r.origin,r.destination
from routes r join schedules s 
where r.route_id=s.route_id
and CAST(s.dept_time as DATE) = input_date;
END //
DELIMITER ;
call getAllFlightSchedulesForADate('2023-05-20');
 
drop procedure if exists findFlights;
DELIMITER //
create procedure findFlights(IN input_date date,
IN og varchar(127),
IN ds VARCHAR(127))
begin
SELECT s.schedule_id, CONCAT(YEAR(s.dept_time), '-', LPAD(MONTH(s.dept_time), 2, '0'), '-', LPAD(DAY(s.dept_time), 2, '0'), ' ', LPAD(HOUR(s.dept_time), 2, '0'), ':', LPAD(MINUTE(s.dept_time), 2, '0'), ':', LPAD(SECOND(s.dept_time), 2, '0')) AS Time_of_Departure, CONCAT(YEAR(s.arr_time), '-', LPAD(MONTH(s.arr_time), 2, '0'), '-', LPAD(DAY(s.arr_time), 2, '0'), ' ', LPAD(HOUR(s.arr_time), 2, '0'), ':', LPAD(MINUTE(s.arr_time), 2, '0'), ':', LPAD(SECOND(s.arr_time), 2, '0')) AS Time_of_Arrival, s.route_id, r.origin,r.destination,s.fare, s.tickets_left FROM schedules s join routes r on s.route_id = r.route_id WHERE DATE(s.dept_time) = input_date AND r.origin = og AND r.destination = ds;
END //
DELIMITER ;
call getAllFlightSchedulesForADate('2023-05-01');
call findAllUserBookings('johnsmith@example.com');
 
 
drop procedure if exists getAllBookingId;
DELIMITER //
create procedure getAllBookingId(IN input_email varchar(127))
begin
SELECT b.booking_id from booking b join passengers p on p.passenger_id = b.passenger_id
where p.email = input_email;
END //
DELIMITER ;
 
drop procedure if exists getDetails;
DELIMITER //
create procedure getDetails(IN booking_id_old VARCHAR(127))
begin
SELECT r.origin,r.destination,DATE(s.dept_time) FROM routes r join schedules s on s.route_id = r.route_id join booking b on b.schedule_id = s.schedule_id where b.booking_id=booking_id_old;
END //
DELIMITER ;
 
drop procedure if exists getAllEmails;
DELIMITER //
create procedure getAllEmails()
begin
SELECT email from passengers;
END //
DELIMITER ;
 
 
drop procedure if exists getAllRoutes;
DELIMITER //
CREATE PROCEDURE getAllRoutes()
begin
select r.route_id,r.origin,r.destination from routes r;
END //
DELIMITER ;
 
drop procedure if exists createSchedule;
DELIMITER //
CREATE PROCEDURE createSchedule(in dept_new_time datetime, in arrival_new_time datetime, in tickets_left int, in route_id_new varchar(127),in air_craft_id varchar(127), in fare_new int)
begin
INSERT INTO schedules ( dept_time, arr_time, tickets_left, route_id,aircraft_id,fare)
  VALUES ( dept_new_time, arrival_new_time, tickets_left, route_id_new, air_craft_id,fare_new);
END //
DELIMITER ;
 
 
drop procedure if exists getAllAircrafts;
DELIMITER //
CREATE PROCEDURE getAllAircrafts()
begin
SELECT aircraft_id from aircraft;
END //
DELIMITER ;
 
 
drop procedure if exists updateSchedule;
DELIMITER //
create procedure updateSchedule(in s_id int,
in new_dept_time datetime,
in new_arr_time datetime)
begin
update schedules set dept_time = new_dept_time, arr_time = new_arr_time 
where schedule_id = s_id;
 
END //
DELIMITER ;
 
 
drop procedure if exists getAllScheduleDetails;
DELIMITER //
create procedure getAllScheduleDetails(in s_id int)
begin
select s.schedule_id,s.dept_time,s.arr_time,s.tickets_left,s.fare,r.route_id,r.origin,r.destination,a.model_id, m.model_name,a.aircraft_id,a.aircraft_name,a.capacity,a.start_date,ai.airlines_id,ai.airlines_name
 
from schedules s join routes r on r.route_id = s.route_id
join aircraft a on a.aircraft_id = s.aircraft_id 
join airlines ai on ai.airlines_id = a.airlines_id
join model m on m.model_id = a.model_id
where s.schedule_id = s_id;
 
END //
DELIMITER ;
 
 
/*Functions*/
 
 
DROP FUNCTION IF EXISTS updateUserPassword;
DELIMITER //
CREATE FUNCTION updateUserPassword(old_email VARCHAR(127),passowordnew VARCHAR(20))
RETURNS INT
DETERMINISTIC MODIFIES SQL DATA
BEGIN
UPDATE passengers SET passoword = passowordnew WHERE email = old_email;
RETURN NULL;
END //
DELIMITER ;
 
DROP FUNCTION IF EXISTS updateUserEmail;
DELIMITER //
CREATE FUNCTION updateUserEmail(old_email VARCHAR(127),newEmail VARCHAR(20))
RETURNS INT
DETERMINISTIC MODIFIES SQL DATA
BEGIN
UPDATE passengers SET email = newEmail WHERE email = old_email;
RETURN NULL;
END //
DELIMITER ;
 
DROP FUNCTION IF EXISTS updateUserName;
DELIMITER //
CREATE FUNCTION updateUserName(old_email VARCHAR(127),newName VARCHAR(20))
RETURNS INT
DETERMINISTIC MODIFIES SQL DATA
BEGIN
UPDATE passengers SET passenger_name = newName WHERE email = old_email;
RETURN NULL;
END //
DELIMITER ;
 
DROP FUNCTION IF EXISTS updateUserCity;
DELIMITER //
CREATE FUNCTION updateUserCity(old_email VARCHAR(127),newCity VARCHAR(20))
RETURNS INT
DETERMINISTIC MODIFIES SQL DATA
BEGIN
UPDATE passengers SET city = newCity WHERE email = old_email;
RETURN NULL;
END //
DELIMITER ;
 
DROP FUNCTION IF EXISTS bookTicket;
DELIMITER //
CREATE FUNCTION bookTicket(schedule_id VARCHAR(127),user_email VARCHAR(127))
RETURNS INT
DETERMINISTIC MODIFIES SQL DATA
BEGIN
DECLARE temp VARCHAR(127);
DECLARE pass_id VARCHAR(127);
 
SELECT passenger_id into pass_id from passengers where email=user_email;
INSERT INTO booking (schedule_id, passenger_id) values (schedule_id, pass_id);
SET temp = LAST_INSERT_ID();
RETURN temp;
END //
DELIMITER ;
 
DROP FUNCTION IF EXISTS updateTicket;
DELIMITER //
CREATE FUNCTION updateTicket(new_schedule_id VARCHAR(127),user_email VARCHAR(127),old_booking_id VARCHAR(127))
RETURNS INT
DETERMINISTIC MODIFIES SQL DATA
BEGIN
DECLARE pass_id VARCHAR(127);
SELECT passenger_id into pass_id from passengers where email=user_email;
UPDATE  booking set schedule_id = new_schedule_id where passenger_id = pass_id and booking_id = old_booking_id;
RETURN NULL;
END //
DELIMITER ;
 
 
DROP FUNCTION IF EXISTS deleteTicket;
DELIMITER //
CREATE FUNCTION deleteTicket(delete_booking_id VARCHAR(127),user_email VARCHAR(127))
RETURNS INT
DETERMINISTIC MODIFIES SQL DATA
BEGIN
DECLARE pass_id VARCHAR(127);
SELECT passenger_id into pass_id from passengers where email=user_email;
DELETE FROM booking WHERE booking_id =  delete_booking_id and passenger_id = pass_id;
RETURN NULL;
END //
DELIMITER ;
 
/*Triggers*/
DROP TRIGGER IF EXISTS duplicateBooking;
DELIMITER //
CREATE TRIGGER duplicateBooking
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM booking
        WHERE passenger_id = NEW.passenger_id
        AND schedule_id = NEW.schedule_id
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot book the same ticket more than once';
    END IF;
END //
DELIMITER ;
 
DROP TRIGGER IF EXISTS duplicateUser;
DELIMITER //
CREATE TRIGGER duplicateUser
BEFORE INSERT ON passengers
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM passengers WHERE email = NEW.email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User with this email already exists';
    END IF;
END //
DELIMITER ;
 
DROP TRIGGER IF EXISTS checkSeatsLeft;
DELIMITER //
CREATE TRIGGER checkSeatsLeft
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE remaining_seats INT;
    SELECT tickets_left INTO remaining_seats FROM schedules WHERE schedule_id = NEW.schedule_id;
    IF remaining_seats <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No seats left on this schedule';
    ELSE
        UPDATE schedules SET tickets_left = tickets_left - 1 WHERE schedule_id = NEW.schedule_id;
    END IF;
END //
DELIMITER ;
 
DROP TRIGGER IF EXISTS updateSeatsOnDelete;
DELIMITER //
CREATE TRIGGER updateSeatsOnDelete
BEFORE DELETE ON booking
FOR EACH ROW
BEGIN
    UPDATE schedules SET tickets_left = tickets_left + 1 WHERE schedule_id = OLD.schedule_id;
END //
DELIMITER ;
 
DROP TRIGGER IF EXISTS updateSeatsOnUpdate;
DELIMITER //
CREATE TRIGGER updateSeatsOnUpdate
BEFORE UPDATE ON booking
FOR EACH ROW
BEGIN
    UPDATE schedules
    SET tickets_left = tickets_left - 1
    WHERE schedule_id =  NEW.schedule_id;
    UPDATE schedules
    SET tickets_left = tickets_left + 1
    WHERE schedule_id = OLD.schedule_id;
END //
DELIMITER ;
 
DROP TRIGGER IF EXISTS scheduleExists;
DELIMITER //
CREATE TRIGGER scheduleExists
BEFORE INSERT ON schedules
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT * FROM schedules
        WHERE route_id = NEW.route_id
        AND dept_time = NEW.dept_time
        AND arr_time = NEW.arr_time
    )
    THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Same schedule already exists';
    END IF;
END //
DELIMITER ;
 
DROP TRIGGER IF EXISTS beforeUpdateBooking;
DELIMITER //
CREATE TRIGGER beforeUpdateBooking
BEFORE UPDATE ON booking
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM booking
        WHERE passenger_id = NEW.passenger_id
        AND schedule_id = NEW.schedule_id
        and booking_id = new.booking_id
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot book the same schedule for the same passenger more than once';
    END IF;
END //
DELIMITER ;
 
DROP TRIGGER IF EXISTS beforeInsertBookingNew;
DELIMITER //
CREATE TRIGGER beforeInsertBookingNew
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT * FROM schedules WHERE schedule_id = NEW.schedule_id) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid schedule ID';
    END IF;
END;
 
DROP TRIGGER IF EXISTS beforeUpdateForScheduleNotExistsBooking;
DELIMITER //
CREATE TRIGGER beforeUpdateForScheduleNotExistsBooking
BEFORE UPDATE ON booking
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT * FROM schedules WHERE schedule_id = NEW.schedule_id) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid schedule ID';
    END IF;
END;
 
 
/*DATA*/
 
INSERT INTO airlines (airlines_id, airlines_name)
VALUES ('AA', 'American Airlines'),
       ('DL', 'Delta Air Lines'),
       ('UA', 'United Airlines'),
       ('EK', 'Emirates'),
       ('AC','Air Canada');
INSERT INTO employees (employee_id, ssn, employee_fname, employee_lname, airlines_id)
VALUES ('1', '111-22-3333', 'Sanjana', 'Kandunoori', 'AA'),
       ('2', '222-33-4444', 'Ram', 'Mogulla', 'AA'),
       ('3', '333-44-5555', 'Sushmitha', 'Kurum', 'DL'),
	   ('4', '444-55-6666', 'Rajesh', 'Adi', 'DL'),
       ('5', '555-66-7777', 'Arjun', 'Rampal', 'UA'),
       ('6', '666-77-8888', 'Priyanka', 'Rajesh', 'UA');
INSERT INTO ground_staff (employee_id,employee_email,employee_password)
VALUES ('1','sanjana@gmail.com','1234'),
       ('2','rajesh@gmail.com','1234'),
       ('3','sushmitha@gmail.com','1234');       
INSERT INTO pilots (employee_id, ranking, start_date)
VALUES ('4', 'Captain', '2020-01-01'),
       ('5', 'First Officer', '2021-03-15'),
       ('6', 'Captain', '2018-05-10');
 
INSERT INTO model (model_id, model_name)
VALUES ('1', 'Boeing 737'),
       ('2', 'Airbus A320'),
       ('3', 'Boeing 787'),
       ('4', 'Airbus A380'),
       ('5', 'Embraer E190');

INSERT INTO aircraft (model_id, airlines_id, aircraft_id, aircraft_name, capacity, start_date)
VALUES        ('1', 'EK', 'EK4001', 'Airbus A380-800', 615, '2010-04-17'),
       ('2', 'AC', 'AC5001', 'Embraer E190', 97, '2021-03-01'),
		('3', 'AA', 'AA1001', 'Boeing 737-800', 160, '2021-09-01'),
       ('4', 'UA', 'UA2001', 'Airbus A320', 180, '2022-08-10'),
       ('5', 'DL', 'DL3001', 'Boeing 787-9', 290, '2020-09-19');

INSERT INTO aircraft_pilot (aircraft_id, pilot_id)
VALUES ('AA1001', '4'),
       ('UA2001', '5'),
       ('DL3001', '6');
INSERT INTO country (country_id, country_name)
VALUES
('USA', 'United States of America'),
('CAN', 'Canada'),
('IND', 'India'),
('CHN', 'China');
 
INSERT INTO city (country_id, city_id, city_name)
VALUES
('USA', 'NYC', 'New York City'),
('USA', 'LA', 'Los Angeles'),
('CAN', 'TOR', 'Toronto'),
('CAN', 'MTL', 'Montreal'),
('IND', 'BLR', 'Bengaluru'),
('IND', 'HYD', 'Hyderabad'),
('IND', 'DEL', 'Delhi'),
('CHN', 'BEI', 'Beijing'),
('IND', 'CHE', 'Chennai');
 
	
 
INSERT INTO routes (route_id,  origin, destination)
VALUES
('R01',  'NYC', 'TOR'),
('R02', 'LA', 'DEL'),
('R03', 'TOR', 'MTL'),
('R04', 'HYD', 'BLR'),
('R05', 'BLR', 'BEI'),
('R06',  'CHE', 'BLR'),
('R07', 'LA', 'TOR'),
('R08', 'BLR', 'DEL'),
('R09', 'DEL', 'NYC'),
('R10', 'NYC', 'BEI');
 
INSERT INTO schedules ( dept_time, arr_time, tickets_left, route_id,aircraft_id,fare)
VALUES 
( '2023-05-01 10:00:00', '2023-05-01 12:00:00', 2, 'R01','AA1001',200),
('2023-05-01 14:00:00', '2023-05-01 16:00:00', 150, 'R01', 'UA2001',180),
('2023-05-02 08:00:00', '2023-05-02 10:00:00', 50, 'R02', 'DL3001',190),
('2023-05-02 12:00:00', '2023-05-02 14:00:00', 120, 'R02', 'EK4001',101),
('2023-05-03 09:00:00', '2023-05-03 11:00:00', 80, 'R03','AC5001',100),
('2023-05-03 13:00:00', '2023-05-03 15:00:00', 90, 'R03','AC5001',100),
( '2023-05-04 11:00:00', '2023-05-04 13:00:00', 110, 'R04','DL3001',190),
('2023-05-04 15:00:00', '2023-05-04 17:00:00', 70, 'R04','DL3001',190),
('2023-05-05 08:00:00', '2023-05-05 12:00:00', 200, 'R05','AC5001',100),
('2023-05-06 10:00:00', '2023-05-06 14:00:00', 120, 'R06','AA1001',20),
( '2023-05-07 12:00:00', '2023-05-07 16:00:00', 80, 'R07','EK4001',101),
( '2023-05-08 14:00:00', '2023-05-08 16:00:00', 50, 'R08', 'DL3001',190),
('2023-05-09 09:00:00', '2023-05-09 11:00:00', 70, 'R09','AA1001',20),
( '2023-05-10 11:00:00', '2023-05-10 13:00:00', 90, 'R10','DL3001',190),
( '2023-05-11 14:00:00', '2023-05-11 16:00:00', 100, 'R01','AC5001',100),
( '2023-05-12 08:00:00', '2023-05-12 10:00:00', 80, 'R02','EK4001',101),
( '2023-05-13 12:00:00', '2023-05-13 14:00:00', 60, 'R03','EK4001',101),
( '2023-05-14 09:00:00', '2023-05-14 11:00:00', 150, 'R04','AA1001',200),
( '2023-06-01 09:00:00', '2023-06-01 11:00:00', 1, 'R10','AA1001',180),
( '2023-06-01 11:00:00', '2023-06-01 13:00:00', 2, 'R10','EK4001',800);
INSERT INTO passengers ( passenger_name, email, passoword, date_of_birth, city)
VALUES
( 'Rensuree Chava', 'renusreechava@gmail.com', 'pass1', '1999-10-11', 'Bengaluru'),
( 'Chetan Chauhan', 'chetanc@gmail.com', 'pass1', '1996-02-23', 'Delhi');
 
 
INSERT INTO booking (schedule_id, passenger_id)
VALUES 
(1, 1),
(2, 2);
 
INSERT INTO airlineAdmin(user_name, password) VALUES ('admin', 'admin');