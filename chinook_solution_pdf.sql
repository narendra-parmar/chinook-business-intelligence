-- Q1.Does any table have missing values or duplicates? If yes how would you handle it?
-- for customer table 
SELECT 
    COUNT(*) AS total,
    COUNT(company) AS company_not_null,
    COUNT(state) AS state_not_null,
    COUNT(fax) AS fax_not_null
FROM customer;

-- for Trak table 
SELECT 
    COUNT(*) AS total_rows,
    COUNT(composer) AS composer_not_null,
    COUNT(bytes) AS bytes_not_null
FROM track;
-- for employee table
SELECT 
    COUNT(*) AS total_rows,
    COUNT(reports_to) AS reports_to_not_null,
    COUNT(fax) AS fax_not_null
FROM employee;
-- for invoice table 
SELECT 
    * 
FROM invoice 
WHERE billing_state IS NULL;

-- Q.2 Find the top-selling tracks and top artist in the USA and identify their most famous genres?
-- TOP SELLING TRACK IN USA
SELECT 
    t.name AS track_name,
    SUM(il.quantity) AS total_sales,
    g.name AS genre
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY t.track_id, t.name, g.name
ORDER BY total_sales DESC
LIMIT 5;

-- Top Artist in the USA
SELECT 
    ar.name AS artist_name,
    SUM(il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY ar.artist_id, ar.name
ORDER BY total_sales DESC
LIMIT 1;

-- Most Popular Genre of the Top Artist
SELECT 
    ar.name AS artist_name,
    g.name AS genre,
    SUM(il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY ar.artist_id, ar.name, g.genre_id, g.name 
ORDER BY total_sales DESC;  

-- 3.What is the customer demographic breakdown (age, gender, location) of Chinook's customer base?
-- Customers by Country
SELECT 
      coalesce(country,"UNKNOWN") as Country_Name,
      COUNT(*) AS total_customers
FROM chinook.customer
GROUP BY country
ORDER BY total_customers DESC;

-- Customers by state
SELECT 
      coalesce(state,"UNKNOWN") AS STATE_NAME, 
      COUNT(*) AS total_customers
FROM chinook.customer
GROUP BY state
ORDER BY total_customers DESC;

-- Customers by CITY
SELECT 
      coalesce(city,"UNKNOWN") AS City_Name, 
      COUNT(*) AS total_customers
FROM chinook.customer
GROUP BY city
ORDER BY total_customers DESC;

-- 4.Calculate the total revenue and number of invoices for each country, state, and city:
-- Total revenue and total invoice in diffrent country,state and city:
SELECT 
    billing_country AS country,
    billing_state AS state,
    billing_city AS city,
    COUNT(invoice_id) AS total_invoices,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country, billing_state, billing_city
ORDER BY total_revenue DESC;

-- 5. Find the top 5 customers by total revenue in each country?
-- Top 5 customers based on total revenue
SELECT *
FROM (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        SUM(i.total) AS total_revenue,
        RANK() OVER (
            PARTITION BY c.country 
            ORDER BY SUM(i.total) DESC
        ) AS rank_in_country
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY 
        c.customer_id, c.first_name, c.last_name, c.country
) ranked_customers
WHERE rank_in_country <= 5
ORDER BY country, rank_in_country;

-- 6.Identify the top-selling track for each customer
-- Top selling track for each customer
SELECT *
FROM (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        t.track_id,
        t.name AS track_name,
        SUM(il.quantity) AS total_purchased,
        RANK() OVER (
            PARTITION BY c.customer_id
            ORDER BY SUM(il.quantity) DESC
        ) AS rank_per_customer
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    JOIN invoice_line il 
        ON i.invoice_id = il.invoice_id
    JOIN track t 
        ON il.track_id = t.track_id
    GROUP BY 
        c.customer_id, c.first_name, c.last_name, 
        t.track_id, t.name
) ranked_tracks
WHERE rank_per_customer = 1
ORDER BY customer_id;

-- 7.	Are there any patterns or trends in customer purchasing behavior (e.g., frequency of purchases, preferred payment methods, average order value)?
-- Purchase Frequency
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(i.invoice_id) AS total_orders
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC;

-- Average Order Value
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    round(AVG(i.total),2) AS avg_order_value
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_order_value DESC;

-- Geographic Trends
SELECT 
    billing_country,
    COUNT(invoice_id) AS total_orders,
    round(AVG(total),2)  AS avg_order_value,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

-- 8.What is the customer churn rate?
-- Churn based on inactivity
WITH last_purchase AS (
    SELECT 
        customer_id,
        MAX(invoice_date) AS last_purchase_date
    FROM invoice
    GROUP BY customer_id
),
churned_customers AS (
    SELECT 
        customer_id
    FROM last_purchase
    WHERE last_purchase_date < DATE_SUB(
        (SELECT MAX(invoice_date) FROM invoice), 
        INTERVAL 6 MONTH
    )
)
SELECT 
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT ch.customer_id) AS churned_customers,
    ROUND(
        COUNT(DISTINCT ch.customer_id) * 100.0 / COUNT(DISTINCT c.customer_id), 
        2
    ) AS churn_rate_percentage
FROM customer c
LEFT JOIN churned_customers ch 
    ON c.customer_id = ch.customer_id;

-- 9.Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.
-- % of Total Sales by Genre
SELECT 
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS genre_revenue,
    ROUND(
        SUM(il.unit_price * il.quantity) * 100.0 /
        SUM(SUM(il.unit_price * il.quantity)) OVER (),
        2
    ) AS percentage_contribution
FROM invoice i
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY percentage_contribution DESC;

-- Best-Selling Genres in USA
SELECT 
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS genre_revenue,
    ROUND(
        SUM(il.unit_price * il.quantity) * 100.0 /
        SUM(SUM(il.unit_price * il.quantity)) OVER (),
        2
    ) AS percentage_contribution
FROM invoice i
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY genre_revenue DESC
LIMIT 5;

-- Best-Selling Artists in USA
SELECT 
    ar.name AS artist,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice i
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN album al 
    ON t.album_id = al.album_id
JOIN artist ar 
    ON al.artist_id = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY ar.name
ORDER BY total_revenue DESC
LIMIT 5;

-- Find customers who have purchased tracks from at least 3 different genres?
-- customer purchased in at least 3 diffrent genres
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT g.genre_id) AS unique_genres_purchased
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT g.genre_id) >= 3
ORDER BY unique_genres_purchased DESC;

