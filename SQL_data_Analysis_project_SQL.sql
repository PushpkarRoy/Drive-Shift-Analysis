SELECT * FROM Gold_customers

SELECT * FROM gold_Products

SELECT * FROM Gold_sales

-- Sales By Year--
SELECT EXTRACT(YEAR FROM order_date::date) AS year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold_sales
WHERE order_date IS NOT NULL
GROUP BY year
ORDER BY year ASC

-- Sales By Month--


SELECT *,
RANK() OVER(PARTITION BY year ORDER BY month_no ASC) AS ranking 
FROM (
	SELECT
		EXTRACT(YEAR FROM order_date::date) AS year,
		EXTRACT(MONTH FROM order_date::date) Month_No,
		TO_CHAR(order_date::date, 'Month') AS month_name,
		SUM(sales_amount) AS total_sales,
		COUNT( DISTINCT customer_key) AS total_customers,
		SUM(quantity) AS total_quantity
	FROM gold_sales 
	WHERE order_date IS NOT NULL 
	GROUP BY month_name, Month_no, Year
	ORDER BY Month_no ASC ) AS x

-- Running total Sales by year--

SELECT *,
SUM(total_sales) OVER(ORDER BY year ASC) AS Running_sales 
FROM (
	SELECT EXTRACT(YEAR FROM order_date::date) AS year,
		SUM(sales_amount) AS total_sales 
	FROM gold_sales 
	WHERE order_date IS NOT NULL 
	GROUP BY year )

-- Moving Average sales by Month

SELECT *,
ROUND(AVG(Avg_sales) OVER(ORDER BY Month_no ASC):: NUMERIC , 2) AS Running_Avg_sales
FROM (
	SELECT EXTRACT(MONTH FROM order_date::DATE) AS Month_no,
		TO_CHAR(Order_date::date, 'Month') AS Month_name,
		ROUND(AVG(sales_amount):: NUMERIC , 2) AS Avg_sales		
	FROM gold_sales 
	WHERE order_date IS NOT NULL 
	GROUP BY Month_name, Month_no 
	ORDER BY Month_no ASC )


-- Running Sales By Month--

SELECT *,
ROUND(SUM(total_sales) OVER(ORDER BY Year ASC, Month_no ASC):: NUMERIC , 0) AS Running_Avg_sales
FROM (
	SELECT EXTRACT(YEAR FROM order_date::date) AS year,
		EXTRACT(MONTH FROM order_date::DATE) AS Month_no,
		TO_CHAR(Order_date::date, 'Month') AS Month_name,
		ROUND(SUM(sales_amount):: NUMERIC , 0) AS total_sales		
	FROM gold_sales 
	WHERE order_date IS NOT NULL 
	GROUP BY Month_name, Month_no, year 
	ORDER BY Month_no ASC )

-- Running Sales By every date --

SELECT * FROM gold_sales 

SELECT * ,
SUM(total_sales) OVER(ORDER BY order_date ASC) AS Running_total
FROM (
	SELECT order_date,
		SUM(sales_amount) AS total_sales
	FROM gold_sales 
	WHERE order_date IS NOT NULL 
	GROUP BY order_date 
	ORDER BY order_date ASC )

-- Product Performance -- 

SELECT Year, product_name, total_sales, avg_sales, total_sales - Avg_sales AS Sales_performance 
FROM (
	SELECT EXTRACT(YEAR FROM order_date::date) AS Year,
		product_name , SUM(sales_amount) AS total_sales,
		ROUND(AVG(sales_amount):: NUMERIC , 2) AS Avg_sales
	FROM Gold_products AS gp
	JOIN gold_sales AS gs
	ON gp.product_key = gs.product_key
	WHERE order_date IS NOT NULL 
	GROUP BY Year, product_name )
ORDER BY Year

-- Avg Sales Performance

SELECT *, total_sales - Avg_Sales AS Sales_performance  
FROM (
	SELECT EXTRACT(YEAR FROM order_date::date) AS Year,
		EXTRACT(MONTH FROM order_date::date) AS Month_No,
		TO_CHAR(order_date::date, 'Month') AS Month_name,
		SUM(sales_amount) AS total_sales,
		ROUND(AVG(sales_Amount):: NUMERIC , 2) AS Avg_sales 
	FROM gold_sales  
	WHERE order_date IS NOT NULL
	GROUP BY Year, Month_no, Month_name
	ORDER BY Year ASC, Month_no ASC )
	
-- Sales Performance based on previous Month --

SELECT * FROM Gold_sales 

