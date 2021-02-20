USE [FundsManagementStaging]
GO

/****** Object:  UserDefinedFunction [dbo].[uf_GetPriorQuarterEnds]    Script Date: 8/20/2019 1:57:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[uf_GetPriorQuarterEnds]
(
	@StartDate				DateTime,
	@NumOfQuarters	Int
)
RETURNS VARCHAR(MAX)
/***************************************************************************
    Database:   FundsManagementStaging

    Copyright:  Copyright ? 2018 by LFG, Inc.
                ALL RIGHTS RESERVED

    Description: 
        This function returns a string of quarter ending dates delimited by
		commas. The first date is the next quarter end date followed by a
		parameter driven number of earlier quarter end dates

****************************************************************************
    Revision History
    Date		Project	Modified By		Description of Change
----------------------------------------------------------------------------
    09/20/2018	003802	Jeff Belknap	Initial Version
----------------------------------------------------------------------------

----------------------------------------------------------------------------
***************************************************************************/
BEGIN
	DECLARE @StrReturn		VARCHAR(MAX)
	DECLARE @QuarterDates	TABLE
	(
		StrQuarterDates			VARCHAR(MAX)
	);

	WITH PriorQuarterEndDates(Date_Value, Next_EOQ, Previous_EOQ, D_Level) AS
	(
		SELECT
			date_value,
			eoq_after_date_value,
			prior_eoq_date,
			0 as D_Level
		FROM
			FundsManagementWarehouse.dbo.DateDim
		WHERE
			date_value = Convert(date, @StartDate)
		UNION ALL  
		SELECT
			d.date_value,
			d.eoq_after_date_value,
			d.prior_eoq_date,
			D_Level + 1
		FROM
			FundsManagementWarehouse.dbo.DateDim d
				INNER JOIN PriorQuarterEndDates e ON e.Previous_EOQ = d.date_value
	)

	INSERT INTO @QuarterDates (StrQuarterDates)
		SELECT TOP (@NumOfQuarters)
			'''' + CONVERT(VARCHAR, Next_EOQ, 120) + '''' AS Next_EOQ
		FROM
			PriorQuarterEndDates
		WHERE
			D_Level != 0

	SELECT @StrReturn = COALESCE(@StrReturn + ', ' + StrQuarterDates, StrQuarterDates) FROM @QuarterDates

	RETURN @StrReturn
END
GO


