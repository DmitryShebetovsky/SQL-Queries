use Library
go

select *
from Students

select *
from Teachers

select *
from Books

insert into Books
values('Гарри Поттер: философский камень', 323, 2003, 1, 1, 1, 1, N'текст', 1)

delete from BOOKS
where Name like '%Гарри Поттер%'

update Books
set Name = 'Гарри Поттер: философский камень'
where Name like '%Гарри Поттер%'

update S_Cards
set DateIn = getdate()
where Id_Book = 1 and Id_Student = 2 

delete from S_Cards
where Id_Book = 1 and Id_Student = 2 