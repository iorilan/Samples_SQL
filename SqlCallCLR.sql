ALTER DATABASE TestDb SET TRUSTWORTHY ON
GO


--enable clr 
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO


---------------------------------

-- if exists assembly ,remove 
declare @assemName varchar(50);
set @assemName = 'ManagedCodeAndSqlServer';
declare @assemPath varchar(200);
set @assemPath = 'D:\xxxx\xxxx.dll';
--above is your assembly directory 

if exists(select * from sys.assemblies where name = @assemName)
begin 
drop assembly ManagedCodeAndSqlServer --replace with the correct assembly name
--WITH PERMISSION_SET = UNSAFE
--GO
end

-----------------------------------------

--add assembly 
CREATE ASSEMBLY ManagedCodeAndSqlServer
--AUTHORIZATION dbo
FROM @assemPath

--if exists sp ,remove 
declare @spName varchar(50);
set @spName = 'usp_UseHelloDotNetAssembly';


if exists(select * from sys.procedures where name = @spName)
begin
drop procedure usp_UseHelloDotNetAssembly
end

------------------------------------------

--create procedure again 
CREATE PROCEDURE usp_UseHelloDotNetAssembly
@name nvarchar(200),
@msg nvarchar(MAX) OUTPUT

--assemblyName.[namespace.class].Method

AS EXTERNAL NAME ManagedCodeAndSQLServer.[ManagedCodeAndSqlServer.BaseFunctionClass].GetMessage
GO


DECLARE @msg varchar(MAX)
EXEC usp_UseHelloDotNetAssembly 'this msg from sql server ',@msg output
select @msg