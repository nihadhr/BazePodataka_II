--ISPITNI 25.09.2017

CREATE DATABASE IB170105
go
USE IB170105
GO

CREATE TABLE Klijenti(
KlijentID int IDENTITY(1,1) PRIMARY KEY,
Ime varchar(50) not null,
Prezime varchar(50) not null,
Drzava varchar(50) not null,
Grad varchar(50) not null,
Email varchar(50) not null,
Telefon varchar(50) not null
)

CREATE TABLE Izleti(
Sifra varchar(10) not null CONSTRAINT PK_Sifra PRIMARY KEY,
Naziv varchar(100) not null,
DatumPolaska date not null,
DatumPovratka date not null,
Cijena real not null,
Opis text null
)

CREATE TABLE Prijave(
KlijentID int not null,
IzletID varchar(10) not null,
Datum datetime not null,
BrojOdraslih int not null,
BrojDjece int not null
CONSTRAINT PK_KlijentIzlet PRIMARY KEY(KlijentID,IzletID),
CONSTRAINT FK_KlijentIzlet_KlijentID FOREIGN KEY(KlijentID) references Klijenti(KlijentID),
CONSTRAINT FK_KlijentIzlet_IzletID FOREIGN KEY(IzletID) references Izleti(Sifra)
)

INSERT INTO Klijenti
SELECT PP.FirstName,PP.LastName,PCR.Name,PA.City,EA.EmailAddress,PH.PhoneNumber
FROM AdventureWorks2014.Sales.SalesPerson as SP
inner join AdventureWorks2014.Person.Person AS PP
ON PP.BusinessEntityID=SP.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as EA
on EA.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Person.PersonPhone as PH
on PH.BusinessEntityID=EA.BusinessEntityID
inner join AdventureWorks2014.Person.BusinessEntity as BE
on BE.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Person.BusinessEntityAddress as BEA
on BEA.BusinessEntityID=BE.BusinessEntityID
inner join AdventureWorks2014.Person.Address as PA
ON PA.AddressID=BEA.AddressID
inner join AdventureWorks2014.Person.StateProvince as STP
ON STP.StateProvinceID=PA.StateProvinceID
inner join AdventureWorks2014.Person.CountryRegion AS PCR
ON PCR.CountryRegionCode=STP.CountryRegionCode

SELECT *
FROM Klijenti

INSERT INTO Izleti
VALUES('1242','MedjugorjeTrip',DATEADD(year,-4,SYSDATETIME()),DATEADD(year,-3,SYSDATETIME()),455,'Bice zanimljivo')

INSERT INTO Izleti
VALUES('1232','MedjugorjeTrip',DATEADD(year,-4,SYSDATETIME()),DATEADD(year,-3,SYSDATETIME()),455,'Bice zaasfnimljivo')

INSERT INTO Izleti
VALUES('1212','MedjugorjeTrip',DATEADD(year,-4,SYSDATETIME()),DATEADD(year,-3,SYSDATETIME()),4255,'Bice zanfsdfimljivo')


select DATEADD(year,-4,SYSDATETIME())

select *
from Izleti

select *
from Klijenti


ALTER PROC DodajPrijavu
@KlijentID int,@IzletID varchar(10),@BrojOdraslih int,@BrojDjece int 
as
begin
INSERT INTO Prijave(KlijentID,IzletID,Datum,BrojOdraslih,BrojDjece)
VALUES(@KlijentID,@IzletID,SYSDATETIME(),@BrojOdraslih,@BrojDjece)
end

EXEC DodajPrijavu 10,10,2,4

select * FROM Izleti
insert into Izleti(Sifra,Naziv,DatumPolaska,DatumPovratka,Cijena,Opis)
values(10,'Umra',SYSDATETIME(),DATEADD(day,12,SYSDATETIME()),2600,'Umra')



CREATE UNIQUE INDEX UnikatniEmail
ON Klijenti(Email)

INSERT INTO Klijenti(Ime,Prezime,Drzava,Grad,Email,Telefon)
VALUES('Nihad','Hrustic','USA','Florida','syed09@adventure-works.com','421-124-222')

UPDATE Izleti
SET Cijena=Cijena*0.9
WHERE Sifra in(
SELECT IzletID
FROM Prijave as I
GROUP BY IzletID
HAVING COUNT(IzletID)>3
)

CREATE VIEW PodaciOIzletu
AS
SELECT I.Sifra as Sifra,I.Naziv,I.DatumPolaska,I.DatumPovratka,I.Cijena,COUNT(P.IzletID)BrojPrijava,
SUM(P.BrojDjece+P.BrojOdraslih)BrojPutnika,SUM(P.BrojDjece)as BrojDjece,SUM(P.BrojOdraslih)BrojOdraslih
from Izleti as I
inner join Prijave as P
on P.IzletID=I.Sifra
GROUP BY I.Sifra,I.Naziv,I.DatumPolaska,I.DatumPovratka,I.Cijena

SELECT *
FROM PodaciOIzletu

alter PROC Zarada
@Sifra varchar(10)
as
begin
SELECT I.Sifra,SUM(I.Cijena),sum(P.BrojDjece*I.Cijena)*0.5 as zaradaOdDjece,sum(P.BrojOdraslih*I.Cijena)zaradaOdOdraslih
FROM Izleti as I
inner join Prijave as P
on P.IzletID=I.Sifra
WHERE I.Sifra like @Sifra
group by I.Sifra
end

EXEC Zarada 10

CREATE TABLE IzletiHistorijaCijena(
IzmjenaID int identity(1,1) PRIMARY KEY,
SifraID varchar(10) not null,
DatumIzmjeneCijene datetime,
StaraCijena real,
NovaCijena real
)

CREATE TRIGGER IzmjenaCijene
ON Izleti after update as
INSERT INTO IzletiHistorijaCijena(SifraID,DatumIzmjeneCijene,StaraCijena,NovaCijena)
select i.Sifra,SYSDATETIME(),d.Cijena,i.Cijena
from inserted as i
inner join deleted as d
on d.Sifra=i.Sifra

SELECT *
FROM IzletiHistorijaCijena

SELECT *
FROM Izleti

UPDATE Izleti
SET Cijena=250
WHERE Sifra like 1212

select I.Naziv,I.DatumPolaska,I.DatumPovratka,I.Cijena,IZC.DatumIzmjeneCijene,IZC.StaraCijena,IZC.NovaCijena
from Izleti as I
inner join IzletiHistorijaCijena as IZC
on IZC.SifraID=I.Sifra
WHERE I.Sifra LIKE 1212

select *
from Klijenti

select P.KlijentID
from Prijave as P


DELETE FROM Klijenti
where KlijentID NOT IN(
select P.KlijentID
from Prijave as P
)

BACKUP DATABASE IB170105 TO DISK ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\MojPrvi'
BACKUP DATABASE IB170105 TO DISK ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\mojdrugi' WITH DIFFERENTIAL
GO

-------------------------------------------------------------------------------

--ISPITNI 20.06.2017

CREATE DATABASE IB170106

ON(NAME=Ispitni2_mdf,
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\DATA\Ispitni2.mdf'
)
LOG ON(NAME=Ispitni2_ldf,
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Log\Ispitni2.ldf'
)
USE IB170106
GO
CREATE TABLE Proizvodi(
ProizvodID int not null PRIMARY KEY,
Sifra nvarchar(25) NOT NULL CONSTRAINT UQ_Sifra UNIQUE,
Naziv nvarchar(50) NOT NULL,
Kategorija nvarchar(50) NOT NULL,
Cijena real NOT NULL
)

CREATE TABLE Narudzbe(
NarudzbaID int PRIMARY KEY,
BrojNarudzbe nvarchar(25) not null UNIQUE,
Datum date NOT NULL,
Ukupno real not null
)

