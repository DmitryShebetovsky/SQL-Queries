create database pills  
on   
(   name = pills_dat,  
    filename = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\pills.mdf',  
    size = 10,  
    maxsize = 50,  
    filegrowth = 5 )  
log on  
(   name = pills_log,  
    filename = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\pills.ldf',  
    size = 5mb,  
    maxsize = 25mb,  
    filegrowth = 5mb ) ; 
go

use pills

create table manufacturer
(
	id int not null identity(1,1) primary key,
	name nvarchar(100) not null unique
);

create table units
(
	id int not null identity(1,1) primary key,
	unitname nvarchar(100) not null unique
);

create table medicament_types
(
	id int not null identity(1,1) primary key,
	type nvarchar(100) not null unique
);

create table medicaments
(
	id int not null identity(1,1) primary key,
	name nvarchar(100) not null unique,
	manufacturerid int null foreign key references manufacturer(id)
		on delete no action
		on update cascade,
	typeid int null foreign key references medicament_types(id)
		on delete no action
		on update cascade,
	unitofpreparationid int null foreign key references units(id)
		on delete no action
		on update cascade
);

create table users
(
	id int not null identity(1,1) primary key,
	name nvarchar(100) not null,
	avatar nvarchar(100) null
);

create table medications
(
	id int not null identity(1,1) primary key,
	startdate date not null,
	count int not null,
	during int not null,
	notes nvarchar(200),
	medicamentid int not null foreign key references medicaments(id)
		on delete no action
		on update cascade,
	userid int not null foreign key references users(id)
		on delete no action
		on update cascade
);

create table medicament_receptions
(
	id int not null identity(1,1) primary key,
	isdone bit null,
	dateandtime datetime not null,
	medicationid int not null foreign key references medications(id)
		on delete no action
		on update cascade
);

create table medications_archive
(
	id int not null identity(1,1) primary key,
	startdate date not null,
	count int not null,
	during int not null,
	notes nvarchar(200),
	medicamentid int not null foreign key references medicaments(id)
		on delete no action
		on update cascade,
	userid int not null foreign key references users(id)
		on delete no action
		on update cascade
);

create table medicament_receptions_archive
(
	id int not null identity(1,1) primary key,
	isdone bit null,
	dateandtime datetime not null,
	medicationid int not null foreign key references medications_archive(id)
		on delete no action
		on update cascade
);
go

-- создание представления для medicaments
create view medicamentsinfo (id, name, type, unitsofpreparation, manufacturer)
as
select medicaments.id, medicaments.name, medicament_types.type, units.unitname, manufacturer.name
from medicaments join medicament_types on typeid = medicament_types.id
	 join manufacturer on manufacturerid = manufacturer.id
	 join units on unitofpreparationid = units.id
go

-- создание представления для medications
create view medications_info (id, startdate, count, during, notes, username, medicamentname, medicamenttype, unitsofpreparation, medicamentmanufacturer)
as
select medications.id, medications.startdate, medications.count, medications.during, medications.notes, users.name, 
		medicamentsinfo.name, medicamentsinfo.type, medicamentsinfo.unitsofpreparation, medicamentsinfo.manufacturer
from medications join users on medications.userid = users.id
	join medicamentsinfo on medications.medicamentid = medicamentsinfo.id
go

-- создание триггера для добавления medicament_reception в таблицу medicament_receptions_archive
create trigger medicament_receptions_archive
on medicament_receptions_archive
for insert
as
begin
	if exists (select * from medicament_receptions where 
			dateandtime = (select dateandtime from inserted)
		and medicationid = (select medicationid from inserted))
		begin 
			delete from medicament_receptions
			where dateandtime = (select dateandtime from inserted)
		and medicationid = (select medicationid from inserted)
		end;
end;
go

insert into medicaments
values ('парацетамол', null, null, null)

select *
from medicaments

insert into users
values ('кирилл', null)

select *
from users

insert into medications
values (getdate(), 10, 20, 'витамин с', 1, 1)

select *
from medications

delete from medications
where id = 2

select *
from medications_archive

insert into medications
values (getdate(), 11, 21, 'витамин', 1, 1)

delete from medications_archive
where id = 6 or id = 7
