USE Library
GO

--Написать такие функции: 

--1. Функцию, возвращающую кол-во студентов, которые не брали книги. 
CREATE FUNCTION StudentsWithoutBooks()
RETURNS int
AS
BEGIN
	DECLARE @count_of_students int
	SELECT @count_of_students = COUNT(*)
	FROM Students
	WHERE NOT EXISTS (SELECT * FROM S_Cards WHERE Id_Student = Students.Id)
	RETURN @count_of_students;
END;
GO

SELECT dbo.StudentsWithoutBooks();
GO

--2. Функцию, возвращающую минимальное из трех переданных параметров. 
CREATE FUNCTION GetMinimum(@first int, @second int, @third int)
RETURNS int
AS
BEGIN 
	DECLARE @result int
	SELECT @result = @first
	IF @result > @second
		SELECT @result = @second
	IF @result > @third
		SELECT @result = @third
	RETURN @result
END;
GO

SELECT dbo.GetMinimum(6, 4, 15);
GO

--3. Функцию, которая принимает в качестве параметра двухразрядное число и определяет какой из разрядов больше, либо они равны. (используйте % - деление по модулю. Например: 57%10=7) 
CREATE FUNCTION TwoDigitNumber(@number int)
RETURNS int
AS
BEGIN
	DECLARE @first_digit int, @second_digit int, @result int
	SELECT @first_digit = @number / 10
	SELECT @second_digit = @number % 10
	IF @first_digit > @second_digit
		SELECT @result = @first_digit
	ELSE
		SELECT @result = @second_digit
	RETURN @result
END;
GO

SELECT dbo.TwoDigitNumber(76);
GO
--4. Функцию, возвращающую кол-во взятых книг по каждой из групп и по каждой из кафедр (departments). 
CREATE FUNCTION CountBooksGroupDepartment()
RETURNS @res TABLE(CountBooks int, GroupOrDepartment nvarchar(50))
AS
BEGIN 	
	INSERT @res
		SELECT COUNT(*) as CountBooks, Groups.Name
		FROM S_Cards JOIN Students ON Id_Student = Students.Id
		JOIN Groups ON Students.Id_Group = Groups.Id
		GROUP BY Groups.Name
		UNION ALL
		SELECT COUNT(*) as CountBooks, Departments.Name
		FROM T_Cards JOIN Teachers ON Id_Teacher = Teachers.Id
		JOIN Departments ON Departments.Id = Teachers.Id_Dep
		GROUP BY Departments.Name
	RETURN;
END;
GO

SELECT *
FROM dbo.CountBooksGroupDepartment()
GO

--5. Функцию, возвращающую список книг, отвечающих набору критериев (например, имя автора, фамилия автора, тематика, категория), и отсортированный по номеру поля, указанному в 5-м параметре, в направлении, указанном в 6-м параметре. 
CREATE FUNCTION BookList(@authorFirstName nvarchar(50), @authorLastName nvarchar(50), @theme nvarchar(50), @category nvarchar(50), @numberOfSortColumn int, @direction int)
RETURNS @res TABLE(Id int, Name nvarchar(100), Pages int, YearPress int, Id_Themes int, Id_Category int, Id_Author int, Id_Press int, Comment nvarchar(50), Quantity int)
AS
BEGIN 
	IF @direction = 0
		BEGIN
			INSERT @res
				SELECT Id, Name, Pages, YearPress, Id_Themes, Id_Category, Id_Author, Id_Press, Comment, Quantity
				FROM Books
				WHERE Id_Author = (SELECT Id FROM Authors WHERE FirstName = @authorFirstName AND LastName = @authorLastName)
				AND Id_Themes = (SELECT Id FROM Themes WHERE Name = @theme) 
				AND Id_Category = (SELECT Id FROM Categories WHERE Name = @category)
				ORDER BY CASE @numberOfSortColumn
							WHEN 1 THEN Name
							WHEN 2 THEN Pages
							WHEN 3 THEN YearPress
							WHEN 4 THEN Id_Themes
							WHEN 5 THEN Id_Category
							WHEN 6 THEN Id_Author
							WHEN 7 THEN Id_Press
							WHEN 8 THEN Comment
							WHEN 9 THEN Quantity
							END
							ASC
		END;
	ELSE
		BEGIN
			INSERT @res
				SELECT Id, Name, Pages, YearPress, Id_Themes, Id_Category, Id_Author, Id_Press, Comment, Quantity
				FROM Books
				WHERE Id_Author = (SELECT Id FROM Authors WHERE FirstName = @authorFirstName AND LastName = @authorLastName)
				AND Id_Themes = (SELECT Id FROM Themes WHERE Name = @theme) 
				AND Id_Category = (SELECT Id FROM Categories WHERE Name = @category)
				ORDER BY CASE @numberOfSortColumn
							WHEN 1 THEN Name
							WHEN 2 THEN Pages
							WHEN 3 THEN YearPress
							WHEN 4 THEN Id_Themes
							WHEN 5 THEN Id_Category
							WHEN 6 THEN Id_Author
							WHEN 7 THEN Id_Press
							WHEN 8 THEN Comment
							WHEN 9 THEN Quantity
							END
							DESC
		END;
RETURN;
END;
GO

SELECT *
FROM dbo.BookList('Алексей', 'Архангельский', 'Программирование', 'C++ Builder', 2, 1)
GO

--6. Функцию, которая возвращает список библиотекарей и кол-во выданных каждым из них книг.
CREATE FUNCTION LibrarianList()
RETURNS @res TABLE (CountOfBooks int, FirstName nvarchar(50), LastName nvarchar(50), Id int)
AS
BEGIN
	WITH buf (CountOfBooks, FirstName, LastName, Id)
	AS
	(	SELECT COUNT(*), Libs.FirstName, Libs.LastName, Libs.Id
		FROM S_Cards JOIN Libs ON Id_Lib = Libs.Id
		GROUP BY Libs.FirstName, Libs.LastName, Libs.Id
		UNION ALL
		SELECT COUNT(*), Libs.FirstName, Libs.LastName, Libs.Id
		FROM T_Cards JOIN Libs ON Id_Lib = Libs.Id
		GROUP BY Libs.FirstName, Libs.LastName, Libs.Id	)
	INSERT @res
		SELECT SUM(CountOfBooks), FirstName, LastName, Id
		FROM buf
		GROUP BY FirstName, LastName, Id
	RETURN;
END;
GO

SELECT *
FROM dbo.LibrarianList()