CREATE TABLE StavkeNarudzbe(
ProizvodID int,
NarudzbaID int,
Kolicina int not null,
Cijena real not null,
Popust real not null,
Iznos real not null,
CONSTRAINT PK_ProizvodNarudzbe PRIMARY KEY(ProizvodID,NarudzbaID),
CONSTRAINT FK_ProizvodNarudzbe_ProizvodID FOREIGN KEY(ProizvodID) references Proizvodi(ProizvodID),
CONSTRAINT FK_ProizvodNarudzbe_NarudzbaID FOREIGN KEY(NarudzbaID) references Narudzbe(NarudzbaID)
)

INSERT INTO Proizvodi(ProizvodID,Sifra,Naziv,Kategorija,Cijena)
SELECT DISTINCT PP.ProductID,PP.ProductNumber,PP.Name,PC.Name,PP.ListPrice
FROM AdventureWorks2014.Production.Product AS PP
inner join AdventureWorks2014.Production.ProductSubcategory AS PSC
on PSC.ProductSubcategoryID=PP.ProductSubcategoryID
inner join AdventureWorks2014.Production.ProductCategory as PC
on PC.ProductCategoryID=PSC.ProductCategoryID
inner join AdventureWorks2014.Sales.SalesOrderDetail as SOD
on SOD.ProductID=PP.ProductID
inner join AdventureWorks2014.Sales.SalesOrderHeader as SOH
on SOH.SalesOrderID=SOD.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2014

SELECT *
FROM StavkeNarudzbe

INSERT INTO Narudzbe(NarudzbaID,BrojNarudzbe,Datum,Ukupno)
SELECT SOH.SalesOrderID,SOH.SalesOrderNumber,SOH.OrderDate,SOH.TotalDue
FROM AdventureWorks2014.sales.SalesOrderHeader as SOH
where YEAR(SOH.OrderDate)=2014

INSERT INTO StavkeNarudzbe(ProizvodID,NarudzbaID,Kolicina,Cijena,Popust,Iznos)
select SOD.ProductID,SOD.SalesOrderID,SOD.OrderQty,SOD.UnitPrice,SOD.UnitPriceDiscount,SOD.LineTotal
from AdventureWorks2014.Sales.SalesOrderDetail as SOD
inner join AdventureWorks2014.Sales.SalesOrderHeader as SOH
on SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2014


CREATE TABLE Skladista(
SkladisteID int identity(1,2) PRIMARY KEY,
Naziv varchar(20) not null

)
CREATE TABLE SkladisteProizvod(
SkladisteID int,
ProizvodID int,
Kolicina int
CONSTRAINT PK_SkladisteProizvod PRIMARY KEY(SkladisteID,ProizvodID),
CONSTRAINT FK_SkladisteProizvod_SkladisteID FOREIGN KEY(SkladisteID) references Skladista(SkladisteID),
CONSTRAINT FK_SkladisteProizvod_ProizvodID FOREIGN KEY(ProizvodID) references Proizvodi(ProizvodID)
)

INSERT INTO Skladista(Naziv)
VALUES('Mostarsko'),('Sarajevsko'),('Vitez3')

INSERT INTO SkladisteProizvod(SkladisteID,ProizvodID,Kolicina)
SELECT 5,P.ProizvodID,0
FROM Proizvodi as P

CREATE PROC IzmjenaStanja
@ProizvodID int,@SkladisteID int,@Kolicina int
as
begin
UPDATE SkladisteProizvod
SET Kolicina=@Kolicina
WHERE SkladisteID=@SkladisteID AND ProizvodID=@ProizvodID
end

SELECT *
FROM Proizvodi

EXEC IzmjenaStanja 707,1,5

CREATE NONCLUSTERED INDEX ix_proizvodi
ON Proizvodi(Sifra,Naziv)
drop index ix_proizvodi on Proizvodi

SELECT *
FROM Proizvodi
WHERE Sifra LIKE 'HL%' AND Naziv like 'Sport%'


alter TRIGGER Alert
ON Proizvodi
INSTEAD OF DELETE 
as
RAISERROR( 'Brisanje je onemoguceno', 16, 2 )
ROLLBACK;

delete from Proizvodi
where ProizvodID=707

CREATE VIEW Prodaja
AS
SELECT P.Sifra,P.Naziv,P.Cijena,SUM(SN.Kolicina)KolicinaUk,sum(SN.Kolicina*P.Cijena)ZaradaUk
From Proizvodi as P
inner join StavkeNarudzbe as SN
on SN.ProizvodID=P.ProizvodID
inner join Narudzbe as N
on N.NarudzbaID=SN.NarudzbaID
GROUP BY P.Sifra,P.Naziv,P.Cijena


SELECT * 
FROM Prodaja
ORDER BY Prodaja.ZaradaUk desc

create proc UnesiSifru
@Sifra varchar(25)
AS
BEGIN
SELECT P.Naziv,SUM(SN.Kolicina)UkProdanaKolicina,SUM(SN.Kolicina*P.Cijena)UkZarada
FROM Proizvodi as P
inner join StavkeNarudzbe as SN
on SN.ProizvodID=P.ProizvodID
inner join Narudzbe as N
on N.NarudzbaID=SN.NarudzbaID
GROUP BY P.Naziv
END

ALTER PROC Unesi
@Sifra varchar(25)='%'
as
begin
SELECT *
FROM Prodaja
WHERE Prodaja.Sifra LIKE @Sifra
end

select *
from Proizvodi

exec Unesi

CREATE LOGIN Nixi
WITH PASSWORD='LUDNICA';
GO

CREATE USER Nixi FOR LOGIN Nixi;
GO


BACKUP DATABASE IB170106 TO DISK ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\MojTreci'
BACKUP DATABASE IB170106 TO DISK ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\mojcetvrti' WITH DIFFERENTIAL
GO

-----------------------------------------------------------------------------------------------------------------

--ISPITNI 07.09.2017

CREATE DATABASE IB170107
GO

USE IB170107
GO

CREATE TABLE Klijenti(
KlijentID int identity(1,1) CONSTRAINT PK_Klijent PRIMARY KEY,
Ime varchar(50) not null,
Prezime varchar(50) not null,
Grad varchar(50) not null,
Email varchar(50) not null,
Telefon varchar(50) not null
)

CREATE TABLE Racuni(
RacunID int identity(1,1) CONSTRAINT PK_Racun PRIMARY KEY,
DatumOtvaranja date not null,
TipRacuna varchar(50) not null,
BrojRacuna varchar(16) not null,
Stanje real not null
)
ALTER TABLE Racuni
ADD KlijentID int CONSTRAINT FK_Klijent REFERENCES Klijenti(KlijentID)

CREATE TABLE Transakcije(
TransakcijaID int identity(2,3) CONSTRAINT PK_Transakcija PRIMARY KEY,
Datum datetime not null,
Primatelj varchar(50) not null,
BrojRacunaPrimatelja varchar(16) not null,
MjestoPrimatelja varchar(50) not null,
AdresaPrimatelja varchar(50) null,
Svrha varchar(200) null,
Iznos real not null,
RacunID int CONSTRAINT FK_Racun FOREIGN KEY REFERENCES Racuni(RacunID)
)
DROP CONSTRAINT FK_Racun

ALTER TABLE Racuni
WITH CHECK ADD CONSTRAINT PK_Racun PRIMARY KEY(RacunID)
alter table Transakcije
with check add constraint FK_Racun FOREIGN KEY (RacunID) REFERENCES Racuni(RacunID) ON DELETE CASCADE

CREATE UNIQUE INDEX UQ_Email 
ON Klijenti(Email)

CREATE UNIQUE INDEX UQ_BrojRacuna
ON Racuni(BrojRacuna)

ALTER PROC UnosRacuna
@DatumOtvaranja date,
@TipRacuna varchar(50),
@BrojRacuna varchar(16),
@Stanje real =0,
@KlijentID int
AS
BEGIN
INSERT INTO Racuni(DatumOtvaranja,TipRacuna,BrojRacuna,Stanje,KlijentID)
VALUES(@DatumOtvaranja,@TipRacuna,@BrojRacuna,@Stanje,@KlijentID)
END

DECLARE @Datum DATE=SYSDATETIME()
EXEC UnosRacuna '2010-05-14','SDS','12412'

SELECT *
FROM Klijenti
EXEC UnosRacuna '2010-05-14','SDS','1252152',0,1

