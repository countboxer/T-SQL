--**********--
-- Calculate and print the time difference between two dates

--5 days, 13 hrs, 29 mins

-- Declare working variables
DECLARE @duration nvarchar(50)
DECLARE @minDiff int, @hourDiff int, @dayDiff int
DECLARE @minString nvarchar(50), @hourString nvarchar(50), @dayString nvarchar(50)

-- Calculate day, hour and minute differences
SELECT @minDiff = DATEDIFF(MINUTE,'2018-01-13 12:37:28.737','2018-01-19 02:06:39.147')
SELECT @hourDiff = @minDiff / 60
SELECT @dayDiff = @hourDiff / 24

SELECT @minDiff = @minDiff - (@hourDiff * 60)
SELECT @hourDiff = @hourDiff - (@dayDiff * 24)

-- Cast differences as strings for printing purposes
SELECT @minString = cast(@minDiff as nvarchar(50)), @hourString = cast(@hourDiff as nvarchar(50)), @dayString = cast(@dayDiff as nvarchar(50))

-- Build and print the time difference
EXEC xp_sprintf @duration OUTPUT, '%s days, %s hours, %s minutes', @dayString, @hourString, @minString
SELECT @duration as 'Duration'

--**********--
-- Code to return quarter end dates
DECLARE @val	NVARCHAR(MAX);

WITH PriorQuarterEnds(Date_Value, Next_EOQ, Previous_EOQ, D_Level) AS
(
    SELECT
        date_value,
        eoq_after_date_value,
        prior_eoq_date,
        0 as D_Level
    FROM
        DateDim
    WHERE
        date_value = Convert(date, getdate())
    UNION ALL  
    SELECT
        d.date_value,
        d.eoq_after_date_value,
        d.prior_eoq_date,
        D_Level + 1
    FROM
        DateDim d
        INNER JOIN PriorQuarterEnds e ON e.Previous_EOQ = d.date_value
)

SELECT TOP 4
    LEFT(CONVERT(VARCHAR, Next_EOQ, 120),10) as Next_EOQ
INTO
    #tempT
FROM
    PriorQuarterEnds
WHERE
    D_Level != 0

SELECT TOP 4 @val = COALESCE(@val + ', ' + Next_EOQ, Next_EOQ) FROM #tempT
SELECT @val;

--**********--
-- Code to test the try/catch process

DROP TABLE IF EXISTS #temp

CREATE TABLE #temp
(
    id INT NOT NULL,
    [name] VARCHAR (255) NOT NULL,
    weight INT NOT NULL,
    turn INT NOT NULL
)

INSERT INTO #temp VALUES
    (1, 'Mickey Mouse', 12, 1),(2, 'Donald Duck', 23, 2),(3, 'Goofy', 34, 2),(4, 'Pluto', 45, 3)

SELECT * FROM #temp

SELECT
    @@ERROR AS '@@ERROR'
    ,@@ROWCOUNT AS '@@ROWCOUNT'
    ,@@SERVERNAME AS '@@SERVERNAME'
    ,@@VERSION AS '@@VERSION'

BEGIN TRY  
    -- Generate a divide-by-zero error.  
    SELECT 1/0;  
END TRY  
BEGIN CATCH  
    SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage;  
END CATCH;

SELECT * FROM master.dbo.sysmessages WHERE error = 8134
SELECT * FROM master.dbo.syslanguages WHERE langid IN (0,6)

--**********--
-- Executing a T-SQL batch multiple times using GO

CREATE TABLE dbo.TEST (ID INT IDENTITY (1,1), ROWID uniqueidentifier) 
GO 
INSERT INTO dbo.TEST (ROWID) VALUES (NEWID())  
--GO 1000 -- This may be incorrect syntax

--**********--
-- Dropping a table using IF EXISTS

--Applies to: SQL Server ( SQL Server 2016 (13.x) through current version).

--The following example creates a table named T1.
--Then the second statement drops the table.
--The third statement performs no action because the table is already deleted, however it does not cause an error.

CREATE TABLE T1 (Col1 int);  
GO  
DROP TABLE IF EXISTS T1;  
GO  
DROP TABLE IF EXISTS T1;  
GO

--**********--
-- Return all records or a subset depending on a parameter

CREATE PROCEDURE dbo.sp_CRTest_with_parameters
(
	@fund_family_name varchar(50) = NULL
)
AS
	DECLARE @qe_dates	varchar(max)
	SET @qe_dates = dbo.uf_GetPriorQuarterEnds(GetDate(), 5)

    BEGIN
		SELECT
			fund_family_name,
			fund_name,
			product_high_level,
			line,
			eoq_after_date_value,
			net_assets,
			net_flow,
			quarter_name
		FROM
			FundsManagementWarehouse.dbo.v_MergedDetailMonthlyFact_Trees v_MergedDetailMonthlyFact_Trees
		WHERE
			product_code = product_tree_node_name AND
			COALESCE(fund_family_name,'') LIKE CASE WHEN @fund_family_name IS NULL THEN '%' ELSE @fund_family_name END AND
			CHARINDEX(convert(varchar, eoq_after_date_value, 20), @qe_dates) > 0
    END