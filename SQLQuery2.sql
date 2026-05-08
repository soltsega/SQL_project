drop table if exists stud;
create table stud(
fname varchar(50) not null,
lname varchar(50) not null,
id varchar(10) primary key,
sex char(1) not null,
cgpa decimal(2,2) not null,
age int,
bdate date,
-- constraint pk_stud primary key(id),
--constraint no_name default fname = "no name",
qualification varchar(50),

);





drop table if exists inst;
create table inst(
fname varchar(50) not null,
lname varchar(50) not null,
age int,
inst_id varchar(10) primary key,
sex char(1) not null,
cgpa decimal(2,2) not null,
bdate date,
salary decimal(10,2),
stud_id varchar(30) not null,
--constraint pk_inst primary key(inst_id),
--constraint no_name default fname = "no name",
qualification varchar(50),
constraint fk_stud_inst foreign key (inst_id) references stud(id),
);




drop table if exists course;
create table course(
inst_id varchar(10),
cgpa decimal(2,2) not null,
course_code varchar(30) primary key,
bdate date,
coursename varchar(100),
stud_id varchar(30) not null,
--constraint pk_course primary key(course_code),
--constraint fk_stud_course foreign key (stud_id) references stud(id),
constraint fk_inst_course foreign key (inst_id) references inst(inst_id),

);


-- insert into the table
insert into stud values
('Abebe', 'Girma', 'id', 'm', '3.85', '21', '2003-12-12')


/*



*/


-- query the table records
select * from stud;
select * from inst;
select * from course;

