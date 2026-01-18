# SQL Data Cleaning & Exploratory Analysis

## Overview
This project demonstrates data inspection, cleaning, and exploratory analysis using **Microsoft SQL Server**.  
The goal is to identify data quality issues in a real-world transactional dataset and prepare an analysis-ready table using SQL.

## Dataset
- **Online Retail Dataset**
- ~540,000 raw transaction records
- Common data issues:
  - Missing customer identifiers
  - Cancelled transactions
  - Invalid quantities and prices
  - Inconsistent date formats

## What Was Done
- Inspected raw data schema, size, and time range
- Identified missing values and invalid records
- Removed cancelled transactions and invalid rows
- Performed defensive type conversions using `TRY_CONVERT`
- Created a clean, analysis-ready dataset
- Conducted light exploratory analysis to validate data quality

## SQL Techniques Used
- Schema inspection (`INFORMATION_SCHEMA`)
- Data quality checks
- Filtering and cleaning logic
- Type casting and validation
- Aggregations for exploratory analysis

## Outcome
The dataset was reduced from ~540K raw records to ~161K high-quality transactions suitable for further analysis.

## Tools
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
