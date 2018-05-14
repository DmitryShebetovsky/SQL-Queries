use Library;
go
-- студент
create login Student_1 with password = '12345'
create user Student_1 for login Student_1

create role Students
alter role Students
add member Student_1

grant select on Books TO Students
grant select on S_Cards(Id_Student, Id_Book) TO Students

revoke select on S_Cards(Id_Student, Id_Book) TO Students

--библиотекарь
create login Librarian_1 with password = '12345'
create user Librarian_1 for login Librarian_1

create role Librarians

alter role Librarians
add member Librarian_1

grant select on Students to Librarians
grant select on Teachers to Librarians
grant select on Books to Librarians
grant select on Themes to Librarians
grant select on Authors to Librarians
grant select on Categories to Librarians
grant select on Press to Librarians
grant select on S_Cards to Librarians
grant select on T_Cards to Librarians

grant insert, update, delete, select on Books to Librarians

grant insert, update, delete, select on S_Cards to Librarians

grant insert, update, delete, select on T_Cards to Librarians

--завуч
create login HeadTeacher_1 with password = '12345'
create user HeadTeacher_1 for login HeadTeacher_1

create role HeadTeachers

alter role HeadTeachers
add member HeadTeacher_1

grant insert, update, delete, select on S_Cards to HeadTeachers

grant insert, update, delete, select on T_Cards to HeadTeachers