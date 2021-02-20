DECLARE
	@firstDayOfYear				datetime,
	@monthEndDate				datetime,
	@parameterProcessingDate	datetime = '12/31/9999'

IF (@parameterProcessingDate = '12/31/9999')
	BEGIN	-- using the date from process date table
		SELECT
			@monthEndDate = a.prev_mo_last_clndr_day_date,
			@firstDayOfYear = '01/01/' + Substring(Convert(varchar(10),a.prev_mo_last_clndr_day_date,101),7,4)
		FROM
			CommonDb.dbo.ProcessDatesTbl a
	END
ELSE
	BEGIN	-- using the parameter date
		SELECT
			@monthEndDate = @parameterProcessingDate,
			@firstDayOfYear = '01/01/' + Substring(Convert(varchar(10),@parameterProcessingDate,101),7,4)
		FROM
			CommonDb.dbo.ProcessDatesTbl a
	END;

WITH
	product_category as
	(
		SELECT DISTINCT
			mft.FundFamily as 'fund_family_name',
			mft.ProductHighLevel as 'product_high_level',
			Category =
				CASE mft.ProductHighLevel
					WHEN 'Choice Plus'			THEN 'Choice Plus'
					WHEN 'Investor Advantage'	THEN 'Investor Advantage'
					WHEN 'Legacy'				THEN 'Legacy'
					WHEN 'Director'				THEN 'Retirement'
					WHEN 'GVA'					THEN 'Retirement'
					WHEN 'Multifund'			THEN 'Retirement'
					WHEN 'Alliance'				THEN 'Retirement'
					WHEN 'BOLI'					THEN 'Life'
					WHEN 'COLI'					THEN 'Life'
					WHEN 'Life'					THEN 'Life'
					WHEN 'Fund of Funds'		THEN 'Fund of Funds'
					ELSE 'Other'
				END
		FROM
			FundsManagementWarehouse.dbo.v_FundData_With_FOF mft
		WHERE
			mft.FundFamily IS NOT NULL AND
			mft.ProductHighLevel IS NOT NULL AND
			mft.ProductHighLevel != 'Lincoln Stable Value' AND
			mft.MonthEndDate BETWEEN @firstDayOfYear AND @monthEndDate
	),
	product_category_group_with_LVIP_FOF_Flag_equal_N as
	(
		SELECT
			mft.FundFamily as 'fund_family_name',
			col1_name	= CASE WHEN prc.Category = 'Choice Plus'		THEN 'Choice Plus' END,
			col1_value	= CASE WHEN prc.Category = 'Choice Plus'		THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col2_name	= CASE WHEN prc.Category = 'Investor Advantage'	THEN 'Investor Advantage' END,
			col2_value	= CASE WHEN prc.Category = 'Investor Advantage'	THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col3_name	= CASE WHEN prc.Category = 'Legacy'				THEN 'Legacy' END,
			col3_value	= CASE WHEN prc.Category = 'Legacy'				THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col4_name	= CASE WHEN prc.Category = 'Retirement'			THEN 'Retirement' END,
			col4_value	= CASE WHEN prc.Category = 'Retirement'			THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col5_name	= CASE WHEN prc.Category = 'Fund of Funds'		THEN 'Fund of Funds' END,
			col5_value	= CASE WHEN prc.Category = 'Fund of Funds'		THEN sum(mft.NetFlow_FOF/1000000)	ELSE 0 END,
			col6_name	= CASE WHEN prc.Category = 'Life'				THEN 'Life' END,
			col6_value	= CASE WHEN prc.Category = 'Life'				THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col7_name	= CASE WHEN prc.Category = 'Other'				THEN 'Other' END,
			col7_value	= CASE WHEN prc.Category = 'Other'				THEN sum(mft.NetFlow/1000000)		ELSE 0 END
		FROM
			FundsManagementWarehouse.dbo.v_FundData_With_FOF mft
			INNER JOIN product_category prc ON mft.FundFamily = prc.fund_family_name AND mft.ProductHighLevel = prc.product_high_level
		WHERE
			mft.MonthEndDate BETWEEN @firstDayOfYear AND @monthEndDate
			AND mft.LVIP_FOF_Flag = 'N'
		GROUP BY
			mft.FundFamily,
			prc.Category
	),
	product_category_group_with_LVIP_FOF_Flag_equal_Y as
	(
		SELECT
			mft.FundFamily as 'fund_family_name',
			col1_name	= CASE WHEN prc.Category = 'Choice Plus'		THEN 'Choice Plus' END,
			col1_value	= CASE WHEN prc.Category = 'Choice Plus'		THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col2_name	= CASE WHEN prc.Category = 'Investor Advantage'	THEN 'Investor Advantage' END,
			col2_value	= CASE WHEN prc.Category = 'Investor Advantage'	THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col3_name	= CASE WHEN prc.Category = 'Legacy'				THEN 'Legacy' END,
			col3_value	= CASE WHEN prc.Category = 'Legacy'				THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col4_name	= CASE WHEN prc.Category = 'Retirement'			THEN 'Retirement' END,
			col4_value	= CASE WHEN prc.Category = 'Retirement'			THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col5_name	= CASE WHEN prc.Category = 'Fund of Funds'		THEN 'Fund of Funds' END,
			col5_value	= CASE WHEN prc.Category = 'Fund of Funds'		THEN sum(mft.NetFlow_FOF/1000000)	ELSE 0 END,
			col6_name	= CASE WHEN prc.Category = 'Life'				THEN 'Life' END,
			col6_value	= CASE WHEN prc.Category = 'Life'				THEN sum(mft.NetFlow/1000000)		ELSE 0 END,
			col7_name	= CASE WHEN prc.Category = 'Other'				THEN 'Other' END,
			col7_value	= CASE WHEN prc.Category = 'Other'				THEN sum(mft.NetFlow/1000000)		ELSE 0 END
		FROM
			FundsManagementWarehouse.dbo.v_FundData_With_FOF mft
			INNER JOIN product_category prc ON mft.FundFamily = prc.fund_family_name AND mft.ProductHighLevel = prc.product_high_level
		WHERE
			mft.MonthEndDate BETWEEN @firstDayOfYear AND @monthEndDate
			AND mft.LVIP_FOF_Flag = 'Y'
		GROUP BY
			mft.FundFamily,
			prc.Category
	),
	fund_family_name_group_with_LVIP_FOF_Flag_equal_N as
	(
		SELECT
			ROW_NUMBER() OVER(ORDER BY abs(sum(col1_value + col2_value + col3_value + col4_value + col5_value + col6_value + col7_value)) DESC) AS row_num,
			fund_family_name,
			max(col1_name) as col1_name,
			sum(col1_value) as col1_value,
			max(col2_name) as col2_name,
			sum(col2_value) as col2_value,
			max(col3_name) as col3_name,
			sum(col3_value) as col3_value,
			max(col4_name) as col4_name,
			sum(col4_value) as col4_value,
			max(col5_name) as col5_name,
			sum(col5_value) as col5_value,
			max(col6_name) as col6_name,
			sum(col6_value) as col6_value,
			max(col7_name) as col7_name,
			sum(col7_value) as col7_value,
			sum(col1_value + col2_value + col3_value + col4_value + col5_value + col6_value + col7_value) as total_fund_family_value
		FROM
			product_category_group_with_LVIP_FOF_Flag_equal_N pcg
		GROUP BY
			pcg.fund_family_name
	),
	fund_family_name_group_with_LVIP_FOF_Flag_equal_Y as
	(
		SELECT
			ROW_NUMBER() OVER(ORDER BY sum(col1_value + col2_value + col3_value + col4_value + col5_value + col6_value + col7_value) DESC) AS row_num,
			fund_family_name,
			max(col1_name) as col1_name,
			sum(col1_value) as col1_value,
			max(col2_name) as col2_name,
			sum(col2_value) as col2_value,
			max(col3_name) as col3_name,
			sum(col3_value) as col3_value,
			max(col4_name) as col4_name,
			sum(col4_value) as col4_value,
			max(col5_name) as col5_name,
			sum(col5_value) as col5_value,
			max(col6_name) as col6_name,
			sum(col6_value) as col6_value,
			max(col7_name) as col7_name,
			sum(col7_value) as col7_value,
			sum(col1_value + col2_value + col3_value + col4_value + col5_value + col6_value + col7_value) as total_fund_family_value
		FROM
			product_category_group_with_LVIP_FOF_Flag_equal_Y pcg
		GROUP BY
			pcg.fund_family_name
	),
	calc_total_FOF_row as
	(
		SELECT
			sum(total_fund_family_value) as total_FOF_row
		FROM
			fund_family_name_group_with_LVIP_FOF_Flag_equal_Y fng
	),
	calc_total_FOF_col as
	(
		SELECT
			sum(col3_value) as total_FOF_col
		FROM
			fund_family_name_group_with_LVIP_FOF_Flag_equal_N fng
	)

