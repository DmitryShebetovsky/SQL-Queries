use Library_new

go

--1.	Функцию, возвращающую кол-во студентов, которые не брали книги

alter function SCountWithOutBooks() 
returns int
as
begin
	declare @Rezult int
	select @Rezult=Count(id) from Students
	where id != all(select Id_Student from S_Cards)
	return @Rezult
end
GO
Print  dbo.SCountWithOutBooks()

--2.	Функцию, возвращающую минимальное из трех переданных параметров. 
--declare @a int, @b int, @c int
alter function TreeMin(@a int, @b int, @c int) 
returns int
as
begin	
	if((@a<=@b) and (@a<=@c)) return @a
	if((@b<=@a) and (@b<=@c)) return @b	
	return @c
end
Go

Print dbo.TreeMin(9,3,5) 

--3.	Функцию, которая принимает в качестве параметра двухразрядное число и определяет какой из разрядов больше, либо они равны. (используйте % - деление по модулю. Например: 57%10=7) 

alter function Razriad(@a int)
returns nvarchar(50)
as
begin
	declare @min int
	declare @first int
	set @first = (@a %10)
	declare @second int
	set @second = @a / 10
	declare @max int
	if(@second > @first) return 'Первый разряд больше второго'
	if(@first > @second) return 'Второй разряд больше первого'
	return 'разряды равны'
end
go

select dbo.Razriad(66)

--4.	Функцию, возвращающую кол-во взятых книг по каждой из групп и по каждой из кафедр (departments). 

create function CountBooksGroupDepartment()
returns @res table(CountBooks int, GroupOrDepartment nvarchar(50))
as
begin 	
	insert @res
		select COUNT(*) as CountBooks, Groups.Name
		from S_Cards join Students on Id_Student = Students.Id
		join Groups on Students.Id_Group = Groups.Id
		group by Groups.Name
		union all
		select COUNT(*) as CountBooks, Departments.Name
		from T_Cards JOIN Teachers on Id_Teacher = Teachers.Id
		JOIN Departments on Departments.Id = Teachers.Id_Dep
		group by Departments.Name
	return;
end;
go

select *
from dbo.CountBooksGroupDepartment()
go

--5. Функцию, возвращающую список книг, отвечающих набору критериев (например, имя автора, фамилия автора, тематика, категория), и отсортированный по номеру поля, указанному в 5-м параметре, в направлении, указанном в 6-м параметре. 
create function BookList(@authorFirstName nvarchar(50), @authorLastName nvarchar(50), @theme nvarchar(50), @category nvarchar(50), @numberOfSortColumn int, @direction int)
returns @res table(Id int, Name nvarchar(100), Pages int, YearPress int, Id_Themes int, Id_Category int, Id_Author int, Id_Press int, Comment nvarchar(50), Quantity int)
as
begin 
	if @direction = 0
		begin
			insert @res
				select Id, Name, Pages, YearPress, Id_Themes, Id_Category, Id_Author, Id_Press, Comment, Quantity
				from Books
				where Id_Author = (select Id from Authors where FirstName = @authorFirstName and LastName = @authorLastName)
				and Id_Themes = (select Id from Themes where Name = @theme) 
				and Id_Category = (select Id from Categories where Name = @category)
				order by case @numberOfSortColumn
							when 1 then Name
							when 2 then Pages
							when 3 then YearPress
							when 4 then Id_Themes
							when 5 then Id_Category
							when 6 then Id_Author
							when 7 then Id_Press
							when 8 then Comment
							when 9 then Quantity
							end
							asc
		end;
	else
		begin
			insert @res
				select Id, Name, Pages, YearPress, Id_Themes, Id_Category, Id_Author, Id_Press, Comment, Quantity
				from Books
				where Id_Author = (select Id from Authors where FirstName = @authorFirstName and LastName = @authorLastName)
				and Id_Themes = (select Id from Themes where Name = @theme) 
				and Id_Category = (select Id from Categories where Name = @category)
				order by case @numberOfSortColumn
							when 1 then Name
							when 2 then Pages
							when 3 then YearPress
							when 4 then Id_Themes
							when 5 then Id_Category
							when 6 then Id_Author
							when 7 then Id_Press
							when 8 then Comment
							when 9 then Quantity
							end
							asc
		end;
return;
end;
go

select *
from dbo.BookList('Алексей', 'Архангельский', 'Программирование', 'C++ Builder', 2, 1)
go


-- 6.	Функцию, которая возвращает список библиотекарей и кол-во выданных каждым из них книг.

create function LibrarianList()
returns @res table (CountOfBooks int, FirstName nvarchar(50), LastName nvarchar(50), Id int)
as
begin
	with buf (CountOfBooks, FirstName, LastName, Id)
	as
	(	select COUNT(*), Libs.FirstName, Libs.LastName, Libs.Id
		from S_Cards JOIN Libs on Id_Lib = Libs.Id
		group by Libs.FirstName, Libs.LastName, Libs.Id
		union ALL
		select COUNT(*), Libs.FirstName, Libs.LastName, Libs.Id
		from T_Cards JOIN Libs on Id_Lib = Libs.Id
		group by Libs.FirstName, Libs.LastName, Libs.Id	)
	insert @res
		select SUM(CountOfBooks), FirstName, LastName, Id
		from buf
		group by FirstName, LastName, Id
	return;
end;
go

select *
from dbo.LibrarianList()

