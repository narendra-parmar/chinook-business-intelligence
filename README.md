# 🎵 Chinook Music Store — SQL Analysis Project

<p align="center">
  <img src="https://img.shields.io/badge/SQL-MySQL-blue?style=for-the-badge&logo=mysql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Database-Chinook-green?style=for-the-badge&logo=databricks&logoColor=white"/>
  <img src="https://img.shields.io/badge/Analysis-Business%20Intelligence-orange?style=for-the-badge&logo=chartdotjs&logoColor=white"/>
  <img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge"/>
</p>

---

## 👤 Author

| Field        | Details                          |
|--------------|----------------------------------|
| **Name**     | Narendra Parmar                  |
| **Role**     | Data Analyst                     |
| **Project**  | Chinook Music Store SQL Analysis |

---

## 📌 Problem Statement

> You are hired as a **Data Analyst at Chinook**, and your objective is to analyse music record sales data to gain insights and make recommendations for the company's strategy in the physical music market.

This project involves comprehensive SQL-based analysis of the **Chinook digital music store database**, covering sales trends, customer behaviour, genre popularity, churn analysis, and business strategy recommendations.

---

## 🗃️ Database Schema

The Chinook database consists of the following tables:

```
chinook
├── customer         → Customer profiles and contact information
├── invoice          → Purchase transactions and billing info
├── invoice_line     → Individual line items per invoice
├── track            → Music tracks with metadata
├── album            → Album records linked to artists
├── artist           → Artist information
├── genre            → Music genre classifications
├── media_type       → Media format types
├── playlist         → Named playlists
└── playlist_track   → Track-playlist mapping
```

### Table Descriptions

<details>
<summary><strong>📋 customer</strong></summary>

| Column           | Description                                      |
|------------------|--------------------------------------------------|
| `customer_id`    | Unique identifier for each customer              |
| `first_name`     | Customer's first name                            |
| `last_name`      | Customer's last name                             |
| `company`        | Associated company name                          |
| `address`        | Street address                                   |
| `city`           | City of residence                                |
| `state`          | State or province                                |
| `country`        | Country                                          |
| `postal_code`    | Postal/ZIP code                                  |
| `phone`          | Phone number                                     |
| `fax`            | Fax number                                       |
| `email`          | Email address                                    |
| `support_rep_id` | Assigned support representative's employee ID    |

</details>

<details>
<summary><strong>🧾 invoice</strong></summary>

| Column                | Description                          |
|-----------------------|--------------------------------------|
| `invoice_id`          | Unique invoice identifier            |
| `customer_id`         | Associated customer ID               |
| `invoice_date`        | Date the invoice was issued          |
| `billing_address`     | Billing street address               |
| `billing_city`        | Billing city                         |
| `billing_state`       | Billing state/province               |
| `billing_country`     | Billing country                      |
| `billing_postal_code` | Billing postal code                  |
| `total`               | Total amount due                     |

</details>

<details>
<summary><strong>🎵 track</strong></summary>

| Column          | Description                          |
|-----------------|--------------------------------------|
| `track_id`      | Unique track identifier              |
| `name`          | Track title                          |
| `album_id`      | Album the track belongs to           |
| `media_type_id` | Associated media type                |
| `genre_id`      | Associated genre                     |
| `composer`      | Composer/artist name                 |
| `milliseconds`  | Track duration in milliseconds       |
| `bytes`         | File size in bytes                   |
| `unit_price`    | Price per unit                       |

</details>

<details>
<summary><strong>💿 album / artist / genre / media_type</strong></summary>

| Table        | Key Columns                                  |
|--------------|----------------------------------------------|
| `album`      | `album_id`, `title`, `artist_id`             |
| `artist`     | `artist_id`, `name`                          |
| `genre`      | `genre_id`, `name`                           |
| `media_type` | `media_type_id`, `name`                      |

</details>

---

## 🛠️ Technologies Used

- **Database:** MySQL (Chinook Schema)
- **Language:** SQL
- **Concepts:** Joins, Window Functions, CTEs, Aggregations, Subqueries, CASE statements, Date functions

---

## 📂 Project Structure

```
chinook-sql-analysis/
├── README.md                      ← You are here
├── chinook_solution_pdf.sql       ← All SQL queries (objective + subjective)
├── objective_questions.docx       ← Objective Q&A with insights
├── subjective_questions.docx      ← Subjective Q&A with strategies
└── chinook_ppt.pptx               ← Presentation deck with query screenshots
```

