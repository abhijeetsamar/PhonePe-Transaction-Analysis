-------------------------------------------------


CREATE TABLE users (
    user_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    join_date DATE
);

-------------------------------------------------

CREATE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    amount DECIMAL(12,2),
    user_id VARCHAR(20),
    service VARCHAR(50),
    service_type VARCHAR(50),
    payment_status VARCHAR(20),
    reason VARCHAR(100),
    transaction_date DATE
);

-------------------------------------------------
-- Total Users
-------------------------------------------------
SELECT COUNT(*) AS total_users
FROM users;

-------------------------------------------------
-- Total Transactions
-------------------------------------------------
SELECT COUNT(*) AS total_transactions
FROM transactions;

-------------------------------------------------
-- Total Transaction Amount
-------------------------------------------------
SELECT SUM(amount) AS total_transaction_amount
FROM transactions;

-------------------------------------------------
-- Average Transaction Amount
-------------------------------------------------
SELECT ROUND(AVG(amount), 2) AS average_transaction_amount
FROM transactions;

-------------------------------------------------
-- Successful vs Failed Transactions
-------------------------------------------------
SELECT
    payment_status,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY payment_status;

-------------------------------------------------
-- Service-wise Analysis
-------------------------------------------------
SELECT
    service,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY service
ORDER BY total_amount DESC;

-------------------------------------------------
-- Failure Reason Analysis
-------------------------------------------------
SELECT
    reason,
    COUNT(*) AS failed_transactions,
    SUM(amount) AS failed_amount
FROM transactions
WHERE payment_status = 'Failed'
GROUP BY reason
ORDER BY failed_transactions DESC;

-------------------------------------------------
-- Top 10 Users by Transaction Amount
-------------------------------------------------
SELECT
    u.user_id,
    u.name,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_amount
FROM users u
JOIN transactions t
    ON u.user_id = t.user_id
GROUP BY u.user_id, u.name
ORDER BY total_amount DESC
LIMIT 10;

-------------------------------------------------
-- Age Group Analysis
-------------------------------------------------
SELECT
    CASE
        WHEN age < 18 THEN 'Below 18'
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS age_group,
    COUNT(*) AS total_users
FROM users
GROUP BY age_group
ORDER BY total_users;

-------------------------------------------------
-- Age Group ke according Transactions 
-------------------------------------------------
SELECT
    CASE
        WHEN u.age < 18 THEN 'Below 18'
        WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS age_group,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_amount,
    ROUND(AVG(t.amount), 2) AS average_transaction
FROM users u
JOIN transactions t
    ON u.user_id = t.user_id
GROUP BY age_group
ORDER BY total_amount DESC;

-------------------------------------------------
-- Monthly Transaction Trend
-------------------------------------------------
SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY month
ORDER BY month;

-------------------------------------------------
-- Year-wise Analysis
-------------------------------------------------
SELECT
    EXTRACT(YEAR FROM transaction_date) AS year,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY year
ORDER BY year;

-------------------------------------------------
-- Service Type Analysis 
-------------------------------------------------
SELECT
    service,
    service_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY service, service_type
ORDER BY total_amount DESC;

-------------------------------------------------
-- Success Rate
-------------------------------------------------
SELECT
    COUNT(*) AS total_transactions,
    COUNT(CASE WHEN payment_status = 'Successful' THEN 1 END) AS successful_transactions,
    COUNT(CASE WHEN payment_status = 'Failed' THEN 1 END) AS failed_transactions,
    ROUND(
        100.0 * COUNT(CASE WHEN payment_status = 'Successful' THEN 1 END) / COUNT(*),
        2
    ) AS success_rate
FROM transactions;

-------------------------------------------------
-- Service-wise Success Rate
-------------------------------------------------
SELECT
    service,
    COUNT(*) AS total_transactions,
    COUNT(CASE WHEN payment_status = 'Successful' THEN 1 END) AS successful_transactions,
    COUNT(CASE WHEN payment_status = 'Failed' THEN 1 END) AS failed_transactions,
    ROUND(
        100.0 * COUNT(CASE WHEN payment_status = 'Successful' THEN 1 END) / COUNT(*),
        2
    ) AS success_rate
FROM transactions
GROUP BY service
ORDER BY success_rate DESC;

-------------------------------------------------
-- Failure Rate by Reason
-------------------------------------------------
SELECT
    reason,
    COUNT(*) AS failed_transactions,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM transactions WHERE payment_status = 'Failed'),
        2
    ) AS failure_percentage
FROM transactions
WHERE payment_status = 'Failed'
GROUP BY reason
ORDER BY failed_transactions DESC; 

-------------------------------------------------
-- Repeat Users
-------------------------------------------------
SELECT
    COUNT(*) AS repeat_users
FROM (
    SELECT user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(*) > 1
) AS repeat_users;

-------------------------------------------------
-- Highest Transaction
-------------------------------------------------
SELECT
    transaction_id,
    user_id,
    amount,
    service,
    service_type,
    transaction_date
FROM transactions
ORDER BY amount DESC
LIMIT 10;

-------------------------------------------------
-- Monthly Growth %
-------------------------------------------------
WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY month
)
SELECT
    month,
    ROUND(total_amount, 2) AS total_amount,
    ROUND(
        100.0 * (
            total_amount - LAG(total_amount) OVER (ORDER BY month)
        ) / NULLIF(LAG(total_amount) OVER (ORDER BY month), 0),
        2
    ) AS growth_percentage
FROM monthly_data
ORDER BY month;

-------------------------------------------------
-- User Spending Segmentation
-------------------------------------------------
SELECT
    CASE
        WHEN SUM(t.amount) < 5000 THEN 'Low Spender'
        WHEN SUM(t.amount) BETWEEN 5000 AND 20000 THEN 'Medium Spender'
        ELSE 'High Spender'
    END AS spending_segment,
    COUNT(*) AS total_users,
    ROUND(SUM(t.amount), 2) AS total_amount
FROM transactions t
GROUP BY t.user_id
ORDER BY total_amount DESC;






