-- Rank genres based on total sales in the USA
SELECT 
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS total_sales,
    dense_rank() OVER (
        ORDER BY SUM(il.unit_price * il.quantity) DESC
    ) AS genre_rank
FROM invoice i
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY genre_rank;

-- Find customers who have NOT made any purchase in the last 3 months?
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    MAX(i.invoice_date) AS last_purchase_date
FROM customer c
LEFT JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    MAX(i.invoice_date) < DATE_SUB(
        (SELECT MAX(invoice_date) FROM invoice), 
        INTERVAL 3 MONTH
    )
    OR MAX(i.invoice_date) IS NULL;
    
    
-- Subjective Question starts from here :
-- 1. Recommend Top 3 albums to promote in the USA Based on best-performing genres
-- Finding  Top Genres in USA
SELECT 
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY total_sales DESC
LIMIT 3;

-- Finding Top Albums from These Genres
SELECT 
    al.title AS album,
    ar.name AS artist,
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
AND g.name IN (
    SELECT g.name
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country = 'USA'
    GROUP BY g.name
    ORDER BY SUM(il.unit_price * il.quantity) DESC LIMIT 3
)
GROUP BY al.title, ar.name, g.name
ORDER BY total_sales DESC
LIMIT 3;
use chinook
-- 2.Determine the top-selling genres in countries other than the USA and identify any commonalities or differences.
-- Top-Selling Genres of all countries (not in USA)
SELECT 
    i.billing_country AS country,
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS total_sales,
    DENSE_RANK() OVER (
        PARTITION BY i.billing_country
        ORDER BY SUM(il.unit_price * il.quantity) DESC
    ) AS rank_in_country
FROM invoice i
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE i.billing_country <> 'USA'
GROUP BY i.billing_country, g.name
ORDER BY country, rank_in_country;