---

## 🎯 Objective Questions & Solutions

### Q1. Does any table have missing values or duplicates?

**Answer:**

**Tables with Missing Values:** `customer`, `track`, `employee`, `invoice`

**Tables without Missing Values:** `album`, `artist`, `genre`, `invoice_line`

**Duplicate Records:** No true duplicates exist due to primary key constraints. `invoice_line` contains valid transactional repetitions.

```sql
-- Check missing values in customer table
SELECT 
    COUNT(*) AS total,
    COUNT(company) AS company_not_null,
    COUNT(state) AS state_not_null,
    COUNT(fax) AS fax_not_null
FROM customer;

-- Check missing values in track table
SELECT 
    COUNT(*) AS total_rows,
    COUNT(composer) AS composer_not_null,
    COUNT(bytes) AS bytes_not_null
FROM track;

-- Check NULL billing_state in invoice
SELECT * FROM invoice WHERE billing_state IS NULL;
```

**Handling strategies:**
- `COALESCE` / `IFNULL` to replace NULLs with defaults
- `ROW_NUMBER()` with `DELETE` to remove duplicates
- `GROUP BY` for analytical deduplication
- Add UNIQUE constraints to prevent future duplicates

---

### Q2. Find the top-selling tracks and top artist in the USA and identify their most famous genres.

```sql
-- Top-selling tracks in USA
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

-- Top artist in USA
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

-- Most popular genre of the top artist
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
```

---

### Q3. What is the customer demographic breakdown of Chinook's customer base?

> ⚠️ **Note:** The Chinook dataset does **NOT** contain `age` or `gender` columns. Demographics are based on **location** only.

```sql
-- Customers by Country
SELECT 
    COALESCE(country, 'UNKNOWN') AS Country_Name,
    COUNT(*) AS total_customers
FROM chinook.customer
GROUP BY country
ORDER BY total_customers DESC;

-- Customers by State
SELECT 
    COALESCE(state, 'UNKNOWN') AS STATE_NAME,
    COUNT(*) AS total_customers
FROM chinook.customer
GROUP BY state
ORDER BY total_customers DESC;

-- Customers by City
SELECT 
    COALESCE(city, 'UNKNOWN') AS City_Name,
    COUNT(*) AS total_customers
FROM chinook.customer
GROUP BY city
ORDER BY total_customers DESC;
```

---

### Q4. Calculate the total revenue and number of invoices for each country, state, and city.

```sql
SELECT 
    billing_country AS country,
    billing_state AS state,
    billing_city AS city,
    COUNT(invoice_id) AS total_invoices,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country, billing_state, billing_city
ORDER BY total_revenue DESC;
```

---

### Q5. Find the top 5 customers by total revenue in each country.

```sql
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
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
) ranked_customers
WHERE rank_in_country <= 5
ORDER BY country, rank_in_country;
```

---

### Q6. Identify the top-selling track for each customer.

```sql
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
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    GROUP BY c.customer_id, c.first_name, c.last_name, t.track_id, t.name
) ranked_tracks
WHERE rank_per_customer = 1
ORDER BY customer_id;
```

---

### Q7. Are there any patterns or trends in customer purchasing behaviour?

```sql
-- Purchase Frequency per Customer
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(i.invoice_id) AS total_orders
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC;

-- Average Order Value
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(AVG(i.total), 2) AS avg_order_value
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_order_value DESC;

-- Geographic Purchasing Trends
SELECT 
    billing_country,
    COUNT(invoice_id) AS total_orders,
    ROUND(AVG(total), 2) AS avg_order_value,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;
```

**Key Insights:**
- Some customers are **frequent loyal buyers**, others are **one-time purchasers**
- Countries like **USA, Canada, Brazil** generate the most revenue
- Useful for **customer segmentation** and **targeted marketing**

---

### Q8. What is the customer churn rate?

> A customer is considered **churned** if they have **not made a purchase in the last 6 months**.

```sql
WITH last_purchase AS (
    SELECT 
        customer_id,
        MAX(invoice_date) AS last_purchase_date
    FROM invoice
    GROUP BY customer_id
),
churned_customers AS (
    SELECT customer_id
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
LEFT JOIN churned_customers ch ON c.customer_id = ch.customer_id;
```

---

### Q9. Calculate the percentage of total sales by genre in the USA.