SELECT
	'A' as section,
	row_num,
	fund_family_name,
	col1_name,
	Convert(NUMERIC(19,6), col1_value)						AS 'col1_value',
	col2_name,
	Convert(NUMERIC(19,6), col2_value)						AS 'col2_value',
	col3_name,
	Convert(NUMERIC(19,6), col3_value)						AS 'col3_value',
	col4_name,
	Convert(NUMERIC(19,6), col4_value)						AS 'col4_value',
	col5_name,
	Convert(NUMERIC(19,6), col5_value)						AS 'col5_value',
	col6_name,
	Convert(NUMERIC(19,6), col6_value)						AS 'col6_value',
	col7_name,
	Convert(NUMERIC(19,6), col7_value)						AS 'col7_value',
	Convert(NUMERIC(19,6), total_fund_family_value)			AS 'total_fund_family_value',
	@firstDayOfYear											AS 'firstdayofyear',
	@monthEndDate											AS 'monthenddate'
FROM
	fund_family_name_group_with_LVIP_FOF_Flag_equal_N fng
WHERE
	row_num < 40
UNION ALL
SELECT
	'D'														as section,
	'42'													as 'row_num',
	'Other'													as fund_family_name,
	max(col1_name)											as col1_name,
	Convert(NUMERIC(19,6), sum(col1_value))					as col1_value,
	max(col2_name)											as col2_name,
	Convert(NUMERIC(19,6), sum(col2_value))					as col2_value,
	max(col3_name)											as col3_name,
	Convert(NUMERIC(19,6), sum(col3_value))					as col3_value,
	max(col4_name)											as col4_name,
	Convert(NUMERIC(19,6), sum(col4_value))					as col4_value,
	max(col5_name)											as col5_name,
	Convert(NUMERIC(19,6), sum(col5_value))					as col5_value,
	max(col6_name)											as col6_name,
	Convert(NUMERIC(19,6), sum(col6_value))					as col6_value,
	max(col7_name)											as col7_name,
	Convert(NUMERIC(19,6), sum(col7_value))					as col7_value,
	Convert(NUMERIC(19,6), sum(total_fund_family_value))	as total_fund_family_value,
	@firstDayOfYear											AS 'firstdayofyear',
	@monthEndDate											AS 'monthenddate'
