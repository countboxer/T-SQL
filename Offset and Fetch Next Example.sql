-- Test code to illustrate how to skip and return rows

-- Create temporary table
CREATE TABLE #JCB (
	ProductID int PRIMARY KEY NOT NULL,
	ProductName varchar(25) NOT NULL,
	Price money NULL,
	ProductDescription text NULL
)
GO
-- Insert test data
INSERT #JCB (ProductID, ProductName, Price, ProductDescription)
	VALUES (1, 'Clamp', 12.48, 'Workbench clamp')
GO
INSERT #JCB (ProductName, ProductID, Price, ProductDescription)
	VALUES ('Screwdriver', 50, 3.17, 'Flat head')
GO
INSERT #JCB
	VALUES
		(75, 'Tire Bar', NULL, 'Tool for changing tires'),
		(76, 'Hammer', 4.97, 'Hammer time'),
		(77, 'Hop River Beer', 0, 'Required item')
GO

-- Return all rows
SELECT
	*
FROM
	#JCB
ORDER BY
	ProductName
GO

-- Skip the first row and only fetch two
SELECT
	*
FROM
	#JCB
ORDER BY
	ProductName
OFFSET 1 ROWS
FETCH NEXT 2 ROWS ONLY
GO

-- Remove the temporary table
DROP TABLE #JCB
GO