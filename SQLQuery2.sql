use Library_new

go
--Показать издательства и сумму страниц по каждому из них.
select Press.Name, sum(Books.Pages) as pages 
from Press
left join Books on Press.Id = Books.Id_Press
group by Press.name
having sum(Books.Pages) is not null

--Показать общее кол-во книг, взятых студентами факультета Программирования.
select count(*) [кол-во книг] from S_Cards
where Id_Student = any (select Students.Id from Groups left join Students on Students.Id_Group = Groups.Id where Groups.Id_Faculty=1)

--Вывести кол-во книг и сумму страниц этих книг по каждому из издательств
--Питер, Наука; и Кудиц-Образ.
select Press.Name, count(Press.Id) [кол-во книг], sum(Books.Pages) [сумма страниц]
from Press
left join Books on Books.Id_Press =press.id
where Press.name in('Питер','Наука','Кудиц-Образ')
group by Press.Name

--Вывести на экран кол-во взятых книг по каждой из кафедр.
select Faculties.Name, count(id_book) [кол-во взятых]
From S_Cards
left join Students on Students.id = S_Cards.Id_Student
left join Groups on Groups.Id = Students.Id_Group
left join Faculties on Faculties.Id = Groups.Id_Faculty
Group by Faculties.Name

--Показать издательства и самую старую книгу для каждого из них.
Select Press.Name as PressName, Books.Name as BooksName, Query.Year
from(
	select Books.Id_Press, min(YearPress) as [Year]
	from Books
	Group By Books.Id_Press
	) as Query
Left join Press on Press.Id = Query.Id_Press
Left join Books on Books.YearPress = Query.Year and Books.Id_Press=Query.Id_Press

--Вывести статистику посещений библиотеки по каждой группе студентов.
select Groups.Name, count(S_Cards.Id_Student)
from S_Cards
join Students on Students.Id = S_Cards.Id_Student
join Groups on Groups.Id = Students.Id_Group
GROUP BY Groups.Name

--Вывести количество книг, взятых в библиотеке программистами по тематикам
--&quot;Программирование&quot; и &quot;Базы данных&quot;, и сумму страниц в этих книгах
select Themes.Name as 'Тематика', count(Books.Id) as 'количество', sum(books.Pages) as 'сумма страниц'
from Faculties
join Groups on Groups.Id_Faculty = Faculties.Id
join Students on  Students.Id_Group = Groups.Id
join S_Cards on S_Cards.Id_Student = Students.Id
join Books on Books.Id = S_Cards.Id_Book
join Themes on Themes.Id = Books.Id_Themes
where Faculties.Name = 'Программирования' and Themes.Name in('Программирование', 'Базы данных')
group by Themes.Name

--Если считать общее количество книг в библиотеке за 100%, то необходимо
--подсчитать сколько книг (в процентном отношении) брал каждый факультет
--select sum(Books.Quantity) from Books
select Faculties.Name, count(S_Cards.Id_Student) as 'book count', ((count(S_Cards.Id_Student) * 100) / 33 ) as '%'
from Faculties
join Groups on Groups.Id_Faculty = Faculties.Id
join Students on Students.Id_Group = Groups.Id
join S_Cards on S_Cards.Id_Student = Students.Id
group by Faculties.Name

--Допустим, что студент имеет право держать книгу у себя дома только 1 месяц, а за
--каждую неделю сверх того он обязан &quot;выставить&quot; уважаемому библиотекарю
--Максу (Сергею Максименко) полбутылки (емкость бутылки 0.5 л) светлого пива.
--Необходимо вывести сколько литров должен каждый студент, а также суммарное
--количество литров пива. Итоговая сумма должна округляться в большую сторону,
--то есть суммарное число литров должно быть целым.
select sum(datediff(ww, dateadd(month, 1, S_Cards.DateOut), getdate()) * 0.25) as 'литры', Students.FirstName + ' ' + Students.LastName as 'студент'
from S_Cards 
join students on S_Cards.Id_Student = Students.Id
where S_Cards.DateIn is null
group by Students.FirstName, Students.LastName

select round(sum(datediff(ww, dateadd(month, 1, S_Cards.DateOut), getdate()) * 0.25), -1) as 'сумма литров'
from S_Cards 
where S_Cards.DateIn is null

--&quot;Заставить&quot; сдать книги тех студентов, которые не сдавали книги более года, то
--есть в таблице &quot;Карточка студентов&quot; (S_cards) заполнить поле дата возврата
--текущей датой (Date())
select Students.FirstName, Students.LastName, S_Cards.DateOut, S_Cards.DateIn
from S_Cards
join Students on Students.Id = S_Cards.Id_Student
Update S_Cards
set DateIn = GETDATE()
where GETDATE() > dateadd(YEAR, 1, S_Cards.DateOut)

--Удалить из таблицы 'Карточка студентов' студентов, которые уже вернули книги.
delete 
from S_Cards
where S_Cards.DateIn is not null