EXEC UnosRacuna '2010-05-14','SDS','122241',0,1
EXEC UnosRacuna '2010-05-14','SDS','1346442',0,11
EXEC UnosRacuna '2018-05-14','SSSDS','1789152',0,14
EXEC UnosRacuna '2010-05-14','SDADS','12521S52',0,16
EXEC UnosRacuna '2015-05-11','AFFG','12521A52',0,9
EXEC UnosRacuna '2010-05-14','0O12','12521d52',0,4
EXEC UnosRacuna '2010-05-14','24DDA','1252s152',0,4
EXEC UnosRacuna '2007-05-16','14NB','125s2152',0,5
EXEC UnosRacuna '2014-07-14','SD11','125c2152',0,4



select *
from Transakcije

INSERT INTO Klijenti(Ime,Prezime,Grad,Email,Telefon)
SELECT SUBSTRING(C.ContactName,0,CHARINDEX(' ',C.ContactName)),SUBSTRING(C.ContactName,CHARINDEX(' ',C.ContactName),50),C.City,SUBSTRING(C.ContactName,0,CHARINDEX(' ',C.ContactName))+'.'+SUBSTRING(C.ContactName,CHARINDEX(' ',C.ContactName)+1,50)+'@northwind.ba',C.Phone
FROM NORTHWND.dbo.Customers AS C

select R.RacunID
from Racuni as R

INSERT INTO Transakcije
SELECT TOP 10 O.OrderDate,O.ShipName,O.OrderID+'00000123456',O.ShipCity,O.ShipAddress,NULL,OD.Quantity*OD.UnitPrice,17
FROM NORTHWND.dbo.Orders as O
inner join NORTHWND.dbo.[Order Details] as OD
on OD.OrderID=O.OrderID
ORDER BY NEWID()

INSERT INTO Transakcije
SELECT TOP 10 O.OrderDate,O.ShipName,O.OrderID+'00000123456',O.ShipCity,O.ShipAddress,NULL,OD.Quantity*OD.UnitPrice,3
FROM NORTHWND.dbo.Orders as O
WHERE O.OrderID=(
SELECT OD.OrderID
FROM NORTHWND.dbo.[Order Details] as OD
)
ORDER BY NEWID()

select *
from Transakcije

UPDATE Racuni
SET Stanje=Stanje+500
FROM Racuni AS R
inner join Klijenti as K
on K.KlijentID=R.KlijentID
WHERE K.Grad like 'London' and MONTH(R.DatumOtvaranja)=5

create view PregledStanja
as
select K.Ime+K.Prezime AS ImePrezime,K.Grad,K.Email,K.Telefon,R.TipRacuna,R.BrojRacuna,R.Stanje,T.Primatelj,T.BrojRacunaPrimatelja,T.Iznos
FROM Klijenti as K
left join Racuni as R
on R.KlijentID=K.KlijentID
left join Transakcije as T
on T.RacunID=R.RacunID

CREATE PROC BrojRacuna
@BrojRacuna varchar(50)
AS
begin
Select PS.ImePrezime,PS.Grad,PS.Telefon,isnull(PS.BrojRacuna,'N/A'),ISNULL(CONVERT(VARCHAR,PS.Stanje),'N/A'),count(PS.BrojRacuna)brojTransakcija
FROM PregledStanja as PS
WHERE PS.BrojRacuna LIKE @BrojRacuna
GROUP BY PS.ImePrezime,PS.Grad,PS.Telefon,PS.BrojRacuna,PS.Stanje
end

EXEC BrojRacuna '1789152'

alter PROC Klijent
@KlijentID int
as
begin 

DELETE FROM Racuni
WHERE Racuni.KlijentID=@KlijentID

DELETE FROM Klijenti
WHERE KlijentID=@KlijentID
end

SELECT *
FROM Transakcije

EXEC Klijent 4

create proc Uvecaj
@Grad varchar(50),@Mjesec int,@UvecajZa real
as
begin
UPDATE R
SET Stanje=Stanje+@UvecajZa
FROM Racuni as R
inner join Klijenti as K
on K.KlijentID=R.KlijentID
WHERE K.Grad LIKE @Grad and MONTH(R.DatumOtvaranja)=@Mjesec
end

EXEC Uvecaj 'London',5,500

backup database IB170107 TO disk='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\MojPeti'
backup database IB170107 TO disk='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\MojSesti' WITH DIFFERENTIAL

---------------------------------------------------------------------------------------------------------------------

--ISPITNI 05.09.2016

CREATE DATABASE IB170108
GO

USE IB170108
GO

CREATE TABLE Klijenti(
KlijentID int identity(1,1) PRIMARY KEY,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null,
Telefon nvarchar(20) not null,
Mail nvarchar(50) not null CONSTRAINT UQ_Mail UNIQUE,
BrojRacuna nvarchar(15) not null,
KorisnickoIme nvarchar(20) not null,
Lozinka nvarchar(20) not null
)
alter table Klijenti
ALTER COLUMN KorisnickoIme nvarchar(59)not null

CREATE TABLE Transakcije(
TransakcijaID int identity(1,1) CONSTRAINT PK_Transakcija PRIMARY KEY,
Datum datetime not null,
TipTransakcije nvarchar(30)not null,
PosiljalacID int not null CONSTRAINT FK_Posiljalac FOREIGN KEY REFERENCES Klijenti(KlijentID), 
PrimalacID int not null CONSTRAINT FK_Primalac FOREIGN KEY REFERENCES Klijenti(KlijentID),
Svrha nvarchar(50) not null,
Iznos real not null
)

ALTER TABLE Transakcije
DROP CONSTRAINT FK_Primalac

ALTER TABLE Transakcije
DROP COLUMN PosiljalacID
ALTER TABLE Transakcije
DROP COLUMN PrimalacID

select *
from Transakcije

alter table Transakcije
ADD PrimalacID int constraint FK_Primalac foreign key references Klijenti(KlijentID) ON DELETE CASCADE;

INSERT INTO Klijenti(Ime,Prezime,Telefon,Mail,BrojRacuna,KorisnickoIme,Lozinka)
SELECT P.FirstName,P.LastName,PH.PhoneNumber,PE.EmailAddress,SC.AccountNumber,P.FirstName+'.'+P.LastName,RIGHT(PP.PasswordHash,8)
FROM AdventureWorks2014.Sales.Customer as SC
inner join AdventureWorks2014.Person.Person as P
on P.BusinessEntityID=SC.PersonID
inner join AdventureWorks2014.Person.Password as PP
ON PP.BusinessEntityID=P.BusinessEntityID
inner join AdventureWorks2014.Person.PersonPhone as PH
on PH.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as PE
on PE.BusinessEntityID=PH.BusinessEntityID

select K.KlijentID,K.KorisnickoIme
FROM Klijenti as K

INSERT INTO Transakcije(Datum,TipTransakcije,PosiljalacID,PrimalacID,Svrha,Iznos)
values('2017-05-15','Uplata','143','162','Obnova ucionice',920),
('2010-05-14','Uplata','121','122','Stipendija',150)
,('2010-05-01','Uplata','121','125','Stipendija',150)
,('2010-05-10','Uplata','121','127','Stipendija',150)
,('2010-05-13','Uplata','121','144','Stipendija',150)
,('2010-05-15','Uplata','121','142','Stipendija',150)
,('2010-05-16','Uplata','121','153','Stipendija',150)
,('2010-05-17','Uplata','121','152','Stipendija',150)
,('2010-05-12','Uplata','121','132','Stipendija',150)
,('2010-05-11','Uplata','121','172','Stipendija',150)
,('2017-05-15','Uplata','143','162','Obnova ucionice',920)

CREATE NONCLUSTERED INDEX NX_Klijenti
ON Klijenti(Ime,Prezime)
INCLUDE (BrojRacuna)

ALTER INDEX NX_Klijenti on Klijenti
DISABLE