```sql
-- % of Total Sales by Genre in USA
SELECT 
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS genre_revenue,
    ROUND(
        SUM(il.unit_price * il.quantity) * 100.0 /
        SUM(SUM(il.unit_price * il.quantity)) OVER (),
        2
    ) AS percentage_contribution
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY percentage_contribution DESC;

-- Best-Selling Artists in USA
SELECT 
    ar.name AS artist,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY ar.name
ORDER BY total_revenue DESC
LIMIT 5;
```

---

### Q10. Find customers who purchased from at least 3 different genres.

```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT g.genre_id) AS unique_genres_purchased
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT g.genre_id) >= 3
ORDER BY unique_genres_purchased DESC;
```

---

### Q11. Rank genres based on total sales in the USA.

```sql
SELECT 
    g.name AS genre,
    SUM(il.unit_price * il.quantity) AS total_sales,
    DENSE_RANK() OVER (
        ORDER BY SUM(il.unit_price * il.quantity) DESC
    ) AS genre_rank
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY genre_rank;
```

---

### Q12. Find customers who have NOT made a purchase in the last 3 months.

```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    MAX(i.invoice_date) AS last_purchase_date
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING 
    MAX(i.invoice_date) < DATE_SUB(
        (SELECT MAX(invoice_date) FROM invoice), 
        INTERVAL 3 MONTH
    )
    OR MAX(i.invoice_date) IS NULL;
```

---

## 📊 Subjective Questions & Business Insights

### S1. Recommend the Top 3 Albums to Promote in the USA

```sql
-- Step 1: Find Top Genres in USA
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

-- Step 2: Find Top Albums from These Genres
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
```

**Recommendations:**
- 🎸 Prioritize **Rock, Metal, and Alternative** genres — highest demand in USA
- 🎯 Target **high-value customers** with personalized campaigns
- 🔁 Use **cross-selling**: Rock buyers → suggest Metal/Alternative

---

### S2. Top-Selling Genres in Countries Other Than USA

```sql
-- Top Genre per Country (excluding USA)
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
ORDER BY total_sales DESC;
```

**Key Insights:**
| Pattern | Detail |
|---------|--------|
| 🌍 Universal | Rock dominates globally |
| 🌎 Regional | Brazil → Latin; Europe → Jazz/Classical |
| 📊 Concentration | Few genres drive most revenue everywhere |

**Strategy:** Global (Rock) + Localized (country-specific) = Hybrid approach

---

### S3. Customer Purchasing Behaviour Analysis (New vs Long-Term)

```sql
WITH customer_activity AS (
    SELECT 
        c.customer_id,
        MIN(i.invoice_date) AS first_purchase,
        MAX(i.invoice_date) AS last_purchase,
        COUNT(i.invoice_id) AS total_orders,
        SUM(i.total) AS total_spent,
        AVG(i.total) AS avg_order_value
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
classified AS (
    SELECT *,
        CASE 
            WHEN first_purchase < DATE_SUB(
                (SELECT MAX(invoice_date) FROM invoice), INTERVAL 6 MONTH)
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
```

**Insights:**
- **Long-Term Customers:** Higher frequency, consistent behaviour, genre loyal
- **New Customers:** Low frequency, exploratory, higher churn risk

---

### S4. Product Affinity Analysis (Co-Purchase Patterns)

```sql
-- Genres Frequently Bought Together
SELECT 
    g1.name AS genre_1,
    g2.name AS genre_2,
    COUNT(*) AS purchase_count
FROM invoice_line il1
JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN genre g1 ON t1.genre_id = g1.genre_id
JOIN genre g2 ON t2.genre_id = g2.genre_id
GROUP BY g1.name, g2.name
ORDER BY purchase_count DESC;
```

**Key Pairs:**
- 🎸 Rock + Metal → Most common pairing
- 🎵 Rock + Alternative/Punk → Frequent co-purchase
- Customers rarely mix very different genres (e.g., Classical + Heavy Metal)

---

### S5. Customer Risk Profiling (RFM-Based)

```sql
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.country,
        MAX(i.invoice_date) AS last_purchase,
        COUNT(i.invoice_id) AS frequency,
        SUM(i.total) AS total_spent,
        AVG(i.total) AS avg_order_value
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
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
```

| Risk Segment | Characteristics | Strategy |
|---|---|---|
| 🔴 High Risk | Inactive >90 days, freq ≤2 | Discounts, Re-engagement emails |
| 🟡 Medium Risk | Moderate inactivity | Personalized recommendations |
| 🟢 Low Risk | Recent, frequent, high spend | Loyalty rewards, early access |