FROM
	fund_family_name_group_with_LVIP_FOF_Flag_equal_N fng
WHERE
	row_num > 39
UNION ALL
SELECT
	'C'														as section,
	'41'													as 'row_num',
	'Fund of Funds'											as fund_family_name,
	max(col1_name)											as col1_name,
	Convert(NUMERIC(19,6), sum(col1_value))					as col1_value,
	max(col2_name)											as col2_name,
	Convert(NUMERIC(19,6), sum(col2_value))					as col2_value,
	max(col3_name)											as col3_name,
	Convert(NUMERIC(19,6), sum(col3_value))					as col3_value,
	max(col4_name)											as col4_name,
	Convert(NUMERIC(19,6), sum(col4_value))					as col4_value,
	max(col5_name)											as col5_name,
	Convert(NUMERIC(19,6), max(ctr.total_FOF_row) * -1)		as col5_value,
	max(col6_name)											as col6_name,
	Convert(NUMERIC(19,6), sum(col6_value))					as col6_value,
	max(col7_name)											as col7_name,
	Convert(NUMERIC(19,6), sum(col7_value))					as col7_value,
	Convert(NUMERIC(19,6), sum(total_fund_family_value))	as total_fund_family_value,
	@firstDayOfYear											AS 'firstdayofyear',
	@monthEndDate											AS 'monthenddate'
FROM
	fund_family_name_group_with_LVIP_FOF_Flag_equal_Y fng
	CROSS JOIN calc_total_FOF_row ctr
UNION ALL
SELECT
	'B' as section,
	'40'									as 'row_num',
	'LIAC FOF Cash/ETFs'					as fund_family_name,
	'Choice Plus'							as col1_name,
	0										as col1_value,
	'Investor Advantage'					as col2_name,
	0										as col2_value,
	'Legacy'								as col3_name,
	0										as col3_value,
	'Retirement'							as col4_name,
	0										as col4_value,
	'Fund of Funds'							as col5_name,
	Convert(NUMERIC(19,6), ctr.total_FOF_row - ctc.total_FOF_col) as col5_value,
	'Life'									as col6_name,
	0										as col6_value,
	'Other'									as col7_name,
	0										as col7_value,
	Convert(NUMERIC(19,6), ctr.total_FOF_row - ctc.total_FOF_col) as total_fund_family_value,
	@firstDayOfYear							AS 'firstdayofyear',
	@monthEndDate							AS 'monthenddate'
FROM
	calc_total_FOF_row ctr
	CROSS JOIN calc_total_FOF_col ctc
ORDER BY
	section,
	total_fund_family_value DESC