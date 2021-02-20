SELECT
	t.name			as 'Table Name',
	c.name			as 'Column Name',
	x.name			as 'Column Type',
	c.max_length	as 'Column Length',
	c.precision		as 'Column Precision',
	c.scale			as 'Column Scale'
--	,c.*
FROM
	sys.columns c
	JOIN sys.tables t ON c.object_id = t.object_id
	JOIN sys.types x on c.system_type_id = x.system_type_id
WHERE
	c.name LIKE '%base_market_value%'
ORDER BY
	c.name,
	1;

--SELECT * FROM sys.types