use Library_new

go
--�������� ������������ � ����� ������� �� ������� �� ���.
select Press.Name, sum(Books.Pages) as pages 
from Press
left join Books on Press.Id = Books.Id_Press
group by Press.name
having sum(Books.Pages) is not null

--�������� ����� ���-�� ����, ������ ���������� ���������� ����������������.
select count(*) [���-�� ����] from S_Cards
where Id_Student = any (select Students.Id from Groups left join Students on Students.Id_Group = Groups.Id where Groups.Id_Faculty=1)

--������� ���-�� ���� � ����� ������� ���� ���� �� ������� �� �����������
--�����, �����; � �����-�����.
select Press.Name, count(Press.Id) [���-�� ����], sum(Books.Pages) [����� �������]
from Press
left join Books on Books.Id_Press =press.id
where Press.name in('�����','�����','�����-�����')
group by Press.Name

--������� �� ����� ���-�� ������ ���� �� ������ �� ������.
select Faculties.Name, count(id_book) [���-�� ������]
From S_Cards
left join Students on Students.id = S_Cards.Id_Student
left join Groups on Groups.Id = Students.Id_Group
left join Faculties on Faculties.Id = Groups.Id_Faculty
Group by Faculties.Name

--�������� ������������ � ����� ������ ����� ��� ������� �� ���.
Select Press.Name as PressName, Books.Name as BooksName, Query.Year
from(
	select Books.Id_Press, min(YearPress) as [Year]
	from Books
	Group By Books.Id_Press
	) as Query
Left join Press on Press.Id = Query.Id_Press
Left join Books on Books.YearPress = Query.Year and Books.Id_Press=Query.Id_Press

--������� ���������� ��������� ���������� �� ������ ������ ���������.
select Groups.Name, count(S_Cards.Id_Student)
from S_Cards
join Students on Students.Id = S_Cards.Id_Student
join Groups on Groups.Id = Students.Id_Group
GROUP BY Groups.Name

--������� ���������� ����, ������ � ���������� �������������� �� ���������
--&quot;����������������&quot; � &quot;���� ������&quot;, � ����� ������� � ���� ������
select Themes.Name as '��������', count(Books.Id) as '����������', sum(books.Pages) as '����� �������'
from Faculties
join Groups on Groups.Id_Faculty = Faculties.Id
join Students on  Students.Id_Group = Groups.Id
join S_Cards on S_Cards.Id_Student = Students.Id
join Books on Books.Id = S_Cards.Id_Book
join Themes on Themes.Id = Books.Id_Themes
where Faculties.Name = '����������������' and Themes.Name in('����������������', '���� ������')
group by Themes.Name

--���� ������� ����� ���������� ���� � ���������� �� 100%, �� ����������
--���������� ������� ���� (� ���������� ���������) ���� ������ ���������
--select sum(Books.Quantity) from Books
select Faculties.Name, count(S_Cards.Id_Student) as 'book count', ((count(S_Cards.Id_Student) * 100) / 33 ) as '%'
from Faculties
join Groups on Groups.Id_Faculty = Faculties.Id
join Students on Students.Id_Group = Groups.Id
join S_Cards on S_Cards.Id_Student = Students.Id
group by Faculties.Name

--��������, ��� ������� ����� ����� ������� ����� � ���� ���� ������ 1 �����, � ��
--������ ������ ����� ���� �� ������ &quot;���������&quot; ���������� ������������
--����� (������ ����������) ���������� (������� ������� 0.5 �) �������� ����.
--���������� ������� ������� ������ ������ ������ �������, � ����� ���������
--���������� ������ ����. �������� ����� ������ ����������� � ������� �������,
--�� ���� ��������� ����� ������ ������ ���� �����.
select sum(datediff(ww, dateadd(month, 1, S_Cards.DateOut), getdate()) * 0.25) as '�����', Students.FirstName + ' ' + Students.LastName as '�������'
from S_Cards 
join students on S_Cards.Id_Student = Students.Id
where S_Cards.DateIn is null
group by Students.FirstName, Students.LastName

select round(sum(datediff(ww, dateadd(month, 1, S_Cards.DateOut), getdate()) * 0.25), -1) as '����� ������'
from S_Cards 
where S_Cards.DateIn is null

--&quot;���������&quot; ����� ����� ��� ���������, ������� �� ������� ����� ����� ����, ��
--���� � ������� &quot;�������� ���������&quot; (S_cards) ��������� ���� ���� ��������
--������� ����� (Date())
select Students.FirstName, Students.LastName, S_Cards.DateOut, S_Cards.DateIn
from S_Cards
join Students on Students.Id = S_Cards.Id_Student
Update S_Cards
set DateIn = GETDATE()
where GETDATE() > dateadd(YEAR, 1, S_Cards.DateOut)

--������� �� ������� '�������� ���������' ���������, ������� ��� ������� �����.
delete 
from S_Cards
where S_Cards.DateIn is not null
