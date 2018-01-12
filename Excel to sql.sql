导入excel到表

SET @RosterFile ='YOUR FILE NAME';

---Clear data and import records from Txt File
DELETE FROM ROSTER WHERE CreatedAt <= DATEADD (day , -7 , GETDATE() )
TRUNCATE TABLE RosterTemp

DECLARE @sql NVARCHAR(4000) = 'BULK INSERT {your_table} FROM ''' + @RosterFile + ''' WITH ( FIELDTERMINATOR ='';'', ROWTERMINATOR =''\n'' )';
EXEC(@sql);