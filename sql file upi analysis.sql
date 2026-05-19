-- =========================================
-- UPI TRANSACTION TRENDS ANALYSIS
-- SQL Business Analysis Project
-- =========================================

CREATE DATABASE upi_analysis_excel;
USE upi_analysis_excel;
-- =========================================
-- DATABASE SETUP
-- =========================================

CREATE TABLE upi_transactions (
    transaction_id VARCHAR(30),
    timestamp DATETIME,
    transaction_type VARCHAR(50),
    merchant_category VARCHAR(50),
    amount_in_INR DECIMAL(10,2),
    transaction_status VARCHAR(20),
    sender_age_group VARCHAR(20),
    receiver_age_group VARCHAR(20),
    sender_state VARCHAR(50),
    sender_bank VARCHAR(50),
    receiver_bank VARCHAR(50),
    device_type VARCHAR(30),
    network_type VARCHAR(30),
    fraud_flag INT,
    hour_of_day INT,
    day_of_week VARCHAR(20),
    is_weekend VARCHAR(10)
);
-- =========================================
-- DATA VALIDATION & EXPLORATION
-- =========================================

SELECT COUNT(*) FROM upi_analysis_excel;
SELECT COUNT(*) FROM upi_transactions;

SHOW DATABASES;
SHOW TABLES;

SELECT *
FROM upi_transactions
WHERE amount_in_INR IS NULL;

SELECT * FROM upi_transactions WHERE amount_in_INR IS NULL;
SELECT * FROM upi_transactions WHERE amount_in_INR <= 0;
SELECT DISTINCT transaction_type FROM upi_transactions;
SELECT DISTINCT merchant_category FROM upi_transactions;
SELECT DISTINCT sender_bank FROM upi_transactions;
SELECT * FROM upi_transactions LIMIT 10;

-- =========================================
-- KPI ANALYSIS
-- =========================================

-- =========================================
-- BANK FAILURE RATE ANALYSIS
-- Rank banks based on transaction failure percentage
-- =========================================
SELECT
sender_bank,
ROUND(
SUM(CASE WHEN transaction_status='FAILED' THEN 1 ELSE 0 END)
*100.0/COUNT(*),
2
) AS failure_rate,
RANK() OVER (
ORDER BY
ROUND(
SUM(CASE WHEN transaction_status='FAILED' THEN 1 ELSE 0 END)
*100.0/COUNT(*),
2
) DESC
) AS failure_rank
FROM upi_transactions
GROUP BY sender_bank;

WITH bank_transactions AS (
SELECT
sender_state,
sender_bank,
COUNT(*) AS total_transactions
FROM upi_transactions
GROUP BY sender_state, sender_bank
)
SELECT *
FROM (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY sender_state
ORDER BY total_transactions DESC
) AS rn
FROM bank_transactions
) ranked
WHERE rn = 1;

SELECT * FROM upi_transactions LIMIT 10;
SELECT VERSION();
-- =========================================
-- STATE-WISE BANK TRANSACTION ANALYSIS
-- Compare transaction distribution across banks and states
-- =========================================
SELECT
sender_state,
sender_bank,
COUNT(*) AS total_transactions
FROM upi_transactions
GROUP BY sender_state, sender_bank
ORDER BY sender_state, total_transactions DESC;
-- =========================================
-- PEAK TRANSACTION HOURS
-- Identify hours with highest UPI transaction activity
-- =========================================
SELECT hour_of_day, COUNT(*) AS total_transactions
FROM upi_transactions
GROUP BY hour_of_day
ORDER BY total_transactions DESC;
-- =========================================
-- FRAUD ANALYSIS BY TRANSACTION VALUE
-- Analyze fraud rates across transaction amount ranges
-- =========================================
SELECT
  CASE
    WHEN amount_in_INR < 500   THEN 'Under 500'
    WHEN amount_in_INR < 2000  THEN '500–2000'
    WHEN amount_in_INR < 10000 THEN '2000–10000'
    ELSE 'Above 10000'
  END AS amount_bracket,
  COUNT(*) AS total,
  SUM(fraud_flag) AS fraud_count,
  ROUND(SUM(fraud_flag)*100.0/COUNT(*), 2) AS fraud_rate
FROM upi_transactions
GROUP BY amount_bracket
ORDER BY fraud_rate DESC;
-- =========================================
-- AGE GROUP SPENDING ANALYSIS
-- Analyze spending behavior across customer age groups
-- =========================================
SELECT
  sender_age_group,
  ROUND(AVG(amount_in_INR), 2) AS avg_transaction,
  ROUND(SUM(amount_in_INR), 2) AS total_spending,
  COUNT(*) AS total_transactions
FROM upi_transactions
GROUP BY sender_age_group
ORDER BY avg_transaction DESC;
-- =========================================
-- MERCHANT CATEGORY ANALYSIS
-- Compare transaction value and fraud trends across categories
-- =========================================
SELECT
  merchant_category,
  ROUND(AVG(amount_in_INR), 2) AS avg_amount,
  ROUND(SUM(amount_in_INR), 2) AS total_value,
  ROUND(SUM(fraud_flag)*100.0/COUNT(*), 2) AS fraud_rate