CREATE PROC UnosKlijenta
@Ime nvarchar(30),
@Prezime nvarchar(30),
@Telefon nvarchar(20),
@Mail nvarchar(50),
@BrojRacuna nvarchar(15),
@KorisnickoIme nvarchar(20),
@Lozinka nvarchar(20)
AS
BEGIN
INSERT INTO Klijenti(Ime,Prezime,Telefon,Mail,BrojRacuna,KorisnickoIme,Lozinka)
values(@Ime,@Prezime,@Telefon,@Mail,@BrojRacuna,@KorisnickoIme,@Lozinka)
END


CREATE VIEW TransakcijeV
as
SELECT T.Datum,T.TipTransakcije,K1.Ime+K1.Prezime PosiljaocImePrezime,K1.BrojRacuna PosiljaocBroj,
K2.Ime+K2.Prezime PrimaocImePreizme,K2.BrojRacuna PrimaocBrojRacuna,T.Svrha,T.Iznos
FROM Transakcije as T
inner join Klijenti K1
on K1.KlijentID=T.PosiljalacID
inner join Klijenti K2
on K2.KlijentID=T.PrimalacID

SELECT *
FROM TransakcijeV

CREATE PROC PregledTransakcijaByRacun
@BrojRacuna nvarchar(50)
AS
BEGIN
SELECT *
FROM TransakcijeV
WHERE TransakcijeV.PosiljaocBroj like @BrojRacuna
END

EXEC PregledTransakcijaByRacun 'AW00029484'

SELECT year(T.Datum) KalendarskaGodina,SUM(T.Iznos)UkIznos
FROM Transakcije as T
GROUP BY YEAR(T.Datum)
ORDER BY YEAR(T.Datum)asc

create proc BrisanjeKlijenata
@KlijentID int
as
begin
DELETE FROM Klijenti
WHERE Klijenti.KlijentID=@KlijentID
end

BACKUP DATABASE IB170108 TO disk='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\DATA\NekoIme'

-------------------------------------------------------------------------------------------------------------------------

--ISPITNI 05.07.2018

CREATE DATABASE IB170109
GO

USE IB170109
GO

CREATE TABLE Zaposlenici(
ZaposlenikID int PRIMARY KEY,
Ime varchar(30) not null,
Prezime varchar(30) not null,
Spol varchar(10) not null,
JMBG varchar(13) not null,
DatumRodjenja date not null DEFAULT SYSDATETIME(),
Adresa varchar(100) not null,
Email varchar(100) not null,
KorisnickoIme varchar(60) not null,
Lozinka varchar(30) not null
)
alter table Zaposlenici
ALTER COLUMN Adresa varchar(100) NULL


Create table Artikli(
ArtikalID int PRIMARY KEY,
Naziv varchar(50)not null,
Cijena real not null,
StanjeNaSkladistu int not null
)

CREATE TABLE Prodaja(
ArtikalID int,
ZaposlenikID int,
Datum date not null DEFAULT SYSDATETIME(),
Kolicina real not null,
CONSTRAINT PK_Artikal_Zaposlenik_Datum PRIMARY KEY(ArtikalID,ZaposlenikID,Datum),
CONSTRAINT FK_Artikal_Zaposlenik_Datum_Artikal FOREIGN KEY(ArtikalID) REFERENCES Artikli(ArtikalID),
CONSTRAINT FK_Artikal_Zaposlenik_Datum_Zaposlenik FOREIGN KEY(ZaposlenikID) REFERENCES Zaposlenici(ZaposlenikID)
)
alter table Artikli
add Kategorija varchar(50)

alter table Prodaja
add constraint FK_Artikal_Zaposlenik_Datum_Zaposlenik FOREIGN KEY(ZaposlenikID) REFERENCES Zaposlenici(ZaposlenikID)ON DELETE CASCADE;


INSERT INTO Zaposlenici(ZaposlenikID,Ime,Prezime,Spol,JMBG,DatumRodjenja,Adresa,Email,KorisnickoIme,Lozinka)
SELECT E.EmployeeID,E.FirstName,E.LastName,CASE WHEN E.TitleOfCourtesy LIKE 'Ms.' THEN 'Z' ELSE 'M' END,DAY(E.BirthDate)+MONTH(E.BirthDate)+YEAR(E.BirthDate),E.BirthDate,E.Country+' '+E.City+' '+E.Address,
E.FirstName+RIGHT(CONVERT(varchar,YEAR(E.BirthDate)),2)+'@poslovna.ba',E.FirstName+'.'+E.LastName,
REPLACE(REVERSE(SUBSTRING(E.Notes,15,21)+LEFT(E.Extension,2)+' '+CONVERT(VARCHAR,DATEDIFF(DAY,E.BirthDate,E.HireDate))),' ','#')
FROM NORTHWND.dbo.Employees as E
WHERE DATEDIFF(year,E.BirthDate,SYSDATETIME())>60

INSERT INTO Artikli(ArtikalID,Naziv,Cijena,StanjeNaSkladistu)
SELECT DISTINCT P.ProductID,P.ProductName,P.UnitPrice,P.UnitsInStock
FROM NORTHWND.dbo.Products as P
inner join NORTHWND.dbo.[Order Details] AS OD
ON OD.ProductID=P.ProductID
inner join NORTHWND.dbo.Orders AS O
on O.OrderID=OD.OrderID
WHERE YEAR(O.OrderDate)=1997 AND (MONTH(O.OrderDate)=7 OR MONTH(O.OrderDate)=8)

INSERT INTO Prodaja(ArtikalID,ZaposlenikID,Datum,Kolicina)
SELECT OD.ProductID,O.EmployeeID,O.OrderDate,OD.Quantity
FROM NORTHWND.dbo.[Order Details] as OD
inner join NORTHWND.dbo.Orders as O
on O.OrderID=OD.OrderID
WHERE YEAR(O.OrderDate)=1997 AND (MONTH(O.OrderDate)=7 OR MONTH(O.OrderDate)=8)
AND O.EmployeeID IN(SELECT Z.ZaposlenikID
FROM Zaposlenici as Z
)

update Artikli
SET Artikli.Kategorija='Hrana'
WHERE Artikli.ArtikalID%3=0
select *
from Artikli

UPDATE Zaposlenici
SET Zaposlenici.DatumRodjenja=DATEADD(year,2,DatumRodjenja)
where Spol like 'Z'

SELECT year(E.BirthDate)+month(E.BirthDate)+day(E.BirthDate)
FROM NORTHWND.dbo.Employees as E



UPDATE Zaposlenici
SET KorisnickoIme=Ime+'_'+SUBSTRING(CONVERT(varchar,YEAR(DatumRodjenja)),2,3)+'_'+Prezime

SELECT A.Naziv,A.StanjeNaSkladistu,SUM(P.Kolicina) naruceno,SUM(P.Kolicina)-A.StanjeNaSkladistu as KolikoFali
FROM Artikli as A
inner join Prodaja as P
on A.ArtikalID=P.ArtikalID
GROUP BY A.Naziv,A.StanjeNaSkladistu
having SUM(P.Kolicina)>A.StanjeNaSkladistu

select Z.Ime+Z.Prezime,A.Naziv,ISNULL(A.Kategorija,'N/A'),convert(varchar,sum(P.Kolicina))+' kom' KOLICINA,convert(varchar,sum(P.Kolicina*A.Cijena))+' KM' ZARADA
from Zaposlenici as Z
inner join Prodaja as P
on P.ZaposlenikID=Z.ZaposlenikID
inner join Artikli as A
on A.ArtikalID=P.ArtikalID
WHERE Z.Adresa LIKE '%USA%'
GROUP BY Z.Ime,Z.Prezime,A.Naziv,A.Kategorija

select Z.Ime+Z.Prezime,A.Naziv,ISNULL(A.Kategorija,'N/A'),convert(varchar,sum(P.Kolicina))+' kom' KOLICINA,convert(varchar,sum(P.Kolicina*A.Cijena))+' KM' ZARADA
from Zaposlenici as Z
inner join Prodaja as P
on P.ZaposlenikID=Z.ZaposlenikID
inner join Artikli as A
on A.ArtikalID=P.ArtikalID
where (A.Naziv LIKE 'G%' OR A.Naziv LIKE 'C%') AND Z.Spol LIKE 'Z' AND (P.Datum='1997-09-22' or P.Datum='1997-08-22')
GROUP BY Z.Ime,Z.Prezime,A.Naziv,A.Kategorija

