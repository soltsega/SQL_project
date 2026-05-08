drop table if exists stud;
create table stud(
fname varchar(50) not null,
lname varchar(50) not null,
age int,
id varchar(10),
sex char(1) not null,
cgpa decimal(2,2) not null,
bdate date,
constraint pk_stud primary key(id),
--constraint no_name default fname = "no name",
qualification varchar(50),

);


