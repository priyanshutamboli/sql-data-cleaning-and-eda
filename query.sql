CREATE DATABASE OnlineRetail
USE OnlineRetail

SELECT * FROM dbo.data;


SELECT
    InvoiceNo,
    StockCode,
    Description,
    TRY_CONVERT(INT, Quantity),
    TRY_CONVERT(DATETIME, InvoiceDate, 103),
    TRY_CONVERT(FLOAT, UnitPrice),
    TRY_CONVERT(INT, CustomerID),
    Country
FROM DATA
WHERE
    CustomerID IS NOT NULL
    AND TRY_CONVERT(DATETIME, InvoiceDate, 103) IS NOT NULL;

--1.When did each customer make their first-ever purchase?
WITH first_orders AS(
    SELECT 
        CustomerID,
        MIN(InvoiceDate) AS first_purchase_date
    FROM dbo.data
    WHERE 
        CustomerID IS NOT NULL
    GROUP BY
        CustomerID
)

SELECT * 
FROM first_orders
ORDER BY
    first_purchase_date

-- Checking if no of customer rows MATCH no of purchase dates
-- How many customers?
SELECT COUNT(*) 
FROM (
    SELECT DISTINCT customerid 
    FROM dbo.data
) c;

-- How many orders?
SELECT COUNT(*) 
FROM (
    SELECT 
        customerid, 
        MIN(invoicedate) AS first_purchase_date 
    FROM dbo.data
    GROUP BY customerid
)fp;

--2.Group customers into cohorts based on the month of their first purchase.
WITH first_orders AS(
    SELECT 
        CustomerID,
        MIN(InvoiceDate) AS first_purchase_date
    FROM dbo.data
    WHERE 
        CustomerID IS NOT NULL
    GROUP BY
        CustomerID
),
customer_cohorts AS(
    SELECT 
        CustomerID,
        DATEFROMPARTS(
            YEAR(first_purchase_date),
            MONTH(first_purchase_date),
            1
                      ) AS cohort_month
    FROM first_orders
)

SELECT 
    cohort_month,
    COUNT(*) as customer_per_cohort
FROM
    customer_cohorts
GROUP BY cohort_month
ORDER BY cohort_month

--3.Of customers acquired in a given month, how many of them came back in Month 0, Month 1, Month 2, …?
WITH first_orders AS(
    SELECT 
        CustomerID,
        MIN(InvoiceDate) AS first_purchase_date
    FROM dbo.data
    WHERE 
        CustomerID IS NOT NULL
    GROUP BY
        CustomerID
),
customer_cohorts AS(
    SELECT 
        CustomerID,
        DATEFROMPARTS(
            YEAR(first_purchase_date),
            MONTH(first_purchase_date),
            1
                      ) AS cohort_month
    FROM first_orders
),
orders_with_months AS(
    SELECT
        CustomerID,
        DATEFROMPARTS(
            YEAR(InvoiceDate),
            MONTH(InvoiceDate),
            1
                      ) AS order_month
    FROM dbo.data
    WHERE CustomerID IS NOT NULL
),
cohort_activity AS (
    SELECT
        o.CustomerID,
        c.cohort_month,
        o.order_month,
        DATEDIFF(
            MONTH,
            c.cohort_month,
            o.order_month
        ) AS cohort_index
    FROM orders_with_months o
    JOIN customer_cohorts c
        ON o.CustomerID = c.CustomerID
)
SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT CustomerID) AS active_customers
FROM cohort_activity
WHERE cohort_index >=0
GROUP BY 
    cohort_month,
    cohort_index
ORDER BY
    cohort_month,
    cohort_index


--4.For how long does a customer stay active after their first purchase?
WITH customer_lifecycle AS (
    SELECT
        CustomerID,
        DATEFROMPARTS(
            YEAR(MIN(InvoiceDate)),
            MONTH(MIN(InvoiceDate)),
            1
        ) AS first_purchase_month,
        DATEFROMPARTS(
            YEAR(MAX(InvoiceDate)),
            MONTH(MAX(InvoiceDate)),
            1
        ) AS last_purchase_month
    FROM dbo.DATA
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    DATEDIFF(
        MONTH,
        first_purchase_month,
        last_purchase_month
    ) AS lifetime_months
FROM customer_lifecycle
WHERE
    last_purchase_month >= first_purchase_month;

/*5.Consider a customer churned if they have no purchase in the last 90 days.
How many customers are churned?*/

WITH customer_last_purchase AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date
    FROM dbo.DATA
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
dataset_max_date AS (
    SELECT MAX(InvoiceDate) AS max_invoice_date
    FROM dbo.DATA
),
churn_flag AS (
    SELECT
        c.CustomerID,
        CASE 
            WHEN DATEDIFF(DAY, c.last_purchase_date, d.max_invoice_date) > 90
                THEN 1
            ELSE 0
        END AS is_churned
    FROM customer_last_purchase c
    CROSS JOIN dataset_max_date d
)
SELECT
    is_churned,
    COUNT(*) AS customers
FROM churn_flag
GROUP BY is_churned;