SELECT Z.Ime,Z.Prezime,Z.DatumRodjenja,Z.Spol,COUNT(P.ZaposlenikID)BrojProdaja
FROM Zaposlenici as Z
inner join Prodaja as P
ON P.ZaposlenikID=Z.ZaposlenikID
GROUP BY Z.Ime,Z.Prezime,Z.DatumRodjenja,Z.Spol
ORDER BY COUNT(P.ZaposlenikID)desc

DELETE FROM Zaposlenici
WHERE Zaposlenici.Adresa like '%London%'

---------------------------------------------------------------------------------------------------------------------

--ISPITNI 22.06.2018

CREATE DATABASE IB170110
GO

USE IB170110
GO

CREATE TABLE Otkupljivaci(
OtkupljivacID int CONSTRAINT PK_Otkupljivac PRIMARY KEY,
Ime varchar(50) not null,
Prezime varchar(50) not null,
DatumRodjenja date not null DEFAULT SYSDATETIME(),
JMBG varchar(13),
Spol char not null,
Grad varchar(50) not null,
Adresa varchar(100) not null,
Email varchar(100) not null CONSTRAINT UQ_Email UNIQUE,
Aktivan bit not null DEFAULT 1
)

CREATE TABLE Proizvodi(
ProizvodID int CONSTRAINT PK_Proizvod PRIMARY KEY,
Naziv varchar(50) not null,
Sorta varchar(50) not null,
OtkupnaCijena real not null,
Opis text
)

CREATE TABLE OtkupProizvoda(
ProizvodID int,
OtkupljivacID int,
Datum date not null DEFAULT SYSDATETIME(),
Kolicina real not null,
BrojGajbica int not null,
CONSTRAINT PK_ProizvodID_OtkupljivacID_Kolicina PRIMARY KEY(ProizvodID,OtkupljivacID,Kolicina),
CONSTRAINT FK_ProizvodID_OtkupljivacID_Kolicina_Proizvod FOREIGN KEY(ProizvodID) references Proizvodi(ProizvodID),
CONSTRAINT FK_ProizvodID_OtkupljivacID_Kolicina_Otkupljivac FOREIGN KEY(OtkupljivacID) references Otkupljivaci(OtkupljivacID)

)
ALTER TABLE OtkupProizvoda
ADD CONSTRAINT FK_Proizvod_Otkupljivac_Datum_Kolicina_Otkupljivac FOREIGN KEY(OtkupljivacID)references Otkupljivaci(OtkupljivacID)

alter table OtkupProizvoda
add CONSTRAINT FK_Proizvod_Otkupljivac_Datum_Kolicina_Otkupljivac foreign key(OtkupljivacID) REFERENCES Otkupljivaci(OtkupljivacID) ON DELETE CASCADE;

SELECT *
FROM OtkupProizvoda


INSERT INTO Otkupljivaci(OtkupljivacID,Ime,Prezime,DatumRodjenja,JMBG,Spol,Grad,Adresa,Email,Aktivan)
select TOP 5 E.EmployeeID,E.FirstName,E.LastName,E.BirthDate, 
REVERSE(CONVERT(VARCHAR,YEAR(E.BirthDate)))+CONVERT(varchar,day(E.BirthDate))+CONVERT(varchar,month(E.BirthDate))+convert(varchar,RIGHT(E.HomePhone,4)),CASE WHEN E.TitleOfCourtesy LIKE 'Ms.' THEN 'Z' ELSE 'M' end,E.City,REPLACE(E.Address,' ','_'),E.FirstName+'_'+E.LastName+'@edu.fit.ba',1
from NORTHWND.dbo.Employees as E
order by E.BirthDate desc

INSERT INTO Proizvodi(ProizvodID,Naziv,Sorta,OtkupnaCijena,Opis)
SELECT P.ProductID,P.ProductName,C.CategoryName,P.UnitPrice,C.Description
FROM NORTHWND.dbo.Products as P
inner join NORTHWND.dbo.Categories as C
on C.CategoryID=P.CategoryID

INSERT INTO OtkupProizvoda(ProizvodID,OtkupljivacID,Datum,Kolicina,BrojGajbica)
SELECT OD.ProductID,O.EmployeeID,O.OrderDate,OD.Quantity*8,OD.Quantity
FROM NORTHWND.dbo.[Order Details] AS OD
inner join NORTHWND.dbo.Orders as O
ON OD.OrderID=O.OrderID
WHERE O.EmployeeID IN(
SELECT OtkupljivacID
FROM Otkupljivaci
)

select CustomerID
from NORTHWND.dbo.[Orders]

ALTER TABLE Otkupljivaci
ALTER COLUMN Adresa varchar(100)  null

ALTER TABLE Proizvodi
add TipProizvoda varchar(50)

UPDATE Proizvodi
SET TipProizvoda='Voce'
WHERE ProizvodID%3=0

UPDATE Otkupljivaci
SET Aktivan=0
WHERE Otkupljivaci.Grad NOT LIKE 'London' AND YEAR(Otkupljivaci.DatumRodjenja)>=1960

UPDATE Proizvodi
SET OtkupnaCijena=OtkupnaCijena+5.45
where Proizvodi.Sorta like '%/%'

SELECT O.Ime + ' ' +O.Prezime ImePrezime,P.Naziv NazivProizvoda,SUM(OP.Kolicina)Kolicina,SUM(OP.BrojGajbica)BrojGajbica
FROM Otkupljivaci as O
inner join OtkupProizvoda as OP
ON OP.OtkupljivacID=O.OtkupljivacID
inner join Proizvodi as P
on P.ProizvodID=OP.ProizvodID
GROUP BY O.Ime+ ' ' +O.Prezime,P.Naziv
ORDER BY P.Naziv asc,SUM(OP.Kolicina)DESC

SELECT P.Naziv,convert(varchar,SUM(OP.Kolicina*P.OtkupnaCijena)) +' KM' as Zarada,convert(varchar,SUM(OP.Kolicina))+' KOM' Kolicina
FROM Proizvodi as P
inner join OtkupProizvoda as OP
on OP.ProizvodID=P.ProizvodID
where (OP.Datum BETWEEN '1996-12-24' AND '1997-08-16' )
GROUP BY P.Naziv
having SUM(OP.Kolicina) >1000

SELECT P.Naziv,ISNULL(P.TipProizvoda,'NIJE DEFINISAN'),P.Sorta,count(OP.ProizvodID)BrojOtkupljivanja
FROM Proizvodi as P
inner join OtkupProizvoda as OP
ON OP.ProizvodID=P.ProizvodID
GROUP BY P.Naziv,ISNULL(P.TipProizvoda,'NIJE DEFINISAN'),P.Sorta
order BY COUNT(OP.ProizvodID) desc

SELECT *
FROM OtkupProizvoda

SELECT *
FROM Otkupljivaci

DELETE FROM Otkupljivaci
WHERE Grad like 'Seattle'

backup database IB170110 TO DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\DATA\MojDeveti';

-------------------------------------------------------------------------------------------------------------------------------------------------

--ISPITNI 16.07.2016

CREATE DATABASE IB170111
GO

USE IB170111
GO

CREATE TABLE Proizvodi(
ProizvodID int identity(1,1)CONSTRAINT PK_Proizvod PRIMARY KEY,
Sifra nvarchar(10) not null CONSTRAINT UQ_Sifra UNIQUE,
Naziv nvarchar(50) not null,
Cijena decimal not null
)

CREATE TABLE Skladista(
SkladisteID int identity(1,1)CONSTRAINT PK_Skladiste PRIMARY KEY,
Naziv nvarchar(50) not null,
Oznaka nvarchar(10) not null CONSTRAINT UQ_Oznaka UNIQUE,
Lokacija nvarchar(50) not null
)

