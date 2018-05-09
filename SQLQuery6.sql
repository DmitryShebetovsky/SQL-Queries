select Groups.Name, COUNT(S_Cards.Id_Student)
from S_Cards
join Students ON Students.Id = S_Cards.Id_Student
join Groups ON Groups.Id = Students.Id_Group
GROUP BY Groups.Name

—Вывести количество книг, взятых в библиотеке программистами по тематикам "Программирование" и "Базы данных", 
—и сумму страниц в этих книгах. 
select Themes.Name as 'Themes', count(Books.Id) as 'count', sum(books.Pages)
from Faculties
join Groups ON Groups.Id_Faculty = Faculties.Id
join Students ON  Students.Id_Group = Groups.Id
join S_Cards ON S_Cards.Id_Student = Students.Id
join Books ON Books.Id = S_Cards.Id_Book
join Themes ON Themes.Id = Books.Id_Themes
where Faculties.Name = 'Программирования' AND Themes.Name in('Программирование', 'Базы данных')
GROUP BY Themes.Name

—Если считать общее количество книг в библиотеке за 100%, то необходимо подсчитать сколько книг (в процентном отношении) 
—брал каждый факультет 
DECLARE @count int
SET @count = (SELECT SUM(Books.Quantity) FROM Books)
select Faculties.Name, COUNT(S_Cards.Id_Student) as 'book count', ((COUNT(S_Cards.Id_Student) * 100) / @count ) as 'book count %'
from Faculties
join Groups ON Groups.Id_Faculty = Faculties.Id
join Students ON Students.Id_Group = Groups.Id
join S_Cards ON S_Cards.Id_Student = Students.Id
GROUP BY Faculties.Name

—Допустим, что студент имеет право держать книгу у себя дома только 1 месяц, а за каждую неделю сверх того он 
—обязан "выставить" уважаемому библиотекарю Максу (Сергею Максименко) полбутылки (емкость бутылки 0.5 л) светлого пива.
—Необходимо вывести сколько литров должен каждый студент, а также суммарное количество литров пива. 
—Итоговая сумма должна округляться в большую сторону, то есть суммарное число литров должно быть целым.
declare @litersTotal int
set @litersTotal = (select ROUND(SUM(datediff(ww, dateadd(month, 1, S_Cards.DateOut), getdate()) * 0.25), -1)
from S_Cards 
where S_Cards.DateIn is NULL)

select SUM(datediff(ww, dateadd(month, 1, S_Cards.DateOut), getdate()) * 0.25) as 'lit', Students.FirstName + ' ' + Students.LastName as student, @litersTotal as 'liters Total'
from S_Cards 
join students ON S_Cards.Id_Student = Students.Id
where S_Cards.DateIn is NULL
group by Students.FirstName, Students.LastName

—"Заставить" сдать книги тех студентов, которые не сдавали книги более года, то есть
—в таблице "Карточка студентов" (S_cards) заполнить поле дата возврата текущей датой (Date())
—select Students.FirstName, Students.LastName, S_Cards.DateOut, S_Cards.DateIn
—from S_Cards
—join Students ON Students.Id = S_Cards.Id_Student
Update S_Cards
set DateIn = GETDATE()
where GETDATE() > dateadd(YEAR, 1, S_Cards.DateOut)

—Удалить из таблицы "Карточка студентов" студентов, которые уже вернули книги.
delete 
from S_Cards
where S_Cards.DateIn is not null