SELECT 
	*, 
	Total_sales - comparing AS Sales_performance 	
FROM (
	SELECT 
		*,
		LAG(Total_sales, 1,0) OVER(ORDER BY year ASC, Month_no ASC) AS Comparing
	FROM (
		SELECT 
			EXTRACT(YEAR FROM order_date::date) AS Year,
			EXTRACT(MONTH FROM order_date::date) AS Month_no,
			TO_CHAR(order_date::date, 'Month') Month_name,
			SUM(sales_amount) AS Total_sales
		FROM Gold_sales
		WHERE order_date IS NOT NULL
		GROUP BY Month_no, month_name, Year
		ORDER BY  Year ASC ,Month_no ASC 
	) AS A 
) AS B

-- Sales Performance Bases on year on year 

SELECT 
	*,
	total_sales - pre_year_sales AS Sales_performance
FROM (
	SELECT 
		*,
		LAG(total_sales, 1,0) OVER(ORDER BY Year ASC) AS pre_year_sales
	FROM(
		SELECT 
			EXTRACT(YEAR FROM order_date::date)AS Year,
			SUM(sales_amount) AS total_sales
		FROM Gold_sales
		WHERE Order_date IS NOT NULL
		GROUP BY Year 
	) AS A 
) AS B


-- Analyse the yearly performance of products by comparing each products sales to both it's avg.
-- sales performance and the previous year sales.--

SELECT * FROM Gold_sales 
SELECT * FROM Gold_products

SELECT 
	year, product_name, total_sales, avg_sales, sales_performance, sales_performance_meter, 
	total_sales, pre_year_sales, Performance_base_on_pre_year,
	CASE 
		WHEN total_sales > pre_year_sales THEN 'Increasing'
		WHEN total_sales < pre_year_sales THEN 'Descreasing' 
		ELSE 'Normal_sales'
	END AS Performance_base_on_pre_year_Meter
FROM (
	SELECT 
		*,
		LAG(total_sales, 1, 0) OVER(PARTITION BY product_name ORDER BY Year ASC) AS pre_year_sales,
		Total_sales - LAG(total_sales, 1, 0) OVER(PARTITION BY product_name ORDER BY Year ASC) AS Performance_base_on_pre_year
	FROM (
		SELECT 
			*, 
			CASE 
				WHEN Total_sales > avg_sales THEN 'Above_Average'
				WHEN Total_sales < avg_sales THEN 'Below_Average'
				ELSE 'Normal_sales'
			END AS Sales_Performance_meter
		FROM (
			SELECT 
				*,
				ROUND(AVG(total_sales) OVER (PARTITION BY product_name ORDER BY year ASC), 2) AS avg_sales,
				Total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_name ORDER BY year ASC), 2) AS Sales_performance
			FROM (
				SELECT 
					EXTRACT(YEAR FROM order_date::date) AS Year,
					product_name,
					SUM(sales_amount) AS Total_sales
				FROM Gold_sales AS gs
				FULL JOIN gold_products AS gp
				ON gs.product_key =  gp.product_key
				WHERE order_date IS NOT NULL
				GROUP BY Year, product_name 
			) AS A 
		) AS B 
	) AS C 
) AS D


-- Which categories contribute the most to overall sales --

-- Best Selling Product 

SELECT * FROM Gold_sales 
SELECT * FROM Gold_products 

SELECT
	Category,  
	SUM(sales_amount)AS total_sales_amount,
	ROUND((SUM(sales_amount) * 100.0 / ( SELECT SUM(sales_amount)
									FROM gold_sales ))::NUMERIC, 2) AS Sales_percentage
FROM gold_sales AS gs 
FULL JOIN gold_products AS gp
ON gs.product_key  = gp.product_key
WHERE category IS NOT NULL
GROUP BY category

--  ___________________________OR___________________________________


SELECT 
	Category,
	COALESCE(SUM(sales_amount), 0) AS Total_sales,
	COALESCE(ROUND(
				(SUM(sales_amount) * 100.0 / 
						( SELECT SUM(sales_amount)
									FROM gold_sales )
								)::NUMERIC, 
							2),
						0) AS Sales_percentage
FROM gold_sales AS gs 
FULL JOIN gold_products AS gp
ON gs.product_key  = gp.product_key
WHERE category IS NOT NULL
GROUP BY category

-- Best Selling Product By Year on Year 

