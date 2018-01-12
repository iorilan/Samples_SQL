--1.ISNULL() function 

select ISNULL(AgentCode,'-') as AgentCode from cm.FrmAddressForService order by CreatedDate desc;
--comment : if agentcode is null  then replace by '-'

--2.assigned value from a query 

  DECLARE @FrmAddressFK UNIQUEIDENTIFIER
  SELECT @FrmAddressFK = [CM].[vwFrmAddressForService].[FrmAddressFK]
  FROM   [CM].[vwFrmAddressForService]
  WHERE [CM].[vwFrmAddressForService].[FrmMstFK] = @FrmMstId

--3. nested select query,and where condition also can be a select query :


DECLARE @ID UNIQUEIDENTIFIER

SELECT 
  FAFS.[Id] AS FAddressForServiceID
      ,FAFS.[AgentCode]
      ,FAFS.[AgentName]
      ,FAFS.[XAgentFirm] 
      ,FAFS.[RepresentativeName]
      ,FA.[Id] AS FrmAddressID
      ,FA.[AddressTypeCode] 
      ,(SELECT CodeDesc FROM [CM].[fnGetCodeDescByID](FA.AddressTypeCode)) AS CodeDesc
      ,FA.[POBoxNbr] 
      ,FA.[PostalCode]
      ,FA.[BlockHouseNbr]
      ,FA.[StreetName]
      ,FA.[Level]
      ,FA.[Unit]
      ,FA.[BuildingName]
      ,FA.[Address1] 
      ,FA.[Address2] 
      ,FA.[Address3] 
      ,FAFS.[ContactPerson]
      ,FAFS.[ContactNbr]
      ,FAFS.[ContactEmail]
      --,(SELECT * FROM [CM].[fnGetCodeByGUID](FA.[AddressTypeCode]))
      --@ID=FA.[AddressTypeCode]
  FROM [CM].[vwFrmAddress] AS FA
  INNER JOIN [CM].[vwFrmAddressForService] AS FAFS
  ON FA.[Id] =FAFS.[FrmAddressFK]
  INNER JOIN [CM].[vwFrmMst] AS FM
  ON FM.[Id]=FAFS.[FrmMstFK]
  WHERE FM.[Id]=(SELECT [Id] FROM [CM].[vwFrmMst] 
             WHERE  [EfileRefNbr]=@EfileRefNbr)

--4. use newId() to get a GUID

--5. order by newId() can be good used to generate random records

SELECT TOP 100 * 
FROM master.spt_values 
ORDER BY NEWID()


--6.case when then else example

 SELECT 
[Id] AS FrmDeclarationId
,[FrmMstFK] AS FrmMstFK
,(CASE WHEN @DeclarationDesc = 'APP' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END) AS IsApplicantOrProprietor
,(CASE WHEN @DeclarationDesc = 'AGN' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END) AS IsAgent
    FROM 
[CM].[vwFrmDeclaration]


--7.return row number by using row_number() over(orderby ...). example:


select  * ,ROW_NUMBER() over(order by BuildingName) from cm.FrmAddress ;


--or 


select  * ,ROW_NUMBER() over(order by (select 1)) from cm.FrmAddress ;--random sequence 


--8.while loop , char index ,left,right


 BEGIN         
            WHILE CHARINDEX(',',@RoleId)>0         
                  BEGIN    
                        SET @rolltID=LEFT(@RoleId,CHARINDEX(',',@RoleId)-1)      
                        SET @RoleId=RIGHT(@RoleId,LEN(@RoleId)-CHARINDEX(',',@RoleId))                 
                        INSERT INTO @tmpRollId (uniqId) SELECT @rolltID         
                  END
      END
      IF len(@RoleId)>0
            BEGIN
                  INSERT INTO @tmpRollId (uniqId) SELECT @RoleId         
            END


--9.dynamic exec sql 


declare @sql varchar(200)
set @sql = 'select  BuildingName ,ROW_NUMBER() over(order by (BuildingName) desc) from cm.FrmAddress ';
exec(@sql);


--10.temp table :
  
 select top 10 * into #temp from cm.FrmAddress order by CreatedDate;
 select * from #temp;
 drop table #temp;--remember to drop temp table


--11.in/not in


SELECT * 
 FROM [CM].[vwCodeTable] 
 WHERE CodeType = 'PaymentModestatus' 
 AND Code not IN ('PDC','PDG')


--12.date compare


declare @rlt int;
set @rlt = (select DATEDIFF(DAY,'2012-1-1','2013-1-2')) ;


select case when @rlt > 0 then 'larger' else 'smaller' end;

--13.use row over and partition by 

USE AdventureWorks2012;
GO
SELECT FirstName, LastName, TerritoryName, ROUND(SalesYTD,2,1),
ROW_NUMBER() OVER(PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS Row
FROM Sales.vSalesPerson
WHERE TerritoryName IS NOT NULL AND SalesYTD <> 0
ORDER BY TerritoryName;

--Here is the result set.

--FirstName  LastName             TerritoryName        SalesYTD      Row
---------  -------------------- ------------------   ------------  ---
--Lynn       Tsoflias             Australia            1421810.92    1
--José       Saraiva              Canada               2604540.71    1
--Garrett    Vargas               Canada               1453719.46    2
--Jillian    Carson               Central              3189418.36    1
--Ranjit     Varkey Chudukatil    France               3121616.32    1
--Rachel     Valdez               Germany              1827066.71    1
--Michael    Blythe               Northeast            3763178.17    1
--Tete       Mensa-Annan          Northwest            1576562.19    1
--David      Campbell             Northwest            1573012.93    2
--Pamela     Ansman-Wolfe         Northwest            1352577.13    3

--14.one case can has multiple classes 
--case : class = 1:n
--find out the case number which has only one class.

select * from hm.[Class] where CaseFK in
(select CaseFK clsCount from hm.[Class] group by CaseFK having count(ClassNbr) < 2 )


--15 case when then order by 1,2,2A,1A such rows

DECLARE @TBL TABLE(
VAL NVARCHAR(20)
)
INSERT INTO @TBL VALUES('1A');
INSERT INTO @TBL VALUES('2A');
INSERT INTO @TBL VALUES('1');
INSERT INTO @TBL VALUES('a2');
INSERT INTO @TBL VALUES('33');
INSERT INTO @TBL VALUES('3C');
INSERT INTO @TBL VALUES('2');

SELECT VAL,CASE WHEN IsNumeric(VAL) = 1 THEN Right('0000000000' + VAL + '0', 10)
    ELSE Right('0000000000' + VAL, 10)
    END AS V1 FROM @TBL
ORDER BY CASE
    WHEN IsNumeric(VAL) = 1 THEN Right('0000000000' + VAL + '0', 10)
    ELSE Right('0000000000' + VAL, 10)
    END 


--16 check temp table if exist then delete 
-- v1 :
IF Object_id('tempdb..#TempRevenue_GM') IS NOT NULL
  DROP TABLE #TempRevenue_GM

-- v2 :
if exists (
		select  * from tempdb.dbo.sysobjects o (nolock)
		where o.xtype in ('U')  
		and o.id = object_id(N'tempdb..#XXX')
	) begin
		drop table #XXX;
	end
	create table #XXX (
		...
	)
