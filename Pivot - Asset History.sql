-- Sum the last five quarters of net assets with dynamic column headings

DECLARE @eoq_dates          NVARCHAR(MAX)
DECLARE @fund_family_name   NVARCHAR(50) = 'American Funds'
DECLARE @query              NVARCHAR(MAX)

SELECT TOP 5
	@eoq_dates = COALESCE(@eoq_dates + ', ','') + '[' + CONVERT(NVARCHAR, date_value, 101) + ']'
FROM
	FundsManagementWarehouse.dbo.DateDim
WHERE
	date_is_eoq_flag = 'Y'
	AND date_value <= GetDate()
ORDER BY
	date_value DESC
--SELECT @eoq_dates

SET @query = 
'SELECT *
FROM
(
	SELECT
		mft.fund_family_name, mft.fund_name, mft.product_high_level, mft.line, mft.date_value, mft.net_assets, mft.source_name
	FROM
		FundsManagementWarehouse.dbo.v_MergedDetailMonthlyFact_Trees	mft
) AS src
PIVOT
(
	SUM(src.net_assets)
	FOR src.date_value in (' + @eoq_dates + ')
) AS pvt
WHERE
	source_name in (''Alliance'',''Consolidated'') AND
	line is not null AND
	fund_family_name = ''' + @fund_family_name + '''
ORDER BY
	line,
	product_high_level,
	fund_name'
--SELECT @query

EXECUTE(@query)