CREATE TABLE SkladisteProizvodi(
SkladisteID int,
ProizvodID int,
Stanje decimal not null,
CONSTRAINT PK_SkladisteProizvod PRIMARY KEY(SkladisteID,ProizvodID),
CONSTRAINT FK_SkladisteProizvod_Skladiste FOREIGN KEY(SkladisteID)REFERENCES Skladista(SkladisteID),
CONSTRAINT FK_SkladisteProizvod_Proizvod FOREIGN KEY(ProizvodID)REFERENCES Proizvodi(ProizvodID) ON DELETE CASCADE
)

INSERT INTO Skladista(Naziv,Oznaka,Lokacija)
VALUES ('Mostarsko','MO3121','Mostar'),
('Sarajevsko','SA1946','Sarajevo'),
('Zenicko','ZE1945','Zenica')

INSERT INTO Proizvodi(Sifra,Naziv,Cijena)
SELECT TOP 10 P.ProductNumber,P.Name,P.ListPrice
FROM AdventureWorks2014.Production.Product as P
inner join AdventureWorks2014.Production.ProductSubcategory as PSC
on P.ProductSubcategoryID=PSC.ProductSubcategoryID
inner join AdventureWorks2014.Production.ProductCategory AS PC
ON PC.ProductCategoryID=PSC.ProductCategoryID
inner join AdventureWorks2014.Sales.SalesOrderDetail as SOH
on SOH.ProductID=P.ProductID
WHERE PC.Name LIKE 'Bikes'
GROUP BY P.ProductNumber,P.Name,P.ListPrice
ORDER BY SUM(SOH.OrderQty)desc

INSERT INTO SkladisteProizvodi(ProizvodID,SkladisteID,Stanje)
SELECT P.ProizvodID,6,0
from Proizvodi as P

SELECT *
FROM Skladista
insert into Skladista(Naziv,Oznaka,Lokacija)
VALUES('Banjalucko','BL','Banja Luka')


USE IB170111
GO

select *
from SkladisteProizvodi

create proc StanjeSkladista
@ProizvodID int,@SkladisteID int,@Dodaj int
as
begin
UPDATE SkladisteProizvodi
SET Stanje=Stanje+@Dodaj
WHERE SkladisteID=@SkladisteID and ProizvodID=@ProizvodID
end

EXEC StanjeSkladista 1,1,5

CREATE NONCLUSTERED INDEX IX_Proizvod
ON Proizvodi(Sifra,Naziv)
INCLUDE(Cijena)

ALTER INDEX IX_Proizvod ON Proizvodi
DISABLE;

CREATE VIEW Informacije
as
SELECT P.Sifra,P.Naziv NazivProizvoda,P.Cijena,S.Oznaka,S.Naziv,S.Lokacija,SP.Stanje 
FROM Proizvodi as P
inner join SkladisteProizvodi as SP
on P.ProizvodID=SP.ProizvodID
inner join Skladista AS S
on SP.SkladisteID=S.SkladisteID

select *
from Proizvodi

alter proc UkupneZalihe
@Sifra nvarchar(10)
as
begin
SELECT I.Sifra,I.NazivProizvoda,I.Cijena,SUM(I.Stanje)
FROM Informacije as I
WHERE I.Sifra LIKE @Sifra
GROUP BY I.Sifra,I.NazivProizvoda,I.Cijena
end
use IB170111
go
EXEC UkupneZalihe 'BK-M68B-38'

alter proc UnosProizvoda
@Naziv nvarchar(10),@Cijena decimal,@Sifra nvarchar(10)
as
begin
INSERT INTO Proizvodi(Sifra,Naziv,Cijena)
VALUES(@Sifra,@Naziv,@Cijena)

INSERT SkladisteProizvodi
select S.SkladisteID, (select ProizvodID from Proizvodi where @Sifra=Sifra),0
from Skladista as S
end

EXEC UnosProizvoda 'Cokolada',2,'MojSiMoj1312'


CREATE PROC BrisiSifra
@Sifra varchar(40)
as
begin
DELETE FROM Proizvodi
WHERE Sifra LIKE @Sifra
end
EXEC BrisiSifra 'BK-M68B-38'

SELECT *
FROM SkladisteProizvodi

create trigger Preventiva
ON Proizvodi FOR DELETE
AS
PRINT 'Greska' 
ROLLBACK;

DROP TRIGGER Preventiva

create trigger Prevnntuj
on Proizvodi for delete ,update,insert
as
PRINT 'Nemre'
rollback

drop trigger Prevnntuj


DELETE FROM Proizvodi
WHERE Proizvodi.Naziv LIKE 'Cokolada'

insert into Proizvodi(Cijena,Naziv,Sifra)
values (14,'niij3h','146222624')

CREATE TRIGGER JBG
ON DATABASE
FOR DROP_TABLE
AS
PRINT 'DSFSFD'
ROLLBACK;

DROP TRIGGER JBG
ON DATABASE

CREATE TABLE LogUpdate(
LogID int identity(1,1) primary key,
VrijemeIzmjene datetime,
NazivStari varchar(40)
)

USE prihodi
go
CREATE TRIGGER NeDozvoliBrisanje
ON DATABASE
FOR DROP_TABLE,DROP_VIEW
AS
Print 'Nedozvoljena operacija'
rollback;

use IB170111
GO

ALTER trigger UpdateLog
ON Proizvodi
AFTER UPDATE AS
INSERT INTO LogUpdate(VrijemeIzmjene,NazivStari)
select SYSDATETIME(),d.Naziv
from inserted as i
inner join deleted as d
on d.ProizvodID=i.ProizvodID

UPDATE Proizvodi
SET Naziv='izmjsdsadena'
WHERE Sifra LIKE 'BK-M68B-42'

DROP TRIGGER Prevnntuj

select *
from Proizvodi

SELECT *
FROM LogUpdate


CREATE TRIGGER NeDozvoliMijenjaneStanjaNaSkladistu
ON SkladisteProizvodi
FOR UPDATE
as
PRINT 'Nije dozvoljeno mijenjanje stanja'
rollback;


DROP TRIGGER NeDozvoliMijenjaneStanjaNaSkladistu


UPDATE SkladisteProizvodi 
SET Stanje=Stanje+1
WHERE ProizvodID=2



CREATE TABLE LogIzmjeneStanja(
LogID int identity(1,1) primary key,
NazivProizvoda varchar(40),
StaroStanje int,
NovoStanje int,
Korisnik varchar(40)
)
select *
from LogIzmjeneStanja

create trigger TraceIzmjenuStanja
ON SkladisteProizvodi
AFTER UPDATE AS
INSERT INTO LogIzmjeneStanja(NazivProizvoda,StaroStanje,NovoStanje,Korisnik)
SELECT P.Naziv,d.Stanje,i.Stanje,SYSTEM_USER
FROM inserted as i
inner join deleted as d
on d.ProizvodID=i.ProizvodID and d.SkladisteID=i.SkladisteID
inner join Proizvodi as P
on P.ProizvodID=i.ProizvodID

SELECT *
FROM SkladisteProizvodi

--- 1  2 101+5

UPDATE SkladisteProizvodi
SET Stanje=Stanje+5
WHERE SkladisteID=1 AND ProizvodID=3

SELECT *
FROM LogIzmjeneStanja
USE IB170111
GO

CREATE TRIGGER NoDelete
on Skladista
FOR DELETE
AS
PRINT 'XXXX'
ROLLBACK;

drop trigger NoDelete
SELECT *
FROM Skladista


CREATE TRIGGER NemaBrisanjaProizvoda
ON Proizvodi
FOR DELETE,UPDATE
AS
PRINT 'NOO'
ROLLBACK;

DROP TRIGGER NemaBrisanjaProizvoda

DELETE FROM Proizvodi
WHERE ProizvodID=4

create table Logiraj(
ID_LOG int identity(1,1) PRIMARY KEY,
Korisnik varchar(30),
Datum datetime,
StaroIme varchar(30),
NovoIme varchar(30)
)

select *
from Logiraj

