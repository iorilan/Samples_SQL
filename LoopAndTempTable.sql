
--sample of using loop and temp table


BEGIN
DECLARE @FrmMstId UNIQUEIDENTIFIER
set @FrmMstId ='0E38D831-AC9D-4DEC-9422-11998A834269'

DECLARE  @FieldsDataTable TABLE
(
		SetID	int,
		FieldName varchar(200),
		Value varchar(max)
)

DECLARE @SetID AS	int = 1
DECLARE @Item AS nvarchar(20)
DECLARE @Matter AS nvarchar(200)
DECLARE @CostClaimed AS float = 0
DECLARE @IsAgree AS int = 0
DECLARE @ProposedAmt AS float = 0
DECLARE @BocBreakdown AS nvarchar(200)
--fetch boc item
IF Object_id('tempdb..#T1') IS NOT NULL
  DROP TABLE #T1
  
SELECT fbi.Id ,bi.Item,
	bi.Matter ,fbi.CostClaimed,fbi.IsAgree,fbi.ProposedAmt
	INTO #T1
	FROM CM.FrmMst fm 
	JOIN HM.FrmBoc fb ON fm.Id = fb.FrmMstFK
	JOIN HM.FrmBocItem fbi ON fbi.FrmBocFK = fb.Id
	JOIN HM.BocItem bi ON bi.Id = fbi.BocItemFK
	WHERE fm.Id = @FrmMstId AND 
	(bi.ExpiryDate > getdate() AND bi.effectiveDate <= getdate())
	AND fb.DeletedBy IS NULL 
	
	ORDER BY CASE
    WHEN IsNumeric(bi.Item) = 1 THEN Right('0000000000' + bi.Item + '0', 10)
    ELSE Right('0000000000' + bi.Item, 10)
    END

--process 
DECLARE @FrmBocItemId AS UNIQUEIDENTIFIER

WHILE (SELECT Count(*) FROM #T1) > 0
BEGIN

    SELECT TOP 1 
    @FrmBocItemId = Id,
    @Item = Item,
    @Matter = Matter,
    @CostClaimed = CostClaimed,
    @IsAgree = IsAgree,
    @ProposedAmt = ProposedAmt
	FROM #T1
	
	INSERT INTO @FieldsDataTable values(@SetID, 'Item',ISNULL(@Item,''));
	INSERT INTO @FieldsDataTable values(NULL, 'Matter',ISNULL(@Matter,''));
	INSERT INTO @FieldsDataTable values(NULL, 'CostClaimed',@CostClaimed);
	INSERT INTO @FieldsDataTable values(NULL, 'IsAgree',isNULL(@IsAgree,0));
	INSERT INTO @FieldsDataTable values(NULL, 'Proposed Amount',isNULL(@ProposedAmt,0));
	

--process break down data

	--step 1: check temp table is not exist
	IF Object_id('tempdb..#T2') IS NOT NULL
	DROP TABLE #T2
	
	--step 2:fetch data into temp table
	DECLARE @BreakdownId uniqueidentifier;
	SELECT Id,BocItemBreakdownDesc INTO #T2 FROM HM.FrmBocItemBreakdown WHERE FrmBocItemFK = @FrmBocItemId;
	
	--step 3:loop fetch data
	WHILE (SELECT Count(*) FROM #T2) > 0
	BEGIN
	SELECT TOP 1 @BreakdownId = Id,@BocBreakdown = BocItemBreakdownDesc FROM #T2
	
	INSERT INTO @FieldsDataTable values(NULL, '',ISNULL(@BocBreakdown,''));
	DELETE #T2 WHERE Id = @BreakdownId
	END

SET @SetID = @SetID + 1;

DELETE #T1 WHERE Id = @FrmBocItemId
END



END