SELECT
	*,
	SUM(total_sales) OVER(PARTITION BY Category ORDER BY year ASC) AS Running_total_sales
	FROM (
	SELECT 
		EXTRACT(YEAR FROM order_date::date) AS Year,
		Category,
		COALESCE(SUM(sales_amount), 0) AS Total_sales,
		COALESCE(ROUND(
					(SUM(sales_amount) * 100.0 / 
							( SELECT SUM(sales_amount)
										FROM gold_sales )
									)::NUMERIC, 
								2),
							0) || ' %' AS Sales_percentage
	FROM gold_sales AS gs 
	FULL JOIN gold_products AS gp
	ON gs.product_key  = gp.product_key
	WHERE category IS NOT NULL AND 
			order_date IS NOT NULL
	GROUP BY category, year ) AS A


-- Best Selling Product By Year on Year Growth 

SELECT 
	Year, category, sales_percentage, total_sales,Per_year_sales, Yr_on_yr_sales,
		CASE 
			WHEN total_sales > Per_year_sales THEN 'Increasing'
			WHEN total_sales < Per_year_sales THEN 'Descreasing'
			ELSE 'Normal'
		END AS Sales_scale
FROM (
	SELECT
		*,
		LAG(total_sales, 1, 0) OVER(PARTITION BY Category ORDER BY Year ASC) AS Per_year_sales,
		Total_sales - LAG(total_sales, 1, 0) OVER(PARTITION BY Category ORDER BY Year ASC) AS Yr_on_yr_sales 
		FROM (
		SELECT 
			EXTRACT(YEAR FROM order_date::date) AS Year,
			Category,
			COALESCE(SUM(sales_amount), 0) AS Total_sales,
			COALESCE(ROUND(
						(SUM(sales_amount) * 100.0 / 
								( SELECT SUM(sales_amount)
											FROM gold_sales )
										)::NUMERIC, 
									2),
								0) || ' %' AS Sales_percentage
		FROM gold_sales AS gs 
		FULL JOIN gold_products AS gp
		ON gs.product_key  = gp.product_key
		WHERE category IS NOT NULL AND 
				order_date IS NOT NULL
		GROUP BY category, year 
	) AS A 
) AS B


-- Individual Category Monthly Growth with percentage 
-- 1. 'Bikes'

SELECT 
	EXTRACT(YEAR FROM Order_date::date) AS Year,
	EXTRACT(MONTH FROM Order_date::Date) AS Month_no,
	TO_CHAR(order_date::date, 'Month') AS Month_name,
	Category, SUM(sales_amount) AS Total_sales, 
	ROUND((SUM(sales_amount) * 100.0 / ( SELECT SUM(sales_amount)
									FROM Gold_sales ))::NUMERIC , 2) || ' %' AS Sales_percentage
FROM gold_sales AS gs
JOIN gold_products AS gp
ON gp.product_key = gs.product_key
WHERE   Order_date IS NOT NULL 
	AND 
		Category = 'Bikes'
GROUP BY year, month_no, month_name, category
ORDER BY Sales_percentage DESC 

-- Individual Category Monthly Growth with percentage 
-- 2. 'Accessories'

SELECT 
	EXTRACT(YEAR FROM Order_date::date) AS Year,
	EXTRACT(MONTH FROM Order_date::Date) AS Month_no,
	TO_CHAR(order_date::date, 'Month') AS Month_name,
	Category, SUM(sales_amount) AS Total_sales, 
	ROUND((SUM(sales_amount) * 100.0 / ( SELECT SUM(sales_amount)
									FROM Gold_sales ))::NUMERIC , 2) || ' %' AS Sales_percentage
FROM gold_sales AS gs
JOIN gold_products AS gp
ON gp.product_key = gs.product_key
WHERE   Order_date IS NOT NULL 
	AND 
		Category = 'Accessories'
GROUP BY year, month_no, month_name, category
ORDER BY Sales_percentage DESC 

-- Individual Category Monthly Growth with percentage 
-- 3. 'Clothing'

SELECT 
	EXTRACT(YEAR FROM Order_date::date) AS Year,
	EXTRACT(MONTH FROM Order_date::Date) AS Month_no,
	TO_CHAR(order_date::date, 'Month') AS Month_name,
	Category, SUM(sales_amount) AS Total_sales, 
	ROUND((SUM(sales_amount) * 100.0 / ( SELECT SUM(sales_amount)
									FROM Gold_sales ))::NUMERIC , 2) || ' %' AS Sales_percentage
FROM gold_sales AS gs
JOIN gold_products AS gp
ON gp.product_key = gs.product_key
WHERE   Order_date IS NOT NULL 
	AND 
		Category = 'Clothing' 
