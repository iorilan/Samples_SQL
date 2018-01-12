use sq_jiayouzhan
go

--create table dbo.GasStation

IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_NAME = 'GasStation')
   DROP TABLE dbo.GasStation
GO
CREATE TABLE dbo.GasStation
(
 Id int IDENTITY(1,1),
 StationName nvarchar (50) not null,
 StationDesc nvarchar(200)
)