FROM upi_transactions
GROUP BY merchant_category
ORDER BY avg_amount DESC;
-- =========================================
-- FAILURE RATE BY HOUR
-- Analyze transaction reliability during different hours of the day
-- =========================================
SELECT
  hour_of_day,
  COUNT(*) AS total,
  ROUND(SUM(CASE WHEN transaction_status='FAILED' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS failure_rate
FROM upi_transactions
GROUP BY hour_of_day
ORDER BY failure_rate DESC;
-- =========================================
-- FRAUD SUMMARY USING CTE
-- Identify high-risk combinations of age group and merchant category
-- =========================================
WITH fraud_summary AS (
  SELECT
    sender_age_group,
    merchant_category,
    COUNT(*) AS total_transactions,
    SUM(fraud_flag) AS fraud_count,
    ROUND(AVG(amount_in_INR), 2) AS avg_amount,
    ROUND(SUM(fraud_flag)*100.0/COUNT(*), 2) AS fraud_rate
  FROM upi_transactions
  GROUP BY sender_age_group, merchant_category
)
SELECT *
FROM fraud_summary
WHERE fraud_count > 0
ORDER BY fraud_rate DESC
LIMIT 15;
-- =========================================
-- MONTH-OVER-MONTH TRANSACTION GROWTH
-- Analyze monthly transaction trends using LAG() window function
-- =========================================
WITH monthly AS (
  SELECT
    MONTH(timestamp) AS txn_month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_in_INR), 2) AS total_value
  FROM upi_transactions
  GROUP BY MONTH(timestamp)
)

SELECT *,
  LAG(total_transactions) OVER (ORDER BY txn_month) AS prev_month_txns,
  ROUND(
    (total_transactions - LAG(total_transactions) OVER (ORDER BY txn_month))
    * 100.0 /
    LAG(total_transactions) OVER (ORDER BY txn_month),
  2) AS mom_growth_percent
FROM monthly;
-- =========================================
-- OVERALL KPI SUMMARY
-- Calculate core transaction and fraud performance metrics
-- =========================================
SELECT
  COUNT(*) AS total_transactions,
  ROUND(SUM(amount_in_INR), 2) AS total_value,
  ROUND(AVG(amount_in_INR), 2) AS avg_transaction,
  ROUND(SUM(CASE WHEN transaction_status='SUCCESS' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS success_rate,
  ROUND(SUM(CASE WHEN transaction_status='FAILED' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS failure_rate,
  ROUND(SUM(fraud_flag)*100.0/COUNT(*), 2) AS fraud_rate
FROM upi_transactions;
-- =========================================
-- WEEKEND VS WEEKDAY ANALYSIS
-- Compare transaction behavior during weekends and weekdays
-- =========================================
SELECT
  is_weekend,
  COUNT(*) AS total_transactions,
  ROUND(AVG(amount_in_INR), 2) AS avg_transaction,
  ROUND(SUM(amount_in_INR), 2) AS total_spending,
  ROUND(SUM(fraud_flag)*100.0/COUNT(*), 2) AS fraud_rate
FROM upi_transactions
GROUP BY is_weekend;
-- =========================================
-- TRANSACTION DISTRIBUTION BY AGE GROUP
-- Compare minimum, average, and maximum transaction values by age
-- =========================================
SELECT
  sender_age_group,
  ROUND(MIN(amount_in_INR), 2) AS min_txn,
  ROUND(AVG(amount_in_INR), 2) AS avg_txn,
  ROUND(MAX(amount_in_INR), 2) AS max_txn,
  COUNT(*) AS total,
  SUM(fraud_flag) AS fraud_count
FROM upi_transactions
GROUP BY sender_age_group
ORDER BY avg_txn DESC;
-- =========================================
-- DAY-WISE TRANSACTION ANALYSIS
-- Analyze transaction activity and failure trends across weekdays
-- =========================================
SELECT
  day_of_week,
  COUNT(*) AS total_transactions,
  ROUND(SUM(amount_in_INR), 2) AS total_spending,
  ROUND(SUM(CASE WHEN transaction_status='FAILED' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS failure_rate
FROM upi_transactions
GROUP BY day_of_week
ORDER BY total_transactions DESC;

USE upi_analysis_excel;
SHOW TABLES;

SELECT COUNT(*) FROM upi_transactions;

SHOW TABLES;
SELECT COUNT(*) FROM upi_transactions;
-- =========================================
-- TRANSACTION TYPE PERFORMANCE ANALYSIS
-- Compare transaction volume, value, fraud rate, and failure rate
-- =========================================
SELECT
  transaction_type,
  COUNT(*) AS total_transactions,
  ROUND(SUM(amount_in_INR), 2) AS total_value,
  ROUND(AVG(amount_in_INR), 2) AS avg_value,
  ROUND(SUM(fraud_flag)*100.0/COUNT(*), 2) AS fraud_rate,
  ROUND(SUM(CASE WHEN transaction_status='FAILED' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS failure_rate
FROM upi_transactions
GROUP BY transaction_type
ORDER BY total_transactions DESC;
-- =========================================
-- BANK PAIR FAILURE ANALYSIS
-- Identify sender and receiver bank combinations with highest failures
-- =========================================
SELECT
sender_bank,
receiver_bank,
COUNT(*) AS failed_transactions
FROM upi_transactions
WHERE transaction_status='FAILED'
GROUP BY sender_bank, receiver_bank
ORDER BY failed_transactions DESC;
-- =========================================
-- TRANSACTION TYPE PEAK HOUR ANALYSIS
-- Identify peak usage hours for different transaction types
-- =========================================
SELECT
transaction_type,
hour_of_day,
COUNT(*) AS total_transactions
FROM upi_transactions
GROUP BY transaction_type, hour_of_day
ORDER BY transaction_type, total_transactions DESC;
-- =========================================
-- END OF SQL ANALYSIS PROJECT
-- =========================================
