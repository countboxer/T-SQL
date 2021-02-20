-- Each order each day and its total, with a running total along the side
select
	sale_date,
	salesorderid,
	subtotal,
	sum(subtotal) over(partition by sale_date order by salesorderid) as total_sales
from
	sales.salesorderheader
where
	orderdate between '2018-01-01 00:00:00:000' and '2018-12-31 00:00:00:000'
order by
	sale_date

----------

-- ranks each row by subtotal
select
	sale_date,
	salesorderid,
	subtotal,
	dense_rank() over(order by subtotal desc) as sales_rank
from
	sales.salesorderheader
where
	orderdate between '2018-01-01 00:00:00:000' and '2018-12-31 00:00:00:000'
order by
	sale_date

----------

-- bucket groups of rows
select
	territoryid,
	customerid,
	sum(subtotal) as subtotal,
	ntile(4) over(order by sum(subtotal)) as bucket
from
	sales.salesorderheader
where
	sales_date between '2018-01-01 00:00:00:000' and '2018-12-31 00:00:00:000'
group by
	territoryid,
	customerid

----------

-- by using lag() we are able to reach up and return the result from the previous row
select
	customerid,
	subtotal,
	sale_date,
	lag(sale_date) over(order by sale_date) as last_order
from
	sales.salesorderheader
where
	customerid = 11078
	and sale_date between '2018-01-01 00:00:00:000' and '2018-12-31 00:00:00:000'

----------

-- add a new column to calculate the difference between the dates
select
	customerid,
	subtotal,
	sale_date,
	lag(sale_date) over(order by sale_date) as last_order,
	cast(sale_date - (lag(sale_date) over(order by sale_date)) as int) as days_between
from
	sales.salesorderheader
where
	customerid = 11078
	and sale_date between '2018-01-01 00:00:00:000' and '2018-12-31 00:00:00:000'
