----6.1 — Rewrite this derived table query as a CTE:

--SELECT AVG(order_count) AS avg_orders
--FROM (
--    SELECT store_id, COUNT(*) AS order_count
--    FROM sales.orders
--    GROUP BY store_id
--) AS store_counts;

with store_counts as (
	select store_id, count(*) as order_count
	from sales.orders
	group by store_id
)
select 
	avg(order_count) as avg_orders
from store_counts;

----6.2 — Write a CTE called cte_high_value_products that returns products with list_price > 2000.
--Then query the CTE to return only Mountain Bikes from that list, joining to production.categories.

with cte_high_value_products as (
	select category_id,
			product_name,
			list_price
	from production.products
	where list_price > 2000
)
select 
	h.product_name,
	h.list_price,
	c.category_name
	from cte_high_value_products as h 
	join production.categories as c
	on
	h.category_id = c.category_id
	where category_name = 'Mountain Bikes';

----6.3 — Write two CTEs in one WITH clause: one that counts orders per customer, and one that sums revenue per customer.
--Join them in the outer query to return customer_id, order_count, and total_revenue side by side.

with cte_order as (
	select customer_id, count(*) as order_count
	from sales.orders
	group by customer_id
),
	cte_revenue as (
	select o.customer_id,
			SUM(quantity * list_price * (1 - discount)) as total_revenue
	from sales.orders as o
	join sales.order_items as oi
	on o.order_id = oi.order_id
	group by o.customer_id
)
	select 
		o.customer_id,
		o.order_count,
		r.total_revenue
	from cte_order as o
	join cte_revenue as r
	on o.customer_id = r.customer_id;

----6.4 — Using a recursive CTE, generate a list of numbers from 1 to 10.
--Each row should have the number and its square (n * n).

with cte_numbers as (
	select 1 as n

	union all 

	select n + 1 
	from cte_numbers
	where n < 10
)
select n, n*n as square
from cte_numbers;

----6.5 — Using the recursive CTE org chart from section 9.6.2 as a starting point,
--modify it to also show the manager's first_name alongside each employee. Add a level column
--(0 for the top manager, 1 for their direct reports, 2 for the next level down).

with cte_orgchart as (
	select 
		staff_id,
		first_name,
		manager_id,
			cast (null as varchar (50)) as manager_name , 0 as level 
	from sales.staffs
	where manager_id is null
	
union all

	select 
		s.staff_id,
		s.first_name,
		s.manager_id,
		co.first_name as manager_full_name,
		co.level + 1 as level
		from sales.staffs as s
		join cte_orgchart as co
		on s.manager_id = co.staff_id
)
select * from cte_orgchart
order by level, staff_id;


----6.6 — Think About It: A CTE is defined once but referenced twice in the same outer query.
--A colleague says "CTEs are faster than subqueries because the database computes the result once and reuses it.
--" Is this claim accurate? What would you need to do if you genuinely needed the result computed only once and reused?

