# UPI-Transaction-Analysis
## Project Overview

This project focuses on analyzing large-scale UPI transaction data using SQL, Exploratory Data Analysis (EDA), and Power BI to generate meaningful business insights.

The project simulates a real-world fintech analytics workflow where transaction data is analyzed to identify customer behavior, fraud trends, bank performance, transaction patterns, and operational insights.

The analysis was performed on a dataset containing 100,000+ UPI transactions.

---

# Tools & Technologies Used

- MySQL
- SQL
- Power BI
- DAX
- Excel / CSV
- GitHub

---

# Dataset Information

The dataset contains the following attributes:

- transaction_id
- timestamp
- transaction_type
- merchant_category
- amount_in_INR
- transaction_status
- sender_age_group
- receiver_age_group
- sender_state
- sender_bank
- receiver_bank
- device_type
- network_type
- fraud_flag
- hour_of_day
- day_of_week
- is_weekend

---

# Exploratory Data Analysis (EDA)

EDA was performed to understand transaction patterns and identify meaningful trends within the dataset.

### EDA Tasks Performed

- Transaction distribution analysis
- Fraud pattern analysis
- Missing value inspection
- Bank-wise transaction analysis
- Time-based transaction analysis
- Customer spending analysis
- Merchant category analysis
- Device-type fraud analysis

---

# SQL Analysis Performed

The project includes multiple SQL queries to perform operational and business analysis.

### SQL Concepts Used

- GROUP BY
- Aggregate Functions
- CASE WHEN
- Window Functions
- ROW_NUMBER()
- RANK()
- LAG()
- Common Table Expressions (CTEs)
- ORDER BY
- Filtering using WHERE clause
- Multi-column grouping
- Fraud analysis queries

---

# Key SQL Insights

## Bank Performance Analysis
- Identified banks with highest transaction volumes
- Calculated bank-wise transaction failure rates
- Compared successful vs failed transactions

## Fraud Analysis
- Fraud distribution across merchant categories
- Fraud analysis by transaction amount range
- Fraud occurrence by device type
- Fraud analysis by customer demographics

## Time-Based Analysis
- Peak transaction hours
- Monthly transaction trends
- Weekday transaction activity
- Weekend vs weekday usage patterns

## Customer Analysis
- Spending analysis by age group
- Average transaction value by merchant category
- Transaction type distribution

---

# Power BI Dashboard

An interactive Power BI dashboard was created to visualize business insights and operational trends.

The dashboard was divided into 4 analytical pages for better storytelling and analysis.

---

# Dashboard Pages

## 1. Executive Overview
Contains:
- Total Transactions
- Total Transaction Value
- Average Transaction Value
- Success Rate
- Fraud Rate
- Monthly Transaction Trends
- Transaction Type Distribution

---

## 2. Bank Performance Analysis
Contains:
- Bank Failure Rate Analysis
- Transaction Volume by Bank
- Bank Market Share
- Bank Pair Failure Analysis
- Success vs Failed Transactions by Bank

---

## 3. Time & Usage Analysis
Contains:
- Peak Transaction Hours
- Weekday Transaction Activity
- Weekend vs Weekday Transactions
- Transaction Success vs Failure by Hour

---

## 4. Fraud & Customer Analysis
Contains:
- Fraud Cases by Merchant Category
- Fraud by Transaction Amount Range
- Spending by Age Group
- Fraud by Device Type
- Average Transaction Value by Merchant Category

---

