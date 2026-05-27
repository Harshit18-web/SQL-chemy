# cofee analysis
select * from cofee.customers ;
select * from cofee.city ;
select * from cofee.products ;
select * from cofee.sales ;
 
 
 # report and data analysis 
 
 # Q-1) Cofee consumers count 
 # how many people in each city are estimated to consume cofee , given that 25% of the population does ?
 
select 
city_name,
population,
city_rank ,
round((population * 0.25)/1000000,2) as Cofee_consumers_in_millons
from city
order by population desc ;

# Q -2) Total Revenue cofee sales 
# what is the total revenue generated from cofee sales across all cities in the last quarter of 2023 ?

select 
sum(total) as total_revenue 
from sales 
where 
	extract(year from sale_date ) = 2023
    AND 
    extract(quarter from sale_date) = 4 ;
    


-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

select 
p.product_name ,
count(s.product_id) as product_count
from sales s
join products p
ON s.product_id = p.product_id
group by p.product_name
order by product_count desc ; 


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
-- city abd total sale
-- no cx in each these city

SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,

    ROUND(
        SUM(s.total) /
        COUNT(DISTINCT s.customer_id),
    2) AS avg_sale_pr_cx

FROM sales AS s

JOIN customers AS c
    ON s.customer_id = c.customer_id

JOIN city AS ci
    ON ci.city_id = c.city_id

GROUP BY ci.city_name

ORDER BY total_revenue DESC;




-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)
WITH city_table AS
(
    SELECT 
        city_name,
        population,

        ROUND(
            (population * 0.25) / 1000000,
        2) AS coffee_consumers

    FROM city
),

customer_table AS
(
    SELECT 
        ci.city_name,

        COUNT(DISTINCT c.customer_id) AS unique_cx

    FROM sales AS s

    JOIN customers AS c
        ON c.customer_id = s.customer_id

    JOIN city AS ci
        ON ci.city_id = c.city_id

    GROUP BY ci.city_name
)

SELECT 
    customer_table.city_name,
    city_table.coffee_consumers AS coffee_consumer_in_millions,
    city_table.population,
    customer_table.unique_cx

FROM city_table

JOIN customer_table
    ON city_table.city_name = customer_table.city_name;
-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT *
FROM
(
    SELECT 
        ci.city_name,
        p.product_name,

        COUNT(s.sale_id) AS total_orders,

        DENSE_RANK() OVER
        (
            PARTITION BY ci.city_name
            ORDER BY COUNT(s.sale_id) DESC
        ) AS ranking

    FROM sales AS s

    JOIN products AS p
        ON s.product_id = p.product_id

    JOIN customers AS c
        ON c.customer_id = s.customer_id

    JOIN city AS ci
        ON ci.city_id = c.city_id

    GROUP BY ci.city_name, p.product_name

) AS T

WHERE ranking <= 3;


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?


SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
GROUP BY(ci.city_name) ;

-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

WITH city_table AS
(
    SELECT 
        ci.city_name,

        SUM(s.total) AS total_revenue,

        COUNT(DISTINCT s.customer_id) AS total_cx,

        ROUND(
            SUM(s.total) /
            COUNT(DISTINCT s.customer_id),
        2) AS avg_sale_pr_cx

    FROM sales AS s

    JOIN customers AS c
        ON s.customer_id = c.customer_id

    JOIN city AS ci
        ON ci.city_id = c.city_id

    GROUP BY ci.city_name
),

city_rent AS
(
    SELECT 
        city_name,
        estimated_rent

    FROM city
)

SELECT 
    cr.city_name,
    cr.estimated_rent,
    ct.total_cx,
    ct.avg_sale_pr_cx,

    ROUND(
        cr.estimated_rent / ct.total_cx,
    2) AS avg_rent_per_cx

FROM city_rent AS cr

JOIN city_table AS ct
    ON cr.city_name = ct.city_name

ORDER BY avg_sale_pr_cx DESC;

-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

WITH monthly_sales AS
(
    SELECT 
        ci.city_name,

        EXTRACT(MONTH FROM sale_date) AS month,

        EXTRACT(YEAR FROM sale_date) AS year,

        SUM(s.total) AS total_sale

    FROM sales AS s

    JOIN customers AS c
        ON c.customer_id = s.customer_id

    JOIN city AS ci
        ON ci.city_id = c.city_id

    GROUP BY 
        ci.city_name,
        month,
        year
),

growth_ratio AS
(
    SELECT
        city_name,
        month,
        year,

        total_sale AS cr_month_sale,

        LAG(total_sale, 1)
        OVER
        (
            PARTITION BY city_name
            ORDER BY year, month
        ) AS last_month_sale

    FROM monthly_sales
)

SELECT
    city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,

    ROUND(
        (
            (cr_month_sale - last_month_sale)
            / last_month_sale
        ) * 100,
    2) AS growth_ratio

FROM growth_ratio

WHERE last_month_sale IS NOT NULL;

-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

WITH city_table AS
(
    SELECT 
        ci.city_name,

        SUM(s.total) AS total_revenue,

        COUNT(DISTINCT s.customer_id) AS total_cx,

        ROUND(
            SUM(s.total) /
            COUNT(DISTINCT s.customer_id),
        2) AS avg_sale_pr_cx

    FROM sales AS s

    JOIN customers AS c
        ON s.customer_id = c.customer_id

    JOIN city AS ci
        ON ci.city_id = c.city_id

    GROUP BY ci.city_name
),

city_rent AS
(
    SELECT 
        city_name,

        estimated_rent,

        ROUND(
            (population * 0.25) / 1000000,
        3) AS estimated_coffee_consumer_in_millions

    FROM city
)

SELECT 
    cr.city_name,

    ct.total_revenue,

    cr.estimated_rent AS total_rent,

    ct.total_cx,

    cr.estimated_coffee_consumer_in_millions,

    ct.avg_sale_pr_cx,

    ROUND(
        cr.estimated_rent / ct.total_cx,
    2) AS avg_rent_per_cx

FROM city_rent AS cr

JOIN city_table AS ct
    ON cr.city_name = ct.city_name

ORDER BY total_revenue DESC

LIMIT 3;

