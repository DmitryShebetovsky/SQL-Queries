use Library_new
go
--����� ��� ������ ������������ �����, �� ���-�� ����������� �� 1. 
alter trigger Decrement_Books_Quantity_S
on S_Cards
for Insert
as
Declare @InsBookId int
declare @q int
Select @InsBookId=Id_Book from inserted
select @q = Books.Quantity from Books where Books.Id = @InsBookId
if ( @q <= 0)
begin
print('������������ ���-�� ����')
end
else 
update Books set Books.Quantity -=1 where Books.Id = @InsBookId	
--
alter trigger Decrement_Books_Quantity_T
on T_Cards
after Insert
as
Declare @InsBookId int
Select @InsBookId=Id_Book from inserted
update Books set Books.Quantity -=1 where Books.Id = @InsBookId	

--select Quantity from Books Where Books.Id =1

insert into S_Cards(Id_Student,Id_Book,DateOut,DateIn,Id_Lib) 
values (3,1,'20140313',null,1)

select Quantity from Books Where Books.Id =1

