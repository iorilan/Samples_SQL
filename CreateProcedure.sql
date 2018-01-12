USE dbName
GO
/****** Object:  StoredProcedure dbo.QueryGasListByGasId    Script Date: 02/25/2013 10:07:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'QueryStationListByGasId')
BEGIN
    DROP PROCEDURE QueryStationListByGasId
END
GO


CREATE PROC QueryStationListByGasId(
    @gasId int,
	@topN int
    )
AS 
BEGIN
	SET NOCOUNT ON 


SELECT TOP (@topN) gs.Id as StationId , gs.StationName , g.GasName ,sd.StationAddress, sgm.Price FROM GasStation gs 
JOIN StationDetails sd on sd.StationFK = gs.Id 
JOIN StationGasMapping sgm on sgm.StationFK = gs.Id
JOIN Gas g on g.Id = sgm.GasFK 

WHERE sgm.GasFK =@gasId 
 ORDER BY sgm.Price;

END