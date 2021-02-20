-- Retrieves the next quarter end date and the three previous quarter end dates
-- Combines all dates into a single field seperated by commas

DECLARE @val	NVARCHAR(MAX);

WITH
	-- Returns the next and previous end of quarter dates associated with today
	Prior_Quarter_Ends(Date_Value, Next_EOQ, Previous_EOQ, D_Level) AS
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
			INNER JOIN Prior_Quarter_Ends e ON e.Previous_EOQ = d.date_value
	),
	-- Restricts the above query to the top four excluding the first one which isn't a valid date value
	Top_Four_Quarter_Ends AS
	(
		SELECT TOP 4
			LEFT(CONVERT(VARCHAR, Next_EOQ, 120),10) as Next_EOQ
		FROM
			Prior_Quarter_Ends
		WHERE
			D_Level != 0
)

-- Combines the four values into a string
SELECT @val = COALESCE(@val + ', ' + Next_EOQ, Next_EOQ) FROM Top_Four_Quarter_Ends

SELECT @val;
