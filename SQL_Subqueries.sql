USE Library

--1. Вывести информацию о книге по программированию с наибольшим количеством страниц. 

select *
from Books
where Books.Pages = 
(
select MAX(Pages)
from Books
where Books.Id_Themes = (
                  select id
				  from Themes
				  where Themes.Name = 'Программирование'
                 )
)

--2. Показать информацию о самой новой книге автора Грофф
declare @year int
set @year = (select MAX(Books.YearPress) from Books where Books.Id_Author = (select Authors.Id from Authors where Authors.LastName = 'Архангельский'))
select @year

select (select FirstName + ' ' + LastName from Authors where Authors.LastName = 'Архангельский') as 'Author', Books.*
from books
where Books.Id_Author = (select id from Authors where LastName = 'Архангельский') 
AND Books.YearPress = @year

--3. Показать информацию о самой новой книге каждого автора
select Authors.FirstName + ' ' + Authors.LastName as Author, Books.*
from Authors
join Books on Authors.Id = Books.Id_Author
where YearPress = (select MAX(YearPress) from Books where Books.Id_Author = Authors.Id)

--4. Показать название книги с максимальным кол-вом страниц по каждому из издательств.
select Press.Name, Books.*
from Books
join Press ON Books.Id_Press = Press.Id
where Books.Pages = (select MAX(Pages) from Books where Books.Id_Press = Press.Id)

--5. Показать студентов, которые посещали библиотеку больше двух раз
select Students.FirstName, Students.LastName
from Students
where Students.Id in 
(select S_Cards.Id_Student
 from S_Cards
 group by S_Cards.Id_Student
 having COUNT(S_Cards.Id_Student) >= 2)

--6. Показать все группы в которых студентов меньше 4

select Groups.Name, Groups.Id
from Groups
where Groups.Id in(
select Students.Id_Group 
from Students 
group by Students.Id_Group
having COUNT(Students.Id_Group) < 4)


--7. Показать все издательства, книг которых нет в библиотеке
select Press.*
from Press
where Press.Id not in(select Id_Press from Books)