GROUP BY year, month_no, month_name, category
ORDER BY Sales_percentage DESC



-- Segment products into cost ranges and count how many products fall into each segments --

SELECT * FROM gold_products


SELECT COUNT(product_key) AS Total_Products, Cost_scale
FROM (
	SELECT 	
		Product_key, product_name, cost,
		CASE 
			WHEN cost < 500 THEN 'Under 500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
			WHEN cost BETWEEN 1000 AND 2000 THEN '1000 - 2000'
			ELSE 'Above 2000'
		END AS Cost_scale 
	FROM gold_products  ) AS A
GROUP BY Cost_scale
ORDER BY Total_Products 


-- Group customers into three segments based on their spending behavior. 
-- 	VIP:- At least 12 month of history and spend more then 5000.
-- 	Regular:- At least 12 months of history but spend 5000 or less.
-- 	New:- Lifespan less then 12 months 

SELECT * FROM gold_customers 
SELECT * FROM Gold_sales 

SELECT Customer_id, full_name, first_order, last_order, lifespan, total_sales,
	CASE 
		WHEN lifespan > 12
		AND total_sales > 5000 THEN 'VIP Customer'

		WHEN lifespan > 12
		AND total_sales < 5000 THEN 'Regular Customer'
		
		ELSE 'New Customer'
	END AS customer_type
FROM (
		SELECT 
			gs.customer_key,
			customer_id,
			CONCAT(first_name, ' ', last_name) AS Full_name,
			MIN(order_date) AS first_order,
			MAX(order_date) AS last_order,
			SUM(Sales_amount) AS Total_sales,
			(EXTRACT(YEAR FROM MAX(order_date::date)) - EXTRACT(YEAR FROM MIN(order_date::date))) * 12 +
		    (EXTRACT(MONTH FROM MAX(order_date::date)) - EXTRACT(MONTH FROM MIN(order_date::date))) AS lifespan
		FROM gold_sales AS gs
		JOIN gold_customers AS gc
		ON gs.customer_key = gc.customer_key
		GROUP BY gs.customer_key, customer_id, Full_name ) AS A


-- Highlights:
--     1. Gathers essential fields such as names, ages, and transaction details.
-- 	   2. Segments customers into categories (VIP, Regular, New) and age groups.
--     3. Aggregates customer-level metrics:
-- 	   -  1.total orders
-- 	   -  2.total sales
-- 	   -  3.total quantity purchased
-- 	   -  4.total products
-- 	   - lifespan (in months)
--     4. Calculates valuable KPIs:
-- 	    -  1.recency (months since last order)
-- 		-  2.average order value
-- 		-  3.average monthly spend 

CREATE VIEW report_customers AS 
SELECT 
    product_key,
    customer_id,
    customer_name,
    age,
    first_buy,
    last_buy,
    lifespan_in_months,
    total_sales,
    total_orders,
    Age_group,
    customer_type,

    COUNT(customer_key) AS total_order,
    SUM(quantity) AS total_quantity,
    COUNT(product_key) AS total_product,

    -- Months since last order
    (EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAX(order_date::date))) * 12 +
     EXTRACT(MONTH FROM AGE(CURRENT_DATE, MAX(order_date::date)))) AS months_since_last_order,

    -- Average monthly spend
    ROUND((SUM(total_sales) / NULLIF(lifespan_in_months, 0))::NUMERIC, 2) AS avg_monthly_spend,

    -- Average order value
    ROUND((SUM(total_sales) / NULLIF(SUM(quantity), 0))::NUMERIC, 2) AS avg_order_value

FROM (
    -- 👇 Age group + Customer type layer
    SELECT 
        *,
        CASE 
            WHEN age < 20 THEN 'Below 20'
            WHEN age BETWEEN 20 AND 40 THEN '20 - 40'
            WHEN age BETWEEN 40 AND 60 THEN '40 - 60'
            WHEN age BETWEEN 60 AND 70 THEN '60 - 70'
            ELSE 'Above 70'
        END AS age_group,
        CASE 
            WHEN lifespan_in_months > 12 AND total_sales > 5000 THEN 'VIP Customer'
            WHEN lifespan_in_months > 12 AND total_sales <= 5000 THEN 'Regular Customer'
            ELSE 'New Customer'
        END AS customer_type
    FROM (
        -- 👇 Base customer purchase layer
        SELECT 
            gc.customer_key,
            product_key,
            gc.customer_id,
            CONCAT(first_name, ' ', last_name) AS customer_name,
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate::date)) AS age,
            quantity,
            order_date,
            MIN(gs.order_date) AS first_buy,
            MAX(gs.order_date) AS last_buy,
            (EXTRACT(YEAR FROM MAX(gs.order_date::date)) - EXTRACT(YEAR FROM MIN(gs.order_date::date))) * 12 +
            (EXTRACT(MONTH FROM MAX(gs.order_date::date)) - EXTRACT(MONTH FROM MIN(gs.order_date::date))) AS lifespan_in_months,
            SUM(gs.sales_amount) AS total_sales,
            COUNT(DISTINCT gs.order_number) AS total_orders
        FROM gold_sales AS gs
        JOIN gold_customers AS gc
            ON gs.customer_key = gc.customer_key
        WHERE gs.order_date IS NOT NULL
        GROUP BY gc.customer_key, gc.customer_id, customer_name, age, quantity, product_key, order_date
    ) AS A
) AS B