create trigger LogirajIzmjene
ON Proizvodi
AFTER UPDATE AS 
INSERT INTO Logiraj(Korisnik,Datum,StaroIme,NovoIme)
select SYSTEM_USER,SYSDATETIME(),d.Naziv,i.Naziv
from Proizvodi as P
inner join inserted as i
on i.ProizvodID=P.ProizvodID
inner join deleted as d
on d.ProizvodID=P.ProizvodID


UPDATE Proizvodi 
SET Naziv='Vanilija'
WHERE ProizvodID=6

CREATE TRIGGER BrisanjeSaStanja
ON SkladisteProizvodi
FOR DELETE as
print 'nopp'
rollback;

DELETE FROM SkladisteProizvodi
where Stanje=100

DROP trigger BrisanjeSaStanja

CREATE TRIGGER Opcenito
ON DATABASE
FOR DROP_TABLE
AS
PRINT 'ZABRANA'
ROLLBACK;

drop table Proizvodi


CREATE TABLE LogLokacija
(
LogID int identity(1,2) primary key,
StariNaziv varchar(30) ,
NoviNaziv varchar(30),
Korisnik nvarchar(40)
)
select *
from LogLokacija

CREATE TRIGGER LogLocation
ON Skladista 
AFTER UPDATE AS
INSERT INTO LogLokacija(StariNaziv,NoviNaziv,Korisnik)
SELECT d.Naziv,i.Naziv,SYSTEM_USER
FROM inserted as i
inner join deleted as d
on i.SkladisteID=d.SkladisteID

update Skladista
SET Naziv='BanjaLucko RS'
WHERE SkladisteID=6

DROP TRIGGER Prevntuj

DECLARE @Var nvarchar(50)
SET @Var=CONVERT(nvarchar,SYSDATETIME(),103)
SELECT @Var 
---------------------------------------------------------------

--ISPITNI 04.09.2018

CREATE DATABASE IB170104
GO

use IB170104

create table Autori(
AutorID nvarchar(11) CONSTRAINT PK_Autor PRIMARY KEY,
Prezime nvarchar(25) NOT NULL,
Ime nvarchar(25) not null,
Telefon nvarchar(20) DEFAULT NULL,
DatumKreiranjaZapisa date not null DEFAULT SYSDATETIME(),
DatumModifikovanjaZapisa date DEFAULT NULL
)

CREATE TABLE Izdavaci(
IzdavacID nvarchar(4) CONSTRAINT PK_Izdavac PRIMARY KEY,
Naziv nvarchar(100) not null CONSTRAINT UQ_Naziv UNIQUE,
Biljeske nvarchar(1000) DEFAULT 'Lorem ipsum',
DatumKreiranjaZapisa date not null DEFAULT SYSDATETIME(),
DatumModifikovanjaZapisa date DEFAULT NULL
)

CREATE TABLE Naslovi(
NaslovID nvarchar(6) CONSTRAINT PK_Naslov PRIMARY KEY,
IzdavacID nvarchar(4) CONSTRAINT FK_Izdavac FOREIGN KEY REFERENCES Izdavaci(IzdavacID),
Naslov nvarchar(100) not null,
Cijena money,
DatumIzdavanja date not null DEFAULT SYSDATETIME(),
DatumKreiranjaZapisa date not null Default sysdatetime(),
DatumModifikovanjaZapisa date DEFAULT NULL

)

create table NasloviAutori(
AutorID nvarchar(11),
NaslovID nvarchar(6),
DatumKreiranjaZapisa date not null DEFAULT SYSDATETIME(),
DatumModifikovanjaZapisa date DEFAULT NULL
CONSTRAINT PK_Autor_Naslov PRIMARY KEY(AutorID,NaslovID),
CONSTRAINT FK_Autor_Naslov_AutorID FOREIGN KEY(AutorID) references Autori(AutorID),
CONSTRAINT FK_Autor_Naslov_NaslovID FOREIGN KEY(NaslovID) references Naslovi(NaslovID)
)


INSERT INTO Autori(AutorID,Prezime,Ime,Telefon)
select A.au_id,A.au_lname,A.au_fname,A.phone
FROM (SELECT *
FROM pubs.dbo.authors) as A
ORDER BY NEWID()

select *
from Autori

INSERT INTO Izdavaci(IzdavacID,Naziv,Biljeske)
SELECT P.pub_id,P.pub_name,LEFT(CONVERT(VARCHAR,Pinf.pr_info),100)
FROM pubs.dbo.publishers as P
INNER JOIN(select pub_info.pr_info,pub_info.pub_id
from pubs.dbo.pub_info)Pinf
ON P.pub_id=Pinf.pub_id
order by NEWID()


select *
from Izdavaci
delete from Izdavaci

INSERT INTO Naslovi(NaslovID,IzdavacID,Naslov,Cijena,DatumIzdavanja)
SELECT T.title_id,T.pub_id,T.title,T.price,T.pubdate
FROM (SELECT title_id,pub_id,title,price,pubdate
FROM pubs.dbo.titles)AS T

INSERT INTO NasloviAutori(AutorID,NaslovID)
SELECT TA.au_id,TA.title_id
FROM (SELECT *
FROM pubs.dbo.titleauthor 
)TA

SELECT  *
FROM NasloviAutori

CREATE TABLE Gradovi(
GradID int identity(5,5) PRIMARY KEY,
Naziv nvarchar(100) NOT NULL CONSTRAINT UQ_NazivGrada UNIQUE,
DatumKreiranjaZapisa date not null DEFAULT SYSDATETIME(),
DatumModifikovanjaZapisa date DEFAULT NULL,
)

Insert INTO Gradovi(Naziv)
select G.city
from (SELECT distinct city
FROM pubs.dbo.authors)as G

SELECT *
FROM Gradovi

ALTER TABLE Autori
ADD GradID int CONSTRAINT FK_Grad foreign key references Gradovi(GradID)

alter PROC Modif1
as
begin 
UPDATE top (10) Autori
SET GradID=(SELECT G.GradID FROM Gradovi as G  WHERE Naziv='San Francisco')
end

EXEC Modif1

CREATE PROC Modif2
AS
BEGIN
UPDATE Autori
SET GradID=(SELECT G.GradID FROM Gradovi as G WHERE Naziv like 'Berkeley')
WHERE GradID IS NULL
END
EXEC Modif2


USE IB170104
GO

create view v_Prvi
AS
SELECT A.Ime+A.Prezime AutorImePrezime,N.Naslov Naslov,G.Naziv Grad,I.Naziv Izdavac,I.Biljeske
FROM Autori as A
inner join NasloviAutori as NA
on NA.AutorID=A.AutorID
inner join Naslovi as N
on N.NaslovID=NA.NaslovID
inner join Izdavaci as I
on I.IzdavacID=N.IzdavacID
inner join Gradovi as G
on G.GradID=A.GradID
where N.Cijena IS NOT NULL and N.Cijena>10 and I.Naziv LIKE '%&%' AND G.Naziv LIKE 'San Francisco'


SELECT *
FROM Izdavaci


ALTER TABLE Autori
ADD Email nvarchar(100) DEFAULT NULL

CREATE PROC Email1
AS
BEGIN
UPDATE Autori
SET Email=Ime+'.'+Prezime+'@fit.ba'
where GradID=(SELECT G.GradID FROM Gradovi as G WHERE G.Naziv LIKE 'San Francisco')
END
EXEC Email1

CREATE PROC Email2
AS
BEGIN
UPDATE Autori
SET Email=Prezime+'.'+Ime+'@fit.ba'
where GradID=(SELECT G.GradID FROM Gradovi as G WHERE G.Naziv LIKE 'Berkeley')
END
EXEC Email2

create table #TempTablee(
PersonID int constraint FK_Personn PRIMARY KEY,
Title nvarchar(8),
LastName nvarchar(100),
FirstName nvarchar(100),
Email nvarchar(100),
Username nvarchar(200),
Password nvarchar(16)
)

