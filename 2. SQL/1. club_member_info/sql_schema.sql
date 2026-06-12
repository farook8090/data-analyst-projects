-- Create table to import SQL data into and use for data cleaning.

-- GitHub Link : https://github.com/iweld/data_cleaning

create database dataCleaning;
use dataCleaning;
DROP TABLE IF EXISTS club_member_info;
CREATE TABLE club_member_info (
	member_id serial,
	full_name varchar(100),
	age int,
	maritial_status varchar(50),
	email varchar(150),
	phone varchar(20),
	full_address varchar(150),
	job_title varchar(100),
	membership_date date,
	PRIMARY KEY (member_id)
);

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;