-- Only Top Genre per Country
SELECT *
FROM (
    SELECT 
        i.billing_country AS country,
        g.name AS genre,
        SUM(il.unit_price * il.quantity) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY i.billing_country
            ORDER BY SUM(il.unit_price * il.quantity) DESC
        ) AS rank_in_country
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country <> 'USA'
    GROUP BY i.billing_country, g.name
) ranked
WHERE rank_in_country = 1
order by total_sales desc;

-- 3.Customer Purchasing Behaviour Analysis
WITH customer_activity AS (
    SELECT 
        c.customer_id,
        MIN(i.invoice_date) AS first_purchase,
        MAX(i.invoice_date) AS last_purchase,
        COUNT(i.invoice_id) AS total_orders,
        SUM(i.total) AS total_spent,
        AVG(i.total) AS avg_order_value
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
classified AS (
    SELECT *,
        CASE 
            WHEN first_purchase < DATE_SUB(
                (SELECT MAX(invoice_date) FROM invoice), INTERVAL 6 MONTH
            )
            THEN 'Long-Term'
            ELSE 'New'
        END AS customer_type
    FROM customer_activity
)
SELECT 
    customer_type,
    COUNT(customer_id) AS total_customers,
    AVG(total_orders) AS avg_frequency,
    AVG(avg_order_value) AS avg_basket_size,
    AVG(total_spent) AS avg_total_spending
FROM classified
GROUP BY customer_type;


-- Find which genres / artists / albums are purchased together in the same invoice
-- Genres Bought Together
SELECT 
    g1.name AS genre_1,
    g2.name AS genre_2,
    COUNT(*) AS purchase_count
FROM invoice_line il1
JOIN invoice_line il2 
    ON il1.invoice_id = il2.invoice_id
    AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN genre g1 ON t1.genre_id = g1.genre_id
JOIN genre g2 ON t2.genre_id = g2.genre_id
GROUP BY g1.name, g2.name
ORDER BY purchase_count DESC;

-- Artist Affinity
SELECT 
    ar1.name AS artist_1,
    ar2.name AS artist_2,
    COUNT(*) AS purchase_count
FROM invoice_line il1
JOIN invoice_line il2 
    ON il1.invoice_id = il2.invoice_id
    AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN album al1 ON t1.album_id = al1.album_id
JOIN album al2 ON t2.album_id = al2.album_id
JOIN artist ar1 ON al1.artist_id = ar1.artist_id
JOIN artist ar2 ON al2.artist_id = ar2.artist_id
GROUP BY ar1.name, ar2.name
ORDER BY purchase_count DESC;

-- Album Affinity
SELECT 
    al1.title AS album_1,
    al2.title AS album_2,
    COUNT(*) AS purchase_count
FROM invoice_line il1
JOIN invoice_line il2 
    ON il1.invoice_id = il2.invoice_id
    AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN album al1 ON t1.album_id = al1.album_id
JOIN album al2 ON t2.album_id = al2.album_id
GROUP BY al1.title, al2.title
ORDER BY purchase_count DESC;

-- Compare purchasing behavior + churn across regions (countries/cities)
-- Regional Purchasing Behaviour
-- Country-Level Analysis
SELECT 
    billing_country AS country,
    COUNT(invoice_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(COUNT(invoice_id) * 1.0 / COUNT(DISTINCT customer_id), 2) AS avg_orders_per_customer,
    AVG(total) AS avg_order_value,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

-- City-Level Analysis
SELECT 
    billing_city AS city,
    COUNT(invoice_id) AS total_orders,
    AVG(total) AS avg_order_value,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC;

-- Regional Churn Rate
WITH last_purchase AS (
    SELECT 
        customer_id,
        billing_country,
        MAX(invoice_date) AS last_purchase_date
    FROM invoice
    GROUP BY customer_id, billing_country
),
churned AS (
    SELECT *
    FROM last_purchase
    WHERE last_purchase_date < DATE_SUB(
        (SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH
    )
)
SELECT 
    lp.billing_country AS country,
    COUNT(DISTINCT lp.customer_id) AS total_customers,
    COUNT(DISTINCT ch.customer_id) AS churned_customers,
    ROUND(
        COUNT(DISTINCT ch.customer_id) * 100.0 / COUNT(DISTINCT lp.customer_id),
        2
    ) AS churn_rate
FROM last_purchase lp
LEFT JOIN churned ch 
    ON lp.customer_id = ch.customer_id
GROUP BY lp.billing_country
ORDER BY churn_rate DESC;

-- Build Customer Risk Profile
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.country,
        MAX(i.invoice_date) AS last_purchase,
        COUNT(i.invoice_id) AS frequency,
        SUM(i.total) AS total_spent,
        AVG(i.total) AS avg_order_value
    FROM customer c
    LEFT JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
),
rfm AS (
    SELECT *,
        DATEDIFF(
            (SELECT MAX(invoice_date) FROM invoice), 
            last_purchase
        ) AS recency_days
    FROM customer_metrics
)
SELECT *,
    CASE 
        WHEN recency_days > 90 AND frequency <= 2 THEN 'High Risk'
        WHEN recency_days > 60 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment
FROM rfm;

-- Build Customer Lifetime Value  Metrics
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        MIN(i.invoice_date) AS first_purchase,
        MAX(i.invoice_date) AS last_purchase,
        COUNT(i.invoice_id) AS frequency,
        SUM(i.total) AS total_spent,
        round(AVG(i.total),2) AS avg_order_value
    FROM customer c
    LEFT JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
clv_calc AS (
    SELECT *,
        DATEDIFF(last_purchase, first_purchase) AS lifespan_days,
        (frequency * avg_order_value) AS estimated_clv
    FROM customer_metrics
)
SELECT * FROM clv_calc
ORDER BY estimated_clv DESC;
-- Segment Customers by Customer Lifetime Value
SELECT 
    CASE 
        WHEN estimated_clv > 100 THEN 'High Value'
        WHEN estimated_clv BETWEEN 50 AND 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    AVG(estimated_clv) AS avg_clv
FROM (
    SELECT 
        customer_id,
        (COUNT(invoice_id) * AVG(total)) AS estimated_clv
    FROM invoice
    GROUP BY customer_id
) t
GROUP BY customer_segment;
-- Identify Churned Customers Pattern
WITH last_purchase AS (
    SELECT 
        customer_id,
        MAX(invoice_date) AS last_purchase
    FROM invoice
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    COUNT(i.invoice_id) AS total_orders,
    SUM(i.total) AS total_spent,
    MAX(i.invoice_date) AS last_purchase
FROM customer c
LEFT JOIN invoice i 
    ON c.customer_id = i.customer_id
JOIN last_purchase lp 
    ON c.customer_id = lp.customer_id
WHERE lp.last_purchase < DATE_SUB(
    (SELECT MAX(invoice_date) FROM invoice), 
    INTERVAL 3 MONTH
)
GROUP BY c.customer_id;


-- New Customers per Month
SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    COUNT(DISTINCT customer_id) AS new_customers
FROM invoice i
WHERE customer_id NOT IN (
    SELECT customer_id 
    FROM invoice 
    WHERE invoice_date < i.invoice_date
)
GROUP BY year, month
ORDER BY year, month;

-- Repeat Purchase Rate
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(invoice_id) AS total_orders
    FROM invoice
    GROUP BY customer_id
)
SELECT 
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / COUNT(*) 
    AS retention_rate
FROM customer_orders;

-- Revenue Trend Over Time
SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    COUNT(invoice_id) AS total_orders,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY year, month
ORDER BY year, month;

-- Measure Average Order Value
SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    AVG(total) AS avg_order_value
FROM invoice
GROUP BY year, month;

-- a new column Release Year to the album table in the Chinook database, you use the ALTER TABLE statement.
ALTER TABLE album
ADD COLUMN release_year INTEGER;
select * from album;

-- Average total amount spent per customer , Number of customers and Average number of tracks purchased per customer
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        c.country,
        SUM(i.total) AS total_spent,
        COUNT(il.track_id) AS total_tracks
    FROM customer c
    LEFT JOIN invoice i 
        ON c.customer_id = i.customer_id
    LEFT JOIN invoice_line il 
        ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id, c.country
)
SELECT 
    country,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(total_spent), 2) AS avg_amount_spent_per_customer,
    ROUND(AVG(total_tracks), 2) AS avg_tracks_per_customer
FROM customer_stats
GROUP BY country
ORDER BY avg_amount_spent_per_customer DESC;

-- END OF QUERIES --