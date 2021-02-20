-- Last five quarter end dates starting with the end of the previous year

DECLARE @curr AS DateTime
DECLARE @prior AS DateTime
DECLARE @prior2nd AS DateTime
DECLARE @prior3rd AS DateTime
DECLARE @prior4th AS DateTime

DECLARE @eoq_Dates AS CURSOR

SET @eoq_Dates = CURSOR FOR
	SELECT
		t1.date_value
	FROM FundsManagementWarehouse.dbo.DateDim t1
		INNER JOIN FundsManagementWarehouse.dbo.DateDim t2 ON
			(t1.year_id = t2.year_id - 1 AND t1.quarter_id >= t2.quarter_id) OR
			(t1.year_id = t2.year_id - 2 AND t1.quarter_id <= t2.quarter_id)
	WHERE
		t2.date_value = cast (GetDate () AS DATE) AND
		t1.date_is_eoq_flag = 'Y'
	ORDER BY
		t1.date_value DESC

OPEN @eoq_Dates
FETCH NEXT FROM @eoq_Dates INTO @curr
FETCH NEXT FROM @eoq_Dates INTO @prior
FETCH NEXT FROM @eoq_Dates INTO @prior2nd
FETCH NEXT FROM @eoq_Dates INTO @prior3rd
FETCH NEXT FROM @eoq_Dates INTO @prior4th

SELECT @curr as 'curr', @prior as 'prior', @prior2nd as 'prior2nd', @prior3rd as 'prior3rd', @prior4th as 'prior4th'

CLOSE @eoq_Dates
DEALLOCATE @eoq_Dates