INSERT INTO #TempTablee(PersonID,Title,LastName,FirstName,Email,Username,Password)
SELECT P.BusinessEntityID,P.Title,P.LastName,P.FirstName,PE.EmailAddress,P.FirstName+'.'+P.LastName,replace(lower(LEFT(NEWID(),16)),'-','7')
FROM AdventureWorks2014.Person.Person P
INNER JOIN (SELECT * FROM AdventureWorks2014.Person.EmailAddress )PE
ON PE.BusinessEntityID=P.BusinessEntityID
INNER JOIN AdventureWorks2014.Person.PersonPhone AS pp
on pp.BusinessEntityID=PE.BusinessEntityID

select LOWER(REPLACE(LEFT(NEWID(),16),'-','7'))
backup database IB170104 to disk='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\iSPIT'

alter PROC ObrisiSve
as
begin
DELETE FROM NasloviAutori
DELETE FROM Autori
DELETE FROM Naslovi
DELETE FROM Gradovi
end

EXEC ObrisiSve

select *
from NasloviAutori

use IB170104
go

USE NORTHWND
GO

SELECT C.ContactName,C.OrderID
FROM (SELECT u.ContactName,r.OrderID
FROM Customers u
inner join Orders r
on u.CustomerID=r.CustomerID) as C
CREATE TABLE LogBrisanja(
LogID int identity(1,1)primary key,
Korisnik varchar(50),
OrderID int,
Freight money
)
CREATE TRIGGER LogDelete
ON Orders AFTER DELETE
AS
INSERT INTO LogBrisanja(Korisnik,OrderID,Freight)
select SYSTEM_USER,d.OrderID,d.Freight
from deleted as d

ALTER PROC ObrisiPoID
@Name nvarchar(50)
as
begin
delete from [Order Details] 
FROM [Order Details] as OD
where OD.OrderID IN (SELECT O.OrderID FROM Orders O INNER JOIN Customers as C on O.CustomerID=C.CustomerID WHERE C.ContactName LIKE @Name)

DELETE From Orders
FROM Orders as O
inner join Customers as C
on O.CustomerID=C.CustomerID
WHERE C.ContactName LIKE @Name
end


EXEC ObrisiPoID 'Maria Anders'


select o.CustomerID,OD.OrderID
from Orders o
inner join [Order Details] OD
on OD.OrderID=o.OrderID
where o.CustomerID=(select C.CustomerID from Customers as C WHERE C.ContactName like 'Maria Anders')


select *
from Customers
SELECT *
FROM LogBrisanja

-------------------------------------------------------------------------------------------------------------
--ISPITNI 05.09.2016

CREATE DATABASE IB170
GO

USE IB170
GO

create table Klijenti(
KlijentID int identity(1,1) CONSTRAINT PK_Klijent PRIMARY KEY,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null,
Telefon nvarchar(20) not null,
Mail nvarchar(50) not null CONSTRAINT UQ_Mail UNIQUE,
BrojRacuna nvarchar(15) not null,
KorisnickoIme nvarchar(20) not null,
Lozinka nvarchar(20) not null
)
ALTER TABLE Klijenti
ALTER COLUMN KorisnickoIme nvarchar(50) not null

CREATE TABLE Transakcije(
TransakcijaID int identity(1,1) CONSTRAINT PK_Transakcija PRIMARY KEY,
Datum datetime not null,
TipTransakcije nvarchar(30) not null,
PosiljalacID int not null,
PrimalacID int not null,
Svrha nvarchar(50) not null,
Iznos decimal not null,
CONSTRAINT FK_Posiljalac FOREIGN KEY(PosiljalacID) references Klijenti(KlijentID) ON DELETE CASCADE,
CONSTRAINT FK_Primalac FOREIGN KEY(PrimalacID) REFERENCES Klijenti(KlijentID)
)

insert into Klijenti(Ime,Prezime,Telefon,Mail,BrojRacuna,KorisnickoIme,Lozinka)
SELECT P.FirstName,P.LastName,Ph.PhoneNumber,E.EmailAddress,C.AccountNumber,P.FirstName+'.'+P.LastName,
RIGHT(Pw.PasswordHash,8)
FROM AdventureWorks2014.Sales.Customer as C
inner join AdventureWorks2014.Person.Person as P
on C.PersonID=P.BusinessEntityID
inner join AdventureWorks2014.Person.PersonPhone as Ph
on Ph.BusinessEntityID=P.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress AS E
on E.BusinessEntityID=Ph.BusinessEntityID
inner join AdventureWorks2014.Person.Password as Pw
on Pw.BusinessEntityID=E.BusinessEntityID

select *
from Klijenti

INSERT INTO Transakcije(Datum,TipTransakcije,PosiljalacID,PrimalacID,Svrha,Iznos)
values(SYSDATETIME(),'Uplata',121,125,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',121,129,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',121,143,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',121,124,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',121,123,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',121,125,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',121,128,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',129,133,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',122,156,'Stipendija',456.50),
(SYSDATETIME(),'Uplata',124,154,'Stipendija',456.50)

CREATE NONCLUSTERED INDEX IX_Klijenti ON Klijenti(Ime,Prezime)INCLUDE(BrojRacuna)
ALTER INDEX IX_Klijenti ON Klijenti
DISABLE;

CREATE PROC UnosKlijenta
@Ime nvarchar(40),@Prezime nvarchar(40),@Telefon nvarchar(20),@Mail nvarchar(50),@BrojRacuna nvarchar(15),@KorisnickoIme nvarchar(20),@Lozinka nvarchar(20)
as
INSERT INTO Klijenti(Ime,Prezime,Telefon,Mail,BrojRacuna,KorisnickoIme,Lozinka)
VALUES(@Ime,@Prezime,@Telefon,@Mail,@BrojRacuna,@KorisnickoIme,@Lozinka)

EXEC UnosKlijenta 'Nihad','Hrustić','06111104','nihad@fit.ba','14004000202','nixi','nema$ifr3'

alter VIEW v_Informacije
as
SELECT T.TransakcijaID,T.Datum,T.TipTransakcije,K1.Ime Posiljaoc,K1.BrojRacuna PosiljaocBrojRacuna,K2.Ime Primalac,K2.BrojRacuna PrimalacBrojRacuna,T.Iznos,T.Svrha
FROM Transakcije T
inner join Klijenti as K1
on K1.KlijentID=T.PosiljalacID
inner join Klijenti as K2
on K2.KlijentID=T.PrimalacID

SELECT *  FROM v_Informacije


CREATE PROC RacunInfo
@BrojRacuna nvarchar(15)
as
begin
select I.TransakcijaID,I.TipTransakcije,I.Svrha,I.Datum,I.Iznos
from v_Informacije I
where I.PosiljaocBrojRacuna like @BrojRacuna
end


EXEC RacunInfo 'AW00029484'

SELECT YEAR(T.Datum)Godina,SUM(T.Iznos)Ukupno
FROM Transakcije as T
GROUP BY YEAR(T.Datum)
ORDER BY YEAR(T.Datum) asc

CREATE PROC Brisi
@KlijentID int 
as
begin

DELETE FROM Transakcije
FROM Transakcije as T
inner join Klijenti as K1
on K1.KlijentID=T.PosiljalacID
inner join Klijenti as K2
on K2.KlijentID=T.PrimalacID
WHERE K1.KlijentID=@KlijentID or K2.KlijentID=@KlijentID

DELETE FROM Klijenti
where KlijentID=@KlijentID

end

SELECT *
FROM Klijenti

SELECT *
FROM Transakcije
EXEC Brisi 122

alter PROC Pretraga
@BrojRacuna nvarchar(15)='%',@Prezime nvarchar(30)='%'
as
begin
SELECT V.Datum,V.Posiljaoc,V.Svrha
FROM v_Informacije as V
INNER join Klijenti as K
on V.PrimalacBrojRacuna=K.BrojRacuna
where V.PosiljaocBrojRacuna=@BrojRacuna and  K.Prezime LIKE @Prezime
end

select *
from Klijenti

EXEC Pretraga 'Achong'

BACKUP DATABASE IB170 TO DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\IB170.bak'

BACKUP DATABASE IB170 TO DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL\MSSQL\Backup\IB170.bak' WITH DIFFERENTIAL