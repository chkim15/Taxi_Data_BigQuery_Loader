# Taxi Data BigQuery Loader

This repository contains scripts and configuration to load taxi data from a PostgreSQL dump into BigQuery.

## Tables
- taxi_search_history
- taxi_request

## Setup

1. Clone this repository
2. Install required dependencies: `pip install -r requirements.txt`
3. Configure `.env` file with your credentials
4. Run the loading scripts

## Usage

```bash
# Process the SQL dump
python scripts/process_sql_dump.py

# Load to BigQuery
python scripts/load_to_bigquery.py
```