---

### S6. Customer Lifetime Value (CLV) Modelling

```sql
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        MIN(i.invoice_date) AS first_purchase,
        MAX(i.invoice_date) AS last_purchase,
        COUNT(i.invoice_id) AS frequency,
        SUM(i.total) AS total_spent,
        ROUND(AVG(i.total), 2) AS avg_order_value
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
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

-- CLV Segmentation
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
```

---

### S7. Regional Churn Analysis

```sql
WITH last_purchase AS (
    SELECT 
        customer_id,
        billing_country,
        MAX(invoice_date) AS last_purchase_date
    FROM invoice
    GROUP BY customer_id, billing_country
),
churned AS (
    SELECT * FROM last_purchase
    WHERE last_purchase_date < DATE_SUB(
        (SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH
    )
)
SELECT 
    lp.billing_country AS country,
    COUNT(DISTINCT lp.customer_id) AS total_customers,
    COUNT(DISTINCT ch.customer_id) AS churned_customers,
    ROUND(
        COUNT(DISTINCT ch.customer_id) * 100.0 / COUNT(DISTINCT lp.customer_id), 2
    ) AS churn_rate
FROM last_purchase lp
LEFT JOIN churned ch ON lp.customer_id = ch.customer_id
GROUP BY lp.billing_country
ORDER BY churn_rate DESC;
```

**Regional Strategy:**
| Market Type | Action |
|---|---|
| High Value + Low Churn | Maintain & reward |
| High Value + High Churn | Aggressive retention |
| Low Value + High Churn | Re-evaluate investment |

---

### S8. Revenue Trend & Retention Tracking

```sql
-- Revenue Trend Over Time
SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    COUNT(invoice_id) AS total_orders,
    SUM(total) AS total_revenue
FROM invoice
GROUP BY year, month
ORDER BY year, month;

-- Repeat Purchase Rate
WITH customer_orders AS (
    SELECT customer_id, COUNT(invoice_id) AS total_orders
    FROM invoice
    GROUP BY customer_id
)
SELECT 
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / COUNT(*) 
    AS retention_rate
FROM customer_orders;
```

---

### S9. Alter Album Table — Add Release Year Column

```sql
ALTER TABLE album
ADD COLUMN release_year INTEGER;

SELECT * FROM album;
```

---

### S10. Customer Spending by Country (Multi-Metric)

```sql
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        c.country,
        SUM(i.total) AS total_spent,
        COUNT(il.track_id) AS total_tracks
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    LEFT JOIN invoice_line il ON i.invoice_id = il.invoice_id
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
```

---

## 💡 Key Business Recommendations

| # | Recommendation | Priority |
|---|---|---|
| 1 | Invest heavily in **Rock, Metal, Alternative** — dominant USA genres | 🔴 High |
| 2 | Build **loyalty programs** for long-term, high-value customers | 🔴 High |
| 3 | Launch **re-engagement campaigns** for high-risk/churned customers | 🔴 High |
| 4 | Use **RFM segmentation** for targeted marketing | 🟡 Medium |
| 5 | Implement **cross-selling**: Rock → Metal, Rock → Alternative | 🟡 Medium |
| 6 | **Localize** genre promotion by country (Latin in Brazil, Jazz in Europe) | 🟡 Medium |
| 7 | Track **CLV** to prioritize marketing spend on high-value segments | 🟢 Ongoing |
| 8 | Add **campaign tracking table** for measuring promotional ROI | 🟢 Ongoing |

---

## 🖼️ Screenshots

> Query output screenshots are available in the presentation file: **`chinook_ppt.pptx`** (Slides 7–20)

The presentation covers visual outputs for:
- Top-selling tracks & artists in USA
- Customer demographic breakdown by country/city
- Revenue by region
- Genre sales percentage contribution
- Churn rate analysis
- CLV segmentation

---

## 🚀 How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/chinook-sql-analysis.git
   cd chinook-sql-analysis
   ```

2. **Set up the Chinook database**
   - Download the [Chinook Database](https://github.com/lerocha/chinook-database)
   - Import into MySQL:
     ```bash
     mysql -u root -p < Chinook_MySql.sql
     ```

3. **Run the queries**
   ```bash
   mysql -u root -p chinook < chinook_solution_pdf.sql
   ```


---

<p align="center">
  Made with ❤️ by <strong>Narendra Parmar</strong>
</p>
