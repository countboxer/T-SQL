-- Convert a date field to an integer
SELECT
	GetDate(),
	cast(convert(char(8), GetDate(), 112) as int)