GROUP BY 
    product_key, customer_id, customer_name, age, first_buy, last_buy, 
    lifespan_in_months, total_sales, total_orders, age_group, customer_type 
ORDER BY lifespan_in_months DESC 


SELECT * FROM report_customers 


-- Product Report

-- Purpose:
--     - This report consolidates key product metrics and behaviors.

-- Highlights:
--     1. Gathers essential fields such as product name, category, subcategory, and cost.
--     2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
--     3. Aggregates product-level metrics:
--        - total orders
--        - total sales
--        - total quantity sold
--        - total customers (unique)
--        - lifespan (in months)
--     4. Calculates valuable KPIs:
--        - recency (months since last sale)
--        - average order revenue (AOR)
--        - average monthly revenue


CREATE OR REPLACE VIEW report_products AS
SELECT 
    p_agg.product_key,
    p_agg.product_name,
    p_agg.category,
    p_agg.subcategory,
    p_agg.cost,
    p_agg.last_sale_date,

    -- 🔹 Months since last sale
    (EXTRACT(YEAR FROM AGE(CURRENT_DATE, p_agg.last_sale_date)) * 12 +
     EXTRACT(MONTH FROM AGE(CURRENT_DATE, p_agg.last_sale_date))) AS recency_in_months,

    -- 🔹 Product Segment classification
    CASE
        WHEN p_agg.total_sales > 50000 THEN 'High-Performer'
        WHEN p_agg.total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    p_agg.lifespan,
    p_agg.total_orders,
    p_agg.total_sales,
    p_agg.total_quantity,
    p_agg.total_customers,
    p_agg.avg_selling_price,

    -- 🔹 Average Order Revenue (AOR)
    CASE 
        WHEN p_agg.total_orders = 0 THEN 0
        ELSE ROUND((p_agg.total_sales / p_agg.total_orders)::NUMERIC, 2)
    END AS avg_order_revenue,

    -- 🔹 Average Monthly Revenue
    CASE
        WHEN p_agg.lifespan = 0 THEN ROUND(p_agg.total_sales::NUMERIC, 2)
        ELSE ROUND((p_agg.total_sales / p_agg.lifespan)::NUMERIC, 2)
    END AS avg_monthly_revenue

FROM (
    -- 🧱 Product Aggregation Subquery (Base + Grouping)
    SELECT
        gp.product_key,
        gp.product_name,
        gp.category,
        gp.subcategory,
        gp.cost,

        -- lifespan in months between first and last sale
        ((EXTRACT(YEAR FROM MAX(gs.order_date::date)) - EXTRACT(YEAR FROM MIN(gs.order_date::date))) * 12 +
         (EXTRACT(MONTH FROM MAX(gs.order_date::date)) - EXTRACT(MONTH FROM MIN(gs.order_date::date)))) AS lifespan,

        MAX(gs.order_date::date) AS last_sale_date,
        COUNT(DISTINCT gs.order_number) AS total_orders,
        COUNT(DISTINCT gs.customer_key) AS total_customers,
        SUM(gs.sales_amount) AS total_sales,
        SUM(gs.quantity) AS total_quantity,

        -- average selling price
        ROUND(AVG((gs.sales_amount / NULLIF(gs.quantity, 0))::NUMERIC), 1) AS avg_selling_price

    FROM gold_sales AS gs
    LEFT JOIN gold_products AS gp
        ON gs.product_key = gp.product_key
    WHERE gs.order_date IS NOT NULL
    GROUP BY 
        gp.product_key,
        gp.product_name,
        gp.category,
        gp.subcategory,
        gp.cost
) AS p_agg
ORDER BY p_agg.total_sales DESC 

