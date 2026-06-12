use dataCleaning;
SET SQL_SAFE_UPDATES = 0;

create table club_member_info_raw
like club_member_info;

insert club_member_info_raw
SELECT * FROM datacleaning.club_member_info;

SELECT * FROM datacleaning.club_member_info;

-- checking duplicates
with ranking as(
	select 
		*,
		row_number() over(partition by full_name, email, phone) as "row_num"
	from club_member_info
)
select * from ranking where `row_num` > 1 ;

create table club_member_info_no_duplicates
like club_member_info;

ALTER TABLE club_member_info_no_duplicates
ADD COLUMN row_num INT;

select * from club_member_info_no_duplicates;

-- inserting all rows but with no duplicates. There were 10 number of duplicates rows.
insert club_member_info_no_duplicates
with ranking as(
	select 
		*,
		row_number() over(partition by full_name, email, phone) as "row_num"
	from club_member_info
)
select * from ranking where `row_num` = 1 ;

-- for safety creating new table

create table club_member_info_no_duplicates_second
like club_member_info_no_duplicates;

insert club_member_info_no_duplicates_second
SELECT * FROM datacleaning.club_member_info_no_duplicates;

-- Remove white space from full_name.

select * from club_member_info_no_duplicates_second;

select * from club_member_info_no_duplicates where phone is null;


select *
from club_member_info_no_duplicates cm1
join club_member_info_no_duplicates cm2
on cm1.email = cm2.email;

update club_member_info_no_duplicates cm1
join club_member_info_no_duplicates cm2
on cm1.email = cm2.email
set cm1.full_name = trim(cm1.full_name);

-- removing invalid characters

select * , trim(LEADING '?' from full_name)
from club_member_info_no_duplicates
where full_name like "%?%";

update club_member_info_no_duplicates cm1
join club_member_info_no_duplicates cm2
on cm1.email = cm2.email
set cm1.full_name = trim(LEADING '?' from cm1.full_name);


-- making in proper string

update club_member_info_no_duplicates cm1
join club_member_info_no_duplicates cm2
on cm1.email = cm2.email
set cm1.full_name = concat(
	upper(left(cm1.full_name,1)), 
    lower(substring(cm1.full_name,2,locate(" ",cm1.full_name)-2))," ",
    left(upper(substring(cm1.full_name,locate(" ",cm1.full_name)+1,locate(" ",cm1.full_name)+1)),1),
    lower(substring(cm1.full_name,locate(" ",cm1.full_name)+2))
);

-- checking for outliers

ALTER TABLE club_member_info_no_duplicates
ADD COLUMN overall_mean INT, ADD COLUMN overall_stddev INT, ADD COLUMN z_score INT;

select * from club_member_info_no_duplicates;

with stats as(
select 
*,
round(avg(age) over(),2) as overall_mean1, 
round(stddev(age) over(),2) as overall_stddev1
from club_member_info_no_duplicates
)

select 
*, 
round(((age-overall_mean1)/overall_stddev1),2) as z_score1
from stats where abs(((age-overall_mean1)/overall_stddev1)) > 3.0;


with stats as(
select age,
round(avg(age) over(),2) as overall_mean, 
round(stddev(age) over(),2) as overall_stddev
from club_member_info_no_duplicates
)

update club_member_info_no_duplicates cm1
join stats
set cm1.overall_mean = stats.overall_mean,
cm1.overall_stddev = stats.overall_stddev,
cm1.z_score = round(((cm1.age-stats.overall_mean)/stats.overall_stddev),2);

update club_member_info_no_duplicates 
set age = NULL
where z_score >3;


select * from club_member_info_no_duplicates;


-- cleaning martial_status

select * 
from club_member_info_no_duplicates
where martial_status in ('divored');


update club_member_info_no_duplicates
set martial_status = 'divorced'
where martial_status = 'divored';


update club_member_info_no_duplicates
set martial_status = 'not available'
where martial_status is null;

select * 
from club_member_info_no_duplicates
where email is null or phone is null or full_address is null or job_title is null;


update club_member_info_no_duplicates
set phone = 'not available', 
email = 'not available',
full_address = 'not available',
job_title = 'not available'
where email is null or phone is null or full_address is null or job_title is null;


select * 
from club_member_info_no_duplicates;

update club_member_info_no_duplicates
set membership_date = str_to_date(membership_date,"%m/%d/%Y");

alter table club_member_info_no_duplicates
modify column membership_date date;

select * 
from club_member_info_no_duplicates;

-- data cleaned
