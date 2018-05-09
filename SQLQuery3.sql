use library
go

--написать такие триггера:

--1. чтобы при взятии определенной книги, ее кол-во уменьшалось на 1.
create trigger s_cards_inserting
on s_cards
for insert
as
begin
	declare @id_book int;
	select @id_book = id_book from inserted;

	declare @quantity int;
	
	select @quantity = quantity
	from books
	where id = @id_book;
	
	if @quantity = 0
		rollback;
	else
		update books
		set quantity = quantity - 1
		where id = @id_book;
end;
go


create trigger t_cards_inserting
on t_cards
for insert
as
begin
	declare @id_book int;
	select @id_book = id_book from inserted;

	declare @quantity int;
	
	select @quantity = quantity
	from books
	where id = @id_book;
	
	if @quantity = 0
		rollback;
	else
		update books
		set quantity = quantity - 1
		where id = @id_book;
end;
go

--2. чтобы при возврате определенной книги, ее кол-во увеличивалось на 1.
create trigger s_cards_updating
on s_cards
for update
as
begin
	declare @id_book int, @date_in datetime;
	select @id_book = id_book, @date_in = datein from inserted;
	if @date_in != null
		begin
			declare @quantity int;
	
			select @quantity = quantity
			from books
			where id = @id_book;
			
			update books
			set quantity = quantity + 1
			where id = @id_book;
		end;
end;
go

create trigger t_cards_updating
on t_cards
for update
as
begin
	declare @id_book int, @date_in datetime;
	select @id_book = id_book, @date_in = datein from inserted;
	if @date_in != null
		begin
			declare @quantity int;
	
			select @quantity = quantity
			from books
			where id = @id_book;
			
			update books
			set quantity = quantity + 1
			where id = @id_book;
		end;
end;
go

--3. чтобы нельзя было выдать книгу, которой уже нет в библиотеке (по кол-ву).
create trigger s_cards_inserting
on s_cards
for insert
as
begin
	declare @id_book int;
	select @id_book = id_book from inserted;

	declare @quantity int;
	
	select @quantity = quantity
	from books
	where id = @id_book;
	
	if @quantity = 0
		rollback;
	else
		update books
		set quantity = quantity - 1
		where id = @id_book;
end;
go

create trigger t_cards_inserting
on t_cards
for insert
as
begin
	declare @id_book int;
	select @id_book = id_book from inserted;

	declare @quantity int;
	
	select @quantity = quantity
	from books
	where id = @id_book;
	
	if @quantity = 0
		rollback;
	else
		update books
		set quantity = quantity - 1
		where id = @id_book;
end;
go

--4. чтобы нельзя было выдать более трех книг одному студенту.
create trigger s_cards_inserting_student_count_control
on s_cards
for insert
as
begin
	declare @count_books_dateout int, @id_student int, @count_books_datein int
	select @id_student = id_student from inserted;
	select @count_books_dateout = count(*)
	from s_cards
	where id_student = @id_student
	select @count_books_datein = count(datein)
	from s_cards
	where id_student = @id_student
	
	if @count_books_dateout - @count_books_datein >= 3
		rollback;
end;
go

--5. чтобы при удалении книги, данные о ней копировались в таблицу удаленные.
create table booksdeleted
(
	id int primary key not null,
	name nvarchar(100) not null,
	pages int not null,
	yearpress int not null,
	id_themes int,
	id_category int,
	id_author int not null,
	id_press int not null,
	comment nvarchar(50),
	quantity int not null
)
go

create trigger bookdelete
on books
for delete
as
begin 
	insert into booksdeleted
	values (5,(select name from deleted),
			 (select pages from deleted),
			 (select yearpress from deleted),
			 (select id_themes from deleted),
			 (select id_category from deleted),
			 (select id_author from deleted),
			 (select id_press from deleted),
			 (select comment from deleted),
			 (select quantity from deleted));
end;

delete from books
where id = 5
go

--6. если книга добавляется в базу, она должна быть удалена из таблицы удаленные.
create trigger bookinsert
on books
for insert
as
begin 
	if exists (select * from booksdeleted where name = (select name from inserted) and pages = (select pages from inserted) 
	and id_author = (select id_author from inserted) and id_press = (select id_press from inserted))
		delete from booksdeleted
		where name = (select name from inserted)and pages = (select pages from inserted) 
		and id_author = (select id_author from inserted) and id_press = (select id_press from inserted)
end;
delete from books
where id = 5