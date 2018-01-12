USE sq_jiayouzhan
GO
/****** Object:  Function dbo.GetDistance    Script Date: 02/25/2013 10:07:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'GetDistance')
BEGIN
    DROP FUNCTION GetDistance
END
GO

CREATE FUNCTION dbo.GetDistance (@lng1 float,@lat1 float,@lng2 float,@lat2 float)
RETURNS float 
WITH EXECUTE AS CALLER
AS
BEGIN

     DECLARE @s float  
   DECLARE @radLat1  float;
   DECLARE @radLat2 float ;
   DECLARE @radLng1 float;
   DECLARE @radLng2 float ;
   DECLARE @a float;
   DECLARE @b float;
   DECLARE @EARTH_RADIUS float ;
   set @EARTH_RADIUS = 6378.137;
   
   set @radLat1 = @lat1 * PI() / 180.0;
   set @radLat2 = @lat2 * PI() / 180.0;
   set @radLng1 = @lng1 * PI() / 180.0;
   set @radLng2 = @lng2 * PI() / 180.0;
   set @a = @radLat1 - @radLat2;
   set @b = @radLng1 - @radLng2;
   
   set @s = 2 * Asin(Sqrt(POWER(Sin(@a/2),2) + Cos(@radLat1) * Cos(@radLat2) * power(Sin(@b/2),2)));
   set @s = @s * @EARTH_RADIUS;
  -- set @s = Round(@s * 10000) / 10000;
   return (@s);
END;
GO
